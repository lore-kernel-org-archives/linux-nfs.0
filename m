Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7282 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752932Ab2HGPad (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 11:30:33 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, joro@8bytes.org, mdauchy@gmail.com
Subject: [PATCH] NFS: Clear key construction data if the idmap upcall fails
Date: Tue,  7 Aug 2012 11:30:31 -0400
Message-Id: <1344353431-28831-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

idmap_pipe_downcall already clears this field if the upcall succeeds,
but if it fails (rpc.idmapd isn't running) the field will still be set
on the next call triggering a BUG_ON().

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b701358..645cfe7 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -683,10 +683,12 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 
 	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
 	if (ret < 0)
-		goto out2;
+		goto out3;
 
 	return ret;
 
+out3:
+	idmap->idmap_key_cons = NULL;
 out2:
 	kfree(im);
 out1:
-- 
1.7.11.4

