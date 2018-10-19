Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt1-f195.google.com ([209.85.160.195]:39200 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727050AbeJSXf6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:35:58 -0400
Received: by mail-qt1-f195.google.com with SMTP id e21-v6so2520742qtp.6
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:23 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 10/13] NFSD check stateids against copy stateids
Date: Fri, 19 Oct 2018 11:29:02 -0400
Message-Id: <20181019152905.32418-11-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

Incoming stateid (used by a READ) could be a saved copy stateid.
On first use make it active and check that the copy has started
within the allowable lease time.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4state.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7764a8b..16359de 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5206,6 +5206,47 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 
 	return 0;
 }
+/*
+ * A READ from an inter server to server COPY will have a
+ * copy stateid. Return the parent nfs4_stid.
+ */
+static __be32 _find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
+		     struct nfs4_cpntf_state **cps)
+{
+	struct nfs4_cpntf_state *state = NULL;
+
+	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
+		return nfserr_bad_stateid;
+	spin_lock(&nn->s2s_cp_lock);
+	state = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
+	spin_unlock(&nn->s2s_cp_lock);
+	if (!state)
+		return nfserr_bad_stateid;
+	*cps = state;
+	return 0;
+}
+
+static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
+			       struct nfs4_stid **stid)
+{
+	__be32 status;
+	struct nfs4_cpntf_state *cps = NULL;
+
+	status = _find_cpntf_state(nn, st, &cps);
+	if (status)
+		return status;
+
+	/* Did the inter server to server copy start in time? */
+	if (cps->cp_active == false && !time_after(cps->cp_timeout, jiffies))
+		return nfserr_partner_no_auth;
+	else
+		cps->cp_active = true;
+
+	*stid = cps->cp_p_stid;
+	refcount_inc(&cps->cp_p_stid->sc_count);
+
+	return nfs_ok;
+}
 
 /*
  * Checks for stateid operations
@@ -5238,6 +5279,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
+	if (status == nfserr_bad_stateid)
+		status = find_cpntf_state(nn, stateid, &s);
 	if (status)
 		return status;
 	status = nfsd4_stid_check_stateid_generation(stateid, s,
-- 
1.8.3.1
