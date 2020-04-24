# Convert DER-encoded certificate to something...

module.exports = der2

forge$ = require  \./forge

formatters = {der, pem, txt, asn1, x509}

list = []
for k, v of formatters
  der2[k] = list.length
  list.push v

der2.forge = der2.x509

is-buffer = Buffer.is-buffer

buffer-from = Buffer.from || (data, encoding)->
  new Buffer data, encoding

function der2(format, blob)
  converter = list[format] || list[0]
  if blob?
    converter blob
  else
    converter

# Individual converters below
function der
  if is-buffer it
    it
  else
    buffer-from it, \binary

function pem
  it = der it .toString \base64
  lines = ['-----BEGIN CERTIFICATE-----']
  for i til it.length by 64
    lines.push it.substr i , 64
  lines.push '-----END CERTIFICATE-----' ''
  lines.join "\r\n"

function txt
  crt = asn1 it
  d = new Date
  """
  Subject\t#{
    crt.subject.value.map (.value[0].value[1].value) .join '/'}
  Valid\t#{
    crt.valid.value.map (.value) .join ' - '}
  #{pem it}
  """

function asn1
  asn1parser = forge$!asn1
  it .= to-string \binary
  crt = asn1parser.from-der it   # Certificate
    .value[0].value             # TBSCertificate
  serial = crt[0]
  has-serial =
    serial.tag-class == asn1parser.Class.CONTEXT_SPECIFIC and
    serial.type == 0 and
    serial.constructed
  crt = crt.slice has-serial
  serial:  crt[0]
  valid:   crt[3]
  issuer:  crt[2]
  subject: crt[4]

function x509
  it.to-string \binary
  |>  forge$!asn1.from-der
  |>  forge$!pki.certificate-from-asn1
