Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52139 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757858Ab3DXVLz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 17:11:55 -0400
Date: Wed, 24 Apr 2013 17:11:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dave Chiluk <chiluk@canonical.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
Message-ID: <20130424211153.GJ20275@fieldses.org>
References: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 03:55:49PM -0500, Dave Chiluk wrote:
> Changing the retry to start at NFS4_POLL_RETRY_MIN and exponentially grow
> to NFS4_POLL_RETRY_MAX allow for faster handling of these error conditions.
> 
> Additionally this alleviates an interoperability problem with the AIX NFSv4
> Server.  The AIX server frequently (2 out of 3) returns NFS4ERR_DELAY, on a
> close when it happens in close proximity to a RELEASE_LOCKOWNER.  This would
> cause a linux client to hang for 15 seconds.
> 
> Signed-off-by: Dave Chiluk <chiluk@canonical.com>
> ---
>  fs/nfs/nfs4proc.c            |   12 ++++++++++++
>  include/linux/sunrpc/sched.h |    1 +
>  2 files changed, 13 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0ad025e..37dad27 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4006,6 +4006,18 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
>  #endif /* CONFIG_NFS_V4_1 */
>  		case -NFS4ERR_DELAY:
>  			nfs_inc_server_stats(server, NFSIOS_DELAY);
> +			/* Do an exponential backoff of retries from
> +			 * NFS4_POLL_RETRY_MIN to NFS4_POLL_RETRY_MAX. */
> +			task->tk_timeout = NFS4_POLL_RETRY_MIN <<
> +					(task->tk_delays*2);
> +			if (task->tk_timeout > NFS4_POLL_RETRY_MAX)
> +				rpc_delay(task, NFS4_POLL_RETRY_MAX);
> +			else {
> +				task->tk_delays++;
> +				rpc_delay(task, task->tk_timeout);
> +			}
> +			task->tk_status = 0;
> +			return -EAGAIN;

Just as a matter of style, could you stick this in a helper something
like the existing nfs4_delay?:

		case -NFS4ERR_DELAY:
			nfs_inc_server_stats(server, NFSIOS_DELAY);
			nfs4_async_delay(task);
			task->tk_status = 0;
			return -EAGAIN;
		...

--b.

>  		case -NFS4ERR_GRACE:
>  			rpc_delay(task, NFS4_POLL_RETRY_MAX);
>  			task->tk_status = 0;
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index 84ca436..60f82bf 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -62,6 +62,7 @@ struct rpc_task {
>  	void *			tk_calldata;
>  
>  	unsigned long		tk_timeout;	/* timeout for rpc_sleep() */
> +	unsigned short		tk_delays;	/* number of times task delayed */
>  	unsigned long		tk_runstate;	/* Task run status */
>  	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
>  						 * be any workqueue
> -- 
> 1.7.9.5
> 
