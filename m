From: andros@netapp.com
Subject: [PATCH 3/5] pnfs_post_submit: add getdevicelist io operation
Date: Fri, 30 Apr 2010 14:27:10 -0400
Message-ID: <1272652032-2496-4-git-send-email-andros@netapp.com>
References: <1272652032-2496-1-git-send-email-andros@netapp.com>
 <1272652032-2496-2-git-send-email-andros@netapp.com>
 <1272652032-2496-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933885Ab0D3S1q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 14:27:46 -0400
In-Reply-To: <1272652032-2496-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The block layout driver called getdevicelist in it's
initialize_mountpoint layoutdriver_io_operation. Since initialize_mountpoint
has been moved to nfs_probe_fsinfo where the required super block and file
handle are not available, provide a getdevicelist call in nfs4_get_root.

There is no error returned because the layout driver will handle errors
internally, and there is no reason to fail the mount.
If GETDEVICELIST fails, the layout driver can
either fall back to NFSv4.1 by calling nfs4_put_deviceid_cache and removing
the nfs_server->pnfs_curr_ld pointer, or ignore the error and call
GETDEVICEINFO on unresolved device id's presented by LAYOUTGET.

nfs4_pnfs_getdevicelist does call nfs4_handle_exception which handles
session level and other errors.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/getroot.c          |    3 +++
 fs/nfs/pnfs.h             |   13 +++++++++++++
 include/linux/nfs4_pnfs.h |    1 +
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index b35d2a6..fe61767 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -38,6 +38,7 @@
 #include "nfs4_fs.h"
 #include "delegation.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
@@ -286,6 +287,8 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 	if (!mntroot->d_op)
 		mntroot->d_op = server->nfs_client->rpc_ops->dentry_ops;
 
+	nfs4_getdevicelist(sb, mntfh);
+
 	dprintk("<-- nfs4_get_root()\n");
 	return mntroot;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a44cde8..08b2af7 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -106,6 +106,13 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
+static inline void
+nfs4_getdevicelist(struct super_block *sb, struct nfs_fh *fh)
+{
+	if (PNFS_EXISTS_LDIO_OP(NFS_SB(sb), getdevicelist))
+		NFS_SB(sb)->pnfs_curr_ld->ld_io_ops->getdevicelist(sb, fh);
+}
+
 static inline enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
@@ -280,6 +287,12 @@ static inline int pnfs_use_rpc(struct nfs_server *nfss)
 
 #else  /* CONFIG_NFS_V4_1 */
 
+static inline void
+nfs4_getdevicelist(struct super_block *sb, struct nfs_fh *fh)
+{
+	return;
+}
+
 static inline enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 6b37319..b99843b 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -170,6 +170,7 @@ struct layoutdriver_io_operations {
 	 */
 	int (*initialize_mountpoint) (struct nfs_client *);
 	int (*uninitialize_mountpoint) (struct nfs_server *server);
+	int (*getdevicelist) (struct super_block *, struct nfs_fh *);
 };
 
 enum layoutdriver_policy_flags {
-- 
1.6.6

