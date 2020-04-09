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

def get_lagged_df(df, index_col="Date", col2lag=["Open_SNP500"] , n=1):
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

def split_data(df_filepath):
    temp_df = pd.read_csv(df_filepath)
    first = temp_df[temp_df['Date'] == '1/7/2019'].index[0]
    second = temp_df[temp_df['Date'] == '31/12/2019'].index[0]
    data = temp_df.iloc[:first]
    psuedo_OOB = temp_df.iloc[first:second+1]
    OOB = temp_df.iloc[second+1:]

    return data.set_index("Date"), psuedo_OOB.set_index("Date"), OOB.set_index("Date")

if __name__ == '__main__':
    # get_lagged("./data/PPH_pharm_etf.csv", n=2)
    # df = pd.read_csv("./data/output.csv")

    # final_df = get_lagged_df(df, col2lag=["Open_Pharm", "Volume_Pharm"],n=3).head()
    # print(final_df)
    data, psuedo_OOB, OOB = split_data("./data/output.csv")
    print(psuedo_OOB.tail())
    print(OOB.head())