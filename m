Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 051092DF134
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 12:31:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784205089; cv=none; b=tUgx+Yj6SFByD0czUtsK2EE4MVqoYn80Ye/U5ldQGlQGA2S2NJvW7H/g0FgP+/yI+fXMurwTXvq8W8Ty+NIIzhxB410B6ZVm+FlpI00XgG63BL5TpJHPYPQdeeji9FbqCL7moGlyz2BSKP96vMyAwxlHj90/EmrbnHUB+4eUm5Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784205089; c=relaxed/simple;
	bh=QxdZAmTBOjSJS/PUnCabDKIMKqKGdcktRnuc20va640=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=cqMRVBBNxvZaRfuqXoxn8ClUWDQTf29OvImFkXynEwAXiMkc+9eIF+4ZTmbcomsTqGrEGq2NO9fi4JO0EMQLqHdarUV0wg1PkZb8o0okWpsVloXQPahCvMcBBpgpaR79nMmKLfsvGCU73OVl6ujltiYHKu+Sw0quwuTnXzgVX2E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Qe+ZSTQF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Qe+ZSTQF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0933D1F000E9;
	Thu, 16 Jul 2026 12:31:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784205087;
	bh=EOXQim70MScRN9b6eiZj2aZby/4CNdIP5enWI+ZE2vk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Qe+ZSTQFn60p/4YoeXb3YZt8s9Va+Hnb8O3T+JSfV7ez68f8t/q1oG3zmlsEA0hwY
	 5cxo59B6nNL4QJ8W860LIetyvJO1uthw8Ply/5jydW+K6Ldu4FJ3BHR9iy9Cpl5uc6
	 KBXyioxn7MPcFV+7zIvCxMIL3d5aydEAJpxeQ9/mIxkJCiBx9IDIXSxPK4OrZEeDXR
	 nLDINkzktskdguTGDZmvishAwFLNQOsKKXtO6cxnB4LtROSzNiGoNzdCQ1ZjRyLnr9
	 npZc/Tf/yWHFubZ2b0/Xa+SiOB+9G33xPlkneWaFz5TRtxA4zcomN4zfY6GrlXCDaP
	 Osq6hFiwYmbEA==
Message-ID: <22d3e319c9c739a6a79fa4e62b5a75817390e4a6.camel@kernel.org>
Subject: Re: [PATCH v3 15/17] nfsd: move v0 checking out of
 nfsd_check_obj_isreg()
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neil@brown.name>, Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org
Date: Thu, 16 Jul 2026 08:31:25 -0400
In-Reply-To: <20260713062219.6399-16-neilb@ownmail.net>
References: <20260713062219.6399-1-neilb@ownmail.net>
	 <20260713062219.6399-16-neilb@ownmail.net>
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

On Mon, 2026-07-13 at 16:15 +1000, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>=20
> A future patch will use nfsd_check_obj_isreg() in a context where the
> protocol version is not easily available.  So move the version check out
> and put it at the end of do_open_lookup().
>=20
> Also change to return errno error code and use nfserrno() to convert to
> nfs error codes.  Use -ELOOP for nfserr_symlink, which is an error
> indication a problem with symlinks.  -EFTYPE is a good match for
> nfserr_wrong_type.
>=20
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/nfsd/nfs4proc.c | 29 ++++++++++++-----------------
>  fs/nfsd/vfs.c      |  4 +++-
>  2 files changed, 15 insertions(+), 18 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 0d1bcb12ecbc..ffeda7214d66 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -168,23 +168,17 @@ do_open_permission(struct svc_rqst *rqstp, struct s=
vc_fh *current_fh, struct nfs
>  	return fh_verify(rqstp, current_fh, S_IFREG, accmode);
>  }
> =20
> -static __be32 nfsd_check_obj_isreg(struct dentry *child, u32 minor_versi=
on)
> +static __be32 nfsd_check_obj_isreg(struct dentry *child)
>  {
>  	umode_t mode =3D d_inode(child)->i_mode;
> =20
>  	if (S_ISREG(mode))
> -		return nfs_ok;
> +		return 0;
>  	if (S_ISDIR(mode))
> -		return nfserr_isdir;
> +		return -EISDIR;
>  	if (S_ISLNK(mode))
> -		return nfserr_symlink;
> -
> -	/* RFC 7530 - 16.16.6 */
> -	if (minor_version =3D=3D 0)
> -		return nfserr_symlink;
> -	else
> -		return nfserr_wrong_type;
> -
> +		return -ELOOP;
> +	return -EFTYPE;
>  }
> =20
>  static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state=
 *cstate, struct nfsd4_open *open, struct svc_fh *resfh)
> @@ -212,8 +206,6 @@ static __be32
>  nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		  struct svc_fh *resfhp, struct nfsd4_open *open)
>  {
> -	struct nfsd4_compoundres *resp =3D rqstp->rq_resp;
> -	struct nfsd4_compound_state *cstate =3D &resp->cstate;
>  	struct iattr *iap =3D &open->op_iattr;
>  	struct nfsd_attrs attrs =3D {
>  		.na_iattr	=3D iap,
> @@ -356,8 +348,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_=
fh *fhp,
>  		 * op_filp and consequently a valid ->f_path.dentry.
>  		 */
> =20
> -		status =3D nfsd_check_obj_isreg(child, cstate->minorversion);
> -		if (status =3D=3D nfs_ok) {
> +		status =3D nfserrno(nfsd_check_obj_isreg(child));
> +		if (!status) {
>  			open->op_filp =3D dentry_open(&path, oflags,
>  						    current_cred());
>  			if (IS_ERR(open->op_filp)) {
> @@ -536,8 +528,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_c=
ompound_state *cstate, stru
>  	}
>  	if (status)
>  		goto out;
> -	status =3D nfsd_check_obj_isreg((*resfh)->fh_dentry,
> -				      cstate->minorversion);
> +	status =3D nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
>  	if (status)
>  		goto out;
> =20
> @@ -549,6 +540,10 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_=
compound_state *cstate, stru
>  	status =3D do_open_permission(rqstp, *resfh, open, accmode);
>  	set_change_info(&open->op_cinfo, current_fh);
>  out:
> +	if (status =3D=3D nfserr_wrong_type && cstate->minorversion =3D=3D 0)
> +		/* RFC 7530 - 16.16.6 */
> +		return nfserr_symlink;
> +
>  	return status;
>  }
> =20
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 9e05c3949cc1..c0e8c87a5e00 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -61,7 +61,7 @@ u64 nfsd_io_cache_write __read_mostly =3D NFSD_IO_BUFFE=
RED;
>   * it's an error we don't expect, log it once and return nfserr_io.
>   */
>  __be32
> -nfserrno (int errno)
> +nfserrno(int errno)
>  {
>  	static struct {
>  		__be32	nfserr;
> @@ -105,6 +105,8 @@ nfserrno (int errno)
>  		{ nfserr_perm, -ENOKEY },
>  		{ nfserr_no_grace, -ENOGRACE},
>  		{ nfserr_io, -EBADMSG },
> +		{ nfserr_symlink, -ELOOP },
> +		{ nfserr_wrong_type, -EFTYPE },
>  	};
>  	int	i;
> =20

Reviewed-by: Jeff Layton <jlayton@kernel.org>
