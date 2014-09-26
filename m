Return-Path: linux-nfs-owner@vger.kernel.org
Received: from postout1.mail.lrz.de ([129.187.255.137]:36814 "EHLO
	postout1.mail.lrz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbaIZQYf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 12:24:35 -0400
Message-ID: <54259341.30709@tum.de>
Date: Fri, 26 Sep 2014 18:24:33 +0200
From: Joschi Brauchle <joschi.brauchle@tum.de>
MIME-Version: 1.0
To: Jeff Layton <jlayton@poochiereds.net>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Fehenberger, Tobias" <tobias.fehenberger@tum.de>,
        "Stinner, Markus" <markus.stinner@tum.de>
Subject: Re: Need help debugging NFSv3+KRB5+PAT (Port Address Translation)
 problem
References: <542586EB.2040101@tum.de> <20140926115646.684c8e3c@tlielax.poochiereds.net>
In-Reply-To: <20140926115646.684c8e3c@tlielax.poochiereds.net>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms060903060404010301030804"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms060903060404010301030804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On 09/26/2014 05:56 PM, Jeff Layton wrote:
> On Fri, 26 Sep 2014 17:31:55 +0200
> Joschi Brauchle <joschi.brauchle@tum.de> wrote:
>
>> Hello everyone,
>>
>> I need some help debugging a NFSv3 + KRB5 + PAT (Port Address
>> Translation) problem.
>>
>> We have two hosts behind a firewall and an NFSv3 server outside
>> requiring KRB5 authentication.
>>
>> 1) Client_NAT is using NAT (network address translation),
>> 2) Client_PAT is using PAT (port address translation)
>> to reach the NFSv3 server through the firewall.
>>
>> Both clients are configured identically in terms of Kerberos and so on=
=2E
>>
>> Mounting an NFSv3 share now fails on Client_PAT with the message:
>> RPC: server SERVERNAME requires stronger authentication.
>> On Client_NAT, mounting succeeds.
>>
>> We strongly suspect the port address translation to be the reason for
>> the failure, but would need help confirming this and advice on how to
>> fix it.
>>
>> Please find here the RPC debug logs from
>> Client_NAT: http://pastebin.com/9RANqVgY
>> Client_PAT: http://pastebin.com/TiscNVqW
>> Here is a DIFF between the two: http://pastebin.com/wCg7WyYd
>>
>> I'm grateful for any help on this problem!
>>
>> Best regards,
>> Joschi Brauchle
>
> I'm not terribly familiar with the PAT vs. NAT distinction, but many
> NFS servers require you to use privileged ports to connect to them. Is
> your PAT client having its privileged port converted to a
> non-privileged one?
>
> If so (and if the server is Linux-based) then you can try to get around=

> that by exporting with the "insecure" export option.

We do not have control over the NFS server, but from the firewall logs I =

can see that the PAT client trying to access the server with an=20
originally privileged port (<1024) gets translated to a non-privileged=20
one. Shortly after that, the mount fails.

So I guess this is the problem! Thanks for the hint.


--------------ms060903060404010301030804
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIPnDCC
BNUwggO9oAMCAQICCFBOxvU9EbRkMA0GCSqGSIb3DQEBCwUAMHExCzAJBgNVBAYTAkRFMRww
GgYDVQQKExNEZXV0c2NoZSBUZWxla29tIEFHMR8wHQYDVQQLExZULVRlbGVTZWMgVHJ1c3Qg
Q2VudGVyMSMwIQYDVQQDExpEZXV0c2NoZSBUZWxla29tIFJvb3QgQ0EgMjAeFw0xNDA3MjIx
MjA4MjZaFw0xOTA3MDkyMzU5MDBaMFoxCzAJBgNVBAYTAkRFMRMwEQYDVQQKEwpERk4tVmVy
ZWluMRAwDgYDVQQLEwdERk4tUEtJMSQwIgYDVQQDExtERk4tVmVyZWluIFBDQSBHbG9iYWwg
LSBHMDEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDpm8NnhfkNrvWNVMOWUDU9
YuluTO2U1wBblSJ01CDrNI/W7MAxBAuZgeKmFNJSoCgjhIt0iQReW+DieMF4yxbLKDU5ey2Q
RdDtoAB6fL9KDhsAw4bpXCsxEXsM84IkQ4wcOItqaACa7txPeKvSxhObdq3u3ibo7wGvdA/B
CaL2a869080UME/15eOkyGKbghoDJzANAmVgTe3RCSMqljVYJ9N2xnG2kB3E7f81hn1vM7Pb
D8URwoqDoZRdQWvY0hD1TP3KUazZve+Sg7va64sWVlZDz+HVEz2mHycwzUlU28kTNJpxdcVs
6qcLmPkhnSevPqM5OUhqjK3JmfvDEvK9AgMBAAGjggGGMIIBgjAOBgNVHQ8BAf8EBAMCAQYw
HQYDVR0OBBYEFEm3xs/oPR9/6kR7Eyn38QpwPt5kMB8GA1UdIwQYMBaAFDHDeRu69VPXF+CJ
ei0XbAqzK50zMBIGA1UdEwEB/wQIMAYBAf8CAQIwYgYDVR0gBFswWTARBg8rBgEEAYGtIYIs
AQEEAgIwEQYPKwYBBAGBrSGCLAEBBAMAMBEGDysGAQQBga0hgiwBAQQDATAPBg0rBgEEAYGt
IYIsAQEEMA0GCysGAQQBga0hgiweMD4GA1UdHwQ3MDUwM6AxoC+GLWh0dHA6Ly9wa2kwMzM2
LnRlbGVzZWMuZGUvcmwvRFRfUk9PVF9DQV8yLmNybDB4BggrBgEFBQcBAQRsMGowLAYIKwYB
BQUHMAGGIGh0dHA6Ly9vY3NwMDMzNi50ZWxlc2VjLmRlL29jc3ByMDoGCCsGAQUFBzAChi5o
dHRwOi8vcGtpMDMzNi50ZWxlc2VjLmRlL2NydC9EVF9ST09UX0NBXzIuY2VyMA0GCSqGSIb3
DQEBCwUAA4IBAQBjICj9nCGGcr45Rlk5MiW8qQGbDczKfUGchm0KbiyzE1l1sTOSG2EnFv/D
stU1gvuEKgFJvWa7Zi+ywgZdbj9u4wFaW8pDY1yVtuExpx/VB19N5mWCTjL5w3x6S81NXHTu
IfJ1AuxSPtLJatOQI25JZzW+f01WpOzML8+3oZeocj7JvEDWWqQIPda8gsO3tzKOsSyOam23
NQIZz/U5RFhjpyQAELC7/E6vbi84u6VXST/YblBvLJeW3B1GmmWJz67M8uXZn1OzPqEvkqnY
C8aEHwTG6x7on321e6UC8STFJGMRNMxakyAqeYg6JUKQqWU7fIbTEhUjKfws2sw5W1QXMIIF
HTCCBAWgAwIBAgIHF5Bg3/QB2TANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQGEwJERTETMBEG
A1UEChMKREZOLVZlcmVpbjEQMA4GA1UECxMHREZOLVBLSTEkMCIGA1UEAxMbREZOLVZlcmVp
biBQQ0EgR2xvYmFsIC0gRzAxMB4XDTE0MDUxMjE1MDU1MVoXDTE5MDcwOTIzNTkwMFowYDEL
MAkGA1UEBhMCREUxKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11ZW5jaGVu
MSYwJAYDVQQDEx1aZXJ0aWZpemllcnVuZ3NzdGVsbGUgZGVyIFRVTTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKjv6NPYBFzJ+ZELc6JfE/5aga/7K7LWMVBHZvohdJZGd31p
N9QEfzQeph0kiqsm1X5kHraPtTc9jMH8SLASBI45JppNSSYRfw6j6RjKA7PUStRfV0dq5cBP
Bl5FpxAY23lAzMzY+6EQEq3/hS8Ia3zG5Q5saJsc+9B2So8+gvaVwZhrWhe7NhyvVqYMiBpT
E9fbViah3Ur5VdDpcGbsb/BqRDxRrOCjQdNQ6TCQHfIUEDTQMW/czj1wbgLxrp8sB5XlwMPX
7c2Do+yByWbcrkitdGEeagcWqC1gc8pD/f8PJIoVeW4cy60PjHRIfYC0NBVvg9P0viuwFEyW
M17brI8CAwEAAaOCAeAwggHcMBIGA1UdEwEB/wQIMAYBAf8CAQEwDgYDVR0PAQH/BAQDAgEG
MBEGA1UdIAQKMAgwBgYEVR0gADAdBgNVHQ4EFgQUnZ8j8BkbfscjXScqzKU2OqZp5YkwHwYD
VR0jBBgwFoAUSbfGz+g9H3/qRHsTKffxCnA+3mQwgYgGA1UdHwSBgDB+MD2gO6A5hjdodHRw
Oi8vY2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jcmwvY2FjcmwuY3JsMD2g
O6A5hjdodHRwOi8vY2RwMi5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jcmwvY2Fj
cmwuY3JsMIHXBggrBgEFBQcBAQSByjCBxzAzBggrBgEFBQcwAYYnaHR0cDovL29jc3AucGNh
LmRmbi5kZS9PQ1NQLVNlcnZlci9PQ1NQMEcGCCsGAQUFBzAChjtodHRwOi8vY2RwMS5wY2Eu
ZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDBHBggrBgEFBQcw
AoY7aHR0cDovL2NkcDIucGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1jYS9wdWIvY2FjZXJ0L2Nh
Y2VydC5jcnQwDQYJKoZIhvcNAQELBQADggEBANaFYIHzwjpv6JVEdDhka/NaydcN/TSxDEYw
I7YJ34SlUbk7FVykIRBWlTR8uEwUqhBgNtp1Rg+Kq8qSS9DtSnpOG5EqPvxJRN55x9zNCqZv
WINnVU+p0V/yOTn+mYBBlgQhgixSxBkanY8VoPBcjr2/i6cck1Mc8co3bZa8i32qCrX0E0mO
DGohpEVA6sllNkRU6NozLScnab7sibPN7K9w3gbCX61yCPfTvtmiWorJr/GgtLR4D7GczhoD
ofrJpBzxSacgckbZPirIEgloRZL+1X9kAAjka/hEXh+KYd3qkCdNiMAM8+/Por4Kg8Y/l1k+
CDudwzwDxAS9H0tcXl4wggWeMIIEhqADAgECAgcWcetffSz0MA0GCSqGSIb3DQEBBQUAMGAx
CzAJBgNVBAYTAkRFMSkwJwYDVQQKEyBUZWNobmlzY2hlIFVuaXZlcnNpdGFldCBNdWVuY2hl
bjEmMCQGA1UEAxMdWmVydGlmaXppZXJ1bmdzc3RlbGxlIGRlciBUVU0wHhcNMTMxMDA3MDgx
NjE2WhcNMTYxMDA2MDgxNjE2WjCB3TELMAkGA1UEBhMCREUxDzANBgNVBAgTBkJheWVybjER
MA8GA1UEBxMITXVlbmNoZW4xKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11
ZW5jaGVuMT4wPAYDVQQLEzVGYWt1bHRhZXQgZnVlciBFbGVrdHJvdGVjaG5payB1bmQgSW5m
b3JtYXRpb25zdGVjaG5pazEYMBYGA1UEAxMPSm9zY2hpIEJyYXVjaGxlMSUwIwYJKoZIhvcN
AQkBFhZqb3NjaGkuYnJhdWNobGVAdHVtLmRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAw1E6N5L0RYJp0kT8TWRT0tGChhKQxR4/dC67zOPWXS/eWUVt8jO0w39YJo/mBi3n
GyA7xwSgeLoODOkoo53afUxRRFqbPiSqSpHs0I0cePxzYVy+3ZcMg7J9RYsZESY1PrQMFmvh
TJSxzAwN6waIRyjoVZoTVB4/UC/QhaFbl4WZcIyIqOLq0wlRsrPJuXJiNW8IRsY6xxf5uP4w
2Foj9wPqoF4ssSaSHQzPVh2PaBoW5iCmHTV/iPaD9mjCGMSLbClIF7VYLMBMCSmfGgou0UlK
LQ24twb94xkba0QKo8a1GMU00HowMEBb3pY8e4sjHM0hGVzPHfjKf7Z2n774vwIDAQABo4IB
3TCCAdkwLwYDVR0gBCgwJjARBg8rBgEEAYGtIYIsAQEEAwAwEQYPKwYBBAGBrSGCLAIBBAMA
MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgXgMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUSD2MWx96Lbrr7Vaeh3rAprAP4OswHwYDVR0jBBgwFoAUnZ8j8Bkbfscj
XScqzKU2OqZp5YkwIQYDVR0RBBowGIEWam9zY2hpLmJyYXVjaGxlQHR1bS5kZTB3BgNVHR8E
cDBuMDWgM6Axhi9odHRwOi8vY2RwMS5wY2EuZGZuLmRlL3R1bS1jYS9wdWIvY3JsL2NhY3Js
LmNybDA1oDOgMYYvaHR0cDovL2NkcDIucGNhLmRmbi5kZS90dW0tY2EvcHViL2NybC9jYWNy
bC5jcmwwgZIGCCsGAQUFBwEBBIGFMIGCMD8GCCsGAQUFBzAChjNodHRwOi8vY2RwMS5wY2Eu
ZGZuLmRlL3R1bS1jYS9wdWIvY2FjZXJ0L2NhY2VydC5jcnQwPwYIKwYBBQUHMAKGM2h0dHA6
Ly9jZHAyLnBjYS5kZm4uZGUvdHVtLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDANBgkqhkiG
9w0BAQUFAAOCAQEAK98J5s+3aGhWqEPuUwxbm4jxMmLG+f6DbP5s/2AjHvWkGWwSgT9u503U
EjqLP7otgr0AFYWArffwTWv2i6Preh1OfhDHkm051LrOtFj+/lBjN+CwuFojG213BKDOno39
cARrIbSDqBdLpY11DJn7ejEchMj7xNqjt5TbMH40kUD6ApChMuJdilk4tEI/flkKbx4Eo8ba
PxPivXjyEXIgNOSSsZLjEG+rO0R5mko62OshCS+e099Z7aLcjLE5pxrlZ6+8Xlf0hTJ5BLhT
HJCCf5banfDrJK+MQzaMcEtfK5jKFhqxJK6gRomqlu7M3Ib1ApQ3u7WWZ1oug9zLE0ZzcDGC
A1swggNXAgEBMGswYDELMAkGA1UEBhMCREUxKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5pdmVy
c2l0YWV0IE11ZW5jaGVuMSYwJAYDVQQDEx1aZXJ0aWZpemllcnVuZ3NzdGVsbGUgZGVyIFRV
TQIHFnHrX30s9DAJBgUrDgMCGgUAoIIBxTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwG
CSqGSIb3DQEJBTEPFw0xNDA5MjYxNjI0MzNaMCMGCSqGSIb3DQEJBDEWBBSBM2SPv/GFZbVr
fwmUp1LydHBIbDBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjALBglghkgBZQMEAQIw
CgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0G
CCqGSIb3DQMCAgEoMHoGCSsGAQQBgjcQBDFtMGswYDELMAkGA1UEBhMCREUxKTAnBgNVBAoT
IFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11ZW5jaGVuMSYwJAYDVQQDEx1aZXJ0aWZpemll
cnVuZ3NzdGVsbGUgZGVyIFRVTQIHFnHrX30s9DB8BgsqhkiG9w0BCRACCzFtoGswYDELMAkG
A1UEBhMCREUxKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11ZW5jaGVuMSYw
JAYDVQQDEx1aZXJ0aWZpemllcnVuZ3NzdGVsbGUgZGVyIFRVTQIHFnHrX30s9DANBgkqhkiG
9w0BAQEFAASCAQBPVoT+wwf+bg7DI7q125f3t2kYke5qv4HMbDAIdNOFnQWRz26Wkxu4j/0h
6+W0V+17OlLoyz5zmKED9Sw4Hhk/HHfMmnTAF2UQdcXL2vizqX4aXDe/PVbwf1Nxttc/swlZ
SDpFE/MVlOGoxCVpBH5FH7jHCp4/Z2K/c/dXPr7owYZVMnhPRNKvaMHlGJ1RQtj/arbAb4Dn
n9Qq2MOPursdRTr245UonBXfTDGpvdRC2utkZNjXeh4HbLOMkLBR1B70gHZ7eFp6xOzTVx7k
CCHcADWBWXyzb0MNvFy8zKrscfgiaHYTKebsoQ/6WZCkylFxNHHcDI9gXFMQS3yLCfGuAAAA
AAAA
--------------ms060903060404010301030804--
