Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33392 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754148AbcIOQq1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 12:46:27 -0400
Received: by mail-it0-f68.google.com with SMTP id x192so5064055itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 09:46:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v4 19/20] NFSv4: Fix a race in nfs_inode_reclaim_delegation()
Date: Thu, 15 Sep 2016 12:45:59 -0400
Message-Id: <1473957960-10001-20-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473957960-10001-19-git-send-email-trond.myklebust@primarydata.com>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-2-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-3-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-4-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-5-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-6-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-7-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-8-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-9-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-10-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-11-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-12-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-13-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-14-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-15-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-16-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-17-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-18-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-19-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we race with a delegreturn before taking the spin lock, we
currently end up dropping the delegation stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index efd50159ab4a..a17d9a15eb3b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -185,15 +185,13 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
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

