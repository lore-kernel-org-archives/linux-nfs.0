Return-Path: linux-nfs-owner@vger.kernel.org
Received: from riis.snl.salk.edu ([198.202.70.55]:50224 "EHLO
	riis.snl.salk.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab2IPKbw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Sep 2012 06:31:52 -0400
Subject: Re: NFS: kernel forces trailing slash for export in /proc/self/mounts
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: multipart/signed; boundary="Apple-Mail=_97D820A4-146E-42E7-915C-AE92C3461758"; protocol="application/pkcs7-signature"; micalg=sha1
From: Chris Hiestand <chiestand@salk.edu>
In-Reply-To: <1347762073.13258.188.camel@deadeye.wl.decadent.org.uk>
Date: Sun, 16 Sep 2012 03:24:04 -0700
Cc: viro@zeniv.linux.org.uk, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        669314@bugs.debian.org, Micheal Waltz <mwaltz@qualcomm.com>,
        Gabriel Evanoff <gevanoff@salk.edu>
Message-Id: <254E1AAA-BDE2-41A8-94D8-6E677860AD72@salk.edu>
References: <8F8193BD-84C6-4905-8789-DE7EB2579A4E@salk.edu> <1347762073.13258.188.camel@deadeye.wl.decadent.org.uk>
To: Ben Hutchings <ben@decadent.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_97D820A4-146E-42E7-915C-AE92C3461758
Content-Type: multipart/mixed;
	boundary="Apple-Mail=_60139FB5-DCB0-42ED-877E-C304D60757EB"


--Apple-Mail=_60139FB5-DCB0-42ED-877E-C304D60757EB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

I had a couple friends over today and we made a trivial patch to remove =
trailing slashes. We do not know C and have never created a patch for =
the kernel before, so there is undoubtedly a better way to do it. =
However we hope this helps in your efforts.


--Apple-Mail=_60139FB5-DCB0-42ED-877E-C304D60757EB
Content-Disposition: attachment;
	filename=0001-Fixes-trailing-slash-in-nfs-devname.patch
Content-Type: application/octet-stream;
	name="0001-Fixes-trailing-slash-in-nfs-devname.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=2081baa04c07107f81c56c4f163da2178b01294717=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Chris=20Hiestand=20<chiestand@salk.edu>=0A=
Date:=20Sat,=2015=20Sep=202012=2018:40:45=20-0700=0ASubject:=20[PATCH]=20=
Fixes=20trailing=20slash=20in=20nfs=20devname=0A=0A---=0A=20=
fs/nfs/super.c=20|=20=20=20=206=20+++++-=0A=201=20file=20changed,=205=20=
insertions(+),=201=20deletion(-)=0A=0Adiff=20--git=20a/fs/nfs/super.c=20=
b/fs/nfs/super.c=0Aindex=2079bc61f..e300a84=20100644=0A---=20=
a/fs/nfs/super.c=0A+++=20b/fs/nfs/super.c=0A@@=20-742,8=20+742,12=20@@=20=
static=20int=20nfs_show_devname(struct=20seq_file=20*m,=20struct=20=
vfsmount=20*mnt)=0A=20=09devname=20=3D=20nfs_path(&dummy,=20=
mnt->mnt_root,=20page,=20PAGE_SIZE);=0A=20=09if=20(IS_ERR(devname))=0A=20=
=09=09err=20=3D=20PTR_ERR(devname);=0A-=09else=0A+=09else=20{=0A+=09=09=
size_t=20len=20=3D=20strlen(devname);=0A+=09=09if=20(devname[len-1]=20=3D=3D=
=20'/')=0A+=09=09=09devname[len-1]=20=3D=20'\0';=0A=20=09=09=
seq_escape(m,=20devname,=20"=20\t\n\\");=0A+=09}=0A=20=09=
free_page((unsigned=20long)page);=0A=20=09return=20err;=0A=20}=0A--=20=0A=
1.7.10.4=0A=0A=

--Apple-Mail=_60139FB5-DCB0-42ED-877E-C304D60757EB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


This patch was created from the offending commit (c7f404b40a366). But =
I've also applied it to to Linus Torvalds' master HEAD (3f0c3c8fe30c7) =
with success.

-Chris=

--Apple-Mail=_60139FB5-DCB0-42ED-877E-C304D60757EB--

--Apple-Mail=_97D820A4-146E-42E7-915C-AE92C3461758
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIO1TCCBIow
ggNyoAMCAQICECf06hH0eobEbp27bqkXBwcwDQYJKoZIhvcNAQEFBQAwbzELMAkGA1UEBhMCU0Ux
FDASBgNVBAoTC0FkZFRydXN0IEFCMSYwJAYDVQQLEx1BZGRUcnVzdCBFeHRlcm5hbCBUVFAgTmV0
d29yazEiMCAGA1UEAxMZQWRkVHJ1c3QgRXh0ZXJuYWwgQ0EgUm9vdDAeFw0wNTA2MDcwODA5MTBa
Fw0yMDA1MzAxMDQ4MzhaMIGuMQswCQYDVQQGEwJVUzELMAkGA1UECBMCVVQxFzAVBgNVBAcTDlNh
bHQgTGFrZSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxITAfBgNVBAsTGGh0
dHA6Ly93d3cudXNlcnRydXN0LmNvbTE2MDQGA1UEAxMtVVROLVVTRVJGaXJzdC1DbGllbnQgQXV0
aGVudGljYXRpb24gYW5kIEVtYWlsMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjmF
pPJ9q0E7YkY3rs3BYHW8OWX5ShpHornMSMxqmNVNNRm5pELlzkniii8efNIxB8dOtINknS4p1aJk
xIW9hVE1eaROaJB7HHqkkqgX8pgV8pPMyaQylbsMTzC9mKALi+VuG6JG+ni8om+rWV6lL8/K2m2q
L+usobNqqrcuZzWLeeEeaYji5kbNoKXqvgvOdjp6Dpvq/NonWz1zHyLmSGHGTPNpsaguG7bUMSAs
vIKKjqQOpdeJQ/wWWq8dcdcRWdq6hw2v+vPhwvCkxWeM1tZUOt4KpLoDd7NlyP0e03RiqhjKaJMe
oYV+9Udly/hNVyh00jT/MLbu9mIwFIws6wIDAQABo4HhMIHeMB8GA1UdIwQYMBaAFK29mHo0tCb3
+sQmVO8DveAky1QaMB0GA1UdDgQWBBSJgmd9xJ0mcABLtFBIfN49rgRufTAOBgNVHQ8BAf8EBAMC
AQYwDwYDVR0TAQH/BAUwAwEB/zB7BgNVHR8EdDByMDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2Nh
LmNvbS9BZGRUcnVzdEV4dGVybmFsQ0FSb290LmNybDA2oDSgMoYwaHR0cDovL2NybC5jb21vZG8u
bmV0L0FkZFRydXN0RXh0ZXJuYWxDQVJvb3QuY3JsMA0GCSqGSIb3DQEBBQUAA4IBAQAZ2IkRbyis
pgCi54fBm5AD236hEv0e8+LwAamUVEJrmgnEoG3XkJIEA2Z5Q3H8+G+v23ZF4jcaPd3kWQR4rBz0
g0bzes9bhHIt5UbBuhgRKfPLSXmHPLptBZ2kbWhPrXIUNqi5sf2/z3/wpGqUNVCPz4FtVbHdWTBK
322gnGQfSXzvNrv042n0+DmPWq1LhTq3Du3Tzw1EovsEv+QvcI4l+1pUBrPQxLxtjftzMizpm4Qk
LdZ/kXpoAlAfDj9N6cz1u2fo3BwuO/xOzf4CjuOoEwqlJkRl6RDyTVKnrtw+ymsyXEFs/vVdoOr/
0fqbhlhtPZZH5f4ulQTCAMyOofK7MIIFGjCCBAKgAwIBAgIQbRnqpxlPajMi5iIyeqpx3jANBgkq
hkiG9w0BAQUFADCBrjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExh
a2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8v
d3d3LnVzZXJ0cnVzdC5jb20xNjA0BgNVBAMTLVVUTi1VU0VSRmlyc3QtQ2xpZW50IEF1dGhlbnRp
Y2F0aW9uIGFuZCBFbWFpbDAeFw0xMTA0MjgwMDAwMDBaFw0yMDA1MzAxMDQ4MzhaMIGTMQswCQYD
VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRow
GAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE5MDcGA1UEAxMwQ09NT0RPIENsaWVudCBBdXRoZW50
aWNhdGlvbiBhbmQgU2VjdXJlIEVtYWlsIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEAkoSEW0tXmNReL4uk4UDIo1NYX2Zl8TJO958yfVXQeExVt0KU4PkncQfFxmmkuTLE8UAakMwn
VmJ/F7Vxaa7lIBvky2NeYMqiQfZq4aP/uN8fSG1lQ4wqLitjOHffsReswtqCAtbUMmrUZ28gE49c
NfrlVICv2HEKHTcKAlBTbJUdqRAUtJmVWRIx/wmi0kzcUtve4kABW0ho3cVKtODtJB86r3FfB+Os
vxQ7sCVxaD30D9YXWEYVgTxoi4uDD216IVfmNLDbMn7jSuGlUnJkJpFOpZIP/+CxYP0ab2hRmWON
GoulzEKbm30iY9OpoPzOnpDfRBn0XFs1uhbzp5v/wQIDAQABo4IBSzCCAUcwHwYDVR0jBBgwFoAU
iYJnfcSdJnAAS7RQSHzePa4Ebn0wHQYDVR0OBBYEFHoTTgB0W8Z4Y2QnwS/ioFu8ecV7MA4GA1Ud
DwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMBEGA1UdIAQKMAgwBgYEVR0gADBYBgNVHR8E
UTBPME2gS6BJhkdodHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVROLVVTRVJGaXJzdC1DbGllbnRB
dXRoZW50aWNhdGlvbmFuZEVtYWlsLmNybDB0BggrBgEFBQcBAQRoMGYwPQYIKwYBBQUHMAKGMWh0
dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VVE5BZGRUcnVzdENsaWVudF9DQS5jcnQwJQYIKwYBBQUH
MAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEFBQADggEBAIXWvnhXVW0z
f0RS/kLVBqgBA4CK+w2y/Uq/9q9BSfUbWsXSrRtzbj7pJnzmTJjBMCjfy/tCPKElPgp11tA9OYZm
0aGbtU2bb68obB2v5ep0WqjascDxdXovnrqTecr+4pEeVnSy+I3T4ENyG+2P/WA5IEf7i686ZUg8
mD2lJb+972DgSeUWyOs/Q4Pw4O4NwdPNM1+b0L1garM7/vrUyTo8H+2b/5tJM75CKTmD7jNpLoKd
RU2oadqAGx490hpdfEeZpZsIbRKZhtZdVwcbpzC+S0lEuJB+ytF5OOu0M/qgOl0mWJ5hVRi0IdWZ
1eBDQEIwvuql55TSsP7zdfl/bucwggUlMIIEDaADAgECAhAJi8lShk8jTNMgVo7nXaDGMA0GCSqG
SIb3DQEBBQUAMIGTMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAw
DgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE5MDcGA1UEAxMwQ09N
T0RPIENsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQgU2VjdXJlIEVtYWlsIENBMB4XDTEyMDgxNDAw
MDAwMFoXDTEzMDgxNDIzNTk1OVowIzEhMB8GCSqGSIb3DQEJARYSY2hpZXN0YW5kQHNhbGsuZWR1
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtqz/Yy0csi37dTvyoNn8MNtPRvG2D7E3
pwSsuXFnBML17AZU1wpAKsQpggGoznvsFQvvOzJyWRBWKdF0deds1xpFGhe7+/GzMhnQKwFDeVZs
9hTXKWEERVVaBmyIbj0BP3D5VrUo/7eaybMALnxEjrteg9jyuFTSrGDc8qJ+c1Ps5vlH0v+Fvp4V
HoI8bW/+auu4mNT1E0nzpm3eWCsF1Rif2FVDetoDaArW1uTJh+g6oV3d1eJeGiqRnc+k7Q+ShfHj
wehOQT7dvYRE1CqArv69m2BBue+gHXQXWFgfaHx7/9mJapJG/ALpmqaHU8x9bMaBcZcIQHqEQV9E
3yOWpQIDAQABo4IB4jCCAd4wHwYDVR0jBBgwFoAUehNOAHRbxnhjZCfBL+KgW7x5xXswHQYDVR0O
BBYEFGOY5NfMgoO8duC6gWVGeskIkDbrMA4GA1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8EAjAAMCAG
A1UdJQQZMBcGCCsGAQUFBwMEBgsrBgEEAbIxAQMFAjARBglghkgBhvhCAQEEBAMCBSAwRgYDVR0g
BD8wPTA7BgwrBgEEAbIxAQIBAQEwKzApBggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2Rv
Lm5ldC9DUFMwVwYDVR0fBFAwTjBMoEqgSIZGaHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09NT0RP
Q2xpZW50QXV0aGVudGljYXRpb25hbmRTZWN1cmVFbWFpbENBLmNybDCBiAYIKwYBBQUHAQEEfDB6
MFIGCCsGAQUFBzAChkZodHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9DbGllbnRBdXRoZW50
aWNhdGlvbmFuZFNlY3VyZUVtYWlsQ0EuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21v
ZG9jYS5jb20wHQYDVR0RBBYwFIESY2hpZXN0YW5kQHNhbGsuZWR1MA0GCSqGSIb3DQEBBQUAA4IB
AQCHpk5ZpwS5faNtGTJxlHTy9hQm4NwJZhatrTz7xq23Q93RjLxwVn9tFG/YuPB1iN1aEA1DZWwP
Xi5OMbYxEb4Icw7/QGbJGwdHn6IDkU6IR2UOx5RzQJ84Fl6jUKCvlnJ3/UbZuzYG3fCyqi5GhUk1
PN4l/qwbxmsZKLwZep45lrbmea5XmqIO5NB4F02NLFYZWmEByKEi92aHLfgsvULq1CfNJMKIIYD2
/AW96vDQmk/liJHld+gkQQkIlTTzZmOYbHKtkeN8B8kFkB5OmdUZJvWoDMDMLLHhPkfRBBYuS7WO
jQY521z50tPATaS3yDZUYlcFyXjns8Wew/gv/XT5MYIDqzCCA6cCAQEwgagwgZMxCzAJBgNVBAYT
AkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNV
BAoTEUNPTU9ETyBDQSBMaW1pdGVkMTkwNwYDVQQDEzBDT01PRE8gQ2xpZW50IEF1dGhlbnRpY2F0
aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECEAmLyVKGTyNM0yBWjuddoMYwCQYFKw4DAhoFAKCCAdcw
GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTIwOTE2MTAyNDA0WjAj
BgkqhkiG9w0BCQQxFgQU/MP28fKL+seLPTiF62JAnDwStV8wgbkGCSsGAQQBgjcQBDGBqzCBqDCB
kzELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2Fs
Zm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxOTA3BgNVBAMTMENPTU9ETyBDbGllbnQg
QXV0aGVudGljYXRpb24gYW5kIFNlY3VyZSBFbWFpbCBDQQIQCYvJUoZPI0zTIFaO512gxjCBuwYL
KoZIhvcNAQkQAgsxgauggagwgZMxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNo
ZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMTkwNwYD
VQQDEzBDT01PRE8gQ2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECEAmL
yVKGTyNM0yBWjuddoMYwDQYJKoZIhvcNAQEBBQAEggEASrKAQ7sRZW4I6VMbBLOxGVr7qo51m8M5
wmD5c5Vj4OFiiXi1cfP7tTWDWMJc7wQHVeRZ6OjPTW/+CzVY77jjr/O7c1w3w9oz6F0YUlTayR+1
85mT+ZlSCtSeulJ4IOzBsuxds0kwkjK7HUvlCtMjIOcJN4xG2chHu5PYmzvuqR/BvKBPxtSPHask
XHWAX0WL9ng7XpJ0Od6I7ukpwA0ifTf0HgzOVdqfBYb+4fcpgJI0/I9s8iAJ43UNfVe2A3HFiAVG
ZzPrup8168taYYqtrWvLqdV6I9RCYSkfUY89UUh0dJxPz0OnxwvOWjH8j9L1rgyhYxgNvISCMcKF
Hr7vfwAAAAAAAA==

--Apple-Mail=_97D820A4-146E-42E7-915C-AE92C3461758--
