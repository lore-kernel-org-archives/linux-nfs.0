From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH - take 2] knfsd: nfsd: Handle ERESTARTSYS from
   syscalls. (and possible kthread_stop changes)
Date: Tue, 24 Jun 2008 09:55:55 +1000
Message-ID: <18528.14347.525397.917553@notabene.brown>
References: <20080619101025.24263.patches@notabene>
	<1080619001109.24338@suse.de>
	<20080618210947.2110a541@tleilax.poochiereds.net>
	<18521.50300.572838.123366@notabene.brown>
	<20080619063824.00ca6381@tleilax.poochiereds.net>
	<18526.60523.584503.68076@notabene.brown>
	<20080622205244.261a787d@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:48148 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586AbYFWX4F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2008 19:56:05 -0400
In-Reply-To: message from Jeff Layton on Sunday June 22
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sunday June 22, jlayton@redhat.com wrote:
> On Mon, 23 Jun 2008 10:20:59 +1000
> Neil Brown <neilb@suse.de> wrote:
> > 
> > I think my leaning is just to remove the distinction.  About the worst
> > that can happen if the filesystem decides to respond to the signal is
> > that you get a short write or a short read, both of which should be
> > correctly handled by the client.
> > 
> 
> Good points all around. If the sigmask juggling makes no sense, then
> I'm OK with removing it. I'd prefer that we simplify the code rather
> than trying to get clever with init scripts anyway...
> 

Let's do it?

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 941041f..914e579 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -36,12 +36,7 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
-/* these signals will be delivered to an nfsd thread 
- * when handling a request
- */
-#define ALLOWED_SIGS	(sigmask(SIGKILL))
-/* these signals will be delivered to an nfsd thread
- * when not handling a request. i.e. when waiting
+/* These signals can be used to shutdown an nfsd thread.
  */
 #define SHUTDOWN_SIGS	(sigmask(SIGKILL) | sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT))
 /* if the last thread dies with SIGHUP, then the exports table is
@@ -396,7 +391,7 @@ nfsd(struct svc_rqst *rqstp)
 {
 	struct fs_struct *fsp;
 	int		err;
-	sigset_t shutdown_mask, allowed_mask;
+	sigset_t shutdown_mask;
 
 	/* Lock module and set up kernel thread */
 	lock_kernel();
@@ -415,7 +410,8 @@ nfsd(struct svc_rqst *rqstp)
 	current->fs->umask = 0;
 
 	siginitsetinv(&shutdown_mask, SHUTDOWN_SIGS);
-	siginitsetinv(&allowed_mask, ALLOWED_SIGS);
+	/* Block all but the shutdown signals */
+	sigprocmask(SIG_SETMASK, &shutdown_mask, NULL);
 
 	nfsdstats.th_cnt++;
 
@@ -435,8 +431,6 @@ nfsd(struct svc_rqst *rqstp)
 	 * The main request loop
 	 */
 	for (;;) {
-		/* Block all but the shutdown signals */
-		sigprocmask(SIG_SETMASK, &shutdown_mask, NULL);
 
 		/*
 		 * Find a socket with data available and call its
@@ -452,9 +446,6 @@ nfsd(struct svc_rqst *rqstp)
 		/* Lock the export hash tables for reading. */
 		exp_readlock();
 
-		/* Process request with signals blocked.  */
-		sigprocmask(SIG_SETMASK, &allowed_mask, NULL);
-
 		svc_process(rqstp);
 
 		/* Unlock export hash tables */


> 
> The latest patch doesn't use kthread_stop with nfsd. I figured it was
> best to avoid having multiple takedown methods, and since we're using
> signals here anyway, I just kept signaling as the only way to take down
> nfsd. Plus, as you mention -- all kthread_stop's are serialized, which
> could have meant that nfsd's would take a long time to come down on a
> busy box with a lot of them.

Oh, good.  I must have been looking at an old patch.

> 
> As a side note, I'm not terribly thrilled with how kthread_stop is
> implemented. I worry that a stuck kthread would block unrelated
> kthreads from coming down. I did a patch 6 mos ago or so to make it so
> that kthread_stop's could be done in parallel. The downside was that it
> added a new field to the task_struct (which is already too bloated,
> IMO). It might be worth resurrecting that at some point (possibly
> making the new field a union with another field that's unused in
> kthreads), or considering a different approach to parallelize
> kthread_stop.

One the one hand, kthreads are expected to not block and to check for
kthread_should_stop very often, so this wouldn't be a problem.
On the other hand, expectations like this are quickly invalidated, and
the code probably should be fixed.
I suspect we could do without adding anything to task_struct.
Instead of just one kthread_stop_info, have a linked list, one entry
for each thread being stopped at the moment.  kthread_stop adds to
the list, sets PF_EXITING (I hope that is safe) and wakes the process.
kthread_should_stop tests PF_EXITING.
When kthread() finishes, it does a linear search (the list should be
short) and calls complete and the relevant .done.

Something like this?

NeilBrown


diff --git a/kernel/kthread.c b/kernel/kthread.c
index bd1b9ea..107290a 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -39,12 +39,13 @@ struct kthread_stop_info
 	struct task_struct *k;
 	int err;
 	struct completion done;
+	struct kthread_stp_info *next;
 };
 
 /* Thread stopping is done by setthing this var: lock serializes
  * multiple kthread_stop calls. */
 static DEFINE_MUTEX(kthread_stop_lock);
-static struct kthread_stop_info kthread_stop_info;
+static struct kthread_stop_info *kthread_stop_info;
 
 /**
  * kthread_should_stop - should this kthread return now?
@@ -55,7 +56,7 @@ static struct kthread_stop_info kthread_stop_info;
  */
 int kthread_should_stop(void)
 {
-	return (kthread_stop_info.k == current);
+	return test_bit(PF_EXITING, &current.flags);
 }
 EXPORT_SYMBOL(kthread_should_stop);
 
@@ -80,8 +81,17 @@ static int kthread(void *_create)
 
 	/* It might have exited on its own, w/o kthread_stop.  Check. */
 	if (kthread_should_stop()) {
-		kthread_stop_info.err = ret;
-		complete(&kthread_stop_info.done);
+		struct kthread_stop_info **ksip;
+		mutex_lock(&kthread_stop_lock);
+		for (ksip = &kthread_stop_info ; *ksip ; ksip = &(*ksip)->next)
+			if ((*ksip)->k == current)
+				break;
+		*ksip = (*ksip)->next;
+		(*ksip)->next = NULL;
+		mutex_unlock(&kthread_stop_lock);
+
+		ksi->err = ret;
+		complete(&ksi->done);
 	}
 	return 0;
 }
@@ -199,26 +209,20 @@ EXPORT_SYMBOL(kthread_bind);
 int kthread_stop(struct task_struct *k)
 {
 	int ret;
+	struct kthread_stop_info ksi;
 
 	mutex_lock(&kthread_stop_lock);
 
-	/* It could exit after stop_info.k set, but before wake_up_process. */
-	get_task_struct(k);
+	init_completion(&ksi->done);
+	ksi->k = k;
 
-	/* Must init completion *before* thread sees kthread_stop_info.k */
-	init_completion(&kthread_stop_info.done);
-	smp_wmb();
-
-	/* Now set kthread_should_stop() to true, and wake it up. */
-	kthread_stop_info.k = k;
+	set_bit(PF_EXITING, &k->flags);
 	wake_up_process(k);
-	put_task_struct(k);
+	mutex_unlock(&kthread_stop_lock);
 
-	/* Once it dies, reset stop ptr, gather result and we're done. */
-	wait_for_completion(&kthread_stop_info.done);
-	kthread_stop_info.k = NULL;
+	/* Once it dies gather result and we're done. */
+	wait_for_completion(&ksi->done);
 	ret = kthread_stop_info.err;
-	mutex_unlock(&kthread_stop_lock);
 
 	return ret;
 }
