From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Thu, 10 Jan 2008 17:41:35 -0500
Message-ID: <1200004896.13775.27.camel@heimdal.trondhjem.org>
References: <18310.37731.29874.582772@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:39707 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402AbYAJWlj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 17:41:39 -0500
In-Reply-To: <18310.37731.29874.582772-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-11 at 08:51 +1100, Neil Brown wrote:
> 
> I have a report of an unusual NFS deadlock in OpenSuSE 10.3, which is
> based on 2.6.22.
> 
> People who like bugzilla can find a little more detail at:
>     https://bugzilla.novell.com/show_bug.cgi?id=352878
> 
> We start with a "soft,intr" mount over a VPN on an unreliable network.
> 
> I assume an unmount happened (by autofs) while there was some
> outstanding requests  - at least one was a COMMIT but I'm guessing
> there were others.
> 
> When the last commit completed (probably timed-out) it put the open
> context, dropped the last reference on the vfsmnt and so called
> nfs_free_server and thence rpc_shutdown_client.
> All this is happened in rpciod/0.
> 
> rpc_shutdown_client calls rpc_killall_tasks and waits for them all to
> complete.  This deadlocks.
> 
> I'm wondering if some other request (read-ahead?) might need service
> from rpciod/0 before it can complete.  This would mean that it cannot
> complete until rpciod/0 is free, and rpciod/0 won't be free until it
> completes.
> 
> Is this a credible scenario?

Yes, but I have a scenario that I think trumps it:

      * the call that puts the open context is being made in
        nfs_commit_done (or possibly nfs_writeback_done), causing it to
        wait until the rpc_killall_tasks completes.
      * The problem is that rpc_killall_tasks won't complete until the
        rpc_task that is stuck in nfs_commit_done/nfs_writeback_done
        exits.

Urgh...

I'm surprised that we can get into this state, though. How is
sys_umount() able to exit with either readaheads or writebacks still
pending? Is this perhaps occurring on a lazy umount?

Cheers
  Trond

