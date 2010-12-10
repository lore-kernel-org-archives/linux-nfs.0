Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25679 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab0LJGI5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:57 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLw023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:56 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 21/22] SQUASHME: pnfs: filelayout: call print_ds under ifdebug(FACILITY)
Date: Thu,  9 Dec 2010 20:22:56 -0500
Message-Id: <1291944177-7819-22-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fb0efda..328c504 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -596,7 +596,8 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 		}
 		dprintk("%s: Initiating commit: %llu USE DS:\n",
 			__func__, file_offset);
-		print_ds(ds);
+		ifdebug(FACILITY)
+			print_ds(ds);
 
 		/* Send COMMIT to data server */
 		nfs_initiate_commit(dsdata, clnt, call_ops, sync);
-- 
1.7.2.1

