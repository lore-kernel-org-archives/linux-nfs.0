Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14529 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199Ab2BPWBH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 17:01:07 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GM134F015036
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 14:01:06 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 1/1] NFSv4.1 set the cl_hostname for data
 servers
Date: Thu, 16 Feb 2012 22:00:20 +0000
Message-ID: <18B83A3A-12E1-42D8-AE93-9BC2C5FDB136@netapp.com>
References: <1329426646-2074-1-git-send-email-andros@netapp.com>
 <1329427752.19793.30.camel@lade.trondhjem.org>
In-Reply-To: <1329427752.19793.30.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_CFD6E35B-D085-45D6-A6BD-2AA1727DFA35";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_CFD6E35B-D085-45D6-A6BD-2AA1727DFA35
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 16, 2012, at 4:29 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-16 at 16:10 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>=20
>> Used by /proc/fs/nfsfs/servers
>>=20
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/client.c            |    3 ++-
>> fs/nfs/internal.h          |    3 ++-
>> fs/nfs/nfs4filelayoutdev.c |   11 ++++++++++-
>> 3 files changed, 14 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index d0f850f..c625284 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -1443,7 +1443,7 @@ error:
>>  */
>> struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>> 		const struct sockaddr *ds_addr,
>> -		int ds_addrlen, int ds_proto)
>> +		int ds_addrlen, int ds_proto, char *ds_hostname)
>=20
> Can you make this (and the other instances below) 'const char *', so
> that we avoid any confusion? Otherwise it looks more or less OK...
>=20
> Note that we should consider splitting da->da_remotestr into a
> hostname/port part at some point so that we avoid the copy below.

da_remotestr (and ds_remotestr) were meant to be for display only (and =
iirc they can actually be NULL).

The right way to do this is from the actual sin_addr (da_addr).

-dros=

--Apple-Mail=_CFD6E35B-D085-45D6-A6BD-2AA1727DFA35
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTYyMjAwMjBaMCMGCSqGSIb3DQEJBDEWBBSmfLcO5QfSohS8
Uc/v4Z+OBmlntTANBgkqhkiG9w0BAQEFAASCAQBwRCd1tF6iCRPrDx3SAxpt8JFu6JpFlepKSojZ
9i0wm0BwxXh2qbGeNBvMO/JBSyJDgN9JZm3nbFda/clErwgCxQfd/bI+nk9mdwbGstn0WQPS47TU
3NrSybgi90d9h6PH3qzfjIjxYxEodOMHcEokX2rqRWTgRIWcPq2L4v5o9XWSuxGuQyWzvnpZDNJu
JO0MDhveXlmHTClw3UC9EHxyDM5B1TKnEGxDGbA7Jhpsg6usZ91FvDTAQhVMYzFrpElsKvqKXjYr
sFdPMkEE+55/E6jUQS9X//kZwLG3Y4tjf1h4tpj8a+00FSCm3pjBB2JFhIB7lvdvAGjnH6z0jeyh
AAAAAAAA

--Apple-Mail=_CFD6E35B-D085-45D6-A6BD-2AA1727DFA35--
