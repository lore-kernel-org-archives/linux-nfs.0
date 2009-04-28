From: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Subject: Re: nfs-utils-1.1.6 released.
Date: Tue, 28 Apr 2009 18:14:46 +0300
Message-ID: <49F71D66.4070204@arx.net>
References: <49ECB9E6.4010001@RedHat.com> <49EDFE21.2000007@arx.net> <49EF3A83.50409@RedHat.com> <20090422155427.GA8712@fieldses.org> <49F6E9B3.2090508@arx.net> <20090428150551.GE17891@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms020304050203050707030109"
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvs-director.arx.gr ([193.239.214.236]:35787 "EHLO
	lvs-director.arx.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbZD1PQO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 11:16:14 -0400
In-Reply-To: <20090428150551.GE17891@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms020304050203050707030109
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

O/H J. Bruce Fields =CE=AD=CE=B3=CF=81=CE=B1=CF=88=CE=B5:
> On Tue, Apr 28, 2009 at 02:34:11PM +0300, Thanos Chatziathanassiou wrot=
e:
>  =20
>> O/H J. Bruce Fields =CE=AD=CE=B3=CF=81=CE=B1=CF=88=CE=B5:
>>    =20
>>> Might be worth looking at the network traffic to see if some change i=
n
>>> the client or in the mountd security negotiation hasn't caused the
>>> client to start doing auth_null instead of auth_unix?
>>>
>>> --b.
>>>  =20
>>>      =20
>> Apologies for taking so long, but I was out of the office last week.
>> I'm attaching a tcpdump of mounting the directory ``/vhome'' and doing=
 a =20
>> ``touch lala'' (my very own ``foo'') in said directory, which resulted=
 =20
>> in access denied on the client.
>> It doesn't say much to me, but then again I'm certainly no expert.
>>    =20
>
> You could send us a network trace for us to look at; just
>
> 	tcpdump -s0 -wTMP
>
> then do the mount, then ^C the tcpdump process, then send us the file
> TMP.
>  =20
I already did and attached it as nfs.pkt before. Is it missing something =
?
> --b.
>  =20



--------------ms020304050203050707030109
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIII+zCC
AtgwggJBoAMCAQICEDYf5lSnNv5tcTsBokqWKNwwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UE
BhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMT
I1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA5MDMwMzE2MzYzM1oX
DTEwMDMwMzE2MzYzM1owQTEfMB0GA1UEAxMWVGhhd3RlIEZyZWVtYWlsIE1lbWJlcjEeMBwG
CSqGSIb3DQEJARYPdGNoYXR6aUBhcngubmV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAp7Qihqj+5xLt5RT/MmdkxlXgf82jalYMYAVg7aOFg5stuKcwcQebnnm6gpOVEy28
jrfUFIwUg2v+z/PmVLSERoYuq5V94mUzhLv1NsGlsUT/oMpdnoiVEeYuPH7nscTOkyaek0Xe
ST3qSKrhGb0sQs5KdSVjB3kNGK7HLAqpSnQuM/wU4nZTMEWjm1UTVeIJ3G+e8Fm5B2YCxTGp
TBavfZNnIC49Hz/0hybZoBMP3KbcKHwBzl6F3uhaWaxOccezWOcV/LMnRBW/Lrn6d2WLFzQu
dNBVP0AcChtJueI6nDzyMY66FAgJFQbmR1SSq3xQFUW7eEU1nTCZ30GlggVmqwIDAQABoyww
KjAaBgNVHREEEzARgQ90Y2hhdHppQGFyeC5uZXQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0B
AQUFAAOBgQB+qrgv2n3iVNeYl+o7LfJ52f+btX5IKtAPKQx/yCrceF2YnguIruLzhd6ktRiF
rpgTvcY4cO9Va5sNUBBhtKI0ATDHwe6laas0KFDTvtDg3TYbiycK6rdHieg1wfFQKgNofYgr
F35LFf8PlhL4hikFy/V1E39Goih4riLyFeeK5jCCAtgwggJBoAMCAQICEDYf5lSnNv5tcTsB
okqWKNwwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBD
b25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFp
bCBJc3N1aW5nIENBMB4XDTA5MDMwMzE2MzYzM1oXDTEwMDMwMzE2MzYzM1owQTEfMB0GA1UE
AxMWVGhhd3RlIEZyZWVtYWlsIE1lbWJlcjEeMBwGCSqGSIb3DQEJARYPdGNoYXR6aUBhcngu
bmV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp7Qihqj+5xLt5RT/MmdkxlXg
f82jalYMYAVg7aOFg5stuKcwcQebnnm6gpOVEy28jrfUFIwUg2v+z/PmVLSERoYuq5V94mUz
hLv1NsGlsUT/oMpdnoiVEeYuPH7nscTOkyaek0XeST3qSKrhGb0sQs5KdSVjB3kNGK7HLAqp
SnQuM/wU4nZTMEWjm1UTVeIJ3G+e8Fm5B2YCxTGpTBavfZNnIC49Hz/0hybZoBMP3KbcKHwB
zl6F3uhaWaxOccezWOcV/LMnRBW/Lrn6d2WLFzQudNBVP0AcChtJueI6nDzyMY66FAgJFQbm
R1SSq3xQFUW7eEU1nTCZ30GlggVmqwIDAQABoywwKjAaBgNVHREEEzARgQ90Y2hhdHppQGFy
eC5uZXQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQUFAAOBgQB+qrgv2n3iVNeYl+o7LfJ5
2f+btX5IKtAPKQx/yCrceF2YnguIruLzhd6ktRiFrpgTvcY4cO9Va5sNUBBhtKI0ATDHwe6l
aas0KFDTvtDg3TYbiycK6rdHieg1wfFQKgNofYgrF35LFf8PlhL4hikFy/V1E39Goih4riLy
FeeK5jCCAz8wggKooAMCAQICAQ0wDQYJKoZIhvcNAQEFBQAwgdExCzAJBgNVBAYTAlpBMRUw
EwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEaMBgGA1UEChMRVGhh
d3RlIENvbnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2VydmljZXMgRGl2aXNp
b24xJDAiBgNVBAMTG1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBDQTErMCkGCSqGSIb3DQEJ
ARYccGVyc29uYWwtZnJlZW1haWxAdGhhd3RlLmNvbTAeFw0wMzA3MTcwMDAwMDBaFw0xMzA3
MTYyMzU5NTlaMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAo
UHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxKY8VXNV+065yplaHmjAdQRwnd/p/6Me
7L3N9VvyGna9fww6YfK/Uc4B1OVQCjDXAmNaLIkVcI7dyfArhVqqP3FWy688Cwfn8R+RNiQq
E88r1fOCdz0Dviv+uxg+B79AgAJk16emu59l0cUqVIUPSAR/p7bRPGEEQB5kGXJgt/sCAwEA
AaOBlDCBkTASBgNVHRMBAf8ECDAGAQH/AgEAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9j
cmwudGhhd3RlLmNvbS9UaGF3dGVQZXJzb25hbEZyZWVtYWlsQ0EuY3JsMAsGA1UdDwQEAwIB
BjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRUHJpdmF0ZUxhYmVsMi0xMzgwDQYJKoZIhvcN
AQEFBQADgYEASIzRUIPqCy7MDaNmrGcPf6+svsIXoUOWlJ1/TCG4+DYfqi2fNi/A9BxQIJNw
PP2t4WFiw9k6GX6EsZkbAMUaC4J0niVQlGLH2ydxVyWN3amcOY6MIE9lX5Xa9/eH1sYITq72
6jTlEBpbNU1341YheILcIRk13iSx0x1G/11fZU8xggNxMIIDbQIBATB2MGIxCzAJBgNVBAYT
AlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNU
aGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIQNh/mVKc2/m1xOwGiSpYo3DAJ
BgUrDgMCGgUAoIIB0DAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
Fw0wOTA0MjgxNTE0NDZaMCMGCSqGSIb3DQEJBDEWBBTkCLQp7ulcatgQUgHQRyVFNF547TBf
BgkqhkiG9w0BCQ8xUjBQMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgIC
AIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgYUGCSsGAQQBgjcQ
BDF4MHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkp
IEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhA2
H+ZUpzb+bXE7AaJKlijcMIGHBgsqhkiG9w0BCRACCzF4oHYwYjELMAkGA1UEBhMCWkExJTAj
BgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhA2H+ZUpzb+bXE7AaJKlijcMA0GCSqGSIb3
DQEBAQUABIIBAFOg7PJRuPautwbfH1gkDmtFJKdL7B3SH1Ommp54M6lydToA/jhQk9PK0bOy
gzfozGAxUy1lywU2AlxJPUM6kr4SwcdpfXthjxth1MCLtsoogoZxVVW1ioteLdjaEp8lbrhV
Wd6D3TsqEpV1rtlzbsjG1WNGYdcnBOgZ4itRZshKbpe4cerd4uqjcDOCPU1FPn/v356ZeFZx
Pux/e9xyicoq5Pu8r9/Vcj0PV2KgGcOQbsTKRjU+UXVh6q5zP4pTraJw6pSyb2x79+9amzog
bA/hJHWjiCjE/5TN9SH1uOvu2u353K/pEXQ+lus++XnIkqbej1lmtFk2T9mxsVNuDDMAAAAA
AAA=
--------------ms020304050203050707030109--
