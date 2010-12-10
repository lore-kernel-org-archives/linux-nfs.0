Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618Ab0LJGIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:48 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLm023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:48 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/22] pnfs-submit: wave2: NFS4ERR_RESOURCE is not a valid error for CB_LAYOUTRECALL
Date: Thu,  9 Dec 2010 20:22:46 -0500
Message-Id: <1291944177-7819-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

and neither is SERVERFAULT, which pretty much means our only option
on memory allocation failure is DELAY.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2274b6f..61b3c66 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -348,7 +348,7 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (!new) {
-		res = NFS4ERR_RESOURCE;
+		res = NFS4ERR_DELAY;
 		goto out;
 	}
 	memcpy(&new->pcl_args, args, sizeof(*args));
-- 
1.7.2.1

