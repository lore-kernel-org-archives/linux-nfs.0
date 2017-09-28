Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19225 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752217AbdI1RaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:06 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 4/8] NFSD check stateids against copy stateids
Date: Thu, 28 Sep 2017 13:29:58 -0400
Message-ID: <20170928173002.50818-5-kolga@netapp.com>
In-Reply-To: <20170928173002.50818-1-kolga@netapp.com>
References: <20170928173002.50818-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Incoming stateid (used by a READ) could be a saved copy stateid.
On first use make it active and check that the copy has started
within the allowable lease time.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4state.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9932d50..e28447d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -770,6 +770,31 @@ __be32 find_cp_state(struct nfsd_net *nn, stateid_t *st,
 	*cps = state;
 	return 0;
 }
+/*
+ * A READ from an inter server to server COPY will have a
+ * copy stateid. Return the parent nfs4_stid.
+ */
+static __be32 find_cp_state_parent(struct nfsd_net *nn, stateid_t *st,
+				   struct nfs4_stid **stid)
+{
+	__be32 status;
+	struct nfs4_cp_state *cps = NULL;
+
+	status = find_cp_state(nn, st, &cps);
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
+	atomic_inc(&cps->cp_p_stid->sc_count);
+
+	return nfs_ok;
+}
 
 /*
  * When we recall a delegation, we should be careful not to hand it
@@ -5054,6 +5079,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
+	if (status == nfserr_bad_stateid)
+		status = find_cp_state_parent(nn, stateid, &s);
 	if (status)
 		return status;
 	status = check_stateid_generation(stateid, &s->sc_stateid,
-- 
1.8.3.1

