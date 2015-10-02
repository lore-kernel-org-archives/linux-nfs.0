Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34062 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbbJBQjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 12:39:17 -0400
Received: by igcpb10 with SMTP id pb10so22579004igc.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2015 09:39:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4.1: nfs4_opendata_check_deleg needs to handle NFS4_OPEN_CLAIM_DELEG_CUR_FH
Date: Fri,  2 Oct 2015 12:39:15 -0400
Message-Id: <1443803955-9902-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <201510022302.68uvmDNW%fengguang.wu@intel.com>
References: <201510022302.68uvmDNW%fengguang.wu@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to warn against broken NFSv4.1 servers that try to hand out
delegations in response to NFS4_OPEN_CLAIM_DELEG_CUR_FH.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f93b9cdb4934..12e9808d5df0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1458,12 +1458,18 @@ nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
 	if (delegation)
 		delegation_flags = delegation->flags;
 	rcu_read_unlock();
-	if (data->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR) {
+	switch (data->o_arg.claim) {
+	default:
+		break;
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

