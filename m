Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31396 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753644AbaCKVLR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 17:11:17 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs: Don't assume we have a security structure
Date: Tue, 11 Mar 2014 17:11:14 -0400
Message-ID: <1394572274-16474-1-git-send-email-Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the i_security field isn't set then security_dentry_init_security()
won't initialize some of the values used by the security label.  This
causes my client to hit a BUG_ON() while encoding a label of size
-2128927414.

I hit this bug while testing on a client without SELinux installed.

Signed-off-by: Anna Schumaker <anna.schumaker@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b8cd560..994ccc2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -105,6 +105,9 @@ nfs4_label_init_security(struct inode *dir, struct dentry *dentry,
 	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL) == 0)
 		return NULL;
 
+	if (!dir->i_security)
+		return NULL;
+
 	err = security_dentry_init_security(dentry, sattr->ia_mode,
 				&dentry->d_name, (void **)&label->label, &label->len);
 	if (err == 0)
-- 
1.9.0

