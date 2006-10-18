From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 4/9] SUNRPC: Move TCP receive state variables
	into	private data structure
Date: Wed, 18 Oct 2006 16:30:40 -0400
Message-ID: <1161203440.6095.133.camel@lade.trondhjem.org>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211512.8734.17617.stgit@ingres.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaI3u-0003ya-Ga
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:30:50 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaI3u-0007FP-Gn
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:30:51 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061012211512.8734.17617.stgit@ingres.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-10-12 at 17:15 -0400, Chuck Lever wrote:
> Move the TCP receive state variables from the generic rpc_xprt structure to
> a private structure maintained inside net/sunrpc/xprtsock.c.
> 
> Also rename a function/variable pair to refer to RPC fragment headers
> instead of record markers, to be consistent with types defined in
> sunrpc/*.h.
> 
> Test plan:
> Connectathon with NFS over TCP.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/xprt.h |   14 ----
>  net/sunrpc/xprtsock.c       |  159 +++++++++++++++++++++++++------------------
>  2 files changed, 91 insertions(+), 82 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 4c074a7..3ff8230 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -158,15 +158,6 @@ struct rpc_xprt {
>  				resvport   : 1; /* use a reserved port */
>  
>  	/*
> -	 * State of TCP reply receive stuff
> -	 */
> -	__be32			tcp_recm,	/* Fragment header */
> -				tcp_xid;	/* Current XID */
> -	u32			tcp_reclen,	/* fragment length */
> -				tcp_offset;	/* fragment offset */
> -	unsigned long		tcp_copied,	/* copied to request */
> -				tcp_flags;
> -	/*
>  	 * Connection of transports
>  	 */
>  	unsigned long		connect_timeout,
> @@ -212,11 +203,6 @@ struct rpc_xprt {
>  	char *			address_strings[RPC_DISPLAY_MAX];
>  };
>  
> -#define XPRT_LAST_FRAG		(1 << 0)
> -#define XPRT_COPY_RECM		(1 << 1)
> -#define XPRT_COPY_XID		(1 << 2)
> -#define XPRT_COPY_DATA		(1 << 3)
> -
>  #ifdef __KERNEL__
>  
>  /*
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 79088e8..363b2fc 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -133,8 +133,28 @@ struct xs_xprt {
>  	 */
>  	struct socket *		sock;
>  	struct sock *		inet;
> +
> +	/*
> +	 * State of TCP reply receive
> +	 */
> +	__be32			tcp_fraghdr,
> +				tcp_xid;
> +
> +	u32			tcp_offset,
> +				tcp_reclen;
> +
> +	unsigned long		tcp_copied,
> +				tcp_flags;
>  };
>  
> +/*
> + * tcp_flags
> + */
> +#define XS_LAST_FRAG		(1UL << 0)
> +#define XS_COPY_FRGH		(1UL << 1)
> +#define XS_COPY_XID		(1UL << 2)
> +#define XS_COPY_DATA		(1UL << 3)

Why are you renaming these?

> +
>  static inline struct xs_xprt *xs_private_data(struct rpc_xprt *xprt)
>  {
>  	return (struct xs_xprt *) xprt;
> @@ -641,73 +661,73 @@ static inline size_t xs_tcp_copy_data(sk
>  
>  static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, skb_reader_t *desc)
>  {
> +	struct xs_xprt *private = xs_private_data(xprt);

See previous comments about using 'private' as a variable name, and
apply everywhere.

>  	size_t len, used;
>  	char *p;
>  
> -	p = ((char *) &xprt->tcp_recm) + xprt->tcp_offset;
> -	len = sizeof(xprt->tcp_recm) - xprt->tcp_offset;
> +	p = ((char *) &private->tcp_fraghdr) + private->tcp_offset;
> +	len = sizeof(private->tcp_fraghdr) - private->tcp_offset;
>  	used = xs_tcp_copy_data(desc, p, len);
> -	xprt->tcp_offset += used;
> +	private->tcp_offset += used;
>  	if (used != len)
>  		return;
>  
> -	xprt->tcp_reclen = ntohl(xprt->tcp_recm);
> -	if (xprt->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
> -		xprt->tcp_flags |= XPRT_LAST_FRAG;
> +	private->tcp_reclen = ntohl(private->tcp_fraghdr);
> +	if (private->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
> +		private->tcp_flags |= XS_LAST_FRAG;
>  	else
> -		xprt->tcp_flags &= ~XPRT_LAST_FRAG;
> -	xprt->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
> +		private->tcp_flags &= ~XS_LAST_FRAG;
> +	private->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
>  
> -	xprt->tcp_flags &= ~XPRT_COPY_RECM;
> -	xprt->tcp_offset = 0;
> +	private->tcp_flags &= ~XS_COPY_FRGH;
> +	private->tcp_offset = 0;
>  
>  	/* Sanity check of the record length */
> -	if (unlikely(xprt->tcp_reclen < 4)) {
> +	if (unlikely(private->tcp_reclen < 4)) {
>  		dprintk("RPC:      invalid TCP record fragment length\n");
>  		xprt_disconnect(xprt);
>  		return;
>  	}
>  	dprintk("RPC:      reading TCP record fragment of length %d\n",
> -			xprt->tcp_reclen);
> +			private->tcp_reclen);
>  }
>  
> -static void xs_tcp_check_recm(struct rpc_xprt *xprt)
> +static void xs_tcp_check_fraghdr(struct xs_xprt *private)
>  {
> -	dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u, tcp_flags = %lx\n",
> -			xprt, xprt->tcp_copied, xprt->tcp_offset, xprt->tcp_reclen, xprt->tcp_flags);
> -	if (xprt->tcp_offset == xprt->tcp_reclen) {
> -		xprt->tcp_flags |= XPRT_COPY_RECM;
> -		xprt->tcp_offset = 0;
> -		if (xprt->tcp_flags & XPRT_LAST_FRAG) {
> -			xprt->tcp_flags &= ~XPRT_COPY_DATA;
> -			xprt->tcp_flags |= XPRT_COPY_XID;
> -			xprt->tcp_copied = 0;
> +	if (private->tcp_offset == private->tcp_reclen) {
> +		private->tcp_flags |= XS_COPY_FRGH;
> +		private->tcp_offset = 0;
> +		if (private->tcp_flags & XS_LAST_FRAG) {
> +			private->tcp_flags &= ~XS_COPY_DATA;
> +			private->tcp_flags |= XS_COPY_XID;
> +			private->tcp_copied = 0;
>  		}
>  	}
>  }
>  
> -static inline void xs_tcp_read_xid(struct rpc_xprt *xprt, skb_reader_t *desc)
> +static inline void xs_tcp_read_xid(struct xs_xprt *private, skb_reader_t *desc)
>  {
>  	size_t len, used;
>  	char *p;
>  
> -	len = sizeof(xprt->tcp_xid) - xprt->tcp_offset;
> +	len = sizeof(private->tcp_xid) - private->tcp_offset;
>  	dprintk("RPC:      reading XID (%Zu bytes)\n", len);
> -	p = ((char *) &xprt->tcp_xid) + xprt->tcp_offset;
> +	p = ((char *) &private->tcp_xid) + private->tcp_offset;
>  	used = xs_tcp_copy_data(desc, p, len);
> -	xprt->tcp_offset += used;
> +	private->tcp_offset += used;
>  	if (used != len)
>  		return;
> -	xprt->tcp_flags &= ~XPRT_COPY_XID;
> -	xprt->tcp_flags |= XPRT_COPY_DATA;
> -	xprt->tcp_copied = 4;
> +	private->tcp_flags &= ~XS_COPY_XID;
> +	private->tcp_flags |= XS_COPY_DATA;
> +	private->tcp_copied = 4;
>  	dprintk("RPC:      reading reply for XID %08x\n",
> -						ntohl(xprt->tcp_xid));
> -	xs_tcp_check_recm(xprt);
> +						ntohl(private->tcp_xid));
> +	xs_tcp_check_fraghdr(private);
>  }
>  
>  static inline void xs_tcp_read_request(struct rpc_xprt *xprt, skb_reader_t *desc)
>  {
> +	struct xs_xprt *private = xs_private_data(xprt);
>  	struct rpc_rqst *req;
>  	struct xdr_buf *rcvbuf;
>  	size_t len;
> @@ -715,116 +735,116 @@ static inline void xs_tcp_read_request(s
>  
>  	/* Find and lock the request corresponding to this xid */
>  	spin_lock(&xprt->transport_lock);
> -	req = xprt_lookup_rqst(xprt, xprt->tcp_xid);
> +	req = xprt_lookup_rqst(xprt, private->tcp_xid);
>  	if (!req) {
> -		xprt->tcp_flags &= ~XPRT_COPY_DATA;
> +		private->tcp_flags &= ~XS_COPY_DATA;
>  		dprintk("RPC:      XID %08x request not found!\n",
> -				ntohl(xprt->tcp_xid));
> +				ntohl(private->tcp_xid));
>  		spin_unlock(&xprt->transport_lock);
>  		return;
>  	}
>  
>  	rcvbuf = &req->rq_private_buf;
>  	len = desc->count;
> -	if (len > xprt->tcp_reclen - xprt->tcp_offset) {
> +	if (len > private->tcp_reclen - private->tcp_offset) {
>  		skb_reader_t my_desc;
>  
> -		len = xprt->tcp_reclen - xprt->tcp_offset;
> +		len = private->tcp_reclen - private->tcp_offset;
>  		memcpy(&my_desc, desc, sizeof(my_desc));
>  		my_desc.count = len;
> -		r = xdr_partial_copy_from_skb(rcvbuf, xprt->tcp_copied,
> +		r = xdr_partial_copy_from_skb(rcvbuf, private->tcp_copied,
>  					  &my_desc, xs_tcp_copy_data);
>  		desc->count -= r;
>  		desc->offset += r;
>  	} else
> -		r = xdr_partial_copy_from_skb(rcvbuf, xprt->tcp_copied,
> +		r = xdr_partial_copy_from_skb(rcvbuf, private->tcp_copied,
>  					  desc, xs_tcp_copy_data);
>  
>  	if (r > 0) {
> -		xprt->tcp_copied += r;
> -		xprt->tcp_offset += r;
> +		private->tcp_copied += r;
> +		private->tcp_offset += r;
>  	}
>  	if (r != len) {
>  		/* Error when copying to the receive buffer,
>  		 * usually because we weren't able to allocate
>  		 * additional buffer pages. All we can do now
> -		 * is turn off XPRT_COPY_DATA, so the request
> +		 * is turn off XS_COPY_DATA, so the request
>  		 * will not receive any additional updates,
>  		 * and time out.
>  		 * Any remaining data from this record will
>  		 * be discarded.
>  		 */
> -		xprt->tcp_flags &= ~XPRT_COPY_DATA;
> +		private->tcp_flags &= ~XS_COPY_DATA;
>  		dprintk("RPC:      XID %08x truncated request\n",
> -				ntohl(xprt->tcp_xid));
> +				ntohl(private->tcp_xid));
>  		dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
> -				xprt, xprt->tcp_copied, xprt->tcp_offset, xprt->tcp_reclen);
> +				xprt, private->tcp_copied, private->tcp_offset, private->tcp_reclen);
>  		goto out;
>  	}
>  
>  	dprintk("RPC:      XID %08x read %Zd bytes\n",
> -			ntohl(xprt->tcp_xid), r);
> +			ntohl(private->tcp_xid), r);
>  	dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
> -			xprt, xprt->tcp_copied, xprt->tcp_offset, xprt->tcp_reclen);
> +			xprt, private->tcp_copied, private->tcp_offset, private->tcp_reclen);
>  
> -	if (xprt->tcp_copied == req->rq_private_buf.buflen)
> -		xprt->tcp_flags &= ~XPRT_COPY_DATA;
> -	else if (xprt->tcp_offset == xprt->tcp_reclen) {
> -		if (xprt->tcp_flags & XPRT_LAST_FRAG)
> -			xprt->tcp_flags &= ~XPRT_COPY_DATA;
> +	if (private->tcp_copied == req->rq_private_buf.buflen)
> +		private->tcp_flags &= ~XS_COPY_DATA;
> +	else if (private->tcp_offset == private->tcp_reclen) {
> +		if (private->tcp_flags & XS_LAST_FRAG)
> +			private->tcp_flags &= ~XS_COPY_DATA;
>  	}
>  
>  out:
> -	if (!(xprt->tcp_flags & XPRT_COPY_DATA))
> -		xprt_complete_rqst(req->rq_task, xprt->tcp_copied);
> +	if (!(private->tcp_flags & XS_COPY_DATA))
> +		xprt_complete_rqst(req->rq_task, private->tcp_copied);
>  	spin_unlock(&xprt->transport_lock);
> -	xs_tcp_check_recm(xprt);
> +	xs_tcp_check_fraghdr(private);
>  }
>  
> -static inline void xs_tcp_read_discard(struct rpc_xprt *xprt, skb_reader_t *desc)
> +static inline void xs_tcp_read_discard(struct xs_xprt *private, skb_reader_t *desc)
>  {
>  	size_t len;
>  
> -	len = xprt->tcp_reclen - xprt->tcp_offset;
> +	len = private->tcp_reclen - private->tcp_offset;
>  	if (len > desc->count)
>  		len = desc->count;
>  	desc->count -= len;
>  	desc->offset += len;
> -	xprt->tcp_offset += len;
> +	private->tcp_offset += len;
>  	dprintk("RPC:      discarded %Zu bytes\n", len);
> -	xs_tcp_check_recm(xprt);
> +	xs_tcp_check_fraghdr(private);
>  }
>  
>  static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, unsigned int offset, size_t len)
>  {
>  	struct rpc_xprt *xprt = rd_desc->arg.data;
> +	struct xs_xprt *private = xs_private_data(xprt);
>  	skb_reader_t desc = {
>  		.skb	= skb,
>  		.offset	= offset,
>  		.count	= len,
> -		.csum	= 0
>  	};
>  
>  	dprintk("RPC:      xs_tcp_data_recv started\n");
>  	do {
>  		/* Read in a new fragment marker if necessary */
>  		/* Can we ever really expect to get completely empty fragments? */
> -		if (xprt->tcp_flags & XPRT_COPY_RECM) {
> +		if (private->tcp_flags & XS_COPY_FRGH) {
>  			xs_tcp_read_fraghdr(xprt, &desc);
>  			continue;
>  		}
>  		/* Read in the xid if necessary */
> -		if (xprt->tcp_flags & XPRT_COPY_XID) {
> -			xs_tcp_read_xid(xprt, &desc);
> +		if (private->tcp_flags & XS_COPY_XID) {
> +			xs_tcp_read_xid(private, &desc);
>  			continue;
>  		}
>  		/* Read in the request data */
> -		if (xprt->tcp_flags & XPRT_COPY_DATA) {
> +		if (private->tcp_flags & XS_COPY_DATA) {
>  			xs_tcp_read_request(xprt, &desc);
>  			continue;
>  		}
>  		/* Skip over any trailing bytes on short reads */
> -		xs_tcp_read_discard(xprt, &desc);
> +		xs_tcp_read_discard(private, &desc);
>  	} while (desc.count);
>  	dprintk("RPC:      xs_tcp_data_recv done\n");
>  	return len - desc.count;
> @@ -878,11 +898,14 @@ static void xs_tcp_state_change(struct s
>  	case TCP_ESTABLISHED:
>  		spin_lock_bh(&xprt->transport_lock);
>  		if (!xprt_test_and_set_connected(xprt)) {
> +			struct xs_xprt *private = xs_private_data(xprt);
> +
>  			/* Reset TCP record info */
> -			xprt->tcp_offset = 0;
> -			xprt->tcp_reclen = 0;
> -			xprt->tcp_copied = 0;
> -			xprt->tcp_flags = XPRT_COPY_RECM | XPRT_COPY_XID;
> +			private->tcp_offset = 0;
> +			private->tcp_reclen = 0;
> +			private->tcp_copied = 0;
> +			private->tcp_flags = XS_COPY_FRGH | XS_COPY_XID;
> +
>  			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
>  			xprt_wake_pending_tasks(xprt, 0);
>  		}


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
