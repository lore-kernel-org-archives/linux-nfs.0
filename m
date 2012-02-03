Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62533 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757208Ab2BCVqj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 16:46:39 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q13Lkd6G016389
	for <linux-nfs@vger.kernel.org>; Fri, 3 Feb 2012 13:46:39 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix comparison between DS address lists
Date: Fri, 3 Feb 2012 21:46:28 +0000
Message-ID: <4B61D7FE-AB44-4A06-92E3-752E8EDFA871@netapp.com>
References: <1328301940-478-1-git-send-email-dros@netapp.com>
 <4F2C52EC.8050405@netapp.com>
In-Reply-To: <4F2C52EC.8050405@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_0A4BC803-87F9-46BF-9B39-11F82411D439";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_0A4BC803-87F9-46BF-9B39-11F82411D439
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1


On Feb 3, 2012, at 4:34 PM, Bryan Schumaker wrote:

> On 02/03/12 15:45, Weston Andros Adamson wrote:
>=20
>> data_server_cache entries should only be treated as the same if the =
address
>> list hasn't changed.
>>=20
>> A new entry will be made when an MDS changes an address list (as seen =
by
>> GETDEVINFO). The old entry will be freed once all references are =
gone.
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/nfs4filelayoutdev.c |   71 =
+++++++++++++++-----------------------------
>> 1 files changed, 24 insertions(+), 47 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
>> index 6eb59b0..420e748 100644
>> --- a/fs/nfs/nfs4filelayoutdev.c
>> +++ b/fs/nfs/nfs4filelayoutdev.c
>> @@ -108,58 +108,40 @@ same_sockaddr(struct sockaddr *addr1, struct =
sockaddr *addr2)
>> 	return false;
>> }
>>=20
>> -/*
>> - * Lookup DS by addresses.  The first matching address returns true.
>> - * nfs4_ds_cache_lock is held
>> - */
>> -static struct nfs4_pnfs_ds *
>> -_data_server_lookup_locked(struct list_head *dsaddrs)
>> +bool
>> +_same_data_server_addrs_locked(const struct list_head *dsaddrs1,
>> +			       const struct list_head *dsaddrs2)
>> {
>> -	struct nfs4_pnfs_ds *ds;
>> 	struct nfs4_pnfs_ds_addr *da1, *da2;
>>=20
>> -	list_for_each_entry(da1, dsaddrs, da_node) {
>> -		list_for_each_entry(ds, &nfs4_data_server_cache, =
ds_node) {
>> -			list_for_each_entry(da2, &ds->ds_addrs, da_node) =
{
>> -				if (same_sockaddr(
>> -					(struct sockaddr =
*)&da1->da_addr,
>> -					(struct sockaddr =
*)&da2->da_addr))
>> -					return ds;
>> -			}
>> -		}
>> +	/* step through both lists, comparing as we go */
>> +	for (da1 =3D list_first_entry(dsaddrs1, typeof(*da1), da_node),
>> +	     da2 =3D list_first_entry(dsaddrs2, typeof(*da2), da_node);
>> +	     da1 !=3D NULL && da2 !=3D NULL;
>> +	     da1 =3D list_entry(da1->da_node.next, typeof(*da1), =
da_node),
>> +	     da2 =3D list_entry(da2->da_node.next, typeof(*da2), =
da_node)) {
>> +		if (!same_sockaddr((struct sockaddr *)&da1->da_addr,
>> +				   (struct sockaddr *)&da2->da_addr))
>> +			return false;
>> 	}
>=20
>=20
> Does anybody else in the kernel ever need to walk two lists at the =
same time?  Would this be better as a helper function in list.h?

I'm game, but I can see problems with implementing this in list.h:

1) the for loop breaks once either list runs out of entries.  this means =
that=20
   callers have to check the values of the 'pos' nodes after calling the =
macro
   (depending on what they are doing).

   a way around this is to not use a macro and instead make a =
list_cmp_ordered()
   function with a cmp callback.  that probably wouldn't be acceptable =
for=20
   list.h

2) will that mean i have to implement a similar function for hlist, etc?

I'm really not sure how often this would be used.

-dros

>=20
>> -	return NULL;
>> +	if (da1 =3D=3D NULL && da2 =3D=3D NULL)
>> +		return true;
>> +
>> +	return false;
>> }
>>=20
>> /*
>> - * Compare two lists of addresses.
>> + * Lookup DS by addresses.  nfs4_ds_cache_lock is held
>>  */
>> -static bool
>> -_data_server_match_all_addrs_locked(struct list_head *dsaddrs1,
>> -				    struct list_head *dsaddrs2)
>> +static struct nfs4_pnfs_ds *
>> +_data_server_lookup_locked(const struct list_head *dsaddrs)
>> {
>> -	struct nfs4_pnfs_ds_addr *da1, *da2;
>> -	size_t count1 =3D 0,
>> -	       count2 =3D 0;
>> -
>> -	list_for_each_entry(da1, dsaddrs1, da_node)
>> -		count1++;
>> -
>> -	list_for_each_entry(da2, dsaddrs2, da_node) {
>> -		bool found =3D false;
>> -		count2++;
>> -		list_for_each_entry(da1, dsaddrs1, da_node) {
>> -			if (same_sockaddr((struct sockaddr =
*)&da1->da_addr,
>> -				(struct sockaddr *)&da2->da_addr)) {
>> -				found =3D true;
>> -				break;
>> -			}
>> -		}
>> -		if (!found)
>> -			return false;
>> -	}
>> +	struct nfs4_pnfs_ds *ds;
>>=20
>> -	return (count1 =3D=3D count2);
>> +	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node)
>> +		if (_same_data_server_addrs_locked(&ds->ds_addrs, =
dsaddrs))
>> +			return ds;
>> +	return NULL;
>> }
>>=20
>> /*
>> @@ -356,11 +338,6 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, =
gfp_t gfp_flags)
>> 		dprintk("%s add new data server %s\n", __func__,
>> 			ds->ds_remotestr);
>> 	} else {
>> -		if =
(!_data_server_match_all_addrs_locked(&tmp_ds->ds_addrs,
>> -							 dsaddrs)) {
>> -			dprintk("%s:  multipath address mismatch: %s !=3D =
%s",
>> -				__func__, tmp_ds->ds_remotestr, =
remotestr);
>> -		}
>> 		kfree(remotestr);
>> 		kfree(ds);
>> 		atomic_inc(&tmp_ds->ds_count);
>=20
>=20


--Apple-Mail=_0A4BC803-87F9-46BF-9B39-11F82411D439
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDMyMTQ2MjhaMCMGCSqGSIb3DQEJBDEWBBSUmp4fJyn0H7pp
hvtDMv9SpxJh8DANBgkqhkiG9w0BAQEFAASCAQCl4iBANE+W1pk3aOwOrD2Frnnuam3w9BjJ9NAR
5OIObn5uwfew158bV5EBLl5uGMhDtbiD0xHxdS6NCNJRDY3jVby9l7aG5OVNSht9CI0sC1wBmAeN
IyXOjkbmP8yQgyLaVNdfzwgHDo1ZwuBkra9X5sIyaQMJhlc3+b4pH4RMyzp6bv0DCNxDoNnao2mo
djXdJDHuculinZCdO6xw36D6ZDQnmKuJUu4KW45uhs5JFAZglc01hTRf4Ox5wfIhLGpVdMYtfCOc
xf0EbocUcLqJ+JXRqIy5EDq9RG8edZJTUYbFJANvB+LIINJCRgbHEduMMML7tvURAh9xvedUpUM5
AAAAAAAA

--Apple-Mail=_0A4BC803-87F9-46BF-9B39-11F82411D439--
