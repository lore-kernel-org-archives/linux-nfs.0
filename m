Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36828 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964779AbcIVRja (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:30 -0400
Received: by mail-io0-f194.google.com with SMTP id z135so5610846ioe.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:30 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 04/31] NFSv4: nfs4_copy_delegation_stateid() must fail if the delegation is invalid
Date: Thu, 22 Sep 2016 13:38:54 -0400
Message-Id: <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must not allow the use of delegations that have been revoked or are
being returned.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Fixes: 869f9dfa4d6d ("NFSv4: Fix races between nfs_remove_bad_delegation()...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v3.19+
---
 fs/nfs/delegation.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 86d2c748140b..b9c65421ed81 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -41,6 +41,17 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
 	set_bit(NFS_DELEGATION_REFERENCED, &delegation->flags);
 }
 
+static bool
+nfs4_is_valid_delegation(const struct nfs_delegation *delegation,
+		fmode_t flags)
+{
+	if (delegation != NULL && (delegation->type & flags) == flags &&
+	    !test_bit(NFS_DELEGATION_REVOKED, &delegation->flags) &&
+	    !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
+		return true;
+	return false;
+}
+
 static int
 nfs4_do_check_delegation(struct inode *inode, fmode_t flags, bool mark)
 {
@@ -50,9 +61,7 @@ nfs4_do_check_delegation(struct inode *inode, fmode_t flags, bool mark)
 	flags &= FMODE_READ|FMODE_WRITE;
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation != NULL && (delegation->type & flags) == flags &&
-	    !test_bit(NFS_DELEGATION_REVOKED, &delegation->flags) &&
-	    !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags)) {
+	if (nfs4_is_valid_delegation(delegation, flags)) {
 		if (mark)
 			nfs_mark_delegation_referenced(delegation);
 		ret = 1;
@@ -894,7 +903,7 @@ bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags,
 	flags &= FMODE_READ|FMODE_WRITE;
 	rcu_read_lock();
 	delegation = rcu_dereference(nfsi->delegation);
-	ret = (delegation != NULL && (delegation->type & flags) == flags);
+	ret = nfs4_is_valid_delegation(delegation, flags);
 	if (ret) {
 		nfs4_stateid_copy(dst, &delegation->stateid);
 		nfs_mark_delegation_referenced(delegation);
-- 
2.7.4

