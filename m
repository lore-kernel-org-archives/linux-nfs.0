Return-Path: linux-nfs-owner@vger.kernel.org
Received: from discipline.rit.edu ([129.21.6.207]:48271 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1752790AbdKISlQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 13:41:16 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v2] nfsd: check for use of the closed special stateid
Date: Thu,  9 Nov 2017 13:41:10 -0500
Message-Id: <20171109184110.12695-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prevent the use of the closed (invalid) special stateid by clients.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 v2: don't print warning on use of closed special stateid
 
 fs/nfsd/nfs4state.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5740ad8075c3..9ae75c949290 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -73,6 +73,7 @@
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zero_stateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &one_stateid, sizeof(stateid_t)))
 #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
+#define CLOSE_STATEID(stateid)  (!memcmp((stateid), &close_stateid, sizeof(stateid_t)))
 
 /* forward declarations */
 static bool check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner);
@@ -4885,7 +4886,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	struct nfs4_stid *s;
 	__be32 status = nfserr_bad_stateid;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid) ||
+		CLOSE_STATEID(stateid))
 		return status;
 	/* Client debugging aid. */
 	if (!same_clid(&stateid->si_opaque.so_clid, &cl->cl_clientid)) {
@@ -4943,7 +4945,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	else if (typemask & NFS4_DELEG_STID)
 		typemask |= NFS4_REVOKED_DELEG_STID;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid) ||
+		CLOSE_STATEID(stateid))
 		return nfserr_bad_stateid;
 	status = lookup_clientid(&stateid->si_opaque.so_clid, cstate, nn);
 	if (status == nfserr_stale_clientid) {
-- 
1.8.3.1

