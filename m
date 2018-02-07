Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33470 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753443AbeBGGmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 01:42:54 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Date: Wed, 07 Feb 2018 17:42:47 +1100
Subject: Re: [PATCH 1/2] NFS: Remove a redundant call to unmap_mapping_range()
In-Reply-To: <20180129025822.5116-1-trond.myklebust@primarydata.com>
References: <20180129025822.5116-1-trond.myklebust@primarydata.com>
Message-ID: <876079nvvc.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 28 2018, Trond Myklebust wrote:

> We don't need to call unmap_mapping_range() prior to calling
> nfs_sync_mapping().

Don't we?
Doesn't that allow a process which mapped the page to dirty it
immediately after nfs_sync_mapping(), without the page being
reloaded from the server first?
Doesn't seem right..

Thanks,
NeilBrown


>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/inode.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index deeb7d1097d0..49fba9ea5872 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1170,7 +1170,6 @@ static int nfs_invalidate_mapping(struct inode *ino=
de, struct address_space *map
>=20=20
>  	if (mapping->nrpages !=3D 0) {
>  		if (S_ISREG(inode->i_mode)) {
> -			unmap_mapping_range(mapping, 0, 0, 0);
>  			ret =3D nfs_sync_mapping(mapping);
>  			if (ret < 0)
>  				return ret;
> --=20
> 2.14.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp6n+cACgkQOeye3VZi
gbke/g//ZCOuOAzjrpAfwmgAWgdbXcq85k/uc4jxbkWs2hM/iUcefuroX4aNIgjB
54DKG/Si7hlVd5kHV/b4VTYnpcVdF/RHhTzU/RDOwp2WSlTfZHYtlLuw46/mY5iF
at07js8Oxh+gXZGpaIV586petE3xzSqTr4sPCCRNrGL/Hn+qeFygrn9E60e1LDwW
Sr8pStHDiuB5kZWhvi1Q1jHac1/mBXfeFNy0bSEcKRz4ops6l9gOzF6gVFSCGHC9
v2D2N+/02hwTJ1T0yGRUEWlPeElGFUXW0NgykXO1E/44KCP3AOMiO13DuSvfjhhl
885x+a7nxzOBC6nJ0Rhhu5oG3NVlSEcfFyojknLUMBsuyGehYmVrN4zzLMQsLIC1
bDBLu1HrTl1HjldBkASyi1lxOEq5qNbs08OfeAhoWyhwAH+HFHSE7utV04b4H3sl
GDLHvJkym0mdjJp56P8j/rpjD59QnxCtn8oOdnLpQv5pFhIdujyu9wGPkU5cHbou
IWmF98+z1MfPgLRfXMSPO0qzs8BU3CKUMW2jDfiu0FXXx81xgCJtlFKl29TAFEzJ
l8v8hBFgYHx8e5qBJyHVVG2qhOfk2WVLh7u7LhJTXx/LxUN2GHlouWHPEN2Fxy+N
1fYt8PbzpH0sRedCBE406sa7BFDiiWsTwjFlHkAStMvC1+Rgxrc=
=KjmG
-----END PGP SIGNATURE-----
--=-=-=--
