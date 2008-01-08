From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 6/6] NLM: Add reference counting to lockd
Date: Tue, 8 Jan 2008 17:46:33 +1100
Message-ID: <18307.7241.831689.998668@notabene.brown>
References: <1199534542-3384-1-git-send-email-jlayton@redhat.com>
	<1199534542-3384-2-git-send-email-jlayton@redhat.com>
	<1199534542-3384-3-git-send-email-jlayton@redhat.com>
	<1199534542-3384-4-git-send-email-jlayton@redhat.com>
	<1199534542-3384-5-git-send-email-jlayton@redhat.com>
	<1199534542-3384-6-git-send-email-jlayton@redhat.com>
	<1199534542-3384-7-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:42164 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428AbYAHGqm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 01:46:42 -0500
In-Reply-To: message from Jeff Layton on Saturday January 5
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday January 5, jlayton@redhat.com wrote:
> @@ -357,7 +375,18 @@ lockd_down(void)
>  		goto out;
>  	}
>  	warned = 0;
> -	kthread_stop(nlmsvc_task);
> +	if (atomic_sub_return(1, &nlmsvc_ref) != 0)
> +		printk(KERN_WARNING "lockd_down: lockd is waiting for "
> +			"outstanding requests to complete before exiting.\n");

Why not "atomic_dec_and_test" ??

> +
> +	/*
> +	 * Sending a signal is necessary here. If we get to this point and
> +	 * nlm_blocked isn't empty then lockd may be held hostage by clients
> +	 * that are still blocking. Sending the signal makes sure that lockd
> +	 * invalidates all of its locks so that it's just waiting on RPC
> +	 * callbacks to complete
> +	 */
> +	kill_proc(nlmsvc_task->pid, SIGKILL, 1);

The previous patch removes a kill_proc(... SIGKILL),  this one adds it
back.
That makes me wonder if the intermediate state is 'correct'.

But I also wonder what "correct" means.
Do we want all locks to be dropped when the last nfsd thread dies?
The answer is presumably either "yes" or "no".
If "yes", then we don't have that because if there are any NFS mounts
active, lockd will not be killed.
If "no", then we don't want this kill_proc here.

The comment in lockd() which currently reads:

	/*
	 * The main request loop. We don't terminate until the last
	 * NFS mount or NFS daemon has gone away, and we've been sent a
	 * signal, or else another process has taken over our job.
	 */

suggests that someone once thought that lockd could hang around after
all nfsd threads and nfs mounts had gone, but I don't think it does.

We really should think this through and get it right, because if lockd
ever drops it's locks, then we really need to make sure sm_notify gets
run.  So it needs to be a well defined event.

Thoughts?

Also, it is sad that the inc/dec of nlmsvc_ref is called in somewhat
non-obvious ways.
e.g.

> +	if (!nlmsvc_users && error)
> +		atomic_dec(&nlmsvc_ref);

and

> +	if (list_empty(&nlm_blocked))
> +		atomic_inc(&nlmsvc_ref);
> +
>  	if (list_empty(&block->b_list)) {
>  		kref_get(&block->b_count);
>  	} else {

where if we moved the atomic_inc a little bit later next to the
"list_add_tail" (which seems to make more sense) it would actually be
wrong... But I think that code is correct as it is - just non-obvious.

NeilBrown

