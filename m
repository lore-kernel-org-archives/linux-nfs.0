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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3838FC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0E92F218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Cd3ivY7N"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726556AbfCORw5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 13:52:57 -0400
Received: from mail-io1-f49.google.com ([209.85.166.49]:38352 "EHLO
        mail-io1-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726496AbfCORw5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 13:52:57 -0400
Received: by mail-io1-f49.google.com with SMTP id v4so7961660ioj.5
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 10:52:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q3b0beomq0EufQKy0zCGXv8Yfy3DIKlGtoWL89UZoR8=;
        b=Cd3ivY7NZKu8GL2DQAEuaeEY2cPudnBMR71GDWMuSCMzX2cO8/7WTswqra/3H0WWjx
         P3nRI6BWl6aiu2ZuZGndnRWfceCpBbmZBuZb3KLGpSFy5X9oU/xLiKb7Ia8NQyOJ8xZn
         xo4yvfk5UC6OcD0mXYEyARWGRDlxl9JKFMKvmdIl5N+w6y459ZZNFPucLp57s9CPKNkm
         8ij+PrBfRGueVjvQ8quJikyT+xY4KbrnKBx8ebzAGwMMVsox1xxRhCM7YY5+tG/6ux7n
         9RY+4wuBuU5uaMFDREtSrOhSVI4JUr4UVVGLcwAcDbbvcC1/co/brOAN8cjXb6XdlwSu
         WGhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Q3b0beomq0EufQKy0zCGXv8Yfy3DIKlGtoWL89UZoR8=;
        b=FkRVU5rALFmoffHFF7KS/5Px7z5jVdDLVTSETDry5BcRZbi8cawm0qL/kC8MHhJtZ+
         Y13Xv0QoysDadi3JxOqzNSEpDY5j4WVTJPY8HyaQ9Wgnj1eg8hHzVMH2JIPuo7miEQty
         9+BFMUh+a6J5LJEim5qnx0Wbf3dL5uBbbOa9KcAA5kcOWs7Zb4mnuvCOCe2yBNzOcJ1G
         ZHDJW1T5qlq27q8naX/INovRirO4JSuCpfy82OtYydWYmoPJlZWWMBrC1ecY0yzVPTYD
         bfyjr41DcuUvpSKriZ0u+SqL8DSSmsPZldsLPcOIqTtpQQqNamwJqVTDgep/KNfqMbZK
         xyZw==
X-Gm-Message-State: APjAAAVph6ENiMKX83Xancw/zj2XUI5M9LBMM2RBOvZKe9UovugViDUc
        ouWagxIQz39xKWC7EJlSmuZQ69U=
X-Google-Smtp-Source: APXvYqzMIsatBKD84muGMrdJGiKH1awMe1/+X7VjOc6NsKH1MGRHzT4jA7DOWXUoBfaanqyfT64REw==
X-Received: by 2002:a6b:641a:: with SMTP id t26mr2956480iog.204.1552672375611;
        Fri, 15 Mar 2019 10:52:55 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r2sm1138415itk.5.2019.03.15.10.52.54
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 10:52:55 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] SUNRPC: Remove redundant check for the reply length in call_decode()
Date:   Fri, 15 Mar 2019 13:51:41 -0400
Message-Id: <20190315175141.68792-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190315175141.68792-5-trond.myklebust@hammerspace.com>
References: <20190315175141.68792-1-trond.myklebust@hammerspace.com>
 <20190315175141.68792-2-trond.myklebust@hammerspace.com>
 <20190315175141.68792-3-trond.myklebust@hammerspace.com>
 <20190315175141.68792-4-trond.myklebust@hammerspace.com>
 <20190315175141.68792-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Now that we're using the xdr_stream functions to decode the header,
the test for the minimum reply length is redundant.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cb73d6c25857..228970e6e52b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2392,9 +2392,6 @@ call_decode(struct rpc_task *task)
 	WARN_ON(memcmp(&req->rq_rcv_buf, &req->rq_private_buf,
 				sizeof(req->rq_rcv_buf)) != 0);
 
-	if (req->rq_rcv_buf.len < 12)
-		goto out_retry;
-
 	xdr_init_decode(&xdr, &req->rq_rcv_buf,
 			req->rq_rcv_buf.head[0].iov_base, req);
 	switch (rpc_decode_header(task, &xdr)) {
@@ -2405,7 +2402,6 @@ call_decode(struct rpc_task *task)
 			task->tk_pid, __func__, task->tk_status);
 		return;
 	case -EAGAIN:
-out_retry:
 		task->tk_status = 0;
 		/* Note: rpc_decode_header() may have freed the RPC slot */
 		if (task->tk_rqstp == req) {
-- 
2.20.1

