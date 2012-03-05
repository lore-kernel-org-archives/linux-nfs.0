Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:48894 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932277Ab2CEU1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 15:27:47 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 15:27:46 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 898BC6E8051
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:27:43 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KQu0j212798
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:27:06 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQu0A006152
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 17:26:56 -0300
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 07/10] Perform recovery on both inodes for rename.
Date: Mon,  5 Mar 2012 15:26:48 -0500
Message-Id: <1330979211-894-8-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename is a special case because it passes 2 file handles to the server. If the
server replies with NFS4ERR_FHEXPIRED we can't tell which of the to file handles
are expired.

To remedy this, on receiving FHEXPIRED, rename will first call
nfs4_fhexpired_recovery() with the old_dir inode. If this succeeds it will then
call nfs4_fhexpired_recovery() with the new_dir inode. This will bypass
nfs4_handle_exception() on FHEXPIRED errors for renames. Allow us to run
recovery on each of the inodes.

v2:
- Fixed conditional to include check for mount option

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9edf9ae..a593eef 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3058,13 +3058,27 @@ out:
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

