Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33949 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbcITQ4r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:47 -0400
Received: by mail-qk0-f194.google.com with SMTP id b204so1439988qkc.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 22/29] NFSv4: Fix a race in nfs_inode_reclaim_delegation()
Date: Tue, 20 Sep 2016 12:56:04 -0400
Message-Id: <1474390571-17106-23-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-22-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we race with a delegreturn before taking the spin lock, we
currently end up dropping the delegation stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 7a0bf3d439ca..2a441ad4e226 100644
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

