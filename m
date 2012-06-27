Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sara-exch-fe1.ka.sara.nl ([145.100.8.49]:9949 "EHLO
	smtp.sara.nl" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752667Ab2F0N1f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 09:27:35 -0400
Message-ID: <4FEB08FB.4010004@sara.nl>
Date: Wed, 27 Jun 2012 15:22:03 +0200
From: Bas van der Vlies <basv@sara.nl>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Kernel 2.4.3 NFS problem in combo with xfs allocsize
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms050603050704090007020608"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--------------ms050603050704090007020608
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable


We just installed a new kernel 2.4.3 and experiencing problems with alloc=
ation of blocks.  With the standard debian kernel from
squeeze (2.6.32-5-amd64) we do not have any problems with the same xfs se=
ttings

xfs mount options:
 * LABEL=3Dlisapool  /lisapool       xfs     rw,uquota,prjquota,nobarrier=
,allocsize=3D1048576k,logbsize=3D256k

I do a nfs 3 mount on a node and when copying small files everything is o=
k:
{{{
mount -o rw,vers=3D3
}}}

Now on the mounted directory: ls -lsrh
{{{
288K -rw-r--r-- 1 root root 288K Jun 27 13:50 bash.1
}}}

When i do a copy the file size is correct
{{{
288K -rw-r--r-- 1 root root 288K Jun 27 15:14 bash.1_cp
}}}

When the file size is bigger: ls -lsrh
{{{
1.5M -rw-r--r-- 1 root root 1.5M Jun 27 13:55 bash.groot
}}}

Now copying this big file:
{{{
1.0G -rw-r--r-- 1 root root 1.5M Jun 27 15:14 bash.groot_cp
}}}

Note the size equals the xfs allocsize option and causing problems on our=
 quota enabled file server. When i set an allocsize of 4K
we don't see these problem. Also copying between 2 local file system is b=
ehaving as expected. Have other people noticed this problem?

Regards

--=20
********************************************************************
*  Bas van der Vlies                    e-mail: basv@sara.nl       *
*  SARA - Academic Computing Services   Amsterdam, The Netherlands *
********************************************************************



--------------ms050603050704090007020608
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIOBjCC
BIowggNyoAMCAQICECf06hH0eobEbp27bqkXBwcwDQYJKoZIhvcNAQEFBQAwbzELMAkGA1UE
BhMCU0UxFDASBgNVBAoTC0FkZFRydXN0IEFCMSYwJAYDVQQLEx1BZGRUcnVzdCBFeHRlcm5h
bCBUVFAgTmV0d29yazEiMCAGA1UEAxMZQWRkVHJ1c3QgRXh0ZXJuYWwgQ0EgUm9vdDAeFw0w
NTA2MDcwODA5MTBaFw0yMDA1MzAxMDQ4MzhaMIGuMQswCQYDVQQGEwJVUzELMAkGA1UECBMC
VVQxFzAVBgNVBAcTDlNhbHQgTGFrZSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5l
dHdvcmsxITAfBgNVBAsTGGh0dHA6Ly93d3cudXNlcnRydXN0LmNvbTE2MDQGA1UEAxMtVVRO
LVVTRVJGaXJzdC1DbGllbnQgQXV0aGVudGljYXRpb24gYW5kIEVtYWlsMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjmFpPJ9q0E7YkY3rs3BYHW8OWX5ShpHornMSMxqmNVN
NRm5pELlzkniii8efNIxB8dOtINknS4p1aJkxIW9hVE1eaROaJB7HHqkkqgX8pgV8pPMyaQy
lbsMTzC9mKALi+VuG6JG+ni8om+rWV6lL8/K2m2qL+usobNqqrcuZzWLeeEeaYji5kbNoKXq
vgvOdjp6Dpvq/NonWz1zHyLmSGHGTPNpsaguG7bUMSAsvIKKjqQOpdeJQ/wWWq8dcdcRWdq6
hw2v+vPhwvCkxWeM1tZUOt4KpLoDd7NlyP0e03RiqhjKaJMeoYV+9Udly/hNVyh00jT/MLbu
9mIwFIws6wIDAQABo4HhMIHeMB8GA1UdIwQYMBaAFK29mHo0tCb3+sQmVO8DveAky1QaMB0G
A1UdDgQWBBSJgmd9xJ0mcABLtFBIfN49rgRufTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/
BAUwAwEB/zB7BgNVHR8EdDByMDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BZGRU
cnVzdEV4dGVybmFsQ0FSb290LmNybDA2oDSgMoYwaHR0cDovL2NybC5jb21vZG8ubmV0L0Fk
ZFRydXN0RXh0ZXJuYWxDQVJvb3QuY3JsMA0GCSqGSIb3DQEBBQUAA4IBAQAZ2IkRbyispgCi
54fBm5AD236hEv0e8+LwAamUVEJrmgnEoG3XkJIEA2Z5Q3H8+G+v23ZF4jcaPd3kWQR4rBz0
g0bzes9bhHIt5UbBuhgRKfPLSXmHPLptBZ2kbWhPrXIUNqi5sf2/z3/wpGqUNVCPz4FtVbHd
WTBK322gnGQfSXzvNrv042n0+DmPWq1LhTq3Du3Tzw1EovsEv+QvcI4l+1pUBrPQxLxtjftz
Mizpm4QkLdZ/kXpoAlAfDj9N6cz1u2fo3BwuO/xOzf4CjuOoEwqlJkRl6RDyTVKnrtw+ymsy
XEFs/vVdoOr/0fqbhlhtPZZH5f4ulQTCAMyOofK7MIIErTCCA5WgAwIBAgIRALhA7A+jChBa
1hG9KQEYBz4wDQYJKoZIhvcNAQEFBQAwOzELMAkGA1UEBhMCTkwxDzANBgNVBAoTBlRFUkVO
QTEbMBkGA1UEAxMSVEVSRU5BIFBlcnNvbmFsIENBMB4XDTEyMDUyMjAwMDAwMFoXDTEzMDUy
MjIzNTk1OVowfDELMAkGA1UEBhMCTkwxNDAyBgNVBAoTK1N0aWNodGluZyBBY2FkZW1pc2No
IFJla2VuY2VudHJ1bSBBbXN0ZXJkYW0xGjAYBgNVBAMTEUJhcyB2YW4gZGVyIFZsaWVzMRsw
GQYJKoZIhvcNAQkCFgxiYXN2QHNhcmEubmwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQDOmTdQ30PAE6aO0Qq83vSK1lGQeHTlucI/RmbWYJeL4SiOC8MU5VP6oA8Oq5FIo3sS
wbCmEsEjpjIfPsb6xk6zGiu+WgnYxhoTkaqbA3XNRuWwFuNYGb2ceKy3RNJlyoFsv6MIQc7/
A97U6KBo0khpTYah3ekTkLr5WCnHxVcKechKumuhIM+E67SWvlmqfEqcdGjxGJWbJ4Se3Wxr
a0oBbB/u1krNUoIaf6kdj9LeDK8a56FUZz46/jvBwfzLjYhVX3zBmXX5kQ2NhyN3RKDhafOC
i2Alj+neQbk5V6iI4OE73T9Qr8+jwSq1icKqckwQ5waTu27A0WtxSU7Uah63AgMBAAGjggFp
MIIBZTAfBgNVHSMEGDAWgBRjTUNaGUg/xEbBArq/7g7lgrdmpjAdBgNVHQ4EFgQUFq+k5obi
U8FH3kJA80DU0jeP0SUwDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwHQYDVR0lBBYw
FAYIKwYBBQUHAwQGCCsGAQUFBwMCMBgGA1UdIAQRMA8wDQYLKwYBBAGyMQECAh0wPwYDVR0f
BDgwNjA0oDKgMIYuaHR0cDovL2NybC50Y3MudGVyZW5hLm9yZy9URVJFTkFQZXJzb25hbENB
LmNybDByBggrBgEFBQcBAQRmMGQwOgYIKwYBBQUHMAKGLmh0dHA6Ly9jcnQudGNzLnRlcmVu
YS5vcmcvVEVSRU5BUGVyc29uYWxDQS5jcnQwJgYIKwYBBQUHMAGGGmh0dHA6Ly9vY3NwLnRj
cy50ZXJlbmEub3JnMBcGA1UdEQQQMA6BDGJhc3ZAc2FyYS5ubDANBgkqhkiG9w0BAQUFAAOC
AQEAJrMV0EcLzAjG1VYisbv+uizGVU2FxFeCwghQDt2LYV2yhqqqpFBe1P/J87TIhg0za2yo
dw/gsnSNyvV0NPy2pdWCNRC1tBpMfqRJPDDPMeushzhp2T6Hj/ehejw4mBFi5i6Vz+7qussr
Gdz9Z/Hnjl0USvwv5g1UX8i5Z74SeINaWtEBm6Q4W+odXrSTcfQVE19uaSKeQqWQSQZJyrAP
LIZXFCcKMP+IgvyNaMb3opA83L+kTUIxtcGuT6MgHwrUxJUpFlK0e2FXV4ntVcWLjPQ0sIv1
jo12Ep4idTejXoP+u7VkAR+gO1KbtT34wAj17FxJPdoeTdMU/HXPKZh5RzCCBMMwggOroAMC
AQICEHP+V/rfuMUIgXtmuWvwLe8wDQYJKoZIhvcNAQEFBQAwga4xCzAJBgNVBAYTAlVTMQsw
CQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VS
VFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMTYwNAYD
VQQDEy1VVE4tVVNFUkZpcnN0LUNsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQgRW1haWwwHhcN
MDkwNTE4MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjA7MQswCQYDVQQGEwJOTDEPMA0GA1UEChMG
VEVSRU5BMRswGQYDVQQDExJURVJFTkEgUGVyc29uYWwgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQDIFdn1M2ojoZANz7sFRMOrH0o1hRohhaBP+PBA4kpDm/5bsbC/tFfc
dYBBS2Qa9ttPb4/QJUU1+erLSvr72tPtRYgRlDbkzKgN78U9N+0We+PClZ5YM38i+/j/7Oa+
264KZSUih9pvhItG6ECGKD+/VgjiSumDouki+y36tigfkcHDcftTwCtOpAyhbp1V7ezhJIc6
COINHOTETdDLJ/qEZObRl51WJFuTuykuQ+JBaj3iSmX8ml9ahoe8h8d5gJaZUcaQD2SRmX0Q
3awsAyrheGT+zj1O9CtQEUvRWNSbA/B/9TtTsFND+8UvxAQpGjqs11Xp0Q6V0Tsxf3hPrikt
AgMBAAGjggFNMIIBSTAfBgNVHSMEGDAWgBSJgmd9xJ0mcABLtFBIfN49rgRufTAdBgNVHQ4E
FgQUY01DWhlIP8RGwQK6v+4O5YK3ZqYwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYB
Af8CAQAwGAYDVR0gBBEwDzANBgsrBgEEAbIxAQICHTBYBgNVHR8EUTBPME2gS6BJhkdodHRw
Oi8vY3JsLnVzZXJ0cnVzdC5jb20vVVROLVVTRVJGaXJzdC1DbGllbnRBdXRoZW50aWNhdGlv
bmFuZEVtYWlsLmNybDBvBggrBgEFBQcBAQRjMGEwOAYIKwYBBQUHMAKGLGh0dHA6Ly9jcnQu
dXNlcnRydXN0LmNvbS9VVE5BQUFDbGllbnRfQ0EuY3J0MCUGCCsGAQUFBzABhhlodHRwOi8v
b2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQAGK6lTLxPcXDkWzIafXkx7
cvvsjVWKXpoK/1NMdvQGPVDPV/Ciz6+ZjKr+oBl2PpkDMvp1gziKu2uapQwTstQbduaULmeY
WeORbAKQmpzIYEtVq8qIWo0r5WmVAwfR1A78JCIuWbFjpF/t2SNy5JzOOlxsH0+pAMkd/vp/
RS22LoTdDyegWRhO1XYlRfSZJnnbb58j90O7Kw8Eo4EmLLd7Nfk9d19AIeZ/HaWWWr3QyxY6
bLthi4r9BDlECsss4cvOLhCYGtvgk+1JZGQIIJ+3o1Dwot3KtMZ8DD3nXhXcJ4bkOjtSWher
qQZTK50Jc2QcAcP9MNKHA2/kFQN6OV9oMYIDCjCCAwYCAQEwUDA7MQswCQYDVQQGEwJOTDEP
MA0GA1UEChMGVEVSRU5BMRswGQYDVQQDExJURVJFTkEgUGVyc29uYWwgQ0ECEQC4QOwPowoQ
WtYRvSkBGAc+MAkGBSsOAwIaBQCgggGPMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJ
KoZIhvcNAQkFMQ8XDTEyMDYyNzEzMjIwM1owIwYJKoZIhvcNAQkEMRYEFDfCVwYAcILzN8hB
ZvPfBjHRDRtUMF8GCSsGAQQBgjcQBDFSMFAwOzELMAkGA1UEBhMCTkwxDzANBgNVBAoTBlRF
UkVOQTEbMBkGA1UEAxMSVEVSRU5BIFBlcnNvbmFsIENBAhEAuEDsD6MKEFrWEb0pARgHPjBh
BgsqhkiG9w0BCRACCzFSoFAwOzELMAkGA1UEBhMCTkwxDzANBgNVBAoTBlRFUkVOQTEbMBkG
A1UEAxMSVEVSRU5BIFBlcnNvbmFsIENBAhEAuEDsD6MKEFrWEb0pARgHPjBsBgkqhkiG9w0B
CQ8xXzBdMAsGCWCGSAFlAwQBKjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcN
AwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMA0GCSqGSIb3
DQEBAQUABIIBAMxhtc4EKejtdIHMNoD1iZ8F9e029b4rTp86br/GYe7/RtUWCZNxUtRRQx+f
iPIt1bNJsi4ky3PUG05iDmaP2GC+vL5+bWLOVWltBgtYUENEplLjnkaPn1SqrW7ihi/LWpRE
a4/nJ1D91Y+u/yr0mpGIa9CNkn7be5Ggj7LyCJYSC7YM3G/QR6Sh83TXD0pFZDIY/vG6tU3h
25COL7otTmGsYUOfPo54AMKQxmV40e+tkN5kkawkK21PmIj7PQ0BNqg6KpAo0qZahtwYHQqk
Wom4RvmJ7L8GGM4jrGhWQJ1foyWfBdFh294iuQELd0z0mG0iRGr3fSVVSVI3aTPWUQAAAAAA
AAA=
--------------ms050603050704090007020608--
