#!/usr/bin/env python
# pylint: disable=C0116


import logging
import requests

from telegram import Update
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackContext

# IPinfo.io token
Token = ''


logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO
)

logger = logging.getLogger(__name__)


def start(update: Update, _: CallbackContext) -> None:
    """Send a message when the command /start is issued."""
    update.message.reply_text('Send me an IPv4 address to start!\n\nDeveloped by @Huffiy in Python')



def echo(update: Update, _: CallbackContext) -> None:
    """Echo the user message."""
    ip = update.message.text
    print(ip)
    response = requests.get('http://ipinfo.io/' + ip + '?token=' + Token)
    print(response.text)
    update.message.reply_text(response.text)


def main() -> None:
    """Start the bot."""
    # Bot token from @BotFather
    updater = Updater("")

    dispatcher = updater.dispatcher

    dispatcher.add_handler(CommandHandler("start", start))

    dispatcher.add_handler(MessageHandler(Filters.text & ~Filters.command, echo))

    updater.start_polling()

    updater.idle()


if __name__ == '__main__':
    main()