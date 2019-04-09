Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FC15C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E49492084C
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MT8IQDYh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726532AbfDIPsc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 11:48:32 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:35157 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726372AbfDIPsc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 11:48:32 -0400
Received: by mail-it1-f193.google.com with SMTP id w15so5738966itc.0
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 08:48:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UY2cBB4NsCZa+dWRFOq2gzay1AgYXdaj9wCZfZ8odf4=;
        b=MT8IQDYheXQij5mmtfid7bKhp2ajN1pJ5KVCRbab43A2skxCpmIuMJk6lAfzFAA6i2
         kyuSVqL/LeJqynZXzyWRY9x+RyW2tTYOHSmXBwQdlRFIqrcL7Tjk2ObZ5nY+YCNJBJkY
         gjRHJCiq0vMLwnEdICe+VkcJ+/23qfHGHIYFqL3JI32rghRckGpHCZDcka65uxcX/ung
         fTH8PJw5tA0uR2Kc4K0GQgcmq599+4lyXfuldCr5mQWe2Faz0TLGkNZtkO0QXZDlIWXr
         3VZgkKClsMp6kPQAJJQDz6pu6ds+kr6RSv0SCBZbVXhcauYXj4m6/7h2oGaf4yx5dDuJ
         iBwQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=UY2cBB4NsCZa+dWRFOq2gzay1AgYXdaj9wCZfZ8odf4=;
        b=uMv3l4vXRyzROsaMnSUtExUGmsDoxdYisYSj+Ji+8Jp3NLKV99fE7R6EgyCch7Qnez
         kiQTTMdneDzfXhss/9Y4I/A4HFXP00aPERQlktsM3Ksggj3TPiL3fZC0spbHfvIlSqNY
         bT7xv5SPb9wCCZ2FNd1/2IxBl6JJBRP0O/6YWhlb16dO4/0V15cR7hFdNBlfVw+emlmc
         /U4oB+8tx5vOm7HjxM/tnb+BAadeyxzxc5g62sWbU/U+phgbL15V74O1SMo1qxYTaCez
         AMyA5EKKfUgtNh/ux7IDYGitBNeXsRsjpB/niPI0SonNi7vPSRLEc6ZmxyMK7HI/6o5g
         9WNw==
X-Gm-Message-State: APjAAAUWBYjkED2EXOvjCnB+F9ug3m4FJm6FKlT1W4SYUOggkhs7mUQW
        KM2vJ90d3e1OQ6hgoMRcQA==
X-Google-Smtp-Source: APXvYqzKGYVkJnj/uVSVi3nYNShOn0yqI02wLYnY0XGbWGByMQV/5Jyh9fl8amvmAI9nAAqBsYgCGA==
X-Received: by 2002:a02:ac9a:: with SMTP id x26mr26989678jan.129.1554824911049;
        Tue, 09 Apr 2019 08:48:31 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 62sm7026910itx.41.2019.04.09.08.48.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 08:48:30 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/6] SUNRPC: Clean up generic dispatcher code
Date:   Tue,  9 Apr 2019 11:46:16 -0400
Message-Id: <20190409154619.33615-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409154619.33615-3-trond.myklebust@hammerspace.com>
References: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
 <20190409154619.33615-2-trond.myklebust@hammerspace.com>
 <20190409154619.33615-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Simplify the generic server dispatcher.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/svc.c | 75 ++++++++++++++++++++++++++++++------------------
 1 file changed, 47 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 69f3b9e015ce..791c8076793f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1160,6 +1160,45 @@ svc_get_autherr(struct svc_rqst *rqstp, __be32 *statp)
 	return rpc_auth_ok;
 }
 
+static int
+svc_generic_dispatch(struct svc_rqst *rqstp, __be32 *statp)
+{
+	struct kvec *argv = &rqstp->rq_arg.head[0];
+	struct kvec *resv = &rqstp->rq_res.head[0];
+	const struct svc_procedure *procp = rqstp->rq_procinfo;
+
+	/*
+	 * Decode arguments
+	 * XXX: why do we ignore the return value?
+	 */
+	if (procp->pc_decode &&
+	    !procp->pc_decode(rqstp, argv->iov_base)) {
+		*statp = rpc_garbage_args;
+		return 1;
+	}
+
+	*statp = procp->pc_func(rqstp);
+
+	if (*statp == rpc_drop_reply ||
+	    test_bit(RQ_DROPME, &rqstp->rq_flags))
+		return 0;
+
+	if (test_bit(RQ_AUTHERR, &rqstp->rq_flags))
+		return 1;
+
+	if (*statp != rpc_success)
+		return 1;
+
+	/* Encode reply */
+	if (procp->pc_encode &&
+	    !procp->pc_encode(rqstp, resv->iov_base + resv->iov_len)) {
+		dprintk("svc: failed to encode reply\n");
+		/* serv->sv_stats->rpcsystemerr++; */
+		*statp = rpc_system_err;
+	}
+	return 1;
+}
+
 __be32
 svc_generic_init_request(struct svc_rqst *rqstp,
 		const struct svc_program *progp,
@@ -1328,40 +1367,17 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 
 	/* Call the function that processes the request. */
 	if (!process.dispatch) {
-		/*
-		 * Decode arguments
-		 * XXX: why do we ignore the return value?
-		 */
-		if (procp->pc_decode &&
-		    !procp->pc_decode(rqstp, argv->iov_base))
+		if (!svc_generic_dispatch(rqstp, statp))
+			goto release_dropit;
+		if (*statp == rpc_garbage_args)
 			goto err_garbage;
-
-		*statp = procp->pc_func(rqstp);
-
-		/* Encode reply */
-		if (*statp == rpc_drop_reply ||
-		    test_bit(RQ_DROPME, &rqstp->rq_flags)) {
-			if (procp->pc_release)
-				procp->pc_release(rqstp);
-			goto dropit;
-		}
 		auth_stat = svc_get_autherr(rqstp, statp);
 		if (auth_stat != rpc_auth_ok)
 			goto err_release_bad_auth;
-		if (*statp == rpc_success && procp->pc_encode &&
-		    !procp->pc_encode(rqstp, resv->iov_base + resv->iov_len)) {
-			dprintk("svc: failed to encode reply\n");
-			/* serv->sv_stats->rpcsystemerr++; */
-			*statp = rpc_system_err;
-		}
 	} else {
 		dprintk("svc: calling dispatcher\n");
-		if (!process.dispatch(rqstp, statp)) {
-			/* Release reply info */
-			if (procp->pc_release)
-				procp->pc_release(rqstp);
-			goto dropit;
-		}
+		if (!process.dispatch(rqstp, statp))
+			goto release_dropit; /* Release reply info */
 	}
 
 	/* Check RPC status result */
@@ -1380,6 +1396,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		goto close;
 	return 1;		/* Caller can now send it */
 
+release_dropit:
+	if (procp->pc_release)
+		procp->pc_release(rqstp);
  dropit:
 	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
 	dprintk("svc: svc_process dropit\n");
-- 
2.20.1

