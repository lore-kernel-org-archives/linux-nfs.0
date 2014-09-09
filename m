Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34893 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbaIISHp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 14:07:45 -0400
Date: Tue, 9 Sep 2014 11:07:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFS: Implement SEEK
Message-ID: <20140909180745.GA31137@infradead.org>
References: <1409679060-32313-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1409679060-32313-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409679060-32313-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This seems to depend on the server patch adding the constants to
include/linux/nfs4.h, right?

> diff --git a/fs/nfs/nfs42xdr.h b/fs/nfs/nfs42xdr.h
> new file mode 100644
> index 0000000..a30cb3a
> --- /dev/null
> +++ b/fs/nfs/nfs42xdr.h
> @@ -0,0 +1,98 @@
> +/*
> + * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp>

Netapp.com?

> +	__be32 *p;
> +
> +	status = decode_op_hdr(xdr, OP_SEEK);
> +	if (status)
> +		return status;
> +
> +	p = xdr_inline_decode(xdr, 12);

4 + 8, again?

> +#ifdef CONFIG_NFS_V4_2
> +static int nfs42_select_stateid(struct file *file, nfs4_stateid *stateid, fmode_t mode)
> +{
> +	struct nfs_open_context *open;
> +	struct nfs_lock_context *lock;
> +	int ret;
> +
> +	open = nfs_file_open_context(file);
> +	if (!open)
> +		return -EBADF;
> +
> +	lock = nfs_get_lock_context(open);
> +	if (IS_ERR(lock))
> +		return PTR_ERR(lock);
> +
> +	ret = nfs4_set_rw_stateid(stateid, open, lock, mode);
> +
> +	if (lock)
> +		nfs_put_lock_context(lock);
> +	return ret;
> +}

I have to admit I don't really understand the purpose of this code,
can you add some comments to explain it?

> +static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
> +{
> +	struct nfs_server *server = NFS_SERVER(file_inode(filep));
> +	loff_t ret;
> +
> +	switch (whence) {
> +	case SEEK_HOLE:
> +	case SEEK_DATA:
> +		if (server->caps & NFS_CAP_SEEK) {
> +			ret = nfs42_file_llseek(filep, offset, whence);
> +			if (ret != -ENOTSUPP)
> +				return ret;
> +			server->caps &= ~NFS_CAP_SEEK;
> +		}
> +	default:
> +		return nfs_file_llseek(filep, offset, whence);
> +	}
> +}
> +#endif /* CONFIG_NFS_V4_2 */
> +
>  const struct file_operations nfs4_file_operations = {
> +#ifdef CONFIG_NFS_V4_2
> +	.llseek		= nfs4_file_llseek,
> +#else

I suspect it would be a bit nicer to just add the code to a
nfs4_file_llseek that looks like:

static loff_t
nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
{
	struct nfs_server *server = NFS_SERVER(file_inode(filep));
	loff_t ret;

	switch (whence) {
#ifdef CONFIG_NFS_V4_2
	case SEEK_HOLE:
	case SEEK_DATA:
		if (NFS_SERVER(file_inode(filep)->caps & NFS_CAP_SEEK) {
			ret = nfs42_file_llseek(filep, offset, whence);
			if (ret != -ENOTSUPP)
				return ret;
			NFS_SERVER(file_inode(filep)->caps &= ~NFS_CAP_SEEK;
		}
#endif
	default:
		return nfs_file_llseek(filep, offset, whence);
	}
}

> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index e13b59d..6b94428 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -7427,6 +7427,10 @@ nfs4_stat_to_errno(int stat)
>  	return -stat;
>  }
>  
> +#if defined(CONFIG_NFS_V4_2)
> +#include "nfs42xdr.h"
> +#endif /* CONFIG_NFS_V4_2 */

How much code would need to be exported if this was a separate .c file?

Also I think in general #ifdef should be preferred to #if defined()

> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index aed5b88..9fd2b78 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1018,7 +1018,7 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		struct nfsd4_seek *seek)
>  {
>  	struct file *file;
> -	__be32 status = nfs_ok;
> +	__be32 status;
>  
>  	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>  					    &seek->seek_stateid,

This should have been part of the server patch I think.
