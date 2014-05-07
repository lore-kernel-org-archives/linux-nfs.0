Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52361 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933731AbaEGQBT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 12:01:19 -0400
Date: Wed, 7 May 2014 12:01:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: clean up fh_auth usage
Message-ID: <20140507160118.GD4240@fieldses.org>
References: <1399463384-4324-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399463384-4324-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 07, 2014 at 01:49:44PM +0200, Christoph Hellwig wrote:
> Use fh_fsid when reffering to the fsid part of the filehandle.  The
> variable length auth field envisioned in nfsfh wasn't ever implemented.
> Also clean up some lose ends around this and document the file handle
> format better.

Thanks.

> Btw, why do we even export nfsfh.h to userspace?  The file handle very
> much is kernel private, and nothing in nfs-utils include the header
> either.

Something like wireshark might use that information?  But anyway that
doesn't mean it makes much sense to export.  I'm fine with moving that
header.

--b.

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfsfh.c                 |   20 +++++++++-----------
>  include/uapi/linux/nfsd/nfsfh.h |   32 +++++++-------------------------
>  2 files changed, 16 insertions(+), 36 deletions(-)
> 
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index 3c37b16..a337106 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -169,8 +169,8 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
>  		data_left -= len;
>  		if (data_left < 0)
>  			return error;
> -		exp = rqst_exp_find(rqstp, fh->fh_fsid_type, fh->fh_auth);
> -		fid = (struct fid *)(fh->fh_auth + len);
> +		exp = rqst_exp_find(rqstp, fh->fh_fsid_type, fh->fh_fsid);
> +		fid = (struct fid *)(fh->fh_fsid + len);
>  	} else {
>  		__u32 tfh[2];
>  		dev_t xdev;
> @@ -385,7 +385,7 @@ static void _fh_update(struct svc_fh *fhp, struct svc_export *exp,
>  {
>  	if (dentry != exp->ex_path.dentry) {
>  		struct fid *fid = (struct fid *)
> -			(fhp->fh_handle.fh_auth + fhp->fh_handle.fh_size/4 - 1);
> +			(fhp->fh_handle.fh_fsid + fhp->fh_handle.fh_size/4 - 1);
>  		int maxsize = (fhp->fh_maxsize - fhp->fh_handle.fh_size)/4;
>  		int subtreecheck = !(exp->ex_flags & NFSEXP_NOSUBTREECHECK);
>  
> @@ -513,7 +513,6 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
>  	 */
>  
>  	struct inode * inode = dentry->d_inode;
> -	__u32 *datap;
>  	dev_t ex_dev = exp_sb(exp)->s_dev;
>  
>  	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %pd2, ino=%ld)\n",
> @@ -557,17 +556,16 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
>  		if (inode)
>  			_fh_update_old(dentry, exp, &fhp->fh_handle);
>  	} else {
> -		int len;
> +		fhp->fh_handle.fh_size =
> +			key_len(fhp->fh_handle.fh_fsid_type) + 4;
>  		fhp->fh_handle.fh_auth_type = 0;
> -		datap = fhp->fh_handle.fh_auth+0;
> -		mk_fsid(fhp->fh_handle.fh_fsid_type, datap, ex_dev,
> +
> +		mk_fsid(fhp->fh_handle.fh_fsid_type,
> +			fhp->fh_handle.fh_fsid,
> +			ex_dev,
>  			exp->ex_path.dentry->d_inode->i_ino,
>  			exp->ex_fsid, exp->ex_uuid);
>  
> -		len = key_len(fhp->fh_handle.fh_fsid_type);
> -		datap += len/4;
> -		fhp->fh_handle.fh_size = 4 + len;
> -
>  		if (inode)
>  			_fh_update(fhp, exp, dentry);
>  		if (fhp->fh_handle.fh_fileid_type == FILEID_INVALID) {
> diff --git a/include/uapi/linux/nfsd/nfsfh.h b/include/uapi/linux/nfsd/nfsfh.h
> index 616e3b3..2039123 100644
> --- a/include/uapi/linux/nfsd/nfsfh.h
> +++ b/include/uapi/linux/nfsd/nfsfh.h
> @@ -1,13 +1,7 @@
>  /*
> - * include/linux/nfsd/nfsfh.h
> - *
>   * This file describes the layout of the file handles as passed
>   * over the wire.
>   *
> - * Earlier versions of knfsd used to sign file handles using keyed MD5
> - * or SHA. I've removed this code, because it doesn't give you more
> - * security than blocking external access to port 2049 on your firewall.
> - *
>   * Copyright (C) 1995, 1996, 1997 Olaf Kirch <okir@monad.swb.de>
>   */
>  
> @@ -37,7 +31,7 @@ struct nfs_fhbase_old {
>  };
>  
>  /*
> - * This is the new flexible, extensible style NFSv2/v3 file handle.
> + * This is the new flexible, extensible style NFSv2/v3/v4 file handle.
>   * by Neil Brown <neilb@cse.unsw.edu.au> - March 2000
>   *
>   * The file handle starts with a sequence of four-byte words.
> @@ -47,14 +41,7 @@ struct nfs_fhbase_old {
>   *
>   * All four-byte values are in host-byte-order.
>   *
> - * The auth_type field specifies how the filehandle can be authenticated
> - * This might allow a file to be confirmed to be in a writable part of a
> - * filetree without checking the path from it up to the root.
> - * Current values:
> - *     0  - No authentication.  fb_auth is 0 bytes long
> - * Possible future values:
> - *     1  - 4 bytes taken from MD5 hash of the remainer of the file handle
> - *          prefixed by a secret and with the important export flags.
> + * The auth_type field is deprecated and must be set to 0.
>   *
>   * The fsid_type identifies how the filesystem (or export point) is
>   *    encoded.
> @@ -71,14 +58,9 @@ struct nfs_fhbase_old {
>   *     7  - 8 byte inode number and 16 byte uuid
>   *
>   * The fileid_type identified how the file within the filesystem is encoded.
> - * This is (will be) passed to, and set by, the underlying filesystem if it supports
> - * filehandle operations.  The filesystem must not use the value '0' or '0xff' and may
> - * only use the values 1 and 2 as defined below:
> - *  Current values:
> - *    0   - The root, or export point, of the filesystem.  fb_fileid is 0 bytes.
> - *    1   - 32bit inode number, 32 bit generation number.
> - *    2   - 32bit inode number, 32 bit generation number, 32 bit parent directory inode number.
> - *
> + *   The values for this field are filesystem specific, exccept that
> + *   filesystems must not use the values '0' or '0xff'. 'See enum fid_type'
> + *   in include/linux/exportfs.h for currently registered values.
>   */
>  struct nfs_fhbase_new {
>  	__u8		fb_version;	/* == 1, even => nfs_fhbase_old */
> @@ -114,9 +96,9 @@ struct knfsd_fh {
>  #define	fh_fsid_type		fh_base.fh_new.fb_fsid_type
>  #define	fh_auth_type		fh_base.fh_new.fb_auth_type
>  #define	fh_fileid_type		fh_base.fh_new.fb_fileid_type
> -#define	fh_auth			fh_base.fh_new.fb_auth
>  #define	fh_fsid			fh_base.fh_new.fb_auth
>  
> -
> +/* Do not use, provided for userspace compatiblity. */
> +#define	fh_auth			fh_base.fh_new.fb_auth
>  
>  #endif /* _UAPI_LINUX_NFSD_FH_H */
> -- 
> 1.7.10.4
> 
