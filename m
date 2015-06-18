Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36098 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbbFRUib (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 16:38:31 -0400
Received: by igbiq7 with SMTP id iq7so221082igb.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 13:38:30 -0700 (PDT)
Date: Thu, 18 Jun 2015 16:38:28 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Ensure we set NFS_CONTEXT_RESEND_WRITES when
 requeuing writes
Message-ID: <20150618163828.1fe03023@tlielax.poochiereds.net>
In-Reply-To: <1434585771-14169-2-git-send-email-trond.myklebust@primarydata.com>
References: <1434585771-14169-1-git-send-email-trond.myklebust@primarydata.com>
	<1434585771-14169-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jun 2015 20:02:51 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> If a write attempt fails, and the write is queued up for resending to
> the server, as opposed to being dropped, then we need to set the
> appropriate flag so that nfs_file_fsync() does the right thing.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/pnfs.c  | 1 +
>  fs/nfs/write.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 219ee6a3f1b3..d47c188682b1 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1821,6 +1821,7 @@ int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *hdr)
>  	/* Resend all requests through the MDS */
>  	nfs_pageio_init_write(&pgio, hdr->inode, FLUSH_STABLE, true,
>  			      hdr->completion_ops);
> +	set_bit(NFS_CONTEXT_RESEND_WRITES, &hdr->args.context->flags);
>  	return nfs_pageio_resend(&pgio, hdr);
>  }
>  EXPORT_SYMBOL_GPL(pnfs_write_done_resend_to_mds);
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index dfc19f1575a1..daf355642845 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1289,6 +1289,7 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
>  static void nfs_redirty_request(struct nfs_page *req)
>  {
>  	nfs_mark_request_dirty(req);
> +	set_bit(NFS_CONTEXT_RESEND_WRITES, &req->wb_context->flags);
>  	nfs_unlock_request(req);
>  	nfs_end_page_writeback(req);
>  	nfs_release_request(req);

Looks right.

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
