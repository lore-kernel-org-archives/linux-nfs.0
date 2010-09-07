Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42747 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244Ab0IGUel convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 16:34:41 -0400
Subject: Re: [PATCH 5/6] NFS: remove readdir plus limit
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C869AA7.2030000@netapp.com>
Date: Tue, 7 Sep 2010 16:33:22 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <14C46455-5738-4FBA-872D-0442B8DAB3C5@oracle.com>
References: <4C869AA7.2030000@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bryan-

On Sep 7, 2010, at 4:03 PM, Bryan Schumaker wrote:

> NFS remove readdir plus limit
> 
> We will now use readdir plus even on directories that are very large.

READDIRPLUS operations on some servers may be quite expensive, since the server usually treats directories as byte streams, and can be read sequentially; but inode attributes are read by random disk seeks.  So assembling a READDIRPLUS result on a large directory that isn't in the server's cache might be an awful lot of work on a busy server.

On large directories, there isn't much proven benefit to having all the dcache entries on hand on the client.  It can even hurt performance by pushing more useful entries out of the cache.

If we really want to take the directory size cap off, that seems like it could be a far-reaching change.  You should at least use the patch description to provide thorough rationale.  Even some benchmark results, with especially slow servers and networks, and small clients, would be nice.

> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 7d2d6c7..b2e12bc 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -234,9 +234,6 @@ nfs_init_locked(struct inode *inode, void *opaque)
> 	return 0;
> }
> 
> -/* Don't use READDIRPLUS on directories that we believe are too large */
> -#define NFS_LIMIT_READDIRPLUS (8*PAGE_SIZE)
> -
> /*
>  * This is our front-end to iget that looks up inodes by file handle
>  * instead of inode number.
> @@ -291,8 +288,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
> 		} else if (S_ISDIR(inode->i_mode)) {
> 			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
> 			inode->i_fop = &nfs_dir_operations;
> -			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
> -			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
> +			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
> 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
> 			/* Deal with crossing mountpoints */
> 			if ((fattr->valid & NFS_ATTR_FATTR_FSID)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com




