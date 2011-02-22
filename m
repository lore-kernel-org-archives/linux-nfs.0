Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29833 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab1BVX4F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 18:56:05 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] NFSv4.1: reject zero layout with zeroed stripe unit
Date: Tue, 22 Feb 2011 15:56:01 -0800
Message-Id: <1298418961-15667-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Allowing stripe_unit==0 causes the client to crash later on
when dividing by zero.

Reported-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 23f930c..3982665 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -92,8 +92,8 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 		goto out;
 	}
 
-	if (fl->stripe_unit % PAGE_SIZE) {
-		dprintk("%s Stripe unit (%u) not page aligned\n",
+	if (!fl->stripe_unit || fl->stripe_unit % PAGE_SIZE) {
+		dprintk("%s Invalid stripe unit (%u)\n",
 			__func__, fl->stripe_unit);
 		goto out;
 	}
-- 
1.7.3.4

