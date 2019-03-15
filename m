Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55825C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 29F86218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HI0FCVrs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726218AbfCORwz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 13:52:55 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:38775 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726496AbfCORwz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 13:52:55 -0400
Received: by mail-it1-f194.google.com with SMTP id k193so12214144ita.3
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 10:52:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K178YlptAS1rbu3+nUSapJpQeyVeZCrBcvjd+Sn51Uo=;
        b=HI0FCVrsnKXquvyUIf6bIZCyxA4q3lphZbqbEvFmhq8GvNDEIu83TxPbz5FejzibuO
         RmcNshmFYMA72AhDfLZkFOimfSy4XE7s08dusH0MNi4tnILBXpYI8vmodB2jV414kVpZ
         LvqnBiIxWShZVEAn6nefQngMx5g0Jxovg7mTlg8r6g0+xYdY5BdA14IprUiiYFfbz4zX
         qdCEIzdpT2aj3r7qrWFqdEzvrU1iLxEKMIz1U/3Z58dFhqI7mhgGuwQvQarcK0vEUnyu
         Kbac/Dj19nLmLyat7P1piQ6euX2QJrfsurRdKEo1tyecMkppGoLQjzosaPNKeuGY5N3Y
         aAzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=K178YlptAS1rbu3+nUSapJpQeyVeZCrBcvjd+Sn51Uo=;
        b=eXOgjqiVg3z0iDD3len7Ns2e/SKxu9op9KMyo/ObfKDbgXloEH6+nZ6KMaMvLJYEBV
         EFJc2hioLCv6jGbEbkd6UWR5FH8OPr6XxJZLv2O4+O7QWt9qVszA/04Taa7Ec5aFvePw
         Z+2vJFwvYHKXhNVKpvSb51R6cP1VCp+mW0oxOh1z6jtURt1dWuJ8PIaIBsQVopcPI68n
         BpyOVNJpa7ly9Nz6yUU6uozyzewbLbl6ldbKyhVzUVtwcH644nps1eBB1p7dM/BTger1
         lppiwsND55vX77VI6fPxnXjH3ATi40HZ4zY6cFUe7S3utvhh95FckihZf0hrtxLQxNMm
         KpVQ==
X-Gm-Message-State: APjAAAXrbYCObj41phncsdeJxWPWUaGbyx4Ufi15Ceut5UGlSwH8f55t
        WzJAYgzheGz2oOkGPQaIkEg9RlI=
X-Google-Smtp-Source: APXvYqwYRFTtDP+SPZYtFxo/Z/hqR96JWeq2Or4z3M/YRG4CUj5WMC+z4YTLrN0vIMxnkfco3vKZcg==
X-Received: by 2002:a02:700f:: with SMTP id f15mr409131jac.139.1552672373944;
        Fri, 15 Mar 2019 10:52:53 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r2sm1138415itk.5.2019.03.15.10.52.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 10:52:53 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] SUNRPC: rpc_decode_header() must always return a non-zero value on error
Date:   Fri, 15 Mar 2019 13:51:39 -0400
Message-Id: <20190315175141.68792-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190315175141.68792-3-trond.myklebust@hammerspace.com>
References: <20190315175141.68792-1-trond.myklebust@hammerspace.com>
 <20190315175141.68792-2-trond.myklebust@hammerspace.com>
 <20190315175141.68792-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ensure that when the "garbage args" case falls through, we do set
an error of EIO.

Fixes: a0584ee9aed8 ("SUNRPC: Use struct xdr_stream when decoding...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 310873895578..1f47801e0002 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2454,7 +2454,7 @@ static noinline int
 rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 {
 	struct rpc_clnt *clnt = task->tk_client;
-	int error = -EACCES;
+	int error;
 	__be32 *p;
 
 	/* RFC-1014 says that the representation of XDR data must be a
@@ -2463,7 +2463,7 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 	 *   undefined results
 	 */
 	if (task->tk_rqstp->rq_rcv_buf.len & 3)
-		goto out_badlen;
+		goto out_unparsable;
 
 	p = xdr_inline_decode(xdr, 3 * sizeof(*p));
 	if (!p)
@@ -2498,9 +2498,10 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 		goto out_err;
 	case rpc_garbage_args:
 		trace_rpc__garbage_args(task);
+		error = -EIO;
 		break;
 	default:
-		trace_rpc__unparsable(task);
+		goto out_unparsable;
 	}
 
 out_garbage:
@@ -2514,11 +2515,6 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 	rpc_exit(task, error);
 	return error;
 
-out_badlen:
-	trace_rpc__unparsable(task);
-	error = -EIO;
-	goto out_err;
-
 out_unparsable:
 	trace_rpc__unparsable(task);
 	error = -EIO;
@@ -2529,6 +2525,7 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 	goto out_garbage;
 
 out_msg_denied:
+	error = -EACCES;
 	p = xdr_inline_decode(xdr, sizeof(*p));
 	if (!p)
 		goto out_unparsable;
@@ -2540,9 +2537,7 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 		error = -EPROTONOSUPPORT;
 		goto out_err;
 	default:
-		trace_rpc__unparsable(task);
-		error = -EIO;
-		goto out_err;
+		goto out_unparsable;
 	}
 
 	p = xdr_inline_decode(xdr, sizeof(*p));
@@ -2577,8 +2572,7 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 			task->tk_xprt->servername);
 		break;
 	default:
-		trace_rpc__unparsable(task);
-		error = -EIO;
+		goto out_unparsable;
 	}
 	goto out_err;
 }
-- 
2.20.1

