Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33412 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757538AbcIQFN6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:58 -0400
Received: by mail-io0-f193.google.com with SMTP id r145so2386845ior.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 23/25] NFS: Always call nfs_inode_find_state_and_recover() when revoking a delegation
Date: Sat, 17 Sep 2016 01:13:31 -0400
Message-Id: <1474089213-104014-24-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-23-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-16-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-17-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-18-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-19-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-20-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-21-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-22-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-23-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't rely on nfs_inode_detach_delegation() succeeding. That can race...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 45b97cf4bab1..62b2215a30b9 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -653,18 +653,24 @@ static bool nfs_revoke_delegation(struct inode *inode,
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
 
@@ -676,10 +682,8 @@ void nfs_remove_bad_delegation(struct inode *inode,
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

