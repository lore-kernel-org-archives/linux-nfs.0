Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:63197 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:25 -0400
Received: by mail-qe0-f53.google.com with SMTP id jy17so1108206qeb.12
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:25 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 37/49] pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report dlm device list.
Date: Thu, 26 Sep 2013 14:42:22 -0400
Message-Id: <1380220942-14393-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Eric Anderle <eanderle@umich.edu>

The ability to read the current device list is useful for debugging.

Signed-off-by: Eric Anderle <eanderle@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
[pnfsd: fix dlm device naming]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c            | 44 +++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsctl.c                 |  4 +++-
 include/linux/nfsd/nfs4pnfsdlm.h |  2 ++
 3 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 19002c1..4c2ab87 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -28,6 +28,8 @@
 #include <linux/nfsd/nfs4layoutxdr.h>
 #include <linux/sunrpc/addr.h>
 
+#include "nfsd.h"
+
 #define NFSDDBG_FACILITY                NFSDDBG_FILELAYOUT
 
 /* Just use a linked list. Do not expect more than 32 dlm_device_entries
@@ -45,12 +47,15 @@ struct dlm_device_entry {
 };
 
 static struct dlm_device_entry *
-nfsd4_find_pnfs_dlm_device(char *disk_name)
+_nfsd4_find_pnfs_dlm_device(char *disk_name)
 {
 	struct dlm_device_entry *dlm_pdev;
 
+	dprintk("--> %s  disk name %s\n", __func__, disk_name);
 	spin_lock(&dlm_device_list_lock);
 	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list) {
+		dprintk("%s Look for dlm_pdev %s\n", __func__,
+			dlm_pdev->disk_name);
 		if (!memcmp(dlm_pdev->disk_name, disk_name, strlen(disk_name))) {
 			spin_unlock(&dlm_device_list_lock);
 			return dlm_pdev;
@@ -60,6 +65,39 @@ struct dlm_device_entry {
 	return NULL;
 }
 
+static struct dlm_device_entry *
+nfsd4_find_pnfs_dlm_device(struct super_block *sb) {
+	char dname[BDEVNAME_SIZE];
+
+	bdevname(sb->s_bdev, dname);
+	return _nfsd4_find_pnfs_dlm_device(dname);
+}
+
+ssize_t
+nfsd4_get_pnfs_dlm_device_list(char *buf, ssize_t buflen)
+{
+	char *pos = buf;
+	ssize_t size = 0;
+	struct dlm_device_entry *dlm_pdev;
+	int ret = -EINVAL;
+
+	spin_lock(&dlm_device_list_lock);
+	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list)
+	{
+		int advanced;
+		advanced = snprintf(pos, buflen - size, "%s:%s\n", dlm_pdev->disk_name, dlm_pdev->ds_list);
+		if (advanced >= buflen - size)
+			goto out;
+		size += advanced;
+		pos += advanced;
+	}
+	ret = size;
+
+out:
+	spin_unlock(&dlm_device_list_lock);
+	return ret;
+}
+
 bool nfsd4_validate_pnfs_dlm_device(char *ds_list, int *num_ds)
 {
 	char *start = ds_list;
@@ -140,7 +178,7 @@ bool nfsd4_validate_pnfs_dlm_device(char *ds_list, int *num_ds)
 	dprintk("%s disk_name %s num_ds %d ds_list %s\n", __func__,
 		new->disk_name, new->num_ds, new->ds_list);
 
-	found = nfsd4_find_pnfs_dlm_device(new->disk_name);
+	found = _nfsd4_find_pnfs_dlm_device(new->disk_name);
 	if (found) {
 		/* FIXME: should compare found->ds_list with new->ds_list
 		 * and if it is different, kick off a CB_NOTIFY change
@@ -235,7 +273,7 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
 	/*
 	 * If the DS list has not been established, return -EINVAL
 	 */
-	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb->s_bdev->bd_disk->disk_name);
+	dlm_pdev = nfsd4_find_pnfs_dlm_device(sb);
 	if (!dlm_pdev) {
 		dprintk("%s: DEBUG: disk %s Not Found\n", __func__,
 			sb->s_bdev->bd_disk->disk_name);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7da8584..4fafa2a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1068,7 +1068,9 @@ static ssize_t __write_pnfs_dlm_device(struct file *file, char *buf,
 			return ret;
 
 		ret = nfsd4_set_pnfs_dlm_device(pnfs_dlm_device, len);
-	}
+	} else
+		return nfsd4_get_pnfs_dlm_device_list(buf, SIMPLE_TRANSACTION_LIMIT);
+
 	return ret <= 0 ? ret : strlen(buf);
 }
 
diff --git a/include/linux/nfsd/nfs4pnfsdlm.h b/include/linux/nfsd/nfs4pnfsdlm.h
index 63248aa..a4f3477 100644
--- a/include/linux/nfsd/nfs4pnfsdlm.h
+++ b/include/linux/nfsd/nfs4pnfsdlm.h
@@ -39,6 +39,8 @@
 
 void nfsd4_pnfs_dlm_shutdown(void);
 
+ssize_t nfsd4_get_pnfs_dlm_device_list(char *buf, ssize_t buflen);
+
 #else /* CONFIG_PNFSD */
 
 static inline void nfsd4_pnfs_dlm_shutdown(void)
-- 
1.8.3.1

