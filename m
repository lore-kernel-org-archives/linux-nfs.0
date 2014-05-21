Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57699 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711AbaEUQF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2014 12:05:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 2/2] nfsd4: warn on finding lockowner without stateid's
Date: Wed, 21 May 2014 12:05:25 -0400
Message-Id: <1400688325-5345-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1400688325-5345-1-git-send-email-bfields@redhat.com>
References: <1400688325-5345-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The current code assumes a one-to-one lockowner<->lock stateid
correspondance.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 89e4240..9a77a5a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4166,6 +4166,10 @@ static bool same_lockowner_ino(struct nfs4_lockowner *lo, struct inode *inode, c
 
 	if (!same_owner_str(&lo->lo_owner, owner, clid))
 		return false;
+	if (list_empty(&lo->lo_owner.so_stateids)) {
+		WARN_ON_ONCE(1);
+		return false;
+	}
 	lst = list_first_entry(&lo->lo_owner.so_stateids,
 			       struct nfs4_ol_stateid, st_perstateowner);
 	return lst->st_file->fi_inode == inode;
-- 
1.9.0

