Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:41975 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbaCESaS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 13:30:18 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so1503021iec.9
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 10:30:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/4] NFSv4: Fix the return value of nfs4_select_rw_stateid
Date: Wed,  5 Mar 2014 13:30:09 -0500
Message-Id: <1394044211-22302-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1394044211-22302-2-git-send-email-trond.myklebust@primarydata.com>
References: <1394028452-15956-1-git-send-email-trond.myklebust@primarydata.com>
 <1394044211-22302-1-git-send-email-trond.myklebust@primarydata.com>
 <1394044211-22302-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In commit 5521abfdcf4d6 (NFSv4: Resend the READ/WRITE RPC call
if a stateid change causes an error), we overloaded the return value of
nfs4_select_rw_stateid() to cause it to return -EWOULDBLOCK if an RPC
call is outstanding that would cause the NFSv4 lock or open stateid
to change.
That is all redundant when we actually copy the stateid used in the
read/write RPC call that failed, and check that against the current
stateid. It is doubly so, when we consider that in the NFSv4.1 case,
we also set the stateid's seqid to the special value '0', which means
'match the current valid stateid'.

Reported-by: Andy Adamson <andros@netapp.com>
Link: http://lkml.kernel.org/r/1393954269-3974-1-git-send-email-andros@netapp.com
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e1a47217c05e..0deb32105ccf 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -974,9 +974,6 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
 		nfs4_stateid_copy(dst, &lsp->ls_stateid);
 		ret = 0;
-		smp_rmb();
-		if (!list_empty(&lsp->ls_seqid.list))
-			ret = -EWOULDBLOCK;
 	}
 	spin_unlock(&state->state_lock);
 	nfs4_put_lock_state(lsp);
@@ -984,10 +981,9 @@ out:
 	return ret;
 }
 
-static int nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
 	const nfs4_stateid *src;
-	int ret;
 	int seq;
 
 	do {
@@ -996,12 +992,7 @@ static int nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 		if (test_bit(NFS_OPEN_STATE, &state->flags))
 			src = &state->open_stateid;
 		nfs4_stateid_copy(dst, src);
-		ret = 0;
-		smp_rmb();
-		if (!list_empty(&state->owner->so_seqid.list))
-			ret = -EWOULDBLOCK;
 	} while (read_seqretry(&state->seqlock, seq));
-	return ret;
 }
 
 /*
@@ -1026,7 +1017,8 @@ int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 		 * choose to use.
 		 */
 		goto out;
-	ret = nfs4_copy_open_stateid(dst, state);
+	nfs4_copy_open_stateid(dst, state);
+	ret = 0;
 out:
 	if (nfs_server_capable(state->inode, NFS_CAP_STATEID_NFSV41))
 		dst->seqid = 0;
-- 
1.8.5.3

