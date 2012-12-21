Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56803 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464Ab2LUXPm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2012 18:15:42 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>
Subject: RE: nfsd oops on Linus' current tree.
Date: Fri, 21 Dec 2012 23:15:40 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121221153348.GA32151@redhat.com>
 <20121221180824.GA27729@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>,<20121221230849.GB29739@fieldses.org>
In-Reply-To: <20121221230849.GB29739@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies for top-posting. The SSD on my laptop died, and so I'm stuck using webmail for this account...

Our experience with nfsiod is that the WQ_MEM_RECLAIM option still deadlocks despite the "rescuer thread". The CPU that is running the workqueue will deadlock with any rpciod task that is assigned to the same CPU. Interestingly enough, the WQ_UNBOUND option also appears able to deadlock in the same situation.

Sorry, I have no explanation why...

Cheers,
  Trond


________________________________________
From: J. Bruce Fields [bfields@fieldses.org]
Sent: Friday, December 21, 2012 6:08 PM
To: Myklebust, Trond
Cc: Dave Jones; Linux Kernel; linux-nfs@vger.kernel.org; Adamson, Dros
Subject: Re: nfsd oops on Linus' current tree.

On Fri, Dec 21, 2012 at 06:40:54PM +0000, Myklebust, Trond wrote:
> On Fri, 2012-12-21 at 13:08 -0500, J. Bruce Fields wrote:
> > On Fri, Dec 21, 2012 at 10:33:48AM -0500, Dave Jones wrote:
> > > Did a mount from a client (also running Linus current), and the
> > > server spat this out..
> > >
> > > [ 6936.306135] ------------[ cut here ]------------
> > > [ 6936.306154] WARNING: at net/sunrpc/clnt.c:617 rpc_shutdown_client+0x12a/0x1b0 [sunrpc]()
> >
> > This is a warning added by 168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9
> > "SUNRPC: add WARN_ON_ONCE for potential deadlock", pointing out that
> > nfsd is calling shutdown_client from a workqueue, which is a problem
> > because shutdown_client has to wait on rpc tasks that run on a
> > workqueue.
> >
> > I don't believe there's any circular dependency among the workqueues
> > (we're calling shutdown_client from callback_wq, not rpciod_workqueue),
>
> We were getting deadlocks with rpciod when calling rpc_shutdown_client
> from the nfsiod workqueue.
>
> The problem here is that the workqueues all run using the same pool of
> threads, and so you can get "interesting" deadlocks when one of these
> threads has to wait for another one.

OK, coming back after reviewing Documentation/workqueue.txt: the
workqueues potentially involved here are rpciod and the server's
laundromat and callback workqueues.

The former is created with

        alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 1);

and the latter two are both created with
create_singlethread_workqueue(), which also sets WQ_MEM_RECLAIM.

As I understand it, that ensures that each of the three has at least one
"rescuer" thread dedicated to it--so there shouldn't be any deadlock as
long as there's no circular dependency among the three.

So think this is a false positive--am I missing something?

> > but 168e4b39d1afb.. says that we could get a deadlock if both are
> > running on the same kworker thread.
> >
> > I'm not sure what to do about that.
> >
>
> The question is if you really do need the call to rpc_killall_tasks and
> the synchronous wait for completion of old tasks? If you don't care,
> then we could just have you call rpc_release_client() in order to
> release your reference on the rpc_client.

No, the waiting's intentional: for example, the laundromat wq is what's
responsible for reaping expired clients, and it wants to wait for
callback rpc's to exit.  (If I remember right they may reference data
structures we're about to clean up).

--b.
