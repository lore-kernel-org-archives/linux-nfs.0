Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:48052 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab3JGPp1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Oct 2013 11:45:27 -0400
Received: by mail-wi0-f179.google.com with SMTP id hm2so5073476wib.12
        for <linux-nfs@vger.kernel.org>; Mon, 07 Oct 2013 08:45:26 -0700 (PDT)
Message-ID: <5252D713.7000004@primarydata.com>
Date: Mon, 07 Oct 2013 18:45:23 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Christoph Hellwig <hch@infradead.org>,
        Nadav Shemer <nadav@primarydata.com>
Subject: [PATCH v2 2/4] SQUASHME: pnfsd: nfs4_find_create_layout_stateid
References: <5251140B.4000203@primarydata.com> <1381045468-30670-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <1381045468-30670-1-git-send-email-bhalevy@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split off nfs4_process_layout_stateid functionality for layout get.
layout commit and return never allocate a new layout stateid.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 77 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 61 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2b421e0..84f0283 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -193,23 +193,20 @@ struct sbid_tracker {
 }

 /*
- * We have looked up the nfs4_file corresponding to the current_fh, and
- * confirmed the clientid. Pull the few tests from nfs4_preprocess_stateid_op()
- * that make sense with a layout stateid.
- *
  * If the layout state was found in cache, grab a reference count on it;
- * otherwise, allocate a new layout state if "do_alloc" is set.
+ * otherwise, allocate a new layout state if the client provided a open/
+ * lock/deleg stateid.
  *
  * Called with the state_lock held
- * Returns zero and stateid is updated, or error.
+ * Returns zero and the layout state in *lsp, or error.
  */
 static __be32
-nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
-			    stateid_t *stateid, unsigned char typemask,
-			    struct nfs4_layout_state **lsp)
+nfs4_find_create_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
+				stateid_t *stateid, unsigned char typemask,
+				struct nfs4_layout_state **lsp)
 {
 	struct nfs4_layout_state *ls = NULL;
-	__be32 status = 0;
+	__be32 status;
 	struct nfs4_stid *stid;

 	dprintk("--> %s clp %p fp %p operation stateid=" STATEID_FMT "\n",
@@ -233,13 +230,61 @@ struct sbid_tracker {

 		/* BAD STATEID */
 		if (stateid->si_generation > ls->ls_stid.sc_stateid.si_generation) {
-			dprintk("%s bad stateid 1\n", __func__);
 			status = nfserr_bad_stateid;
 			goto out;
 		}
 		get_layout_state(ls);
 	}
-	status = 0;
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
+ * If the layout state was found in cache, grab a reference count on it.
+ *
+ * Called with the state_lock held
+ * Returns zero and the layout state in *lsp, or error.
+ */
+static __be32
+nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
+			    stateid_t *stateid, unsigned char typemask,
+			    struct nfs4_layout_state **lsp)
+{
+	struct nfs4_layout_state *ls = NULL;
+	__be32 status;
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
+		status = nfserr_bad_stateid;
+		goto out;
+	}
+
+	ls = container_of(stid, struct nfs4_layout_state, ls_stid);
+
+	/* BAD STATEID */
+	if (stateid->si_generation > ls->ls_stid.sc_stateid.si_generation) {
+		dprintk("%s bad stateid 1\n", __func__);
+		status = nfserr_bad_stateid;
+		goto out;
+	}
+	get_layout_state(ls);

 	*lsp = ls;
 	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
@@ -576,10 +621,10 @@ struct super_block *
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


