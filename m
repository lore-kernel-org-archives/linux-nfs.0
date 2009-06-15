From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: RE: [PATCH 08/14] SQUASHME: Removal of ugly #ifdefs
Date: Mon, 15 Jun 2009 12:59:49 -0400
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C554@daytona.int.panasas.com>
References: <273FE88A07F5D445824060902F70034406334CCD@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	<pnfs@linux-nfs.org>, <linux-nfs@vger.kernel.org>
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:19975
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751275AbZFOREO convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 13:04:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> There are two lines in common between the #ifdef and #else case.
> 
> +	*rqstpp = nfs4_callback_up(serv);
> +	*callback_svc = nfs4_callback_svc;

In the function body...
There's also the function's header.

> 
> Calling it code duplication is a bit of a stretch :-)

I agree it isn't much but still any change you will make
in the future will have to bapplied on both copies and that's bad (IMO).

Benny

> 
> - ricardo

-----Original Message-----
From: Labiaga, Ricardo [mailto:Ricardo.Labiaga@netapp.com]
Sent: Mon 2009-06-15 18:31
To: Halevy, Benny
Cc: Myklebust, Trond; pnfs@linux-nfs.org; linux-nfs@vger.kernel.org
Subject: RE: [PATCH 08/14] SQUASHME: Removal of ugly #ifdefs
 
> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@panasas.com]
> Sent: Sunday, June 14, 2009 7:30 AM
> To: Labiaga, Ricardo
> Cc: Myklebust, Trond; pnfs@linux-nfs.org; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 08/14] SQUASHME: Removal of ugly #ifdefs
> 
> On Jun. 12, 2009, 1:54 -0400, Ricardo Labiaga
<Ricardo.Labiaga@netapp.com>
> wrote:
> > [squash with: nfs41: Implement NFSv4.1 callback service process]
> >
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > ---
> >  fs/nfs/callback.c |   50
+++++++++++++++++++++++++++++++++++-----------
> ----
> >  1 files changed, 35 insertions(+), 15 deletions(-)
> >
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index 4395c96..116424e 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -209,6 +209,39 @@ out:
> >  	dprintk("--> %s return %p\n", __func__, rqstp);
> >  	return rqstp;
> >  }
> > +
> > +static inline void nfs_callback_svc_setup(u32 minorversion,
> > +		struct svc_serv *serv, struct rpc_xprt *xprt,
> > +		struct svc_rqst **rqstpp, int (**callback_svc)(void
*vrqstp))
> > +{
> > +	if (minorversion) {
> > +		*rqstpp = nfs41_callback_up(serv, xprt);
> > +		*callback_svc = nfs41_callback_svc;
> > +	} else {
> > +		*rqstpp = nfs4_callback_up(serv);
> > +		*callback_svc = nfs4_callback_svc;
> > +	}
> > +}
> > +
> > +static inline void nfs_callback_bc_serv(u32 minorversion, struct
> rpc_xprt *xprt,
> > +		struct nfs_callback_data *cb_info)
> > +{
> > +	if (minorversion)
> > +		xprt->bc_serv = cb_info->serv;
> > +}
> > +#else
> > +static inline void nfs_callback_svc_setup(u32 minorversion,
> > +		struct svc_serv *serv, struct rpc_xprt *xprt,
> > +		struct svc_rqst **rqstpp, int (**callback_svc)(void
*vrqstp))
> > +{
> > +	*rqstpp = nfs4_callback_up(serv);
> > +	*callback_svc = nfs4_callback_svc;
> > +}
> > +
> > +static inline void nfs_callback_bc_serv(u32 minorversion, struct
> rpc_xprt *xprt,
> > +		struct nfs_callback_data *cb_info)
> > +{
> > +}
> >  #endif /* CONFIG_NFS_V4_1 */
> 
> Although this removes the ungly #ifdefs from inside nfs_callback_up
> it just introduces them elsewhere and what's worse, it adds code
> duplication which is even more unreadable and harder to maintain.
> 

There are two lines in common between the #ifdef and #else case.

+	*rqstpp = nfs4_callback_up(serv);
+	*callback_svc = nfs4_callback_svc;

Calling it code duplication is a bit of a stretch :-)

- ricardo

> How about something along these line?
> 
> static inline void nfs_callback_svc_setup(u32 minorversion,
> 		struct svc_serv *serv, struct rpc_xprt *xprt,
> 		struct svc_rqst **rqstpp, int (**callback_svc)(void
*vrqstp))
> {
> #ifdef CONFIG_NFS_V4_1
> 	if (minorversion) {
> 		*rqstpp = nfs41_callback_up(serv, xprt);
> 		*callback_svc = nfs41_callback_svc;
> 		return;
> 	}
> #endif /* CONFIG_NFS_V4_1 */
> 	*rqstpp = nfs4_callback_up(serv);
> 	*callback_svc = nfs4_callback_svc;
> }
> 
> static inline void nfs_callback_bc_serv(u32 minorversion, struct
rpc_xprt
> *xprt,
> 		struct nfs_callback_data *cb_info)
> {
> #ifdef CONFIG_NFS_V4_1
> 	if (minorversion)
> 		xprt->bc_serv = cb_info->serv;
> #endif /* CONFIG_NFS_V4_1 */
> }
> 
> Benny
> 
> >
> >  /*
> > @@ -225,10 +258,7 @@ int nfs_callback_up(u32 minorversion, struct
> rpc_xprt *xprt)
> >
> >  	mutex_lock(&nfs_callback_mutex);
> >  	if (cb_info->users++ || cb_info->task != NULL) {
> > -#if defined(CONFIG_NFS_V4_1)
> > -		if (minorversion)
> > -			xprt->bc_serv = cb_info->serv;
> > -#endif /* CONFIG_NFS_V4_1 */
> > +		nfs_callback_bc_serv(minorversion, xprt, cb_info);
> >  		goto out;
> >  	}
> >  	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
> NULL);
> > @@ -239,17 +269,7 @@ int nfs_callback_up(u32 minorversion, struct
> rpc_xprt *xprt)
> >
> >  	/* FIXME: either 4.0 or 4.1 callback service can be up at a time
> >  	 * need to monitor and control them both */
> > -	if (!minorversion) {
> > -		rqstp = nfs4_callback_up(serv);
> > -		callback_svc = nfs4_callback_svc;
> > -	} else {
> > -#if defined(CONFIG_NFS_V4_1)
> > -		rqstp = nfs41_callback_up(serv, xprt);
> > -		callback_svc = nfs41_callback_svc;
> > -#else  /* CONFIG_NFS_V4_1 */
> > -		BUG();
> > -#endif /* CONFIG_NFS_V4_1 */
> > -	}
> > +	nfs_callback_svc_setup(minorversion, serv, xprt, &rqstp,
> &callback_svc);
> >
> >  	if (IS_ERR(rqstp)) {
> >  		ret = PTR_ERR(rqstp);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

