Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f47.google.com ([74.125.83.47]:40520 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab3JFHoc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 03:44:32 -0400
Received: by mail-ee0-f47.google.com with SMTP id d49so2551108eek.6
        for <linux-nfs@vger.kernel.org>; Sun, 06 Oct 2013 00:44:31 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] SQUASHME: pnfsd: nfs4_find_create_layout_stateid
Date: Sun,  6 Oct 2013 10:44:28 +0300
Message-Id: <1381045468-30670-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <5251140B.4000203@primarydata.com>
References: <5251140B.4000203@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split off nfs4_process_layout_stateid functionality for layout get.
layout commit and return never allocate a new layout stateid.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 58 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index a9e535f..c00eb03 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -199,6 +199,60 @@ struct sbid_tracker {
 }
 
 /*
+ * If the layout state was found in cache, grab a reference count on it;
+ * otherwise, allocate a new layout state if "do_alloc" is set.
+ *
+ * Called with the state_lock held
+ * Returns zero and the layout state in *lsp, or error.
+ */
+static __be32
+nfs4_find_create_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
+				stateid_t *stateid, unsigned char typemask,
+				struct nfs4_layout_state **lsp)
+{
+	struct nfs4_layout_state *ls = NULL;
+	__be32 status = 0;
+	struct nfs4_stid *stid;
+
+	dprintk("--> %s clp %p fp %p operation stateid=" STATEID_FMT "\n",
+		__func__, clp, fp, STATEID_VAL(stateid));
+
+	nfs4_assert_state_locked();
+	status = nfsd4_lookup_stateid(stateid, typemask, &stid, true,
+				      net_generic(clp->net, nfsd_net_id));
+	if (status)
+		goto out;
+
+	/* Is this the first use of this layout ? */
+	if (stid->sc_type != NFS4_LAYOUT_STID) {
+		ls = alloc_init_layout_state(clp, fp, stateid);
+		if (!ls) {
+			status = nfserr_jukebox;
+			goto out;
+		}
+	} else {
+		ls = container_of(stid, struct nfs4_layout_state, ls_stid);
+
+		/* BAD STATEID */
+		if (stateid->si_generation > ls->ls_stid.sc_stateid.si_generation) {
+			status = nfserr_bad_stateid;
+			goto out;
+		}
+		get_layout_state(ls);
+	}
+	status = 0;
+
+	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
+		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));
+
+	*lsp = ls;
+out:
+	dprintk("<-- %s status %d\n", __func__, htonl(status));
+
+	return status;
+}
+
+/*
  * We have looked up the nfs4_file corresponding to the current_fh, and
  * confirmed the clientid. Pull the few tests from nfs4_preprocess_stateid_op()
  * that make sense with a layout stateid.
@@ -776,10 +830,10 @@ struct super_block *
 	}
 
 	/* Check decoded layout stateid */
-	nfserr = nfs4_process_layout_stateid(clp, fp, &lgp->lg_sid,
-					     (NFS4_OPEN_STID | NFS4_LOCK_STID |
-					      NFS4_DELEG_STID | NFS4_LAYOUT_STID),
-					     &ls);
+	nfserr = nfs4_find_create_layout_stateid(clp, fp, &lgp->lg_sid,
+						 (NFS4_OPEN_STID | NFS4_LOCK_STID |
+						  NFS4_DELEG_STID | NFS4_LAYOUT_STID),
+						 &ls);
 	if (nfserr)
 		goto out_unlock;
 
-- 
1.8.3.1

