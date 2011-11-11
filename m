Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e5.ny.us.ibm.com ([32.97.182.145]:42697 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032Ab1KKXGP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Nov 2011 18:06:15 -0500
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 18:06:14 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABN5ole3526844
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 18:05:50 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABN5n6b022315
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 21:05:50 -0200
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC 6/7] Perform recovery on both inodes for rename.
Date: Fri, 11 Nov 2011 18:04:31 -0500
Message-Id: <1321052673-22171-7-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
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

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 50bb823..ebc5ee9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2907,13 +2907,26 @@ out:
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
+		if (err == -NFS4ERR_FHEXPIRED) {
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

