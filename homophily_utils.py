import pandas as pd
import numpy as np
import networkx as nx

def random_sampling(population_data, group_size, num_groups=None, seed=123):
    seed = seed #TODO: fix this
    available_data = population_data.copy()
    
    if num_groups is None: # Default to as many groups as possible
        num_groups = len(available_data) // group_size
    
    assert group_size * num_groups <= len(population_data), "Not enough data to create the specified number of groups."
    
    groups = []

    for group_id in range(1, num_groups + 1):  # Group IDs start at 1
        group_members = available_data.sample(n=group_size, random_state=seed)
        available_data = available_data.drop(group_members.index)
        group_members['group_id'] = group_id
        groups.append(group_members)
    
    # Combine all groups into a single DataFrame
    all_groups_df = pd.concat(groups, axis=0).reset_index(drop=True)
    
    # Reorder columns to place 'group_id' first
    columns = ['group_id'] + [col for col in all_groups_df.columns if col != 'group_id']
    all_groups_df = all_groups_df[columns]
    
    return all_groups_df


def biased_sampling_by_trait(population_data, group_size, trait, secondary_trait = None, num_groups = None, seed = 123):
    np.random.seed(seed)
    available_data = population_data.copy()
    
    if num_groups is None: # Default to as many groups as possible
        num_groups = len(available_data) // group_size
    
    assert group_size * num_groups <= len(population_data), "Not enough data to create the specified number of groups."

    
    groups = []

    for group_id in range(1, num_groups + 1): #group IDs start at 1
        group_members = []

        anchor = available_data.sample(1, random_state = seed)
        anchor_value = anchor[trait].values[0]
        group_members.append(anchor)
        available_data = available_data.drop(anchor.index)

        #add similar individuals
        similar_trait_data = available_data[available_data[trait] == anchor_value]

        while len(group_members) < group_size and not available_data.empty:
            if not similar_trait_data.empty: # Select an indiv with the same trait value
                next_individual = similar_trait_data.sample(1) 
            elif secondary_trait: # If a secondary trait is specified, select based on that
                current_secondary_values = pd.concat(group_members)[secondary_trait]
                majority_secondary_value = current_secondary_values.mode()[0]  # Find group majority
                secondary_trait_data = available_data[available_data[secondary_trait] == majority_secondary_value]
                if not secondary_trait_data.empty:
                    next_individual = secondary_trait_data.sample(1)
                else: # Fallback to random
                    next_individual = available_data.sample(1)  
            else: # Final Fallback: Randomly select if no matches remain
                next_individual = available_data.sample(1)      
                next_individual = available_data.sample(1) 

            group_members.append(next_individual)
            available_data = available_data.drop(next_individual.index)
            similar_trait_data = available_data[available_data[trait] == anchor_value]


        # Combine group members into a DataFrame and save the group
        group_df = pd.concat(group_members, axis=0)
        group_df['group_id'] = group_id
        groups.append(group_df)

    # Combine all groups into a single DataFrame
    all_groups_df = pd.concat(groups, axis = 0).reset_index(drop = True)
    columns = ['group_id'] + [col for col in all_groups_df.columns if col != 'group_id'] #Move 'group_id' to the first column
    all_groups_df = all_groups_df[columns]

    return all_groups_df


def homophily_function(node1, node2, G, weights, max_distances): #TODO: incorporate euclidean distance?
    '''Homophily function for edge prediction
    The output should be the number of hours the two people in the edge spend together'''

    normalized_total_distance = 0
    max_normalized_total_distance = sum(weights.values())

    for attribute, weight in weights.items():
        value1 = G.nodes[node1].get(attribute)
        value2 = G.nodes[node2].get(attribute)
        max_attribute_distance = max_distances[attribute]

        #handle continuous variables
        if isinstance(value1, (int, float)) and isinstance(value2, (int, float)): #TODO: add handling of NA values
            absolute_distance = abs(value1 - value2)
            normalized_distance = absolute_distance / max_attribute_distance
            weighted_normalized_distance = normalized_distance * weight
            normalized_total_distance += weighted_normalized_distance

        #handle categorical variables
        elif isinstance(value1, str) and isinstance(value2, str):
            normalized_distance = 1 if value1 != value2 else 0
            normalized_total_distance += weight * normalized_distance

    #Convert distance to hours
    #TODO: use a nonmonotonic function here according to Bruggeman
    # Output score between 0 and 1
    score = 1 - (normalized_total_distance / max_normalized_total_distance)
    return round(score, 2)


def create_group_graph(support_group_data):
    n = len(support_group_data)
    G = nx.complete_graph(n)

    for i, row in support_group_data.iterrows():
        G.add_node(i, **row.to_dict())

    return G


def prepare_regression_data(G, attributes, max_distances):
    '''Prepares data for regression'''
    data = []

    for node1, node2, edge in G.edges(data=True):
        row = {}

        for attr in attributes:
            value1 = G.nodes[node1].get(attr, 0)
            value2 = G.nodes[node2].get(attr, 0)
            max_attribute_distance = max_distances[attr]

            # Absolute differences for continuous attributes
            if isinstance(value1, (int, float)) and isinstance(value2, (int, float)): #TODO: add handling o NA values
                absolute_distance = abs(value1 - value2)
                normalized_distance = absolute_distance / max_attribute_distance
                row[attr] = - normalized_distance

            # Binary differences for categorical attributes
            elif isinstance(value1, str) and isinstance(value2, str):
                row[attr] = - 1 if value1 != value2 else 0 #minus because distance has negative contribution to hours
                
        row['target'] = edge['weight']
        data.append(row)      

    return pd.DataFrame(data)