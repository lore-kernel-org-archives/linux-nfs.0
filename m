Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60193 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262Ab1INLp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 23/25] nfsd4: fix test_stateid for delegation stateid's
Date: Wed, 14 Sep 2011 07:45:19 -0400
Message-Id: <1316000721-3289-24-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Test_stateid should handle delegation stateid's as well.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 24685a0..30387f3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3261,28 +3261,26 @@ static int is_delegation_stateid(stateid_t *stateid)
 
 __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 {
-	struct nfs4_ol_stateid *stp = NULL;
-	__be32 status = nfserr_stale_stateid;
+	struct nfs4_stid *s;
+	struct nfs4_ol_stateid *ols;
+	__be32 status;
 
 	if (STALE_STATEID(stateid))
-		goto out;
-
-	status = nfserr_expired;
-	stp = find_ol_stateid(stateid);
-	if (!stp)
-		goto out;
-	status = nfserr_bad_stateid;
-	if (stp->st_stateowner->so_is_open_owner
-	    && !openowner(stp->st_stateowner)->oo_confirmed)
-		goto out;
+		return nfserr_stale_stateid;
 
-	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, has_session);
+	s = find_stateid(stateid);
+	if (!s)
+		 return nfserr_stale_stateid;
+	status = check_stateid_generation(stateid, &s->sc_stateid, has_session);
 	if (status)
-		goto out;
-
-	status = nfs_ok;
-out:
-	return status;
+		return status;
+	if (!(s->sc_type & (NFS4_OPEN_STID | NFS4_LOCK_STID)))
+		return nfs_ok;
+	ols = openlockstateid(s);
+	if (ols->st_stateowner->so_is_open_owner
+	    && !openowner(ols->st_stateowner)->oo_confirmed)
+		return nfserr_bad_stateid;
+	return nfs_ok;
 }
 
 /*
-- 
1.7.4.1

