Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755862Ab2CLPdC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 11:33:02 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Check return value from rpc_queue_upcall()
Date: Mon, 12 Mar 2012 11:33:00 -0400
Message-Id: <1331566380-15162-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This function could fail to queue the upcall if rpc.idmapd is not running,
causing a warning message to be printed.  Instead, I want to check the
return value and revoke the key if the upcall can't be run.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

---
 fs/nfs/idmap.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index f9f89fc..a701a83 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -656,14 +656,19 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 
 	idmap->idmap_key_cons = cons;
 
-	return rpc_queue_upcall(idmap->idmap_pipe, msg);
+	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
+	if (ret < 0)
+		goto out2;
+
+	return ret;
 
 out2:
 	kfree(im);
 out1:
 	kfree(msg);
 out0:
-	complete_request_key(cons, ret);
+	key_revoke(cons->key);
+	key_revoke(cons->authkey);
 	return ret;
 }
 
-- 
1.7.9.2

