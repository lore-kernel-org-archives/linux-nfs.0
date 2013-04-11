Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53524 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935376Ab3DKBVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 21:21:30 -0400
Date: Thu, 11 Apr 2013 11:21:21 +1000
From: NeilBrown <neilb@suse.de>
To: malahal naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv3/v2: Fix data corruption with NFS short reads.
Message-ID: <20130411112121.74d996c5@notabene.brown>
In-Reply-To: <1364587026-7504-1-git-send-email-malahal@us.ibm.com>
References: <1364587026-7504-1-git-send-email-malahal@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/WRshQDiT_n=Edf4O460f0tY"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/WRshQDiT_n=Edf4O460f0tY
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 29 Mar 2013 19:57:06 -0000 malahal naineni <malahal@us.ibm.com> wro=
te:

> This bug seems to be present in v2.6.37 or lower versions. The code was
> re-organized in v2.6.38 that eliminated the bug. Current upstream code
> doesn't have this bug. This may be applicable to some longterm releases!
>=20
> Here are the bug details:
>=20
> 1. nfs_read_rpcsetup(), args.count and res.count are both set to the
>    actual number of bytes to be read. Let us assume that the request is
>    for 16K, so arg.count =3D res.count =3D 16K
> 2. nfs3_xdr_readres() conditionally sets res.count to to the actual
>    number of bytes read. This condition is true for the first response
>    as res.count was set to args.count before the first request. Let us
>    say the server returned only 4K bytes. res.count=3D4K
> 3. Another read request is sent for the remaining data. Note that
>    res.count is NOT updated. It is still set to the actual amount of
>    bytes we got in the first response.  The client will send a READ
>    request for the remaining 12K.

This is looks like a real bug, but I think the "NOT" above is the best thing
to fix.
i.e. when another read request is set, res.count *SHOULD*BE* updated.  That
makes it consistent with the original send, and consistency is good!

So this patch.

Index: linux-2.6.32-SLE11-SP1-LTSS/fs/nfs/read.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.32-SLE11-SP1-LTSS.orig/fs/nfs/read.c	2013-03-20 16:24:31.4266=
05189 +1100
+++ linux-2.6.32-SLE11-SP1-LTSS/fs/nfs/read.c	2013-04-11 11:19:57.670724540=
 +1000
@@ -368,6 +368,7 @@ static void nfs_readpage_retry(struct rp
 	argp->offset +=3D resp->count;
 	argp->pgbase +=3D resp->count;
 	argp->count -=3D resp->count;
+	resp->count =3D argp->count;
 	nfs4_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
 	return;
 out:


This would old affect clients with servers which would sometimes return
partial reads, and I don't think the Linux NFS server does.  What server ha=
ve
you seen this against?

NeilBrown



> 4. Assume that the server gave all 12K bytes. We still think we got ony
>    4K bytes due to conditional update in nfs3_xdr_readres(). The client
>    sends further requests, if not EOF! If this response includes EOF, it
>    truncates pages beyond 4K+4K causing data corruption beyond 8K. The
>    corrupted data is filled with zeros!
>=20
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
>=20
> ---
> fs/nfs/nfs2xdr.c | 3 +--
>  fs/nfs/nfs3xdr.c | 3 +--
>  2 files changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
> index 5914a19..710ca56 100644
> --- a/fs/nfs/nfs2xdr.c
> +++ b/fs/nfs/nfs2xdr.c
> @@ -287,8 +287,7 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, stru=
ct nfs_readres *res)
>  	}
> =20
>  	dprintk("RPC:      readres OK count %u\n", count);
> -	if (count < res->count)
> -		res->count =3D count;
> +	res->count =3D count;
> =20
>  	return count;
>  }
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index f6cc60f..152a5e4 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -914,8 +914,7 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, str=
uct nfs_readres *res)
>  		res->eof =3D 0;
>  	}
> =20
> -	if (count < res->count)
> -		res->count =3D count;
> +	res->count =3D count;
> =20
>  	return count;
>  }


--Sig_/WRshQDiT_n=Edf4O460f0tY
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUWYQETnsnt1WYoG5AQJn4A//Tu8gzU5w/Lk0mKBLoFxHyBiEtTvwWVPw
xGIJ5j8x791EFXXRztxtnITujRbY/DcJJBG0viq2uHizBsiXYkYEO8j9qDq1sor8
Sav4y+dfna3XDEtDeia4447+4f1Zcuodf1PwMEBo3fjjAiAqLPlblNWUmAM/F9At
403jMcsPtD5RepIikdYkXIj+PLpDQrMgJWnWpaG5bsdibOp0fYw7bN4aFTASDEpL
3I0Rf+Amsdi4oNomfpwy3ZSQf+cxGaq21w1wGb889kxl8UinPVFr2z5i+4PibqLq
sRWiA6aKDRxMqs5UYby46GZ1FCsxcch2GLIBuI+zsOgw4ZQfZNyMYhWt9eyZ9LSL
K7I2kt15s5w6N5aI6YDSGVGXFBDO4l4FvMQoCSJdXzZZMYdbR14MLx6KBYDYFqCh
diopeWJ6Qc05CGVEkIMrq8hgpazLKwwaJjdBxYmH6oKOAcy/m9OtIwK0Qml9QUba
1JGs3GgxdD69LGGbtGrd6o5miEU99GbgDzfEuwT+tYOe3BO5nETOsy/qBTok9fCo
bzGsgW64IQBZ53+8RGBl80hiYjikBmG2soZEAvCyhIJLFWY9e4k6OsjRIEs7nuCF
4hARkV3dEcZl3HKKDjQVH/p/6E6mE7VT/XO91WxitoNvey6Ur8Ps+KVD0w9Ac5oN
V7WoRCe+0Qo=
=7wVG
-----END PGP SIGNATURE-----

--Sig_/WRshQDiT_n=Edf4O460f0tY--
