From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/5] knfsd: convert knfsd to kthread API
Date: Fri, 6 Jun 2008 14:11:16 -0400
Message-ID: <20080606141116.07b79b14@tleilax.poochiereds.net>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
	<1212765171-26042-2-git-send-email-jlayton@redhat.com>
	<1212765171-26042-3-git-send-email-jlayton@redhat.com>
	<1212765171-26042-4-git-send-email-jlayton@redhat.com>
	<1212765171-26042-5-git-send-email-jlayton@redhat.com>
	<20080606172431.GA761@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080606172431.GA761@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 6 Jun 2008 13:24:31 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jun 06, 2008 at 11:12:50AM -0400, Jeff Layton wrote:
> > This patch is rather large, but I couldn't figure out a way to break it
> > up that would remain bisectable. It does several things:
> > 
> > - change svc_thread_fn typedef to better match what kthread_create expects
> > - change svc_pool_map_set_cpumask to be more kthread friendly. Make it
> >   take a task arg and and get rid of the "oldmask"
> > - have svc_set_num_threads call kthread_create directly
> > - eliminate __svc_create_thread
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfssvc.c           |   52 ++++++++++++++--------
> >  include/linux/sunrpc/svc.h |    2 +-
> >  net/sunrpc/svc.c           |  102 +++++++++++++++-----------------------------
> >  3 files changed, 68 insertions(+), 88 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > index 6339cb7..fe62ec8 100644
> > --- a/fs/nfsd/nfssvc.c
> > +++ b/fs/nfsd/nfssvc.c
> > @@ -21,6 +21,7 @@
> >  #include <linux/smp_lock.h>
> >  #include <linux/freezer.h>
> >  #include <linux/fs_struct.h>
> > +#include <linux/kthread.h>
> >  
> >  #include <linux/sunrpc/types.h>
> >  #include <linux/sunrpc/stats.h>
> > @@ -46,7 +47,7 @@
> >  #define SHUTDOWN_SIGS	(sigmask(SIGKILL) | sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT))
> >  
> >  extern struct svc_program	nfsd_program;
> > -static void			nfsd(struct svc_rqst *rqstp);
> > +static int			nfsd(void *vrqstp);
> >  struct timeval			nfssvc_boot;
> >  static atomic_t			nfsd_busy;
> >  static unsigned long		nfsd_last_call;
> > @@ -407,18 +408,19 @@ update_thread_usage(int busy_threads)
> >  /*
> >   * This is the NFS server kernel thread
> >   */
> > -static void
> > -nfsd(struct svc_rqst *rqstp)
> > +static int
> > +nfsd(void *vrqstp)
> >  {
> > +	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
> >  	struct fs_struct *fsp;
> > -	int		err;
> >  	sigset_t shutdown_mask, allowed_mask;
> > +	int err, preverr = 0;
> > +	unsigned int signo;
> >  
> >  	/* Lock module and set up kernel thread */
> >  	mutex_lock(&nfsd_mutex);
> > -	daemonize("nfsd");
> >  
> > -	/* After daemonize() this kernel thread shares current->fs
> > +	/* At this point, the thread shares current->fs
> >  	 * with the init process. We need to create files with a
> >  	 * umask of 0 instead of init's umask. */
> >  	fsp = copy_fs_struct(current->fs);
> > @@ -433,14 +435,18 @@ nfsd(struct svc_rqst *rqstp)
> >  	siginitsetinv(&shutdown_mask, SHUTDOWN_SIGS);
> >  	siginitsetinv(&allowed_mask, ALLOWED_SIGS);
> >  
> > +	/*
> > +	 * thread is spawned with all signals set to SIG_IGN, re-enable
> > +	 * the ones that matter
> > +	 */
> > +	for (signo = 1; signo <= _NSIG; signo++) {
> > +		if (!sigismember(&shutdown_mask, signo))
> > +			allow_signal(signo);
> > +	}
> >  
> >  	nfsdstats.th_cnt++;
> > -
> > -	rqstp->rq_task = current;
> > -
> >  	mutex_unlock(&nfsd_mutex);
> >  
> > -
> >  	/*
> >  	 * We want less throttling in balance_dirty_pages() so that nfs to
> >  	 * localhost doesn't cause nfsd to lock up due to all the client's
> > @@ -462,15 +468,25 @@ nfsd(struct svc_rqst *rqstp)
> >  		 */
> >  		while ((err = svc_recv(rqstp, 60*60*HZ)) == -EAGAIN)
> >  			;
> > -		if (err < 0)
> > +		if (err == -EINTR)
> >  			break;
> > +		else if (err < 0) {
> > +			if (err != preverr) {
> > +				printk(KERN_WARNING "%s: unexpected error "
> > +					"from svc_recv (%d)\n", __func__, -err);
> > +				preverr = err;
> > +			}
> > +			schedule_timeout_uninterruptible(HZ);
> > +			continue;
> > +		}
> > +
> >  		update_thread_usage(atomic_read(&nfsd_busy));
> >  		atomic_inc(&nfsd_busy);
> >  
> >  		/* Lock the export hash tables for reading. */
> >  		exp_readlock();
> >  
> > -		/* Process request with signals blocked.  */
> > +		/* Process request with signals blocked. */
> >  		sigprocmask(SIG_SETMASK, &allowed_mask, NULL);
> >  
> >  		svc_process(rqstp);
> > @@ -479,25 +495,23 @@ nfsd(struct svc_rqst *rqstp)
> >  		exp_readunlock();
> >  		update_thread_usage(atomic_read(&nfsd_busy));
> >  		atomic_dec(&nfsd_busy);
> > -	}
> >  
> > -	if (err != -EINTR)
> > -		printk(KERN_WARNING "nfsd: terminating on error %d\n", -err);
> > +		/* reset err in case kthread_stop is called */
> > +		err = 0;
> > +	}
> 
> There's no use of err here until it's next set in
> 
> 	while ((err = svc_recv(rqstp, 60*60*HZ)) == -EAGAIN)
> 
> so I assume the comment and this "err = 0" are artifacts of a previous
> implementation.
> 

That's correct. An earlier patch has the main loop as
"while(!kthread_should_stop())". Since we're using signals to take the
thread down though, there's not much point in checking
kthread_should_stop(). I can remove the "err = 0;" there.

> >  
> >  	/* Clear signals before calling svc_exit_thread() */
> >  	flush_signals(current);
> >  
> >  	mutex_lock(&nfsd_mutex);
> > -
> >  	nfsdstats.th_cnt --;
> >  
> >  out:
> >  	/* Release the thread */
> >  	svc_exit_thread(rqstp);
> > -
> > -	/* Release module */
> >  	mutex_unlock(&nfsd_mutex);
> > -	module_put_and_exit(0);
> 
> How does the module refcounting work after this patch?
> 
> --b.
> 

I think I've goofed this part, actually. I was thinking that we didn't
need to bump the refcount here, and that the kernel would realize that
nfsd() hadn't returned and would prevent unloading until it had. This
doesn't seem to be the case. I'll need to go back and add refcounting
back in.

-- 
Jeff Layton <jlayton@redhat.com>
