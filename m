Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:36644 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1755992AbdKCSGf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 14:06:35 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org,
        trond.myklebust@primarydata.com
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v3] nfsd: deal with revoked delegations appropriately
Date: Fri,  3 Nov 2017 14:06:31 -0400
Message-Id: <20171103180631.76071-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a delegation has been revoked by the server, operations using that
delegation should error out with NFS4ERR_DELEG_REVOKED in the >4.1
case, and NFS4ERR_BAD_STATEID otherwise.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 v2: deconflicting with Trond's OPEN/CLOSE locking work
 v3: don't return NFS4_OK on DELEGRETURN with revoked delegation
 
 fs/nfsd/nfs4state.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81aa63b..d386d569edbc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3966,7 +3966,8 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 {
 	struct nfs4_stid *ret;
 
-	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
+	ret = find_stateid_by_type(cl, s,
+				NFS4_DELEG_STID|NFS4_REVOKED_DELEG_STID);
 	if (!ret)
 		return NULL;
 	return delegstateid(ret);
@@ -3989,6 +3990,12 @@ static bool nfsd4_is_deleg_cur(struct nfsd4_open *open)
 	deleg = find_deleg_stateid(cl, &open->op_delegate_stateid);
 	if (deleg == NULL)
 		goto out;
+	if (deleg->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID) {
+		nfs4_put_stid(&deleg->dl_stid);
+		if (cl->cl_minorversion)
+			status = nfserr_deleg_revoked;
+		goto out;
+	}
 	flags = share_access_to_flags(open->op_share_access);
 	status = nfs4_check_delegmode(deleg, flags);
 	if (status) {
@@ -4858,6 +4865,16 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 		     struct nfs4_stid **s, struct nfsd_net *nn)
 {
 	__be32 status;
+	bool return_revoked = false;
+
+	/*
+	 *  only return revoked delegations if explicitly asked.
+	 *  otherwise we report revoked or bad_stateid status.
+	 */
+	if (typemask & NFS4_REVOKED_DELEG_STID)
+		return_revoked = true;
+	else if (typemask & NFS4_DELEG_STID)
+		typemask |= NFS4_REVOKED_DELEG_STID;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
@@ -4872,6 +4889,12 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
+	if (((*s)->sc_type == NFS4_REVOKED_DELEG_STID) && !return_revoked) {
+		nfs4_put_stid(*s);
+		if (cstate->minorversion)
+			return nfserr_deleg_revoked;
+		return nfserr_bad_stateid;
+	}
 	return nfs_ok;
 }
 
-- 
1.8.3.1

