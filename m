Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38273C282C2
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:36:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F036C20811
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:36:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IBSUUguZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730831AbfBFQg5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 11:36:57 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:55073 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730678AbfBFQg5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2019 11:36:57 -0500
Received: by mail-it1-f196.google.com with SMTP id i145so7585964ita.4
        for <linux-nfs@vger.kernel.org>; Wed, 06 Feb 2019 08:36:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ni8Ebgf4CrraYTR402x+jTubCAGP2TtYigExe5dKhvM=;
        b=IBSUUguZAssdYmsjxwzjTpVRploPttO+aPuOReLOh9lWNaetVrCTAYp3a1OBPuOXff
         WFukK51YhRmBmralqYhQ+DAumPEWSJBUPA5DcqI7dXTu1ytnWvqMmZURii4M14bh1QIh
         YlDPWwngQAPeG1pCwXLreRGbTN1ySjqi2XIhfaH6F8M4CX9FmmhCk3FgbXI9hfa5rqgc
         +KgeRmtvrlEAVQMEpW5l7t3QkzlfHsn3vXe9PZGfrXrSur8zpo2CAUVeTUi4HWiznkLc
         dKio32BqjvrL0L2mNOMnHvmGkhMUXhncJcq5P5Grgul19vZGFmiwCYfn1tO4xzTfnms5
         OGxA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ni8Ebgf4CrraYTR402x+jTubCAGP2TtYigExe5dKhvM=;
        b=ad0QTd6XvsxXfz0XM2ge2PcR/SAosdVVL43VywwO9BGxZX+lJakdCeRo4mYy9o2HNR
         vtfu4TlBu2LnPUcepc3bIShNN2jfzH/DwyV2PL5sQjo+xNh5MLu3yKpmyEqtXXBgX+Ep
         Zso0PAUAxbzA1kOn3uKgL0iKBjbzdo/8Ft9oEwhmoUk6rIe85LTL+GEi28mhC/tb0sO4
         QPSkY30+OBPvgA1hPouwI6gCTbqrrT22toinU62jU77CEsG+IHMeWBizeB0bjZhRvO1A
         s1eXCKtNEXzjKTVAOc26RIl+oM2rzKnTbmjegDBO30/lfmBSGh7sY8OlWZQQX56uuZLY
         5q8w==
X-Gm-Message-State: AHQUAubcaSRD65jpwl2StmBZ32/HUZwMWK7jDA5f+u7eF9XN3FPmprS1
        ewK/nYQgb9RXjxJlft+cGHfw4oei
X-Google-Smtp-Source: AHgI3IYNSEnviYyjnkSIkfZcmLwoAmJKY+ucSKREikKIuoTyfY3YjX37rlxzCu/ccVJlGLksjquiig==
X-Received: by 2002:a02:94eb:: with SMTP id x98mr6068721jah.88.1549471015497;
        Wed, 06 Feb 2019 08:36:55 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id e19sm2711455iob.70.2019.02.06.08.36.54
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:36:55 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x16Gasre015987
        for <linux-nfs@vger.kernel.org>; Wed, 6 Feb 2019 16:36:54 GMT
Subject: [PATCH RFC 1/5] SUNRPC: Introduce rpc_prepare_reply_pages()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 06 Feb 2019 11:36:54 -0500
Message-ID: <20190206163654.16810.48449.stgit@manet.1015granger.net>
In-Reply-To: <20190206163256.16810.62516.stgit@manet.1015granger.net>
References: <20190206163256.16810.62516.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

prepare_reply_buffer() and its NFSv4 equivalents expose the details
of the RPC header and the auth slack values to upper layer
consumers, creating a layering violation, and duplicating code.

Remedy these issues by adding a new RPC client API that hides those
details from upper layers in a common helper function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs2xdr.c              |   27 +++++-----------------
 fs/nfs/nfs3xdr.c              |   29 ++++++-----------------
 fs/nfs/nfs4xdr.c              |   51 +++++++++++++++++------------------------
 include/linux/sunrpc/clnt.h   |    3 ++
 include/trace/events/sunrpc.h |   37 ++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c             |   19 +++++++++++++++
 net/sunrpc/xdr.c              |    9 +++++++
 7 files changed, 102 insertions(+), 73 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index bac3a4e..1dcd0fe 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -66,21 +66,6 @@
 static int nfs_stat_to_errno(enum nfs_stat);
 
 /*
- * While encoding arguments, set up the reply buffer in advance to
- * receive reply data directly into the page cache.
- */
-static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
-				 unsigned int base, unsigned int len,
-				 unsigned int bufsize)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
-	unsigned int replen;
-
-	replen = RPC_REPHDRSIZE + auth->au_rslack + bufsize;
-	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, pages, base, len);
-}
-
-/*
  * Encode/decode NFSv2 basic data types
  *
  * Basic NFSv2 data types are defined in section 2.3 of RFC 1094:
@@ -593,8 +578,8 @@ static void nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req,
 	const struct nfs_readlinkargs *args = data;
 
 	encode_fhandle(xdr, args->fh);
-	prepare_reply_buffer(req, args->pages, args->pgbase,
-					args->pglen, NFS_readlinkres_sz);
+	rpc_prepare_reply_pages(req, args->pages, args->pgbase,
+				args->pglen, NFS_readlinkres_sz);
 }
 
 /*
@@ -629,8 +614,8 @@ static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
 	const struct nfs_pgio_args *args = data;
 
 	encode_readargs(xdr, args);
-	prepare_reply_buffer(req, args->pages, args->pgbase,
-					args->count, NFS_readres_sz);
+	rpc_prepare_reply_pages(req, args->pages, args->pgbase,
+				args->count, NFS_readres_sz);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 }
 
@@ -787,8 +772,8 @@ static void nfs2_xdr_enc_readdirargs(struct rpc_rqst *req,
 	const struct nfs_readdirargs *args = data;
 
 	encode_readdirargs(xdr, args);
-	prepare_reply_buffer(req, args->pages, 0,
-					args->count, NFS_readdirres_sz);
+	rpc_prepare_reply_pages(req, args->pages, 0,
+				args->count, NFS_readdirres_sz);
 }
 
 /*
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 4aa3ffe..a54dcf4 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -105,21 +105,6 @@
 };
 
 /*
- * While encoding arguments, set up the reply buffer in advance to
- * receive reply data directly into the page cache.
- */
-static void prepare_reply_buffer(struct rpc_rqst *req, struct page **pages,
-				 unsigned int base, unsigned int len,
-				 unsigned int bufsize)
-{
-	struct rpc_auth	*auth = req->rq_cred->cr_auth;
-	unsigned int replen;
-
-	replen = RPC_REPHDRSIZE + auth->au_rslack + bufsize;
-	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, pages, base, len);
-}
-
-/*
  * Encode/decode NFSv3 basic data types
  *
  * Basic NFSv3 data types are defined in section 2.5 of RFC 1813:
@@ -910,8 +895,8 @@ static void nfs3_xdr_enc_readlink3args(struct rpc_rqst *req,
 	const struct nfs3_readlinkargs *args = data;
 
 	encode_nfs_fh3(xdr, args->fh);
-	prepare_reply_buffer(req, args->pages, args->pgbase,
-					args->pglen, NFS3_readlinkres_sz);
+	rpc_prepare_reply_pages(req, args->pages, args->pgbase,
+				args->pglen, NFS3_readlinkres_sz);
 }
 
 /*
@@ -943,8 +928,8 @@ static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
 	unsigned int replen = args->replen ? args->replen : NFS3_readres_sz;
 
 	encode_read3args(xdr, args);
-	prepare_reply_buffer(req, args->pages, args->pgbase,
-					args->count, replen);
+	rpc_prepare_reply_pages(req, args->pages, args->pgbase,
+				args->count, replen);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 }
 
@@ -1236,7 +1221,7 @@ static void nfs3_xdr_enc_readdir3args(struct rpc_rqst *req,
 	const struct nfs3_readdirargs *args = data;
 
 	encode_readdir3args(xdr, args);
-	prepare_reply_buffer(req, args->pages, 0,
+	rpc_prepare_reply_pages(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
 }
 
@@ -1278,7 +1263,7 @@ static void nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req,
 	const struct nfs3_readdirargs *args = data;
 
 	encode_readdirplus3args(xdr, args);
-	prepare_reply_buffer(req, args->pages, 0,
+	rpc_prepare_reply_pages(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
 }
 
@@ -1323,7 +1308,7 @@ static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
 	encode_nfs_fh3(xdr, args->fh);
 	encode_uint32(xdr, args->mask);
 	if (args->mask & (NFS_ACL | NFS_DFACL)) {
-		prepare_reply_buffer(req, args->pages, 0,
+		rpc_prepare_reply_pages(req, args->pages, 0,
 					NFSACL_MAXPAGES << PAGE_SHIFT,
 					ACL3_getaclres_sz);
 		req->rq_rcv_buf.flags |= XDRBUF_SPARSE_PAGES;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 38a4cbc..d0fa18d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1016,12 +1016,11 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 				struct compound_hdr *hdr)
 {
 	__be32 *p;
-	struct rpc_auth *auth = req->rq_cred->cr_auth;
 
 	/* initialize running count of expected bytes in reply.
 	 * NOTE: the replied tag SHOULD be the same is the one sent,
 	 * but this is not required as a MUST for the server to do so. */
-	hdr->replen = RPC_REPHDRSIZE + auth->au_rslack + 3 + hdr->taglen;
+	hdr->replen = 3 + hdr->taglen;
 
 	WARN_ON_ONCE(hdr->taglen > NFS4_MAXTAGLEN);
 	encode_string(xdr, hdr->taglen, hdr->tag);
@@ -2341,9 +2340,9 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	if (args->lg_args) {
 		encode_layoutget(xdr, args->lg_args, &hdr);
-		xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
-				 args->lg_args->layout.pages,
-				 0, args->lg_args->layout.pglen);
+		rpc_prepare_reply_pages(req, args->lg_args->layout.pages, 0,
+					args->lg_args->layout.pglen,
+					hdr.replen);
 	}
 	encode_nops(&hdr);
 }
@@ -2387,9 +2386,9 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	if (args->lg_args) {
 		encode_layoutget(xdr, args->lg_args, &hdr);
-		xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
-				 args->lg_args->layout.pages,
-				 0, args->lg_args->layout.pglen);
+		rpc_prepare_reply_pages(req, args->lg_args->layout.pages, 0,
+					args->lg_args->layout.pglen,
+					hdr.replen);
 	}
 	encode_nops(&hdr);
 }
@@ -2499,8 +2498,8 @@ static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_readlink(xdr, args, req, &hdr);
 
-	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, args->pages,
-			args->pgbase, args->pglen);
+	rpc_prepare_reply_pages(req, args->pages, args->pgbase,
+				args->pglen, hdr.replen);
 	encode_nops(&hdr);
 }
 
@@ -2520,11 +2519,8 @@ static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_readdir(xdr, args, req, &hdr);
 
-	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, args->pages,
-			 args->pgbase, args->count);
-	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
-			__func__, hdr.replen << 2, args->pages,
-			args->pgbase, args->count);
+	rpc_prepare_reply_pages(req, args->pages, args->pgbase,
+				args->count, hdr.replen);
 	encode_nops(&hdr);
 }
 
@@ -2544,8 +2540,8 @@ static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_read(xdr, args, &hdr);
 
-	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
-			 args->pages, args->pgbase, args->count);
+	rpc_prepare_reply_pages(req, args->pages, args->pgbase,
+				args->count, hdr.replen);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 	encode_nops(&hdr);
 }
@@ -2591,9 +2587,8 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getattr(xdr, nfs4_acl_bitmap, NULL,
 			ARRAY_SIZE(nfs4_acl_bitmap), &hdr);
 
-	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
-		args->acl_pages, 0, args->acl_len);
-
+	rpc_prepare_reply_pages(req, args->acl_pages, 0,
+				args->acl_len, replen);
 	encode_nops(&hdr);
 }
 
@@ -2814,9 +2809,8 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 		encode_fs_locations(xdr, args->bitmask, &hdr);
 	}
 
-	/* Set up reply kvec to capture returned fs_locations array. */
-	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
-			 (struct page **)&args->page, 0, PAGE_SIZE);
+	rpc_prepare_reply_pages(req, (struct page **)&args->page, 0,
+				PAGE_SIZE, replen);
 	encode_nops(&hdr);
 }
 
@@ -3018,10 +3012,8 @@ static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
 
 	/* set up reply kvec. Subtract notification bitmap max size (2)
 	 * so that notification bitmap is put in xdr_buf tail */
-	xdr_inline_pages(&req->rq_rcv_buf, (hdr.replen - 2) << 2,
-			 args->pdev->pages, args->pdev->pgbase,
-			 args->pdev->pglen);
-
+	rpc_prepare_reply_pages(req, args->pdev->pages, args->pdev->pgbase,
+				args->pdev->pglen, hdr.replen - 2);
 	encode_nops(&hdr);
 }
 
@@ -3042,9 +3034,8 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
 	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
 	encode_layoutget(xdr, args, &hdr);
 
-	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
-	    args->layout.pages, 0, args->layout.pglen);
-
+	rpc_prepare_reply_pages(req, args->layout.pages, 0,
+				args->layout.pglen, hdr.replen);
 	encode_nops(&hdr);
 }
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 1c44171..98bc988 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -169,6 +169,9 @@ int		rpcb_v4_register(struct net *net, const u32 program,
 				 const char *netid);
 void		rpcb_getport_async(struct rpc_task *);
 
+void rpc_prepare_reply_pages(struct rpc_rqst *req, struct page **pages,
+			     unsigned int base, unsigned int len,
+			     unsigned int hdrsize);
 void		rpc_call_start(struct rpc_task *);
 int		rpc_call_async(struct rpc_clnt *clnt,
 			       const struct rpc_message *msg, int flags,
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index e58dda8..8451f30 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -461,6 +461,43 @@
 	)
 );
 
+TRACE_EVENT(rpc_reply_pages,
+	TP_PROTO(
+		const struct rpc_rqst *req
+	),
+
+	TP_ARGS(req),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(const void *, head_base)
+		__field(size_t, head_len)
+		__field(const void *, tail_base)
+		__field(size_t, tail_len)
+		__field(unsigned int, page_len)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = req->rq_task->tk_pid;
+		__entry->client_id = req->rq_task->tk_client->cl_clid;
+
+		__entry->head_base = req->rq_rcv_buf.head[0].iov_base;
+		__entry->head_len = req->rq_rcv_buf.head[0].iov_len;
+		__entry->page_len = req->rq_rcv_buf.page_len;
+		__entry->tail_base = req->rq_rcv_buf.tail[0].iov_base;
+		__entry->tail_len = req->rq_rcv_buf.tail[0].iov_len;
+	),
+
+	TP_printk(
+		"task:%u@%u xdr=[%p,%zu]/%u/[%p,%zu]\n",
+		__entry->task_id, __entry->client_id,
+		__entry->head_base, __entry->head_len,
+		__entry->page_len,
+		__entry->tail_base, __entry->tail_len
+	)
+);
+
 /*
  * First define the enums in the below macros to be exported to userspace
  * via TRACE_DEFINE_ENUM().
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 803e931..f780605 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1164,6 +1164,25 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
+/**
+ * rpc_prepare_reply_pages - Prepare to receive a reply data payload into pages
+ * @req: RPC request to prepare
+ * @pages: vector of struct page pointers
+ * @base: offset in first page where receive should start, in bytes
+ * @len: expected size of the upper layer data payload, in bytes
+ * @hdrsize: expected size of upper layer reply header, in XDR words
+ *
+ */
+void rpc_prepare_reply_pages(struct rpc_rqst *req, struct page **pages,
+			     unsigned int base, unsigned int len,
+			     unsigned int hdrsize)
+{
+	hdrsize += RPC_REPHDRSIZE + req->rq_cred->cr_auth->au_rslack;
+	xdr_inline_pages(&req->rq_rcv_buf, hdrsize << 2, pages, base, len);
+	trace_rpc_reply_pages(req);
+}
+EXPORT_SYMBOL_GPL(rpc_prepare_reply_pages);
+
 void
 rpc_call_start(struct rpc_task *task)
 {
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4bce619..7cca515 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -163,6 +163,15 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
 	buf->bvec = NULL;
 }
 
+/**
+ * xdr_inline_pages - Prepare receive buffer for a large reply
+ * @xdr: xdr_buf into which reply will be placed
+ * @offset: expected offset where data payload will start, in bytes
+ * @pages: vector of struct page pointers
+ * @base: offset in first page where receive should start, in bytes
+ * @len: expected size of the upper layer data payload, in bytes
+ *
+ */
 void
 xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
 		 struct page **pages, unsigned int base, unsigned int len)

