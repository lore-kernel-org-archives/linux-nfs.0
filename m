Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47889 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab0LXRBK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Dec 2010 12:01:10 -0500
Date: Fri, 24 Dec 2010 12:01:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V5 01/11] SUNRPC move svc_drop to caller of
 svc_process_common
Message-ID: <20101224170106.GB2889@fieldses.org>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <20101221182305.GA19349@fieldses.org>
 <273FE88A07F5D445824060902F7003440E68B924@SACMVEXC1-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <273FE88A07F5D445824060902F7003440E68B924@SACMVEXC1-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 23, 2010 at 07:43:07PM -0800, Labiaga, Ricardo wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Tuesday, December 21, 2010 10:23 AM
> > To: Adamson, Andy
> > Cc: Myklebust, Trond; bfields@redhat.com; linux-nfs@vger.kernel.org
> > Subject: Re: [PATCH_V5 01/11] SUNRPC move svc_drop to caller of
> > svc_process_common
> > 
> > On Mon, Dec 20, 2010 at 04:04:38PM -0500, andros@netapp.com wrote:
> > > From: Andy Adamson <andros@netapp.com>
> > >
> > > The NFSv4.1 shared back channel does not need to call svc_drop
> > because the
> > > callback service never outlives the single connection it services,
> > and it
> > > reuses it's buffers and keeps the trasport.
> > 
> > Looks better....
> > 
> > > Signed-off-by: Andy Adamson <andros@netapp.com>
> > > ---
> > >  net/sunrpc/svc.c |   30 ++++++++++++++++--------------
> > >  1 files changed, 16 insertions(+), 14 deletions(-)
> > >
> > > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > > index 6359c42..606d182 100644
> > > --- a/net/sunrpc/svc.c
> > > +++ b/net/sunrpc/svc.c
> > > @@ -1147,7 +1147,6 @@ svc_process_common(struct svc_rqst *rqstp,
> > struct kvec *argv, struct kvec *resv)
> > >   dropit:
> > >  	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
> > >  	dprintk("svc: svc_process dropit\n");
> > > -	svc_drop(rqstp);
> > >  	return 0;
> > >
> > >  err_short_len:
> > > @@ -1218,7 +1217,6 @@ svc_process(struct svc_rqst *rqstp)
> > >  	struct kvec		*resv = &rqstp->rq_res.head[0];
> > >  	struct svc_serv		*serv = rqstp->rq_server;
> > >  	u32			dir;
> > > -	int			error;
> > >
> > >  	/*
> > >  	 * Setup response xdr_buf.
> > > @@ -1246,11 +1244,13 @@ svc_process(struct svc_rqst *rqstp)
> > >  		return 0;
> > >  	}
> > >
> > > -	error = svc_process_common(rqstp, argv, resv);
> > > -	if (error <= 0)
> > 
> > Oh, and that was pretty ugly, seeing as svc_process_common never
> > returned <0.  Thanks for cleaning that up.
> > 
> > > -		return error;
> > > -
> > > -	return svc_send(rqstp);
> > > +	/* Returns 1 for send, 0 for drop */
> > > +	if (svc_process_common(rqstp, argv, resv))
> > > +		return svc_send(rqstp);
> > > +	else {
> > > +		svc_drop(rqstp);
> > > +		return 0;
> > > +	}
> > >  }
> > >
> > >  #if defined(CONFIG_NFS_V4_1)
> > > @@ -1264,7 +1264,6 @@ bc_svc_process(struct svc_serv *serv, struct
> > rpc_rqst *req,
> > >  {
> > >  	struct kvec	*argv = &rqstp->rq_arg.head[0];
> > >  	struct kvec	*resv = &rqstp->rq_res.head[0];
> > > -	int 		error;
> > >
> > >  	/* Build the svc_rqst used by the common processing routine */
> > >  	rqstp->rq_xprt = serv->bc_xprt;
> > > @@ -1292,12 +1291,15 @@ bc_svc_process(struct svc_serv *serv, struct
> > rpc_rqst *req,
> > >  	svc_getu32(argv);	/* XID */
> > >  	svc_getnl(argv);	/* CALLDIR */
> > >
> > > -	error = svc_process_common(rqstp, argv, resv);
> > > -	if (error <= 0)
> > > -		return error;
> > > -
> > > -	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req-
> > >rq_snd_buf));
> > > -	return bc_send(req);
> > > +	/* Returns 1 for send, 0 for drop */
> > > +	if (svc_process_common(rqstp, argv, resv)) {
> > > +		memcpy(&req->rq_snd_buf, &rqstp->rq_res,
> > > +
> sizeof(req->rq_snd_buf));
> > > +		return bc_send(req);
> > > +	} else {
> > > +		/* Nothing to do to drop request */
> > > +		return 0;
> > 
> > The one thing that bothers me is the svc_reserve stuff.  Which you
> have
> > no use for, I guess.  But svc_reserve_auth() is called from
> > svc_process_common(); I wonder if that can get us into trouble?  I'll
> > look a little closer.
> > 	
> 
> The callback request arrives on the backchannel and is placed in a
> preallocated 'struct rpc_rqst'.  bc_svc_process() is then called, which
> populates the 'struct svc_rqst' rq_arg and rq_res from the 'struct
> rpc_rqst' send and receive buffers.  So the reply buffer is independent
> of any other request on the forechannel or backchannel.
> 
> The space reserved for the 'struct svc_rqst' will be 0 when
> svc_reserve() is called, so it should not call svc_xprt_enqueue().
> 
> So I think we're okay, but I'm not sure what has you concerned.

No, I think you're right, if rq_reserved is initialized to zero then I
can't see what would go wrong.

--b.
