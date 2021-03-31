from cvdupdate.cvdupdate import CVDUpdate
import schedule
import logging
import os
import http.server
import socketserver


def update():
    m = CVDUpdate(config='', verbose=False)
    errors = m.db_update()
    if errors > 0:
        # TODO: handle errors
        pass


if __name__ == "__main__":
    # Update the mirror every 4 hours
    schedule.every(5).hours.do(update)
    logging.info("Performing initial update")
    update()

    logging.info("Starting web server")
    try:
        os.chdir('/clamav')
        with socketserver.TCPServer(("", 80), http.server.SimpleHTTPRequestHandler) as httpd:
            logging.info("Now serving at port TCP 80")
            httpd.serve_forever()
    except:
        logging.error("Failed bringing up the web server.")
