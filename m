From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/5] pnfs-post-submit: pass struct nfs_server * to getdevicelist
Date: Thu,  6 May 2010 22:23:20 +0300
Message-ID: <1273173800-27713-1-git-send-email-bhalevy@panasas.com>
References: <4BE3166F.7060800@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:32581 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754813Ab0EFTX1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:23:27 -0400
In-Reply-To: <4BE3166F.7060800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c         |   11 +++++------
 fs/nfs/pnfs.h             |    4 ++--
 include/linux/nfs4_pnfs.h |    3 ++-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f7ab35d..3742ba0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5770,8 +5770,8 @@ out:
 /*
  * Retrieve the list of Data Server devices from the MDS.
  */
-static int _nfs4_pnfs_getdevicelist(struct nfs_fh *fh,
-				    struct nfs_server *server,
+static int _nfs4_pnfs_getdevicelist(struct nfs_server *server,
+				    const struct nfs_fh *fh,
 				    struct pnfs_devicelist *devlist)
 {
 	struct nfs4_pnfs_getdevicelist_arg arg = {
@@ -5794,17 +5794,16 @@ static int _nfs4_pnfs_getdevicelist(struct nfs_fh *fh,
 	return status;
 }
 
-int nfs4_pnfs_getdevicelist(struct super_block *sb,
-			    struct nfs_fh *fh,
+int nfs4_pnfs_getdevicelist(struct nfs_server *server,
+			    const struct nfs_fh *fh,
 			    struct pnfs_devicelist *devlist)
 {
 	struct nfs4_exception exception = { };
-	struct nfs_server *server = NFS_SB(sb);
 	int err;
 
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs4_pnfs_getdevicelist(fh, server, devlist),
+				_nfs4_pnfs_getdevicelist(server, fh, devlist),
 				&exception);
 	} while (exception.retry);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b5bb742..77623ea 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -22,8 +22,8 @@
 #include "iostat.h"
 
 /* nfs4proc.c */
-extern int nfs4_pnfs_getdevicelist(struct super_block *sb,
-				   struct nfs_fh *fh,
+extern int nfs4_pnfs_getdevicelist(struct nfs_server *server,
+				   const struct nfs_fh *fh,
 				   struct pnfs_devicelist *devlist);
 extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 3385a5c..87bb982 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -321,7 +321,8 @@ extern void nfs4_delete_device(struct nfs4_deviceid_cache *,
  * E.g., getdeviceinfo, I/O callbacks, etc
  */
 struct pnfs_client_operations {
-	int (*nfs_getdevicelist) (struct super_block *sb, struct nfs_fh *fh,
+	int (*nfs_getdevicelist) (struct nfs_server *,
+				  const struct nfs_fh *fh,
 				  struct pnfs_devicelist *devlist);
 	int (*nfs_getdeviceinfo) (struct nfs_server *,
 				  struct pnfs_device *dev);
-- 
1.6.5.1

