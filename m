Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5B8BC282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 90475218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XKkcc8uZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728529AbfBKQYk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:40 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:38169 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728518AbfBKQYk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:40 -0500
Received: by mail-it1-f196.google.com with SMTP id z20so27637301itc.3;
        Mon, 11 Feb 2019 08:24:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=aJWyu4yqiF6oEJf2GFLO3VcdAYqwCPRZxwDL723FfcI=;
        b=XKkcc8uZ85fw3eFk/o/F2qLBApL/jiXMbApLvfc+4oddT56+b8qcDsV2Syzd4eyuxf
         O2btLK2/JVhF9Doaj162gnLqLjs1pfj6XDYUXlJ9aB6ul1F09j2MW8e2fMUmwh132i0J
         tC7QPTGjr2gxh98TY/09EPJP8GI1CGvERoGPv9Rl5k/KJrBXS+IUwLMzgTz4uZTpI6WB
         djn0kuSQkTy6s7Qo7WnqkA/G2U7Vmxod4yMi2t12IP40niNCZAa+JK5UVvadm17R23+D
         GUxgOANkpUQwAJR52/PtBWxNAEP3npIK89TLpgBKnuqTi7Nv/zJibzMriU9z9UZOfWOX
         uiBA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=aJWyu4yqiF6oEJf2GFLO3VcdAYqwCPRZxwDL723FfcI=;
        b=f807HfzJas5F7k0sP3+x5sVKkmJFAt2CziXDz21N1xTNYtY0gv6nizGmouaRI2wROH
         MZ1yfSmECp4yEUUx7GrkWVcNb2QjuJJ9laVIaaJpHY+I8soItQ864wv4I6K3SkXh+xj2
         aWpieMtI+s4uNNzQuASx1WU9QEN7/uXPMSuhe5ZYkMbEkYDKqd94+M5IDoC2xepvcM5N
         a8LLoxVqoDupAWRLjVpYeJcWWzHN8u7REyGXLUoKxiPheRXkz3RI3lCi8LrRAN+ErHrD
         S/qDRKzLDWQR7U5TP9Xz5SN5k4CuEOR/8a3UthFA1BHZUPC/WehuwH0VFWv9pSA1P/f+
         nOQQ==
X-Gm-Message-State: AHQUAubTGy60tpGRbFMaYNlY1poc3EahhBCyVy0gCu/W/X85jPa6a0bq
        OtLdE6iZRnTtH6eU4n3/SRs=
X-Google-Smtp-Source: AHgI3IY9E7kdsw3pl+rgS1gtxqy/qa93ADxxAIJXu3PEPDRiEBDT1qi99Jm9BC6zx86gXcVgKZqpZA==
X-Received: by 2002:a02:7127:: with SMTP id n39mr18961123jac.91.1549902279093;
        Mon, 11 Feb 2019 08:24:39 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id k62sm4231788ite.3.2019.02.11.08.24.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:38 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGObZN029985;
        Mon, 11 Feb 2019 16:24:37 GMT
Subject: [PATCH v1 11/23] SUNRPC: Remove rpc_xprt::tsh_size
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:37 -0500
Message-ID: <20190211162437.2817.33967.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

tsh_size was added to accommodate transports that send a pre-amble
before each RPC message. However, this assumes the pre-amble is
fixed in size, which isn't true for some transports. That makes
tsh_size not very generic.

Also I'd like to make the estimation of RPC send and receive
buffer sizes more precise. tsh_size doesn't currently appear to be
accounted for at all by call_allocate.

Therefore let's just remove the tsh_size concept, and make the only
transports that have a non-zero tsh_size employ a direct approach.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h                |    7 --
 net/sunrpc/auth_gss/auth_gss.c             |    3 -
 net/sunrpc/clnt.c                          |    1 
 net/sunrpc/svc.c                           |   19 +-----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 
 net/sunrpc/xprtrdma/transport.c            |    1 
 net/sunrpc/xprtsock.c                      |   91 ++++++++++++++++++----------
 7 files changed, 65 insertions(+), 58 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index ad7e910..3a39154 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -196,8 +196,6 @@ struct rpc_xprt {
 
 	size_t			max_payload;	/* largest RPC payload size,
 						   in bytes */
-	unsigned int		tsh_size;	/* size of transport specific
-						   header */
 
 	struct rpc_wait_queue	binding;	/* requests waiting on rpcbind */
 	struct rpc_wait_queue	sending;	/* requests waiting to send */
@@ -362,11 +360,6 @@ struct rpc_xprt *	xprt_alloc(struct net *net, size_t size,
 				unsigned int max_req);
 void			xprt_free(struct rpc_xprt *);
 
-static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
-{
-	return p + xprt->tsh_size;
-}
-
 static inline int
 xprt_enable_swap(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index a42672e..4b52e2b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1563,8 +1563,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 
 	/* We compute the checksum for the verifier over the xdr-encoded bytes
 	 * starting with the xid and ending at the end of the credential: */
-	iov.iov_base = xprt_skip_transport_header(req->rq_xprt,
-					req->rq_snd_buf.head[0].iov_base);
+	iov.iov_base = req->rq_snd_buf.head[0].iov_base;
 	iov.iov_len = (u8 *)p - (u8 *)iov.iov_base;
 	xdr_buf_from_iov(&iov, &verf_buf);
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d7ec613..c4203f6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2331,7 +2331,6 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 
 	/* FIXME: check buffer size? */
 
-	p = xprt_skip_transport_header(req->rq_xprt, p);
 	*p++ = req->rq_xid;		/* XID */
 	*p++ = htonl(RPC_CALL);		/* CALL */
 	*p++ = htonl(RPC_VERSION);	/* RPC version */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e87ddb9..dbd1969 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1145,17 +1145,6 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
 #endif
 
 /*
- * Setup response header for TCP, it has a 4B record length field.
- */
-static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
-{
-	struct kvec *resv = &rqstp->rq_res.head[0];
-
-	/* tcp needs a space for the record length... */
-	svc_putnl(resv, 0);
-}
-
-/*
  * Common routine for processing the RPC request.
  */
 static int
@@ -1182,10 +1171,6 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
 	clear_bit(RQ_DROPME, &rqstp->rq_flags);
 
-	/* Setup reply header */
-	if (rqstp->rq_prot == IPPROTO_TCP)
-		svc_tcp_prep_reply_hdr(rqstp);
-
 	svc_putu32(resv, rqstp->rq_xid);
 
 	vers = svc_getnl(argv);
@@ -1443,6 +1428,10 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 		goto out_drop;
 	}
 
+	/* Reserve space for the record marker */
+	if (rqstp->rq_prot == IPPROTO_TCP)
+		svc_putnl(resv, 0);
+
 	/* Returns 1 for send, 0 for drop */
 	if (likely(svc_process_common(rqstp, argv, resv)))
 		return svc_send(rqstp);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index b908f2c..907464c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -304,7 +304,6 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	xprt->idle_timeout = RPCRDMA_IDLE_DISC_TO;
 
 	xprt->prot = XPRT_TRANSPORT_BC_RDMA;
-	xprt->tsh_size = 0;
 	xprt->ops = &xprt_rdma_bc_procs;
 
 	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index fbc171e..e7274dc 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -332,7 +332,6 @@
 	xprt->idle_timeout = RPCRDMA_IDLE_DISC_TO;
 
 	xprt->resvport = 0;		/* privileged port not needed */
-	xprt->tsh_size = 0;		/* RPC-RDMA handles framing */
 	xprt->ops = &xprt_rdma_procs;
 
 	/*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7754aa3..ae09d85 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -696,6 +696,40 @@ static void xs_stream_data_receive_workfn(struct work_struct *work)
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
+/* Common case:
+ *  - stream transport
+ *  - sending from byte 0 of the message
+ *  - the message is wholly contained in @xdr's head iovec
+ */
+static int xs_send_rm_and_kvec(struct socket *sock, struct xdr_buf *xdr,
+			       unsigned int remainder)
+{
+	struct msghdr msg = {
+		.msg_flags	= XS_SENDMSG_FLAGS | (remainder ? MSG_MORE : 0)
+	};
+	rpc_fraghdr marker = cpu_to_be32(RPC_LAST_STREAM_FRAGMENT |
+					 (u32)xdr->len);
+	struct kvec iov[2] = {
+		{
+			.iov_base	= &marker,
+			.iov_len	= sizeof(marker)
+		},
+		{
+			.iov_base	= xdr->head[0].iov_base,
+			.iov_len	= xdr->head[0].iov_len
+		},
+	};
+	int ret;
+
+	ret = kernel_sendmsg(sock, &msg, iov, 2,
+			     iov[0].iov_len + iov[1].iov_len);
+	if (ret < 0)
+		return ret;
+	if (ret < iov[0].iov_len)
+		return -EPIPE;
+	return ret - iov[0].iov_len;
+}
+
 static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
 {
 	struct msghdr msg = {
@@ -779,7 +813,11 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (base < xdr->head[0].iov_len || addr != NULL) {
 		unsigned int len = xdr->head[0].iov_len - base;
 		remainder -= len;
-		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0], base, remainder != 0);
+		if (!base && !addr)
+			err = xs_send_rm_and_kvec(sock, xdr, remainder);
+		else
+			err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0],
+					   base, remainder != 0);
 		if (remainder == 0 || err != len)
 			goto out;
 		*sent_p += err;
@@ -869,16 +907,6 @@ static int xs_nospace(struct rpc_rqst *req)
 	return transport->xmit.offset != 0 && req->rq_bytes_sent == 0;
 }
 
-/*
- * Construct a stream transport record marker in @buf.
- */
-static inline void xs_encode_stream_record_marker(struct xdr_buf *buf)
-{
-	u32 reclen = buf->len - sizeof(rpc_fraghdr);
-	rpc_fraghdr *base = buf->head[0].iov_base;
-	*base = cpu_to_be32(RPC_LAST_STREAM_FRAGMENT | reclen);
-}
-
 /**
  * xs_local_send_request - write an RPC request to an AF_LOCAL socket
  * @req: pointer to RPC request
@@ -905,8 +933,6 @@ static int xs_local_send_request(struct rpc_rqst *req)
 		return -ENOTCONN;
 	}
 
-	xs_encode_stream_record_marker(&req->rq_snd_buf);
-
 	xs_pktdump("packet data:",
 			req->rq_svec->iov_base, req->rq_svec->iov_len);
 
@@ -1057,8 +1083,6 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 		return -ENOTCONN;
 	}
 
-	xs_encode_stream_record_marker(&req->rq_snd_buf);
-
 	xs_pktdump("packet data:",
 				req->rq_svec->iov_base,
 				req->rq_svec->iov_len);
@@ -2534,26 +2558,35 @@ static int bc_sendto(struct rpc_rqst *req)
 {
 	int len;
 	struct xdr_buf *xbufp = &req->rq_snd_buf;
-	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport =
-				container_of(xprt, struct sock_xprt, xprt);
-	struct socket *sock = transport->sock;
+			container_of(req->rq_xprt, struct sock_xprt, xprt);
 	unsigned long headoff;
 	unsigned long tailoff;
+	struct page *tailpage;
+	struct msghdr msg = {
+		.msg_flags	= MSG_MORE
+	};
+	rpc_fraghdr marker = cpu_to_be32(RPC_LAST_STREAM_FRAGMENT |
+					 (u32)xbufp->len);
+	struct kvec iov = {
+		.iov_base	= &marker,
+		.iov_len	= sizeof(marker),
+	};
 
-	xs_encode_stream_record_marker(xbufp);
+	len = kernel_sendmsg(transport->sock, &msg, &iov, 1, iov.iov_len);
+	if (len != iov.iov_len)
+		return -EAGAIN;
 
+	tailpage = NULL;
+	if (xbufp->tail[0].iov_len)
+		tailpage = virt_to_page(xbufp->tail[0].iov_base);
 	tailoff = (unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK;
 	headoff = (unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK;
-	len = svc_send_common(sock, xbufp,
+	len = svc_send_common(transport->sock, xbufp,
 			      virt_to_page(xbufp->head[0].iov_base), headoff,
-			      xbufp->tail[0].iov_base, tailoff);
-
-	if (len != xbufp->len) {
-		printk(KERN_NOTICE "Error sending entire callback!\n");
-		len = -EAGAIN;
-	}
-
+			      tailpage, tailoff);
+	if (len != xbufp->len)
+		return -EAGAIN;
 	return len;
 }
 
@@ -2793,7 +2826,6 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = 0;
-	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
 	xprt->bind_timeout = XS_BIND_TO;
@@ -2862,7 +2894,6 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = IPPROTO_UDP;
-	xprt->tsh_size = 0;
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
@@ -2942,7 +2973,6 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = IPPROTO_TCP;
-	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
 	xprt->bind_timeout = XS_BIND_TO;
@@ -3015,7 +3045,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = IPPROTO_TCP;
-	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 	xprt->timeout = &xs_tcp_default_timeout;
 

