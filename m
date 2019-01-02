Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0C16C43612
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8DAEF20879
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O7HvPG1B"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729990AbfABWyZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 17:54:25 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:51127 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729935AbfABWyZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 17:54:25 -0500
Received: by mail-it1-f195.google.com with SMTP id z7so43086863iti.0
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 14:54:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6i+R29n/uLak+GIH+f2r+Se6UvKJSXp0zdIvffi5Q8k=;
        b=O7HvPG1BbcQMrbAOg7zjWYHPJVAQCxvjKOFG7H2FMvccxoq3+WCnA/bMC0Rawtkyqa
         7/1uyK/FFZdHsyyj8YbHdm1TasGDRQRmiW9lzHYifXgJ2rq545LFTKx6D3StxVLorJiY
         DayMsTvHPbr+xRH+/kTWodceE6eFJ2INcHcRNgPkbf1/qXNgpXD3ThSWSEdGby6nq3Yt
         nlTLhHHeXoisGfq8IQpJzYEnxxbTX7oHXeip9yhm1FkndV8013LesOupE3PcE9PWZIoc
         r+d921XnuM0apEB58/gMNbd+N+SjEmRzAuRNK/UhZo9VS8d8gDe9VOGIILfPfcInletU
         6qvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=6i+R29n/uLak+GIH+f2r+Se6UvKJSXp0zdIvffi5Q8k=;
        b=SMUoton3d9X1gfHDVy2muCgY8RFMEbhFGofr+xkQ2qDGa9mpOmv+LFwT8Qawz6xdui
         I7inYKalLz36xxKRYWGXp/wzzWj+4OmxGoRQByGV1sWNcXPXFjQsDagdEHclzuAHXxEp
         hwwIanytO14rZOq9NF24CRluWfxJMS9RLNonschl58Azl7UfP12HrSs9DDq/hexJm2Ke
         b3l+rQRXxcHQmsLU4n6y0ioVe3Uf0jQhidJH6tZnwYzBwi6H9B08W6P6FcBnmaTToMiD
         vhU5iMDQi8RIE0MTG3GeVA7bqFroi+VsWLyUmoY6oACp7WuOwDCYColy/uRQKYfUqvfW
         cfTw==
X-Gm-Message-State: AA+aEWaTMrJtwWqIZMpXnBMCa8yKX4pLYnksj2nNbZzGyea77WXesQEO
        MxqnNwujC68soyiu2Ph1LQhIWtdf0A==
X-Google-Smtp-Source: AFSGD/U2prwOd5PdSTacIohObeJZbAh7eiWCU4TMlaiVbyBDL9Diso23ohtT6xTjv9yegjRYJDsKdA==
X-Received: by 2002:a24:cc46:: with SMTP id x67mr27905668itf.66.1546469664134;
        Wed, 02 Jan 2019 14:54:24 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d3sm23036154itc.40.2019.01.02.14.54.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 14:54:23 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] SUNRPC: Ensure we respect the RPCSEC_GSS sequence number limit
Date:   Wed,  2 Jan 2019 17:53:13 -0500
Message-Id: <20190102225313.2097-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190102225313.2097-4-trond.myklebust@hammerspace.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
 <20190102225313.2097-2-trond.myklebust@hammerspace.com>
 <20190102225313.2097-3-trond.myklebust@hammerspace.com>
 <20190102225313.2097-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

According to RFC2203, the RPCSEC_GSS sequence numbers are bounded to
an upper limit of MAXSEQ = 0x80000000. Ensure that we handle that
correctly.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 12 +++++++++---
 net/sunrpc/clnt.c              | 19 ++++++++++++-------
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index dc7124d45c8a..96c1f12e791e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1563,8 +1563,10 @@ gss_marshal(struct rpc_task *task, __be32 *p)
 	cred_len = p++;
 
 	spin_lock(&ctx->gc_seq_lock);
-	req->rq_seqno = ctx->gc_seq++;
+	req->rq_seqno = (ctx->gc_seq < MAXSEQ) ? ctx->gc_seq++ : MAXSEQ;
 	spin_unlock(&ctx->gc_seq_lock);
+	if (req->rq_seqno == MAXSEQ)
+		goto out_expired;
 
 	*p++ = htonl((u32) RPC_GSS_VERSION);
 	*p++ = htonl((u32) ctx->gc_proc);
@@ -1586,14 +1588,18 @@ gss_marshal(struct rpc_task *task, __be32 *p)
 	mic.data = (u8 *)(p + 1);
 	maj_stat = gss_get_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
-		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
+		goto out_expired;
 	} else if (maj_stat != 0) {
-		printk("gss_marshal: gss_get_mic FAILED (%d)\n", maj_stat);
+		pr_warn("gss_marshal: gss_get_mic FAILED (%d)\n", maj_stat);
+		task->tk_status = -EIO;
 		goto out_put_ctx;
 	}
 	p = xdr_encode_opaque(p, NULL, mic.len);
 	gss_put_ctx(ctx);
 	return p;
+out_expired:
+	clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
+	task->tk_status = -EKEYEXPIRED;
 out_put_ctx:
 	gss_put_ctx(ctx);
 	return NULL;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2189fbc4c570..1ee04e0ec4bc 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1740,11 +1740,8 @@ rpc_xdr_encode(struct rpc_task *task)
 		     req->rq_rcvsize);
 
 	p = rpc_encode_header(task);
-	if (p == NULL) {
-		printk(KERN_INFO "RPC: couldn't encode RPC header, exit EIO\n");
-		rpc_exit(task, -EIO);
+	if (p == NULL)
 		return;
-	}
 
 	encode = task->tk_msg.rpc_proc->p_encode;
 	if (encode == NULL)
@@ -1769,10 +1766,17 @@ call_encode(struct rpc_task *task)
 	/* Did the encode result in an error condition? */
 	if (task->tk_status != 0) {
 		/* Was the error nonfatal? */
-		if (task->tk_status == -EAGAIN || task->tk_status == -ENOMEM)
+		switch (task->tk_status) {
+		case -EAGAIN:
+		case -ENOMEM:
 			rpc_delay(task, HZ >> 4);
-		else
+			break;
+		case -EKEYEXPIRED:
+			task->tk_action = call_refresh;
+			break;
+		default:
 			rpc_exit(task, task->tk_status);
+		}
 		return;
 	}
 
@@ -2334,7 +2338,8 @@ rpc_encode_header(struct rpc_task *task)
 	*p++ = htonl(clnt->cl_vers);	/* program version */
 	*p++ = htonl(task->tk_msg.rpc_proc->p_proc);	/* procedure */
 	p = rpcauth_marshcred(task, p);
-	req->rq_slen = xdr_adjust_iovec(&req->rq_svec[0], p);
+	if (p)
+		req->rq_slen = xdr_adjust_iovec(&req->rq_svec[0], p);
 	return p;
 }
 
-- 
2.20.1

