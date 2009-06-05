From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [pnfs] [RFC 14/39] nfs41: Implement NFSv4.1 callback service process.
Date: Fri, 5 Jun 2009 10:57:47 -0700
Message-ID: <273FE88A07F5D445824060902F7003440612B8AE@SACMVEXC1-PRD.hq.netapp.com>
References: <1244146681.5203.99.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13139 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756611AbZFESAf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2009 14:00:35 -0400
In-Reply-To: <1244146681.5203.99.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Myklebust, Trond
> Sent: Thursday, June 04, 2009 1:18 PM
> To: Benny Halevy
> Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
> Subject: Re: [pnfs] [RFC 14/39] nfs41: Implement NFSv4.1 callback
service
> process.
> 
> On Fri, 2009-05-01 at 02:21 +0300, Benny Halevy wrote:
> > From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> >
> > nfs41_callback_up() initializes the necessary queues and creates the
new
> > nfs41_callback_svc thread.  This thread executes the callback
service
> which
> > waits for requests to arrive on the svc_serv->sv_cb_list.
> >
> > NFS41_BC_MIN_CALLBACKS is set to 1 because we expect callbacks to
not
> > cause substantial latency.
> >
> > The actual processing of the callback will be implemented as a
separate
> patch.
> >
> > There is only one NFSv4.1 callback service.  The first caller of
> > nfs4_callback_up() creates the service, subsequent callers increment
a
> > reference count on the service.  The service is destroyed when the
last
> > caller invokes nfs_callback_down().
> >
> > The transport needs to hold a reference to the callback service in
order
> > to invoke it during callback processing.  Currently this reference
is
> only
> > obtained when the service is first created.  This is incorrect,
since
> > subsequent registrations for other transports will leave the
xprt->serv
> > pointer uninitialized, leading to an oops when a callback arrives on
> > the "unreferenced" transport.
> >
> > This patch fixes the problem by ensuring that a reference to the
service
> > is saved in xprt->serv, either because the service is created by
this
> > invocation to nfs4_callback_up() or by a prior invocation.
> >
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > [nfs41: Add a reference to svc_serv during callback service bring
up]
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> >  fs/nfs/callback.c          |   83
> ++++++++++++++++++++++++++++++++++++++++++-
> >  fs/nfs/callback.h          |    7 ++++
> >  include/linux/sunrpc/svc.h |    2 +
> >  3 files changed, 90 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index 3926046..9ee174c 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -17,6 +17,9 @@
> >  #include <linux/freezer.h>
> >  #include <linux/kthread.h>
> >  #include <linux/sunrpc/svcauth_gss.h>
> > +#if defined(CONFIG_NFS_V4_1)
> > +#include <linux/sunrpc/bc_xprt.h>
> > +#endif
> >
> >  #include <net/inet_sock.h>
> >
> > @@ -131,6 +134,69 @@ out_err:
> >  	return ERR_PTR(ret);
> >  }
> >
> > +#if defined(CONFIG_NFS_V4_1)
> > +/*
> > + * The callback service for NFSv4.1 callbacks
> > + */
> > +static int
> > +nfs41_callback_svc(void *vrqstp)
> > +{
> > +	struct svc_rqst *rqstp = vrqstp;
> > +	struct svc_serv *serv = rqstp->rq_server;
> > +	struct rpc_rqst *req;
> > +	int error;
> > +	DEFINE_WAIT(wq);
> > +
> > +	set_freezable();
> > +
> > +	/*
> > +	 * FIXME: do we really need to run this under the BKL? If so,
please
> > +	 * add a comment about what it's intended to protect.
> > +	 */
> > +	lock_kernel();
> > +	while (!kthread_should_stop()) {
> > +		prepare_to_wait(&serv->sv_cb_waitq, &wq,
TASK_INTERRUPTIBLE);
> > +		spin_lock_bh(&serv->sv_cb_lock);
> > +		if (!list_empty(&serv->sv_cb_list)) {
> > +			req = list_first_entry(&serv->sv_cb_list,
> > +					struct rpc_rqst, rq_bc_list);
> > +			list_del(&req->rq_bc_list);
> > +			spin_unlock_bh(&serv->sv_cb_lock);
> > +			dprintk("Invoking bc_svc_process()\n");
> > +			error = bc_svc_process(serv, req, rqstp);
> > +			dprintk("bc_svc_process() returned w/ error
code= %d\n",
> > +				error);
> > +		} else {
> > +			spin_unlock_bh(&serv->sv_cb_lock);
> > +			schedule();
> > +		}
> > +		finish_wait(&serv->sv_cb_waitq, &wq);
> > +	}
> > +	unlock_kernel();
> > +	nfs_callback_info.task = NULL;
> > +	svc_exit_thread(rqstp);
> > +	return 0;
> > +}
> > +
> > +/*
> > + * Bring up the NFSv4.1 callback service
> > + */
> > +struct svc_rqst *
> > +nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
> > +{
> > +	/*
> > +	 * Save the svc_serv in the transport so that it can
> > +	 * be referenced when the session backchannel is initialized
> > +	 */
> > +	xprt->bc_serv = serv;
> > +
> > +	INIT_LIST_HEAD(&serv->sv_cb_list);
> > +	spin_lock_init(&serv->sv_cb_lock);
> > +	init_waitqueue_head(&serv->sv_cb_waitq);
> > +	return svc_prepare_thread(serv, &serv->sv_pools[0]);
> > +}
> > +#endif /* CONFIG_NFS_V4_1 */
> > +
> >  /*
> >   * Bring up the callback thread if it is not already up.
> >   */
> > @@ -141,10 +207,18 @@ int nfs_callback_up(u32 minorversion, void
*args)
> >  	int (*callback_svc)(void *vrqstp);
> >  	char svc_name[12];
> >  	int ret = 0;
> > +#if defined(CONFIG_NFS_V4_1)
> > +	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
> > +#endif /* CONFIG_NFS_V4_1 */
> 
> More ugly embedded ifdefs...
> 
> >
> >  	mutex_lock(&nfs_callback_mutex);
> > -	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
> > +	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
{
> > +#if defined(CONFIG_NFS_V4_1)
> > +		if (minorversion)
> > +			xprt->bc_serv = nfs_callback_info.serv;
> > +#endif /* CONFIG_NFS_V4_1 */
> 
> Ditto
> 
> >  		goto out;
> > +	}
> >  	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
> NULL);
> >  	if (!serv) {
> >  		ret = -ENOMEM;
> > @@ -157,7 +231,12 @@ int nfs_callback_up(u32 minorversion, void
*args)
> >  		rqstp = nfs4_callback_up(serv);
> >  		callback_svc = nfs4_callback_svc;
> >  	} else {
> > -		BUG();	/* for now */
> > +#if defined(CONFIG_NFS_V4_1)
> > +		rqstp = nfs41_callback_up(serv, xprt);
> > +		callback_svc = nfs41_callback_svc;
> > +#else  /* CONFIG_NFS_V4_1 */
> > +		BUG();
> > +#endif /* CONFIG_NFS_V4_1 */
> 
> Ditto
> 
> >  	}
> >
> >  	if (IS_ERR(rqstp)) {
> > diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> > index 7f12e65..f2696ba 100644
> > --- a/fs/nfs/callback.h
> > +++ b/fs/nfs/callback.h
> > @@ -70,6 +70,13 @@ extern void nfs_callback_down(void);
> >  #define nfs_callback_down()	do {} while(0)
> >  #endif
> >
> > +/*
> > + * nfs41: Callbacks are expected to not cause substantial latency,
> > + * so we limit their concurrency to 1 by setting up the maximum
number
> > + * of slots for the backchannel.
> > + */
> > +#define NFS41_BC_MIN_CALLBACKS 1
> > +
> >  extern unsigned int nfs_callback_set_tcpport;
> >  extern unsigned short nfs_callback_tcpport;
> >  extern unsigned short nfs_callback_tcpport6;
> > diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> > index 4a8afbd..16043c4 100644
> > --- a/include/linux/sunrpc/svc.h
> > +++ b/include/linux/sunrpc/svc.h
> > @@ -419,6 +419,8 @@ int		   svc_set_num_threads(struct
svc_serv
> *, struct svc_pool *, int);
> >  int		   svc_pool_stats_open(struct svc_serv *serv,
struct file
> *file);
> >  void		   svc_destroy(struct svc_serv *);
> >  int		   svc_process(struct svc_rqst *);
> > +int		   bc_svc_process(struct svc_serv *, struct
rpc_rqst *,
> > +			struct svc_rqst *);
> 
> OK, I give up. Why is the function text and export declaration in one
> patch, while the declaration is in this patch?
> 

Will move this declaration to patch 13 along with the function and
export declaration.  Will also address the ifdefs.

- ricardo

> >  int		   svc_register(const struct svc_serv *, const
int,
> >  				const unsigned short, const unsigned
short);
> >
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
