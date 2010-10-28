From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] [bz 192] Fixed Regression in NFS Direct I/O path
Date: Thu, 28 Oct 2010 14:19:30 -0400
Message-ID: <1288289970.14221.15.camel@heimdal.trondhjem.org>
References: <1288268274-9444-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57900 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759829Ab0J1STf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 14:19:35 -0400
In-Reply-To: <1288268274-9444-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-10-28 at 08:17 -0400, Steve Dickson wrote:
> A typo, introduced by commit f11ac8db, in the nfs_direct_write()
> routine causes writes with O_DIRECT set to fail with a ENOMEM error.
> 
> Found-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/direct.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 064a809..84d3c8b 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -873,7 +873,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
>  	dreq->inode = inode;
>  	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
>  	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
> -	if (dreq->l_ctx != NULL)
> +	if (dreq->l_ctx == NULL)
>  		goto out_release;
>  	if (!is_sync_kiocb(iocb))
>  		dreq->iocb = iocb;

Applied! Thanks!

Trond

