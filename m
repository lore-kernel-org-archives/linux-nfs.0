Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C92EC169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 696EB218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ope1dsU/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728812AbfBKQZj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:25:39 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36817 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728692AbfBKQZj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:25:39 -0500
Received: by mail-it1-f193.google.com with SMTP id c9so27714631itj.1;
        Mon, 11 Feb 2019 08:25:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=I38fChzTVDZah9FeYvUpriEqPAk8ShJ/ljnYltjyp00=;
        b=Ope1dsU/lvMHHjMmMb6i7hfhIZQ+qESHMOTyQNOP8U5pVzSQjGQHPMrrT87jWrhAeA
         8k0dJIc/UDIig0HV9ACmRVmSgiOnbYOm8M9tDVSnVabAW6usaD1c26yb4jmVSilKPYiV
         2+vApKZ9vZulzeml2pVf84flVYodcevzG4UaFwsgQOiqv6itq9DYR4xNkMStx/DtQgcx
         Dc02T/ngDkWKM6mGmhGWJn5Ieb3HVdvFDK/ObO8bsfArMd1p6bq4qqh1nFUBmnfvWiB9
         BXjfy5zdsewj/vMnJt73Q6ZozQSQ0w25emiTER35/f4ZMQgJEsqqgoKn5hpHe8evc8y8
         F6HQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=I38fChzTVDZah9FeYvUpriEqPAk8ShJ/ljnYltjyp00=;
        b=K4uJQaHAXaE54gjJaIYfMduh+QlBQYdnWrEGfmcdzGi+PbEcVjJB/CESzxRxFHvKMi
         pak+L96poCT7xBiQAzD+a3y2Pi+L2O/5my1f9OECsjWh2QK9qvkISq9USwFTPcDZ3aWg
         KXSk9PZ4Jl3filW8PSekDkd2vjXDjktqohIgvLHhECHsFhAKYtHNw0Qpb+CQ8tWPn2JD
         24NGZTV40rT+czrtfxPzJibF3SIAaD9o9sqmgKIxcN0OMhk8zOTBJK3ROF+SKLLN7SR9
         ygS1gKTW4cxn0z23J0JEDLaSImSsp3rHZuWr/oZa+FfUfxWfInNo74dwJS6hWdDdxIOr
         4P7Q==
X-Gm-Message-State: AHQUAuYuvbHMf21brfU2Y4ovU1Wh3Y2qCKvjod06RWV33dnUFkv/FtpV
        8JrwGh74a49c4bUNLMQsSVNBhPUY
X-Google-Smtp-Source: AHgI3IaKZG2SwPmuilyrDUKzVX8oYbDmvDK6UWQa76yUT50qGGQuUuks4q8WUSMQ1ybh82wBhnqiVw==
X-Received: by 2002:a6b:398b:: with SMTP id g133mr19616424ioa.160.1549902337940;
        Mon, 11 Feb 2019 08:25:37 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 24sm4671553iog.25.2019.02.11.08.25.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:25:37 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGPaFR030018;
        Mon, 11 Feb 2019 16:25:36 GMT
Subject: [PATCH v1 22/23] SUNRPC: Add rpc_auth::au_ralign field
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:25:36 -0500
Message-ID: <20190211162536.2817.90001.stgit@manet.1015granger.net>
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

Currently rpc_inline_rcv_pages() uses au_rslack to estimate the
size of the upper layer reply header. This is fine for auth flavors
where au_verfsize == au_rslack.

However, some auth flavors have more going on. krb5i for example has
two more words after the verifier, and another blob following the
RPC message. The calculation involving au_rslack pushes the upper
layer reply header too far into the rcv_buf.

au_rslack is still valuable: it's the amount of buffer space needed
for the reply, and is used when allocating the reply buffer. We'll
keep that.

But, add a new field that can be used to properly estimate the
location of the upper layer header in each RPC reply, based on the
auth flavor in use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/auth.h    |    9 ++++-----
 net/sunrpc/auth_gss/auth_gss.c |   18 +++++++++++++-----
 net/sunrpc/auth_null.c         |    1 +
 net/sunrpc/auth_unix.c         |    1 +
 net/sunrpc/clnt.c              |    2 +-
 5 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 359dfdd..5f9076f 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -74,13 +74,12 @@ struct rpc_cred {
 struct rpc_authops;
 struct rpc_auth {
 	unsigned int		au_cslack;	/* call cred size estimate */
-				/* guess at number of u32's auth adds before
-				 * reply data; normally the verifier size: */
-	unsigned int		au_rslack;
+	unsigned int		au_rslack;	/* reply cred size estimate */
 	unsigned int		au_verfsize;	/* size of reply verifier */
+	unsigned int		au_ralign;	/* words before UL header */
 
-	unsigned int		au_flags;	/* various flags */
-	const struct rpc_authops *au_ops;		/* operations */
+	unsigned int		au_flags;
+	const struct rpc_authops *au_ops;
 	rpc_authflavor_t	au_flavor;	/* pseudoflavor (note may
 						 * differ from the flavor in
 						 * au_ops->au_flavor in gss
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 731e7a4..c67e2ad 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1017,6 +1017,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 	auth->au_cslack = GSS_CRED_SLACK >> 2;
 	auth->au_rslack = GSS_VERF_SLACK >> 2;
 	auth->au_verfsize = GSS_VERF_SLACK >> 2;
+	auth->au_ralign = GSS_VERF_SLACK >> 2;
 	auth->au_flags = 0;
 	auth->au_ops = &authgss_ops;
 	auth->au_flavor = flavor;
@@ -1891,7 +1892,10 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 static int
 gss_unwrap_resp_auth(struct rpc_cred *cred)
 {
-	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize;
+	struct rpc_auth *auth = cred->cr_auth;
+
+	auth->au_rslack = auth->au_verfsize;
+	auth->au_ralign = auth->au_verfsize;
 	return 0;
 }
 
@@ -1902,6 +1906,7 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct xdr_buf integ_buf, *rcv_buf = &rqstp->rq_rcv_buf;
 	u32 data_offset, mic_offset, integ_len, maj_stat;
+	struct rpc_auth *auth = cred->cr_auth;
 	struct xdr_netobj mic;
 	__be32 *p;
 
@@ -1928,8 +1933,8 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	if (maj_stat != GSS_S_COMPLETE)
 		goto bad_mic;
 
-	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + 2 +
-				   1 + XDR_QUADLEN(mic.len);
+	auth->au_rslack = auth->au_verfsize + 2 + 1 + XDR_QUADLEN(mic.len);
+	auth->au_ralign = auth->au_verfsize + 2;
 	return 0;
 unwrap_failed:
 	trace_rpcgss_unwrap_failed(task);
@@ -1949,6 +1954,7 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct xdr_buf *rcv_buf = &rqstp->rq_rcv_buf;
 	struct kvec *head = rqstp->rq_rcv_buf.head;
+	struct rpc_auth *auth = cred->cr_auth;
 	unsigned int savedlen = rcv_buf->len;
 	u32 offset, opaque_len, maj_stat;
 	__be32 *p;
@@ -1976,8 +1982,10 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	 */
 	xdr_init_decode(xdr, rcv_buf, p, rqstp);
 
-	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + 2 +
-				   XDR_QUADLEN(savedlen - rcv_buf->len);
+	auth->au_rslack = auth->au_verfsize + 2 +
+			  XDR_QUADLEN(savedlen - rcv_buf->len);
+	auth->au_ralign = auth->au_verfsize + 2 +
+			  XDR_QUADLEN(savedlen - rcv_buf->len);
 	return 0;
 unwrap_failed:
 	trace_rpcgss_unwrap_failed(task);
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 9ae0824..41a633a 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -115,6 +115,7 @@ struct rpc_auth null_auth = {
 	.au_cslack	= NUL_CALLSLACK,
 	.au_rslack	= NUL_REPLYSLACK,
 	.au_verfsize	= NUL_REPLYSLACK,
+	.au_ralign	= NUL_REPLYSLACK,
 	.au_ops		= &authnull_ops,
 	.au_flavor	= RPC_AUTH_NULL,
 	.au_count	= REFCOUNT_INIT(1),
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index a93c564..c048eb6 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -187,6 +187,7 @@
 
 	auth->au_verfsize = XDR_QUADLEN(size) + 2;
 	auth->au_rslack = XDR_QUADLEN(size) + 2;
+	auth->au_ralign = XDR_QUADLEN(size) + 2;
 	return 0;
 }
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4ea38b0..99bfeb1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1180,7 +1180,7 @@ void rpc_prepare_reply_pages(struct rpc_rqst *req, struct page **pages,
 	/* Subtract one to force an extra word of buffer space for the
 	 * payload's XDR pad to fall into the rcv_buf's tail iovec.
 	 */
-	hdrsize += RPC_REPHDRSIZE + req->rq_cred->cr_auth->au_rslack - 1;
+	hdrsize += RPC_REPHDRSIZE + req->rq_cred->cr_auth->au_ralign - 1;
 
 	xdr_inline_pages(&req->rq_rcv_buf, hdrsize << 2, pages, base, len);
 	trace_rpc_reply_pages(req);

