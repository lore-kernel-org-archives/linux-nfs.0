Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72EDCC10F0B
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 422DC20700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="muBlBSkq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726468AbfDBXRB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:17:01 -0400
Received: from mail-pf1-f194.google.com ([209.85.210.194]:37334 "EHLO
        mail-pf1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXRB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:17:01 -0400
Received: by mail-pf1-f194.google.com with SMTP id 8so7137667pfr.4
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:17:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Iht5gb18bswJBpgm1NBVbGqUyySiCx/zHHcVSXLhJAU=;
        b=muBlBSkqh7s7hr9a8kjgIULh873kniVzVxpOb3lYA7wJweTZxhOcyRCFF799a3cUEo
         hIXMEIGfQHdAynLbazBkxrcPKzCC1vS/MfOTkurckH7TmGPZvtgHN2ZziTYxVYcXsXSL
         aQrRn7Yy4iT7oLfZG67HcU1+pv+Dr2bx/JXHlp2kZTiWxUZGUnoFoLiotdIRpHc3rjWT
         5mNxH+laHODbk6DLNqUoisdmOzwzLcvu2j+I8wdVeggJ7I7tqbmh8GCtfvD5geNKgS1s
         Z33IGbp+61Vv19GcQ3TS0T3/yp2mpNdVe3XWqd6QATVd6DRslTMH5X9wWxgfn/S+WZVV
         t7AQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Iht5gb18bswJBpgm1NBVbGqUyySiCx/zHHcVSXLhJAU=;
        b=tNrphWNT+xmP4dvJbs793jf7MA2D+Pw06gryeJMq31WXXx6wuJmkDOm9cd0hq7PtYb
         WWI1rVJJdMOWXtw5P0J9rpbtQbRxu6B1uYh8XdjaV+r/KyLaahurYOXiM5joAa+Go5kF
         zDcwkKFC5tW6lGBnIXuWz7J+QrQjS7ldnQkOhCPfi10zd1PGV94MjyVAYBUj1cNBEqe5
         TS0nGZzRNJkHTdgV5o7Bkab3ohnvMnSB7HKrBUb6SI3x2Z0uEYGP664dgcB5Lyzr9fzK
         cqqwpq3gTxY2gfktbFWgOu3U0PFCvypFB2Fm9ol7fZqw9McCc38jMeEZZ/CnambivOnG
         UazQ==
X-Gm-Message-State: APjAAAVKTsTlmSzBnyHKDLsMP/Avnj3ZfyhJcHc043MAblOpOaqMysY3
        NHkAwC6atfZUsCYUYQZPy8tXnuo=
X-Google-Smtp-Source: APXvYqyH7sHaW3jpjhHn0UfaPNaqRORfEY2fy3n8x/vhRWc/6qV49SSl9Xr9Qa38Hd4w+P6R1WXPhg==
X-Received: by 2002:a63:2015:: with SMTP id g21mr45909415pgg.226.1554247020474;
        Tue, 02 Apr 2019 16:17:00 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id k17sm18160799pfk.166.2019.04.02.16.16.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:16:59 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] SUNRPC: Clean up generic dispatcher code
Date:   Tue,  2 Apr 2019 16:14:45 -0700
Message-Id: <20190402231448.27743-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402231448.27743-3-trond.myklebust@hammerspace.com>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
 <20190402231448.27743-2-trond.myklebust@hammerspace.com>
 <20190402231448.27743-3-trond.myklebust@hammerspace.com>
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
index 5f87c0f1e4e0..eb6c7cef40de 100644
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

