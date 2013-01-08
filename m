Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:59250 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab3AHVNt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 16:13:49 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Date: Tue, 8 Jan 2013 21:13:45 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911993A92@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130107202021.GC16957@nyc-qws-132.nyc.delacy.com>
	 <1357590561.28341.11.camel@lade.trondhjem.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911991BE9@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
	 <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911993608@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130108210106.GB30872@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20130108210106.GB30872@nyc-qws-132.nyc.delacy.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-08 at 16:01 -0500, Chris Perl wrote:
+AD4- +AD4- My main interest is always the upstream (Linus) kernel, however the RPC
+AD4- +AD4- client in the CentOS 6.3 kernel does actually contain a lot of code that
+AD4- +AD4- was recently backported from upstream. As such, it is definitely of
+AD4- +AD4- interest to figure out corner case bugs so that we can compare to
+AD4- +AD4- upstream...
+AD4- 
+AD4- Ok, great.  I will try this version of the patch as well.  However, when just
+AD4- thinking about this, I'm concerned that the race still exists, but is just less
+AD4- likely to manifest.
+AD4- 
+AD4- I imagine something like this happening.  I assume there is some reason this
+AD4- can't happen that I'm not seeing?  These are functions from linus's current
+AD4- git, not the CentOS 6.3 code: 
+AD4- 
+AD4- thread 1                                          thread 2
+AD4- --------                                          --------
+AD4- +AF8AXw-rpc+AF8-execute                                     +AF8AXw-rpc+AF8-execute
+AD4- ...                                               ...
+AD4- call+AF8-reserve
+AD4- xprt+AF8-reserve
+AD4- xprt+AF8-lock+AF8-and+AF8-alloc+AF8-slot
+AD4- xprt+AF8-lock+AF8-write
+AD4- xprt+AF8-reserve+AF8-xprt
+AD4- ...
+AD4- xprt+AF8-release+AF8-write
+AD4-                                                   call+AF8-reserve
+AD4- 						  xprt+AF8-reserve
+AD4- 						  xprt+AF8-lock+AF8-and+AF8-alloc+AF8-slot
+AD4- 						  xprt+AF8-lock+AF8-write
+AD4- 						  xprt+AF8-reserve+AF8-xprt
+AD4- 						  rpc+AF8-sleep+AF8-on+AF8-priority
+AD4- 						  +AF8AXw-rpc+AF8-sleep+AF8-on+AF8-priority
+AD4- 						  +AF8AXw-rpc+AF8-add+AF8-wait+AF8-queue
+AD4- 						  +AF8AXw-rpc+AF8-add+AF8-wait+AF8-queue+AF8-priority
+AD4- 						  (Now on the sending wait queue)
+AD4- xs+AF8-tcp+AF8-release+AF8-xprt
+AD4- xprt+AF8-release+AF8-xprt
+AD4- xprt+AF8-clear+AF8-locked
+AD4- +AF8AXw-xprt+AF8-lock+AF8-write+AF8-next
+AD4- rpc+AF8-wake+AF8-up+AF8-first
+AD4- +AF8AXw-rpc+AF8-find+AF8-next+AF8-queued
+AD4- +AF8AXw-rpc+AF8-find+AF8-next+AF8-queued+AF8-priority
+AD4- ...
+AD4- (has now pulled thread 2 off the wait queue)
+AD4-                                                  out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-bit
+AD4- 						 (receive SIGKILL)
+AD4- 						 rpc+AF8-wait+AF8-bit+AF8-killable
+AD4- 						 rpc+AF8-exit
+AD4- 						 rpc+AF8-exit+AF8-task
+AD4- 						 rpc+AF8-release+AF8-task
+AD4- 						 (doesn't release xprt b/c he isn't listed in snd+AF8-task yet)
+AD4- 						 (returns from +AF8AXw-rpc+AF8-execute)
+AD4- +AF8AXw-xprt+AF8-lock+AF8-write+AF8-func
+AD4- (thread 2 now has the transport locked)
+AD4- rpc+AF8-wake+AF8-up+AF8-task+AF8-queue+AF8-locked
+AD4- +AF8AXw-rpc+AF8-remove+AF8-wait+AF8-queue
+AD4- +AF8AXw-rpc+AF8-remove+AF8-wait+AF8-queue+AF8-priority
+AD4- (continues on, potentially exiting early,
+AD4-  potentially blocking the next time it needs the transport)
+AD4- 
+AD4- With the patch we're discussing, it would fix the case where thread 2 is
+AD4- breaking out of the FSM loop after having been given the transport lock.  But
+AD4- what about the above.  Is there something else synchronizing things?

Hi Chris,

I'm not sure I understand how the above would work. rpc+AF8-exit+AF8-task() will
remove the rpc+AF8-task from the xprt-+AD4-sending rpc+AF8-wait+AF8-queue, at which
point +AF8AXw-xprt+AF8-lock+AF8-write+AF8-func() can no longer find it.

+AD4- In my testing so far with my (not quite right) amended v3 of the patch, the
+AD4- timing has become such that I was having trouble reproducing the problem while
+AD4- attempting to instrument things with systemtap.  However, without systemtap
+AD4- running, I'm still able to reproduce the hang pretty easily.

Is it really the same hang? Does 'echo 0 +AD4-/proc/sys/sunrpc/rpc+AF8-debug'
show you a similar list of rpc tasks waiting on xprt-+AD4-sending?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
