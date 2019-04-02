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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CE68C10F0B
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E111C20700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:16:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nCyjeT8K"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726427AbfDBXQ7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:16:59 -0400
Received: from mail-pg1-f195.google.com ([209.85.215.195]:46805 "EHLO
        mail-pg1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXQ7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:16:59 -0400
Received: by mail-pg1-f195.google.com with SMTP id q1so7280703pgv.13
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:16:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1A5NK/zg/oW1o+8IsGnp/XdXrqF9UEN0vlLWFqRQ5wQ=;
        b=nCyjeT8KhthTkPzA7Xnw7UA735BUeojTerJc3i0tdAUVidA825SBtA0/I8jiT8bgtB
         ZeeXSGxAmJZS+2AxICZJdlYsGqfhyBO9BJhVPG469VMhCghOk+mqdCw/BJDwGYIKKm0B
         58GdtPrpF4VSsRh6911zl/xI6NH018Opar1xlgiDixRLjgPvZ9V+s+ORPaENz+tzEcWN
         1EkokaDxzC6JO+ReJfzpQ3cy6NKwQQhZFQVumP8Aa5FAdcdwqWkU6ztdeRIntGHFJs30
         ajbofulmP+KUsbqrPl1SQGW0heBc2OPa8pDpO9+cm7iuofff0xXoLUgSUNyh5zymWaDK
         7euA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=1A5NK/zg/oW1o+8IsGnp/XdXrqF9UEN0vlLWFqRQ5wQ=;
        b=AjjUKvBOVKe8LjJlJmmUzS8lmh7RAXltLO8v6/FMHq1J6HBdAB01OX+WpAvMBtbONJ
         xTE8kPvBtZm41ljC6qdJyYYBP6mCowdyRpSHiMMnAVEQbMTlo22hLEvP8rwluQyoKY9q
         omzfhbQS/gjw11vqATlN74HZkTcAoBMNTzZOxUQXmwaq4EETW3r/zlpkaEhhwACAi6Wf
         e/AYufNQvgxcTxyy+NJU6AgwSq7N7KQ4RjnxBbvndMTjc+T8cKw3/0YYCKbHOoL2gPbD
         zZ6QtTdAcIWAK43b2flDusDenie86DDweFxzZW6gplpYd8xpZT8O/tKGEpAZ/2rhD2hl
         Kr0g==
X-Gm-Message-State: APjAAAXicmVMnhuBt8sVJ1RT2Di927fAFF1T5mqnk5Nsj7zlFsN16L0Q
        bw0tTTawp/VlRgHd4ZMWjW3zEjA=
X-Google-Smtp-Source: APXvYqzT6DEk5w86jpGaRbtwmn3Zv7w7Ii8o7lGiB/o4e3B6vlkPuGNDKqf+3Px1OgPqeeXpoyPpdw==
X-Received: by 2002:a63:f809:: with SMTP id n9mr5193982pgh.201.1554247018014;
        Tue, 02 Apr 2019 16:16:58 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id k17sm18160799pfk.166.2019.04.02.16.16.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:16:57 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] SUNRPC/nfs: Fix return value for nfs4_callback_compound()
Date:   Tue,  2 Apr 2019 16:14:43 -0700
Message-Id: <20190402231448.27743-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

RPC server procedures are normally expected to return a __be32 encoded
status value of type 'enum rpc_accept_stat', however at least one function
wants to return an authentication status of type 'enum rpc_auth_stat'
in the case where authentication fails.
This patch adds functionality to allow this.

Fixes: a4e187d83d88 ("NFS: Don't drop CB requests with invalid principals")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_xdr.c      |  2 +-
 include/linux/sunrpc/svc.h |  2 ++
 net/sunrpc/svc.c           | 27 ++++++++++++++++++++++-----
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 06233bfa6d73..73a5a5ea2976 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -983,7 +983,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 
 out_invalidcred:
 	pr_warn_ratelimited("NFS: NFSv4 callback contains invalid cred\n");
-	return rpc_autherr_badcred;
+	return svc_return_autherr(rqstp, rpc_autherr_badcred);
 }
 
 /*
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index e52385340b3b..7ff12c9dbeaf 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -271,6 +271,7 @@ struct svc_rqst {
 #define	RQ_VICTIM	(5)			/* about to be shut down */
 #define	RQ_BUSY		(6)			/* request is busy */
 #define	RQ_DATA		(7)			/* request has data */
+#define RQ_AUTHERR	(8)			/* Request status is auth error */
 	unsigned long		rq_flags;	/* flags field */
 	ktime_t			rq_qtime;	/* enqueue time */
 
@@ -504,6 +505,7 @@ unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
 char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
 					     struct kvec *first, void *p,
 					     size_t total);
+__be32		   svc_return_autherr(struct svc_rqst *rqstp, __be32 auth_err);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dbd19697ee38..3d5dd6b86652 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1144,6 +1144,22 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...) {}
 #endif
 
+__be32
+svc_return_autherr(struct svc_rqst *rqstp, __be32 auth_err)
+{
+	set_bit(RQ_AUTHERR, &rqstp->rq_flags);
+	return auth_err;
+}
+EXPORT_SYMBOL_GPL(svc_return_autherr);
+
+static __be32
+svc_get_autherr(struct svc_rqst *rqstp, __be32 *statp)
+{
+	if (test_and_clear_bit(RQ_AUTHERR, &rqstp->rq_flags))
+		return *statp;
+	return rpc_auth_ok;
+}
+
 /*
  * Common routine for processing the RPC request.
  */
@@ -1290,11 +1306,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 				procp->pc_release(rqstp);
 			goto dropit;
 		}
-		if (*statp == rpc_autherr_badcred) {
-			if (procp->pc_release)
-				procp->pc_release(rqstp);
-			goto err_bad_auth;
-		}
+		auth_stat = svc_get_autherr(rqstp, statp);
+		if (auth_stat != rpc_auth_ok)
+			goto err_release_bad_auth;
 		if (*statp == rpc_success && procp->pc_encode &&
 		    !procp->pc_encode(rqstp, resv->iov_base + resv->iov_len)) {
 			dprintk("svc: failed to encode reply\n");
@@ -1351,6 +1365,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	svc_putnl(resv, 2);
 	goto sendit;
 
+err_release_bad_auth:
+	if (procp->pc_release)
+		procp->pc_release(rqstp);
 err_bad_auth:
 	dprintk("svc: authentication failed (%d)\n", ntohl(auth_stat));
 	serv->sv_stats->rpcbadauth++;
-- 
2.20.1

