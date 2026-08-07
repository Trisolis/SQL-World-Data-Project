# Pandas cleanup script (raw into clean csv data)
import pandas as pd

# Global_countries.csv
df = pd.read_csv("global_countries.csv")

# Global_cities_public.csv
df = pd.read_csv("global_cities_public.csv")

# Global_economy.csv
df = pd.read_csv("global_economy.csv")

# Global_population.csv
df = pd.read_csv("global_population.csv")