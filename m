From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 53/85] nfs41: Add ability to read RPC call direction
 on	TCP stream.
Date: Mon, 17 Nov 2008 15:52:27 +0200
Message-ID: <4921771B.6020607@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348852-8994-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:12565 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751984AbYKQNwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:52:30 -0500
In-Reply-To: <1226348852-8994-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:27 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> NFSv4.1 callbacks can arrive over an existing connection. This patch adds
> the logic to read the RPC call direction (call or reply). It does this by
> updating the state machine to look for the call direction invoking
> xs_tcp_read_calldir(...) after reading the XID.
> 
> To avoid confusion, keep tcp_calldir in code in host order.
> 
> Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/xprtsock.c |   49 +++++++++++++++++++++++++++++++++++++++++++++----
>  1 files changed, 45 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 0a50361..1ce05d7 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -222,7 +222,8 @@ struct sock_xprt {
>  	 * State of TCP reply receive
>  	 */
>  	__be32			tcp_fraghdr,
> -				tcp_xid;
> +				tcp_xid,
> +				tcp_calldir;	/* Is this a call or a reply? */
>  
>  	u32			tcp_offset,
>  				tcp_reclen;
> @@ -259,6 +260,7 @@ struct sock_xprt {
>  #define TCP_RCV_COPY_FRAGHDR	(1UL << 1)
>  #define TCP_RCV_COPY_XID	(1UL << 2)
>  #define TCP_RCV_COPY_DATA	(1UL << 3)
> +#define TCP_RCV_COPY_CALLDIR	(1UL << 4)
>  
>  static inline struct sockaddr *xs_addr(struct rpc_xprt *xprt)
>  {
> @@ -919,7 +921,7 @@ static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_rea
>  	transport->tcp_offset = 0;
>  
>  	/* Sanity check of the record length */
> -	if (unlikely(transport->tcp_reclen < 4)) {
> +	if (unlikely(transport->tcp_reclen < 8)) {
>  		dprintk("RPC:       invalid TCP record fragment length\n");
>  		xprt_force_disconnect(xprt);
>  		return;
> @@ -954,13 +956,47 @@ static inline void xs_tcp_read_xid(struct sock_xprt *transport, struct xdr_skb_r
>  	if (used != len)
>  		return;
>  	transport->tcp_flags &= ~TCP_RCV_COPY_XID;
> -	transport->tcp_flags |= TCP_RCV_COPY_DATA;
> +	transport->tcp_flags |= TCP_RCV_COPY_CALLDIR;
>  	transport->tcp_copied = 4;
> -	dprintk("RPC:       reading reply for XID %08x\n",
> +	dprintk("RPC:       reading %s XID %08x\n",
> +			(transport->tcp_calldir == RPC_REPLY) ? "reply for"
> +							      : "request with",
>  			ntohl(transport->tcp_xid));
>  	xs_tcp_check_fraghdr(transport);
>  }
>  
> +static inline void xs_tcp_read_calldir(struct sock_xprt *transport,
> +				       struct xdr_skb_reader *desc)
> +{
> +	size_t len, used;
> +	u32 offset;
> +	char *p;
> +
> +	/*
> +	 * We want transport->tcp_offset to be 8 at the end of this routine
> +	 * (4 bytes for the xid and 4 bytes for the call/reply flag).
> +	 * When this function is called for the first time,
> +	 * transport->tcp_offset is 4 (after having already read the xid).
> +	 */
> +	offset = transport->tcp_offset - sizeof(transport->tcp_xid);
> +	len = sizeof(transport->tcp_calldir) - offset;
> +	dprintk("RPC:       reading CALL/REPLY flag (%Zu bytes)\n", len);
> +	p = ((char *) &transport->tcp_calldir) + offset;
> +	used = xdr_skb_read_bits(desc, p, len);
> +	transport->tcp_offset += used;
> +	if (used != len)
> +		return;
> +	transport->tcp_flags &= ~TCP_RCV_COPY_CALLDIR;
> +	transport->tcp_flags |= TCP_RCV_COPY_DATA;
> +	transport->tcp_copied += 4;
> +	transport->tcp_calldir = ntohl(transport->tcp_calldir);

review 11-14: introduce direction flag, no need to save the
actual value of calldir.

> +	dprintk("RPC:       reading %s CALL/REPLY flag %08x\n",
> +			(transport->tcp_calldir == RPC_REPLY) ? "reply for"
> +							      : "request with",
> +							transport->tcp_calldir);
> +	xs_tcp_check_fraghdr(transport);
> +}
> +
>  static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_reader *desc)
>  {
>  	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> @@ -1077,6 +1113,11 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
>  			xs_tcp_read_xid(transport, &desc);
>  			continue;
>  		}
> +		/* Read in the call/reply flag */
> +		if (transport->tcp_flags & TCP_RCV_COPY_CALLDIR) {
> +			xs_tcp_read_calldir(transport, &desc);
> +			continue;
> +		}
>  		/* Read in the request data */
>  		if (transport->tcp_flags & TCP_RCV_COPY_DATA) {
>  			xs_tcp_read_request(xprt, &desc);
