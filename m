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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F9E9C65BAE
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:50:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 509702082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:50:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g1O4fj5g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 509702082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726600AbeLAKBQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 05:01:16 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:44800 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726474AbeLAKBQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 05:01:16 -0500
Received: by mail-io1-f65.google.com with SMTP id r200so5826978iod.11
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 14:50:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=01dPSorkMzYoAkW8cLBYQTAhpw9QBeR18qNhoOAgQ3Y=;
        b=g1O4fj5gfqqOSUWHZQhrrVLAPo/ZlGshxneSxLcW1h7y0MLHgs7VAyuWSqZ2kfjYgZ
         v4aN/cNNPYpDIaVt8FLoo0v+c/+Ua4eu1nV9eNCRmZtfgGhY6ZiMDHoKdASt7CPbM6h0
         0DElC/kMj3sPWrjgOyYruMRj3PnSbRWjUvit9GX71PoyBDqSZFNFxxOX3feeZlje+/Vp
         vu/VIDmcdcO51qD99DmzHozpyzkGeLlgYQEsU0SE+3CLzQAPTrW9WqD3sAtxHcu59n+E
         j8Z3cMmWewkOrKiSE3t8lTfSeqfO9eFJTpCC6EjyfXXbFtfGg9y1Slgp15lnJkYErq/C
         p+gA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=01dPSorkMzYoAkW8cLBYQTAhpw9QBeR18qNhoOAgQ3Y=;
        b=ZwruABxrpuGuXwW4z+UhC7b9RbtfHxfadvxxkv8p8JSt/D5iDjz04KdlA7qeMO4/q1
         SbFFQSHxPdjpBmlxCXFpH3iwtW6eCkUR1torPgov0mpOkMsPjvDa0Zy8Tn8qw1lJPdjl
         +d3+8aJgG4XYiMIM+6xKjdSwpmOg1VSiKAEnIkTSiLW0/1Q+Fg2maCGgKB6oNt1UhiqG
         RcqdJM42rJSL4UCCQlDDcw8/ppKHlNBFagInaVx2+qlufFmsg8Y07+Gs7YBPbp/MFWG0
         mbcVd1UMfnwMVYbURMaYQ6GvLPOxhChnpLwHxWIdc6yqSvfmpmz8tMVDgk89kOYXGfha
         R88Q==
X-Gm-Message-State: AA+aEWZCTCdldGi1a7TQWbYxON0jKqZ/iDQsjm5Ir2Te2vz1IQiRoxzg
        MUvfrVl1VkBT6ciP/xa5fLu0ib8=
X-Google-Smtp-Source: AFSGD/WTvzB8TrTIoV5FGYJcPc3P4kJoNiMfk7ANfz83/Jd7ey05QrBqXeU6HIYVRv8cadUyIPpl3w==
X-Received: by 2002:a6b:3bc8:: with SMTP id i191mr6630924ioa.23.1543618224520;
        Fri, 30 Nov 2018 14:50:24 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id m8sm39391ioj.73.2018.11.30.14.50.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 14:50:23 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/3] SUNRPC: Fix leak of krb5p encode pages
Date:   Fri, 30 Nov 2018 17:49:15 -0500
Message-Id: <20181130224916.22751-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181130224916.22751-1-trond.myklebust@hammerspace.com>
References: <20181130224916.22751-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

call_encode can be invoked more than once per RPC call. Ensure that
each call to gss_wrap_req_priv does not overwrite pointers to
previously allocated memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 5d3f252659f1..ba765473d1f0 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1791,6 +1791,7 @@ priv_release_snd_buf(struct rpc_rqst *rqstp)
 	for (i=0; i < rqstp->rq_enc_pages_num; i++)
 		__free_page(rqstp->rq_enc_pages[i]);
 	kfree(rqstp->rq_enc_pages);
+	rqstp->rq_release_snd_buf = NULL;
 }
 
 static int
@@ -1799,6 +1800,9 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 	struct xdr_buf *snd_buf = &rqstp->rq_snd_buf;
 	int first, last, i;
 
+	if (rqstp->rq_release_snd_buf)
+		rqstp->rq_release_snd_buf(rqstp);
+
 	if (snd_buf->page_len == 0) {
 		rqstp->rq_enc_pages_num = 0;
 		return 0;
-- 
2.19.2

