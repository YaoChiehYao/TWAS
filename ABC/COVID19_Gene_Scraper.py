import requests
from bs4 import BeautifulSoup

# scrape GeneLists from CDC as a control
url = 'https://phgkb.cdc.gov/PHGKB/coVInfoFinder.action?Mysubmit=geneList&dbTypeChoice=all&order=name'

response = requests.get(url)

if response.status_code == 200:
    soup = BeautifulSoup(response.text, 'html.parser')

    # html structure tbody -> tr -> td -> first a tag
    gene_symbols = [tr.select_one('a').text for tr in soup.select(
        'tbody tr') if tr.select_one('a')]

    # save the gene symbols to a text file with a header
    with open('data/GeneLists.COVID19.txt', 'w') as file:
        file.write('CDC_COVID19_GeneLists\n')

        for symbol in gene_symbols:
            file.write(symbol + '\n')

    print("The gene symbols with a header have been saved to GeneLists.COVID19.txt")
else:
    print("Failed to fetch the webpage. Status code:", response.status_code)
