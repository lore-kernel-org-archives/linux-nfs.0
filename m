Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60162 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/25] nfsd4: simplify check_open logic
Date: Wed, 14 Sep 2011 07:45:04 -0400
Message-Id: <1316000721-3289-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Sometimes the single-exit style is good, sometimes it's unnecessarily
convoluted....

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8edc9ad..8694e60 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2573,7 +2573,6 @@ static __be32
 nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_stateid **stpp)
 {
 	struct nfs4_stateid *local;
-	__be32 status = nfserr_share_denied;
 	struct nfs4_stateowner *sop = open->op_stateowner;
 
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
@@ -2585,11 +2584,9 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_state
 			*stpp = local;
 		/* check for conflicting share reservations */
 		if (!test_share(local, open))
-			goto out;
+			return nfserr_share_denied;
 	}
-	status = 0;
-out:
-	return status;
+	return nfs_ok;
 }
 
 static inline struct nfs4_stateid *
-- 
1.7.4.1

