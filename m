Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33953 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932692AbcITQ4u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:50 -0400
Received: by mail-qt0-f194.google.com with SMTP id e5so720453qtb.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 24/29] NFS: Always call nfs_inode_find_state_and_recover() when revoking a delegation
Date: Tue, 20 Sep 2016 12:56:06 -0400
Message-Id: <1474390571-17106-25-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-24-git-send-email-trond.myklebust@primarydata.com>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-2-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-3-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-4-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-5-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-6-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-7-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-8-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-9-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-10-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-11-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-12-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-14-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-15-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-16-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-17-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-18-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-19-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-20-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-21-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-22-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-23-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-24-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't rely on nfs_inode_detach_delegation() succeeding. That can race...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 2a441ad4e226..0073848b5ad3 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -662,18 +662,24 @@ static bool nfs_revoke_delegation(struct inode *inode,
 		const nfs4_stateid *stateid)
 {
 	struct nfs_delegation *delegation;
+	nfs4_stateid tmp;
 	bool ret = false;
 
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation == NULL)
 		goto out;
-	if (stateid && !nfs4_stateid_match(stateid, &delegation->stateid))
+	if (stateid == NULL) {
+		nfs4_stateid_copy(&tmp, &delegation->stateid);
+		stateid = &tmp;
+	} else if (!nfs4_stateid_match(stateid, &delegation->stateid))
 		goto out;
 	nfs_mark_delegation_revoked(NFS_SERVER(inode), delegation);
 	ret = true;
 out:
 	rcu_read_unlock();
+	if (ret)
+		nfs_inode_find_state_and_recover(inode, stateid);
 	return ret;
 }
 
@@ -685,10 +691,8 @@ void nfs_remove_bad_delegation(struct inode *inode,
 	if (!nfs_revoke_delegation(inode, stateid))
 		return;
 	delegation = nfs_inode_detach_delegation(inode);
-	if (delegation) {
-		nfs_inode_find_state_and_recover(inode, &delegation->stateid);
+	if (delegation)
 		nfs_free_delegation(delegation);
-	}
 }
 EXPORT_SYMBOL_GPL(nfs_remove_bad_delegation);
 
-- 
2.7.4

