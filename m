Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:58223 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931AbaJMOxc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2014 10:53:32 -0400
Received: by mail-ig0-f177.google.com with SMTP id a13so10691334igq.16
        for <linux-nfs@vger.kernel.org>; Mon, 13 Oct 2014 07:53:31 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 1/1] NFSv4: open context can be NULL in nfs_put_open_context
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1413209295-13509-1-git-send-email-andros@netapp.com>
Date: Mon, 13 Oct 2014 10:53:31 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <72CB6478-87D9-48B6-9C38-86BB5D3F4CDF@primarydata.com>
References: <1413209295-13509-1-git-send-email-andros@netapp.com>
To: William Andros Adamson <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 13, 2014, at 10:08 AM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> If a pgio error is caught before the nfs_pgio_header args->context is set
> with get_nfs_open_context, the context can be NULL.

It looks like all three calls to nfs_pgio_error would hit this!

The fix looks good to me.

-dros

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/inode.c | 3 +++
> 1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 141c9f4..a2b148e 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -798,6 +798,9 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
> 	struct inode *inode = ctx->dentry->d_inode;
> 	struct super_block *sb = ctx->dentry->d_sb;
> 
> +	if (ctx == NULL)
> +		return;
> +
> 	if (!list_empty(&ctx->list)) {
> 		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
> 			return;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

