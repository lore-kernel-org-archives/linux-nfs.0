Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47196 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755651Ab2BOA7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 19:59:46 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1F0xjg7002300
	for <linux-nfs@vger.kernel.org>; Tue, 14 Feb 2012 16:59:46 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: fix nfs4_find_slot() not found ret value
Date: Wed, 15 Feb 2012 00:59:34 +0000
Message-ID: <92E0B63A-C29D-4DCD-8A9D-258E707FAED3@netapp.com>
References: <1329254637-1952-1-git-send-email-dros@netapp.com>
 <1329258196.11759.8.camel@lade.trondhjem.org>
In-Reply-To: <1329258196.11759.8.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E544EAB1-6D25-4262-99BC-DDFAB70E7FD7";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_E544EAB1-6D25-4262-99BC-DDFAB70E7FD7
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252


On Feb 14, 2012, at 5:23 PM, Myklebust, Trond wrote:

> On Tue, 2012-02-14 at 16:23 -0500, Weston Andros Adamson wrote:
>> The caller of nfs4_find_slot() expects NFS4_MAX_SLOT_TABLE when no =
slot is
>> available (also mentioned in the comment header for =
nfs4_find_slot()).
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> This fixes an OOPS that is easy to reproduce:
>>=20
>> dd if=3D/dev/zero of=3D./zerofile bs=3D10024 count=3D1
>>=20
>> nfs4_find_slot() returns 2^32-1 which !=3D NFS4_MAX_SLOT_TABLE, so =
it's used
>> as a valid slotid.
>>=20
>> Note that NFS4_NO_SLOT is still used for =
nfs4_slot_table::highest_used_slotid
>=20
> We need to fix the broken caller, not nfs4_find_slot()... I seem to =
have
> missed a couple of instances in the 'Convert slotid' patch=85
>=20
> How's this?

Looks good - one minor issue below.

-dros

>=20
> =
8<------------------------------------------------------------------------=
-----
> =46rom 6e885e370726c4d72a24acfb06cbd6673e4b791f Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Tue, 14 Feb 2012 17:11:57 -0500
> Subject: [PATCH] fixup! NFSv4.1: Convert slotid from u8 to u32
>=20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/nfs4proc.c |   21 ++++++++++-----------
> 1 files changed, 10 insertions(+), 11 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index da985c3..0b33165 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -362,16 +362,14 @@ static void renew_lease(const struct nfs_server =
*server, unsigned long timestamp
>  * When updating highest_used_slotid there may be "holes" in the =
bitmap
>  * so we need to scan down from highest_used_slotid to 0 looking for =
the now
>  * highest slotid in use.
> - * If none found, highest_used_slotid is set to -1.
> + * If none found, highest_used_slotid is set to NFS4_NO_SLOT.
>  *
>  * Must be called while holding tbl->slot_tbl_lock
>  */
> static void
> -nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
> +nfs4_free_slot(struct nfs4_slot_table *tbl, u32 slotid)
> {
> -	int slotid =3D free_slotid;
> -
> -	BUG_ON(slotid < 0 || slotid >=3D NFS4_MAX_SLOT_TABLE);
> +	BUG_ON(slotid >=3D NFS4_MAX_SLOT_TABLE);
> 	/* clear used bit in bitmap */
> 	__clear_bit(slotid, tbl->used_slots);
>=20
> @@ -381,10 +379,10 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, u8 =
free_slotid)
> 		if (slotid < tbl->max_slots)
> 			tbl->highest_used_slotid =3D slotid;
> 		else
> -			tbl->highest_used_slotid =3D -1;
> +			tbl->highest_used_slotid =3D NFS4_NO_SLOT;
> 	}
> -	dprintk("%s: free_slotid %u highest_used_slotid %d\n", __func__,
> -		free_slotid, tbl->highest_used_slotid);
> +	dprintk("%s: slotid %u highest_used_slotid %d\n", __func__,
> +		slotid, tbl->highest_used_slotid);

%d -> %u, also %d -> %u in dprintk before return in nfs4_find_slot().

> }
>=20
> bool nfs4_set_task_privileged(struct rpc_task *task, void *dummy)
> @@ -512,7 +510,7 @@ static int nfs4_sequence_done(struct rpc_task =
*task,
>  * nfs4_find_slot looks for an unset bit in the used_slots bitmap.
>  * If found, we mark the slot as used, update the highest_used_slotid,
>  * and respectively set up the sequence operation args.
> - * The slot number is returned if found, or NFS4_MAX_SLOT_TABLE =
otherwise.
> + * The slot number is returned if found, or NFS4_NO_SLOT otherwise.
>  *
>  * Note: must be called with under the slot_tbl_lock.
>  */
> @@ -529,7 +527,8 @@ nfs4_find_slot(struct nfs4_slot_table *tbl)
> 	if (slotid >=3D tbl->max_slots)
> 		goto out;
> 	__set_bit(slotid, tbl->used_slots);
> -	if (slotid > tbl->highest_used_slotid)
> +	if (slotid > tbl->highest_used_slotid ||
> +			tbl->highest_used_slotid =3D=3D NFS4_NO_SLOT)
> 		tbl->highest_used_slotid =3D slotid;
> 	ret_id =3D slotid;
> out:
> @@ -584,7 +583,7 @@ int nfs41_setup_sequence(struct nfs4_session =
*session,
> 	}
>=20
> 	slotid =3D nfs4_find_slot(tbl);
> -	if (slotid =3D=3D NFS4_MAX_SLOT_TABLE) {
> +	if (slotid =3D=3D NFS4_NO_SLOT) {
> 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
> 		spin_unlock(&tbl->slot_tbl_lock);
> 		dprintk("<-- %s: no free slots\n", __func__);
> --=20
> 1.7.7.6
>=20
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20


--Apple-Mail=_E544EAB1-6D25-4262-99BC-DDFAB70E7FD7
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTUwMDU5MzRaMCMGCSqGSIb3DQEJBDEWBBQoq2zHNDjWcNAh
Hd5KgyNGI7PwxTANBgkqhkiG9w0BAQEFAASCAQADSHysr6wmCeVMS9caTWUskaf57hz28QjA27B2
am61l55Rv6U6k1G/ynMy9Nmaajay0gZoMSYff+iM69t+J11QXo56+oScb3VNimn4K5lDvACfWBZC
r/7Ti8ZsV7SI4yX/S4nlwMddE0C6ErRQ2XsULyuK/Tg+gK6+Sn0JQq7Z0Cvl5dOdBLAp0LoxOMVr
eHmu+RUVB2ATIt6qgand/54MQ9z/sgPGzUG+jbTvbLiLuNj0C05WQis/mloFV1VU9CbGRhfNE66v
RAwwgECoZEsmL8+qH56PSubPSD00iC7Fp2jgZC7tYekEwgClfzJXEewIb21tQ2y5MsekOCSnJxWS
AAAAAAAA

--Apple-Mail=_E544EAB1-6D25-4262-99BC-DDFAB70E7FD7--
