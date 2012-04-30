Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:52947 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151Ab2D3QJt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 12:09:49 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Apr 2012 12:09:47 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id DBE0838C8071
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 12:09:44 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3UG9hZv098054
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 12:09:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3ULeZjW013583
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 17:40:35 -0400
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q3ULeZmd013564
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 17:40:35 -0400
Date: Mon, 30 Apr 2012 11:09:42 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fixed goto readability in nfs_update_inode.
Message-ID: <20120430160942.GA536@us.ibm.com>
References: <1335799977-5587-1-git-send-email-treinish@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335799977-5587-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Matthew Treinish [treinish@linux.vnet.ibm.com] wrote:
> Simplified error gotos to make it slightly easier to read,
> it doesn't affect the functionality of the routine.
> 
> Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
> ---
>  fs/nfs/inode.c |   34 +++++++++++++++++-----------------
>  1 files changed, 17 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e8bbfa5..943d1d0 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1279,14 +1279,26 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  			nfs_display_fhandle_hash(NFS_FH(inode)),
>  			atomic_read(&inode->i_count), fattr->valid);
> 
> -	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
> -		goto out_fileid;
> +	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid) {
> +		printk(KERN_ERR "NFS: server %s error: fileid changed\n"
> +			"fsid %s: expected fileid 0x%Lx, got 0x%Lx\n",
> +			NFS_SERVER(inode)->nfs_client->cl_hostname,
> +			inode->i_sb->s_id, (long long)nfsi->fileid,
> +			(long long)fattr->fileid);
> +		goto out_err;
> +	}
> 
>  	/*
>  	 * Make sure the inode's type hasn't changed.
>  	 */
> -	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
> -		goto out_changed;
> +	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT)) {
> +		/*
> +		* Big trouble! The inode has become a different object.
> +		*/
> +		printk(KERN_DEBUG "NFS: %s: inode %ld mode changed, %07o to %07o\n",
> +				__func__, inode->i_ino, inode->i_mode, fattr->mode);
> +		goto out_err;
> +	}
> 
>  	server = NFS_SERVER(inode);
>  	/* Update the fsid? */
> @@ -1466,12 +1479,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  		nfsi->cache_validity |= invalid;
> 
>  	return 0;
> - out_changed:
> -	/*
> -	 * Big trouble! The inode has become a different object.
> -	 */
> -	printk(KERN_DEBUG "NFS: %s: inode %ld mode changed, %07o to %07o\n",
> -			__func__, inode->i_ino, inode->i_mode, fattr->mode);
>   out_err:
>  	/*
>  	 * No need to worry about unhashing the dentry, as the
> @@ -1480,13 +1487,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  	 */
>  	nfs_invalidate_inode(inode);
>  	return -ESTALE;
> -
> - out_fileid:
> -	printk(KERN_ERR "NFS: server %s error: fileid changed\n"
> -		"fsid %s: expected fileid 0x%Lx, got 0x%Lx\n",
> -		NFS_SERVER(inode)->nfs_client->cl_hostname, inode->i_sb->s_id,
> -		(long long)nfsi->fileid, (long long)fattr->fileid);
> -	goto out_err;
>  }

Reviewed-by: Malahal Naineni <malahal@us.ibm.com>

