Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e37.co.us.ibm.com ([32.97.110.158]:48127 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363Ab1LIPYA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 10:24:00 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 9 Dec 2011 08:23:59 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB9FNhWB161632
	for <linux-nfs@vger.kernel.org>; Fri, 9 Dec 2011 08:23:45 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB9FNhwe028629
	for <linux-nfs@vger.kernel.org>; Fri, 9 Dec 2011 08:23:43 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v2 6/7] Perform recovery on both inodes for rename.
Date: Fri,  9 Dec 2011 10:23:31 -0500
Message-Id: <1323444212-9855-7-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1323444212-9855-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1323444212-9855-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename is a special case because it passes 2 file handles to the server. If the
server replies with NFS4ERR_FHEXPIRED we can't tell which of the 2 file handles
are expired.

To remedy this, on receiving FHEXPIRED, rename will first call
nfs4_fhexpired_recovery() with the old_dir inode. If this succeeds it will
then call nfs4_fhexpired_recovery() with the new_dir inode. This will bypass
nfs4_handle_exception() on FHEXPIRED errors for renames. Allowing us to run
recovery on each of the inodes.

v2:
- Fixed conditional to include check for mount option

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4804b39..358f5b0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2947,13 +2947,27 @@ out:
 static int nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = old_dir,
+		.dentry = NULL,
+	};
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(old_dir),
-				_nfs4_proc_rename(old_dir, old_name,
-					new_dir, new_name),
-				&exception);
+		err = _nfs4_proc_rename(old_dir, old_name, new_dir, new_name);
+		if (err == -NFS4ERR_FHEXPIRED && NFS_SERVER(old_dir)->flags
+				& NFS_MOUNT_VFHRETRY) {
+			err = nfs4_fhexpired_recovery(NFS_SERVER(old_dir),
+					&exception);
+			if (err == -EAGAIN) {
+				exception.inode = new_dir;
+				err = nfs4_fhexpired_recovery(
+						NFS_SERVER(old_dir),
+						&exception);
+			}
+			return err;
+		}
+		err = nfs4_handle_exception(NFS_SERVER(old_dir), err,
+					&exception);
 	} while (exception.retry);
 	return err;
 }
-- 
1.7.4.4

