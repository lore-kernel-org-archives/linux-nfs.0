From: Neil Brown <neilb@suse.de>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Fri, 11 Jan 2008 12:07:54 +1100
Message-ID: <18310.49514.808155.132856@notabene.brown>
References: <18310.37731.29874.582772@notabene.brown>
	<1200004896.13775.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:39911 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755471AbYAKBIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 20:08:02 -0500
In-Reply-To: message from Trond Myklebust on Thursday January 10
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday January 10, trond.myklebust@fys.uio.no wrote:
> 
> On Fri, 2008-01-11 at 08:51 +1100, Neil Brown wrote:
> > 
> > Is this a credible scenario?
> 
> Yes, but I have a scenario that I think trumps it:
> 
>       * the call that puts the open context is being made in
>         nfs_commit_done (or possibly nfs_writeback_done), causing it to
>         wait until the rpc_killall_tasks completes.
>       * The problem is that rpc_killall_tasks won't complete until the
>         rpc_task that is stuck in nfs_commit_done/nfs_writeback_done
>         exits.
> 
> Urgh...


Oh, yes, that would be ugly!

> 
> I'm surprised that we can get into this state, though. How is
> sys_umount() able to exit with either readaheads or writebacks still
> pending? Is this perhaps occurring on a lazy umount?

It does sound like it has to be a lazy unmount, doesn't it?  I don't
think autofs will do that.  The computer in question was suspended
while on the slow slow network and when it resumed the problem hit.
So maybe there is a suspend-time script which did the lazy unmount.
I'll ask.

Meanwhile, I managed to reproduce it.  It went something like:

Client:

  mount -o soft,intr server:/home /mnt
  { echo open > /dev/tty ;sleep 10; echo writing > /dev/tty; \
    exec cat /boot/bzImage-test;  } > /mnt/testing

  "open"

Server:
   rpc.nfsd 0

Client:

   "writing"

   type control-C

   umount -l /mnt


  wait a little while, notice that one rpciod is in 'D' wait.  
  echo t > /proc/sysrq-trigger

  See the same stack trace.


However I cannot do it again, so I cannot test a fix.


The only fix that occurs to me is to use schedule_work to shunt the
rpc_shutdown_client into a separate thread.

Thanks,
NeilBrown
