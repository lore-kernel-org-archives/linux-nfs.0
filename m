From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH - take 2] knfsd: nfsd: Handle ERESTARTSYS from
	syscalls. (and possible kthread_stop changes)
Date: Mon, 30 Jun 2008 15:29:51 -0400
Message-ID: <20080630192951.GC6502@fieldses.org>
References: <1080619001109.24338@suse.de> <20080618210947.2110a541@tleilax.poochiereds.net> <18521.50300.572838.123366@notabene.brown> <20080619063824.00ca6381@tleilax.poochiereds.net> <18526.60523.584503.68076@notabene.brown> <20080622205244.261a787d@tleilax.poochiereds.net> <18528.14347.525397.917553@notabene.brown> <20080630083536.680b093a@barsoom.rdu.redhat.com> <20080630171019.GA4877@fieldses.org> <20080630140946.34154d4c@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33714 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344AbYF3T3z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2008 15:29:55 -0400
In-Reply-To: <20080630140946.34154d4c-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 02:09:46PM -0400, Jeff Layton wrote:
> On Mon, 30 Jun 2008 13:10:19 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jun 30, 2008 at 08:35:36AM -0400, Jeff Layton wrote:
> > > The idea looks reasonable, but the patch above doesn't apply to Bruce's
> > > for-2.6.27 tree. The nfsd() function has changed a bit. Actually, I
> > > think we can make this even simpler. kthreads start with all signals
> > > ignored and the new patch enables all of the ones in SHUTDOWN_SIGS. So
> > > I don't think we need any signal masking at all.
> > > 
> > > How about this patch? It should apply on top of the patchset already
> > > in Bruce's tree.
> > 
> > Looks reasonable to me; applied for 2.6.27 barring any test failures or
> > objections.
> > 
> > --b.
> > 
> 
> Actually, here's an even simpler version. How about we just get rid of
> the loop and just have a series of allow_signal() calls. We can get
> rid of a local variable that way and since we're only referencing
> SHUTDOWN_SIGS once, I don't see any reason to keep it around.

Yep, it's one less definition to track down when you read the code....
Thanks!

--b.

> 
> -------[snip]-----------
> 
> knfsd: treat all shutdown signals as equivalent
> 
> knfsd currently uses 2 signal masks when processing requests. A "loose"
> mask (SHUTDOWN_SIGS) that it uses when receiving network requests, and
> then a more "strict" mask (ALLOWED_SIGS, which is just SIGKILL) that it
> allows when doing the actual operation on the local storage.
> 
> This is apparently unnecessarily complicated. The underlying filesystem
> should be able to sanely handle a signal in the middle of an operation.
> This patch removes the signal mask handling from knfsd altogether. When
> knfsd is started as a kthread, all signals are ignored. It then allows
> all of the signals in SHUTDOWN_SIGS. There's no need to set the mask
> as well.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfssvc.c |   30 +++++-------------------------
>  1 files changed, 5 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 96fdbca..80292ff 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -37,15 +37,6 @@
>  
>  #define NFSDDBG_FACILITY	NFSDDBG_SVC
>  
> -/* these signals will be delivered to an nfsd thread 
> - * when handling a request
> - */
> -#define ALLOWED_SIGS	(sigmask(SIGKILL))
> -/* these signals will be delivered to an nfsd thread
> - * when not handling a request. i.e. when waiting
> - */
> -#define SHUTDOWN_SIGS	(sigmask(SIGKILL) | sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT))
> -
>  extern struct svc_program	nfsd_program;
>  static int			nfsd(void *vrqstp);
>  struct timeval			nfssvc_boot;
> @@ -414,9 +405,7 @@ nfsd(void *vrqstp)
>  {
>  	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
>  	struct fs_struct *fsp;
> -	sigset_t shutdown_mask, allowed_mask;
>  	int err, preverr = 0;
> -	unsigned int signo;
>  
>  	/* Lock module and set up kernel thread */
>  	mutex_lock(&nfsd_mutex);
> @@ -433,17 +422,14 @@ nfsd(void *vrqstp)
>  	current->fs = fsp;
>  	current->fs->umask = 0;
>  
> -	siginitsetinv(&shutdown_mask, SHUTDOWN_SIGS);
> -	siginitsetinv(&allowed_mask, ALLOWED_SIGS);
> -
>  	/*
>  	 * thread is spawned with all signals set to SIG_IGN, re-enable
> -	 * the ones that matter
> +	 * the ones that will bring down the thread
>  	 */
> -	for (signo = 1; signo <= _NSIG; signo++) {
> -		if (!sigismember(&shutdown_mask, signo))
> -			allow_signal(signo);
> -	}
> +	allow_signal(SIGKILL);
> +	allow_signal(SIGHUP);
> +	allow_signal(SIGINT);
> +	allow_signal(SIGQUIT);
>  
>  	nfsdstats.th_cnt++;
>  	mutex_unlock(&nfsd_mutex);
> @@ -460,9 +446,6 @@ nfsd(void *vrqstp)
>  	 * The main request loop
>  	 */
>  	for (;;) {
> -		/* Block all but the shutdown signals */
> -		sigprocmask(SIG_SETMASK, &shutdown_mask, NULL);
> -
>  		/*
>  		 * Find a socket with data available and call its
>  		 * recvfrom routine.
> @@ -487,9 +470,6 @@ nfsd(void *vrqstp)
>  		/* Lock the export hash tables for reading. */
>  		exp_readlock();
>  
> -		/* Process request with signals blocked. */
> -		sigprocmask(SIG_SETMASK, &allowed_mask, NULL);
> -
>  		svc_process(rqstp);
>  
>  		/* Unlock export hash tables */
> -- 
> 1.5.5.1
> 
