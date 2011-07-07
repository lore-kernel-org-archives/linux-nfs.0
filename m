Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477Ab1GGOfw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 10:35:52 -0400
Subject: Re: [PATCH] sunrpc: when call_bind fails with -EACCES, don't exit
 with -EIO
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 07 Jul 2011 10:35:56 -0400
In-Reply-To: <1310049133-10255-1-git-send-email-jlayton@redhat.com>
References: <1310049133-10255-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1310049356.3863.45.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-07-07 at 10:32 -0400, Jeff Layton wrote: 
> Commit 0b760113a fixed the client not to loop indefinitely if the
> rpcbind was continually failing. When this occurs though, the rpc_task
> now exits with a status of -EIO. If the tk_status is -EACCES, it seems
> like we should preserve that in this situation.

Why? This isn't the POSIX EACCES error, but a sign that the server is
once again refusing to do business with us: usually that means EIO.

Cheers
  Trond

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/clnt.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 8c91415..77f6c0c 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1175,8 +1175,10 @@ call_bind_status(struct rpc_task *task)
>  			status = -EOPNOTSUPP;
>  			break;
>  		}
> -		if (task->tk_rebind_retry == 0)
> +		if (task->tk_rebind_retry == 0) {
> +			status = task->tk_status;
>  			break;
> +		}
>  		task->tk_rebind_retry--;
>  		rpc_delay(task, 3*HZ);
>  		goto retry_timeout;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

