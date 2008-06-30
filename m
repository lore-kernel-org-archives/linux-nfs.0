From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH - take 2] knfsd: nfsd: Handle ERESTARTSYS from  
 syscalls. (and possible kthread_stop changes)
Date: Mon, 30 Jun 2008 08:35:36 -0400
Message-ID: <20080630083536.680b093a@barsoom.rdu.redhat.com>
References: <20080619101025.24263.patches@notabene>
	<1080619001109.24338@suse.de>
	<20080618210947.2110a541@tleilax.poochiereds.net>
	<18521.50300.572838.123366@notabene.brown>
	<20080619063824.00ca6381@tleilax.poochiereds.net>
	<18526.60523.584503.68076@notabene.brown>
	<20080622205244.261a787d@tleilax.poochiereds.net>
	<18528.14347.525397.917553@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671AbYF3Mfl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2008 08:35:41 -0400
In-Reply-To: <18528.14347.525397.917553-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jun 2008 09:55:55 +1000
Neil Brown <neilb@suse.de> wrote:

> On Sunday June 22, jlayton@redhat.com wrote:
> > On Mon, 23 Jun 2008 10:20:59 +1000
> > Neil Brown <neilb@suse.de> wrote:
> > > 
> > > I think my leaning is just to remove the distinction.  About the worst
> > > that can happen if the filesystem decides to respond to the signal is
> > > that you get a short write or a short read, both of which should be
> > > correctly handled by the client.
> > > 
> > 
> > Good points all around. If the sigmask juggling makes no sense, then
> > I'm OK with removing it. I'd prefer that we simplify the code rather
> > than trying to get clever with init scripts anyway...
> > 
> 
> Let's do it?
> 

The idea looks reasonable, but the patch above doesn't apply to Bruce's
for-2.6.27 tree. The nfsd() function has changed a bit. Actually, I
think we can make this even simpler. kthreads start with all signals
ignored and the new patch enables all of the ones in SHUTDOWN_SIGS. So
I don't think we need any signal masking at all.

How about this patch? It should apply on top of the patchset already
in Bruce's tree.

------------[snip]--------------

Subject: [PATCH] knfsd: treat all shutdown signals as equivalent

knfsd currently uses 2 signal masks when processing requests. A "loose"
mask (SHUTDOWN_SIGS) that it uses when receiving network requests, and
then a more "strict" mask (ALLOWED_SIGS, which is just SIGKILL) that it
allows when doing the actual operation on the local storage.

This is apparently unnecessarily complicated. The underlying filesystem
should be able to sanely handle a signal in the middle of an operation.
This patch removes the signal mask handling from knfsd altogether. When
knfsd is started as a kthread, all signals are ignored. It then allows
all of the signals in SHUTDOWN_SIGS. There's no need to set the mask
as well.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c |   20 ++------------------
 1 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 96fdbca..d20a087 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -37,13 +37,7 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
-/* these signals will be delivered to an nfsd thread 
- * when handling a request
- */
-#define ALLOWED_SIGS	(sigmask(SIGKILL))
-/* these signals will be delivered to an nfsd thread
- * when not handling a request. i.e. when waiting
- */
+/* These signals can be used to shutdown an nfsd thread. */
 #define SHUTDOWN_SIGS	(sigmask(SIGKILL) | sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT))
 
 extern struct svc_program	nfsd_program;
@@ -414,7 +408,6 @@ nfsd(void *vrqstp)
 {
 	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
 	struct fs_struct *fsp;
-	sigset_t shutdown_mask, allowed_mask;
 	int err, preverr = 0;
 	unsigned int signo;
 
@@ -433,15 +426,12 @@ nfsd(void *vrqstp)
 	current->fs = fsp;
 	current->fs->umask = 0;
 
-	siginitsetinv(&shutdown_mask, SHUTDOWN_SIGS);
-	siginitsetinv(&allowed_mask, ALLOWED_SIGS);
-
 	/*
 	 * thread is spawned with all signals set to SIG_IGN, re-enable
 	 * the ones that matter
 	 */
 	for (signo = 1; signo <= _NSIG; signo++) {
-		if (!sigismember(&shutdown_mask, signo))
+		if (siginmask(signo, SHUTDOWN_SIGS))
 			allow_signal(signo);
 	}
 
@@ -460,9 +450,6 @@ nfsd(void *vrqstp)
 	 * The main request loop
 	 */
 	for (;;) {
-		/* Block all but the shutdown signals */
-		sigprocmask(SIG_SETMASK, &shutdown_mask, NULL);
-
 		/*
 		 * Find a socket with data available and call its
 		 * recvfrom routine.
@@ -487,9 +474,6 @@ nfsd(void *vrqstp)
 		/* Lock the export hash tables for reading. */
 		exp_readlock();
 
-		/* Process request with signals blocked. */
-		sigprocmask(SIG_SETMASK, &allowed_mask, NULL);
-
 		svc_process(rqstp);
 
 		/* Unlock export hash tables */
-- 
1.5.5.1



> > 
> > The latest patch doesn't use kthread_stop with nfsd. I figured it was
> > best to avoid having multiple takedown methods, and since we're using
> > signals here anyway, I just kept signaling as the only way to take down
> > nfsd. Plus, as you mention -- all kthread_stop's are serialized, which
> > could have meant that nfsd's would take a long time to come down on a
> > busy box with a lot of them.
> 
> Oh, good.  I must have been looking at an old patch.
> 
> > 
> > As a side note, I'm not terribly thrilled with how kthread_stop is
> > implemented. I worry that a stuck kthread would block unrelated
> > kthreads from coming down. I did a patch 6 mos ago or so to make it so
> > that kthread_stop's could be done in parallel. The downside was that it
> > added a new field to the task_struct (which is already too bloated,
> > IMO). It might be worth resurrecting that at some point (possibly
> > making the new field a union with another field that's unused in
> > kthreads), or considering a different approach to parallelize
> > kthread_stop.
> 
> One the one hand, kthreads are expected to not block and to check for
> kthread_should_stop very often, so this wouldn't be a problem.
> On the other hand, expectations like this are quickly invalidated, and
> the code probably should be fixed.
> I suspect we could do without adding anything to task_struct.
> Instead of just one kthread_stop_info, have a linked list, one entry
> for each thread being stopped at the moment.  kthread_stop adds to
> the list, sets PF_EXITING (I hope that is safe) and wakes the process.
> kthread_should_stop tests PF_EXITING.
> When kthread() finishes, it does a linear search (the list should be
> short) and calls complete and the relevant .done.
> 
> Something like this?
> 
> NeilBrown
> 
> 
> diff --git a/kernel/kthread.c b/kernel/kthread.c
> index bd1b9ea..107290a 100644
> --- a/kernel/kthread.c
> +++ b/kernel/kthread.c
> @@ -39,12 +39,13 @@ struct kthread_stop_info
>  	struct task_struct *k;
>  	int err;
>  	struct completion done;
> +	struct kthread_stp_info *next;
>  };
>  
>  /* Thread stopping is done by setthing this var: lock serializes
>   * multiple kthread_stop calls. */
>  static DEFINE_MUTEX(kthread_stop_lock);
> -static struct kthread_stop_info kthread_stop_info;
> +static struct kthread_stop_info *kthread_stop_info;
>  
>  /**
>   * kthread_should_stop - should this kthread return now?
> @@ -55,7 +56,7 @@ static struct kthread_stop_info kthread_stop_info;
>   */
>  int kthread_should_stop(void)
>  {
> -	return (kthread_stop_info.k == current);
> +	return test_bit(PF_EXITING, &current.flags);
>  }
>  EXPORT_SYMBOL(kthread_should_stop);
>  
> @@ -80,8 +81,17 @@ static int kthread(void *_create)
>  
>  	/* It might have exited on its own, w/o kthread_stop.  Check. */
>  	if (kthread_should_stop()) {
> -		kthread_stop_info.err = ret;
> -		complete(&kthread_stop_info.done);
> +		struct kthread_stop_info **ksip;
> +		mutex_lock(&kthread_stop_lock);
> +		for (ksip = &kthread_stop_info ; *ksip ; ksip = &(*ksip)->next)
> +			if ((*ksip)->k == current)
> +				break;
> +		*ksip = (*ksip)->next;
> +		(*ksip)->next = NULL;
> +		mutex_unlock(&kthread_stop_lock);
> +
> +		ksi->err = ret;
> +		complete(&ksi->done);
>  	}
>  	return 0;
>  }
> @@ -199,26 +209,20 @@ EXPORT_SYMBOL(kthread_bind);
>  int kthread_stop(struct task_struct *k)
>  {
>  	int ret;
> +	struct kthread_stop_info ksi;
>  
>  	mutex_lock(&kthread_stop_lock);
>  
> -	/* It could exit after stop_info.k set, but before wake_up_process. */
> -	get_task_struct(k);
> +	init_completion(&ksi->done);
> +	ksi->k = k;
>  
> -	/* Must init completion *before* thread sees kthread_stop_info.k */
> -	init_completion(&kthread_stop_info.done);
> -	smp_wmb();
> -
> -	/* Now set kthread_should_stop() to true, and wake it up. */
> -	kthread_stop_info.k = k;
> +	set_bit(PF_EXITING, &k->flags);
>  	wake_up_process(k);
> -	put_task_struct(k);
> +	mutex_unlock(&kthread_stop_lock);
>  
> -	/* Once it dies, reset stop ptr, gather result and we're done. */
> -	wait_for_completion(&kthread_stop_info.done);
> -	kthread_stop_info.k = NULL;
> +	/* Once it dies gather result and we're done. */
> +	wait_for_completion(&ksi->done);
>  	ret = kthread_stop_info.err;
> -	mutex_unlock(&kthread_stop_lock);
>  
>  	return ret;
>  }


That looks reasonable to me, though I tend to find standard list
functions easier to follow...

The main reason I was going to add a field to the task_struct was
because I wanted to make sure that kthread_should_stop() was a quick
operation. If we can just use PF_EXITING then that's definitely a
better scheme.

-- 
Jeff Layton <jlayton@redhat.com>
