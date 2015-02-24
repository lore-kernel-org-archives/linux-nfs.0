Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39800 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752450AbbBXVx0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Feb 2015 16:53:26 -0500
Date: Wed, 25 Feb 2015 08:53:18 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Nix <nix@esperi.org.uk>
Subject: Re: [PATCH 3/3] NFS: Don't require a filehandle to refresh the
 inode in nfs_prime_dcache()
Message-ID: <20150225085318.2a714592@notabene.brown>
In-Reply-To: <1424736897-95767-3-git-send-email-trond.myklebust@primarydata.com>
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
	<1424736897-95767-2-git-send-email-trond.myklebust@primarydata.com>
	<1424736897-95767-3-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/MZp0ZSgIMCkIk_q/GqTBOLd"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MZp0ZSgIMCkIk_q/GqTBOLd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 23 Feb 2015 19:14:57 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> If the server does not return a valid set of attributes that we can
> use to either create a file or refresh the inode, then there is no
> value in calling nfs_prime_dcache().
>=20
> However if we're just refreshing the inode using the attributes that
> the server returned, then it shouldn't matter whether or not we have
> a filehandle, as long as we check the fsid+fileid combination.
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/dir.c | 18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 0da617a61c0b..c19e16f0b2d0 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -408,14 +408,22 @@ static int xdr_decode(nfs_readdir_descriptor_t *des=
c,
>  	return 0;
>  }
> =20
> +/* Match file and dirent using either filehandle or fileid
> + * Note: caller is responsible for checking the fsid
> + */
>  static
>  int nfs_same_file(struct dentry *dentry, struct nfs_entry *entry)
>  {
> +	struct nfs_inode *nfsi;
> +
>  	if (dentry->d_inode =3D=3D NULL)
>  		goto different;
> -	if (nfs_compare_fh(entry->fh, NFS_FH(dentry->d_inode)) !=3D 0)
> -		goto different;
> -	return 1;
> +
> +	nfsi =3D NFS_I(dentry->d_inode);
> +	if (entry->fattr->fileid =3D=3D nfsi->fileid)
> +		return 1;
> +	if (nfs_compare_fh(entry->fh, &nfsi->fh) =3D=3D 0)
> +		return 1;
>  different:
>  	return 0;
>  }
> @@ -469,6 +477,10 @@ void nfs_prime_dcache(struct dentry *parent, struct =
nfs_entry *entry)
>  	struct inode *inode;
>  	int status;
> =20
> +	if (!(entry->fattr->valid & NFS_ATTR_FATTR_FILEID))
> +		return;
> +	if (!(entry->fattr->valid & NFS_ATTR_FATTR_FSID))
> +		return;
>  	if (filename.name[0] =3D=3D '.') {
>  		if (filename.len =3D=3D 1)
>  			return;


I believe this will fix the observed problem.  This is partly because the
Linux NFSv3 server either returns both a filehandle and attributes, or
neither.

If a server happened to return postop attributes, but no filehandle, then t=
he
"nfs_compare_fh()" would be a meaningless test.

I think you should abort nfs_prime_dcache if entry->fh->size is zero for
exactly the same reason that you abort if NFS_ATTR_FATTR_FSID is not set.

NeilBrown

--Sig_/MZp0ZSgIMCkIk_q/GqTBOLd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOzyzjnsnt1WYoG5AQIILQ//TnjKksA1K2FjxeiJS/4XW+EUtfewGSyt
FlvG3wGKoUdvZx31VNCbxdtk3o1SXY3jbYHyZsuN1xI58p2mRnIySyZTPgtS752b
0+sw+aFtEk1EiZrLrnDYHLIpf8nZHfdBexrmnMfK6ERg2bT+pN7w9rQ/GvAE54Y5
NqWgV9ooaY2/ozTSRBLRWT6/hrgKhPTLhWS+ttArVszDwgDB+fDn1BXliwrQIlU4
Ze+Bc7GUoIkRso6bP+sIVBwTsHVtgO0iwl7vh3XfBBw0y5HEWCSAcc3Wnn8OMnpJ
beEZ7/AqYxKDP8Ues5aMJnQGch3opOUjjyYn4K9zEZ8sycuj0WddkE0U92sr1cmT
Neb7+ofssVC9104AK5r3oq7ZC6U80HKtwJA2hb7NqQhF7HAU8tXckI50ySl0zDx+
qNUieQSPOBvc2zeaEVWGGngjNNjmAys2xf8dqaqoWoKjI3ntv1ZZJuPYVzjGMT95
UKCG1a7QmhMprWY76SVOtT4v2WDIwd4BVfjMoHdpE3o5+XHBnI1QLfk2L9y8fLSK
Doos0TQkkDB3HCBkHzAHda1PdW52HhYno/DEfmUWfU3aoRXk9NrY6UKvP+o/mBfM
8yIJNbjk6rZr++7wocZC2RX7Fgeo5l2Tk0sGsqz/MQyJsNKQkU/jxGywqSIgpowd
Une6eyGR0QA=
=HKBy
-----END PGP SIGNATURE-----

--Sig_/MZp0ZSgIMCkIk_q/GqTBOLd--
