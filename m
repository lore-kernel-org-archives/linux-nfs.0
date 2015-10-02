Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35130 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbbJBPr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 11:47:27 -0400
Received: by qkap81 with SMTP id p81so44538330qka.2
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2015 08:47:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: nfs4_opendata_check_deleg needs to handle NFS4_OPEN_CLAIM_DELEG_CUR_FH
Date: Fri,  2 Oct 2015 11:47:24 -0400
Message-Id: <1443800844-7249-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to warn against broken NFSv4.1 servers that try to hand out
delegations in response to NFS4_OPEN_CLAIM_DELEG_CUR_FH.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f93b9cdb4934..56b0958b940f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1458,12 +1458,16 @@ nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
 	if (delegation)
 		delegation_flags = delegation->flags;
 	rcu_read_unlock();
-	if (data->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR) {
+	switch (data->o_arg.claim) {
+	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
+	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
 		pr_err_ratelimited("NFS: Broken NFSv4 server %s is "
 				   "returning a delegation for "
 				   "OPEN(CLAIM_DELEGATE_CUR)\n",
 				   clp->cl_hostname);
-	} else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
+		return;
+	}
+	if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
 		nfs_inode_set_delegation(state->inode,
 					 data->owner->so_cred,
 					 &data->o_res);
-- 
2.4.3

