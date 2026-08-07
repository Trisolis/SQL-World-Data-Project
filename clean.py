# Pandas cleanup script (raw into clean csv data)
import pandas as pd
import pycountry

# Valid ISO2 codes
valid_iso = set(country.alpha_2 for country in pycountry.countries)

# To convert ISO3 format to ISO2 (for HDI and GDP data)
def iso3_to_iso2(code):
    try:
        return pycountry.countries.get(alpha_3=code).alpha_2
    except:
        return None


# --- MAIN DATASETS --- #

# Global_countries.csv
countries = pd.read_csv("./data/raw/global_countries.csv")
countries = countries[countries["iso_code"].isin(valid_iso)]                                 # removes non-country rows (territories, oceans, world)
countries = countries[["iso_code", "name_en", "region"]]                                     # removes unnecessary columns
countries = countries.rename(columns={'name_en' : 'name'})                                   # renames columns for easy referring

# Global_cities_public.csv
cities = pd.read_csv("./data/raw/global_cities_public.csv")
cities = cities[cities["iso2"].isin(valid_iso)]                                              # removes non-country rows (territories, oceans, world)
cities = cities[(cities['population'] >= 500000) | (cities["feature_code"] == "PPLC")]       # only includes cities w/ pop >= 500k OR that are capitals
cities = cities[["city_name", "country_name", "iso2", "region", 
                 "latitude", "longitude", "population", "elevation", 
                 "timezone", "feature_code"]]                                                # removes unnecessary columns
cities = cities.rename(columns={'city_name' : 'name', 
                                'country_name' : 'country',})                                # renames columns for easy referring
cities.to_csv("./data/clean/cities.csv", index=False)

# Global_economy.csv
economy = pd.read_csv("./data/raw/global_economy.csv")
economy = economy[economy["iso_code"].isin(valid_iso)]                                       # removes non-country rows (territories, oceans, world)
economy = economy[["iso_code", "name_en", "gdp_ppp", "gdp_per_capita", 
                   "inflation", "unemployment", "public_debt_pct"]]                          # removes unnecessary columns
economy = economy.rename(columns={'name_en' : 'name'})                                       # renames columns for easy referring

# Global_population.csv
indicators = pd.read_csv("./data/raw/global_population.csv")
indicators = indicators[indicators["iso_code"].isin(valid_iso)]                              # removes non-country rows (territories, oceans, world)
indicators = indicators[["iso_code", "name_en", "population", "birth_rate",
                         "death_rate", "life_expectancy", "literacy_rate",
                         "area_sq_km", "population_density"]]                                # removes unnecessary columns
indicators = indicators.rename(columns={'name_en' : 'name',
                                        'area_sq_km' : 'area',
                                        'population_density' : 'density'})                   # renames columns for easy referring


# --- SUPPLEMENTARY DATA --- #

# HDI 
hdi = pd.read_csv("./data/raw/human-development-index.csv")
hdi["iso_code"] = hdi["Code"].apply(iso3_to_iso2)                       # convert ISO3 to ISO2
hdi = hdi.sort_values("Year")                                           # sort by year to grab only the latest year's data
hdi = hdi.groupby("iso_code").last().reset_index() 
hdi = hdi[["iso_code", "Human Development Index"]]
hdi.columns = ["iso_code", "hdi"]

indicators = pd.merge(indicators, hdi, on="iso_code", how="left")

# Move area to countries, then drop from indicators
countries = pd.merge(countries, indicators[["iso_code", "area"]], on="iso_code", how="left")
countries.to_csv("./data/clean/countries.csv", index=False)

indicators = indicators.drop(columns=["area"])
indicators.to_csv("./data/clean/indicators.csv", index=False)

# GDP
gdp = pd.read_csv("./data/raw/gdp-worldbank-constant-usd.csv")
gdp["iso_code"] = gdp["Code"].apply(iso3_to_iso2)                       # convert ISO3 to ISO2
gdp = gdp.sort_values("Year")                                           # sort by year to grab only the latest year's data
gdp = gdp.groupby("iso_code").last().reset_index()
gdp = gdp[["iso_code", "GDP"]]
gdp.columns = ["iso_code", "gdp"]

economy = pd.merge(economy, gdp, on="iso_code", how="left")
economy.to_csv("./data/clean/economy.csv", index=False)


# --- QUICK TESTS ---
print("Countries:", pd.read_csv("./data/clean/countries.csv").shape)
print("Cities:", pd.read_csv("./data/clean/cities.csv").shape)
print("Economy:", pd.read_csv("./data/clean/economy.csv").shape)
print("Indicators:", pd.read_csv("./data/clean/indicators.csv").shape)