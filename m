Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5BBEC10F00
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 00:20:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A5A8C20842
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 00:20:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oDD3ocuM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725985AbfCDAUi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Mar 2019 19:20:38 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:34331 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725962AbfCDAUi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Mar 2019 19:20:38 -0500
Received: by mail-io1-f65.google.com with SMTP id e1so2669661iok.1
        for <linux-nfs@vger.kernel.org>; Sun, 03 Mar 2019 16:20:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=eRXQ0LgSa+pW3rznCRL9/8rJU0QHTXA1XY+8DpU/xCI=;
        b=oDD3ocuM+z3lOz4ruU+O86ubiyL+7ix1euN088yJYF5cSOMpsnQDyWrDBhL5Myz9Ig
         7XPGM2euFjurG1+Nd56LkeSheZcyfkJ09tDJWIyN35m3KCo8JaLrhu5kdqiKwRWD6hte
         0wPdQDbWnx1ftHkKNnXZEcNfj+MDf+ZNbd3xW/m1Wq/kHhdZod8VX5unzpGCVycknNgl
         oDl/GFCBFTX69fc2Reh/0tUJ6jr5+tKcvx7sezP4i3xIn1nI7MMaN41fvN5D7LJWoVVs
         c8RUVQU/5vxIoRZGUv1HszqllkEkzzCF2QGzdtvesz3iexwujBV+By1lDyfFuymk0zO/
         rr/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=eRXQ0LgSa+pW3rznCRL9/8rJU0QHTXA1XY+8DpU/xCI=;
        b=D4l+jDd+wKouQs9menXquJuEnQJwSzyYIRIvqHzycZY10EHvyQJFLEFPcruiG1jv+K
         TXdhxePFFuwDXbWqB+jaIO2STX2Xq9mvy04OBWoj3KL8zQosEDozpik7XhhQlm3yno07
         GCsiaNe1yhb0UtuEmZpF0AODjXuWJquVSUV6Wtce84hFsXYsArfUvjqPdyA6Lu60FuiF
         HJoJr7rGu7SET63ZhuAWGWn7Q/Gwn/5SQVMJwF9JaVv9Jt1YHLiGR2IFPnA/QMqD5Z/X
         eWSOz2hwX5BXlmLpXLajUP0C1twVnQ51IayHWX8oWDU4V2N2U+g2x3yOeoklWBcbcbT+
         XMBw==
X-Gm-Message-State: APjAAAWMNTRK4rIoDLC2JVGUqQb2+LVFk1x+F5J250DxEvzLhfpb8lwA
        jymn0rKKD7QCd1d1hw7ccnjaJqk=
X-Google-Smtp-Source: APXvYqyL1jI5R3kNQ3fcl1CkFlvaNawVe59W9PDE+DM+NEitJqcyaAdVzMSa72SED43OlzJyG3BsJw==
X-Received: by 2002:a5d:9455:: with SMTP id x21mr8920032ior.250.1551658836711;
        Sun, 03 Mar 2019 16:20:36 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id i5sm2430350itb.3.2019.03.03.16.20.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Mar 2019 16:20:35 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] SUNRPC: Convert remaining GFP_NOIO, and GFP_NOWAIT sites in sunrpc
Date:   Sun,  3 Mar 2019 19:19:26 -0500
Message-Id: <20190304001928.4397-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Convert the remaining gfp_flags arguments in sunrpc to standard reclaiming
allocations, now that we set memalloc_nofs_save() as appropriate.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 2 +-
 net/sunrpc/sched.c             | 7 ++-----
 net/sunrpc/xprtsock.c          | 4 ++--
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index c67e2ad151ae..3fd56c0c90ae 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1208,7 +1208,7 @@ gss_dup_cred(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	struct gss_cred *new;
 
 	/* Make a copy of the cred so that we can reference count it */
-	new = kzalloc(sizeof(*gss_cred), GFP_NOIO);
+	new = kzalloc(sizeof(*gss_cred), GFP_NOFS);
 	if (new) {
 		struct auth_cred acred = {
 			.cred = gss_cred->gc_base.cr_cred,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 2168d4d9c09f..f21557213a43 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -925,16 +925,13 @@ static void rpc_async_schedule(struct work_struct *work)
  * Most requests are 'small' (under 2KiB) and can be serviced from a
  * mempool, ensuring that NFS reads and writes can always proceed,
  * and that there is good locality of reference for these buffers.
- *
- * In order to avoid memory starvation triggering more writebacks of
- * NFS requests, we avoid using GFP_KERNEL.
  */
 int rpc_malloc(struct rpc_task *task)
 {
 	struct rpc_rqst *rqst = task->tk_rqstp;
 	size_t size = rqst->rq_callsize + rqst->rq_rcvsize;
 	struct rpc_buffer *buf;
-	gfp_t gfp = GFP_NOIO | __GFP_NOWARN;
+	gfp_t gfp = GFP_NOFS;
 
 	if (RPC_IS_SWAPPER(task))
 		gfp = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
@@ -1015,7 +1012,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e829036ed81f..42f45d33dc56 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -423,7 +423,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 
 	want = xs_alloc_sparse_pages(buf,
 			min_t(size_t, count - offset, buf->page_len),
-			GFP_NOWAIT);
+			GFP_KERNEL);
 	if (seek < want) {
 		ret = xs_read_bvec(sock, msg, flags, buf->bvec,
 				xdr_buf_pagecount(buf),
@@ -909,7 +909,7 @@ static int xs_nospace(struct rpc_rqst *req)
 static void
 xs_stream_prepare_request(struct rpc_rqst *req)
 {
-	req->rq_task->tk_status = xdr_alloc_bvec(&req->rq_rcv_buf, GFP_NOIO);
+	req->rq_task->tk_status = xdr_alloc_bvec(&req->rq_rcv_buf, GFP_KERNEL);
 }
 
 /*
-- 
2.20.1

