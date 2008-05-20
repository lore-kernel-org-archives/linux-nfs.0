From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove
	signaling for shutdown
Date: Tue, 20 May 2008 07:13:46 -0400
Message-ID: <20080520071346.26a549e3@tupile.poochiereds.net>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
	<18482.4782.858347.981553@notabene.brown>
	<20080519222457.6f24daa5@tupile.poochiereds.net>
	<18482.16837.381955.636390@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <18482.16837.381955.636390@notabene.brown>
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

On Tue, 20 May 2008 13:13:09 +1000
Neil Brown <neilb@suse.de> wrote:

> On Monday May 19, jlayton@redhat.com wrote:
> > 
> > I find all of the locking in rpc/nlm/nfs/nfsd *very* confusing. It's
> > always been explained to me that it's best to not use locking to
> > protect a section of code, but rather data structures. This makes it
> > easier to get the locking right when the code changes.
> 
> Absolutely.
> 
> > 
> > This is the problem we have now with the BKL. So much of
> > rpc/nlm/nfs/nfsd runs under it that it's nearly impossible to tell what
> > it's intended to actually protect. If we're going to start a push
> > toward BKL removal, my humble request is that we try to be as explicit
> > as possible about what locks protect what data structures.
> > 
> > So that's my question about this patch -- exactly what data is this new
> > mutex intended to protect?
> > 
> 
> Fair question.
> The new nfsd_mutex primarily protects "nfsd_serv", both the pointer
> itself and various members of the structure that it sometimes points
> to.
> In particular, ->sv_nrthreads but also to some extent sv_temp_socks
> and sv_permsocks.
> Also nfsdstats.th_cnt.
> 
> If (out side the lock) nfsd_serv is non-NULL, then it must point to
> a properly initialised 'struct svc_serv' with ->sv_nrthreads > 0, and
> that number of nfsd threads must exist and each must listed in
> ->sp_all_threads for exactly on ->sv_pools[].
> 
> The particular thing that the lock is protecting is transitions
> between 0 and non-0.  On these transitions, the svc_serv struct needs
> to be either created and initialised, or freed up.
> 

Thanks. That makes sense. It might not hurt to sprinkle in some
comments to this effect to help others who come along later. Also,
cleaning up the comments referencing the BKL as Greg suggests would
also be good...

> Having said all that, I think I see a race.
> When a new rqst is created at put on sp_all_threads, ->rq_task it not
> set and doesn't get set until the thread runs and gets the mutex.  So
> there is a brief hole when ->rq_task isn't set.  I don't know if that
> can cause a problem, but it feels wrong.

Yes, seems like that's depending on scheduler behavior so it could be
racy if that changes.

> When you switch to kthreads, you use the fact that kthread_create
> returns a task_struct, and assign that to ->rq_task in
> __svc_create_thread instead of nfsd, which will close that hole.
> 

My original patch used that to set the rq_task, so I'll plan to do that
for the respin too. 

> If you look in nfsctl.c, you will probably be able to find plenty of
> places where nfsd_serv is dereferenced without any locking.  These are
> all wrong and need fixing.
> 

I'll keep an eye out for them. Since you're working on this locking
patch, I'll plan to resubmit the kthread conversion after you've got
it complete so I can base it on top of it.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
