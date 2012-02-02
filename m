Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56675 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644Ab2BBUPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Feb 2012 15:15:15 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: dont allow minorversion= opt when vers != 4
Date: Thu, 2 Feb 2012 20:14:50 +0000
Message-ID: <C4EC1863-AA4A-42E1-8FF6-107A1E0162B0@netapp.com>
References: <1328123201-894-1-git-send-email-dros@netapp.com>
 <4F29C04B.8020703@panasas.com>
 <BD47F92C-6031-4F3F-A715-8275C7399717@netapp.com>
 <4F2A94FA.30603@netapp.com>
 <F797D932-12F4-4063-B46D-0410385A911F@netapp.com>
 <4F2ADD58.9080000@netapp.com>
In-Reply-To: <4F2ADD58.9080000@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_8064E639-49D5-49B4-AD98-7BB0B112A533";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_8064E639-49D5-49B4-AD98-7BB0B112A533
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252


On Feb 2, 2012, at 2:00 PM, Bryan Schumaker wrote:

> On 02/02/12 12:03, Adamson, Dros wrote:
>=20
>>=20
>> On Feb 2, 2012, at 8:51 AM, Bryan Schumaker wrote:
>>=20
>>> On 02/01/12 18:07, Adamson, Dros wrote:
>>>=20
>>>> On Feb 1, 2012, at 5:44 PM, Boaz Harrosh wrote:
>>>>=20
>>>>> On 02/01/2012 09:06 PM, Weston Andros Adamson wrote:
>>>>>> Don't allow invalid 'vers' and 'minorversion' combinations in =
mount options,
>>>>>> such as "vers=3D3,minorversion=3D1".
>>>>>>=20
>>>>>=20
>>>>> Just my $0.017 I don't see the point in this.=20
>>>>>=20
>>>>> If vers=3D=3D3 then minorversion is ignored, just like today.
>>>>> What kind  of extra protection does it buy us?
>>>>=20
>>>> No, minorversion is not ignored when vers=3D3. =20
>>>=20
>>>=20
>>> But after mounting, does setting vers=3D3, minorversion=3D1 cause =
any change in NFS v3 behavior?
>>>=20
>>=20
>> No it doesn't.  Past the parsing of options, minorversion is ignored =
for versions other than 4.
>>=20
>> I just don't understand how anyone can have problem with this patch.  =
Why would we want to validate minorversion in some cases, but not all =
cases?  How would this patch be a bad thing?
>>=20
>=20
> I don't have a problem with the patch, it makes sense that we =
shouldn't confuse developers or users.  I was just curious if there was =
a spot where we had "if minor_version =3D=3D 1: do_something()" without =
checking for major_version =3D=3D 4.
>=20

Ah, I misunderstood=85=20

Versions !=3D 4 pass the nfs_parsed_mount_data struct to =
nfs_create_server(), which completely ignores the minorversion member.
Version =3D=3D 4 passes the nfs_parsed_mount_data struct to  =
nfs4_create_server(), which (through nfs4_init_server()) uses the =
minorversion member.

So, having a set minorversion when mounting vers !=3D 4 has no effect on =
how the NFS module operates. This is Boaz's argument for why the patch =
isn't needed. I understand that reasoning, but this is a user experience =
enhancement and I think they are important too.

This patch only addresses an inconsistency in mount option validation. =
This doesn't change anything at the protocol level. I should have done a =
better job explaining this in the original post!

-dros

> - Bryan
>=20
>> It's about usability -- if this can confuse NFS developers, how are =
end users going to handle it?
>>=20
>> -dros
>=20
>=20


--Apple-Mail=_8064E639-49D5-49B4-AD98-7BB0B112A533
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDIyMDE0NTBaMCMGCSqGSIb3DQEJBDEWBBReVq4qabGDaEJC
SOlz1DyEwGINYTANBgkqhkiG9w0BAQEFAASCAQCK5NUGBPT9p7Z/M830TAWjFowevfQu95WRlAW8
smLQl7NR1MzxrGSe1GN5u4bhS98fyt7qqCsGA8U6ewiZE8sVMm4NHLQ+6lDr2gPcQY79WkigA51C
SvLmMLARqM0v1s1fYsOVh/nXQEKRVHD415TQbSYlgOMwDwR4EFuLI2VVYtbWq1NV5Eyl82cQlenx
+tQcCjBVQoQgmKCajo92rUxvEj6fuGMXOhqxUPbzomMsKPKVlLJBYVJC6j3EFFlOKtWoHrjixxlV
0t9rzZ41yYCYi8ey4q5sMI85Ir3BrJtX7BWODD4MqhwGmdnbB+GSbsMy6O1jo1gGsFVeyQGJSRmU
AAAAAAAA

--Apple-Mail=_8064E639-49D5-49B4-AD98-7BB0B112A533--
