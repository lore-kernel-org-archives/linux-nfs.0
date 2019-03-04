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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AA9EC4360F
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 00:20:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3C96420835
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 00:20:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y0sTf1Zd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725993AbfCDAUj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Mar 2019 19:20:39 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:36365 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725984AbfCDAUj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Mar 2019 19:20:39 -0500
Received: by mail-io1-f65.google.com with SMTP id r136so2657883iod.3
        for <linux-nfs@vger.kernel.org>; Sun, 03 Mar 2019 16:20:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ueab9x7zbfUZEVoknAUL26f3TY/HO5dzaVBV1Dqvi04=;
        b=Y0sTf1ZdvEmGlm+hBigWVwx45gPR3eMD7dynANGC1mmiBpXPQ0YtueS9K2PUG/I2D0
         eNO4YhrPuwPP+9mGd4Ewo6iSPDnkkEm4rJF1CD5yG4HF/+gwHLO+qr25gM949q9LoUes
         gU8a91egCraVwCklQbpCcKPD1TbZfNPq9UVhMlXKvTH1BnwmoHm5rzJRpeV31GdiSgyR
         5KwfMBNwPkZo93ZvWmZBoBYavnvG6CPtcM5C9/DLNZcRygq4BudSWg8JExtNt/EvI90C
         YcMalJCc6GDIFUff8n2dZHFR3i2x3OAVEJT94XpmxfpfXGMpdEZS2VJxVxPZLmkF3TQc
         5Ryg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Ueab9x7zbfUZEVoknAUL26f3TY/HO5dzaVBV1Dqvi04=;
        b=o8h+wOUHOA3BjuIt4dVnTaYa72qTJJFfcMSH+djg6fl3JqrNIC+DkR+p/6d69W7nSj
         k/a5BT3hDPHZhkIc6m4V6s8zpTQzD+X4HM/Ehn+IlBPhKnNwZ7aJVnRSQ5UcKLOFQNTS
         K0hjn+4jYc+HsFXWN2LGG0rJ0vmGVYBIpOIacwCySLgNsj0dd1PCwf1QPcGkZFsa7bvX
         3fdPrgP0/jWlPeFr+C+OR27yU8Hw2Zzg5oE8xLLBFwgNbVLjZ0IpvwOJAQ/WOFF7kfHQ
         ID6BZ4HxuMuifoUZQPV/YcMuIHF1ONzvYger1TUPMLVyfP3vLo0894CJ8dwOOvnZYVLA
         h3cA==
X-Gm-Message-State: APjAAAU2x4aMPtu+zSTQBAxdwTYdam12S9ePYu3O9fvmz+Rv+IY8wWRC
        HEUYsiSGcyKbqKvjJ2El0UN/F08=
X-Google-Smtp-Source: APXvYqx+2WH8N7awUGVCEd5QN8enoEiGzk9U1XG5VQ4UpzbwBb6Y8P48M6pxhtyWYPgkS4oCV7q1gw==
X-Received: by 2002:a6b:c542:: with SMTP id v63mr8987612iof.176.1551658838270;
        Sun, 03 Mar 2019 16:20:38 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id i5sm2430350itb.3.2019.03.03.16.20.37
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Mar 2019 16:20:37 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] SUNRPC: Allow dynamic allocation of back channel slots
Date:   Sun,  3 Mar 2019 19:19:28 -0500
Message-Id: <20190304001928.4397-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190304001928.4397-2-trond.myklebust@hammerspace.com>
References: <20190304001928.4397-1-trond.myklebust@hammerspace.com>
 <20190304001928.4397-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Now that the reads happen in a process context rather than a softirq,
it is safe to allocate back channel slots using a reclaiming
allocation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/backchannel_rqst.c | 41 +++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index b9313c15ee3a..c47d82622fd1 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -235,7 +235,8 @@ void xprt_destroy_bc(struct rpc_xprt *xprt, unsigned int max_reqs)
 		list_empty(&xprt->bc_pa_list) ? "true" : "false");
 }
 
-static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
+static struct rpc_rqst *xprt_get_bc_request(struct rpc_xprt *xprt, __be32 xid,
+		struct rpc_rqst *new)
 {
 	struct rpc_rqst *req = NULL;
 
@@ -243,10 +244,9 @@ static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
 	if (atomic_read(&xprt->bc_free_slots) <= 0)
 		goto not_found;
 	if (list_empty(&xprt->bc_pa_list)) {
-		req = xprt_alloc_bc_req(xprt, GFP_ATOMIC);
-		if (!req)
+		if (!new)
 			goto not_found;
-		list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
+		list_add_tail(&new->rq_bc_pa_list, &xprt->bc_pa_list);
 		xprt->bc_alloc_count++;
 	}
 	req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
@@ -256,8 +256,8 @@ static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
 			sizeof(req->rq_private_buf));
 	req->rq_xid = xid;
 	req->rq_connect_cookie = xprt->connect_cookie;
-not_found:
 	dprintk("RPC:       backchannel req=%p\n", req);
+not_found:
 	return req;
 }
 
@@ -320,18 +320,27 @@ void xprt_free_bc_rqst(struct rpc_rqst *req)
  */
 struct rpc_rqst *xprt_lookup_bc_request(struct rpc_xprt *xprt, __be32 xid)
 {
-	struct rpc_rqst *req;
-
-	spin_lock(&xprt->bc_pa_lock);
-	list_for_each_entry(req, &xprt->bc_pa_list, rq_bc_pa_list) {
-		if (req->rq_connect_cookie != xprt->connect_cookie)
-			continue;
-		if (req->rq_xid == xid)
-			goto found;
-	}
-	req = xprt_alloc_bc_request(xprt, xid);
+	struct rpc_rqst *req, *new = NULL;
+
+	do {
+		spin_lock(&xprt->bc_pa_lock);
+		list_for_each_entry(req, &xprt->bc_pa_list, rq_bc_pa_list) {
+			if (req->rq_connect_cookie != xprt->connect_cookie)
+				continue;
+			if (req->rq_xid == xid)
+				goto found;
+		}
+		req = xprt_get_bc_request(xprt, xid, new);
 found:
-	spin_unlock(&xprt->bc_pa_lock);
+		spin_unlock(&xprt->bc_pa_lock);
+		if (new) {
+			if (req != new)
+				xprt_free_bc_rqst(new);
+			break;
+		} else if (req)
+			break;
+		new = xprt_alloc_bc_req(xprt, GFP_KERNEL);
+	} while (new);
 	return req;
 }
 
-- 
2.20.1

