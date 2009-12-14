From: andros@netapp.com
Subject: [PATCH 1/1] nfs41: do not zero seqid portion of stateid on close
Date: Mon, 14 Dec 2009 15:46:16 -0500
Message-ID: <1260823576-3703-1-git-send-email-andros@netapp.com>
Cc: Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59456 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905AbZLNUrK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Dec 2009 15:47:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Remove code left over from a previous minorversion draft.
which specified zeroing seqid portions of stateid's.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d44f107..9d18522 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1854,8 +1854,6 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
 	calldata->arg.stateid = &state->open_stateid;
-	if (nfs4_has_session(server->nfs_client))
-		memset(calldata->arg.stateid->data, 0, 4);    /* clear seqid */
 	/* Serialization for the sequence id */
 	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid);
 	if (calldata->arg.seqid == NULL)
-- 
1.6.0.6

