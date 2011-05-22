Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43383 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626Ab1EVXuM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:50:12 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 10/38] SQUASHME: pnfs: refactor device cache _find_get_deviceid
Date: Mon, 23 May 2011 02:49:38 +0300
Message-Id: <1306108178-28173-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs_dev.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 374fa66..f830616 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -90,17 +90,24 @@ _lookup_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
  * @id deviceid to look up
  */
 struct nfs4_deviceid_node *
-nfs4_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
+		   long hash)
 {
 	struct nfs4_deviceid_node *d;
 
 	rcu_read_lock();
-	d = _lookup_deviceid(clp, id, nfs4_deviceid_hash(id));
+	d = _lookup_deviceid(clp, id, hash);
 	if (!atomic_inc_not_zero(&d->ref))
 		d = NULL;
 	rcu_read_unlock();
 	return d;
 }
+
+struct nfs4_deviceid_node *
+nfs4_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+{
+	return _find_get_deviceid(clp, id, nfs4_deviceid_hash(id));
+}
 EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
 
 /*
@@ -189,13 +196,13 @@ nfs4_insert_deviceid_node(struct nfs4_deviceid_node *new)
 	long hash;
 
 	spin_lock(&nfs4_deviceid_lock);
-	d = nfs4_find_get_deviceid(new->nfs_client, &new->deviceid);
+	hash = nfs4_deviceid_hash(&new->deviceid);
+	d = _find_get_deviceid(new->nfs_client, &new->deviceid, hash);
 	if (d) {
 		spin_unlock(&nfs4_deviceid_lock);
 		return d;
 	}
 
-	hash = nfs4_deviceid_hash(&new->deviceid);
 	hlist_add_head_rcu(&new->node, &nfs4_deviceid_cache[hash]);
 	spin_unlock(&nfs4_deviceid_lock);
 
-- 
1.7.3.4

