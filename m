Return-Path: linux-nfs-owner@vger.kernel.org
Received: from postout1.mail.lrz.de ([129.187.255.137]:60169 "EHLO
	postout1.mail.lrz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab3IJVsQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Sep 2013 17:48:16 -0400
From: Joschi Brauchle <joschi.brauchle@tum.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd4: utime sometimes takes 40+ seconds to return (but on
 SLES11SP3 with kernel 3.0.82)
Date: Tue, 10 Sep 2013 21:48:12 +0000
Message-ID: <038EA8B0-BD46-47F2-8F20-DEC8B6DA9087@tum.de>
References: <522F69A1.5090005@tum.de> <20130910203530.GA20296@fieldses.org>
In-Reply-To: <20130910203530.GA20296@fieldses.org>
Content-Type: multipart/signed; micalg=sha1;
	boundary="Apple-Mail-DE3461BE-8060-4C91-8F16-93FB6F77082A";
	protocol="application/pkcs7-signature"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail-DE3461BE-8060-4C91-8F16-93FB6F77082A
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Am 10.09.2013 um 22:35 schrieb "J. Bruce Fields" <bfields@fieldses.org>:

> On Tue, Sep 10, 2013 at 08:49:05PM +0200, Joschi Brauchle wrote:
>> Hello everyone,
>>=20
>> we are administrating an NFS high-availability cluster running on
>> SLES11SP1 with kernel 2.6.32.59. Just recently, one of the cluster
>> machines was updated to SLES11SP3 with kernel 3.0.82.
>>=20
>>=20
>> We are now experiencing severe hangs on NFS clients when the
>> SLES11SP3 server is running the NFS services. An strace on the
>> hanging processes on the client side show that is is waiting up to
>> 60+ seconds for a "utime()" call to complete.
>>=20
>>=20
>> The problem we see is matching the problem described in the thread
>> "v3.5 nfsd4 regression; utime sometimes takes 40+ seconds to
>> return". If the NFS server is running on SLES11SP3, the little test
>> program provided in this tread hangs at the "utime()" call for 60+
>> seconds. It hangs each time it is run! It finishes right away with 0
>> seconds delay is SLES11SP1 is providing NFS services, each time.
>>=20
>>=20
>> Now, in the serverside logfiles of SLES11SP3 we see these messages
>> (not so on SP1):
>> --------------
>> kernel: [99381.184976] RPC: AUTH_GSS upcall timed out.
>> kernel: [99381.184978] Please check user daemon is running.
>> --------------
>>=20
>> We have always been running the NFS server without rpc.gssd on the
>> server side, as the init script for the nfsserver also does not
>> start rpc.gssd.
>>=20
>>=20
>> Once we started rpc.gssd on the SLES11SP3 server, using the test
>> utility on the client shows that the first call to "utime()"
>> succeeds right away, the second call takes ~25s to complete. But
>> now, any consecutive runs of the utility finish with no more delay.
>>=20
>>=20
>> So can anyone confirm that with kernel 3.0+ the rpc.gssd daemon is
>> also required on the server side for correct operation?
>>=20
>> Has there been a change between kernel 2.6.32.59 and 3.0.x?
>>=20
>> Thus, is the init script of the nfsserver in SLES11SP3 indeed
>> missing to start rpc.gssd?
>=20
> It should be starting rpc.gssd to allow callbacks, yes.
>=20
> --b.

Ok, we will run rpc.gssd on the server. Thanks.=20

Could you please comment on having the nfs clients hang on utime() calls is t=
o be expected when *not* running rpc.gssd? Or is this a problem that needs t=
o be investigated?

Best regards,
J Brauchle=

--Apple-Mail-DE3461BE-8060-4C91-8F16-93FB6F77082A
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

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
LmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jcmwvY2FjcmwuY3JsMD2gO6A5hjdodHRwOi8vY2RwMi5w
Y2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jcmwvY2FjcmwuY3JsMIGiBggrBgEFBQcBAQSB
lTCBkjBHBggrBgEFBQcwAoY7aHR0cDovL2NkcDEucGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1jYS9w
dWIvY2FjZXJ0L2NhY2VydC5jcnQwRwYIKwYBBQUHMAKGO2h0dHA6Ly9jZHAyLnBjYS5kZm4uZGUv
Z2xvYmFsLXJvb3QtY2EvcHViL2NhY2VydC9jYWNlcnQuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCD
aDbZwwslMHDw3OvHv7uTv333LPq+MeDnkcSrWF3d3UQsrgqMSQIYXqUpNqEHPPUIVhTjgcXk+yqL
KArJ/obS7YJ2S4+Ef8jV/DHps2D9e9Dmf5uF/b5kYbcvoIfdJAkmZWkIE/TH1fu4NQukIHpVA1fD
evDXeD5dSDAVpAJGWS3E/fx4KJefRRoRQxdbhce0rvr2AZTt4PrR5yNfFyQQzrNmmx0VyOT5mHL7
Roq7FTH1nLNKKGTqJ2MOab1iPjfHWrfQzSL4EXaAoUzinbz1EY7ZGN5CZL3QHzyrH/2Qo9x4XRJ9
G+lWUKg4+1SUQrxTi9LaknNsFKxy0cP/TLtoMIIFdjCCBF6gAwIBAgIEENurezANBgkqhkiG9w0B
AQUFADBgMQswCQYDVQQGEwJERTEpMCcGA1UEChMgVGVjaG5pc2NoZSBVbml2ZXJzaXRhZXQgTXVl
bmNoZW4xJjAkBgNVBAMTHVplcnRpZml6aWVydW5nc3N0ZWxsZSBkZXIgVFVNMB4XDTEwMTAxODEx
MjIyMFoXDTEzMTAxNzExMjIyMFowgd0xCzAJBgNVBAYTAkRFMQ8wDQYDVQQIEwZCYXllcm4xETAP
BgNVBAcTCE11ZW5jaGVuMSkwJwYDVQQKEyBUZWNobmlzY2hlIFVuaXZlcnNpdGFldCBNdWVuY2hl
bjE+MDwGA1UECxM1RmFrdWx0YWV0IGZ1ZXIgRWxla3Ryb3RlY2huaWsgdW5kIEluZm9ybWF0aW9u
c3RlY2huaWsxGDAWBgNVBAMTD0pvc2NoaSBCcmF1Y2hsZTElMCMGCSqGSIb3DQEJARYWam9zY2hp
LmJyYXVjaGxlQHR1bS5kZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANnBerSJSlDZ
mNdlxM/IALVi54n6TykNOlYbBzR9xUWt6qqUnFvesqWES89x06LdhnWOyUphCkse6eXoZTimxHCr
K+e521czpFVv9Epplo66Mc13tXuCk8PUJqcV10CORblF0UKF2YYJDyVl2t9bhM4sW1iDuAx8zNk7
hInRZN8ts3MgOI+oPH5W/MzDEkI6gGn0wwPAnwPo+3CWTgpN9FGWDUbhiyYurSYtZ5mg8tWTAwEA
OT/J0CdwaSRgsVsJuQNKaRAZSjxVo6a6CZ/DRKwkR0YVlnCpB8M8COPMwdG567CqjEFaZIEqrhg/
eHW8gwCG4beTPB0hPHqplo+1IOkCAwEAAaOCAbgwggG0MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgXg
MCkGA1UdJQQiMCAGCCsGAQUFBwMCBggrBgEFBQcDBAYKKwYBBAGCNxQCAjAdBgNVHQ4EFgQUqqAE
Jvf+QHGp9JtJHDJi80Q1LhQwHwYDVR0jBBgwFoAUnZ8j8BkbfscjXScqzKU2OqZp5YkwIQYDVR0R
BBowGIEWam9zY2hpLmJyYXVjaGxlQHR1bS5kZTB3BgNVHR8EcDBuMDWgM6Axhi9odHRwOi8vY2Rw
MS5wY2EuZGZuLmRlL3R1bS1jYS9wdWIvY3JsL2NhY3JsLmNybDA1oDOgMYYvaHR0cDovL2NkcDIu
cGNhLmRmbi5kZS90dW0tY2EvcHViL2NybC9jYWNybC5jcmwwgZIGCCsGAQUFBwEBBIGFMIGCMD8G
CCsGAQUFBzAChjNodHRwOi8vY2RwMS5wY2EuZGZuLmRlL3R1bS1jYS9wdWIvY2FjZXJ0L2NhY2Vy
dC5jcnQwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jZHAyLnBjYS5kZm4uZGUvdHVtLWNhL3B1Yi9jYWNl
cnQvY2FjZXJ0LmNydDANBgkqhkiG9w0BAQUFAAOCAQEAp0MQ5cAyiuQ0hSI+TWmMagnN1sTtl/1V
y/jEsPt3ILKfVvaWLJ1klKGGN9pR6Do+OSzRiVmeIpLng4httI9t5/2qPhvJcFYdw/lD4pJhT6dj
1oNxpW0cEN93GwMVSCfl7DibqW0A3yod1OAFfdW3XfxLoNzgBjjG7QfOB4A/RrMtcRFAx7quDpdu
CVLmXYpjTx1MjL5OG7YfghAjXA44lGepCduJtAChNRqpEW5O4cn6sIUglDj9q4ieiQUGX9FPbCvd
U43TRdPoXvEmaQybSXTBWe+UzuUcK+yi4er+iHn2GD6OH/yH3bTDlyyFQaTlo/7J0qw3hqDvV+ts
z7n6hjGCAuQwggLgAgEBMGgwYDELMAkGA1UEBhMCREUxKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5p
dmVyc2l0YWV0IE11ZW5jaGVuMSYwJAYDVQQDEx1aZXJ0aWZpemllcnVuZ3NzdGVsbGUgZGVyIFRV
TQIEENurezAJBgUrDgMCGgUAoIIBUTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3
DQEJBTEPFw0xMzA5MTAyMTQ2NDlaMCMGCSqGSIb3DQEJBDEWBBSi+XlDZo+tfAoux349k54BImNK
SzB3BgkrBgEEAYI3EAQxajBoMGAxCzAJBgNVBAYTAkRFMSkwJwYDVQQKEyBUZWNobmlzY2hlIFVu
aXZlcnNpdGFldCBNdWVuY2hlbjEmMCQGA1UEAxMdWmVydGlmaXppZXJ1bmdzc3RlbGxlIGRlciBU
VU0CBBDbq3sweQYLKoZIhvcNAQkQAgsxaqBoMGAxCzAJBgNVBAYTAkRFMSkwJwYDVQQKEyBUZWNo
bmlzY2hlIFVuaXZlcnNpdGFldCBNdWVuY2hlbjEmMCQGA1UEAxMdWmVydGlmaXppZXJ1bmdzc3Rl
bGxlIGRlciBUVU0CBBDbq3swDQYJKoZIhvcNAQEBBQAEggEAVtrJW6TCY+Qx2f/FjoucK0mrZZL3
+uJsK63qsHB5/HR37KBrycxy3uQyz5Yn2HE/0CRE+lGmK2Kox4ALm60RDWOOuVcwF9hSMDdi2fTE
t3Os93MFr5tXWnHbKhZad4TiTFCcTIDzKupilZ4y52HMc+U9FJJT1lafgZ7cIhmMzAuYJ9xOflxi
xx0TJR5yfx+xsSCd5+xZ8TJlTxEmhkiLWWknpxOZLDgSvnqvWEEOlOzy//aX4GXfHDD/aUw5WI3D
O2shEwGWEuOeYh7XRm26kwNt9jtpKxFGSntOfQseTq+PhIExDd/zqeK9LCwwvWTw6j1IIUbVXgJe
BJWExUgaGgAAAAAAAA==

--Apple-Mail-DE3461BE-8060-4C91-8F16-93FB6F77082A--
