Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:50696 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698AbaKCOgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2014 09:36:47 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Fixing infinite state recovery loop due to failed delegation return
Date: Mon, 3 Nov 2014 09:36:43 -0500
Message-ID: <1415025403-31914-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we get a bad-stateid-type of error when we send OPEN with delegate_cur
to return currently held delegation, we shouldn't be trying to reclaim locks
associated with that delegation state_id because we don't have an
open_stateid to be used for the LOCK operation. Thus, we should
return an error from the nfs4_open_delegation_recall() in that case.

Furthermore, if an error occurs the delegation code will call
nfs_abort_delegation_return() which sets again the NFS4CLNT_DELEGRETURN
flags in the state and it leads the state manager to into an infinite loop
for trying to reclaim the delegated state.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/delegation.c |    5 +++--
 fs/nfs/nfs4proc.c   |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5853f53..8016d89 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -394,7 +394,7 @@ static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation
 		err = nfs4_wait_clnt_recover(clp);
 	} while (err == 0);
 
-	if (err) {
+	if (err && err != -EIO) {
 		nfs_abort_delegation_return(delegation, clp);
 		goto out;
 	}
@@ -458,7 +458,8 @@ restart:
 			iput(inode);
 			if (!err)
 				goto restart;
-			set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+			if (err != -EIO)
+				set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
 			return err;
 		}
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5aa55c1..6871055 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1655,7 +1655,7 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
 			nfs_inode_find_state_and_recover(state->inode,
 					stateid);
 			nfs4_schedule_stateid_recovery(server, state);
-			return 0;
+			return -EIO;
 		case -NFS4ERR_DELAY:
 		case -NFS4ERR_GRACE:
 			set_bit(NFS_DELEGATED_STATE, &state->flags);
-- 
1.7.1

