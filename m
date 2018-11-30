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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69138C64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:57:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2DAA820660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:57:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="urp5G6Db"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DAA820660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726139AbeLAJHs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:07:48 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:36303 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725749AbeLAJHs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 04:07:48 -0500
Received: by mail-it1-f196.google.com with SMTP id c9so699246itj.1
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 13:57:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=01dPSorkMzYoAkW8cLBYQTAhpw9QBeR18qNhoOAgQ3Y=;
        b=urp5G6DbePt73ThUhbh8sgGhL6YjVCCO195JUrrRJ7ela5mToVVTvcDXqqvcB5zviZ
         DH66MUCd1+4VlEEk1tcNr21ZW2b1cmKMw6Qavo5+YsiToDCx5UuBKcUFW8I+jrsIwbzF
         c7DOjaLpCqV+/gDnT4huXBrO8PmiyPCN2e/VNAagulK5IRXlerytUjh2ar/6rLzgBMti
         8bX0QJ42Tt47O9v6qmfaha+fZwKd0/VAf4iANzRQv/kmPHBehyG1cwfeGlTtbh6pYKX7
         pQKkslwcyDcTYYLJvPJsWMosYpwaxKiDLM7Y67TkW5Y4jgZILmWemqo1hJHSMemfD+uV
         RzzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=01dPSorkMzYoAkW8cLBYQTAhpw9QBeR18qNhoOAgQ3Y=;
        b=hCBjMWS1kW9Gs+Z0WMdN+AOWqIxrn7oWgrHhf/CUfzIi45Nq4ZQBtSYILjXjfXRb+N
         PsjolOgYLQGUZyi9tCnAf2Z5mjdQ29mHDGIJxLdRCDCGXoiU9LJ4PLtp43YM4JXYiwSi
         NOFWcZNzeO0W74+4i0rl5VnMfXiFCi9nOzqGD1QtxKX1QLPQlY7yjUa05VKCFRsA/0El
         8BNWZEBFFrD26bL8mphGvbKkGHifYvUYhm+9FNBjQehTyEs+Jgo9pdsQRbXCmQ0R1gM7
         SCCLc2oSCOfQGWPi5aIk0N5KoLbhDHD5k/lXBwYb4dHCRQtlntgHxXcvtk6ot5qmKKBg
         bTgA==
X-Gm-Message-State: AA+aEWY/7+gKraoL3bGmaJPDsCAM25+2nHq6AAJZnslrdUKyecnefCrZ
        xMbAEBSonsjyalkbPs2jPaaBGck=
X-Google-Smtp-Source: AFSGD/VcIgH2tJb+OAcBqdYVP4Zb5R6Rn5stKvyJttv2pleh5G2g/aXHQ+51UV10Qho+WmQ+qotdMQ==
X-Received: by 2002:a24:3282:: with SMTP id j124mr448824ita.173.1543615024558;
        Fri, 30 Nov 2018 13:57:04 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id z23sm2659119iob.19.2018.11.30.13.57.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 13:57:03 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/3] SUNRPC: Fix leak of krb5p encode pages
Date:   Fri, 30 Nov 2018 16:55:54 -0500
Message-Id: <20181130215555.91107-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
References: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
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

