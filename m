From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: Ensure nfsv4 calls the underlying filesystem on LOCKT
Date: Thu,  1 Jan 2009 19:36:50 -0500
Message-ID: <1230856611-32574-2-git-send-email-bfields@citi.umich.edu>
References: <1230856611-32574-1-git-send-email-bfields@citi.umich.edu>
Cc: Marc Eshel <eshel@almaden.ibm.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbZABAgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jan 2009 19:36:54 -0500
In-Reply-To: <1230856611-32574-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

We need to add the following so vfs_test_lock() will call the underling
filesystem.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6910374..83f8e21 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2835,13 +2835,16 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_transform_lock_offset(&file_lock);
 
-	/* vfs_test_lock uses the struct file _only_ to resolve the inode.
+	/*
+	 * vfs_test_lock uses the struct file _only_ to resolve the inode.
 	 * since LOCKT doesn't require an OPEN, and therefore a struct
 	 * file may not exist, pass vfs_test_lock a struct file with
-	 * only the dentry:inode set.
+	 * only the dentry and i_fop (in case the filesystem defines
+	 * its own lock method) set.
 	 */
 	memset(&file, 0, sizeof (struct file));
 	file.f_path.dentry = cstate->current_fh.fh_dentry;
+	file.f_op = inode->i_fop;
 
 	status = nfs_ok;
 	error = vfs_test_lock(&file, &file_lock);
-- 
1.5.5.rc1

