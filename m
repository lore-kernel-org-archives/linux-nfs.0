From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RE: [pnfs] [RFC 09/39] nfs41: New xs_tcp_read_data()
Date: Fri, 05 Jun 2009 12:56:15 -0400
Message-ID: <1244220975.5410.47.camel@heimdal.trondhjem.org>
References: <273FE88A07F5D445824060902F7003440612B810@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17532 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755610AbZFEQ4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 12:56:19 -0400
In-Reply-To: <273FE88A07F5D445824060902F7003440612B810-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-06-05 at 09:44 -0700, Labiaga, Ricardo wrote:
> > -----Original Message-----
> > From: Myklebust, Trond
> > Sent: Thursday, June 04, 2009 12:40 PM
> > To: Benny Halevy
> > Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
> > Subject: Re: [pnfs] [RFC 09/39] nfs41: New xs_tcp_read_data()
> > 
> > On Fri, 2009-05-01 at 02:20 +0300, Benny Halevy wrote:
> > > From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > >
> > > Handles RPC replies and backchannel callbacks.  Traditionally the
> NFS
> > > client has expected only RPC replies on its open connections.  With
> > > NFSv4.1, callbacks can arrive over an existing open connection.
> > >
> > > This patch refactors the old xs_tcp_read_request() into an RPC reply
> > handler:
> > > xs_tcp_read_reply(), a new backchannel callback handler:
> > xs_tcp_read_callback(),
> > > and a common routine to read the data off the transport:
> > xs_tcp_read_common().
> > > The new xs_tcp_read_callback() queues callback requests onto a queue
> > where
> > > the callback service (a separate thread) is listening for the
> > processing.
> > >
> > > This patch incorporates work and suggestions from Rahul Iyer
> > (iyer@netapp.com)
> > > and Benny Halevy (bhalevy@panasas.com).
> > >
> > > [nfs41: Keep track of RPC call/reply direction with a flag]
> > > [nfs41: Preallocate rpc_rqst receive buffer for handling callbacks]
> > > Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> > > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > > ---
> > >  net/sunrpc/xprtsock.c |  141
> > ++++++++++++++++++++++++++++++++++++++++++------
> > >  1 files changed, 123 insertions(+), 18 deletions(-)
> > >
> > > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > > index 692b517..403ebda 100644
> > > --- a/net/sunrpc/xprtsock.c
> > > +++ b/net/sunrpc/xprtsock.c
> > > @@ -34,6 +34,9 @@
> > >  #include <linux/sunrpc/sched.h>
> > >  #include <linux/sunrpc/xprtsock.h>
> > >  #include <linux/file.h>
> > > +#ifdef CONFIG_NFS_V4_1
> > > +#include <linux/sunrpc/bc_xprt.h>
> > > +#endif
> > >
> > >  #include <net/sock.h>
> > >  #include <net/checksum.h>
> > > @@ -1028,25 +1031,16 @@ static inline void
> xs_tcp_read_calldir(struct
> > sock_xprt *transport,
> > >  	xs_tcp_check_fraghdr(transport);
> > >  }
> > >
> > > -static inline void xs_tcp_read_request(struct rpc_xprt *xprt,
> struct
> > xdr_skb_reader *desc)
> > > +static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
> > > +				     struct xdr_skb_reader *desc,
> > > +				     struct rpc_rqst *req)
> > >  {
> > > -	struct sock_xprt *transport = container_of(xprt, struct
> sock_xprt,
> > xprt);
> > > -	struct rpc_rqst *req;
> > > +	struct sock_xprt *transport =
> > > +				container_of(xprt, struct sock_xprt,
> xprt);
> > >  	struct xdr_buf *rcvbuf;
> > >  	size_t len;
> > >  	ssize_t r;
> > >
> > > -	/* Find and lock the request corresponding to this xid */
> > > -	spin_lock(&xprt->transport_lock);
> > > -	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
> > > -	if (!req) {
> > > -		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
> > > -		dprintk("RPC:       XID %08x request not found!\n",
> > > -				ntohl(transport->tcp_xid));
> > > -		spin_unlock(&xprt->transport_lock);
> > > -		return;
> > > -	}
> > > -
> > >  	rcvbuf = &req->rq_private_buf;
> > >  	len = desc->count;
> > >  	if (len > transport->tcp_reclen - transport->tcp_offset) {
> > > @@ -1084,7 +1078,7 @@ static inline void xs_tcp_read_request(struct
> > rpc_xprt *xprt, struct xdr_skb_rea
> > >  				"tcp_offset = %u, tcp_reclen = %u\n",
> > >  				xprt, transport->tcp_copied,
> > >  				transport->tcp_offset,
> transport->tcp_reclen);
> > > -		goto out;
> > > +		return;
> > >  	}
> > >
> > >  	dprintk("RPC:       XID %08x read %Zd bytes\n",
> > > @@ -1100,11 +1094,122 @@ static inline void
> xs_tcp_read_request(struct
> > rpc_xprt *xprt, struct xdr_skb_rea
> > >  			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
> > >  	}
> > >
> > > -out:
> > > +	return;
> > > +}
> > > +
> > > +/*
> > > + * Finds the request corresponding to the RPC xid and invokes the
> > common
> > > + * tcp read code to read the data.
> > > + */
> > > +static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
> > > +				    struct xdr_skb_reader *desc)
> > > +{
> > > +	struct sock_xprt *transport =
> > > +				container_of(xprt, struct sock_xprt,
> xprt);
> > > +	struct rpc_rqst *req;
> > > +
> > > +	dprintk("RPC:       read reply XID %08x\n", ntohl(transport-
> > >tcp_xid));
> > > +
> > > +	/* Find and lock the request corresponding to this xid */
> > > +	spin_lock(&xprt->transport_lock);
> > > +	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
> > > +	if (!req) {
> > > +		dprintk("RPC:       XID %08x request not found!\n",
> > > +				ntohl(transport->tcp_xid));
> > > +		spin_unlock(&xprt->transport_lock);
> > > +		return -1;
> > > +	}
> > > +
> > > +	xs_tcp_read_common(xprt, desc, req);
> > > +
> > >  	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
> > >  		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
> > > +
> > >  	spin_unlock(&xprt->transport_lock);
> > > -	xs_tcp_check_fraghdr(transport);
> > > +	return 0;
> > > +}
> > > +
> > > +#if defined(CONFIG_NFS_V4_1)
> > > +/*
> > > + * Obtains an rpc_rqst previously allocated and invokes the common
> > > + * tcp read code to read the data.  The result is placed in the
> > callback
> > > + * queue.
> > > + * If we're unable to obtain the rpc_rqst we schedule the closing
> of
> > the
> > > + * connection and return -1.
> > > + */
> > > +static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
> > > +				       struct xdr_skb_reader *desc)
> > > +{
> > > +	struct sock_xprt *transport =
> > > +				container_of(xprt, struct sock_xprt,
> xprt);
> > > +	struct rpc_rqst *req;
> > > +
> > > +	req = xprt_alloc_bc_request(xprt);
> > > +	if (req == NULL) {
> > > +		/*
> > > +		 * Schedule an autoclose RPC call
> > > +		 */
> > > +		printk(KERN_WARNING "Callback slot table overflowed\n");
> > > +		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
> > > +		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
> > > +			queue_work(rpciod_workqueue,
> &xprt->task_cleanup);
> > > +		return -1;
> > > +	}
> > > +
> > > +	req->rq_xid = transport->tcp_xid;
> > > +	dprintk("RPC:       read callback  XID %08x\n",
> ntohl(req->rq_xid));
> > > +	xs_tcp_read_common(xprt, desc, req);
> > > +
> > > +	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
> > > +		struct svc_serv *bc_serv = xprt->bc_serv;
> > > +
> > > +		/*
> > > +		 * Add callback request to callback list.  The callback
> > > +		 * service sleeps on the sv_cb_waitq waiting for new
> > > +		 * requests.  Wake it up after adding enqueing the
> > > +		 * request.
> > > +		 */
> > > +		dprintk("RPC:       add callback request to list\n");
> > > +		spin_lock(&bc_serv->sv_cb_lock);
> > > +		list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
> > > +		spin_unlock(&bc_serv->sv_cb_lock);
> > > +		wake_up(&bc_serv->sv_cb_waitq);
> > > +	}
> > > +
> > > +	req->rq_private_buf.len = transport->tcp_copied;
> > > +
> > > +	return 0;
> > > +}
> > > +#endif /* CONFIG_NFS_V4_1 */
> > > +
> > > +/*
> > > + * Read data off the transport.  This can be either an RPC_CALL or
> an
> > > + * RPC_REPLY.  Relay the processing to helper functions.
> > > + */
> > > +static void xs_tcp_read_data(struct rpc_xprt *xprt,
> > > +				    struct xdr_skb_reader *desc)
> > > +{
> > > +	struct sock_xprt *transport =
> > > +				container_of(xprt, struct sock_xprt,
> xprt);
> > > +	int status;
> > > +
> > > +#if defined(CONFIG_NFS_V4_1)
> > > +	status = (transport->tcp_flags & TCP_RPC_REPLY) ?
> > > +		xs_tcp_read_reply(xprt, desc) :
> > > +		xs_tcp_read_callback(xprt, desc);
> > > +#else
> > > +	status = xs_tcp_read_reply(xprt, desc);
> > > +#endif /* CONFIG_NFS_V4_1 */
> > 
> > Ugh... Please don't embed ifdefs in functions like this...
> > 
> 
> OK, so is it okay to use the CONF_NFS_V4_1 code and remove the ifdefs?

Just define a helper function that does one thing in the 4.1 case, and
calls xs_tcp_read_reply() in the default case.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
