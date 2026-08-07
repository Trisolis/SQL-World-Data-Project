# Pandas cleanup script (raw into clean csv data)
import pandas as pd
import pycountry

# Creates a list of valid country ISO's
valid_iso = set(country.alpha_2 for country in pycountry.countries)

# Global_countries.csv
df = pd.read_csv("./data/raw/global_countries.csv")
df = df[df["iso_code"].isin(valid_iso)]                                 # removes non-country rows (territories, oceans, world)
df = df[["iso_code", "name_en", "region"]]                              # removes unnecessary columns
df = df.rename(columns={'name_en' : 'name'})                            # renames columns for easy referring
df.to_csv("./data/clean/countries.csv", index=False)

# Global_cities_public.csv
df = pd.read_csv("./data/raw/global_cities_public.csv")
df = df[df["iso2"].isin(valid_iso)]                                     # removes non-country rows (territories, oceans, world)
df = df[(df['population'] >= 500000) | (df["feature_code"] == "PPLC")]  # only includes cities w/ pop >= 500k OR that are capitals
df = df[["city_name", "country_name", "iso2", "region", 
         "latitude", "longitude", "population", "elevation", 
         "timezone", "feature_code"]]                                   # removes unnecessary columns
df = df.rename(columns={'city_name' : 'name', 
                        'country_name' : 'country',})                   # renames columns for easy referring
df.to_csv("./data/clean/cities.csv", index=False)

# Global_economy.csv
df = pd.read_csv("./data/raw/global_economy.csv")
df = df[df["iso_code"].isin(valid_iso)]                                 # removes non-country rows (territories, oceans, world)
df = df[["iso_code", "name_en", "gdp_ppp", "gdp_per_capita", 
         "inflation", "unemployment", "public_debt_pct"]]               # removes unnecessary columns
df = df.rename(columns={'name_en' : 'name'})                            # renames columns for easy referring
df.to_csv("./data/clean/economy.csv", index=False)

# Global_population.csv
df = pd.read_csv("./data/raw/global_population.csv")
df = df[df["iso_code"].isin(valid_iso)]                                 # removes non-country rows (territories, oceans, world)
df = df[["iso_code", "name_en", "population", "birth_rate",
         "death_rate", "life_expectancy", "literacy_rate",
         "area_sq_km", "population_density"]]                           # removes unnecessary columns
df = df.rename(columns={'name_en' : 'name',
                        'area_sq_km' : 'area',
                        'population_density' : 'density'})              # renames columns for easy referring
df.to_csv("./data/clean/indicators.csv", index=False)

# Quick tests
print(df.shape)      # rows and columns
print(df.head())     # first few rows
print(df.isnull().sum())  # null counts per column