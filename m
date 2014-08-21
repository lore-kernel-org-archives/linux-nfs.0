Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:41432 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbaHUA3Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 20:29:25 -0400
Received: by mail-ie0-f178.google.com with SMTP id rd18so3834025iec.37
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 17:29:24 -0700 (PDT)
Message-ID: <1408580966.4029.3.camel@leira.trondhjem.org>
Subject: Re: [PATCH] nfs: Don't busy-wait on SIGKILL in __nfs_iocounter_wait
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Jeffery <djeffery@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 Aug 2014 20:29:26 -0400
In-Reply-To: <1630665170.14504134.1407251982055.JavaMail.zimbra@redhat.com>
References: <1630665170.14504134.1407251982055.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-08-05 at 11:19 -0400, David Jeffery wrote:
> If a SIGKILL is sent to a task waiting in __nfs_iocounter_wait,
> it will busy-wait or soft lockup in its while loop.
> nfs_wait_bit_killable won't sleep, and the loop won't exit on
> the error return.  
> 
> Stop the busy-wait by breaking out of the loop when
> nfs_wait_bit_killable returns an error.
> 
> Signed-off-by: David Jeffery <djeffery@redhat.com>
> ---
> I'm not completely confident this is the right solution. I
> would like feedback if the intention was to break out of
> this loop on error, or if we do need to wait here until
> io_count hits zero and use something other than
> nfs_wait_bit_killable to wait in case of SIGKILL.
> 
>  pagelist.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 17fab89..f29a690 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -116,7 +116,7 @@ __nfs_iocounter_wait(struct nfs_io_counter *c)
>  		if (atomic_read(&c->io_count) == 0)
>  			break;
>  		ret = nfs_wait_bit_killable(&c->flags);
> -	} while (atomic_read(&c->io_count) != 0);
> +	} while (atomic_read(&c->io_count) != 0 && !ret);
>  	finish_wait(wq, &q.wait);
>  	return ret;
>  }

Applied.
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


