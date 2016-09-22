Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34241 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965808AbcIVRkB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:40:01 -0400
Received: by mail-it0-f67.google.com with SMTP id 186so5344028itf.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:40:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 24/31] NFS: Always call nfs_inode_find_state_and_recover() when revoking a delegation
Date: Thu, 22 Sep 2016 13:39:14 -0400
Message-Id: <1474565961-21303-25-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't rely on nfs_inode_detach_delegation() succeeding. That can race...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 094e0efe6a82..dff600ae0d74 100644
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

