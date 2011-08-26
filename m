Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53242 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/15] nfsd4: simplify lock openmode check
Date: Fri, 26 Aug 2011 18:28:30 -0400
Message-Id: <1314397716-18602-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Note that the special handling for the lock stateid case is already done
by nfs4_check_openmode() (as of 02921914170e3b7fea1cd82dac9713685d2de5e2
"nfsd4: fix openmode checking on IO using lock stateid") so we no longer
need these two cases in the caller.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a77d8a5..3c4e7ef 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3455,16 +3455,11 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			if (!nfsd4_has_session(cstate) &&
 			    !same_clid(&clp->cl_clientid, lockclid))
 				return nfserr_bad_stateid;
-			/* stp is the open stateid */
-			status = nfs4_check_openmode(stp, lkflg);
-			if (status)
-				return status;
-		} else {
-			/* stp is the lock stateid */
-			status = nfs4_check_openmode(stp->st_openstp, lkflg);
-			if (status)
-				return status;
-               }
+		}
+		/* stp is the open stateid */
+		status = nfs4_check_openmode(stp, lkflg);
+		if (status)
+			return status;
 	}
 
 	if (nfs4_check_fh(current_fh, stp)) {
-- 
1.7.4.1

