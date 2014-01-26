Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38264 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbaAZU7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jan 2014 15:59:24 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd4: fix delegation-unlink/rename race
Date: Sun, 26 Jan 2014 15:59:21 -0500
Message-Id: <1390769961-30898-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1390769961-30898-1-git-send-email-bfields@redhat.com>
References: <1390769961-30898-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If a file is unlinked or renamed between the time when we do the local
open and the time when we get the delegation, then we will return to the
client indicating that it holds a delegation even though the file no
longer exists under the name it was open under.

But a client performing an open-by-name, when it is returned a
delegation, must be able to assume that the file is still linked at the
name it was opened under.

So, hold the parent i_mutex for longer to prevent concurrent renames or
unlinks.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 844813a..ef76ba6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -279,11 +279,15 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE && status == 0)
 			open->op_bmval[1] = (FATTR4_WORD1_TIME_ACCESS |
 							FATTR4_WORD1_TIME_MODIFY);
-	} else {
+	} else
+		/*
+		 * Note this may exit with the parent still locked.
+		 * We will hold the lock until nfsd4_open's final
+		 * lookup, to prevent renames or unlinks until we've had
+		 * a chance to an acquire a delegation if appropriate.
+		 */
 		status = nfsd_lookup(rqstp, current_fh,
 				     open->op_fname.data, open->op_fname.len, *resfh);
-		fh_unlock(current_fh);
-	}
 	if (status)
 		goto out;
 	status = nfsd_check_obj_isreg(*resfh);
-- 
1.7.9.5

