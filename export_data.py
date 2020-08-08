import mysql.connector
from datetime import datetime
import os

db = mysql.connector.connect( 
                   user='scraper',
                   password='scraper',
                   database = 'scraping_results',
                   host='127.0.0.1', 
                   port=3306)

cur = db.cursor(buffered = False)


now = datetime.now().strftime('%Y%m%d%H%M%S')

export_data_path = 'data/immo_data_%s.csv' % now
export_cnt = 0

fo = open(export_data_path, 'a')

cur.execute("""
select r.*, t.*
from(
	select a.data_run, a.data_prima_presenza_online , a.data_ultima_presenza_online ,a.affitto, d.*
	from dettaglio as d
	join annuncio as a
	on d.url_id = a.url_id
) as t
join reversegecodingad as r 
on t.url_id = r.url_id
where r.comune != ''
""")

fo.writelines('"'+'";"'.join([i[0] for i in cur.description])+'"'+'\n')

row = cur.fetchone()

while row is not None:
    
    fo.writelines('"'+'";"'.join([str(i).replace(';', '') for i in row])+'"'+'\n')
    
    export_cnt += 1
    
    if export_cnt % 10000 == 0 :
        print('Scritte %d righe' % export_cnt)
    
    row = cur.fetchone()
    
print('Finito con %d righe' % export_cnt)

fo.close()

print('Compressione del file')
os.system('tar -cvzf %s.tar.gz %s' % (export_data_path, export_data_path))

print('Rimozione file csv')
os.remove(export_data_path)

print('END')
cur.close()
db.close()
