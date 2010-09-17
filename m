Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:48868 "EHLO
	mx01.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753655Ab0IQM0k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 08:26:40 -0400
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx01.colomx.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o8HCQdC7020041
	for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 08:26:39 -0400
Date: Fri, 17 Sep 2010 08:26:39 -0400 (EDT)
From: Sachin Prabhu <sprabhu@redhat.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <29790688.25.1284726394683.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
In-Reply-To: <1103741.22.1284726314119.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Subject: Should we be aggressively invalidating cache when using -onolock?
Content-Type: multipart/mixed;
	boundary="----=_Part_24_28750611.1284726394680"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

------=_Part_24_28750611.1284726394680
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

We came across an issue where the performance of an application using flocks on RHEL 4(2.6.9 kernel) was far better when compared to the performance of the same application on RHEL 5(2.6.18 kernel). The nfs client behavior when performing flocks on RHEL 4 and RHEL 5 differ. To ensure we had a level playing field, we repeated the tests using the mount option -o nolock. 

The performance on RHEL 5 improved slightly but was still pretty bad when compared to performance on RHEL 4. On closer observation, it was seen that there are a large number of READ requests on RHEL 5 while on RHEL 4 there were hardly any. This difference in behavior was caused by the code which invalidates the cache in the do_setlk() function and results in the RHEL 5 client performing a large number of READ requests.

In this case, the files were only being accessed by one client. This is why the nolock mount option was used. When running such workloads, the aggressive invalidation of the cache is unnecessary. This patch improves the performance in such a scenario.

Is this a good idea?

The patch will need to be respinned to accomodate Suresh Jayaraman's patch introducing '-olocal_lock'.

Sachin Prabhu
------=_Part_24_28750611.1284726394680
Content-Type: text/x-patch; name=bz633834.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=bz633834.patch

nfs: Skip zapping caches when using -o nolock

When using -onolock, it is assumed that the file will not be accessed/modified from multiple sources. In such cases, aggressive invalidation of cache is not required.

Signed-off-by: Sachin S. Prabhu <sprabhu@redhat.com>

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index eb51bd6..bfd9c1a 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -733,24 +733,22 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
 static int do_unlk(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
-	int status;
+
+	/* NOTE: special case
+	 * If we're signalled while cleaning up locks on process exit, we
+	 * still need to complete the unlock.
+	 */
+
+	/* Use local locking if mounted with "-onolock" */
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)
+		return do_vfs_lock(filp, fl);
 
 	/*
 	 * Flush all pending writes before doing anything
 	 * with locks..
 	 */
 	nfs_sync_mapping(filp->f_mapping);
-
-	/* NOTE: special case
-	 * 	If we're signalled while cleaning up locks on process exit, we
-	 * 	still need to complete the unlock.
-	 */
-	/* Use local locking if mounted with "-onolock" */
-	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
-		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
-	else
-		status = do_vfs_lock(filp, fl);
-	return status;
+	return NFS_PROTO(inode)->lock(filp, cmd, fl);
 }
 
 static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
@@ -759,6 +757,15 @@ static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
 	int status;
 
 	/*
+	 * Use local locking and skip cache writeback or invalidation
+	 * if mounted with "-onolock"
+	 */
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) {
+		status = do_vfs_lock(filp, fl);
+		goto out;
+	}
+
+	/*
 	 * Flush all pending writes before doing anything
 	 * with locks..
 	 */
@@ -766,11 +773,7 @@ static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
 	if (status != 0)
 		goto out;
 
-	/* Use local locking if mounted with "-onolock" */
-	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
-		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
-	else
-		status = do_vfs_lock(filp, fl);
+	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
 	if (status < 0)
 		goto out;
 	/*

------=_Part_24_28750611.1284726394680--
