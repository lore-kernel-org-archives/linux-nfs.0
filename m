Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35912 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964897AbcIVRj7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:59 -0400
Received: by mail-io0-f196.google.com with SMTP id z135so5611448ioe.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 22/31] NFSv4: Fix a race in nfs_inode_reclaim_delegation()
Date: Thu, 22 Sep 2016 13:39:12 -0400
Message-Id: <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we race with a delegreturn before taking the spin lock, we
currently end up dropping the delegation stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5de4cfb2ab07..094e0efe6a82 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -195,15 +195,13 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
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

