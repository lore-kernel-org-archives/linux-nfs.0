Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52326 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751845AbdIVUPy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Sep 2017 16:15:54 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: override uid and gid for exclusive creates in nfs3_proc_create
Date: Fri, 22 Sep 2017 16:15:51 -0400
Message-Id: <20170922201551.15222-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC 1813 section 3.3.8 states

      Once the client has performed a successful exclusive
      create, it must issue a SETATTR to set the correct file
      attributes.  Until it does so, it should not rely upon any
      of the file attributes, since the server implementation
      may need to overload file metadata to store the verifier.

HP-UX expects the client to send the uid and gid in the post-create
setattr for exclusive creates.  Customers are sometimes seeing bogus
values because the Linux NFS client is only updating the atime and
mtime.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/nfs3proc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d1e87ec..4d77d2d 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -370,6 +370,13 @@ nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	if (data->arg.create.createmode == NFS3_CREATE_EXCLUSIVE) {
 		dprintk("NFS call  setattr (post-create)\n");
 
+		sattr->ia_uid = current_fsuid();
+		sattr->ia_valid |= ATTR_UID;
+		if (dir->i_mode & S_ISGID)
+			sattr->ia_gid = dir->i_gid;
+		else
+			sattr->ia_gid = current_fsgid();
+		sattr->ia_valid |= ATTR_GID;
 		if (!(sattr->ia_valid & ATTR_ATIME_SET))
 			sattr->ia_valid |= ATTR_ATIME;
 		if (!(sattr->ia_valid & ATTR_MTIME_SET))
-- 
2.9.5

