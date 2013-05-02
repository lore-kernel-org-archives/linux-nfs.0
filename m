Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60571 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760906Ab3EBRTc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 13:19:32 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.x: Fix handling of partially delegated locks
Date: Thu,  2 May 2013 13:19:27 -0400
Message-Id: <1367515168-11158-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a NFS client receives a delegation for a file after it has taken
a lock on that file, we can currently end up in a situation where
we mistakenly skip unlocking that file.

The following patch swaps an erroneous check in nfs4_proc_unlck for
whether or not the file has a delegation to one which checks whether
or not we hold a lock stateid for that file.

Reported-by: Chuck Lever <Chuck.Lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
Tested-by: Chuck Lever <Chuck.Lever@oracle.com>
---
 fs/nfs/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9da4bd5..dc1da2a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4766,9 +4766,9 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	if (status != 0)
 		goto out;
 	/* Is this a delegated lock? */
-	if (test_bit(NFS_DELEGATED_STATE, &state->flags))
-		goto out;
 	lsp = request->fl_u.nfs4_fl.owner;
+	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) == 0)
+		goto out;
 	seqid = nfs_alloc_seqid(&lsp->ls_seqid, GFP_KERNEL);
 	status = -ENOMEM;
 	if (seqid == NULL)
-- 
1.8.1.4

