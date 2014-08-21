Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:48797 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbaHUA2x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 20:28:53 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so3826441iec.30
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 17:28:52 -0700 (PDT)
Message-ID: <1408580933.4029.2.camel@leira.trondhjem.org>
Subject: Re: [PATCH] nfs: Always try and release an NFS file lock, even
 after receiving a SIGKILL
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Jeffery <djeffery@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 Aug 2014 20:28:53 -0400
In-Reply-To: <1438879608.14503585.1407251825405.JavaMail.zimbra@redhat.com>
References: <1438879608.14503585.1407251825405.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-08-05 at 11:17 -0400, David Jeffery wrote:
> If a task holding an NFS file lock is killed with SIGKILL, it can
> error out of do_unlk without ever trying to release the lock on
> the server. This triggers the WARN in locks_remove_file(), while
> also leaving the lock still claimed on the NFS server.  The file's
> lock state is left out of sync between client and server, requiring
> a restart of one or the other in order to release this ghost lock
> on the file.
> 
> do_unlk() should continue on and tell the server to release the
> lock, even if nfs_iocounter_wait() reports an error do to SIGKILL.
> 
> Signed-off-by: David Jeffery <djeffery@redhat.com>
> 
> ---
>  file.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 4042ff5..1b09243 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -750,10 +750,8 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>  
>  	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
>  	if (!IS_ERR(l_ctx)) {
> -		status = nfs_iocounter_wait(&l_ctx->io_count);
> +		nfs_iocounter_wait(&l_ctx->io_count);
>  		nfs_put_lock_context(l_ctx);
> -		if (status < 0)
> -			return status;
>  	}
>  
>  	/* NOTE: special case

What guarantees that this does not lead to silent corruption of the file
if there are outstanding write requests?

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


