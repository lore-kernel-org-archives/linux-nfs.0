Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBEC3C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9D4702133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="piEGMR/p"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388329AbeLQQlx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:53 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:35605 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQlx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:53 -0500
Received: by mail-it1-f196.google.com with SMTP id p197so20946607itp.0;
        Mon, 17 Dec 2018 08:41:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=zl8j8je6pfA0Wi9IzJb3FMhbqTE3c/KKDSDa4e1eAIg=;
        b=piEGMR/p/W7nsqva7Ldjl+XONIPE+oILpDt/jClVSFqfhZG7hN+ha7xdI/fCaLCW/X
         tWEGWqRJ5KpNxLlR0rhRPa9O+1WdrtBTBzBzT8dcI5Il3kzd0SgpRshZ08x66WB+KYuC
         TVpPqnmx1l3LIJSUwp3dMmiq3f81zQ5ORSSx5g2S2QuV5nBqI59OV5UaTajGwT3lOaLh
         Eyk99uaYpjVtsmCpTCu7hYmnzVjwRyIv4oN768k7ExQWTUsgM/XoBKqTr5oPl1DR9ssN
         PWXlGcEjjzBf4jbLTukTpASz7WnyPs3NuRSDf2N/ZB+YjLxSi6IAJL/qlqZ0UkuGvZl9
         Luog==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=zl8j8je6pfA0Wi9IzJb3FMhbqTE3c/KKDSDa4e1eAIg=;
        b=mCw1fOllESoOFg/PqmdD7FRW5tiJzeXF2/BG6IWxIp7jCCaELmABBcB4P94jsojrtm
         HgS6D/gIYqwyXa4WYkqlgQe2aOgx1D4KtE8SmRQx7oZdzImmS4SBP6bjfY2x4mn65Ft1
         XH+7nXT3xdPju7o4e7/ymqCXN42DKIfqx3ysi6Uor7QjnZysTWMMUuctdN3/eKH9tfd1
         NkrOPAdYh8hiBAjHIus8ghFp6wAl9HGutrSdXdXCirD+4bIxz1LeMc1ImLWKKipFFFV7
         oI4zDxclEPgMGW0zDvoJVSc4Q5c0+aIaERzdZshL7Q+iKRUHvD5Hp8/y8f4k54NgCf/t
         YacA==
X-Gm-Message-State: AA+aEWYtny5q4uuZuzzT6buKgTIkNRECel916bbpcEyI08rJVfMuUFm9
        r5jN6GW6DuZMzPX9PtAl+ANhv6tb
X-Google-Smtp-Source: AFSGD/XveRTjmxb+GTSw+E72w4inBbHu+DzErbMP1I9CASYGL/MJumwWJaZxxDgAYrnc+o4anfb+oA==
X-Received: by 2002:a24:9fc1:: with SMTP id c184mr12386661ite.8.1545064912167;
        Mon, 17 Dec 2018 08:41:52 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t6sm6397677ioc.87.2018.12.17.08.41.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:51 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfoS4018663;
        Mon, 17 Dec 2018 16:41:50 GMT
Subject: [PATCH v4 28/30] xprtrdma: Add documenting comment for
 rpcrdma_buffer_destroy
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:50 -0500
Message-ID: <20181217164150.24133.67463.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Make a note of the function's dependency on an earlier ib_drain_qp.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c69b985..339c40e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1177,6 +1177,14 @@ struct rpcrdma_req *
 	dprintk("RPC:       %s: released %u MRs\n", __func__, count);
 }
 
+/**
+ * rpcrdma_buffer_destroy - Release all hw resources
+ * @buf: root control block for resources
+ *
+ * ORDERING: relies on a prior ib_drain_qp :
+ * - No more Send or Receive completions can occur
+ * - All MRs, reps, and reqs are returned to their free lists
+ */
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {

