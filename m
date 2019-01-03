Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C10DCC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 18:35:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7746520815
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 18:35:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LlEgO2Qs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726025AbfACSfa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 13:35:30 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:53724 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725986AbfACSfa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 13:35:30 -0500
Received: by mail-it1-f194.google.com with SMTP id g85so46542419ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jan 2019 10:35:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=r268dfwHntBb3iBUSmEHWjkGL8yiCA/sJPmxP9jovJM=;
        b=LlEgO2QscwjP2Zo1LYh5hSDUy4Z82zDD3MSq3uGtK4VEDotUuNcQhoUS/bDf9cwzMj
         8/WHpo2QHdFSd3BGekC+qGAQZL02uvFF3hluzN3FUTb48EJXQR9+hzcds9QD90u2SJag
         mgVOdbfs2a7OM7KyBrsmsGtvsKGlBcDmWP4oz7LtkMi5M/ELnme/zroT5bueukoIjksy
         MrbBxNB8DjUhwfZMfuh0hwea6Op0ShdfHVCfx+4G/Mk1bHp7mPrL1tYDTlBY9R0h0fZ6
         LeB8iJZ1VI1gzlD2mwgwwZO/PE8YEYazLi1Xrodc7LDwsb6v2K1+Li/4z28FTyys8Twn
         gacg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=r268dfwHntBb3iBUSmEHWjkGL8yiCA/sJPmxP9jovJM=;
        b=G24dzvceFhbndDBaYNKab0z7wdj2QP5Nx1CbQFuloDbBzljAz7jwvjAyV6YAyGSSZz
         gFCRiAKu6ZO/zzfdSdNzvaQd+2U4l1kqqnd6TJgjbSbJkp5H+UWjLhMHX0kP7qeDSyz6
         pI92LsMMzDXzjBK1eGmoHaExutkVRnRKECSFKdY1Wuq6Epr3k92D6T/mbWOHlCQxiKPk
         5FFAQr6yWo2f/l4xKhn6+QZOj8KW1H6zIUgrUbCWnxb6aiBBVAPodVV++SJhIx9TukMk
         cSl0IlwqDk5xfKNvocGb8xZ3f75OuYWIbWSNeled8uGbxl2c3IMn4DlY0e58/0eHSP3n
         EyKA==
X-Gm-Message-State: AJcUukcl9n5zOMLRMjstEz8kobgpEdhBF1G/OZi59WrM79yVmN3lcJxL
        xcNeqZJtlhWEAk25Q66cjRig1bfG
X-Google-Smtp-Source: AFSGD/WkS0ailPVw3nK7SBW0RJwbeDmqZFPpGWFL9RjA68yy6w955bbzpX7/79VzfPlSgr3Yo3N8EQ==
X-Received: by 2002:a24:2f82:: with SMTP id j124mr28832805itj.166.1546540160596;
        Thu, 03 Jan 2019 10:29:20 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o16sm23409204ito.19.2019.01.03.10.29.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 10:29:19 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x03ITI1S023231
        for <linux-nfs@vger.kernel.org>; Thu, 3 Jan 2019 18:29:18 GMT
Subject: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Thu, 03 Jan 2019 13:29:18 -0500
Message-ID: <20190103182649.4148.19838.stgit@manet.1015granger.net>
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

I've taken an approach where only the transports that need a record
marker need to pay the expense. I don't want to add another indirect
call in the generic path.

However, I've found that during heavy multi-threaded workloads,
occasionally this mechanism inserts a record marker in the middle of
a Call message.


 include/linux/sunrpc/xprt.h                |    7 ---
 net/sunrpc/auth_gss/auth_gss.c             |    3 -
 net/sunrpc/clnt.c                          |    1 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 
 net/sunrpc/xprtrdma/transport.c            |    1 
 net/sunrpc/xprtsock.c                      |   69 +++++++++++++++++-----------
 6 files changed, 43 insertions(+), 39 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a4ab4f8..17fc651 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -197,8 +197,6 @@ struct rpc_xprt {
 
 	size_t			max_payload;	/* largest RPC payload size,
 						   in bytes */
-	unsigned int		tsh_size;	/* size of transport specific
-						   header */
 
 	struct rpc_wait_queue	binding;	/* requests waiting on rpcbind */
 	struct rpc_wait_queue	sending;	/* requests waiting to send */
@@ -363,11 +361,6 @@ struct rpc_xprt *	xprt_alloc(struct net *net, size_t size,
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
index 4735a06..13508e4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1577,8 +1577,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 
 	/* We compute the checksum for the verifier over the xdr-encoded bytes
 	 * starting with the xid and ending at the end of the credential: */
-	iov.iov_base = xprt_skip_transport_header(req->rq_xprt,
-					req->rq_snd_buf.head[0].iov_base);
+	iov.iov_base = req->rq_snd_buf.head[0].iov_base;
 	iov.iov_len = (u8 *)p - (u8 *)iov.iov_base;
 	xdr_buf_from_iov(&iov, &verf_buf);
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1ee04e0..4f88062 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2330,7 +2330,6 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 
 	/* FIXME: check buffer size? */
 
-	p = xprt_skip_transport_header(req->rq_xprt, p);
 	*p++ = req->rq_xid;		/* XID */
 	*p++ = htonl(RPC_CALL);		/* CALL */
 	*p++ = htonl(RPC_VERSION);	/* RPC version */
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
index 9a7bb58..2a704d5 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -332,7 +332,6 @@
 	xprt->idle_timeout = RPCRDMA_IDLE_DISC_TO;
 
 	xprt->resvport = 0;		/* privileged port not needed */
-	xprt->tsh_size = 0;		/* RPC-RDMA handles framing */
 	xprt->ops = &xprt_rdma_procs;
 
 	/*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d5ce1a8..66b08aa 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -678,6 +678,31 @@ static void xs_stream_data_receive_workfn(struct work_struct *work)
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
+static int xs_send_record_marker(struct sock_xprt *transport,
+				 const struct rpc_rqst *req)
+{
+	static struct msghdr msg = {
+		.msg_name	= NULL,
+		.msg_namelen	= 0,
+		.msg_flags	= (XS_SENDMSG_FLAGS | MSG_MORE),
+	};
+	rpc_fraghdr marker;
+	struct kvec iov = {
+		.iov_base	= &marker,
+		.iov_len	= sizeof(marker),
+	};
+	u32 reclen;
+
+	if (unlikely(!transport->sock))
+		return -ENOTSOCK;
+	if (req->rq_bytes_sent)
+		return 0;
+
+	reclen = req->rq_snd_buf.len;
+	marker = cpu_to_be32(RPC_LAST_STREAM_FRAGMENT | reclen);
+	return kernel_sendmsg(transport->sock, &msg, &iov, 1, iov.iov_len);
+}
+
 static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
 {
 	struct msghdr msg = {
@@ -851,16 +876,6 @@ static int xs_nospace(struct rpc_rqst *req)
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
@@ -887,18 +902,20 @@ static int xs_local_send_request(struct rpc_rqst *req)
 		return -ENOTCONN;
 	}
 
-	xs_encode_stream_record_marker(&req->rq_snd_buf);
-
 	xs_pktdump("packet data:",
 			req->rq_svec->iov_base, req->rq_svec->iov_len);
 
 	req->rq_xtime = ktime_get();
+	status = xs_send_record_marker(transport, req);
+	if (status < 0)
+		goto marker_fail;
 	status = xs_sendpages(transport->sock, NULL, 0, xdr,
 			      transport->xmit.offset,
 			      true, &sent);
 	dprintk("RPC:       %s(%u) = %d\n",
 			__func__, xdr->len - transport->xmit.offset, status);
 
+marker_fail:
 	if (status == -EAGAIN && sock_writeable(transport->inet))
 		status = -ENOBUFS;
 
@@ -1039,8 +1056,6 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 		return -ENOTCONN;
 	}
 
-	xs_encode_stream_record_marker(&req->rq_snd_buf);
-
 	xs_pktdump("packet data:",
 				req->rq_svec->iov_base,
 				req->rq_svec->iov_len);
@@ -1058,6 +1073,9 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 	 * to cope with writespace callbacks arriving _after_ we have
 	 * called sendmsg(). */
 	req->rq_xtime = ktime_get();
+	status = xs_send_record_marker(transport, req);
+	if (status < 0)
+		goto marker_fail;
 	while (1) {
 		sent = 0;
 		status = xs_sendpages(transport->sock, NULL, 0, xdr,
@@ -1106,6 +1124,7 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 		vm_wait = false;
 	}
 
+marker_fail:
 	switch (status) {
 	case -ENOTSOCK:
 		status = -ENOTCONN;
@@ -2530,24 +2549,24 @@ static int bc_sendto(struct rpc_rqst *req)
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
-	struct socket *sock = transport->sock;
 	unsigned long headoff;
 	unsigned long tailoff;
 
-	xs_encode_stream_record_marker(xbufp);
+	len = xs_send_record_marker(transport, req);
+	if (len < 0)
+		goto out_fail;
 
 	tailoff = (unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK;
 	headoff = (unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK;
-	len = svc_send_common(sock, xbufp,
+	len = svc_send_common(transport->sock, xbufp,
 			      virt_to_page(xbufp->head[0].iov_base), headoff,
 			      xbufp->tail[0].iov_base, tailoff);
-
-	if (len != xbufp->len) {
-		printk(KERN_NOTICE "Error sending entire callback!\n");
-		len = -EAGAIN;
-	}
-
+	if (len != xbufp->len)
+		goto out_fail;
 	return len;
+out_fail:
+	pr_info("Error sending entire callback!\n");
+	return -EAGAIN;
 }
 
 /*
@@ -2787,7 +2806,6 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = 0;
-	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
 	xprt->bind_timeout = XS_BIND_TO;
@@ -2856,7 +2874,6 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = IPPROTO_UDP;
-	xprt->tsh_size = 0;
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
@@ -2936,7 +2953,6 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = IPPROTO_TCP;
-	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
 	xprt->bind_timeout = XS_BIND_TO;
@@ -3009,7 +3025,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = IPPROTO_TCP;
-	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 	xprt->timeout = &xs_tcp_default_timeout;
 

