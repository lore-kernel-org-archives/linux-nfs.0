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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69125C65BB0
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:19:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2DCD120660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:19:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t56+a2H+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DCD120660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725749AbeLAIae (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:30:34 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:45427 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726619AbeLAIae (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 03:30:34 -0500
Received: by mail-io1-f67.google.com with SMTP id w7so5665546iom.12
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 13:19:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3CWz8gm7phc3o80CIT3ZbTk88epHNOUnjMVFja2rqvk=;
        b=t56+a2H+eBqFIprFD6BXyA4cNPBGO6PYEeUKXKYblnlnePAQHeeB126XNdADQMQkZ3
         E9gDtKpa06mRomMSQD6TyvHxsNN6urET70XMqJ/zVxVXSGHN4lM+fL8Y4rYj0XQE16XJ
         KkCRwd/XxqhlN3PHrO8r7RIWSU8OO3vlWFLQ0kqovCE7g7GZSvzZ5ZsXl3KCoXe5M12R
         LYl4Y5mXgTTsdFJzhKuFr40Sdb3k3uEnxHH+vmhttIeavVXfmABlN5qJOIA3P9+LDkVl
         aSUV4N/j/dfFdPlEimjxzJl/DDCRcNL98f8czUjIZs7yEYGZq3af8fNoLHlmYAqsclQI
         IxCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=3CWz8gm7phc3o80CIT3ZbTk88epHNOUnjMVFja2rqvk=;
        b=O+vy8XzHPu8awf/OsFg9W/enlrgKB90JsXNPVruWRssp536TFF+NXJg6SkbbSeEIBQ
         65lVSV8suP7J8u4tv36qe6vt82oB9Kl+Tc0Z5deYTQsGHe32RvnqA0AvdlFpHWoAqV2P
         uQILRjuh3wul7ho4mViZqdCv2ccUQGoTjZaQ5L9kOg+npXjaeEVA6VUIkVaP+n3LgUpw
         Pq7WxiFG265dOwznuY+bCUE7ewwXEri8qZhPpefilgBOFNUbwnyx5uYVX2L8wVCI0BYz
         nO0RoDQKvwayDIj/jP2RJNRkQ6dr4nR+tLyNZ2WBfuChxGBrdfL7u76l/D+VtRy5sOG5
         7Vdg==
X-Gm-Message-State: AA+aEWZE6mbQeb+8ev7iw373EmhMBJL9mTKNf64U9OiINyZEGXdKPddz
        Z02Q7tLAYq7A9qpniYPdb252TEA=
X-Google-Smtp-Source: AFSGD/WEb2fkxVTmDOWyG97AAFCgkZnsmXhihUc4c/ktd8yYo8NaNBOvJtUpZyyPjwcJOMXEYg1GgQ==
X-Received: by 2002:a5e:8306:: with SMTP id x6mr5504196iom.229.1543612797301;
        Fri, 30 Nov 2018 13:19:57 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id y1sm141393itb.29.2018.11.30.13.19.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 13:19:56 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] SUNRPC: Ensure we refresh the bvec after RPCSEC_GSS encoding
Date:   Fri, 30 Nov 2018 16:18:46 -0500
Message-Id: <20181130211846.89000-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181130211846.89000-2-trond.myklebust@hammerspace.com>
References: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
 <20181130211846.89000-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A call to gss_wrap_req_priv() will end up replacing the original array
in rqstp->rq_snd_buf.pages with a new one containing the encrypted
data. In order to avoid having the rqstp->rq_snd_buf.bvec point to the
wrong page data, we need to refresh that too.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ae77c71c1f64..615ef2397fc5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -843,6 +843,7 @@ static int xs_nospace(struct rpc_rqst *req)
 static void
 xs_stream_prepare_request(struct rpc_rqst *req)
 {
+	xdr_free_bvec(&req->rq_rcv_buf);
 	req->rq_task->tk_status = xdr_alloc_bvec(&req->rq_rcv_buf, GFP_NOIO);
 }
 
-- 
2.19.2

