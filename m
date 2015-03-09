Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:33482 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbbCIUFJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2015 16:05:09 -0400
Received: by qcvx3 with SMTP id x3so5737017qcv.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2015 13:05:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv4.1: Cleanup - don't opencode nfs4_put_deviceid_node()
Date: Mon,  9 Mar 2015 16:05:01 -0400
Message-Id: <1425931503-37261-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
References: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There really is no reason to do so.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_dev.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index bf23ac97d57d..7e07f4ba4822 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -238,8 +238,7 @@ nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *ld,
 	spin_unlock(&nfs4_deviceid_lock);
 
 	/* balance the initial ref set in pnfs_insert_deviceid */
-	if (atomic_dec_and_test(&d->ref))
-		d->ld->free_deviceid_node(d);
+	nfs4_put_deviceid_node(d);
 }
 EXPORT_SYMBOL_GPL(nfs4_delete_deviceid);
 
@@ -323,8 +322,7 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
 	while (!hlist_empty(&tmp)) {
 		d = hlist_entry(tmp.first, struct nfs4_deviceid_node, tmpnode);
 		hlist_del(&d->tmpnode);
-		if (atomic_dec_and_test(&d->ref))
-			d->ld->free_deviceid_node(d);
+		nfs4_put_deviceid_node(d);
 	}
 }
 
-- 
2.1.0

