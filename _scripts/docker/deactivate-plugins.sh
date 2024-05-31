#!/bin/bash

echo "Deactivating production plugins..."
wp plugin deactivate \
  --allow-root \
  --skip-plugins \
  --skip-themes \
  better-wp-security \
  ithemes-security-pro \
  malcare-security \
  all-in-one-wp-security-and-firewall \
  gotmls \
  wordfence \
  wp-offload-ses \
  wp-mail-smtp \
  wp-mail-smtp-pro \
  fluent-smtp \
  wp-rocket \
  w3-total-cache \
  wp-optimize \
  litespeed-cache \
  login-lockdown \
  akismet \
  wp-super-cache \
  wp-super-minify \
  wp-fastest-cache \
  wp-fastest-cache-premium \
  worker \
  recaptcha-for-woocommerce \
  really-simple-ssl \
  redirection \
  autoptimize \
  mailgun \
  wp-staging \
  easy-wp-smtp \
  offload-media-cloud-storage \
  wp-mail-bank \
  post-smtp \
  google-site-kit \
  google-analytics-for-wordpress \
  ga-google-analytics \
  wpo365-login \
  breeze \
  object-cache-pro \
  webp-express \
  admin-site-enhancements \
  perfmatters \
  cloudflare \
  password-protected