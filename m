Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758652Ab0J1Meh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 08:34:37 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o9SCYbXW027432
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 08:34:37 -0400
Date: Thu, 28 Oct 2010 08:34:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] [bz 192] Fixed Regression in NFS Direct I/O path
Message-ID: <20101028083435.35c990f0@tlielax.poochiereds.net>
In-Reply-To: <1288268274-9444-1-git-send-email-steved@redhat.com>
References: <1288268274-9444-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 28 Oct 2010 08:17:54 -0400
Steve Dickson <steved@redhat.com> wrote:

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

Also, since get_lock_context holds references, this prevents the fs
from being unmounted. It looks like this bug is in 2.6.36 too, so this
may be suitable for stable series as well.

-- 
Jeff Layton <jlayton@redhat.com>
