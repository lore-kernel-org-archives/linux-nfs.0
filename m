Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1169601AbdDXMT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 08:19:29 -0400
Date: Mon, 24 Apr 2017 08:19:20 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2 2/2] NFSv4.x/callback: make sure callback threads are
 interruptible
In-Reply-To: <d8e459af-1efa-dae9-61b6-253e8945831f@gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1704240811480.31833@planck.local>
References: <d8e459af-1efa-dae9-61b6-253e8945831f@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Jan 2017, Kinglong Mee wrote:
> Commit bb6aeba736ba "NFSv4.x: Switch to using svc_set_num_threads()
>  to manage the callback threads" change nfs start/stop threads
> through svc_set_num_threads().
>
> It destroy old threads by SIGINT signal, but our nfs4_callback_svc()
> isn't interruptible. So that, the callback threads will never be killed.
>
> # mount -t nfs -overs=4.2 nfstestnic:/ /mnt/
> # ps -ajx |grep NFS
>     2  5927     0     0 ?           -1 S        0   0:00 [NFSv4 callback]
> # umount /mnt
> # ps -ajx |grep NFS
>     2  5927     0     0 ?           -1 S        0   0:00 [NFSv4 callback]
> # mount -t nfs -overs=4.2 nfstestnic:/ /mnt/
> # umount /mnt
> # ps -ajx |grep NFS
>     2  5927     0     0 ?           -1 S        0   0:00 [NFSv4 callback]
>     2  5963     0     0 ?           -1 S        0   0:00 [NFSv4 callback]
>
> After one mount, there will be one callback thread left that cannot killed,
> the same time, nfs.ko will never be unplugged.
>
> v2, drop the wrong setting of rqstp->rq_server = NULL
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Thanks!  We have some fedora users complaining about this problem:
https://bugzilla.redhat.com/show_bug.cgi?id=1427493

This and
[PATCH v2 1/2] NFSv4.x/callback: Create the callback service through
svc_create_pooled

fix it up for me.

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
Tested-by: Benjamin Coddington <bcodding@redhat.com>

Ben

> ---
>  fs/nfs/callback.c | 39 +++++++++++++++++++++++++++++++++++----
>  1 file changed, 35 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 0a21150..2a0fffd 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -73,6 +73,15 @@ nfs4_callback_svc(void *vrqstp)
>  	int err;
>  	struct svc_rqst *rqstp = vrqstp;
>
> +	/*
> +	 * thread is spawned with all signals set to SIG_IGN, re-enable
> +	 * the ones that will bring down the thread
> +	 */
> +	allow_signal(SIGKILL);
> +	allow_signal(SIGHUP);
> +	allow_signal(SIGINT);
> +	allow_signal(SIGQUIT);
> +
>  	set_freezable();
>
>  	while (!kthread_should_stop()) {
> @@ -80,11 +89,18 @@ nfs4_callback_svc(void *vrqstp)
>  		 * Listen for a request on the socket
>  		 */
>  		err = svc_recv(rqstp, MAX_SCHEDULE_TIMEOUT);
> -		if (err == -EAGAIN || err == -EINTR)
> +		if (err == -EAGAIN)
>  			continue;
> +		else if (err == -EINTR)
> +			break;
>  		svc_process(rqstp);
>  	}
> -	return 0;
> +
> +	flush_signals(current);
> +
> +	/* Release the thread */
> +	svc_exit_thread(rqstp);
> +	module_put_and_exit(0);
>  }
>
>  #if defined(CONFIG_NFS_V4_1)
> @@ -100,6 +116,15 @@ nfs41_callback_svc(void *vrqstp)
>  	int error;
>  	DEFINE_WAIT(wq);
>
> +	/*
> +	 * thread is spawned with all signals set to SIG_IGN, re-enable
> +	 * the ones that will bring down the thread
> +	 */
> +	allow_signal(SIGKILL);
> +	allow_signal(SIGHUP);
> +	allow_signal(SIGINT);
> +	allow_signal(SIGQUIT);
> +
>  	set_freezable();
>
>  	while (!kthread_should_stop()) {
> @@ -121,11 +146,17 @@ nfs41_callback_svc(void *vrqstp)
>  		} else {
>  			spin_unlock_bh(&serv->sv_cb_lock);
>  			schedule();
> +			if (signalled())
> +				break;
>  			finish_wait(&serv->sv_cb_waitq, &wq);
>  		}
> -		flush_signals(current);
>  	}
> -	return 0;
> +
> +	flush_signals(current);
> +
> +	/* Release the thread */
> +	svc_exit_thread(rqstp);
> +	module_put_and_exit(0);
>  }
>
>  static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
> --
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
