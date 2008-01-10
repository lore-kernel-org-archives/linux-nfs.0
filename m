From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 6/6] NLM: Add reference counting to lockd
Date: Thu, 10 Jan 2008 14:29:22 +1100
Message-ID: <18309.37138.207880.305870@notabene.brown>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
	<1199820798-5289-2-git-send-email-jlayton@redhat.com>
	<1199820798-5289-3-git-send-email-jlayton@redhat.com>
	<1199820798-5289-4-git-send-email-jlayton@redhat.com>
	<1199820798-5289-5-git-send-email-jlayton@redhat.com>
	<1199820798-5289-6-git-send-email-jlayton@redhat.com>
	<1199820798-5289-7-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37487 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255AbYAJD3a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 22:29:30 -0500
In-Reply-To: message from Jeff Layton on Tuesday January 8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday January 8, jlayton@redhat.com wrote:
> ...and only have lockd exit when the last reference is dropped.
> 
> The problem is this:
> 
> When a lock that a client is blocking on comes free, lockd does this in
> nlmsvc_grant_blocked():
> 
>     nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG, &nlmsvc_grant_ops);
> 
> the callback from this call is nlmsvc_grant_callback(). That function
> does this at the end to wake up lockd:
> 
>     svc_wake_up(block->b_daemon);

Uhmmm... Maybe there is an easier way.

block->b_daemon will always be nlmsvc_serv, so can we simply make this

	svc_wake_up(nlmsvc_serv);
with a little locking to make sure nlmsvc_serv is valid?

Actually svc_wake_up is only called from lockd and goes through
various hoops to find the right rqstp, which we could have known in
advance.
So store the rqstp in some global wrapped in a spinlock so we can
access it safely and just:

   spin_lock(whatever)
   if (nlmsvc_rqstp)
	wake_up(&nlmsvc_rqstp->rq_wait)
   spin_unlock(whatever)


That seems a somewhat simpler way of avoiding the particular problem.


Hmmm.... I guess that nlmsvc_grant_callback could then be run after
the 'lockd' module had been unloaded.
Maybe nlm_shutdown_hosts could call rpc_killall_tasks(host->h_rpcclnt)
on each host.  That should ensure the callback wont happen afterwards.

Maybe?

NeilBrown

