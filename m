Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20745 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759995AbbIDTii convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 15:38:38 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 1/2] NFS: Optimise away the close-to-open getattr if there is no cached data
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1441394647-16412-1-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 4 Sep 2015 15:38:30 -0400
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DA83C389-2E91-4A35-ACF5-F14F33D50944@oracle.com>
References: <1441394647-16412-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 4, 2015, at 3:24 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> If there is no cached data, then there is no need to track the file
> change attribute on close.

This makes sense. nfs_close_context() is only used by NFSv2
and NFSv3.

Should you update the documenting comment?


> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/inode.c | 8 +++++++-
> 1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 99a68bd9c178..ebaf991e4b02 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -766,6 +766,7 @@ EXPORT_SYMBOL_GPL(nfs_put_lock_context);
>  */
> void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
> {
> +	struct nfs_inode *nfsi;
> 	struct inode *inode;
> 	struct nfs_server *server;
> 
> @@ -774,7 +775,12 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
> 	if (!is_sync)
> 		return;
> 	inode = d_inode(ctx->dentry);
> -	if (!list_empty(&NFS_I(inode)->open_files))
> +	nfsi = NFS_I(inode);
> +	if (inode->i_mapping->nrpages == 0)
> +		return;
> +	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
> +		return;
> +	if (!list_empty(&nfsi->open_files))
> 		return;
> 	server = NFS_SERVER(inode);
> 	if (server->flags & NFS_MOUNT_NOCTO)
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



