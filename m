Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57701 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710AbaEUQF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2014 12:05:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 1/2] nfsd4: remove lockowner when removing lock stateid
Date: Wed, 21 May 2014 12:05:24 -0400
Message-Id: <1400688325-5345-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1400688325-5345-1-git-send-email-bfields@redhat.com>
References: <1400688325-5345-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The nfsv4 state code has always assumed a one-to-one correspondance
between lock stateid's and lockowners even if it appears not to in some
places.

We may actually change that, but for now when FREE_STATEID releases a
lock stateid it also needs to release the parent lockowner.

Symptoms were a subsequent LOCK crashing in find_lockowner_str when it
calls same_lockowner_ino on a lockowner that unexpectedly has an empty
so_stateids list.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 32b699b..89e4240 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3717,9 +3717,16 @@ out:
 static __be32
 nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
-	if (check_for_locks(stp->st_file, lockowner(stp->st_stateowner)))
+	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
+
+	if (check_for_locks(stp->st_file, lo))
 		return nfserr_locks_held;
-	release_lock_stateid(stp);
+	/*
+	 * Currently there's a 1-1 lock stateid<->lockowner
+	 * correspondance, and we have to delete the lockowner when we
+	 * delete the lock stateid:
+	 */
+	unhash_lockowner(lo);
 	return nfs_ok;
 }
 
-- 
1.9.0

