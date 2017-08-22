Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34244 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754408AbdHVA2x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Aug 2017 20:28:53 -0400
Received: by mail-it0-f65.google.com with SMTP id s132so10794500ita.1
        for <linux-nfs@vger.kernel.org>; Mon, 21 Aug 2017 17:28:52 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] NFSv4: Fix up mirror allocation
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <20170820143226.5711-1-trond.myklebust@primarydata.com>
Date: Mon, 21 Aug 2017 20:28:51 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        JianhongYin <yin-jianhong@163.com>
Message-Id: <6B563A9B-1EC7-4272-BA84-13814C519F9A@monkey.org>
References: <20170820143226.5711-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me.

Reviewed-by: Weston Andros Adamson <dros@primarydata.com>

-dros

> On Aug 20, 2017, at 10:32 AM, Trond Myklebust =
<trond.myklebust@primarydata.com> wrote:
>=20
> There are a number of callers of nfs_pageio_complete() that want to
> continue using the nfs_pageio_descriptor without needing to call
> nfs_pageio_init() again. Examples include nfs_pageio_resend() and
> nfs_pageio_cond_complete().
>=20
> The problem is that nfs_pageio_complete() also calls
> nfs_pageio_cleanup_mirroring(), which frees up the array of mirrors.
> This can lead to writeback errors, in the next call to
> nfs_pageio_setup_mirroring().
>=20
> Fix by simply moving the allocation of the mirrors to
> nfs_pageio_setup_mirroring().
>=20
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=3D196709
> Reported-by: JianhongYin <yin-jianhong@163.com>
> Cc: stable@vger.kernel.org # 4.0+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/pagelist.c | 73 =
+++++++++++++++++++++++++++++--------------------------
> 1 file changed, 39 insertions(+), 34 deletions(-)
>=20
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 548ebc7256ff..1c7e625824dc 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -685,9 +685,6 @@ void nfs_pageio_init(struct nfs_pageio_descriptor =
*desc,
> 		     int io_flags,
> 		     gfp_t gfp_flags)
> {
> -	struct nfs_pgio_mirror *new;
> -	int i;
> -
> 	desc->pg_moreio =3D 0;
> 	desc->pg_inode =3D inode;
> 	desc->pg_ops =3D pg_ops;
> @@ -703,21 +700,9 @@ void nfs_pageio_init(struct nfs_pageio_descriptor =
*desc,
> 	desc->pg_mirror_count =3D 1;
> 	desc->pg_mirror_idx =3D 0;
>=20
> -	if (pg_ops->pg_get_mirror_count) {
> -		/* until we have a request, we don't have an lseg and no
> -		 * idea how many mirrors there will be */
> -		new =3D kcalloc(NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX,
> -			      sizeof(struct nfs_pgio_mirror), =
gfp_flags);
> -		desc->pg_mirrors_dynamic =3D new;
> -		desc->pg_mirrors =3D new;
> -
> -		for (i =3D 0; i < NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX; i++)
> -			nfs_pageio_mirror_init(&desc->pg_mirrors[i], =
bsize);
> -	} else {
> -		desc->pg_mirrors_dynamic =3D NULL;
> -		desc->pg_mirrors =3D desc->pg_mirrors_static;
> -		nfs_pageio_mirror_init(&desc->pg_mirrors[0], bsize);
> -	}
> +	desc->pg_mirrors_dynamic =3D NULL;
> +	desc->pg_mirrors =3D desc->pg_mirrors_static;
> +	nfs_pageio_mirror_init(&desc->pg_mirrors[0], bsize);
> }
> EXPORT_SYMBOL_GPL(nfs_pageio_init);
>=20
> @@ -836,32 +821,52 @@ static int nfs_generic_pg_pgios(struct =
nfs_pageio_descriptor *desc)
> 	return ret;
> }
>=20
> +static struct nfs_pgio_mirror *
> +nfs_pageio_alloc_mirrors(struct nfs_pageio_descriptor *desc,
> +		unsigned int mirror_count)
> +{
> +	struct nfs_pgio_mirror *ret;
> +	unsigned int i;
> +
> +	kfree(desc->pg_mirrors_dynamic);
> +	desc->pg_mirrors_dynamic =3D NULL;
> +	if (mirror_count =3D=3D 1)
> +		return desc->pg_mirrors_static;
> +	ret =3D kmalloc_array(mirror_count, sizeof(*ret), GFP_NOFS);
> +	if (ret !=3D NULL) {
> +		for (i =3D 0; i < mirror_count; i++)
> +			nfs_pageio_mirror_init(&ret[i], desc->pg_bsize);
> +		desc->pg_mirrors_dynamic =3D ret;
> +	}
> +	return ret;
> +}
> +
> /*
>  * nfs_pageio_setup_mirroring - determine if mirroring is to be used
>  *				by calling the pg_get_mirror_count op
>  */
> -static int nfs_pageio_setup_mirroring(struct nfs_pageio_descriptor =
*pgio,
> +static void nfs_pageio_setup_mirroring(struct nfs_pageio_descriptor =
*pgio,
> 				       struct nfs_page *req)
> {
> -	int mirror_count =3D 1;
> +	unsigned int mirror_count =3D 1;
>=20
> -	if (!pgio->pg_ops->pg_get_mirror_count)
> -		return 0;
> -
> -	mirror_count =3D pgio->pg_ops->pg_get_mirror_count(pgio, req);
> -
> -	if (pgio->pg_error < 0)
> -		return pgio->pg_error;
> -
> -	if (!mirror_count || mirror_count > =
NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX)
> -		return -EINVAL;
> +	if (pgio->pg_ops->pg_get_mirror_count)
> +		mirror_count =3D pgio->pg_ops->pg_get_mirror_count(pgio, =
req);
> +	if (mirror_count =3D=3D pgio->pg_mirror_count || pgio->pg_error =
< 0)
> +		return;
>=20
> -	if (WARN_ON_ONCE(!pgio->pg_mirrors_dynamic))
> -		return -EINVAL;
> +	if (!mirror_count || mirror_count > =
NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX) {
> +		pgio->pg_error =3D -EINVAL;
> +		return;
> +	}
>=20
> +	pgio->pg_mirrors =3D nfs_pageio_alloc_mirrors(pgio, =
mirror_count);
> +	if (pgio->pg_mirrors =3D=3D NULL) {
> +		pgio->pg_error =3D -ENOMEM;
> +		pgio->pg_mirrors =3D pgio->pg_mirrors_static;
> +		mirror_count =3D 1;
> +	}
> 	pgio->pg_mirror_count =3D mirror_count;
> -
> -	return 0;
> }
>=20
> /*
> --=20
> 2.13.5
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

