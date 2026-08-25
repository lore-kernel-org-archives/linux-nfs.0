Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D56C733C198
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 16:11:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787674265; cv=none; b=m33V5743Rx8jzVfTv4aBcL8X6NUdEDODHYc8edKYCrRuBtT/PSFJPa8DX45s9ObZdBoieeUIPJivVvsFqbB+/72huJW7uInQVBEFxouAXEJahZfd3XHzu9NCSjqBSqPvRHOMb8EhOP66sjKetfUm5lG6fBNJ+amgmC4yQG7+nZQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787674265; c=relaxed/simple;
	bh=w7ozBf1BnHqqlkImxCcB1RpWGTC17gqOMJEgA5BYN4c=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=V+467Wvg3pIBAPzrlR5sYw6R14p7wbSmiKCiTW95/dHegodEnlxAEkOb+NlSnpIuFkAooY9zwQAwjtFnRNr2c/M6C2gvH1AmeaS//wx4P+1jXzTxWYdltg7vpO+qVCB940haNTVfbu9VqtedMWecm6X9HSI3nkOZzZPIlpz+gW4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JnqPK2T0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JnqPK2T0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 15CF91F000E9;
	Tue, 25 Aug 2026 16:11:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787674263;
	bh=VpCg2lyXk8oMHJFPx8OE8+e/x+BiYq+tPazSbf/pkS4=;
	h=Subject:From:To:Date:In-Reply-To:References;
	b=JnqPK2T0dXO7YKYSl1pK0vIEoLiSjxCQvXm2PF6hwBbo4Zj6wOajPMuXYh3D7orZX
	 NgNBlR9h2r+3hFA2+wp8Fwr5DgsUH+yevDn0lX+GKveLFEMCVCdMFqYxI6dVqDDeJl
	 BpEbJe+JBQoajQmh1wBz4CG1ZFd3V1t4ZeacVu5DqLEOslLo44P+xP/9hiMacv/qO9
	 0YJR9g0hzaePT3iv786vF8JLCUA7FFd5dBDqI2puUPcu9fmZdKix3o7hEFivqfagpp
	 BHTdLSQXwWtaZPLCzZ5ZyiLzo7cKpuc1tYw/ITA/riIq13Tfofm4XpRTF0Pwxmn1kS
	 0IZ8vFen24bqg==
Message-ID: <c0704acb89cdf5593970c6d7a7f000c6ef9f24c6.camel@kernel.org>
Subject: Re: [PATCH v2 2/4] NFS: Add support for CB_NOTIFY4_REMOVE_ENTRY
From: Jeff Layton <jlayton@kernel.org>
To: Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
	trond.myklebust@hammerspace.com
Date: Tue, 25 Aug 2026 12:11:01 -0400
In-Reply-To: <20260825150209.694646-3-anna@kernel.org>
References: <20260825150209.694646-1-anna@kernel.org>
	 <20260825150209.694646-3-anna@kernel.org>
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

On Tue, 2026-08-25 at 11:02 -0400, Anna Schumaker wrote:
> From: Anna Schumaker <anna.schumaker@oracle.com>
>=20
> When the server tells us that a directory entry has been removed then we
> need to take that as an indication that our knowledge of the directory
> has changed and needs to be refreshed.
>=20
> Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
> Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
> ---
> v2:
>   * Initialize 'res' to 0 in nfs4_callback_notify()
>   * Add missing error handling
>   * Remove nfs4_cb_notify_lookup()
> ---
>  fs/nfs/callback.h      | 16 ++++++++++-
>  fs/nfs/callback_proc.c | 63 +++++++++++++++++++++++++++++++++++++++++-
>  fs/nfs/callback_xdr.c  | 62 +++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4xdr.c       |  3 +-
>  include/linux/nfs4.h   |  1 +
>  5 files changed, 142 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index f7cc5b6931bf..3740c999bb82 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -143,8 +143,22 @@ struct cb_layoutrecallargs {
>  extern __be32 nfs4_callback_layoutrecall(void *argp, void *resp,
>  		struct cb_process_state *cps);
> =20
> +struct cb_notify_entry {
> +	u32			ne_namelen;
> +	const char		*ne_name;
> +	struct nfs_fattr	ne_attrs;
> +};
> +
> +struct cb_notify_remove {
> +	struct cb_notify_entry	nrm_old_entry;
> +	u64			nrm_old_entry_cookie;
> +};
> +
>  struct cb_notify_changes {
> -	u32 notify_mask;
> +	u32	notify_mask;
> +	union {
> +		struct cb_notify_remove notify_remove;
> +	};
>  };
> =20
>  struct cb_notifyargs {
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 01600d75f2d9..d8ad3cd792df 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -9,6 +9,7 @@
> =20
>  #include <linux/errno.h>
>  #include <linux/math.h>
> +#include <linux/namei.h>
>  #include <linux/nfs4.h>
>  #include <linux/nfs_fs.h>
>  #include <linux/slab.h>
> @@ -369,13 +370,73 @@ static void pnfs_recall_all_layouts(struct nfs_clie=
nt *clp,
>  	do_callback_layoutrecall(clp, &args, cps);
>  }
> =20
> +static __be32 nfs4_cb_notify_remove(struct cb_process_state *cps,
> +				    struct dentry *parent,
> +				    struct cb_notify_remove *cb_remove)
> +{
> +	struct qstr filename =3D QSTR_INIT(cb_remove->nrm_old_entry.ne_name,
> +					 cb_remove->nrm_old_entry.ne_namelen);
> +	struct dentry *child;
> +
> +	filename.hash =3D full_name_hash(parent, filename.name, filename.len);
> +	child =3D d_lookup(parent, &filename);
> +	if (IS_ERR_OR_NULL(child))
> +		return htonl(NFS4ERR_BADHANDLE);
> +
> +	d_drop(child);

Should this instead make this a negative dentry?

I think this will just drop the existing dentry and it'll trigger a
lookup next time we end up trying to hit it.

> +	dput(child);
> +
> +	nfs_set_cache_invalid(parent->d_inode, NFS_INO_INVALID_DATA);
> +	return 0;
> +}
> +
>  __be32 nfs4_callback_notify(void *argp, void *resp,
>  			    struct cb_process_state *cps)
>  {
>  	struct cb_notifyargs *args =3D argp;
> +	struct dentry *parent;
> +	struct inode *inode;
> +	unsigned int i;
> +	__be32 res =3D 0;
> =20
> +	if (!cps->clp) {
> +		res =3D htonl(NFS4ERR_OP_NOT_IN_SESSION);
> +		goto out;
> +	}
> +
> +	inode =3D nfs_delegation_find_inode(cps->clp, &args->cna_fh);
> +	if (IS_ERR(inode)) {
> +		res =3D htonl(NFS4ERR_BADHANDLE);
> +		goto out;
> +	}
> +	parent =3D d_find_alias(inode);
> +	if (!parent)
> +		goto out_iput;
> +
> +	for (i =3D 0; i < args->cna_n_changes; i++) {
> +		struct cb_notify_changes *change =3D &args->cna_changes[i];
> +
> +		switch (change->notify_mask) {
> +		case CB_NOTIFY4_REMOVE_ENTRY:
> +			res =3D nfs4_cb_notify_remove(cps, parent,
> +						    &change->notify_remove);
> +			break;
> +		default:
> +			res =3D htonl(NFS4ERR_NOTSUPP);
> +			goto out_dput;
> +		}
> +
> +		if (unlikely(res !=3D 0))
> +			break;
> +	}
> +
> +out_dput:
> +	dput(parent);
> +out_iput:
> +	nfs_iput_and_deactive(inode);
> +out:
>  	kfree(args->cna_changes);
> -	return 0;
> +	return res;
>  }
> =20
>  __be32 nfs4_callback_devicenotify(void *argp, void *resp,
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 8d822a3ee248..612d215ac66e 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -252,6 +252,50 @@ static __be32 decode_layoutrecall_args(struct svc_rq=
st *rqstp,
>  	return 0;
>  }
> =20
> +static __be32 decode_notify_entry(struct xdr_stream *xdr,
> +				  struct cb_notify_entry *args)
> +{
> +	uint32_t bitmap[3] =3D {0};
> +	__be32 status;
> +	u32 attrlen;
> +	__be32 *p;
> +
> +	status =3D decode_string(xdr, &args->ne_namelen, &args->ne_name,
> +				NFS4_OPAQUE_LIMIT);
> +	if (unlikely(status !=3D 0))
> +		return status;
> +
> +	status =3D decode_bitmap(xdr, bitmap);
> +	if (unlikely(status !=3D 0))
> +		return status;
> +
> +	p =3D xdr_inline_decode(xdr, 4);
> +	if (unlikely(!p))
> +		return htonl(NFS4ERR_BADXDR);
> +
> +	attrlen =3D be32_to_cpup(p);
> +	if (attrlen !=3D 0)
> +		return htonl(NFS4ERR_BADXDR);
> +	return 0;
> +}
> +
> +static __be32 decode_notify_remove(struct xdr_stream *xdr,
> +				   struct cb_notify_remove *args)
> +{
> +	__be32 status;
> +	__be32 *p;
> +
> +	status =3D decode_notify_entry(xdr, &args->nrm_old_entry);
> +	if (unlikely(status !=3D 0))
> +		return status;
> +
> +	p =3D xdr_inline_decode(xdr, 8);
> +	if (unlikely(!p))
> +		return htonl(NFS4ERR_BADXDR);
> +	xdr_decode_hyper(p, &args->nrm_old_entry_cookie);
> +	return 0;
> +}
> +
>  static
>  __be32 decode_notify_args(struct svc_rqst *rqstp,
>  			  struct xdr_stream *xdr,
> @@ -289,6 +333,24 @@ __be32 decode_notify_args(struct svc_rqst *rqstp,
>  						     &change->notify_mask, 1);
>  		if (unlikely(res < 0))
>  			goto err;
> +
> +		/* Decode opaque size */
> +		p =3D xdr_inline_decode(xdr, 4);
> +		if (unlikely(!p))
> +			goto err;
> +		res =3D ntohl(*p);
> +
> +		switch (change->notify_mask) {
> +		case CB_NOTIFY4_REMOVE_ENTRY:
> +			status =3D decode_notify_remove(xdr,
> +						      &change->notify_remove);
> +			break;
> +		default:
> +			goto err;
> +		}
> +
> +		if (unlikely(status !=3D 0))
> +			goto err;
>  	}
> =20
>  	return 0;
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 5c51691fff03..e275fbfd395e 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2012,7 +2012,8 @@ static void
>  encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *h=
dr)
>  {
>  	struct timespec64 ts =3D { 0, 0 };
> -	u32 notifications[1] =3D { CB_NOTIFY4_GFLAG_EXTEND };
> +	u32 notifications[1] =3D { CB_NOTIFY4_REMOVE_ENTRY |
> +				 CB_NOTIFY4_GFLAG_EXTEND };
>  	u32 attributes[1] =3D { 0 };
>  	__be32 *p;
> =20
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 2e33f2ffdc31..8de3ea283767 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -492,6 +492,7 @@ enum {
>  #define THRESHOLD_WR_IO                 (1UL << 3)
> =20
>  /* Directory Delegation / CB_NOTIFY bits */
> +#define CB_NOTIFY4_REMOVE_ENTRY		(1UL << 2)
>  #define CB_NOTIFY4_GFLAG_EXTEND		(1UL << 6)
> =20
>  #define NFSPROC4_NULL 0

--=20
Jeff Layton <jlayton@kernel.org>
