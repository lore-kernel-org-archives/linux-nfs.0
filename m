Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:39738 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbbCIUFL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2015 16:05:11 -0400
Received: by qcvs11 with SMTP id s11so35743331qcv.6
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2015 13:05:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no notifications
Date: Mon,  9 Mar 2015 16:05:03 -0400
Message-Id: <1425931503-37261-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1425931503-37261-4-git-send-email-trond.myklebust@primarydata.com>
References: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-3-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The spec says that once all layouts that reference a given deviceid
have been returned, then we are only allowed to continue to cache
the deviceid if the metadata server supports notifications.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 fs/nfs/pnfs.h     | 2 ++
 fs/nfs/pnfs_dev.c | 9 +++++++++
 3 files changed, 13 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ba8b2b5e98a1..9ff8c63c9cac 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7962,6 +7962,8 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server,
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (res.notification & ~args.notify_types)
 		dprintk("%s: unsupported notification\n", __func__);
+	if (res.notification != args.notify_types)
+		pdev->nocache = 1;
 
 	dprintk("<-- %s status=%d\n", __func__, status);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a1fc16c971a7..b5654e8da936 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -203,6 +203,7 @@ struct pnfs_device {
 	struct page **pages;
 	unsigned int  pgbase;
 	unsigned int  pglen;	/* reply buffer length */
+	unsigned char nocache : 1;/* May not be cached */
 };
 
 #define NFS4_PNFS_GETDEVLIST_MAXNUM 16
@@ -291,6 +292,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 enum {
 	NFS_DEVICEID_INVALID = 0,       /* set when MDS clientid recalled */
 	NFS_DEVICEID_UNAVAILABLE,	/* device temporarily unavailable */
+	NFS_DEVICEID_NOCACHE,		/* device may not be cached */
 };
 
 /* pnfs_dev.c */
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 7e07f4ba4822..2961fcd7a2df 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -149,6 +149,8 @@ nfs4_get_device_info(struct nfs_server *server,
 	 */
 	d = server->pnfs_curr_ld->alloc_deviceid_node(server, pdev,
 			gfp_flags);
+	if (d && pdev->nocache)
+		set_bit(NFS_DEVICEID_NOCACHE, &d->flags);
 
 out_free_pages:
 	for (i = 0; i < max_pages; i++)
@@ -235,6 +237,7 @@ nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *ld,
 		return;
 	}
 	hlist_del_init_rcu(&d->node);
+	clear_bit(NFS_DEVICEID_NOCACHE, &d->flags);
 	spin_unlock(&nfs4_deviceid_lock);
 
 	/* balance the initial ref set in pnfs_insert_deviceid */
@@ -269,6 +272,11 @@ EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
 bool
 nfs4_put_deviceid_node(struct nfs4_deviceid_node *d)
 {
+	if (test_bit(NFS_DEVICEID_NOCACHE, &d->flags)) {
+		if (atomic_add_unless(&d->ref, -1, 2))
+			return false;
+		nfs4_delete_deviceid(d->ld, d->nfs_client, &d->deviceid);
+	}
 	if (!atomic_dec_and_test(&d->ref))
 		return false;
 	d->ld->free_deviceid_node(d);
@@ -312,6 +320,7 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
 		if (d->nfs_client == clp && atomic_read(&d->ref)) {
 			hlist_del_init_rcu(&d->node);
 			hlist_add_head(&d->tmpnode, &tmp);
+			clear_bit(NFS_DEVICEID_NOCACHE, &d->flags);
 		}
 	rcu_read_unlock();
 	spin_unlock(&nfs4_deviceid_lock);
-- 
2.1.0

