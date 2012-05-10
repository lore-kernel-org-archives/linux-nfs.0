Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50178 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757449Ab2EJU4Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 16:56:16 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4AKuFFK011325
	for <linux-nfs@vger.kernel.org>; Thu, 10 May 2012 13:56:16 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Subject: Re: [PATCH] NFS: Prevent a deadlock in the new read and write code
Date: Thu, 10 May 2012 20:56:14 +0000
Message-ID: <77BEB37B-609E-46EF-BE07-107AC6EB9164@netapp.com>
References: <1336582284-8558-1-git-send-email-Trond.Myklebust@netapp.com>
 <A96F9C32-8B2A-441A-BBE9-91747BB585FF@netapp.com>
 <31612217-5DE3-43D0-BFAF-40A23530FEC8@netapp.com>
 <1336590915.3127.135.camel@lade.trondhjem.org>
In-Reply-To: <1336590915.3127.135.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_23D89316-6798-4461-A7B2-B5AEEBDF9A97";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_23D89316-6798-4461-A7B2-B5AEEBDF9A97
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252


On May 9, 2012, at 3:15 PM, Myklebust, Trond wrote:

> On Wed, 2012-05-09 at 18:22 +0000, Adamson, Dros wrote:
>> On May 9, 2012, at 2:20 PM, Adamson, Dros wrote:
>>=20
>>> ACK - This fixes the errant behavior I was seeing.
>>>=20
>>> Before (on any protocol version mounted at /mnt):
>>> $ dd if=3D/dev/zero of=3Dzerofile bs=3D10024 count=3D1000 ; while =
true; do (rm -rf /mnt/foo && echo rm ok) || ls -la /mnt/foo ; mkdir -p =
/mnt/foo/; cp zerofile /mnt/foo/file ; done
>>> 1000+0 records in
>>> 1000+0 records out
>>> 10024000 bytes (10 MB) copied, 0.146738 s, 68.3 MB/s
>>> rm ok
>>> rm: cannot remove `/mnt/foo': Directory not empty
>>> ls: /mnt/foo/.nfs000000000004089d00000001: No such file or directory
>>> total 9800
>>> drwxrwxr-x 2 dros dros     4096 May  9 09:46 .
>>> drwxrwxrwx 5 root root     4096 May  9 09:46 ..
>>> -rw-rw-r-- 0 dros dros 10024000 May  9 09:46 =
.nfs000000000004089d00000001
>>> rm: cannot remove `/mnt/foo': Directory not empty
>>> ...
>>>=20
>>=20
>> Oops, this is after the patch is applied:
>>=20
>>> $ dd if=3D/dev/zero of=3Dzerofile bs=3D10024 count=3D1000 ; while =
true; do (rm -rf /mnt/foo && echo rm ok) || ls -la /mnt/foo ; mkdir -p =
/mnt/foo/; cp zerofile /mnt/foo/file ; done
>>> 1000+0 records in
>>> 1000+0 records out
>>> 10024000 bytes (10 MB) copied, 0.137596 s, 72.9 MB/s
>>> rm ok
>>> rm ok
>>> rm ok
>>> rm ok
>>> ...
>>>=20
>>> -dros
>=20
> OK... Having thought a bit more about the problem, I'd prefer to see =
the
> write code do the same really as the read code is doing. i.e. release
> the nfs_page after the page_writeback lock has been released.
>=20
> I've just written a series of patches to do this. The first patch in =
the
> series is the actual fix. The rest is clean ups in order to make the
> code a bit more readable=85

I tested the new patchset and it seems to work great!

-dros



--Apple-Mail=_23D89316-6798-4461-A7B2-B5AEEBDF9A97
Content-Disposition: attachment; filename="smime.p7s"
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIDTzCCA0sw
ggIzoAMCAQICAQEwCwYJKoZIhvcNAQEFMEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYD
VQQGEwJVUzEeMBwGCSqGSIb3DQEJARYPZHJvc0BuZXRhcHAuY29tMB4XDTExMDYwODIyMDc0NloX
DTEyMDYwNzIyMDc0NlowRjEXMBUGA1UEAwwOV2VzdG9uIEFkYW1zb24xCzAJBgNVBAYTAlVTMR4w
HAYJKoZIhvcNAQkBFg9kcm9zQG5ldGFwcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC8/tJxtovJEXYRfSsrFOWKHxIZGY7/2mBee1DpWuoGDbVNapefCC7WXe+Nqxz609w2J/Mk
/k3trZ3Ge2NXK0tGnP9NzjkzpGA7rSpM3wUFsvbLMUEGfQpvV24/nYvcLHTvOOEUaDPpHduN94bD
dwvyowzDIRIpF2MeRnOzBNeHkrGHlZdzPmGjm8tkhrDRRkDYHhlxaiG4z30KCfAazxomuINiy1kj
vbndXooYMDoh9H63hgW4NkOedtLdflLa322DXQ3nFU7YbyOIjHVl1tgWJLDWf7WT3lsAB8KvuJZ5
zhsUB+fqxCKPJVRPDO1gjChvvtGiG1tGUUZz0H9Wx00zAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIH
gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDBDAaBgNVHREEEzARgQ9kcm9zQG5ldGFwcC5jb20wDQYJ
KoZIhvcNAQEFBQADggEBACv0niZSmW+psB1sJXULh3mecDbN2mj0bFpN1YNdjcV7BiOLJ1Rs1ibV
f13h73z8C7SBsPXTM5si8gmJtOnXM5jsgtlql44h/RrjUr8+mtK5DPCZls9J7iz3cGthzwOPvxUj
nMSv3BpRX5oJom5ESgCM9Nn4u/ECTlLMhEIOYnBFiN0eDxcxz+r1cpbHg3r0otIKyxLpeaCjP6AH
F93EHp4T8Rb63y3CcDgxrQGHlTdVi3QvxaMUexUXD81fiA+UqsB/MKmRxB1Hs4Vf3Q/+ejcm78K1
ROF8TNPmNWRlKg3Y7cSFjZGzLuzXsvSsCbw4HLn0oZe/OfgSbarTAxttL5IxggHRMIIBzQIBATBL
MEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYDVQQGEwJVUzEeMBwGCSqGSIb3DQEJARYP
ZHJvc0BuZXRhcHAuY29tAgEBMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MTAyMDU2MTVaMCMGCSqGSIb3DQEJBDEWBBQ4GJmzUpdHh67q
feAmkq5aVXHI3zANBgkqhkiG9w0BAQEFAASCAQAQRVOj5XieQC9H62LK4cYqHeKxoyCRRZ9gNOt1
LmYT/L5BYYVZx+tRhRscsHyPPRwgf0VXDBnljpJHdkrq4dTq3MPMSY3+ni3TWz1zfk3kyoxKwjQA
TFzVKBUH3DZubiYDTZDR0acf0hhtlv8yVJDsRqEISGoIIydqQUYyCYpB/cAdW8EzXf8A53GuA1lm
pIK9MR1RZSgJero4agZFJDTjvOQ4nrXhAFDflJmda14st/1EaUWwxZr6D9r6fE0pTLxXMHEoFcxT
ySd115p3pTOAc1K4el0RC+Mjmqsa8DC/tEvE328I1R90BiQ0QrQH7RI+56wP7JCrk+UMa0HpGrJ/
AAAAAAAA

--Apple-Mail=_23D89316-6798-4461-A7B2-B5AEEBDF9A97--
