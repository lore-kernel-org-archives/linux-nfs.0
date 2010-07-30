Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27408 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755870Ab0G3TRd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jul 2010 15:17:33 -0400
Received: from [10.58.58.222] ([10.58.58.222])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o6UJHW2H014265
	for <linux-nfs@vger.kernel.org>; Fri, 30 Jul 2010 12:17:32 -0700 (PDT)
Message-ID: <4C532564.2030302@netapp.com>
Date: Fri, 30 Jul 2010 15:17:56 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix /proc/mount for legacy binary interface
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add a flag so we know if we mounted the NFS server using the legacy
binary interface.  If we used the legacy interface, then we should not
show the mountd options.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f9df16d..9b359a7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -546,6 +546,9 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 {
 	struct sockaddr *sap = (struct sockaddr *)&nfss->mountd_address;

+	if (nfss->flags & NFS_MOUNT_LEGACY_INTERFACE)
+		return
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
