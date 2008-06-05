From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/4] knfsd: Replace lock_kernel with a mutex for nfsd
	thread startup/shutdown locking.
Date: Thu, 5 Jun 2008 16:15:43 -0400
Message-ID: <20080605161543.33bebda9@tleilax.poochiereds.net>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
	<1212591796-22144-2-git-send-email-jlayton@redhat.com>
	<484737A9.508@melbourne.sgi.com>
	<20080605200358.GB5829@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080605200358.GB5829@fieldses.org>
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

On Thu, 5 Jun 2008 16:03:58 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jun 05, 2008 at 10:47:37AM +1000, Greg Banks wrote:
> > I notice there's no change to write_leasetime().  That calls
> > nfs4_reset_lease(), which seems to want to only be called when nfsd is
> > not started (according to my reading of the comment preceding the
> > function), and which uses the BKL to protect the variable
> > user_lease_time.  Perhaps that path should be changed to use the new
> > nfsd_mutex also?
> 
> write_leasetime() just results in setting the user_lease_time, which is
> copied (once, on server startup) to lease_time, which is what is
> actually used by the running server.  So I don't think there's a race
> here (and the existing BKL use in write_leasetime() isn't really
> needed).
> 
> --b.
> 

I think write_recoverydir might be a similar situation. It just sets
user_recovery_dirname, and that is also only read once when nfsd is
starting. We can probably eliminate the client_mutex locking around
that too.

Presuming that Bruce and I are correct, then I think I only need to
make sure that we add some nfsd_mutex locking to write_versions.

-- Jeff

> > 
> > Similarly with write_recoverydir().  That calls nfs4_reset_recoverydir()
> > which uses client_mutex to protect user_recovery_dirname[], but that
> > variable is only used during nfsd startup.  Perhaps that path should use
> > the new nfsd_mutex also?


> > > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > > index 941041f..040b3c2 100644
> > > --- a/fs/nfsd/nfssvc.c
> > > +++ b/fs/nfsd/nfssvc.c
> > > @@ -53,11 +53,27 @@
> > > @@ -190,13 +206,14 @@ void nfsd_reset_versions(void)
> > > @@ -223,7 +240,7 @@ int nfsd_create_serv(void)
> > > @@ -282,6 +299,8 @@ int nfsd_set_nrthreads(int n, int *nthreads)
> > > @@ -316,7 +335,6 @@ int nfsd_set_nrthreads(int n, int *nthreads)
> > > @@ -325,7 +343,6 @@ int nfsd_set_nrthreads(int n, int *nthreads)
> > > @@ -334,8 +351,8 @@ int
> > > @@ -363,7 +380,7 @@ nfsd_svc(unsigned short port, int nrservs)
> > > @@ -399,7 +416,7 @@ nfsd(struct svc_rqst *rqstp)
> > > @@ -417,11 +434,13 @@ nfsd(struct svc_rqst *rqstp)
> > > @@ -477,7 +496,7 @@ nfsd(struct svc_rqst *rqstp)
> > > @@ -486,7 +505,7 @@ out:
> > >   
> > All good.
> > > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > > index 01c7e31..7bffaff 100644
> > > --- a/net/sunrpc/svc.c
> > > +++ b/net/sunrpc/svc.c
> > > @@ -461,7 +461,8 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
> > > @@ -578,9 +579,10 @@ out_enomem:
> > > @@ -674,7 +676,7 @@ found_pool:
> > > @@ -722,7 +724,8 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
> > >   
> > 
> > All good.
> > 
> > -- 
> > Greg Banks, P.Engineer, SGI Australian Software Group.
> > The cake is *not* a lie.
> > I don't speak for SGI.
> > 
> > _______________________________________________
> > NFSv4 mailing list
> > NFSv4@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
