Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52166 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725723AbeJDEzh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 00:55:37 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Date: Thu, 04 Oct 2018 08:05:14 +1000
Subject: Re: [PATCH 2/7] pNFS: Don't allocate more pages than we need to fit a layoutget response
In-Reply-To: <20180905192400.107485-3-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com> <20180905192400.107485-2-trond.myklebust@hammerspace.com> <20180905192400.107485-3-trond.myklebust@hammerspace.com>
Message-ID: <87in2iu1np.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 05 2018, Trond Myklebust wrote:

> For the 'files' and 'flexfiles' layout types, we do not expect the reply
> to be any larger than 4k. The block and scsi layout types are a little mo=
re
> greedy, so we keep allocating the maximum response size for now.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/filelayout/filelayout.c         | 1 +
>  fs/nfs/flexfilelayout/flexfilelayout.c | 1 +
>  fs/nfs/pnfs.c                          | 7 +++++++
>  fs/nfs/pnfs.h                          | 1 +
>  4 files changed, 10 insertions(+)
>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayou=
t.c
> index d175724ff566..61f46facb39c 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -1164,6 +1164,7 @@ static struct pnfs_layoutdriver_type filelayout_typ=
e =3D {
>  	.id			=3D LAYOUT_NFSV4_1_FILES,
>  	.name			=3D "LAYOUT_NFSV4_1_FILES",
>  	.owner			=3D THIS_MODULE,
> +	.max_layoutget_response	=3D 4096, /* 1 page or so... */

If it is really "1 page", then surely it should be PAGE_SIZE.
But some builds have PAGE_SIZE > 4096.  So if it is really "probably noy
larger than 4K", then surely the comment should say that.

Confused.

Thanks,
NeilBrown


>  	.alloc_layout_hdr	=3D filelayout_alloc_layout_hdr,
>  	.free_layout_hdr	=3D filelayout_free_layout_hdr,
>  	.alloc_lseg		=3D filelayout_alloc_lseg,
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayo=
ut/flexfilelayout.c
> index cae43333ef16..86bcba40ca61 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -2356,6 +2356,7 @@ static struct pnfs_layoutdriver_type flexfilelayout=
_type =3D {
>  	.name			=3D "LAYOUT_FLEX_FILES",
>  	.owner			=3D THIS_MODULE,
>  	.flags			=3D PNFS_LAYOUTGET_ON_OPEN,
> +	.max_layoutget_response	=3D 4096, /* 1 page or so... */
>  	.set_layoutdriver	=3D ff_layout_set_layoutdriver,
>  	.alloc_layout_hdr	=3D ff_layout_alloc_layout_hdr,
>  	.free_layout_hdr	=3D ff_layout_free_layout_hdr,
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6b5b2d36f502..c5672c02afd6 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -991,6 +991,7 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
>  	   gfp_t gfp_flags)
>  {
>  	struct nfs_server *server =3D pnfs_find_server(ino, ctx);
> +	size_t max_reply_sz =3D server->pnfs_curr_ld->max_layoutget_response;
>  	size_t max_pages =3D max_response_pages(server);
>  	struct nfs4_layoutget *lgp;
>=20=20
> @@ -1000,6 +1001,12 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
>  	if (lgp =3D=3D NULL)
>  		return NULL;
>=20=20
> +	if (max_reply_sz) {
> +		size_t npages =3D (max_reply_sz + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +		if (npages < max_pages)
> +			max_pages =3D npages;
> +	}
> +
>  	lgp->args.layout.pages =3D nfs4_alloc_pages(max_pages, gfp_flags);
>  	if (!lgp->args.layout.pages) {
>  		kfree(lgp);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index ece367ebde69..e2e9fcd5341d 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -125,6 +125,7 @@ struct pnfs_layoutdriver_type {
>  	struct module *owner;
>  	unsigned flags;
>  	unsigned max_deviceinfo_size;
> +	unsigned max_layoutget_response;
>=20=20
>  	int (*set_layoutdriver) (struct nfs_server *, const struct nfs_fh *);
>  	int (*clear_layoutdriver) (struct nfs_server *);
> --=20
> 2.17.1

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlu1PRsACgkQOeye3VZi
gbk3MA//ZHbU7JhvWOrr2Hg0Jn6rO+jiRMfDmFDeDMCZzhByIL0YDfHsmUvkAx6G
59mrOnrFjzDoZ5bYmKeBjneWFZKrdLg9OHMgtODBeNkfxsNToCf6VizFwr/ZDGrO
7IwFOCEBiEkEZZCZRZHTEv9oEiMKfQ7ikTJmLz7UUmnp9E8d+2NbNwjEB7lyOcOp
1U8L5+YPj52koLCG970EFw9go1p3QJ8AxOApzjkLwDx8GgOnBj3xL3b3PuSYj1K1
J0i914B5/x3eAxkgR9lv2Pl1XOFB6NK74C2YpB34mJbO9sFV1f84M05vCFhTeLUF
g40JyUClYrvEJXFyyuqOn1+KuPx1f8LMFiIUJVNt5jzCoJ+NiNeMe/9Y3mkYD/ZE
T988YApdZZBpYpDt6TrIJjMAgN7Z4Lj8D53TiWhNtf6+BuifJ+HQKQSA8l4oIXqr
gnU2StI4a1C5sIlrHQF5yRO5+y89OWYKOSsLNOdUr5sHMbn7PzVZhy+yO82nhCDB
xIcWFY+7W1CBBMHbuhbA3l4UpfQET1auRkt8vddB7ZL0D7AJxghvWpBwrejzqoLN
KKY0wrO+jkfdN51c9CZlNzeT2oRhGoSRs8ihUVMIJSNzAA8xvDyjMubzhG0s0j9F
vsK5KRHWybWurFEQzj52gQVRSiowwQAqMzxzZO6PBSTgMs7XMiI=
=XQYv
-----END PGP SIGNATURE-----
--=-=-=--
