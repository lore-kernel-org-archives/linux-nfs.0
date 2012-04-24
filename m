Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2751 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757156Ab2DXR4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 13:56:19 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 2/8] NFS: Handle exceptions coming out of nfs4_proc_fs_locations()
Date: Tue, 24 Apr 2012 13:56:06 -0400
Message-Id: <1335290172-1532-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335290172-1532-1-git-send-email-bjschuma@netapp.com>
References: <1335290172-1532-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

We don't want to return -NFS4ERR_WRONGSEC to the VFS because it could
cause the kernel to oops.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 60d5f4c..0de2614 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4919,7 +4919,7 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 	fattr->nlink = 2;
 }
 
-int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
+static int _nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
@@ -4959,6 +4959,19 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	return status;
 }
 
+int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
+		struct nfs4_fs_locations *fs_locations, struct page *page)
+{
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		err = nfs4_handle_exception(NFS_SERVER(dir),
+				_nfs4_proc_fs_locations(dir, name, fs_locations, page),
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
 static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
 {
 	int status;
-- 
1.7.10

