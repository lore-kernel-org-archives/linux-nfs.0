Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43373 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1EVXtd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:49:33 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 09/38] SQUASHME: pnfs: refactor device cache _lookup_deviceid
Date: Mon, 23 May 2011 02:48:41 +0300
Message-Id: <1306108121-28134-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs_dev.c |   49 +++++++++++++++++++++++++++----------------------
 1 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index d205b18..374fa66 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -66,6 +66,23 @@ nfs4_deviceid_hash(const struct nfs4_deviceid *id)
 	return x & NFS4_DEVICE_ID_HASH_MASK;
 }
 
+static struct nfs4_deviceid_node *
+_lookup_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
+		 long hash)
+{
+	struct nfs4_deviceid_node *d;
+	struct hlist_node *n;
+
+	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
+		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
+			if (atomic_read(&d->ref))
+				return d;
+			else
+				continue;
+		}
+	return NULL;
+}
+
 /*
  * Lookup a deviceid in cache and get a reference count on it if found
  *
@@ -76,21 +93,13 @@ struct nfs4_deviceid_node *
 nfs4_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
 	struct nfs4_deviceid_node *d;
-	struct hlist_node *n;
-	long hash = nfs4_deviceid_hash(id);
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node) {
-		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
-			if (!atomic_inc_not_zero(&d->ref))
-				goto fail;
-			rcu_read_unlock();
-			return d;
-		}
-	}
-fail:
+	d = _lookup_deviceid(clp, id, nfs4_deviceid_hash(id));
+	if (!atomic_inc_not_zero(&d->ref))
+		d = NULL;
 	rcu_read_unlock();
-	return NULL;
+	return d;
 }
 EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
 
@@ -106,19 +115,15 @@ struct nfs4_deviceid_node *
 nfs4_unhash_put_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
 	struct nfs4_deviceid_node *d;
-	struct hlist_node *n;
-	long hash = nfs4_deviceid_hash(id);
 
+	spin_lock(&nfs4_deviceid_lock);
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
-		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id)))
-			goto found;
+	d = _lookup_deviceid(clp, id, nfs4_deviceid_hash(id));
 	rcu_read_unlock();
-	return NULL;
-
-found:
-	rcu_read_unlock();
-	spin_lock(&nfs4_deviceid_lock);
+	if (!d) {
+		spin_unlock(&nfs4_deviceid_lock);
+		return NULL;
+	}
 	hlist_del_init_rcu(&d->node);
 	spin_unlock(&nfs4_deviceid_lock);
 	synchronize_rcu();
-- 
1.7.3.4

