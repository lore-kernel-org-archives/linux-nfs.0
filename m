Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7569 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab2IZTZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Sep 2012 15:25:55 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] NFS: Remove bad delegations during open recovery
Date: Wed, 26 Sep 2012 15:25:52 -0400
Message-Id: <1348687553-8461-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I put the client into an open recovery loop by:
	Client: Open file
		read half
	Server: Expire client (echo 0 > /sys/kernel/debug/nfsd/forget_clients)
	Client: Drop vm cache (echo 3 > /proc/sys/vm/drop_caches)
		finish reading file

This causes a loop because the client never updates the nfs4_state after
discovering that the delegation is invalid.  This means it will keep
trying to read using the bad delegation rather than attempting to re-open
the file.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
CC: stable@vger.kernel.org [3.4+]
---
 fs/nfs/nfs4proc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e50326..1d49168 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1774,7 +1774,11 @@ static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 		 * informs us the stateid is unrecognized. */
 		if (status != -NFS4ERR_BAD_STATEID)
 			nfs41_free_stateid(server, stateid);
+		nfs_remove_bad_delegation(state->inode);
 
+		write_seqlock(&state->seqlock);
+		nfs4_stateid_copy(&state->stateid, &state->open_stateid);
+		write_sequnlock(&state->seqlock);
 		clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
 }
-- 
1.7.12.1

