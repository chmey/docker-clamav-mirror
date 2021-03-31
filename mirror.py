from cvdupdate.cvdupdate import CVDUpdate
import threading
import logging
import os
import time
import http.server
import socketserver

# Update the mirror every N hours
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
    logging.info("Performing initial update")
    t = threading.Thread(target=keep_updating)
    t.start()

    logging.info("Starting web server")
    try:
        os.chdir('/clamav')
        with socketserver.TCPServer(("", 80), http.server.SimpleHTTPRequestHandler) as httpd:
            logging.info("Now serving at port TCP 80")
            httpd.serve_forever()
    except Exception as e:
        logging.error("Failed bringing up the web server. %s" % e)
