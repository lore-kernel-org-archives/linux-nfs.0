Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f43.google.com ([209.85.212.43]:38136 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756589Ab3AHSpg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 13:45:36 -0500
Received: by mail-vb0-f43.google.com with SMTP id fs19so731716vbb.2
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jan 2013 10:45:36 -0800 (PST)
Date: Tue, 8 Jan 2013 13:40:11 -0500
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Message-ID: <20130108184011.GA30872@nyc-qws-132.nyc.delacy.com>
References: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
 <20130107202021.GC16957@nyc-qws-132.nyc.delacy.com>
 <1357590561.28341.11.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911991BE9@SACEXCMBX04-PRD.hq.netapp.com>
 <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
In-Reply-To: <20130107220047.GA30814@nyc-qws-132.nyc.delacy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 07, 2013 at 05:00:47PM -0500, Chris Perl wrote:
> On Mon, Jan 07, 2013 at 08:35:31PM +0000, Myklebust, Trond wrote:
> > On Mon, 2013-01-07 at 15:29 -0500, Trond Myklebust wrote:
> > > On Mon, 2013-01-07 at 15:20 -0500, Chris Perl wrote:
> > > > On Mon, Jan 07, 2013 at 07:50:10PM +0000, Myklebust, Trond wrote:
> > > > > Hi Chris,
> > > > > 
> > > > > Excellent sleuthing! Given the thoroughness of your explanation, I'm
> > > > > pretty sure that the attached patch should fix the problem.
> > > > > 
> > > > > Cheers
> > > > >   Trond
> > > > > -- 
> > > > > Trond Myklebust
> > > > > Linux NFS client maintainer
> > > > > 
> > > > > NetApp
> > > > > Trond.Myklebust@netapp.com
> > > > > www.netapp.com
> > > > 
> > > > > From ec8cbb4aff21cd0eac2c6f3fc4273ac72cdd91ef Mon Sep 17 00:00:00 2001
> > > > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > > Date: Mon, 7 Jan 2013 14:30:46 -0500
> > > > > Subject: [PATCH] SUNRPC: Ensure we release the socket write lock if the
> > > > >  rpc_task exits early
> > > > > 
> > > > > If the rpc_task exits while holding the socket write lock before it has
> > > > > allocated an rpc slot, then the usual mechanism for releasing the write
> > > > > lock in xprt_release() is defeated.
> > > > > 
> > > > > The problem occurs if the call to xprt_lock_write() initially fails, so
> > > > > that the rpc_task is put on the xprt->sending wait queue. If the task
> > > > > exits after being assigned the lock by __xprt_lock_write_func, but
> > > > > before it has retried the call to xprt_lock_and_alloc_slot(), then
> > > > > it calls xprt_release() while holding the write lock, but will
> > > > > immediately exit due to the test for task->tk_rqstp != NULL.
> > > > > 
> > > > > Reported-by: Chris Perl <chris.perl@gmail.com>
> > > > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > > Cc: stable@vger.kernel.org [>= 3.1]
> > > > > ---
> > > > >  net/sunrpc/xprt.c | 6 ++++--
> > > > >  1 file changed, 4 insertions(+), 2 deletions(-)
> > > > > 
> > > > > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > > > > index bd462a5..6676457 100644
> > > > > --- a/net/sunrpc/xprt.c
> > > > > +++ b/net/sunrpc/xprt.c
> > > > > @@ -1136,10 +1136,12 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
> > > > >  void xprt_release(struct rpc_task *task)
> > > > >  {
> > > > >  	struct rpc_xprt	*xprt;
> > > > > -	struct rpc_rqst	*req;
> > > > > +	struct rpc_rqst	*req = task->tk_rqstp;
> > > > >  
> > > > > -	if (!(req = task->tk_rqstp))
> > > > > +	if (req == NULL) {
> > > > > +		xprt_release_write(task->tk_xprt, task);
> > > > >  		return;
> > > > > +	}
> > > > >  
> > > > >  	xprt = req->rq_xprt;
> > > > >  	if (task->tk_ops->rpc_count_stats != NULL)
> > > > > -- 
> > > > > 1.7.11.7
> > > > > 
> > > > 
> > > > Ah, I totally missed the call to `rpc_release_task' at the bottom of the
> > > > `__rpc_execute' loop (at least thats how I think we'd get to this function
> > > > you're patching).
> > > > 
> > > > But wouldn't we need to update the call site in
> > > > `rpc_release_resources_task' as well?  It contains an explicit check for
> > > > `task->tk_rqstp' being non null.
> > > 
> > > Ewww.... You're right: That's a wart that seems to have been copied and
> > > pasted quite a few times.
> > > 
> > > Here is v2...
> > 
> > ...and a v3 that adds a small optimisation to avoid taking the transport
> > lock in cases where we really don't need it.
> > 
> > -- 
> > Trond Myklebust
> > Linux NFS client maintainer
> > 
> > NetApp
> > Trond.Myklebust@netapp.com
> > www.netapp.com
> 
> > From 51b63a538c54cb9c3b83c4d62572cf18da165cba Mon Sep 17 00:00:00 2001
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date: Mon, 7 Jan 2013 14:30:46 -0500
> > Subject: [PATCH v3] SUNRPC: Ensure we release the socket write lock if the
> >  rpc_task exits early
> > 
> > If the rpc_task exits while holding the socket write lock before it has
> > allocated an rpc slot, then the usual mechanism for releasing the write
> > lock in xprt_release() is defeated.
> > 
> > The problem occurs if the call to xprt_lock_write() initially fails, so
> > that the rpc_task is put on the xprt->sending wait queue. If the task
> > exits after being assigned the lock by __xprt_lock_write_func, but
> > before it has retried the call to xprt_lock_and_alloc_slot(), then
> > it calls xprt_release() while holding the write lock, but will
> > immediately exit due to the test for task->tk_rqstp != NULL.
> > 
> > Reported-by: Chris Perl <chris.perl@gmail.com>
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Cc: stable@vger.kernel.org [>= 3.1]
> > ---
> >  net/sunrpc/sched.c | 3 +--
> >  net/sunrpc/xprt.c  | 8 ++++++--
> >  2 files changed, 7 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> > index b4133bd..bfa3171 100644
> > --- a/net/sunrpc/sched.c
> > +++ b/net/sunrpc/sched.c
> > @@ -972,8 +972,7 @@ static void rpc_async_release(struct work_struct *work)
> >  
> >  static void rpc_release_resources_task(struct rpc_task *task)
> >  {
> > -	if (task->tk_rqstp)
> > -		xprt_release(task);
> > +	xprt_release(task);
> >  	if (task->tk_msg.rpc_cred) {
> >  		put_rpccred(task->tk_msg.rpc_cred);
> >  		task->tk_msg.rpc_cred = NULL;
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index bd462a5..6acc0c5 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -1136,10 +1136,14 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
> >  void xprt_release(struct rpc_task *task)
> >  {
> >  	struct rpc_xprt	*xprt;
> > -	struct rpc_rqst	*req;
> > +	struct rpc_rqst	*req = task->tk_rqstp;
> >  
> > -	if (!(req = task->tk_rqstp))
> > +	if (req == NULL) {
> > +		xprt = task->tk_xprt;
> > +		if (xprt->snd_task == task)
> > +			xprt_release_write(xprt, task);
> >  		return;
> > +	}
> >  
> >  	xprt = req->rq_xprt;
> >  	if (task->tk_ops->rpc_count_stats != NULL)
> > -- 
> > 1.7.11.7
> > 
> 
> Thanks, I will give this a shot tomorrow and let you know how it goes.

I applied the patch to a CentOS 6.3 system (same kernel I referenced
before) as I don't have my laptop available today to test the fedora
system I was using prior.  It panic'd on attempting to mount the NFS
share to start testing.

The backtrace from crash shows it as:

  crash> bt
  PID: 6721   TASK: ffff8810284acae0  CPU: 2   COMMAND: "mount.nfs"
   #0 [ffff881028c255b0] machine_kexec at ffffffff8103281b
   #1 [ffff881028c25610] crash_kexec at ffffffff810ba8e2
   #2 [ffff881028c256e0] oops_end at ffffffff815086b0
   #3 [ffff881028c25710] no_context at ffffffff81043bab
   #4 [ffff881028c25760] __bad_area_nosemaphore at ffffffff81043e35
   #5 [ffff881028c257b0] bad_area at ffffffff81043f5e
   #6 [ffff881028c257e0] __do_page_fault at ffffffff81044710
   #7 [ffff881028c25900] do_page_fault at ffffffff8150a68e
   #8 [ffff881028c25930] page_fault at ffffffff81507a45
      [exception RIP: xprt_release+388]
      RIP: ffffffffa025ec14  RSP: ffff881028c259e8  RFLAGS: 00010246
      RAX: 0000000000000000  RBX: ffff880829be0080  RCX: 0000000000000000
      RDX: 0000000000000002  RSI: 0000000000000000  RDI: ffff880829be0080
      RBP: ffff881028c25a18   R8: 0000000000000000   R9: 0000000000000000
      R10: 0000000000000000  R11: 0000000000000000  R12: 0000000000000000
      R13: ffff880829be0080  R14: ffffffffa0285fe0  R15: ffff88082a3ef968
      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
   #9 [ffff881028c25a20] rpc_release_resources_task at ffffffffa0266436 [sunrpc]
  #10 [ffff881028c25a40] rpc_do_put_task at ffffffffa0266564 [sunrpc]
  #11 [ffff881028c25a70] rpc_put_task at ffffffffa02665b0 [sunrpc]
  #12 [ffff881028c25a80] rpc_call_sync at ffffffffa025d4b8 [sunrpc]
  #13 [ffff881028c25ae0] rpc_ping at ffffffffa025d522 [sunrpc]
  #14 [ffff881028c25b20] rpc_create at ffffffffa025df37 [sunrpc]
  #15 [ffff881028c25bf0] nfs_mount at ffffffffa033f54a [nfs]
  #16 [ffff881028c25cc0] nfs_try_mount at ffffffffa03329f3 [nfs]
  #17 [ffff881028c25d80] nfs_get_sb at ffffffffa0333d86 [nfs]
  #18 [ffff881028c25e00] vfs_kern_mount at ffffffff8117df2b
  #19 [ffff881028c25e50] do_kern_mount at ffffffff8117e0d2
  #20 [ffff881028c25ea0] do_mount at ffffffff8119c862
  #21 [ffff881028c25f20] sys_mount at ffffffff8119cef0
  #22 [ffff881028c25f80] system_call_fastpath at ffffffff8100b0f2
      RIP: 00007ffff70aa8aa  RSP: 00007fffffffdac8  RFLAGS: 00000202
      RAX: 00000000000000a5  RBX: ffffffff8100b0f2  RCX: 0000000073726576
      RDX: 00007ffff7ff8edb  RSI: 00007ffff8205da0  RDI: 00007fffffffe2af
      RBP: 00007ffff7fc76a8   R8: 00007ffff8210090   R9: fefeff3836333834
      R10: 0000000000000000  R11: 0000000000000206  R12: 00007fffffffdbbc
      R13: 00007fffffffdbbe  R14: 00007fffffffdcb0  R15: 00007ffff8206040
      ORIG_RAX: 00000000000000a5  CS: 0033  SS: 002b

Anyway, it appears that on mount the rpc_tasks tk_client member is NULL
and therefore the double dereference of task->tk_xprt is what blew
things up.  I ammended the patch for this [1] and am testing it
now.

Thus far, I've still hit hangs, it just seems to take longer.  I'll have
to dig in a bit further to see what's going on now.

Is this CentOS 6.3 kernel this system too old for you guys to care?
I.e. should I spend time reporting digging into and reporting problems
for this system as well or you only care about the fedora system?

I'll report back again when I have further info and after testing the
fedora system.

[1] linux-kernel-test.patch



--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-kernel-test.patch"

--- a/net/sunrpc/sched.c	2012-11-24 13:48:51.000000000 -0500
+++ b/net/sunrpc/sched.c	2013-01-07 15:52:37.060355764 -0500
@@ -894,8 +894,7 @@
 
 static void rpc_release_resources_task(struct rpc_task *task)
 {
-	if (task->tk_rqstp)
-		xprt_release(task);
+	xprt_release(task);
 	if (task->tk_msg.rpc_cred)
 		put_rpccred(task->tk_msg.rpc_cred);
 	rpc_task_release_client(task);
--- a/net/sunrpc/xprt.c	2012-08-14 08:47:16.000000000 -0400
+++ b/net/sunrpc/xprt.c	2013-01-08 13:01:05.996805810 -0500
@@ -1128,10 +1128,16 @@
 void xprt_release(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt;
-	struct rpc_rqst	*req;
+	struct rpc_rqst	*req = task->tk_rqstp;
 
-	if (!(req = task->tk_rqstp))
+	if (req == NULL) {
+		if (task->tk_client) {
+			xprt = task->tk_xprt;
+			if (xprt->snd_task == task)
+				xprt_release_write(xprt, task);
+		}
 		return;
+	}
 
 	xprt = req->rq_xprt;
 	rpc_count_iostats(task);

--17pEHd4RhPHOinZp--
