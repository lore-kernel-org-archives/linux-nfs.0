Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF75CC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE28621773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LddVo2jZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730489AbfDXNkM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:40:12 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:38554 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727335AbfDXNkM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:40:12 -0400
Received: by mail-io1-f68.google.com with SMTP id y6so8167322ior.5;
        Wed, 24 Apr 2019 06:40:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=uoGfYWajZKkjcbjtVTLDy6dOkR7gJFyuID3v83PCoTw=;
        b=LddVo2jZ6bxoiTA3Xk9V7/LXNpX6Zbx+NlleJV2/EYiP7wmcg8GakJ8dXzIsEBwpJA
         7qEP6j/IXTzFRm+w05y9FkoYVkQ5UxXQsYX2hOiLSgUZbovXIwB7ZI46EbK77Il5da/Y
         E/C6IInkmZlC14cPCxITuAmih8IEZsQP3YJ55BqRr4rnVH0Fx3k38QqkTjMyicFaHKjv
         maHSRNUHsI2PycfhIDNGmV/YNty6r31Z/DIW40Mgg8rTza9IX6uCne0oCOInTobSMDzQ
         CtL+ipA3Yx4Wkx1ZwMdZ0PEFGn9YVUAYVapMWlIQza2qBuJJc2oJRsv8aJfwX6C938C0
         2AgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=uoGfYWajZKkjcbjtVTLDy6dOkR7gJFyuID3v83PCoTw=;
        b=PFlZ5rNfoEd8Q0KyYKXlAyAXzKGCh8iureu0TksoBK2x/hQzMlSEx2d8863Iax+cYv
         rwCn4tZpo41nMsSfg7oygUUjENfBg7bL7de/6aGBGIoIXFnPbCZP/Wnsge3+jp88JfET
         M443gC+xW/9Hu6y2zk53RxxdTgc+eamlFeVmMpne4jxWH2Nm7qdYe/z8vLr/lIoYyXIC
         MQnHLQXvnNOG1gY3xJrbvuSGLWA1k8T/+HOK81dyAMkHOXUJnF1X9QqPmvbKpq81TqMR
         mD/QsoF1MDU5BHeZVQxIWRRBbLGeZZeyKkWG/QyRh0SbRAO5ObAPf5qeYk/YOevy4yK+
         67dA==
X-Gm-Message-State: APjAAAXUpKKwyQ8VhTPZZSKorvhCmsbJtP4Whszl7C/FJrTeBKh+ZeAQ
        oAH1UYgbHthvJWhIPLK0rBM=
X-Google-Smtp-Source: APXvYqy/7X2agIZgnavC8vLT0Oj10uqC+O7Vq/R2Fbf/u/S0Y0Yf/OveVgigShv5HWmUjpJTjbE5CQ==
X-Received: by 2002:a6b:6003:: with SMTP id r3mr6203458iog.37.1556113211280;
        Wed, 24 Apr 2019 06:40:11 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u16sm1288899iol.66.2019.04.24.06.40.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:40:10 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODe9mr011322;
        Wed, 24 Apr 2019 13:40:09 GMT
Subject: [PATCH v3 15/21] SUNRPC: Update comments based on recent changes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:40:09 -0400
Message-ID: <20190424134009.5077.7421.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
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

