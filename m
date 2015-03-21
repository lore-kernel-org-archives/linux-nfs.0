Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45631 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbbCUAsu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2015 20:48:50 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] nfs: fix high load average due to callback thread sleeping
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1426878914-15088-1-git-send-email-jeff.layton@primarydata.com>
Date: Fri, 20 Mar 2015 17:48:46 -0700
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna.Schumaker@netapp.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B81BC8FF-0305-4E1C-9E23-549E6FDD6624@oracle.com>
References: <1426878914-15088-1-git-send-email-jeff.layton@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 20, 2015, at 12:15 PM, Jeff Layton <jlayton@poochiereds.net> wrote:

> Chuck pointed out a problem that crept in with commit 6ffa30d3f734 (nfs:
> don't call blocking operations while !TASK_RUNNING). Linux counts tasks
> in uninterruptible sleep against the load average, so this caused the
> system's load average to be pinned at at least 1 when there was a
> NFSv4.1+ mount active.
> 
> Not a huge problem, but it's probably worth fixing before we get too
> many complaints about it. This patch converts the code back to use
> TASK_INTERRUPTIBLE sleep, simply has it flush any signals on each loop
> iteration. In practice no one should really be signalling this thread at
> all, so I think this is reasonably safe.
> 
> With this change, there's also no need to game the hung task watchdog so
> we can also convert the schedule_timeout call back to a normal schedule.
> 
> Cc: <stable@vger.kernel.org>
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Thanks for the quick response, Jeff.

I applied this on top of the first patch, mounted a test filesystem
with NFSv4.1, and confirmed that the backchannel service is responsive.
Load average on the client at idle is now 0.01.

Tested-by: Chuck Lever <chuck.lever@oracle.com>

Nit: I’d add a Fixes: commit 6ffa30d3f734 (“nfs: don't call blocking . . .”)
tag.

> ---
> fs/nfs/callback.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 351be9205bf8..8d129bb7355a 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -128,7 +128,7 @@ nfs41_callback_svc(void *vrqstp)
> 		if (try_to_freeze())
> 			continue;
> 
> -		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_UNINTERRUPTIBLE);
> +		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
> 		spin_lock_bh(&serv->sv_cb_lock);
> 		if (!list_empty(&serv->sv_cb_list)) {
> 			req = list_first_entry(&serv->sv_cb_list,
> @@ -142,10 +142,10 @@ nfs41_callback_svc(void *vrqstp)
> 				error);
> 		} else {
> 			spin_unlock_bh(&serv->sv_cb_lock);
> -			/* schedule_timeout to game the hung task watchdog */
> -			schedule_timeout(60 * HZ);
> +			schedule();
> 			finish_wait(&serv->sv_cb_waitq, &wq);
> 		}
> +		flush_signals(current);
> 	}
> 	return 0;
> }
> -- 
> 2.1.0
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



