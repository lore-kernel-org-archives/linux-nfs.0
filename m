From: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Subject: Re: nfs-utils-1.1.6 released.
Date: Tue, 21 Apr 2009 20:10:57 +0300
Message-ID: <49EDFE21.2000007@arx.net>
References: <49ECB9E6.4010001@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms070304060405070508000107"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvs-director.arx.gr ([193.239.214.236]:53429 "EHLO
	lvs-director.arx.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109AbZDURSu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 13:18:50 -0400
In-Reply-To: <49ECB9E6.4010001-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms070304060405070508000107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Installed nfs-utils-1.1.6 and I'm facing an issue:

on the server:
# cat /etc/exports
/opt/shared/home 
192.168.99.0/255.255.255.0(rw,no_root_squash,no_subtree_check,sync)

# cat /var/lib/nfs/etab
/opt/shared/home    
192.168.99.0/255.255.255.0(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)

on the client:
# cat /proc/mounts
nfsip:/opt/shared/home /home nfs 
rw,noatime,vers=3,rsize=8192,wsize=8192,hard,intr,proto=udp,timeo=11,retrans=2,addr=nfsip 
0 0

however, everyone (including root) gets mapped to uid 65534 despite 
no_root_squash and no_all_squash...not very useful for a home directory. 
Is there something I'm missing ?
Also tried to go back to the previous (1.1.1) nfs-utils, but after 
``exportfs -ra'' the the server spit a few of those and all mounts froze
nfs mountd[1115]: /var/lib/nfs/etab:1: unknown keyword "mapping=identity"

Any help is greatly appreciated.

--------------ms070304060405070508000107
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
Fw0wOTA0MjExNzEwNTdaMCMGCSqGSIb3DQEJBDEWBBTCFP2w9QSF4nQWzJj7mX5JtlzDVTBf
BgkqhkiG9w0BCQ8xUjBQMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgIC
AIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgYUGCSsGAQQBgjcQ
BDF4MHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkp
IEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhA2
H+ZUpzb+bXE7AaJKlijcMIGHBgsqhkiG9w0BCRACCzF4oHYwYjELMAkGA1UEBhMCWkExJTAj
BgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhA2H+ZUpzb+bXE7AaJKlijcMA0GCSqGSIb3
DQEBAQUABIIBAGE7wRm38M8+5mGipWSoWEKn070qj55/I/BXfnDMyGailw1ju0O67sY9XOBF
W3Ym9IUpIOyUUZd9CgXMNWyehu20Gn7Kh5FV1ij0e+usMh0TCeidWQ45/HKqcMcls/uo//lh
X1pg0GCHN+wKS5jATldKPLX1GoQ/HzXrgf58lyffeBqyMxvRSAFNuSe/DHn3bYsxyLAph8KY
1E7p/LMwIYZOuY7nGZxxvNwtov4tTr6HYu62qwACl2ZqXxrD7j8nIkl62ubqhjknTfeAeLvY
eKZdYiWudFo2fa54g1o0pFi7NSOuvmqN0ZNloxyIVP8A8poWqpC8uppk8YHrQZLLdkgAAAAA
AAA=
--------------ms070304060405070508000107--
