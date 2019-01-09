Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A416BC43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 16:38:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 662F8205C9
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 16:38:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="neRxbZRU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726542AbfAIQil (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 11:38:41 -0500
Received: from esa3.hgst.iphmx.com ([216.71.153.141]:3940 "EHLO
        esa3.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726541AbfAIQil (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2019 11:38:41 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1547051922; x=1578587922;
  h=from:to:cc:subject:date:message-id;
  bh=uwxBjlUAPOo6DRjudE1tf3Cy2veVtyYdsHM1/u+Thv4=;
  b=neRxbZRUSgr35evmY07Y7XWHxCfDlYncenG4Bbz7KWduisCsZ7VOpsd8
   VeWPMnTuHk9e3AczDeX5cCJ0wgurQ0dxTXeck8tMBIVq1wtKpvV8n21wB
   Y549egR93hYf3LaNziPtoBzXsyr1SJXu9gRw7qmGZegpdeMr1EwnVHrPG
   6jsn3sBx4+i1dx/VxIJHYU0unONo3PL+9YGc+jst4vKC6wGJj7Dn09LGs
   oh5oN7B9kSq+bpHVUY7TAm+kLchR9zJPfSDTtWdqommFTn6YfcGHd5YJE
   SbyLHMEmtK0K7Gdpklq1s2jKtJF7F7MsdlnY0SSi1zGxYspqSNdi54Zj5
   w==;
X-IronPort-AV: E=Sophos;i="5.56,458,1539619200"; 
   d="scan'208";a="103293414"
Received: from uls-op-cesaip01.wdc.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 10 Jan 2019 00:38:32 +0800
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 09 Jan 2019 08:18:31 -0800
Received: from ind001917.ad.shared (HELO C02VRAUAHV29.hgst.com) ([10.199.177.224])
  by uls-op-cesaip02.wdc.com with ESMTP; 09 Jan 2019 08:38:29 -0800
From:   Santosh kumar pradhan <santoshkumar.pradhan@wdc.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org, davej@codemonkey.org.uk,
        Santosh kumar pradhan <santoshkumar.pradhan@wdc.com>
Subject: [PATCH] sunrpc: kernel BUG at kernel/cred.c:825!
Date:   Wed,  9 Jan 2019 22:08:26 +0530
Message-Id: <20190109163826.2851-1-santoshkumar.pradhan@wdc.com>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Init missing debug member magic with CRED_MAGIC.

Signed-off-by: Santosh kumar pradhan <santoshkumar.pradhan@wdc.com>
Reported-by: Dave Jones <davej@codemonkey.org.uk>
---
 net/sunrpc/auth.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 1ff9768f5456..f3023bbc0b7f 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -41,6 +41,9 @@ static unsigned long number_cred_unused;
 
 static struct cred machine_cred = {
 	.usage = ATOMIC_INIT(1),
+#ifdef CONFIG_DEBUG_CREDENTIALS
+	.magic = CRED_MAGIC,
+#endif
 };
 
 /*
-- 
2.20.1

