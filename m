Return-Path: <SRS0=DrMw=5M=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 734B2C2D0E7
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Mar 2020 23:27:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 480F72082D
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Mar 2020 23:27:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="AJ6Z0Q7m"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726781AbgC0X1W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 27 Mar 2020 19:27:22 -0400
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:39782 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726384AbgC0X1W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2020 19:27:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1585351642; x=1616887642;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version;
  bh=/ZCkEcg6m2F1Tbhx0TmvlrIxo0wJSypp0E89AmNsjqw=;
  b=AJ6Z0Q7m+JY2pfaztaWqDjxEYZJ0AAu6rIt4/YvKUE4yj7S+vaz3cdCA
   fNrt1jrXADVXe4yvqkWcoioUkRR7SADFyn8cFadyWWOXGlr0L0Q9KopLs
   UZSerWV67BDV/RXL2T38ej3lvATBbN3bEdaA7Ckj1RwE2nXSAwQX2xSjo
   k=;
IronPort-SDR: 7wxu6rjZZU4QxRhx5VDduMwrjwM3COzBouvzeb/m2aP9Z1SDoMnKk0BU5RRpDj6sTD1spmzp1i
 IUoLC92wKJjQ==
X-IronPort-AV: E=Sophos;i="5.72,314,1580774400"; 
   d="scan'208";a="25550511"
Received: from sea32-co-svc-lb4-vlan3.sea.corp.amazon.com (HELO email-inbound-relay-2a-e7be2041.us-west-2.amazon.com) ([10.47.23.38])
  by smtp-border-fw-out-9101.sea19.amazon.com with ESMTP; 27 Mar 2020 23:27:20 +0000
Received: from EX13MTAUWB001.ant.amazon.com (pdx4-ws-svc-p6-lb7-vlan2.pdx.amazon.com [10.170.41.162])
        by email-inbound-relay-2a-e7be2041.us-west-2.amazon.com (Postfix) with ESMTPS id 58233A2A30;
        Fri, 27 Mar 2020 23:27:19 +0000 (UTC)
Received: from EX13D13UWB002.ant.amazon.com (10.43.161.21) by
 EX13MTAUWB001.ant.amazon.com (10.43.161.207) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Fri, 27 Mar 2020 23:27:18 +0000
Received: from EX13MTAUEE002.ant.amazon.com (10.43.62.24) by
 EX13D13UWB002.ant.amazon.com (10.43.161.21) with Microsoft SMTP Server (TLS)
 id 15.0.1497.2; Fri, 27 Mar 2020 23:27:18 +0000
Received: from dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com
 (172.23.141.97) by mail-relay.amazon.com (10.43.62.224) with Microsoft SMTP
 Server id 15.0.1367.3 via Frontend Transport; Fri, 27 Mar 2020 23:27:17 +0000
Received: by dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com (Postfix, from userid 6262777)
        id 4D6BCDEFB6; Fri, 27 Mar 2020 23:27:17 +0000 (UTC)
From:   Frank van der Linden <fllinden@amazon.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>
CC:     Frank van der Linden <fllinden@amazon.com>
Subject: [PATCH v2 09/11] nfsd: use kvmalloc in svcxdr_tmpalloc
Date:   Fri, 27 Mar 2020 23:27:15 +0000
Message-ID: <20200327232717.15331-10-fllinden@amazon.com>
X-Mailer: git-send-email 2.16.6
In-Reply-To: <20200327232717.15331-1-fllinden@amazon.com>
References: <20200327232717.15331-1-fllinden@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

For user extended attributes, temp allocations larger than one page
might be needed.

Use kvmalloc/kvfree to accommodate these larger allocations, while not
affecting the performance of the smaller ones.

Signed-off-by: Frank van der Linden <fllinden@amazon.com>
---
 fs/nfsd/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6e7fc6a9931e..f6322add2992 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -230,7 +230,7 @@ svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, u32 len)
 {
 	struct svcxdr_tmpbuf *tb;
 
-	tb = kmalloc(sizeof(*tb) + len, GFP_KERNEL);
+	tb = kvmalloc(sizeof(*tb) + len, GFP_KERNEL);
 	if (!tb)
 		return NULL;
 	tb->next = argp->to_free;
@@ -4691,7 +4691,7 @@ void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
 	while (args->to_free) {
 		struct svcxdr_tmpbuf *tb = args->to_free;
 		args->to_free = tb->next;
-		kfree(tb);
+		kvfree(tb);
 	}
 }
 
-- 
2.17.2

