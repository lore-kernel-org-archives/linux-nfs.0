Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D3A9C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2D7BE218FE
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OXVclHvp"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727136AbfDPNiN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:38:13 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:34631 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726751AbfDPNiN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:38:13 -0400
Received: by mail-it1-f195.google.com with SMTP id z17so2732097itc.1;
        Tue, 16 Apr 2019 06:38:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=uoGfYWajZKkjcbjtVTLDy6dOkR7gJFyuID3v83PCoTw=;
        b=OXVclHvp4o7WoDM2/myOowobaLA64pQ/cvhPmiNO/NAO4MeT1YD3ETiLvVlXYilJj6
         tg+5IZWLEqpT8tXq6ZP6lZv6WWP2ISrM2KbcMHonrcMYeH8jz8ouX0reJuv++z74VbuZ
         djyKZFldbAER/n4eKZXL8sC48JUyZq9XiAU33HHRDZYy4mWAuKMsceApLADwFNxkzAMp
         EvFtVeeEIfC6ZfF8c59GousK3eGgIC339AeRSA1LH2khK8fhe9DESEQlkA6Ozg6Q7vu6
         tm/zbpL2tYCz5pRkifFuZzG2SVy8VY4vmhiq11AGBSJujVDwquhkny6bvi4sY31hM6YN
         qSgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=uoGfYWajZKkjcbjtVTLDy6dOkR7gJFyuID3v83PCoTw=;
        b=KV60p7rLKgnYG/MxfwbKvIiGRxco8E6GpF1T/2QzdYexurIYwpuC3miHvpUSorlnHH
         C9uBxb7vmPtBE6nNlLgP0Fm3++57CAc3pbxvLoHdcHR6AL1ViFKEKZqUN8OqZgkx1FHD
         gtvmpFnSvtmtZoKh0IxqGizVdDqid4ajipZDsfbe2MPgZ5yqZCsVDMIuX43im1kLDhOq
         1txyzbttewL23i4caSQwCmY3xZgAE1l+08NcLivss4DsI3qG90QQTgv5o8GxwmwDO+jc
         awbOcFYALv0QzhMkqg+3Qz8WNZY2Ace2GUPGWUj3qLy7jGThOJn9Ar/rE/Pt1kokHq4l
         GO6g==
X-Gm-Message-State: APjAAAWFFE4bST+3Fr0a+baukKf4z4omVnH2eerurvkJUI8kMD6/FKz6
        6ud6Q2B1t/eQnqZ4MNAtY64DqcHp
X-Google-Smtp-Source: APXvYqxhCoMJr3/X3UaIaKMfWdTfx70fF+OY/LqCU8uvIO8A3YP+kew0Xqh48ewm0Qalaknvp1Ttbg==
X-Received: by 2002:a24:1683:: with SMTP id a125mr28138965ita.64.1555421892333;
        Tue, 16 Apr 2019 06:38:12 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id p1sm9647858itp.19.2019.04.16.06.38.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:38:11 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDcBL3021241;
        Tue, 16 Apr 2019 13:38:11 GMT
Subject: [PATCH v2 15/21] SUNRPC: Update comments based on recent changes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:38:11 -0400
Message-ID: <20190416133811.23113.99038.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d7117d2..73db033 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -949,7 +949,7 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
  * @req: Request to pin
  *
  * Caller must ensure this is atomic with the call to xprt_lookup_rqst()
- * so should be holding the xprt receive lock.
+ * so should be holding xprt->queue_lock.
  */
 void xprt_pin_rqst(struct rpc_rqst *req)
 {
@@ -961,7 +961,7 @@ void xprt_pin_rqst(struct rpc_rqst *req)
  * xprt_unpin_rqst - Unpin a request on the transport receive list
  * @req: Request to pin
  *
- * Caller should be holding the xprt receive lock.
+ * Caller should be holding xprt->queue_lock.
  */
 void xprt_unpin_rqst(struct rpc_rqst *req)
 {

