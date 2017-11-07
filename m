Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:36156 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751658AbdKGXBf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Nov 2017 18:01:35 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] nfsd: check for use of the closed special stateid
Date: Tue,  7 Nov 2017 18:01:23 -0500
Message-Id: <20171107230123.62054-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Report on and prevent the use of the closed (invalid)
special stateid by clients.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 755b33284979..2b637137fecd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -73,6 +73,7 @@
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zero_stateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &one_stateid, sizeof(stateid_t)))
 #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
+#define CLOSE_STATEID(stateid)  (!memcmp((stateid), &close_stateid, sizeof(stateid_t)))
 
 /* forward declarations */
 static bool check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner);
@@ -4875,13 +4876,35 @@ static __be32 nfsd4_check_openowner_confirmed(struct nfs4_ol_stateid *ols)
 	return nfs_ok;
 }
 
+static inline __be32
+bad_special_stateid_check(struct nfs4_client *cl, stateid_t *stateid)
+{
+	if (CLOSE_STATEID(stateid)) {
+		char addr_str[INET6_ADDRSTRLEN];
+
+		rpc_ntop((struct sockaddr *)&cl->cl_addr, addr_str,
+			sizeof(addr_str));
+		pr_warn_ratelimited("NFSD: client %s using "
+				"invalid/closed stateid\n",
+				addr_str);
+		return nfserr_bad_stateid;
+	}
+
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+		return nfserr_bad_stateid;
+
+	return nfs_ok;
+}
+
 static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 {
 	struct nfs4_stid *s;
-	__be32 status = nfserr_bad_stateid;
+	__be32 status;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+	status = bad_special_stateid_check(cl, stateid);
+	if (status)
 		return status;
+	status = nfserr_bad_stateid;
 	/* Client debugging aid. */
 	if (!same_clid(&stateid->si_opaque.so_clid, &cl->cl_clientid)) {
 		char addr_str[INET6_ADDRSTRLEN];
@@ -4938,8 +4961,9 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	else if (typemask & NFS4_DELEG_STID)
 		typemask |= NFS4_REVOKED_DELEG_STID;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		return nfserr_bad_stateid;
+	status = bad_special_stateid_check(cstate->clp, stateid);
+	if (status)
+		return status;
 	status = lookup_clientid(&stateid->si_opaque.so_clid, cstate, nn);
 	if (status == nfserr_stale_clientid) {
 		if (cstate->session)
-- 
1.8.3.1

