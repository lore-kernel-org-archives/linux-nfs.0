From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 04/10] SUNRPC: Move TCP state flags into xprtsock.c
Date: Wed, 15 Nov 2006 12:28:44 -0500
Message-ID: <1163611724.5691.188.camel@lade.trondhjem.org>
References: <20061025164602.6410.27449.stgit@localhost.localdomain>
	<20061025164706.6410.88080.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkOZP-00083i-E0
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:29:07 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/g0Z35n6P8OZBzyzFRxK0QfZJkuKFptQU=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkOZM-0001Bs-Qo
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:29:08 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061025164706.6410.88080.stgit@localhost.localdomain>
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

On Wed, 2006-10-25 at 12:47 -0400, Chuck Lever wrote:
> Move "XPRT_LAST_FRAG" and friends from xprt.h into xprtsock.c, and rename
> them to use the naming scheme in use in xprtsock.c.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/xprt.h |    5 ----
>  net/sunrpc/xprtsock.c       |   48 +++++++++++++++++++++++++------------------
>  2 files changed, 28 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 0a0ad1c..3ff8230 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -203,11 +203,6 @@ struct rpc_xprt {
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
> index e7ecf99..0e01296 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -147,6 +147,14 @@ struct sock_xprt {
>  				tcp_flags;
>  };
>  
> +/*
> + * TCP receive state flags
> + */
> +#define XS_LAST_FRAG		(1UL << 0)
> +#define XS_COPY_FRGH		(1UL << 1)
> +#define XS_COPY_XID		(1UL << 2)
> +#define XS_COPY_DATA		(1UL << 3)

If you are going to rename these, how about just using RPCMSG_LAST_FRAG,
RPCMSG_COPY_FRAGHDR (FRGH == ugh), RPCMSG_COPY_XID, and
RPCMSG_COPY_DATA?

> +
>  static void xs_format_peer_addresses(struct rpc_xprt *xprt)
>  {
>  	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
> @@ -663,12 +671,12 @@ static inline void xs_tcp_read_fraghdr(s
>  
>  	sx->tcp_reclen = ntohl(sx->tcp_fraghdr);
>  	if (sx->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
> -		sx->tcp_flags |= XPRT_LAST_FRAG;
> +		sx->tcp_flags |= XS_LAST_FRAG;
>  	else
> -		sx->tcp_flags &= ~XPRT_LAST_FRAG;
> +		sx->tcp_flags &= ~XS_LAST_FRAG;
>  	sx->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
>  
> -	sx->tcp_flags &= ~XPRT_COPY_RECM;
> +	sx->tcp_flags &= ~XS_COPY_FRGH;
>  	sx->tcp_offset = 0;
>  
>  	/* Sanity check of the record length */
> @@ -684,11 +692,11 @@ static inline void xs_tcp_read_fraghdr(s
>  static void xs_tcp_check_fraghdr(struct sock_xprt *sx)
>  {
>  	if (sx->tcp_offset == sx->tcp_reclen) {
> -		sx->tcp_flags |= XPRT_COPY_RECM;
> +		sx->tcp_flags |= XS_COPY_FRGH;
>  		sx->tcp_offset = 0;
> -		if (sx->tcp_flags & XPRT_LAST_FRAG) {
> -			sx->tcp_flags &= ~XPRT_COPY_DATA;
> -			sx->tcp_flags |= XPRT_COPY_XID;
> +		if (sx->tcp_flags & XS_LAST_FRAG) {
> +			sx->tcp_flags &= ~XS_COPY_DATA;
> +			sx->tcp_flags |= XS_COPY_XID;
>  			sx->tcp_copied = 0;
>  		}
>  	}
> @@ -706,8 +714,8 @@ static inline void xs_tcp_read_xid(struc
>  	sx->tcp_offset += used;
>  	if (used != len)
>  		return;
> -	sx->tcp_flags &= ~XPRT_COPY_XID;
> -	sx->tcp_flags |= XPRT_COPY_DATA;
> +	sx->tcp_flags &= ~XS_COPY_XID;
> +	sx->tcp_flags |= XS_COPY_DATA;
>  	sx->tcp_copied = 4;
>  	dprintk("RPC:      reading reply for XID %08x\n",
>  			ntohl(sx->tcp_xid));
> @@ -726,7 +734,7 @@ static inline void xs_tcp_read_request(s
>  	spin_lock(&xprt->transport_lock);
>  	req = xprt_lookup_rqst(xprt, sx->tcp_xid);
>  	if (!req) {
> -		sx->tcp_flags &= ~XPRT_COPY_DATA;
> +		sx->tcp_flags &= ~XS_COPY_DATA;
>  		dprintk("RPC:      XID %08x request not found!\n",
>  				ntohl(sx->tcp_xid));
>  		spin_unlock(&xprt->transport_lock);
> @@ -757,13 +765,13 @@ static inline void xs_tcp_read_request(s
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
> -		sx->tcp_flags &= ~XPRT_COPY_DATA;
> +		sx->tcp_flags &= ~XS_COPY_DATA;
>  		dprintk("RPC:      XID %08x truncated request\n",
>  				ntohl(sx->tcp_xid));
>  		dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
> @@ -777,14 +785,14 @@ static inline void xs_tcp_read_request(s
>  			xprt, sx->tcp_copied, sx->tcp_offset, sx->tcp_reclen);
>  
>  	if (sx->tcp_copied == req->rq_private_buf.buflen)
> -		sx->tcp_flags &= ~XPRT_COPY_DATA;
> +		sx->tcp_flags &= ~XS_COPY_DATA;
>  	else if (sx->tcp_offset == sx->tcp_reclen) {
> -		if (sx->tcp_flags & XPRT_LAST_FRAG)
> -			sx->tcp_flags &= ~XPRT_COPY_DATA;
> +		if (sx->tcp_flags & XS_LAST_FRAG)
> +			sx->tcp_flags &= ~XS_COPY_DATA;
>  	}
>  
>  out:
> -	if (!(sx->tcp_flags & XPRT_COPY_DATA))
> +	if (!(sx->tcp_flags & XS_COPY_DATA))
>  		xprt_complete_rqst(req->rq_task, sx->tcp_copied);
>  	spin_unlock(&xprt->transport_lock);
>  	xs_tcp_check_fraghdr(sx);
> @@ -818,17 +826,17 @@ static int xs_tcp_data_recv(read_descrip
>  	do {
>  		/* Read in a new fragment marker if necessary */
>  		/* Can we ever really expect to get completely empty fragments? */
> -		if (sx->tcp_flags & XPRT_COPY_RECM) {
> +		if (sx->tcp_flags & XS_COPY_FRGH) {
>  			xs_tcp_read_fraghdr(xprt, &desc);
>  			continue;
>  		}
>  		/* Read in the xid if necessary */
> -		if (sx->tcp_flags & XPRT_COPY_XID) {
> +		if (sx->tcp_flags & XS_COPY_XID) {
>  			xs_tcp_read_xid(sx, &desc);
>  			continue;
>  		}
>  		/* Read in the request data */
> -		if (sx->tcp_flags & XPRT_COPY_DATA) {
> +		if (sx->tcp_flags & XS_COPY_DATA) {
>  			xs_tcp_read_request(xprt, &desc);
>  			continue;
>  		}
> @@ -894,7 +902,7 @@ static void xs_tcp_state_change(struct s
>  			sx->tcp_offset = 0;
>  			sx->tcp_reclen = 0;
>  			sx->tcp_copied = 0;
> -			sx->tcp_flags = XPRT_COPY_RECM | XPRT_COPY_XID;
> +			sx->tcp_flags = XS_COPY_FRGH | XS_COPY_XID;
>  
>  			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
>  			xprt_wake_pending_tasks(xprt, 0);


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
