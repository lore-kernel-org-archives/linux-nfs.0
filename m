Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794605187;
	b=4SVbCw6BdMposqUCldZynqAYCrmmbIc5/zuVNil3cqiXhOwnZrBIidSdC7qDfXpeqYAI
	 Kr4ZPOkkU5MYXn+rvIUoZMi8ECa1bLUrO+j7FutQH3ONjbl9896QDqEJ3MwOPjNWTNj6w
	 rQVjsWta17togjVJfbTiRpnfQXO2hceS9FjctTVEss9TVSw0I41MSNOaH/SYdWQqL7cer
	 LsqTWHnbAz6Sw75xZlb/CBUMDOV2SzeiMWoJXlq5pjyKWr7YsBOuBx9QOLqsWZHJSVjAD
	 RvsfdTQ9h4kKf2vERWs+jfSL3EXn+/eZQxx0M4soyDp4ZZyHlaSsA3T8iZX5rH6GuRg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794605187;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=+LhmUueiZDpNp+el4ZZxKEiRLNHwEM9VF8h0HiTLPj0=;
	b=uxKEmD3rctmwhT+W+v/RAIRg0QXSGyBQd17f0sYt4oB+8p0Pnyy/YXGCLMxlsFoBReGA
	 MGRRtyAik63qyzKEMY3xQVDLTK2U/+rqzTSWSS+MPyv6B70+Agw+09Z8gF3jnC+BWdTsV
	 iUWL0qAAtvo/kEliVv4CjPaPm1xokgiZAYBIdNvpPiOgJFukRaKpRrxbxBhtrG1Ug4skj
	 q7jHc/36K6eECMxWWJL5Sro2ZG1VY6UPfehIGh958/3/PUudgLxsNaZ8moQJSj5YYkwOk
	 pfMTp8sbSNEqj2rnZotwMwhm0Jtccwlu1QhL0IEi9rBHdQTi0VHuxzVG/+iFA7CuTvg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bbDK0+5B;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5C15606A332
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 21:26:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bbDK0+5B
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 250981F000C6;
	Fri, 13 Nov 2026 21:26:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794605187;
	bh=+LhmUueiZDpNp+el4ZZxKEiRLNHwEM9VF8h0HiTLPj0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=bbDK0+5BoMUQbO3EKY72gpQOUgfM5CsILh5+VE0tbBwMxeovYLpJXMYmf+rmeahKB
	 2KH0TjnHQmdurdIX+gceNdqmpcbQ4YQkhH1p4n8+QdaluVajnCbbpBcFL5OwW7diTg
	 M/G+WY2JBarGAyezs9LAj48l7JTctTCikwbtHmbzDyZ2zoyZ5/Rlm1b5lAn8JjWxrW
	 gT786WGHjmJRvO11aeSglmfFnubgcC+Ep3FTN/26+G2B4apUr4P1/yy7y9CdSefRbG
	 94McLi4rVidSygFhoP6MfTv+H5v6ckCLhPrwhcCzTs4vv1Qp/jkOKdr+oY8vYHfcy2
	 AgTOB3jBS73Bg==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5E96BF40068;
	Fri, 13 Nov 2026 16:26:26 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 13 Nov 2026 16:26:26 -0500
X-ME-Sender: <xms:goD3amuCfgvygbDZVidsH3bAoFEGVqgsZNqls0kZhCk6jOhXZ2iiZQ>
    <xme:goD3amR9PG6xwsZOLDqq29HkhRB_4Ls5lzsV_jHujpV6GCg9N_CCg7fufEGptmfF9
    4LZH55nh5PS5OsaIOWZSq1TDuyeyfweJfUWtkiC7FiYahF5jIJoovz7>
X-ME-Proxy-Cause: dmFkZTGS0741Ia/KPz0rVczqUp+pe41+OSK3M4C2zvp0z9nKAsJwDak3rG6HuLglOCLNdH
    kGY+EFGxDnqXeLTBb3MYXBYcVBD20XAOHjLSPDf1pzkP7h/KFyxQrDy2W5gi+xcBuQ/kAg
    bbHzdW8anbA2YCrU7KUO+Sws1uoyPtFQFt1ZAQRtiwWjhr+ziUXgShAAy/9fxd378aQFfM
    hjJ3DHSuHTR08Bt3mSIDQ3GXHPkshEtx7eaME765GiM707qycsXtfbJllx4G4h7olko7oV
    l9qrQeITl3BAFI37h3zlys/l5dsoqr/ruJD4oCGSot6HVihuJM3UwFNzcQGHFRoAwkJFBr
    z3gag5ZhYcItGGuZsMx6t7uw9ea8Mxv8GuHgqyMBIOI/PXJna3p6yOOfKsKhPGtqKR6lb5
    8eUJicpaPWBhDy/uV3y14iAKS3DhrDaF1njRchCoLRjudTFUpdP9fRXbrB7tVa7t0K4lRk
    YvqQCXu4ByA73rqyl0zfZ4WkGGdXsHeuLNBXGd6nD1x5zmcxKTnhrwJmigoLgvhaWxVo4b
    jBdFAfYZ6rQwlKIteja4tkIXlJyQ1kKrcDoaqDY3jBUDnJ/BsPm26lJVK90j3Qsd9rgxgd
    93t56lF+FVvTwDofRuDeYEnCLxBj3cNAk+xBEMp3fRfZ2x5btb9cliNpPmPg
X-ME-Proxy: <xmx:goD3auVQnMKxxM90ciYzTCz11XFS3cKifVEWsxZmVWAyGTNrV6JNxg>
    <xmx:goD3aoY9eE8ntCf7iYTYoLKD7KvJ5MDCs2Az3roKD_Mx_zZHSrYJNA>
    <xmx:goD3as3LQXaIUzGC_aVcAY-yzve5HOJklAU63otbAx8DolcUwjSj7Q>
    <xmx:goD3aihCsGx54UbUM2jvCPhk-dGOAkxT2IXcs0PqKcQUBUeGoR0VHg>
    <xmx:goD3aoYuR9cDmkgac1Ey4GAhqZW619Of3QR-KfmNVBvDizaLnMZgKtTj>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 40FBFB6006F; Fri, 13 Nov 2026 16:26:26 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AgNBXAS72eqc
Date: Fri, 13 Nov 2026 16:26:06 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Anna Schumaker" <anna.schumaker@oracle.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <ea496fb4-06a8-4ac4-a174-8c2d612704ca@app.fastmail.com>
In-Reply-To: <20261113001611.90519-3-snitzer@kernel.org>
References: <20261113001611.90519-1-snitzer@kernel.org>
 <20261113001611.90519-3-snitzer@kernel.org>
Subject: Re: [PATCH 2/2] SUNRPC: Splice a request's pages into the TCP socket
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Thu, Nov 12, 2026, at 7:16 PM, Mike Snitzer wrote:
> xprt_sock_sendmsg() sends a request's page array to the socket as a
> bvec, and tcp_sendmsg_locked() copies every byte of it into the
> socket's skbs under the socket lock.  For an NFS WRITE that is the
> whole payload, copied by rpciod one request at a time a transport: at
> 1 MiB a WRITE it comes to about 3 GB/s a connection, and on a client
> with 24 connections to a server whose storage takes more, it is the
> ceiling of the rate, with 18% of the client's 48 CPUs in memcpy under
> tcp_sendmsg_locked().
>
> Until commit 0472e4766049 ("SUNRPC: Convert socket page send code to
> use iov_iter()") the client sent the pages with kernel_sendpage(), so
> the socket held them and copied nothing.  Send them with
> MSG_SPLICE_PAGES, as the server's svc_tcp_sendmsg() has since
> commit 5df5dd03a8f7 ("sunrpc: Use sendmsg(MSG_SPLICE_PAGES) rather then
> sendpage"), and the socket holds them again.  Only the page array is
> spliced: the head and the tail are kvecs over the request's buffer,
> memory the socket may not hold a reference to, and are copied as
> before.
>
> A request's pages are the caller's until the reply, and TCP delivers
> them before the server can reply, so a first transmission is safe to
> splice.  A retransmission is not: the reply to the first transmission
> may complete the call and release the pages to be rewritten while the
> socket still holds them for the second, the corruption that
> commit a6b31d18b02f ("SUNRPC: Fix a data corruption issue when
> retransmitting RPC calls") found with kernel_sendpage().  So a
> retransmission is copied, as it was then, and only the TCP transport
> asks for the splice: UDP and AF_LOCAL copy as before.
>
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  net/sunrpc/socklib.c  | 26 ++++++++++++++++++++++----
>  net/sunrpc/xprtsock.c |  9 +++++++++
>  2 files changed, 31 insertions(+), 4 deletions(-)
>
> diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
> index d8d8842c7de5c..ba18387f8ed6d 100644
> --- a/net/sunrpc/socklib.c
> +++ b/net/sunrpc/socklib.c
> @@ -173,11 +173,17 @@ static int xprt_send_kvec(struct socket *sock, 
> struct msghdr *msg,
>  }
> 
>  static int xprt_send_pagedata(struct socket *sock, struct msghdr *msg,
> -			      struct xdr_buf *xdr, size_t base)
> +			      struct xdr_buf *xdr, size_t base,
> +			      unsigned int splice)
>  {
> +	int ret;
> +
>  	iov_iter_bvec(&msg->msg_iter, ITER_SOURCE, xdr->bvec, xdr_buf_pagecount(xdr),
>  		      xdr->page_len + xdr->page_base);
> -	return xprt_sendmsg(sock, msg, base + xdr->page_base);
> +	msg->msg_flags |= splice;
> +	ret = xprt_sendmsg(sock, msg, base + xdr->page_base);
> +	msg->msg_flags &= ~MSG_SPLICE_PAGES;
> +	return ret;
>  }
> 
>  /* Common case:
> @@ -207,6 +213,12 @@ static int xprt_send_rm_and_kvec(struct socket 
> *sock, struct msghdr *msg,
>   * @sock: open socket to send on
>   * @msg: socket message metadata
>   * @xdr: xdr_buf containing this request
> + *
> + * With %MSG_SPLICE_PAGES set in @msg->msg_flags, the pages of @xdr are
> + * spliced into the socket rather than copied, and the caller must 
> leave
> + * them unchanged until the socket has sent them.  The head and the 
> tail
> + * are always copied.
> + *

What an odd place to put this comment. I honestly don't think it's needed,
however. 

>   * @base: starting position in the buffer
>   * @marker: stream record marker field
>   * @sent_p: return the total number of bytes successfully queued for 
> sending
> @@ -221,6 +233,7 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> msghdr *msg,
>  {
>  	unsigned int rmsize = marker ? sizeof(marker) : 0;
>  	unsigned int remainder = rmsize + xdr->len - base;
> +	unsigned int splice = msg->msg_flags & MSG_SPLICE_PAGES;
>  	unsigned int want;
>  	int err = 0;
> 
> @@ -229,6 +242,10 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> msghdr *msg,
>  	if (unlikely(!sock))
>  		return -ENOTSOCK;
> 
> +	/* The head and tail are kvecs over memory the socket may not
> +	 * hold a reference to, so only the page array is spliced.
> +	 */

Same here. Code should be self-documenting enough that comments should
be saved to explain tricky decisions and not describe basic behavior.

> +	msg->msg_flags &= ~MSG_SPLICE_PAGES;
>  	msg->msg_flags |= MSG_MORE;
>  	want = xdr->head[0].iov_len + rmsize;
>  	if (base < want) {
> @@ -256,7 +273,7 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> msghdr *msg,
>  		remainder -= len;
>  		if (remainder == 0)
>  			msg->msg_flags &= ~MSG_MORE;
> -		err = xprt_send_pagedata(sock, msg, xdr, base);
> +		err = xprt_send_pagedata(sock, msg, xdr, base, splice);
>  		if (remainder == 0 || err != len)
>  			goto out;
>  		*sent_p += err;
> @@ -266,10 +283,11 @@ int xprt_sock_sendmsg(struct socket *sock, struct 
> msghdr *msg,
>  	}
> 
>  	if (base >= xdr->tail[0].iov_len)
> -		return 0;
> +		goto out;
>  	msg->msg_flags &= ~MSG_MORE;
>  	err = xprt_send_kvec(sock, msg, &xdr->tail[0], base);
>  out:
> +	msg->msg_flags |= splice;
>  	if (err > 0) {
>  		*sent_p += err;
>  		err = 0;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 173e3b0fd7a3b..2a077cddcc8ad 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1136,6 +1136,15 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
> 
>  	xs_set_srcport(transport, transport->sock);
> 
> +	/* Splice the pages of a first transmission into the socket: TCP
> +	 * delivers them before the server can reply, and the reply is

Does "TCP delivers them before the server can reply" really need to be stated?

Anyway, what do you think is the right path forward for this? Chuck's patches
seem to replace your 1/2, so should I just put this one on top of those?

Thanks,
Anna

> +	 * what releases them.  A retransmission is copied, since the
> +	 * reply to the first transmission may complete the call and
> +	 * release the pages while the socket still holds them.
> +	 */
> +	if (!RPC_WAS_SENT(req->rq_task))
> +		msg.msg_flags |= MSG_SPLICE_PAGES;
> +
>  	/* Continue transmitting the packet/record. We must be careful
>  	 * to cope with writespace callbacks arriving _after_ we have
>  	 * called sendmsg(). */
> -- 
> 2.52.0
