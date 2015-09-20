Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33786 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366AbbITUpQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 16:45:16 -0400
Received: by ykft14 with SMTP id t14so87406320ykf.0
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 13:45:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4: Don't use synchronous delegation recall in exception handling
Date: Sun, 20 Sep 2015 16:45:10 -0400
Message-Id: <1442781911-76248-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1442781911-76248-3-git-send-email-trond.myklebust@primarydata.com>
References: <1442781911-76248-1-git-send-email-trond.myklebust@primarydata.com>
 <1442781911-76248-2-git-send-email-trond.myklebust@primarydata.com>
 <1442781911-76248-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code needs to be able to work from inside an asynchronous context.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 6 ++----
 fs/nfs/nfs4proc.c   | 8 +++-----
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index be806ead7f4d..5166adcfc0fb 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -721,14 +721,12 @@ int nfs_async_inode_return_delegation(struct inode *inode,
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_delegation *delegation;
 
-	filemap_flush(inode->i_mapping);
-
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation == NULL)
 		goto out_enoent;
-
-	if (!clp->cl_mvops->match_stateid(&delegation->stateid, stateid))
+	if (stateid != NULL &&
+	    !clp->cl_mvops->match_stateid(&delegation->stateid, stateid))
 		goto out_enoent;
 	nfs_mark_return_delegation(server, delegation);
 	rcu_read_unlock();
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b6bf246b9b6c..af3168c2b35d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -361,11 +361,9 @@ int nfs4_do_handle_exception(struct nfs_server *server, int errorcode, struct nf
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
-			if (inode && nfs4_have_delegation(inode, FMODE_READ)) {
-				nfs4_inode_return_delegation(inode);
-				exception->retry = 1;
-				return 0;
-			}
+			if (inode && nfs_async_inode_return_delegation(inode,
+						NULL) == 0)
+				goto wait_on_recovery;
 			if (state == NULL)
 				break;
 			ret = nfs4_schedule_stateid_recovery(server, state);
-- 
2.4.3

