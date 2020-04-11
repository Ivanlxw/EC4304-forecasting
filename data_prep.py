"""
Should take in csv from a file source 
and return pd.DataFrame, with its lagged values
"""

import pandas as pd

## returns a csv with lagged values
def get_lagged(filepath:str, index_col="Date", col2lag="Adj Close" , n=1) -> pd.DataFrame:
    '''
    check for filepath then check for pd.DataFrame in df
    '''
    temp_df = pd.read_csv(filepath, index_col=index_col)
    # lag the values
    for lag in range(n):
        temp_c_name = f"{col2lag}_{lag+1}"
        temp_df[temp_c_name] = temp_df[col2lag].shift(lag+1)
    
    ## remove NA values
    temp_df = temp_df.dropna()
    return temp_df

def get_lagged_df(df, index_col="Date", col2lag=["Adj Close_SNP500"] , n=1):
    '''
    col2lag - list (MUST). list items must be in df's columns
    '''
    temp_df = df

    # lag the values
    for collag in col2lag:
        for lag in range(n):
            temp_c_name = f"{collag}_L{lag+1}"
            temp_df[temp_c_name] = temp_df[collag].shift(lag+1)
    
    ## remove NA values
    temp_df = temp_df.dropna()
    return temp_df


## gets the % return of a columns
def get_perc_return(df_filepath, column_name, n=1) -> pd.DataFrame:
    '''
    Column has to be the name of a column in the csv file
    REturns data and result columns
    '''
    temp_df = pd.read_csv(df_filepath)
    target = temp_df[column_name]
    returns = (target - target.shift(n))/target.shift(n)
    temp_df['%_returns'] = returns 
    return temp_df[['Date', '%_returns']]

def get_perc_return_df(target, n=1) -> pd.DataFrame:
    '''
    Column has to be the name of a column in the csv file
    REturns data and result columns
    '''
    returns = (target - target.shift(n))/target.shift(n) * 100
    return returns

def split_data(df_filepath):
    temp_df = pd.read_csv(df_filepath)
    first = temp_df[temp_df['Date'] == '1/7/2019'].index[0]
    second = temp_df[temp_df['Date'] == '1/10/2019'].index[0]
    data = temp_df.iloc[:first]

    return data.set_index("Date"), first, second

if __name__ == '__main__':
    data, psuedo_OOB, OOB = split_data("./data/output.csv")
    print(psuedo_OOB.tail())
    print(OOB.head())