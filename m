Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFFFFC64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:50:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 91E922082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:50:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y7lpDtr7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E922082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726641AbeLAKBR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 05:01:17 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:46501 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726474AbeLAKBR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 05:01:17 -0500
Received: by mail-io1-f68.google.com with SMTP id v10so5824296ios.13
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 14:50:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0obpUWGDNnnecsPzS8P4okftDrsdGX3X7RmIPPZQtt4=;
        b=Y7lpDtr7mmuIznuwsW38LbMd+Xx7g+hhZ5B780F6AhgAOjuR5XLq32sXACjpU0D4GN
         anILOYs2xOe0uP4tNmWKPfTgLSNqqk9XFUksL8/7l/7X1e6Cw4hy9lUioTCDKDG+XGiU
         emXwzx7Gv5RtQjx0AhKMzt1YA1b1tIxcr9k+ejdcS9mAaqiAazq26UdwJ1sKtLVLSp8y
         6ofrTDQeZm25kOCsTkYtB8r6DE++CkgeIO1WOzdvPk1lA68SBk1mJEs9iR9xXIzQQCOc
         uSull7FGbdNJT53sUNt7IOW7NPCvpKLWTzftBJ/duMrOIlTTRm1A2bAf32oJSpq64Yzs
         Ujlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=0obpUWGDNnnecsPzS8P4okftDrsdGX3X7RmIPPZQtt4=;
        b=M/xWtiZGik+MGpx4uh98pMI+svCLqfSW8IHmPEhZNgtyeUWI5l1WuuSayCO0z7OAW0
         1jvJ0qCf0tefOZwdx75CvoLxBEXSaUW8HLqRuAemdGTpTWBojJh6xT4EHLPhUetnMMBu
         IiyE7aUz/WY1/ZhU/Gkbbg2OR3tAAO0rMk9/bTQpLMyXmOgwNEPpAudpRFWhAQLlHBBF
         LdFav6+UVvM9qSpmGzlsTaxUwxD2roZHIx2vmu9dPuc+95C1bN8F/Or5GVXqQVDDG7FB
         Bfy+2oIjJywWdnWHRVRVLgzFxcIl90PzzSeRWRLY/8sTBFaPmyPkpEAJ55ASbpyRysse
         nXMw==
X-Gm-Message-State: AA+aEWZ4zu9E1IG0MUrcVPCggA9xeJnyDTB9q+AzI34sW8KhnfNoXWEv
        k8hH26kDzDqFXqw2BKlYrQQuCYo=
X-Google-Smtp-Source: AFSGD/UuYdKIAYCPp5Zsw5Ig6ge2optYr+R9zFmVz6xOV0W0LPVw8SrGk89YpVdUqb2qi/jpmoC/xQ==
X-Received: by 2002:a6b:fa0e:: with SMTP id p14mr449161ioh.271.1543618225584;
        Fri, 30 Nov 2018 14:50:25 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id m8sm39391ioj.73.2018.11.30.14.50.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 14:50:24 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v4 3/3] SUNRPC: Fix a memory leak in call_encode()
Date:   Fri, 30 Nov 2018 17:49:16 -0500
Message-Id: <20181130224916.22751-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181130224916.22751-2-trond.myklebust@hammerspace.com>
References: <20181130224916.22751-1-trond.myklebust@hammerspace.com>
 <20181130224916.22751-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If we retransmit an RPC request, we currently end up clobbering the
value of req->rq_rcv_buf.bvec that was allocated by the initial call to
xprt_request_prepare(req).

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xdr.h | 1 -
 net/sunrpc/clnt.c          | 1 +
 net/sunrpc/xprt.c          | 2 ++
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 43106ffa6788..2ec128060239 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -72,7 +72,6 @@ xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
 	buf->head[0].iov_base = start;
 	buf->head[0].iov_len = len;
 	buf->tail[0].iov_len = 0;
-	buf->bvec = NULL;
 	buf->pages = NULL;
 	buf->page_len = 0;
 	buf->flags = 0;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e35d642558e7..c6782aa47525 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2309,6 +2309,7 @@ call_decode(struct rpc_task *task)
 	task->tk_status = 0;
 	/* Note: rpc_verify_header() may have freed the RPC slot */
 	if (task->tk_rqstp == req) {
+		xdr_free_bvec(&req->rq_rcv_buf);
 		req->rq_reply_bytes_recvd = req->rq_rcv_buf.len = 0;
 		if (task->tk_client->cl_discrtry)
 			xprt_conditional_disconnect(req->rq_xprt,
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 86bea4520c4d..122c91c28e7c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1623,6 +1623,8 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_snd_buf.buflen = 0;
 	req->rq_rcv_buf.len = 0;
 	req->rq_rcv_buf.buflen = 0;
+	req->rq_snd_buf.bvec = NULL;
+	req->rq_rcv_buf.bvec = NULL;
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
 	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
-- 
2.19.2

