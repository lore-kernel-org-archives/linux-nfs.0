From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] lockd: convert reclaimer thread to kthread interface
Date: Mon, 3 Nov 2008 17:28:50 -0500
Message-ID: <20081103172850.7d935783@tleilax.poochiereds.net>
References: <1225278945-15407-1-git-send-email-jlayton@redhat.com>
	<20081103131215.75a83236.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, hch@infradead.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39421 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbYKCW32 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2008 17:29:28 -0500
In-Reply-To: <20081103131215.75a83236.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 3 Nov 2008 13:12:15 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 29 Oct 2008 07:15:45 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > My understanding is that there is a push to turn the kernel_thread
> > interface into a non-exported symbol and move all kernel threads to use
> > the kthread API. This patch changes lockd to use kthread_run to spawn
> > the reclaimer thread.
> > 
> > I've made the assumption here that the extra module references taken
> > when we spawn this thread are unnecessary and removed them. I've also
> > added a KERN_ERR printk that pops if the thread can't be spawned to warn
> > the admin that the locks won't be reclaimed.
> > 
> > I consider this patch 2.6.29 material.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/lockd/clntlock.c |   14 +++++++++-----
> >  1 files changed, 9 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
> > index 8307dd6..fcc2378 100644
> > --- a/fs/lockd/clntlock.c
> > +++ b/fs/lockd/clntlock.c
> > @@ -14,6 +14,7 @@
> >  #include <linux/sunrpc/svc.h>
> >  #include <linux/lockd/lockd.h>
> >  #include <linux/smp_lock.h>
> > +#include <linux/kthread.h>
> >  
> >  #define NLMDBG_FACILITY		NLMDBG_CLIENT
> >  
> > @@ -191,11 +192,15 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
> >  void
> >  nlmclnt_recovery(struct nlm_host *host)
> >  {
> > +	struct task_struct *task;
> > +
> >  	if (!host->h_reclaiming++) {
> >  		nlm_get_host(host);
> > -		__module_get(THIS_MODULE);
> > -		if (kernel_thread(reclaimer, host, CLONE_FS | CLONE_FILES) < 0)
> > -			module_put(THIS_MODULE);
> > +		task = kthread_run(reclaimer, host, "%s-reclaim", host->h_name);
> > +		if (IS_ERR(task))
> > +			printk(KERN_ERR "lockd: unable to spawn reclaimer "
> > +				"thread. Locks for %s won't be reclaimed! "
> > +				"(%ld)\n", host->h_name, PTR_ERR(task));
> >  	}
> >  }
> >  
> > @@ -207,7 +212,6 @@ reclaimer(void *ptr)
> >  	struct file_lock *fl, *next;
> >  	u32 nsmstate;
> >  
> > -	daemonize("%s-reclaim", host->h_name);
> >  	allow_signal(SIGKILL);
> >  
> >  	down_write(&host->h_rwsem);
> > @@ -261,5 +265,5 @@ restart:
> >  	nlm_release_host(host);
> >  	lockd_down();
> >  	unlock_kernel();
> > -	module_put_and_exit(0);
> > +	return 0;
> >  }
> 
> Looks OK to me.  I assume the SIGKILL handling has been carefully tested?
> 

Not by me, though I don't think this patch will make that any better or
worse. It should just change how the thread is spawned. My testing
mostly consisted of making sure that we could reclaim locks after this
was applied.

> 
> Is it correct to emit a warning and keep going if the thread didn't
> start?  Or would it be safer&saner to fail the whole mount (or whatever
> syscall we're doing here..)
> 
> 
> 
> I see this:
> 
> 	/* Why are we leaking memory here? --okir */
> 	if (signalled())
> 		continue;
> 
> is that still true?  It seems unlikely that what appears to be a pretty
> gross leak has been around for so long.
> 

Well, just before that we do this:

    list_del_init(&fl->fl_u.nfs_fl.list);

...and a little while after, we do this:

    list_add_tail(&fl->fl_u.nfs_fl.list, &host->h_granted);

...so I assume the fact that the fl doesn't end up back on a list if
we're signalled is the problem. If so, then yes, it does look like we're
still leaking memory there.

I've never heard of anyone needing to signal the reclaimer thread, so
maybe we should just make it ignore all signals?

> This code needs some BKL-removal love.

Yep. All of lockd does, though IIRC that's held up by dependencies on
the BKL in generic VFS locking code. Pulling the BKL out of lockd is
probably going to be painful since it's almost surely hiding some
races.

-- 
Jeff Layton <jlayton@redhat.com>
