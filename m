Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42014 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752083Ab1KHCMy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Nov 2011 21:12:54 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RNbBF-0005lo-Ag
	for linux-nfs@vger.kernel.org; Mon, 07 Nov 2011 21:12:53 -0500
Date: Mon, 7 Nov 2011 21:12:53 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix lockowner matching
Message-ID: <20111108021253.GA22060@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Lockowners are looked up by file as well as by owner, but we were
forgetting to do a comparison on the file.  This could cause an
incorrect result from lockt.

(Note looking up the inode from the lockowner is pretty awkward here.
The data structures need fixing.)

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 47e94e3..5abced7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3809,16 +3809,29 @@ nevermind:
 		deny->ld_type = NFS4_WRITE_LT;
 }
 
+static bool same_lockowner_ino(struct nfs4_lockowner *lo, struct inode *inode, clientid_t *clid, struct xdr_netobj *owner)
+{
+	struct nfs4_ol_stateid *lst;
+
+	if (!same_owner_str(&lo->lo_owner, owner, clid))
+		return false;
+	lst = list_first_entry(&lo->lo_owner.so_stateids,
+			       struct nfs4_ol_stateid, st_perstateowner);
+	return lst->st_file->fi_inode == inode;
+}
+
 static struct nfs4_lockowner *
 find_lockowner_str(struct inode *inode, clientid_t *clid,
 		struct xdr_netobj *owner)
 {
 	unsigned int hashval = lock_ownerstr_hashval(inode, clid->cl_id, owner);
+	struct nfs4_lockowner *lo;
 	struct nfs4_stateowner *op;
 
 	list_for_each_entry(op, &lock_ownerstr_hashtbl[hashval], so_strhash) {
-		if (same_owner_str(op, owner, clid))
-			return lockowner(op);
+		lo = lockowner(op);
+		if (same_lockowner_ino(lo, inode, clid, owner))
+			return lo;
 	}
 	return NULL;
 }
-- 
1.7.5.4

