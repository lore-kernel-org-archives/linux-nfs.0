Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:33084 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab3KJUd0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Nov 2013 15:33:26 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] SUNRPC: Fix a data corruption issue when retransmitting RPC calls
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384021209-2586-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Sun, 10 Nov 2013 15:33:22 -0500
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Message-Id: <E3F68432-AA7D-4735-A457-6BDE83839AC0@oracle.com>
References: <1384021209-2586-1-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 9, 2013, at 1:20 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> The following scenario can cause silent data corruption when doing
> NFS writes. It has mainly been observed when doing database writes
> using O_DIRECT.
> 
> 1) The RPC client uses sendpage() to do zero-copy of the page data.
> 2) Due to networking issues, the reply from the server is delayed,
>   and so the RPC client times out.
> 
> 3) The client issues a second sendpage of the page data as part of
>   an RPC call retransmission.
> 
> 4) The reply to the first transmission arrives from the server
>   _before_ the client hardware has emptied the TCP socket send
>   buffer.
> 5) After processing the reply, the RPC state machine rules that
>   the call to be done, and triggers the completion callbacks.
> 6) The application notices the RPC call is done, and reuses the
>   pages to store something else (e.g. a new write).
> 
> 7) The client NIC drains the TCP socket send buffer. Since the
>   page data has now changed, it reads a corrupted version of the
>   initial RPC call, and puts it on the wire.
> 
> This patch fixes the problem in the following manner:
> 
> The ordering guarantees of TCP ensure that when the server sends a
> reply, then we know that the _first_ transmission has completed. Using
> zero-copy in that situation is therefore safe.
> If a time out occurs, we then send the retransmission using sendmsg()
> (i.e. no zero-copy), We then know that the socket contains a full copy of
> the data, and so it will retransmit a faithful reproduction even if the
> RPC call completes, and the application reuses the O_DIRECT buffer in
> the meantime.

Clever!

But if wsize is large, the retransmission will require a potentially large contiguous piece of memory to complete a WRITE RPC.  In low memory scenarios, that might be hard to come by.  Should be safe for direct I/O, but if this I/O is driven by memory reclaim, it could deadlock.

We see this all the time when using NFS on network devices that do not support scatter/gather (and thus have no sock_sendpage() method to begin with).



> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org
> ---
> net/sunrpc/xprtsock.c | 28 +++++++++++++++++++++-------
> 1 file changed, 21 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 17c88928b7db..dd9d295813cf 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -393,8 +393,10 @@ static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen,
> 	return kernel_sendmsg(sock, &msg, NULL, 0, 0);
> }
> 
> -static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more)
> +static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more, bool zerocopy)
> {
> +	ssize_t (*do_sendpage)(struct socket *sock, struct page *page,
> +			int offset, size_t size, int flags);
> 	struct page **ppage;
> 	unsigned int remainder;
> 	int err, sent = 0;
> @@ -403,6 +405,9 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
> 	base += xdr->page_base;
> 	ppage = xdr->pages + (base >> PAGE_SHIFT);
> 	base &= ~PAGE_MASK;
> +	do_sendpage = sock->ops->sendpage;
> +	if (!zerocopy)
> +		do_sendpage = sock_no_sendpage;
> 	for(;;) {
> 		unsigned int len = min_t(unsigned int, PAGE_SIZE - base, remainder);
> 		int flags = XS_SENDMSG_FLAGS;
> @@ -410,7 +415,7 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
> 		remainder -= len;
> 		if (remainder != 0 || more)
> 			flags |= MSG_MORE;
> -		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
> +		err = do_sendpage(sock, *ppage, base, len, flags);
> 		if (remainder == 0 || err != len)
> 			break;
> 		sent += err;
> @@ -431,9 +436,10 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
>  * @addrlen: UDP only -- length of destination address
>  * @xdr: buffer containing this request
>  * @base: starting position in the buffer
> + * @zerocopy: true if it is safe to use sendpage()
>  *
>  */
> -static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base)
> +static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, bool zerocopy)
> {
> 	unsigned int remainder = xdr->len - base;
> 	int err, sent = 0;
> @@ -461,7 +467,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
> 	if (base < xdr->page_len) {
> 		unsigned int len = xdr->page_len - base;
> 		remainder -= len;
> -		err = xs_send_pagedata(sock, xdr, base, remainder != 0);
> +		err = xs_send_pagedata(sock, xdr, base, remainder != 0, zerocopy);
> 		if (remainder == 0 || err != len)
> 			goto out;
> 		sent += err;
> @@ -564,7 +570,7 @@ static int xs_local_send_request(struct rpc_task *task)
> 			req->rq_svec->iov_base, req->rq_svec->iov_len);
> 
> 	status = xs_sendpages(transport->sock, NULL, 0,
> -						xdr, req->rq_bytes_sent);
> +						xdr, req->rq_bytes_sent, true);
> 	dprintk("RPC:       %s(%u) = %d\n",
> 			__func__, xdr->len - req->rq_bytes_sent, status);
> 	if (likely(status >= 0)) {
> @@ -620,7 +626,7 @@ static int xs_udp_send_request(struct rpc_task *task)
> 	status = xs_sendpages(transport->sock,
> 			      xs_addr(xprt),
> 			      xprt->addrlen, xdr,
> -			      req->rq_bytes_sent);
> +			      req->rq_bytes_sent, true);
> 
> 	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
> 			xdr->len - req->rq_bytes_sent, status);
> @@ -693,6 +699,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
> 	struct rpc_xprt *xprt = req->rq_xprt;
> 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> 	struct xdr_buf *xdr = &req->rq_snd_buf;
> +	bool zerocopy = true;
> 	int status;
> 
> 	xs_encode_stream_record_marker(&req->rq_snd_buf);
> @@ -700,13 +707,20 @@ static int xs_tcp_send_request(struct rpc_task *task)
> 	xs_pktdump("packet data:",
> 				req->rq_svec->iov_base,
> 				req->rq_svec->iov_len);
> +	/* Don't use zero copy if this is a resend. If the RPC call
> +	 * completes while the socket holds a reference to the pages,
> +	 * then we may end up resending corrupted data.
> +	 */
> +	if (task->tk_flags & RPC_TASK_SENT)
> +		zerocopy = false;
> 
> 	/* Continue transmitting the packet/record. We must be careful
> 	 * to cope with writespace callbacks arriving _after_ we have
> 	 * called sendmsg(). */
> 	while (1) {
> 		status = xs_sendpages(transport->sock,
> -					NULL, 0, xdr, req->rq_bytes_sent);
> +					NULL, 0, xdr, req->rq_bytes_sent,
> +					zerocopy);
> 
> 		dprintk("RPC:       xs_tcp_send_request(%u) = %d\n",
> 				xdr->len - req->rq_bytes_sent, status);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




