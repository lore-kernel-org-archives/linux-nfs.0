Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50133 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935446Ab3DIX6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/10] nfsd4: clean up validate_stateid
Date: Tue,  9 Apr 2013 19:58:14 -0400
Message-Id: <1365551896-6936-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The logic here is better expressed with a switch statement.

While we're here, CLOSED stateids (or stateids of an unkown type--which
would indicate a server bug) should probably return nfserr_bad_stateid,
though this behavior shouldn't affect any non-buggy client.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 67017fc..add9721 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3456,13 +3456,22 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
 	if (status)
 		return status;
-	if (!(s->sc_type & (NFS4_OPEN_STID | NFS4_LOCK_STID)))
+	switch (s->sc_type) {
+	case NFS4_DELEG_STID:
+		return nfs_ok;
+	case NFS4_OPEN_STID:
+	case NFS4_LOCK_STID:
+		ols = openlockstateid(s);
+		if (ols->st_stateowner->so_is_open_owner
+	    			&& !(openowner(ols->st_stateowner)->oo_flags
+						& NFS4_OO_CONFIRMED))
+			return nfserr_bad_stateid;
 		return nfs_ok;
-	ols = openlockstateid(s);
-	if (ols->st_stateowner->so_is_open_owner
-	    && !(openowner(ols->st_stateowner)->oo_flags & NFS4_OO_CONFIRMED))
+	default:
+		printk("unknown stateid type %x\n", s->sc_type);
+	case NFS4_CLOSED_STID:
 		return nfserr_bad_stateid;
-	return nfs_ok;
+	}
 }
 
 static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
-- 
1.7.9.5

