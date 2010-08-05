Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760574Ab0HEOSG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 10:18:06 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFS: Fix /proc/mount for legacy binary interface
Date: Thu,  5 Aug 2010 10:17:50 -0400
Message-Id: <1281017872-6043-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1281017872-6043-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1281017872-6043-1-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-2-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

Add a flag so we know if we mounted the NFS server using the legacy
binary interface.  If we used the legacy interface, then we should not
show the mountd options.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c            |    4 ++++
 include/linux/nfs_mount.h |    1 +
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f9df16d..f1ae39f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -546,6 +546,9 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 {
 	struct sockaddr *sap = (struct sockaddr *)&nfss->mountd_address;
 
+	if (nfss->flags & NFS_MOUNT_LEGACY_INTERFACE)
+		return;
+
 	switch (sap->sa_family) {
 	case AF_INET: {
 		struct sockaddr_in *sin = (struct sockaddr_in *)sap;
@@ -1780,6 +1783,7 @@ static int nfs_validate_mount_data(void *options,
 		 * can deal with.
 		 */
 		args->flags		= data->flags & NFS_MOUNT_FLAGMASK;
+		args->flags		|= NFS_MOUNT_LEGACY_INTERFACE;
 		args->rsize		= data->rsize;
 		args->wsize		= data->wsize;
 		args->timeo		= data->timeo;
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 4499016..5d59ae8 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -69,5 +69,6 @@ struct nfs_mount_data {
 #define NFS_MOUNT_LOOKUP_CACHE_NONEG	0x10000
 #define NFS_MOUNT_LOOKUP_CACHE_NONE	0x20000
 #define NFS_MOUNT_NORESVPORT		0x40000
+#define NFS_MOUNT_LEGACY_INTERFACE	0x80000
 
 #endif
-- 
1.7.2

