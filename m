Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61003 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756970AbaIRUsV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 16:48:21 -0400
Message-ID: <541B4512.2030607@Netapp.com>
Date: Thu, 18 Sep 2014 16:48:18 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Jason Baron <jbaron@akamai.com>, <trond.myklebust@primarydata.com>,
        <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc: return sent and err from xs_sendpages()
References: <cover.1411068259.git.jbaron@akamai.com> <ac206678a8342c7e31ef0b8c40c4fa946c60d00b.1411068259.git.jbaron@akamai.com>
In-Reply-To: <ac206678a8342c7e31ef0b8c40c4fa946c60d00b.1411068259.git.jbaron@akamai.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/18/2014 03:51 PM, Jason Baron wrote:
> If an error is returned after the first bits of a packet have already been
> successfully queued, xs_sendpages() will return a positive 'int' value
> indicating success. Callers seem to treat this as -EAGAIN.
>
> However, there are cases where its not a question of waiting for the write
> queue to drain. For example, when there is an iptables rule dropping packets
> to the destination, the lower level code can return -EPERM only after parts
> of the packet have been successfully queued. In this case, we can end up
> continuously retrying.
>
> This patch is meant to effectively be a no-op in preparation for subsequent
> patches that can make decisions based on both on the number of bytes sent
> by xs_sendpages() and any errors that may have be returned.

Nit:  I don't like calling this patch a "no-op", since it does change the code.  Saying that it's preparing for the next patch with no change in behavior is probably good enough! :)

>
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---
>  net/sunrpc/xprtsock.c | 80 ++++++++++++++++++++++++++-------------------------
>  1 file changed, 41 insertions(+), 39 deletions(-)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 43cd89e..38eb17d 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -399,13 +399,13 @@ static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen,
>  	return kernel_sendmsg(sock, &msg, NULL, 0, 0);
>  }
>  
> -static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more, bool zerocopy)
> +static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more, bool zerocopy, int *sent_p)
>  {
>  	ssize_t (*do_sendpage)(struct socket *sock, struct page *page,
>  			int offset, size_t size, int flags);
>  	struct page **ppage;
>  	unsigned int remainder;
> -	int err, sent = 0;
> +	int err;
>  
>  	remainder = xdr->page_len - base;
>  	base += xdr->page_base;
> @@ -424,15 +424,15 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
>  		err = do_sendpage(sock, *ppage, base, len, flags);
>  		if (remainder == 0 || err != len)
>  			break;
> -		sent += err;
> +		*sent_p += err;
>  		ppage++;
>  		base = 0;
>  	}
> -	if (sent == 0)
> -		return err;
> -	if (err > 0)
> -		sent += err;
> -	return sent;
> +	if (err > 0) {
> +		*sent_p += err;
> +		err = 0;
> +	}
> +	return err;
>  }
>  
>  /**
> @@ -445,10 +445,11 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
>   * @zerocopy: true if it is safe to use sendpage()

Please update the documentation here to include the new parameter.

Anna
>   *
>   */
> -static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, bool zerocopy)
> +static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, bool zerocopy, int *sent_p)
>  {
>  	unsigned int remainder = xdr->len - base;
> -	int err, sent = 0;
> +	int err = 0;
> +	int sent = 0;
>  
>  	if (unlikely(!sock))
>  		return -ENOTSOCK;
> @@ -465,7 +466,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
>  		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0], base, remainder != 0);
>  		if (remainder == 0 || err != len)
>  			goto out;
> -		sent += err;
> +		*sent_p += err;
>  		base = 0;
>  	} else
>  		base -= xdr->head[0].iov_len;
> @@ -473,23 +474,23 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
>  	if (base < xdr->page_len) {
>  		unsigned int len = xdr->page_len - base;
>  		remainder -= len;
> -		err = xs_send_pagedata(sock, xdr, base, remainder != 0, zerocopy);
> -		if (remainder == 0 || err != len)
> +		err = xs_send_pagedata(sock, xdr, base, remainder != 0, zerocopy, &sent);
> +		*sent_p += sent;
> +		if (remainder == 0 || sent != len)
>  			goto out;
> -		sent += err;
>  		base = 0;
>  	} else
>  		base -= xdr->page_len;
>  
>  	if (base >= xdr->tail[0].iov_len)
> -		return sent;
> +		return 0;
>  	err = xs_send_kvec(sock, NULL, 0, &xdr->tail[0], base, 0);
>  out:
> -	if (sent == 0)
> -		return err;
> -	if (err > 0)
> -		sent += err;
> -	return sent;
> +	if (err > 0) {
> +		*sent_p += err;
> +		err = 0;
> +	}
> +	return err;
>  }
>  
>  static void xs_nospace_callback(struct rpc_task *task)
> @@ -573,19 +574,20 @@ static int xs_local_send_request(struct rpc_task *task)
>  				container_of(xprt, struct sock_xprt, xprt);
>  	struct xdr_buf *xdr = &req->rq_snd_buf;
>  	int status;
> +	int sent = 0;
>  
>  	xs_encode_stream_record_marker(&req->rq_snd_buf);
>  
>  	xs_pktdump("packet data:",
>  			req->rq_svec->iov_base, req->rq_svec->iov_len);
>  
> -	status = xs_sendpages(transport->sock, NULL, 0,
> -						xdr, req->rq_bytes_sent, true);
> +	status = xs_sendpages(transport->sock, NULL, 0, xdr, req->rq_bytes_sent,
> +			      true, &sent);
>  	dprintk("RPC:       %s(%u) = %d\n",
>  			__func__, xdr->len - req->rq_bytes_sent, status);
> -	if (likely(status >= 0)) {
> -		req->rq_bytes_sent += status;
> -		req->rq_xmit_bytes_sent += status;
> +	if (likely(sent > 0) || status == 0) {
> +		req->rq_bytes_sent += sent;
> +		req->rq_xmit_bytes_sent += sent;
>  		if (likely(req->rq_bytes_sent >= req->rq_slen)) {
>  			req->rq_bytes_sent = 0;
>  			return 0;
> @@ -626,6 +628,7 @@ static int xs_udp_send_request(struct rpc_task *task)
>  	struct rpc_xprt *xprt = req->rq_xprt;
>  	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>  	struct xdr_buf *xdr = &req->rq_snd_buf;
> +	int sent = 0;
>  	int status;
>  
>  	xs_pktdump("packet data:",
> @@ -634,17 +637,15 @@ static int xs_udp_send_request(struct rpc_task *task)
>  
>  	if (!xprt_bound(xprt))
>  		return -ENOTCONN;
> -	status = xs_sendpages(transport->sock,
> -			      xs_addr(xprt),
> -			      xprt->addrlen, xdr,
> -			      req->rq_bytes_sent, true);
> +	status = xs_sendpages(transport->sock, xs_addr(xprt), xprt->addrlen,
> +			      xdr, req->rq_bytes_sent, true, &sent);
>  
>  	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
>  			xdr->len - req->rq_bytes_sent, status);
>  
> -	if (status >= 0) {
> -		req->rq_xmit_bytes_sent += status;
> -		if (status >= req->rq_slen)
> +	if (sent > 0 || status == 0) {
> +		req->rq_xmit_bytes_sent += sent;
> +		if (sent >= req->rq_slen)
>  			return 0;
>  		/* Still some bytes left; set up for a retry later. */
>  		status = -EAGAIN;
> @@ -713,6 +714,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
>  	struct xdr_buf *xdr = &req->rq_snd_buf;
>  	bool zerocopy = true;
>  	int status;
> +	int sent = 0;
>  
>  	xs_encode_stream_record_marker(&req->rq_snd_buf);
>  
> @@ -730,26 +732,26 @@ static int xs_tcp_send_request(struct rpc_task *task)
>  	 * to cope with writespace callbacks arriving _after_ we have
>  	 * called sendmsg(). */
>  	while (1) {
> -		status = xs_sendpages(transport->sock,
> -					NULL, 0, xdr, req->rq_bytes_sent,
> -					zerocopy);
> +		sent = 0;
> +		status = xs_sendpages(transport->sock, NULL, 0, xdr,
> +				      req->rq_bytes_sent, zerocopy, &sent);
>  
>  		dprintk("RPC:       xs_tcp_send_request(%u) = %d\n",
>  				xdr->len - req->rq_bytes_sent, status);
>  
> -		if (unlikely(status < 0))
> +		if (unlikely(sent == 0 && status < 0))
>  			break;
>  
>  		/* If we've sent the entire packet, immediately
>  		 * reset the count of bytes sent. */
> -		req->rq_bytes_sent += status;
> -		req->rq_xmit_bytes_sent += status;
> +		req->rq_bytes_sent += sent;
> +		req->rq_xmit_bytes_sent += sent;
>  		if (likely(req->rq_bytes_sent >= req->rq_slen)) {
>  			req->rq_bytes_sent = 0;
>  			return 0;
>  		}
>  
> -		if (status != 0)
> +		if (sent != 0)
>  			continue;
>  		status = -EAGAIN;
>  		break;

