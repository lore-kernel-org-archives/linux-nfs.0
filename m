Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JAQDi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:38 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Uel008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:37 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] SQUASHME: pnfs-devinfo-submit: misc small fixes
Date: Fri,  1 Oct 2010 12:02:45 -0400
Message-Id: <1285948971-2048-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These are various minor touchups to the devinfo submission code

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |    2 +-
 fs/nfs/nfs4filelayoutdev.c |    4 +---
 fs/nfs/pnfs.c              |    4 ++--
 fs/nfs/pnfs.h              |    5 -----
 fs/nfs/read.c              |    1 -
 5 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index a33c47e..2b6e3c9 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -631,7 +631,7 @@ filelayout_get_stripesize(struct pnfs_layout_hdr *lo)
 	lseg = pnfs_has_layout(lo, &range);
 	if (!lseg)
 		return 0;
-	fl = container_of(lseg, struct nfs4_filelayout_segment, generic_hdr);
+	fl = FILELAYOUT_LSEG(lseg);
 	size = fl->stripe_unit;
 	put_lseg_locked(lseg);
 	return size;
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index e4f91f6..5da6fec 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -355,9 +355,7 @@ out_err:
 	return ds;
 }
 
-
-
-/*Decode opaque device data and return the result */
+/* Decode opaque device data and return the result */
 static struct nfs4_file_layout_dsaddr*
 decode_device(struct inode *ino, struct pnfs_device *pdev)
 {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 333b7db..131602c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -50,7 +50,7 @@ static LIST_HEAD(pnfs_modules_tbl);
 static struct pnfs_layoutdriver_type *
 find_pnfs_driver_locked(u32 id)
 {
-	struct  pnfs_layoutdriver_type *local;
+	struct pnfs_layoutdriver_type *local;
 
 	list_for_each_entry(local, &pnfs_modules_tbl, pnfs_tblid)
 		if (local->id == id)
@@ -64,7 +64,7 @@ out:
 static struct pnfs_layoutdriver_type *
 find_pnfs_driver(u32 id)
 {
-	struct  pnfs_layoutdriver_type *local;
+	struct pnfs_layoutdriver_type *local;
 
 	spin_lock(&pnfs_spinlock);
 	local = find_pnfs_driver_locked(id);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9500aa4..4ea3ae0 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -153,7 +153,6 @@ struct pnfs_deviceid_cache {
 	atomic_t		dc_ref;
 	void			(*dc_free_callback)(struct pnfs_deviceid_node *);
 	struct hlist_head	dc_deviceids[NFS4_DEVICE_ID_HASH_SIZE];
-	struct hlist_head	dc_to_free;
 };
 
 extern int pnfs_alloc_init_deviceid_cache(struct nfs_client *,
@@ -295,10 +294,6 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
-static inline void put_lseg_locked(struct pnfs_layout_segment *lseg)
-{
-}
-
 static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index be29689..c34f97d 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -29,7 +29,6 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
-#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-- 
1.7.2.1

