Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:33071 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbcELJQn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 May 2016 05:16:43 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 031B1280373
	for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 11:16:41 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id E63401527
	for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 11:16:40 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2] nfs4: client: do not send empty SETATTR after OPEN_CREATE
Date: Thu, 12 May 2016 11:16:38 +0200
Message-Id: <1463044598-5220-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OPEN_CREATE with EXCLUSIVE4_1 sends initial file permission.
Ignoring  fact, that server have indicated that file mod is set, client
will send yet another SETATTR request, but, as mode is already set,
new SETATTR will be empty. This is not a problem, nevertheless
an extra roundtrip and slow open on high latency networks.

This change is aims to skip extra setattr after open  if there are
no attributes to be set.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/nfs4proc.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 327b8c3..39f4736 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -74,6 +74,17 @@
 #define NFS4_POLL_RETRY_MIN	(HZ/10)
 #define NFS4_POLL_RETRY_MAX	(15*HZ)
 
+/* file attributes which can be mapped to nfs attributes */
+#define NFS4_VALID_ATTRS (ATTR_MODE \
+	| ATTR_UID \
+	| ATTR_GID \
+	| ATTR_SIZE \
+	| ATTR_ATIME \
+	| ATTR_MTIME \
+	| ATTR_CTIME \
+	| ATTR_ATIME_SET \
+	| ATTR_MTIME_SET)
+
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
@@ -2558,15 +2569,20 @@ static int _nfs4_do_open(struct inode *dir,
 	if ((opendata->o_arg.open_flags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL) &&
 	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
 		nfs4_exclusive_attrset(opendata, sattr, &label);
-
-		nfs_fattr_init(opendata->o_res.f_attr);
-		status = nfs4_do_setattr(state->inode, cred,
-				opendata->o_res.f_attr, sattr,
-				state, label, olabel);
-		if (status == 0) {
-			nfs_setattr_update_inode(state->inode, sattr,
-					opendata->o_res.f_attr);
-			nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
+		/*
+		 * send create attributes which was not set by open
+		 * with an extra setattr.
+		 */
+		if (sattr->ia_valid & NFS4_VALID_ATTRS) {
+			nfs_fattr_init(opendata->o_res.f_attr);
+			status = nfs4_do_setattr(state->inode, cred,
+					opendata->o_res.f_attr, sattr,
+					state, label, olabel);
+			if (status == 0) {
+				nfs_setattr_update_inode(state->inode, sattr,
+						opendata->o_res.f_attr);
+				nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
+			}
 		}
 	}
 	if (opened && opendata->file_created)
-- 
2.5.5

