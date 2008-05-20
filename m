From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH REPOST2] svcrdma: Limit ORD based on client's
	advertised IRD
Date: Tue, 20 May 2008 17:29:54 -0500
Message-ID: <1211322594.12428.37.camel@trinity.ogc.int>
References: <1211242295.31725.95.camel@trinity.ogc.int>
	 <20080520212434.GF8177@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:46676 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934631AbYETW0T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 18:26:19 -0400
In-Reply-To: <20080520212434.GF8177@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-05-20 at 17:24 -0400, J. Bruce Fields wrote:
> On Mon, May 19, 2008 at 07:11:35PM -0500, Tom Tucker wrote:
> > When adapters have differing IRD limits, the RDMA transport will fail to
> > connect properly.
>  
> How will this look to the user?  Are they going to get some sort of
> mysterious failure when they try to mount, and then have to go echo
> lower values into /proc/sys/sunrpc/svc_rdma/max_outbound_read_requests
> until it works?

BTW, this is a hypothetical for iWARP. The last I checked, the current
spate of adapters seemed to work fine (Chelsio/Neteffect) because the
NFSRDMA default is supported by both. I'll check again and get back to
you.

Tom

> 
> > The RDMA transport should use the client's advertised
> > inbound read limit when computing its outbound read limit. For iWARP
> > transports, there is currently no standard for exchanging IRD/ORD
> > during connection establishment so the 'responder_resources' field in the
> > connect event is the local device's limit. The RDMA transport can be
> > configured to use a smaller ORD by writing the desired number to the
> > /proc/sys/sunrpc/svc_rdma/max_outbound_read_requests file.
> 
> Do we have any documentation on using these various sysctls?
> 
> --b.
> 
> >     
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> > This one includes the min_t change. This is nicer. Thanks Tom.
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 ++++++++++++----
> >  1 files changed, 12 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > index 68908b5..54b2126 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > @@ -580,7 +580,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
> >   * will call the recvfrom method on the listen xprt which will accept the new
> >   * connection.
> >   */
> > -static void handle_connect_req(struct rdma_cm_id *new_cma_id)
> > +static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)
> >  {
> >  	struct svcxprt_rdma *listen_xprt = new_cma_id->context;
> >  	struct svcxprt_rdma *newxprt;
> > @@ -597,6 +597,9 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id)
> >  	dprintk("svcrdma: Creating newxprt=%p, cm_id=%p, listenxprt=%p\n",
> >  		newxprt, newxprt->sc_cm_id, listen_xprt);
> >  
> > +	/* Save client advertised inbound read limit for use later in accept. */
> > +	newxprt->sc_ord = client_ird;
> > +
> >  	/* Set the local and remote addresses in the transport */
> >  	sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
> >  	svc_xprt_set_remote(&newxprt->sc_xprt, sa, svc_addr_len(sa));
> > @@ -633,7 +636,8 @@ static int rdma_listen_handler(struct rdma_cm_id *cma_id,
> >  	case RDMA_CM_EVENT_CONNECT_REQUEST:
> >  		dprintk("svcrdma: Connect request on cma_id=%p, xprt = %p, "
> >  			"event=%d\n", cma_id, cma_id->context, event->event);
> > -		handle_connect_req(cma_id);
> > +		handle_connect_req(cma_id,
> > +				   event->param.conn.responder_resources);
> >  		break;
> >  
> >  	case RDMA_CM_EVENT_ESTABLISHED:
> > @@ -807,8 +811,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
> >  				   (size_t)svcrdma_max_requests);
> >  	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
> >  
> > -	newxprt->sc_ord =  min((size_t)devattr.max_qp_rd_atom,
> > -			       (size_t)svcrdma_ord);
> > +	/*
> > +	 * Limit ORD based on client limit, local device limit, and
> > +	 * configured svcrdma limit.
> > +	 */
> > +	newxprt->sc_ord = min_t(size_t, devattr.max_qp_rd_atom, newxprt->sc_ord);
> > +	newxprt->sc_ord = min_t(size_t,	svcrdma_ord, newxprt->sc_ord);
> >  
> >  	newxprt->sc_pd = ib_alloc_pd(newxprt->sc_cm_id->device);
> >  	if (IS_ERR(newxprt->sc_pd)) {
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

