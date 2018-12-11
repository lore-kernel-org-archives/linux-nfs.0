Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4AD0C07E85
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 09:58:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 60DA02082F
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 09:58:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="VEd0Ugw5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60DA02082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726164AbeLKJ65 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 04:58:57 -0500
Received: from esa3.hgst.iphmx.com ([216.71.153.141]:6489 "EHLO
        esa3.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726117AbeLKJ65 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 04:58:57 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1544522337; x=1576058337;
  h=from:to:cc:subject:date:message-id;
  bh=OQrurx9pZYUdQMtZ2mb4ZcfbSAYqKn/5RMLKdrgpsCs=;
  b=VEd0Ugw5AvPNT7+xMoxPW1SPruzLOSBJsEzrGN7ZeNt1Qv3w74JVgYT8
   IcpBfx27peZg2SCs83rgQ+qR3UlRvv/zfiB6Z1u86Q4lj2aVcYhiw+3e2
   37zVYrQCOZPrJe5TJ3lSb1LYdS/xWki+hH4O4sFAiU7dkTHmB5x4N6Xah
   RSaOAdAuWSwhgJIFDh1JGsbak3onfHT2ugiLCupBg3AhKy5eQJkbB4pqC
   c5EYSjeABTiaVA9L4doBe/4ZVYxzkISjWnNidyEd7Y80TiVyBCew0/luC
   uVtDUPqugL0wEtsA+PWNuMQ1eIdN7am2biqE+RlsnSODk5/VmAIKan3Lb
   g==;
X-IronPort-AV: E=Sophos;i="5.56,342,1539619200"; 
   d="scan'208";a="101206922"
Received: from uls-op-cesaip02.wdc.com (HELO uls-op-cesaep02.wdc.com) ([199.255.45.15])
  by ob1.hgst.iphmx.com with ESMTP; 11 Dec 2018 17:58:56 +0800
Received: from uls-op-cesaip01.wdc.com ([10.248.3.36])
  by uls-op-cesaep02.wdc.com with ESMTP; 11 Dec 2018 01:41:31 -0800
Received: from unknown (HELO C02VRAUAHV29.wdc.com) ([10.113.196.133])
  by uls-op-cesaip01.wdc.com with ESMTP; 11 Dec 2018 01:58:55 -0800
From:   Santosh kumar pradhan <santoshkumar.pradhan@wdc.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org,
        Santosh Kumar Pradhan <santoshkumar.pradhan@wdc.com>
Subject: [PATCH] sunrpc: Add xprt after nfs4_test_session_trunk()
Date:   Tue, 11 Dec 2018 15:28:43 +0530
Message-Id: <20181211095843.5338-1-santoshkumar.pradhan@wdc.com>
X-Mailer: git-send-email 2.18.0
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Santosh Kumar Pradhan <santoshkumar.pradhan@wdc.com>

Multipathing: In case of NFSv3, rpc_clnt_test_and_add_xprt() adds
the xprt to xprt switch (i.e. xps) if rpc_call_null_helper() returns
success. But in case of NFSv4.1, it needs to do EXCHANGEID to verify
the path along with check for session trunking.

Add the xprt once nfs4_test_session_trunk() returns success.
Also release refcount hold by rpc_clnt_setup_test_and_add_xprt().

Signed-off-by: Santosh Kumar Pradhan <santoshkumar.pradhan@wdc.com>
Tested-by: Suresh Jayaraman <suresh.jayaraman@wdc.com>
---
 net/sunrpc/clnt.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d839c33ae7d9..053f594cc144 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2654,10 +2654,14 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 		goto out_err;
 
 	/* rpc_xprt_switch and rpc_xprt are deferrenced by add_xprt_test() */
-	xtest->add_xprt_test(clnt, xprt, xtest->data);
+	status = xtest->add_xprt_test(clnt, xprt, xtest->data);
+	if (status != 0)
+		goto out_err;
 
-	/* so that rpc_clnt_add_xprt does not call rpc_xprt_switch_add_xprt */
-	return 1;
+	xprt_put(xprt);
+	xprt_switch_put(xps);
+	/* so that rpc_clnt_add_xprt calls rpc_xprt_switch_add_xprt */
+	return 0;
 out_err:
 	xprt_put(xprt);
 	xprt_switch_put(xps);
-- 
2.17.1

