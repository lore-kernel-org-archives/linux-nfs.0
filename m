Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64726 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059Ab0LOQD1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:27 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Lp0001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:26 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/11] wave 2: Fix outdated comment above _pnfs_return_layout
Date: Wed, 15 Dec 2010 11:03:09 -0500
Message-Id: <1292428991-30788-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f4e618d..93f50f4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -585,7 +585,9 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 		}
 }
 
-/* Initiates a LAYOUTRETURN(FILE) */
+/* Since we are using the forgetful model, nothing is sent over the wire.
+ * However, we still must stop using any matching layouts.
+ */
 int
 _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		    bool wait)
-- 
1.7.2.1

