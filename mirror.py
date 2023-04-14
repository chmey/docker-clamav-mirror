"""clamav-mirror-docker"""
from cvdupdate.cvdupdate import CVDUpdate
import threading
import logging
import os
import time
import http.server
import socketserver

# Updating ClamAV databases once EVERY_N_HOURS hours.
EVERY_N_HOURS = 4

def update():
    m = CVDUpdate(config='', verbose=False)
    errors = m.db_update()
    if errors > 0:
        # TODO: handle errors
        pass

def keep_updating():
    while True:
        logging.info("Performing update!")
        update()
        time.sleep(60 * 60 * EVERY_N_HOURS)

if __name__ == "__main__":
    logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"))
    logging.info("Performing initial update")
    t = threading.Thread(target=keep_updating)
    t.start()

    logging.info("Starting web server")
    try:
        time.sleep(60)
        os.chdir('/home/app-user/.cvdupdate/database')
        with socketserver.TCPServer(("", 80), http.server.SimpleHTTPRequestHandler) as httpd:
            logging.info("Now serving at port TCP 80")
            httpd.serve_forever()
    except Exception:
        logging.error("Failed bringing up the web server")