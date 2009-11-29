From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: remove BKL from callback server
Date: Sun, 29 Nov 2009 16:24:44 -0500
Message-ID: <20091129212444.GC7216@fieldses.org>
References: <20091009151151.GB9436@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57715 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895AbZK2VXr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Nov 2009 16:23:47 -0500
In-Reply-To: <20091009151151.GB9436@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, did this get applied?

And is there someplace I should be looking for your pending patches
other than

	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

?  Currently they don't seem to have anything not upstream.  (But I may
have overlooked something.)

--b.

On Fri, Oct 09, 2009 at 11:11:51AM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> The rpc server does not require that service threads take the BKL.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfs/callback.c |   12 ------------
>  1 files changed, 0 insertions(+), 12 deletions(-)
> 
> Just noticed this while looking for something else.
> 
> If these BKL's were cut-and-pasted from lockd or older nfsd code under
> the assumption that the generic rpc server code needed them: that
> assumption was incorrect, and we should apply this patch.
> 
> (If there was some nfs-client-specific issue here, then ignore this
> patch.)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 293fa05..e66ec5d 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -78,11 +78,6 @@ nfs4_callback_svc(void *vrqstp)
>  
>  	set_freezable();
>  
> -	/*
> -	 * FIXME: do we really need to run this under the BKL? If so, please
> -	 * add a comment about what it's intended to protect.
> -	 */
> -	lock_kernel();
>  	while (!kthread_should_stop()) {
>  		/*
>  		 * Listen for a request on the socket
> @@ -104,7 +99,6 @@ nfs4_callback_svc(void *vrqstp)
>  		preverr = err;
>  		svc_process(rqstp);
>  	}
> -	unlock_kernel();
>  	return 0;
>  }
>  
> @@ -160,11 +154,6 @@ nfs41_callback_svc(void *vrqstp)
>  
>  	set_freezable();
>  
> -	/*
> -	 * FIXME: do we really need to run this under the BKL? If so, please
> -	 * add a comment about what it's intended to protect.
> -	 */
> -	lock_kernel();
>  	while (!kthread_should_stop()) {
>  		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
>  		spin_lock_bh(&serv->sv_cb_lock);
> @@ -183,7 +172,6 @@ nfs41_callback_svc(void *vrqstp)
>  		}
>  		finish_wait(&serv->sv_cb_waitq, &wq);
>  	}
> -	unlock_kernel();
>  	return 0;
>  }
>  
> -- 
> 1.6.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
