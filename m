Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47169 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab1BUW3u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:29:50 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/9] pnfsd: Initialize cb_layout clr_recall.cb_work
Date: Mon, 21 Feb 2011 14:29:45 -0800
Message-Id: <1298327385-6766-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fixes a 2,6,37-only bug

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 4aa7999..507e3e2 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -579,6 +579,7 @@ alloc_init_layoutrecall(struct nfsd4_pnfs_cb_layout *cbl,
 
 	kref_init(&clr->clr_ref);
 	INIT_LIST_HEAD(&clr->clr_perclnt);
+	INIT_WORK(&clr->clr_recall.cb_work, nfsd4_do_callback_rpc);
 
 	dprintk("NFSD %s return %p\n", __func__, clr);
 	return clr;
-- 
1.7.3.4

