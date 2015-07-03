Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36740 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbbGCLiq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 07:38:46 -0400
Received: by pdcu2 with SMTP id u2so63709239pdc.3
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 04:38:46 -0700 (PDT)
Message-ID: <5596743C.7080609@gmail.com>
Date: Fri, 03 Jul 2015 19:38:36 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 4/5] nfsd: Check stateid generation in nfsd4_lookup_stateid()
References: <559672B7.4010802@gmail.com>
In-Reply-To: <559672B7.4010802@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c |  2 --
 fs/nfsd/nfs4state.c   | 30 ++++++++++++++----------------
 2 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 367a65a..ef63244 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -264,8 +264,6 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 		ls = container_of(stid, struct nfs4_layout_stateid, ls_stid);
 
 		status = nfserr_bad_stateid;
-		if (stateid->si_generation > stid->sc_stateid.si_generation)
-			goto out_put_stid;
 		if (layout_type != ls->ls_layout_type)
 			goto out_put_stid;
 	}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61dfb33..53248cd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4555,6 +4555,7 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn)
 {
+	struct nfs4_stid *stid;
 	__be32 status;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
@@ -4567,10 +4568,18 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	}
 	if (status)
 		return status;
-	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
-	if (!*s)
+	stid = find_stateid_by_type(cstate->clp, stateid, typemask);
+	if (!stid)
 		return nfserr_bad_stateid;
-	return nfs_ok;
+
+	status = check_stateid_generation(stateid, &stid->sc_stateid,
+			nfsd4_has_session(cstate));
+	if (status)
+		nfs4_put_stid(stid);
+	else
+		*s = stid;
+
+	return status;
 }
 
 static struct file *
@@ -4673,10 +4682,6 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 				&s, nn);
 	if (status)
 		return status;
-	status = check_stateid_generation(stateid, &s->sc_stateid,
-			nfsd4_has_session(cstate));
-	if (status)
-		goto out;
 
 	switch (s->sc_type) {
 	case NFS4_DELEG_STID:
@@ -4694,7 +4699,6 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 done:
 	if (!status && filpp)
 		status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
-out:
 	if (s)
 		nfs4_put_stid(s);
 	return status;
@@ -5021,7 +5025,6 @@ __be32
 nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_delegreturn *dr)
 {
-	struct nfs4_delegation *dp;
 	stateid_t *stateid = &dr->dr_stateid;
 	struct nfs4_stid *s;
 	__be32 status;
@@ -5033,14 +5036,9 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfsd4_lookup_stateid(cstate, stateid, NFS4_DELEG_STID, &s, nn);
 	if (status)
 		goto out;
-	dp = delegstateid(s);
-	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
-	if (status)
-		goto put_stateid;
 
-	destroy_delegation(dp);
-put_stateid:
-	nfs4_put_stid(&dp->dl_stid);
+	destroy_delegation(delegstateid(s));
+	nfs4_put_stid(s);
 out:
 	return status;
 }
-- 
2.4.3

