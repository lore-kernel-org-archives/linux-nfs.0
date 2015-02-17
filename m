Return-Path: linux-nfs-owner@vger.kernel.org
Received: from postout2.mail.lrz.de ([129.187.255.138]:43500 "EHLO
	postout2.mail.lrz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756466AbbBQNnn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2015 08:43:43 -0500
Message-ID: <54E3458B.4090102@tum.de>
Date: Tue, 17 Feb 2015 14:43:39 +0100
From: Joschi Brauchle <joschi.brauchle@tum.de>
MIME-Version: 1.0
To: mdw@linuxbox.com
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Fehenberger, Tobias" <tobias.fehenberger@tum.de>,
        "Stinner, Markus" <markus.stinner@tum.de>,
        Tasnad Kernetzky <tasnad.kernetzky@tum.de>
Subject: Re: Question about NFS4 facls in combination with a GIT shared bare
 repo on NFSv4 share
References: <54E1F532.5030703@tum.de> <20150216213528.GA27453@soma.private.linuxbox.com>
In-Reply-To: <20150216213528.GA27453@soma.private.linuxbox.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms010200000208020605030805"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms010200000208020605030805
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Marcus,

thanks for your reply. I'll provide some more details belog

Question 3:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
This is the complete *working* ACL:
---------------
myuser@myhost:/nfsv4/share/> nfs4_getfacl repodir
A:fdg:MYGROUP@mydomain.fqdn:rwaDxtTnNcCoy
A:fd:OWNER@:rwaDdxtTnNcCoy
A::EVERYONE@:rxtncy
D::OWNER@:
D::EVERYONE@:waDTC
---------------

This is the complete non-working ACL:
---------------
myuser@myhost:/nfsv4/share/> nfs4_getfacl repodir
A:fdg:GROUP@:rwaDxtTnNcCoy
A:fd:OWNER@:rwaDdxtTnNcCoy
A::EVERYONE@:rxtncy
D::OWNER@:
D::EVERYONE@:waDTC
---------------

 > what is the fileserver running?   netapp?  solaris?  linux nfsd??=20
something else?
Server:	NetApp FAS 3140 mit ONTAP 8.1.4P1 7-mode

 > Presumably your client is linux - what version?  If from a=20
distribution which distro & package version?
Client: openSUSE 13.2, 3.16.7-7-desktop, nfs-client =3D 1.3.0

 > Are you using gssapi?  (better for tracing purposes if you can do=20
this without.)
We are using GSSAPI/Kerberos protected NFSv4 shares mounted like to:
nfsv4_server.fqdn:/vol/myshare on /nfsv4/share type nfs4=20
(rw,relatime,vers=3D4.0,rsize=3D65536,wsize=3D65536,namlen=3D255,soft,pro=
to=3Dtcp,port=3D0,timeo=3D600,retrans=3D2,sec=3Dkrb5,local_lock=3Dnone)

We have the user "myuser" a member of "mygroup" but not his primary=20
group, i.e.
# id myuser
uid=3Dxxx(myuser) ... groups=3Dxxx(mygroup) ...

 > You speak of "domains" - what sort are these and why do you think
 > they be considered the same as "@GROUP"?
 >
We have the following ID mapping on the Linux clients:
# cat /etc/idmapd.conf
---------------
[General]

Verbosity =3D 0
Pipefs-Directory =3D /var/lib/nfs/rpc_pipefs
Domain =3D mydomain.fqdn

[Mapping]

Nobody-User =3D nobody
Nobody-Group =3D nobody
---------------
Note that in general, all POSIX ACLS based on user groups are working=20
perfectly fine. So ID-mapping seems to be OK in general.

 > Client & server identities and groups might map differently - is this =

the case here?
I have no idea about the server side...

> Can you demonstrate your problem happen with dd or cp?  Or does it only=

> happen with git?
Nope, only git so far.

 > Can you record a network trace of the bad thing happening?  (this will=

 > point whether it's a client or server side problem.)
Please find a wireshark trace of the failed "git push" command here:
http://wikisend.com/download/940986/wireshark_git.pcapng
(7 days availability) where the problem seems to be
---------------
148	0.070260000	192.168.109.118	10.162.229.2	NFS	438	V4 Call (Reply In=20
149) WRITE StateID: 0xcded Offset: 0 Len: 156
149	0.071190000	10.162.229.2	192.168.109.118	NFS	162	V4 Reply (Call In=20
148) WRITE Status: NFS4ERR_ACCESS
---------------
me =3D 192.168.109.118
nfs4_server =3D 10.162.229.2
Not much more that I can see here unfortunately...

> Possibly helpful to know,:
> 	unix mode permissions work differently than an acl,
> 	with unix modes,
> 		owner permissions eclipse group permissions.
> 	with acls,
> 		group permissions add to owner permissions.
> To accurately map unix mode bits into nfsv4 acls, you have to also
> include 'deny' entries to keep groups from adding permissions the user
> doen't have.

Thanks for the hints and for your help!
I'll do some more thinking about the problem :)

JB


--------------ms010200000208020605030805
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
CSqGSIb3DQEJBTEPFw0xNTAyMTcxMzQzMzlaMCMGCSqGSIb3DQEJBDEWBBQesRu5CHUCq7Ri
aj+KdQAjRmeBsjBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjALBglghkgBZQMEAQIw
CgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0G
CCqGSIb3DQMCAgEoMHoGCSsGAQQBgjcQBDFtMGswYDELMAkGA1UEBhMCREUxKTAnBgNVBAoT
IFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11ZW5jaGVuMSYwJAYDVQQDEx1aZXJ0aWZpemll
cnVuZ3NzdGVsbGUgZGVyIFRVTQIHFnHrX30s9DB8BgsqhkiG9w0BCRACCzFtoGswYDELMAkG
A1UEBhMCREUxKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11ZW5jaGVuMSYw
JAYDVQQDEx1aZXJ0aWZpemllcnVuZ3NzdGVsbGUgZGVyIFRVTQIHFnHrX30s9DANBgkqhkiG
9w0BAQEFAASCAQCf37EOM3AGcxPs10c6elkIIQzxiNrmwogyszL4+2j7ex+8dgSvBJ9LdA13
Ag1ZLJ2ck1mlXTYDEmBoZuLwaZ3xbS+a25E9sTrc4wffUy/xAKwiY3oguGf+sROJ8JR3vj1o
n3o2EA+B2inyBygGoQsUVwNGWcej0SnXdI5o54HxrQ+C9x4ZLfMsf/f4VaroVGGOtJ3eNJ0C
DKmykbxLxoLF4uSRlyravPQY1qPzXBJnT3XmMuRk27bmVfkKHtrl2X54hPKEdaILnDVKKj+N
L7RIUxlZg8AFTN4cq8ex0H+v0sNNnVXH51nd/b3A98z6IKNLFlpVCoVs1O8ly8zJd9ujAAAA
AAAA
--------------ms010200000208020605030805--
