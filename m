From: =?ISO-8859-15?Q?Llu=EDs_Batlle_i_Rossell?= <viriketo@gmail.com>
Subject: Exporting fs from a looped squashfs in linux
Date: Sat, 04 Nov 2006 23:14:56 +0100
Message-ID: <454D10E0.5020301@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0426122216=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GgTn0-0003it-PQ
	for nfs@lists.sourceforge.net; Sat, 04 Nov 2006 14:14:58 -0800
Received: from py-out-1112.google.com ([64.233.166.176])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GgTn1-0003LP-LP
	for nfs@lists.sourceforge.net; Sat, 04 Nov 2006 14:15:00 -0800
Received: by py-out-1112.google.com with SMTP id j37so606172pyc
	for <nfs@lists.sourceforge.net>; Sat, 04 Nov 2006 14:14:59 -0800 (PST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a cryptographically signed message in MIME format.

--===============0426122216==
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=sha1; boundary="------------ms010909070708080607020807"

This is a cryptographically signed message in MIME format.

--------------ms010909070708080607020807
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hi,

I'm trying to serve a mounted loop-filesystem (squashfs) from a linux
box to other unixes. And it doesn't work due to (I think) something
related to /proc/fs/nfs/filehandle.

The server, on mount, says only (mountd with -d all)
Nov  4 23:05:11 llimona rpc.mountd: MNT3(/nfs/sparc/netbsd/usr/) called
Nov  4 23:05:11 llimona rpc.mountd: authenticated mount request from
mandarina:872 for /nfs/sparc/netbsd/usr (/nfs/sparc/netbsd/usr)

The client, on mount says only:
mount: llimona:/nfs/sparc/netbsd/usr/ failed, reason given by server:
S'ha denegat el perm=EDs
(That is, Permission Denied)

I've straced a foreground rpc.mountd, and I've seen the next:
open("/proc/fs/nfs/filehandle", O_RDWR) =3D 9
fstat64(9, {st_mode=3DS_IFREG|0600, st_size=3D0, ...}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0xb7efd000
write(9, "* /nfs/sparc/netbsd/usr 64 \n", 28) =3D -1 EPERM (Operation not
permitted)
read(9, "", 4096)                       =3D 0
close(9)                                =3D 0
munmap(0xb7efd000, 4096)                =3D 0
sendmsg(6, {msg_name(16)=3D{sa_family=3DAF_INET, sin_port=3Dhtons(872),
sin_addr=3Dinet_addr("192.168.1.33")},
msg_iov(1)=3D[{"\36\201\"\21\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..=
.,
28}], msg_controllen=3D24, msg_control=3D0x805ce38, , msg_flags=3D0}, 0) =
=3D 28

So you can see the "EPERM" related to the 'filehandle' proc file. What's
happening here? Am I unable to export a loop squashfs?

Thanks in advance!

--------------ms010909070708080607020807
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJTTCC
AwEwggJqoAMCAQICEC7GHhAgrXIK4gbYgnLRBvIwDQYJKoZIhvcNAQEEBQAwYjELMAkGA1UE
BhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMT
I1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA2MDMxMzIyNTMwMVoX
DTA3MDMxMzIyNTMwMVowRDEfMB0GA1UEAxMWVGhhd3RlIEZyZWVtYWlsIE1lbWJlcjEhMB8G
CSqGSIb3DQEJARYSdmlyaWtldG9AZ21haWwuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAvULiATyjPs5ZNXAo1qG4p3B136VTuzi82L14U0YTuyUO1lrJNJypHfM1+5d5
0vYJKzzSt/sCLD76X3vO3DxC5cqC2nrchEN+GCKndpE2PM7Sp9eWrHs9IVWCfYxP5M3kLoeb
5XXeRCciHCeYJ7+6SLrftWxU2qKVtAAQMGnLghUuwMck0sWXiywDhQ3MVIPbdOEu+VGKRMRM
Ncq4bFRvqNRpNfG5A+WOtsuqxTpJtdLcP0fKTIKK3N7r7k4IMYEHLTPl9iH5Ve0OPgeTekyH
ADZnIjE7zweBDBH0Qh8DDTaMx5XszHAMwsChHxBmCcAjncdPnqxdShbOPshtBiPxHwIDAQAB
o1IwUDAOBgNVHQ8BAf8EBAMCA/gwEQYJYIZIAYb4QgEBBAQDAgUgMB0GA1UdEQQWMBSBEnZp
cmlrZXRvQGdtYWlsLmNvbTAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBBAUAA4GBAFRbmD1g
BXH11x+sumaBS5h4A4ejYdmB1b5u2jBhkZnfvO92RD23dnS8PKk4MdGxGQUzawyGK8JSAUJg
eERQ1Xoxa/xRgTGDphoZLLBdFkkvqjrqz2h2hiXkZHGyE3yFst9UVrXDHZKOyCR9c3LaXPQp
Iz2lJiADJ2BtByn43FtHMIIDATCCAmqgAwIBAgIQLsYeECCtcgriBtiCctEG8jANBgkqhkiG
9w0BAQQFADBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0
eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0Ew
HhcNMDYwMzEzMjI1MzAxWhcNMDcwMzEzMjI1MzAxWjBEMR8wHQYDVQQDExZUaGF3dGUgRnJl
ZW1haWwgTWVtYmVyMSEwHwYJKoZIhvcNAQkBFhJ2aXJpa2V0b0BnbWFpbC5jb20wggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9QuIBPKM+zlk1cCjWobincHXfpVO7OLzYvXhT
RhO7JQ7WWsk0nKkd8zX7l3nS9gkrPNK3+wIsPvpfe87cPELlyoLaetyEQ34YIqd2kTY8ztKn
15asez0hVYJ9jE/kzeQuh5vldd5EJyIcJ5gnv7pIut+1bFTaopW0ABAwacuCFS7AxyTSxZeL
LAOFDcxUg9t04S75UYpExEw1yrhsVG+o1Gk18bkD5Y62y6rFOkm10tw/R8pMgorc3uvuTggx
gQctM+X2IflV7Q4+B5N6TIcANmciMTvPB4EMEfRCHwMNNozHlezMcAzCwKEfEGYJwCOdx0+e
rF1KFs4+yG0GI/EfAgMBAAGjUjBQMA4GA1UdDwEB/wQEAwID+DARBglghkgBhvhCAQEEBAMC
BSAwHQYDVR0RBBYwFIESdmlyaWtldG9AZ21haWwuY29tMAwGA1UdEwEB/wQCMAAwDQYJKoZI
hvcNAQEEBQADgYEAVFuYPWAFcfXXH6y6ZoFLmHgDh6Nh2YHVvm7aMGGRmd+873ZEPbd2dLw8
qTgx0bEZBTNrDIYrwlIBQmB4RFDVejFr/FGBMYOmGhkssF0WSS+qOurPaHaGJeRkcbITfIWy
31RWtcMdko7IJH1zctpc9CkjPaUmIAMnYG0HKfjcW0cwggM/MIICqKADAgECAgENMA0GCSqG
SIb3DQEBBQUAMIHRMQswCQYDVQQGEwJaQTEVMBMGA1UECBMMV2VzdGVybiBDYXBlMRIwEAYD
VQQHEwlDYXBlIFRvd24xGjAYBgNVBAoTEVRoYXd0ZSBDb25zdWx0aW5nMSgwJgYDVQQLEx9D
ZXJ0aWZpY2F0aW9uIFNlcnZpY2VzIERpdmlzaW9uMSQwIgYDVQQDExtUaGF3dGUgUGVyc29u
YWwgRnJlZW1haWwgQ0ExKzApBgkqhkiG9w0BCQEWHHBlcnNvbmFsLWZyZWVtYWlsQHRoYXd0
ZS5jb20wHhcNMDMwNzE3MDAwMDAwWhcNMTMwNzE2MjM1OTU5WjBiMQswCQYDVQQGEwJaQTEl
MCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3Rl
IFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
AoGBAMSmPFVzVftOucqZWh5owHUEcJ3f6f+jHuy9zfVb8hp2vX8MOmHyv1HOAdTlUAow1wJj
WiyJFXCO3cnwK4Vaqj9xVsuvPAsH5/EfkTYkKhPPK9Xzgnc9A74r/rsYPge/QIACZNenpruf
ZdHFKlSFD0gEf6e20TxhBEAeZBlyYLf7AgMBAAGjgZQwgZEwEgYDVR0TAQH/BAgwBgEB/wIB
ADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLnRoYXd0ZS5jb20vVGhhd3RlUGVyc29u
YWxGcmVlbWFpbENBLmNybDALBgNVHQ8EBAMCAQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMT
EVByaXZhdGVMYWJlbDItMTM4MA0GCSqGSIb3DQEBBQUAA4GBAEiM0VCD6gsuzA2jZqxnD3+v
rL7CF6FDlpSdf0whuPg2H6otnzYvwPQcUCCTcDz9reFhYsPZOhl+hLGZGwDFGguCdJ4lUJRi
x9sncVcljd2pnDmOjCBPZV+V2vf3h9bGCE6u9uo05RAaWzVNd+NWIXiC3CEZNd4ksdMdRv9d
X2VPMYIDZDCCA2ACAQEwdjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1
bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElz
c3VpbmcgQ0ECEC7GHhAgrXIK4gbYgnLRBvIwCQYFKw4DAhoFAKCCAcMwGAYJKoZIhvcNAQkD
MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMDYxMTA0MjIxNDU2WjAjBgkqhkiG9w0B
CQQxFgQUjV6uxUW+FEPQESrpExAMZLB3UQQwUgYJKoZIhvcNAQkPMUUwQzAKBggqhkiG9w0D
BzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwIC
ASgwgYUGCSsGAQQBgjcQBDF4MHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBD
b25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFp
bCBJc3N1aW5nIENBAhAuxh4QIK1yCuIG2IJy0QbyMIGHBgsqhkiG9w0BCRACCzF4oHYwYjEL
MAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAq
BgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhAuxh4QIK1yCuIG
2IJy0QbyMA0GCSqGSIb3DQEBAQUABIIBAKGA8wfwM3JVR+2y7Od/D8MUxKEM8fxJFgg/8QT1
z6TiIrl9GDj5XSiZ59z4P01WaPPX2qxAQt7eqlblavGF35Iu7If8ZamX/sCo1HTReLQx/lhN
pZ7gnGwPuVo9TFy6n/xmwdFHzKzUACpavYrXkxmbFPo3CL4BO95JqpfTJ0QJbZif7y13AOTK
oVXS2j6jEbL2cT6YfZMjqNjM2a/tFlxn4mjCnNbNYFJ04uKkVdE5wqHzHwmfrdhj2xBnPcx1
suwYxp8N0vpQ4TBUSgSMLLTYeU6dDEZ66Ja8u0q6ANah6rz87p0e7wftOXZ6DfsPCqQjJuqA
1bo97PAItayNgBUAAAAAAAA=
--------------ms010909070708080607020807--


--===============0426122216==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0426122216==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0426122216==--
