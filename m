Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E678C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CE254217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UXfr4FId"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727902AbfDPNip (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:38:45 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:56259 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726751AbfDPNip (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:38:45 -0400
Received: by mail-it1-f196.google.com with SMTP id y134so32980604itc.5;
        Tue, 16 Apr 2019 06:38:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Kbvt0+GLH4AETSLDGCMvyv9BMJPUeHtyW2KtBML5y9c=;
        b=UXfr4FIdL740tuZqzCGr5lwsiQIgzve4O0XTX6yu4wO48VcMTY0xauJJXyjyFurZu4
         X+3xORrU/hQYrczbwmuQ0uKJOMUaHrpqXyUfpOj1MArjQ0QcaZn8iA5SNBzp52Mi+N2v
         mGc6cmDrci2zyGOPuSm5Opfc/7hSN/N03WwdXRQXACxa71JhJVOAcxnqZi7SjAptaaWU
         abhJk6sI9x6Isloa2IJw+hOgYGa2qgK8inYqzXg784BltgxDwQ9qR/RmE5on++Xfi1XB
         nvabBcQ5NouQXN3J657H4t7kh3TSrAxP/TGaiwLz6G7MtMRZox/q/xusr8LCVomwrW3b
         aTuA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Kbvt0+GLH4AETSLDGCMvyv9BMJPUeHtyW2KtBML5y9c=;
        b=nyjPuWY5gl5+YugI4QWpbp/++U8Potcfwn7CLq/4oIALvC+trMg20hHZV7TTee80Vl
         Zi3fnEuI35Wdl6MYDEZ3duZUZ97yTqwRKyAItZCr7AvJl4qIM39x8rBJxuGe4bTUftjP
         BeXCX5quqyzR0C+zsObjTXPd0+GRF67eBVRTucikKyDLCetdyR8E9xhdyseNcBhpOtQk
         X3cVUQZ17q0dZ3iChpWt0ry29Q/CPIwBb8nqDlzaO54dz+3d+ceaoWtlQtVSPVpQR+Co
         rjYQJYo6U4Mq5eXqwuXYJvfsHQ+M5G1fiiEeZbMhE7vJ4z6UjYsg2TRfppGUMtzPEA6L
         DqaQ==
X-Gm-Message-State: APjAAAVDZ23S3cAL4xQMywEZojwtXYKbm2U6iQBSox5g0cvNQ1aGq1qf
        7Saakq/0kK5IeXIbMs8rTbZelI7K
X-Google-Smtp-Source: APXvYqyjLEvFvJHLZvmoFoH+NLatPpWViYHirzeJGQSKQtYIOqyIGF1MY8scMWcAmvWr2FTrhcv7Lw==
X-Received: by 2002:a24:5dc8:: with SMTP id w191mr28976178ita.136.1555421924209;
        Tue, 16 Apr 2019 06:38:44 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b8sm9837347itb.20.2019.04.16.06.38.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:38:43 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDchFJ021259;
        Tue, 16 Apr 2019 13:38:43 GMT
Subject: [PATCH v2 21/21] xprtrdma: Remove stale comment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:38:43 -0400
Message-ID: <20190416133842.23113.11169.stgit@manet.1015granger.net>
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

The comment hasn't been accurate for several years.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 803f097..f4ea29e 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -239,13 +239,6 @@ struct rpcrdma_sendctx {
  *
  * An external memory region is any buffer or page that is registered
  * on the fly (ie, not pre-registered).
- *
- * Each rpcrdma_buffer has a list of free MWs anchored in rb_mrs. During
- * call_allocate, rpcrdma_buffer_get() assigns one to each segment in
- * an rpcrdma_req. Then rpcrdma_register_external() grabs these to keep
- * track of registration metadata while each RPC is pending.
- * rpcrdma_deregister_external() uses this metadata to unmap and
- * release these resources when an RPC is complete.
  */
 enum rpcrdma_frwr_state {
 	FRWR_IS_INVALID,	/* ready to be used */

