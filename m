Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38243 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756801Ab3EKCnB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:01 -0400
Received: by mail-wi0-f174.google.com with SMTP id m6so1202506wiv.13
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:42:59 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id ek7sm1226193wic.4.2013.05.10.19.42.58
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:42:59 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/38] Revert "pnfsd: Add way of determining if a client has a device."
Date: Sat, 11 May 2013 05:42:54 +0300
Message-Id: <1368240174-31997-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 3573c750c335ddff65c063f12bda1b54b288a674.
---
 fs/nfsd/nfs4pnfsd.c | 35 -----------------------------------
 fs/nfsd/nfs4proc.c  |  5 -----
 fs/nfsd/nfs4state.c |  1 -
 fs/nfsd/pnfsd.h     |  2 --
 fs/nfsd/state.h     |  1 -
 fs/nfsd/xdr4.h      |  1 -
 6 files changed, 45 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 35f43cf..8653719 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -114,35 +114,6 @@ struct sbid_tracker {
 	return 0;
 }
 
-/* XXX: Need to implement the notify types and track which
- * clients have which devices. */
-void pnfs_set_device_notify(clientid_t *clid, unsigned int types)
-{
-	struct nfs4_client *clp;
-	dprintk("%s: -->\n", __func__);
-
-	nfs4_lock_state();
-	/* Indicate that client has a device so we can only notify
-	 * the correct clients */
-	clp = find_confirmed_client(clid, true);
-	if (clp) {
-		atomic_inc(&clp->cl_deviceref);
-		dprintk("%s: Incr device count (clnt %p) to %d\n",
-			__func__, clp, atomic_read(&clp->cl_deviceref));
-	}
-	nfs4_unlock_state();
-}
-
-/* Clear notifications for this client
- * XXX: Do we need to loop through a clean up all
- *      krefs when nfsd cleans up the client? */
-void pnfs_clear_device_notify(struct nfs4_client *clp)
-{
-	atomic_dec(&clp->cl_deviceref);
-	dprintk("%s: Decr device count (clnt %p) to %d\n",
-		__func__, clp, atomic_read(&clp->cl_deviceref));
-}
-
 /*
  * Note: must be called under the state lock
  */
@@ -1593,9 +1564,6 @@ struct create_device_notify_list_arg {
 	struct nfs4_notify_device *cbnd;
 	struct create_device_notify_list_arg *arg = p;
 
-	if (atomic_read(&clp->cl_deviceref) <= 0)
-		return 0;
-
 	cbnd = kzalloc(sizeof(*cbnd), GFP_KERNEL);
 	if (!cbnd)
 		return -ENOMEM;
@@ -1633,7 +1601,6 @@ int nfsd_device_notify_cb(struct super_block *sb,
 			  struct nfsd4_pnfs_cb_dev_list *ndl)
 {
 	struct nfs4_notify_device *cbnd;
-	struct nfs4_client *nd_client;
 	unsigned int notify_num = 0;
 	int status = 0;
 	struct list_head todolist;
@@ -1653,9 +1620,7 @@ int nfsd_device_notify_cb(struct super_block *sb,
 		cbnd = list_entry(todolist.next, struct nfs4_notify_device,
 				  nd_perclnt);
 		list_del_init(&cbnd->nd_perclnt);
-		nd_client = cbnd->nd_client;
 		nfsd4_cb_notify_device(cbnd);
-		pnfs_clear_device_notify(nd_client);
 		notify_num++;
 	}
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4a79281..2f1786a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1143,7 +1143,6 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 {
 	struct super_block *sb;
 	int status;
-	clientid_t clid;
 
 	dprintk("%s: layout_type %u dev_id %llx:%llx maxcnt %u\n",
 	       __func__, gdp->gd_layout_type, gdp->gd_devid.sbid,
@@ -1166,10 +1165,6 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 
 	/* Set up arguments so device can be retrieved at encode time */
 	gdp->gd_sb = sb;
-
-	/* Update notifications */
-	copy_clientid(&clid, cstate->session);
-	pnfs_set_device_notify(&clid, gdp->gd_notify_types);
 out:
 	return status;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b404d33..664c7cb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1324,7 +1324,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 #if defined(CONFIG_PNFSD)
 	INIT_LIST_HEAD(&clp->cl_layouts);
 	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
-	atomic_set(&clp->cl_deviceref, 0);
 #endif /* CONFIG_PNFSD */
 	INIT_LIST_HEAD(&clp->cl_lru);
 	INIT_LIST_HEAD(&clp->cl_callbacks);
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 35859ff..5b3657c 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -131,8 +131,6 @@ int nfsd_layout_recall_cb(struct super_block *, struct inode *,
 int nfsd_device_notify_cb(struct super_block *,
 			  struct nfsd4_pnfs_cb_dev_list *);
 void nfsd4_cb_notify_device(struct nfs4_notify_device *);
-void pnfs_set_device_notify(clientid_t *, unsigned int types);
-void pnfs_clear_device_notify(struct nfs4_client *);
 
 static inline struct nfs4_layout_state *layoutstateid(struct nfs4_stid *s)
 {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 788e5e8..774927c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -285,7 +285,6 @@ struct nfs4_client {
 	struct list_head	cl_layouts;	/* outstanding layouts */
 	struct list_head	cl_layoutrecalls; /* outstanding layoutrecall
 						     callbacks */
-	atomic_t		cl_deviceref;	/* Num outstanding devs */
 #endif /* CONFIG_PNFSD */
 };
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 617e195..459d8ba 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -432,7 +432,6 @@ struct nfsd4_pnfs_getdevinfo {
 	struct nfsd4_pnfs_deviceid gd_devid;	/* request */
 	u32			gd_layout_type;	/* request */
 	u32			gd_maxcount;	/* request */
-	u32			gd_notify_types;/* request */
 	struct super_block	*gd_sb;
 };
 
-- 
1.7.11.7

