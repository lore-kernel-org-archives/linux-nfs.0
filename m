Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:60476 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaGCFFo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 01:05:44 -0400
Received: by mail-pd0-f169.google.com with SMTP id g10so13248746pdj.0
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 22:05:43 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 1/3] nfs4: add nfs4_check_delegation
Date: Thu,  3 Jul 2014 13:05:00 +0800
Message-Id: <1404363902-12943-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1404363902-12943-1-git-send-email-tao.peng@primarydata.com>
References: <1404363902-12943-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/delegation.c | 34 +++++++++++++++++++++++++---------
 fs/nfs/delegation.h |  1 +
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5d8ccec..5853f53 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -41,14 +41,8 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
 	set_bit(NFS_DELEGATION_REFERENCED, &delegation->flags);
 }
 
-/**
- * nfs_have_delegation - check if inode has a delegation
- * @inode: inode to check
- * @flags: delegation types to check for
- *
- * Returns one if inode has the indicated delegation, otherwise zero.
- */
-int nfs4_have_delegation(struct inode *inode, fmode_t flags)
+static int
+nfs4_do_check_delegation(struct inode *inode, fmode_t flags, bool mark)
 {
 	struct nfs_delegation *delegation;
 	int ret = 0;
@@ -58,12 +52,34 @@ int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation != NULL && (delegation->type & flags) == flags &&
 	    !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags)) {
-		nfs_mark_delegation_referenced(delegation);
+		if (mark)
+			nfs_mark_delegation_referenced(delegation);
 		ret = 1;
 	}
 	rcu_read_unlock();
 	return ret;
 }
+/**
+ * nfs_have_delegation - check if inode has a delegation, mark it
+ * NFS_DELEGATION_REFERENCED if there is one.
+ * @inode: inode to check
+ * @flags: delegation types to check for
+ *
+ * Returns one if inode has the indicated delegation, otherwise zero.
+ */
+int nfs4_have_delegation(struct inode *inode, fmode_t flags)
+{
+	return nfs4_do_check_delegation(inode, flags, true);
+}
+
+/*
+ * nfs4_check_delegation - check if inode has a delegation, do not mark
+ * NFS_DELEGATION_REFERENCED if it has one.
+ */
+int nfs4_check_delegation(struct inode *inode, fmode_t flags)
+{
+	return nfs4_do_check_delegation(inode, flags, false);
+}
 
 static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
 {
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 9a79c7a..5c1cce3 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -59,6 +59,7 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
+int nfs4_check_delegation(struct inode *inode, fmode_t flags);
 
 #endif
 
-- 
1.9.1

