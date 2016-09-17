Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34312 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757077AbcIQFN4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:56 -0400
Received: by mail-io0-f194.google.com with SMTP id y139so2395557ioy.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 21/25] NFSv4: Fix a race in nfs_inode_reclaim_delegation()
Date: Sat, 17 Sep 2016 01:13:29 -0400
Message-Id: <1474089213-104014-22-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-21-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we race with a delegreturn before taking the spin lock, we
currently end up dropping the delegation stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 11d49e1aa41b..45b97cf4bab1 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -186,15 +186,13 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 			rcu_read_unlock();
 			put_rpccred(oldcred);
 			trace_nfs4_reclaim_delegation(inode, res->delegation_type);
-		} else {
-			/* We appear to have raced with a delegation return. */
-			spin_unlock(&delegation->lock);
-			rcu_read_unlock();
-			nfs_inode_set_delegation(inode, cred, res);
+			return;
 		}
-	} else {
-		rcu_read_unlock();
+		/* We appear to have raced with a delegation return. */
+		spin_unlock(&delegation->lock);
 	}
+	rcu_read_unlock();
+	nfs_inode_set_delegation(inode, cred, res);
 }
 
 static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
-- 
2.7.4

