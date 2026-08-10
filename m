Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD0D2318EF6
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 17:23:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786382632; cv=none; b=HVcqve9xaAZyCb2Rdd0C73Mf6jS9XMg25TgRYE7Cr2qw4na+ApdgyfU6rwuq1bYlY1v0UoK+5KeP6tsW6G6A1GhU94t29TfzEOUcvL+G3ViUZmnwO+MJXEakOmjAODeGa+45nJBEy1Mf2Y0W9fHnmoMtiz1X2FFe8RSxsuhrakA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786382632; c=relaxed/simple;
	bh=hHL7ubEqyNEsp8OA8CIg4qzaupxhzaeVc0gBySAOuzU=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=mXkgSiyqsmmo1x89sPQnTDFtyCkh8aRt7jgz+30yO5BRBr7LayhFxI4eLySrZz0INwgqEsN4uiYueiVQV0TOQ3gbEDnMmVcW8OUTEqZNWEyF0hNhn8eAH1rl4zHh9fAQF2qjPJpgz43yP9ta3u5O9D7gnzJc3pshdQtzmyC4M3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dChReD1N; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dChReD1N"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C19F91F000E9;
	Mon, 10 Aug 2026 17:23:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786382630;
	bh=SdpgsnOQ1/3BvmQw0tUJ4VdMlOEaZ/C+A6WRLsoMa6E=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=dChReD1N/esPm9dLttZ6ratjSBFtm+XZeY6mbUfAmKsbcDWEDLRSh0z81Q+ag01uL
	 O1Z5hqxCi7CaoZeit4tahMvYhfGZ/wPnC9Wh6yfuYaZX0pOki0yXXrXhxxpP+9Ma22
	 V6NZnKK7WAIeFP9+TfU9wuXQ5Dy9kA4HsU0qwGnoZEe/bAUodffy012T/4CnL7iVX2
	 zNGLKgoBX/q7OUZqV3YS8kJ/7N4stUcxIhDSjExHCoQpbjmq1ZUetkLoL/2zct742d
	 5Ba5NXG6JNbpF8SvQbUpvnG+zDhlVnkNdh7IOltd7DutNUiiuVPb44CwvEOlOLmWIs
	 G9DsuSJY4jW8Q==
Message-ID: <00e0823c793e0783244237e9d3b1bddab74788ab.camel@kernel.org>
Subject: Re: [PATCH v1 2/2] NFSD: Move version-specific ACCESS maps into
 per-version code
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 10 Aug 2026 13:23:49 -0400
In-Reply-To: <20260810141900.33846-2-cel@kernel.org>
References: <20260810141900.33846-1-cel@kernel.org>
	 <20260810141900.33846-2-cel@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-08-10 at 10:19 -0400, Chuck Lever wrote:
> nfsd_access() owns three static tables that map on-the-wire ACCESS
> bits to NFSD_MAY flags, and every NFS version shares them. That puts
> protocol-version specifics in the version-agnostic VFS layer. The
> NFSv4.2 extended-attribute bits are wedged into the NFSv3 tables
> under CONFIG_NFSD_V4.
>=20
> Give each version its own tables in its proc code and pass the
> matching set into nfsd_access() as a new argument.
>=20
> Splitting the tables also stops the NFSv2-ACL and NFSv3 ACCESS paths
> from answering for the NFSv4.2 extended-attribute bits. Both use the
> NFSv4-augmented table whenever CONFIG_NFSD_V4 is set, so an NFSv3
> request that sets an xattr bit has it echoed back in the reply even
> though those bits are undefined for v3.
>=20
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/nfs2acl.c  | 46 ++++++++++++++++++++++++++-
>  fs/nfsd/nfs3proc.c | 41 +++++++++++++++++++++++-
>  fs/nfsd/nfs4proc.c | 42 +++++++++++++++++++++++--
>  fs/nfsd/vfs.c      | 78 ++++++++++------------------------------------
>  fs/nfsd/vfs.h      | 15 ++++++++-
>  5 files changed, 155 insertions(+), 67 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> index aba69dd278a1..33610deda3b0 100644
> --- a/fs/nfsd/nfs2acl.c
> +++ b/fs/nfsd/nfs2acl.c
> @@ -16,6 +16,48 @@
> =20
>  #define NFSDDBG_FACILITY		NFSDDBG_PROC
> =20
> +/*
> + * These maps are identical to the NFSv3 maps (nfs3proc.c). This enables
> + * the behavior of the two versions to diverge if needed.
> + */
> +static const struct nfsd_access_map nfsd2_regaccess[] =3D {
> +	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
> +	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
> +	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
> +	{ 0,			0					}
> +};
> +
> +static const struct nfsd_access_map nfsd2_diraccess[] =3D {
> +	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
> +	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
> +	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
> +	{ NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
> +	{ 0,			0					}
> +};
> +
> +/*
> + * Some clients - Solaris 2.6 at least, make an access call to the NFS
> + * server to check for access for things like /dev/null (which really,
> + * NFSD doesn't care about).  So NFSD provides simple access checking
> + * for those objects, looking mainly at mode bits, ignoring read-only
> + * filesystem checks.
> + */
> +static const struct nfsd_access_map nfsd2_otheraccess[] =3D {
> +	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
> +	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> +	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> +	{ 0,			0					}
> +};
> +
> +static const struct nfsd_access_maps nfsd2_access_maps =3D {
> +	.regular	=3D nfsd2_regaccess,
> +	.directory	=3D nfsd2_diraccess,
> +	.other		=3D nfsd2_otheraccess,
> +};
> +
>  /*
>   * NULL call.
>   */
> @@ -181,7 +223,9 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rq=
stp)
> =20
>  	fh_copy(&resp->fh, &argp->fh);
>  	resp->access =3D argp->access;
> -	resp->status =3D nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
> +
> +	resp->status =3D nfsd_access(rqstp, &resp->fh, &nfsd2_access_maps,
> +				   &resp->access, NULL);
>  	if (resp->status !=3D nfs_ok)
>  		goto out;
>  	resp->status =3D fh_getattr(&resp->fh, &resp->stat);
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 19ab0a713d82..17bbe5d13f18 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -49,6 +49,44 @@ static bool nfsd3_time_in_range(const struct iattr *ia=
p)
>  	return true;
>  }
> =20
> +static const struct nfsd_access_map nfsd3_regaccess[] =3D {
> +	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
> +	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
> +	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
> +	{ 0,			0					}
> +};
> +
> +static const struct nfsd_access_map nfsd3_diraccess[] =3D {
> +	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
> +	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
> +	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
> +	{ NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
> +	{ 0,			0					}
> +};
> +
> +/*
> + * Some clients - Solaris 2.6 at least, make an access call to the NFS
> + * server to check for access for things like /dev/null (which really,
> + * NFSD doesn't care about).  So NFSD provides simple access checking
> + * for those objects, looking mainly at mode bits, ignoring read-only
> + * filesystem checks.
> + */
> +static const struct nfsd_access_map nfsd3_otheraccess[] =3D {
> +	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
> +	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> +	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> +	{ 0,			0					}
> +};
> +
> +static const struct nfsd_access_maps nfsd3_access_maps =3D {
> +	.regular	=3D nfsd3_regaccess,
> +	.directory	=3D nfsd3_diraccess,
> +	.other		=3D nfsd3_otheraccess,
> +};
> +
>  static int nfsd3_iocb_flags(enum nfs3_stable_how how)
>  {
>  	switch (how) {
> @@ -186,7 +224,8 @@ nfsd3_proc_access(struct svc_rqst *rqstp)
> =20
>  	fh_copy(&resp->fh, &argp->fh);
>  	resp->access =3D argp->access;
> -	resp->status =3D nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
> +	resp->status =3D nfsd_access(rqstp, &resp->fh, &nfsd3_access_maps,
> +				   &resp->access, NULL);
>  	resp->status =3D nfsd3_map_status(resp->status);
>  	return rpc_success;
>  }
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a2bea8947ef5..54593f4667f8 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -72,6 +72,43 @@ MODULE_PARM_DESC(nfsd4_ssc_umount_timeout,
> =20
>  #define NFSDDBG_FACILITY		NFSDDBG_PROC
> =20
> +static const struct nfsd_access_map nfsd4_regaccess[] =3D {
> +	{ NFS4_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS4_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
> +	{ NFS4_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
> +	{ NFS4_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
> +	{ NFS4_ACCESS_XAREAD,	NFSD_MAY_READ				},
> +	{ NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE				},
> +	{ NFS4_ACCESS_XALIST,	NFSD_MAY_READ				},
> +	{ 0,			0					}
> +};
> +
> +static const struct nfsd_access_map nfsd4_diraccess[] =3D {
> +	{ NFS4_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS4_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
> +	{ NFS4_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
> +	{ NFS4_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
> +	{ NFS4_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
> +	{ NFS4_ACCESS_XAREAD,	NFSD_MAY_READ				},
> +	{ NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE				},
> +	{ NFS4_ACCESS_XALIST,	NFSD_MAY_READ				},
> +	{ 0,			0					}
> +};
> +
> +static const struct nfsd_access_map nfsd4_otheraccess[] =3D {
> +	{ NFS4_ACCESS_READ,	NFSD_MAY_READ				},
> +	{ NFS4_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
> +	{ NFS4_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> +	{ NFS4_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> +	{ 0,			0					}
> +};
> +
> +static const struct nfsd_access_maps nfsd4_access_maps =3D {
> +	.regular	=3D nfsd4_regaccess,
> +	.directory	=3D nfsd4_diraccess,
> +	.other		=3D nfsd4_otheraccess,
> +};
> +
>  static int nfsd4_iocb_flags(enum stable_how4 how)
>  {
>  	switch (how) {
> @@ -851,10 +888,9 @@ nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_co=
mpound_state *cstate,
> =20
>  	if (access->ac_req_access & ~access_full)
>  		return nfserr_inval;
> -
>  	access->ac_resp_access =3D access->ac_req_access;
> -	return nfsd_access(rqstp, &cstate->current_fh, &access->ac_resp_access,
> -			   &access->ac_supported);
> +	return nfsd_access(rqstp, &cstate->current_fh, &nfsd4_access_maps,
> +			   &access->ac_resp_access, &access->ac_supported);
>  }
> =20
>  static __be32
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 807e09521e0c..6d865f4f9ba3 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -782,64 +782,21 @@ __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, =
struct svc_fh *fhp,
>  }
>  #endif /* defined(CONFIG_NFSD_V4) */
> =20
> -/*
> - * Check server access rights to a file system object
> +/**
> + * nfsd_access - Check caller's access rights to a file system object
> + * @rqstp: RPC transaction context
> + * @fhp: target NFS filehandle
> + * @maps: tables mapping on-the-wire access bits to NFSD_MAY flags
> + * @access: requested access bits on entry, permitted bits on return
> + * @supported: optional output of the access bits the server supports
> + *
> + * Return: nfs_ok on success, otherwise an nfserr status code
>   */
> -struct accessmap {
> -	u32		access;
> -	int		how;
> -};
> -static struct accessmap	nfs3_regaccess[] =3D {
> -    {	NFS3_ACCESS_READ,	NFSD_MAY_READ			},
> -    {	NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC			},
> -    {	NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC	},
> -    {	NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE			},
> -
> -#ifdef CONFIG_NFSD_V4
> -    {	NFS4_ACCESS_XAREAD,	NFSD_MAY_READ			},
> -    {	NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE			},
> -    {	NFS4_ACCESS_XALIST,	NFSD_MAY_READ			},
> -#endif
> -
> -    {	0,			0				}
> -};
> -
> -static struct accessmap	nfs3_diraccess[] =3D {
> -    {	NFS3_ACCESS_READ,	NFSD_MAY_READ			},
> -    {	NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC			},
> -    {	NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC},
> -    {	NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE	},
> -    {	NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE			},
> -
> -#ifdef CONFIG_NFSD_V4
> -    {	NFS4_ACCESS_XAREAD,	NFSD_MAY_READ			},
> -    {	NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE			},
> -    {	NFS4_ACCESS_XALIST,	NFSD_MAY_READ			},
> -#endif
> -
> -    {	0,			0				}
> -};
> -
> -static struct accessmap	nfs3_anyaccess[] =3D {
> -	/* Some clients - Solaris 2.6 at least, make an access call
> -	 * to the server to check for access for things like /dev/null
> -	 * (which really, the server doesn't care about).  So
> -	 * We provide simple access checking for them, looking
> -	 * mainly at mode bits, and we make sure to ignore read-only
> -	 * filesystem checks
> -	 */
> -    {	NFS3_ACCESS_READ,	NFSD_MAY_READ			},
> -    {	NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC			},
> -    {	NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> -    {	NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
> -
> -    {	0,			0				}
> -};
> -
> -__be32
> -nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32=
 *supported)
> +__be32 nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		   const struct nfsd_access_maps *maps,
> +		   u32 *access, u32 *supported)
>  {
> -	struct accessmap	*map;
> +	const struct nfsd_access_map *map;
>  	struct svc_export	*export;
>  	struct dentry		*dentry;
>  	u32			query, result =3D 0, sresult =3D 0;
> @@ -853,12 +810,11 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *=
fhp, u32 *access, u32 *suppor
>  	dentry =3D fhp->fh_dentry;
> =20
>  	if (d_is_reg(dentry))
> -		map =3D nfs3_regaccess;
> +		map =3D maps->regular;
>  	else if (d_is_dir(dentry))
> -		map =3D nfs3_diraccess;
> +		map =3D maps->directory;
>  	else
> -		map =3D nfs3_anyaccess;
> -
> +		map =3D maps->other;
> =20
>  	query =3D *access;
>  	for  (; map->access; map++) {
> @@ -868,7 +824,7 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fh=
p, u32 *access, u32 *suppor
>  			sresult |=3D map->access;
> =20
>  			err2 =3D nfsd_permission(&rqstp->rq_cred, export,
> -					       dentry, map->how);
> +					       dentry, map->may);
>  			switch (err2) {
>  			case nfs_ok:
>  				result |=3D map->access;
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index aa7679d4c54a..3aa4522ca0a4 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -37,6 +37,17 @@
>  #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
>  #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
> =20
> +struct nfsd_access_map {
> +	u32		access;
> +	int		may;
> +};
> +
> +struct nfsd_access_maps {
> +	const struct nfsd_access_map	*regular;
> +	const struct nfsd_access_map	*directory;
> +	const struct nfsd_access_map	*other;
> +};
> +
>  struct nfsd_file;
> =20
>  /*
> @@ -100,7 +111,9 @@ __be32		nfsd_create_locked(struct svc_rqst *, struct =
svc_fh *,
>  __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
>  				char *name, int len, struct nfsd_attrs *attrs,
>  				int type, dev_t rdev, struct svc_fh *res);
> -__be32		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
> +__be32		nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +				const struct nfsd_access_maps *maps,
> +				u32 *access, u32 *supported);
>  __be32		nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  				struct svc_fh *resfhp, struct nfsd_attrs *iap);
>  __be32		nfsd_commit(struct svc_rqst *rqst, struct svc_fh *fhp,

Reviewed-by: Jeff Layton <jlayton@kernel.org>
