Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:21103 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755821Ab3EHUOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 16:14:47 -0400
From: andros@netapp.com
To: trondmyklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFS4.1 Fix data server connection race
Date: Wed,  8 May 2013 16:13:50 -0400
Message-Id: <1368044030-2401-2-git-send-email-andros@netapp.com>
In-Reply-To: <1368044030-2401-1-git-send-email-andros@netapp.com>
References: <1368044030-2401-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Unlike meta data server mounts which support multiple mount points to
the same server via struct nfs_server, data servers support a single connection.

Concurrent calls to setup the data server connection can race where the first
call allocates the nfs_client struct, and before the cache struct nfs_client
pointer can be set, a second call also tries to setup the connection, finds the
already allocated nfs_client, bumps the reference count, re-initializes the
session,etc. This results in a hanging data server session after umount.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.h    |  2 ++
 fs/nfs/nfs4filelayoutdev.c | 26 ++++++++++++++++++++++++--
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index b8da955..235ff95 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -70,6 +70,8 @@ struct nfs4_pnfs_ds {
 	struct list_head	ds_addrs;
 	struct nfs_client	*ds_clp;
 	atomic_t		ds_count;
+	unsigned long		ds_state;
+#define NFS4DS_CONNECTING	0	/* ds is establishing connection */
 };
 
 struct nfs4_file_layout_dsaddr {
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 1fe284f..661a0f6 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -775,6 +775,22 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
 	return flseg->fh_array[i];
 }
 
+static void nfs4_wait_ds_connect(struct nfs4_pnfs_ds *ds)
+{
+	might_sleep();
+	wait_on_bit(&ds->ds_state, NFS4DS_CONNECTING,
+			nfs_wait_bit_killable, TASK_KILLABLE);
+}
+
+static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(NFS4DS_CONNECTING, &ds->ds_state);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&ds->ds_state, NFS4DS_CONNECTING);
+}
+
+
 struct nfs4_pnfs_ds *
 nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 {
@@ -791,16 +807,22 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		filelayout_mark_devid_invalid(devid);
 		return NULL;
 	}
+	if (ds->ds_clp)
+		return ds;
 
-	if (!ds->ds_clp) {
+	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
 		struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
 		int err;
 
 		err = nfs4_ds_connect(s, ds);
 		if (err) {
 			nfs4_mark_deviceid_unavailable(devid);
-			return NULL;
+			ds = NULL;
 		}
+		nfs4_clear_ds_conn_bit(ds);
+	} else {
+		/* Either ds is connected, or ds is NULL */
+		nfs4_wait_ds_connect(ds);
 	}
 	return ds;
 }
-- 
1.7.11.7

