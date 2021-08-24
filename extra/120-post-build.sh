#!/bin/bash

# Hook on post-build sequence

# Example:
# magento setup:upgrade

sudo -u vagrant "$PROJECT_PATH"/bin/magento module:disable Magento_TwoFactorAuth
sudo -u vagrant "$PROJECT_PATH"/bin/magento setup:upgrade
sudo -u vagrant "$PROJECT_PATH"/bin/magento setup:di:compile
chown -fR vagrant:www-data "$PROJECT_PATH"/composer.json