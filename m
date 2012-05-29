Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21381 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902Ab2E2P5S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 11:57:18 -0400
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4TFvHN1010686
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 08:57:17 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/8] NFSv4.1: Move NFSPROC4_CLNT_BIND_CONN_TO_SESSION to
 the end of the operations
Date: Tue, 29 May 2012 15:57:16 +0000
Message-ID: <52B0174D-07F3-4075-8F4C-325558A61D89@netapp.com>
References: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-3-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-4-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-5-git-send-email-Trond.Myklebust@netapp.com>
 <ACF824E6-0473-4E05-9350-8808A180AC15@netapp.com>
 <1338306221.5433.27.camel@lade.trondhjem.org>
In-Reply-To: <1338306221.5433.27.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E2C011E1-674C-4057-9CBF-802E4FA017A4";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_E2C011E1-674C-4057-9CBF-802E4FA017A4
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On May 29, 2012, at 11:43 AM, Myklebust, Trond wrote:

> On Tue, 2012-05-29 at 15:05 +0000, Adamson, Dros wrote:
>> On May 25, 2012, at 6:03 PM, Trond Myklebust wrote:
>>=20
>>> For backward compatibility with nfs-utils.
>>=20
>> Can you expand on that a bit? I put them where they are because they =
are in order of operation id (bind_conn_to_session =3D 41, exchange_id =3D=
 42).
>=20
> nfs4_procedures isn't (and really can't be) ordered by operation. It =
is
> a set of COMPOUNDs, each of which reflects a certain functionality
> rather than a specific operation.

Oh I see.

>=20
>> If we really must only add to the end of the list, we really should =
have a comment above nfs4_procedures, etc.
>=20
> The whole nfsstat is currently problematic because we occasionally do
> want to be able to add to the NFSv4.0 procedures (above the #ifdef
> CONFIG_NFS_V4_1) as well as the NFSv4.1 procedures.
>=20
> Appending is usually the right thing to do, but that #ifdef makes it
> problematic since if we were to append NFSv4.0 routines, then they =
would
> move depending on whether or not we compile in NFSv4.1 or not.
>=20
> Adding in NFSv4.2 will give rise to even more 'interesting' situations
> should we start protecting it with yet more #ifdefs...
>=20
> The solution may be to just accept that we cannot keep separating
> NFSv4.0 and NFSv4.1 routines, and to just get rid of the #ifdefs so =
that
> we can always append to nfs4_procedures[]. However we haven't yet done
> this, and so there is no good 'official' documented policy.

Maybe a comment with a note about how fragile this is and a reminder to =
test nfsstat?

-dros=

--Apple-Mail=_E2C011E1-674C-4057-9CBF-802E4FA017A4
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjkxNTU3MDlaMCMGCSqGSIb3DQEJBDEWBBQ7+Wg+/7XJNq5j
MPEkemBYgaqzPzANBgkqhkiG9w0BAQEFAASCAQBe4oKfrEzNiw1KUnSHfg1kBAHQ37apU5AXckoa
XlTm4U7Ch9Z8teyAI3n3o2q6BJsz5WY//VFrrrer6lpwqma4VhonweEjtDG6GlizXH+TJTCyA6Oe
h57oz+7gdPVcOfj9vfhxkm+sLns5qDk1M78MRZaysAzK6eTgkRGirjg5ddRKKjiyEQLSq+3A2tq2
KQxTEK5XNiKPNifojvE2wkBj/HdjxduZgpAeUy7WgVVcprF0CwlFbiapILi/C0syQpJtAChrPlp5
rOVd3jPWwIMKnD2rWfSRilj70M+HkOTOkvzC1+jUDx6Eu42ibDe78dCGHetKsd3qyTeNmxVyZeTK
AAAAAAAA

--Apple-Mail=_E2C011E1-674C-4057-9CBF-802E4FA017A4--
