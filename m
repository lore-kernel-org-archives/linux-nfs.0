Received: from mail-oi1-f171.google.com (mail-oi1-f171.google.com [209.85.167.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04AA7265623
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653813; cv=none; b=eMwqUdRISDmpPl8cujVNyYbmsfFk9EIfNvew7QwOdqxgdz1wvauJLb9pCmwR0ivg7xJ8h0ytEnpx7qE0PUT8sPYpQq/qNefGD3ZxN+sgOmFxim3QRKrrig20N+uBriH+Et8z5SXTx5h8TZno94TA6KKetCRO5lDkzjwPD2znCeI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653813; c=relaxed/simple;
	bh=8BmWmt1voUyorcq1+OI/9KSOTlz+f4FL1FDvS9rxalU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QYhlMflNtBalUV64Dbs4WlD9199PYm+ZXsELe3NTj2m/ppma5eEDJEZln6i40oU95WZj8JeXEDMeBLMJ6v4NFtvjcj0HtzMJbwPLck9JLTLh2KYLZ+hIzJCBjbqn+q2w/uYe2bWLH70wTsJZVKf2YFcSRExz3d4NrAQWPwCC94Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=NWvre70d; arc=none smtp.client-ip=209.85.167.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="NWvre70d"
Received: by mail-oi1-f171.google.com with SMTP id 5614622812f47-4b21f09ea42so131293b6e.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653811; x=1787258611; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=oT3qx2Bi9NgtiB0fiTni00PWo/G+2khkFIosLPViZK4=;
        b=NWvre70dophHC15sE2No8zttltSQWd7C8LyRVES/wEvz3Pl3smidI0c/VN4x6MI8Wa
         v1x8i+VZ0iTSwsTvm6La8Ue40sTOxbinECUNeiG8jCN+0S9xNOwnQYzE6wmPMPKQvhU1
         iZbaaVhD8WDgmk/zX/V2MStcxPrA2SGRt8sYx6qU75gLIeLy/mFWLbU7YdriwUTBUn+P
         Sp5euBG2Wfr+LjGA1xojw9eo9pgK6N2MQzDTU4g+deSse+nvdq+JnVWQguIL/gaF4zcO
         k3C7vfJmhECa5mzrXk4wdlpPk0UVkhuuV4JcIojtaOWV/ui5lt3jaX+bIGb8pjVbKQ4k
         e0Uw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653811; x=1787258611;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=oT3qx2Bi9NgtiB0fiTni00PWo/G+2khkFIosLPViZK4=;
        b=PbIyi5EjYXEqwGNbZcLriJtHTQN04hKuonqMzaV17e8zejJaplPJLbvFu4WKr1anm9
         a6lMHkck+ReilnZcAP2OODz8+fiFv0heb8bXbvM8mqdtx8fj600x39/o6ElRCgqZzlTN
         FdBNTiGsJiA/gqJM8n5at5yxBAis/8KliKXQzIhPoeJV2gzpOj8ku89T3QGQ7IXgfZ05
         ZzvYd6XDnDJs83msouBBSt62Q1GWNr6NH4sGz75HEdKTcn721+j/CuZGUgJbASz/xFxk
         vpFcmQ9b1uUrtDwV9qftwVrtz2kkoeIQoZ1NICeTyeblUoFcOc0/Aw47eWHuZ6519Pk8
         vuxw==
X-Gm-Message-State: AOJu0YxbxeTK7fPswnNxHzV9F1Tk30kc0nkuTBEnOS8YkE3bYIqsMx3+
	PfkgNKLaleIsUEepoSmBjp7fXB4wJMC6AAb/2H/rv4fh7JCyDSyt2ysmB5olKTLskxs=
X-Gm-Gg: AR+sD13oJA8GnHGPoOi/vXgE+5S7CwukSgdb0ThrJftrb7ez0PBTs5D/Z5D2p5Ujfem
	RMunsnc5VQ71YAl0YhEgAFi3z65ExXtv/5dzQarxzvVw5rq28p+kn72goYpAkkHY1ReAbXkZuRN
	S8IXckBcQRSD32uuFh/SgM92yQMnktMv+T2p69E7dbXUabmkp7PGwHLwzaoJ2qlRh35p2iIfxfd
	B5lPHxsYOcqtrPhgvB/YsgN4cgl5lkaiXENOx0aU17+AkU/qNRCsZYnVJdaLFusui1UgcPaG/s0
	qJxb4i0SIXT8C1ziIsbFelE1jXaG/Jx1PQ0fXnkadBR9Nv5ZRbICo6NfDtyJE171MaxfGt2k1pY
	DfC74rbx3MOAOcuBsW/889B+gTyTIhXxPGkcTAThJHhduGBbR074X+P/AB1MV7HyJLN8xPUfa0N
	XNEiFquJlMQQQl+TO75oZL+IMs77HRLGyQL7QWsexMdNd28jhdICHIS4jNQWzevXvdMBMT6T3u3
	DEApP5WWvaqJeU502D3FSLZ
X-Received: by 2002:a05:6808:c143:b0:49a:a627:14ee with SMTP id 5614622812f47-4b241df4157mr718802b6e.15.1786653810829;
        Thu, 13 Aug 2026 13:43:30 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:30 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 08/21] NFSv4/flexfiles: Make the pinned device node pointer RCU-managed
Date: Thu, 13 Aug 2026 16:43:04 -0400
Message-ID: <41b1948ff52f8d334cd0ac2dce3dfc8855e8fb73.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Annotate mirror->dss[dss_id].mirror_ds as __rcu and convert the
remaining readers, completing the preparation for re-pointing the pinned
node while I/O is in flight:

 - ff_layout_get_mirror_ds() takes its reference under rcu_read_lock()
   with atomic_inc_not_zero(), retrying if it races a reset; the resolve
   path takes the caller's reference before publishing the node so a
   concurrent reset cannot free it under the caller.  This is the shape
   of get_huge_zero_folio(): try-ref, else create and install with
   cmpxchg (retrying on a lost race) holding one reference for the
   pointer and one for the caller, torn down elsewhere by xchg + put.
 - The availability scans hold rcu_read_lock() across the walk; they
   only test flags on the RCU-freed node.
 - ff_layout_cancel_io() takes a reference around the cancel/disconnect
   calls, which may block.
 - ff_layout_mirror_prepare_stats() runs under i_lock, which a future
   re-pointing walk must also hold.
 - ff_layout_free_mirror() tears down the last reference; no concurrency.

The pointer is still only ever set once per mirror lifetime, so there is
no behavior change; this commit makes the subsequent in-place re-resolve
on CB_NOTIFY_DEVICEID CHANGE safe to introduce.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    |  29 ++++--
 fs/nfs/flexfilelayout/flexfilelayout.h    |   2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 112 ++++++++++++++--------
 3 files changed, 92 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c07409056292..dfc0c298ab4b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -313,7 +313,9 @@ static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 		cred = rcu_access_pointer(mirror->dss[dss_id].rw_cred);
 		put_cred(cred);
 		nfs_close_local_fh(&mirror->dss[dss_id].nfl);
-		nfs4_ff_layout_put_deviceid(mirror->dss[dss_id].mirror_ds);
+		/* the last reference to the mirror is gone; no concurrency */
+		nfs4_ff_layout_put_deviceid(rcu_dereference_protected(
+				mirror->dss[dss_id].mirror_ds, 1));
 	}
 
 	kfree(mirror->dss);
@@ -2476,22 +2478,29 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 	for (idx = 0; idx < flseg->mirror_array_cnt; idx++) {
 		mirror = flseg->mirror_array[idx];
 		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
-			mirror_ds = mirror->dss[dss_id].mirror_ds;
-			if (IS_ERR_OR_NULL(mirror_ds))
+			rcu_read_lock();
+			mirror_ds = rcu_dereference(mirror->dss[dss_id].mirror_ds);
+			if (IS_ERR_OR_NULL(mirror_ds) ||
+			    !atomic_inc_not_zero(&mirror_ds->id_node.ref)) {
+				rcu_read_unlock();
 				continue;
-			ds = mirror->dss[dss_id].mirror_ds->ds;
+			}
+			rcu_read_unlock();
+			ds = mirror_ds->ds;
 			if (!ds)
-				continue;
+				goto next;
 			ds_clp = ds->ds_clp;
 			if (!ds_clp)
-				continue;
+				goto next;
 			clnt = ds_clp->cl_rpcclient;
 			if (!clnt)
-				continue;
+				goto next;
 			if (!rpc_cancel_tasks(clnt, -EAGAIN,
 					      ff_layout_match_io, lseg))
-				continue;
+				goto next;
 			rpc_clnt_disconnect(clnt);
+next:
+			nfs4_ff_layout_put_deviceid(mirror_ds);
 		}
 	}
 }
@@ -2958,7 +2967,9 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			dss_info = &mirror->dss[dss_id];
 			if (i >= dev_limit)
 				break;
-			mirror_ds = dss_info->mirror_ds;
+			mirror_ds = rcu_dereference_protected(
+				dss_info->mirror_ds,
+				lockdep_is_held(&lo->plh_inode->i_lock));
 			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
 			if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index d6ec80cf8a6e..54e87847ee45 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -79,7 +79,7 @@ struct nfs4_ff_layout_ds_stripe {
 	struct nfs4_ff_layout_mirror   *mirror;
 	struct nfs4_deviceid		devid;
 	u32				efficiency;
-	struct nfs4_ff_layout_ds	*mirror_ds;
+	struct nfs4_ff_layout_ds __rcu	*mirror_ds;
 	u32				fh_versions_cnt;
 	struct nfs_fh			*fh_versions;
 	nfs4_stateid			stateid;
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index d140e46581e7..4ab55f0874d5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -342,35 +342,54 @@ ff_layout_get_mirror_ds(struct pnfs_layout_hdr *lo,
 			struct nfs4_ff_layout_mirror *mirror,
 			u32 dss_id)
 {
-	struct nfs4_ff_layout_ds *mirror_ds;
+	struct nfs4_ff_layout_ds *mirror_ds, *old;
+	struct nfs4_deviceid_node *node;
 
 	if (mirror == NULL)
 		return ERR_PTR(-ENODEV);
 
-	mirror_ds = mirror->dss[dss_id].mirror_ds;
-	if (mirror_ds == NULL) {
-		struct nfs4_deviceid_node *node;
-
-		mirror_ds = ERR_PTR(-ENODEV);
-		node = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode),
-				&mirror->dss[dss_id].devid, lo->plh_lc_cred,
-				GFP_KERNEL);
-		if (node)
-			mirror_ds = FF_LAYOUT_MIRROR_DS(node);
-
-		/* check for race with another call to this function */
-		if (cmpxchg(&mirror->dss[dss_id].mirror_ds, NULL, mirror_ds) &&
-		    mirror_ds != ERR_PTR(-ENODEV))
-			nfs4_put_deviceid_node(node);
-
-		mirror_ds = mirror->dss[dss_id].mirror_ds;
+retry:
+	rcu_read_lock();
+	mirror_ds = rcu_dereference(mirror->dss[dss_id].mirror_ds);
+	if (mirror_ds && !IS_ERR(mirror_ds) &&
+	    atomic_inc_not_zero(&mirror_ds->id_node.ref)) {
+		rcu_read_unlock();
+		return mirror_ds;
 	}
-
+	rcu_read_unlock();
 	if (IS_ERR(mirror_ds))
 		return mirror_ds;
-	if (!atomic_inc_not_zero(&mirror_ds->id_node.ref))
-		return ERR_PTR(-ENODEV);
-	return mirror_ds;
+	if (mirror_ds != NULL)
+		/* raced with a reset; the field is being re-pointed */
+		goto retry;
+
+	node = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode),
+			&mirror->dss[dss_id].devid, lo->plh_lc_cred,
+			GFP_KERNEL);
+	if (node) {
+		mirror_ds = FF_LAYOUT_MIRROR_DS(node);
+		/*
+		 * The caller's reference, taken while we hold the only
+		 * reference so a concurrent reset of the installed pointer
+		 * cannot free the node under us.
+		 */
+		atomic_inc(&node->ref);
+	} else
+		mirror_ds = ERR_PTR(-ENODEV);
+
+	/* check for race with another call to this function */
+	old = unrcu_pointer(cmpxchg(&mirror->dss[dss_id].mirror_ds,
+				    NULL, RCU_INITIALIZER(mirror_ds)));
+	if (old == NULL)
+		/* installed: one reference on the mirror, one for the caller */
+		return mirror_ds;
+
+	/* lost the race; use the winner's node instead */
+	if (node) {
+		nfs4_put_deviceid_node(node);
+		nfs4_put_deviceid_node(node);
+	}
+	goto retry;
 }
 
 /**
@@ -593,49 +612,60 @@ unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
 static bool ff_read_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_ff_layout_mirror *mirror;
-	struct nfs4_deviceid_node *devid;
+	struct nfs4_ff_layout_ds *mirror_ds;
+	bool ret = false;
 	u32 idx, dss_id;
 
+	rcu_read_lock();
 	for (idx = 0; idx < FF_LAYOUT_MIRROR_COUNT(lseg); idx++) {
 		mirror = FF_LAYOUT_COMP(lseg, idx);
 		if (!mirror)
 			continue;
 		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
-			if (!mirror->dss[dss_id].mirror_ds)
-				return true;
-			if (IS_ERR(mirror->dss[dss_id].mirror_ds))
+			mirror_ds = rcu_dereference(mirror->dss[dss_id].mirror_ds);
+			if (!mirror_ds) {
+				ret = true;
+				goto out;
+			}
+			if (IS_ERR(mirror_ds))
 				continue;
-			devid = &mirror->dss[dss_id].mirror_ds->id_node;
-			if (!nfs4_test_deviceid_unavailable(devid))
-				return true;
+			if (!nfs4_test_deviceid_unavailable(&mirror_ds->id_node)) {
+				ret = true;
+				goto out;
+			}
 		}
 	}
-
-	return false;
+out:
+	rcu_read_unlock();
+	return ret;
 }
 
 static bool ff_rw_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_ff_layout_mirror *mirror;
-	struct nfs4_deviceid_node *devid;
+	struct nfs4_ff_layout_ds *mirror_ds;
+	bool ret = false;
 	u32 idx, dss_id;
 
+	rcu_read_lock();
 	for (idx = 0; idx < FF_LAYOUT_MIRROR_COUNT(lseg); idx++) {
 		mirror = FF_LAYOUT_COMP(lseg, idx);
 		if (!mirror)
-			return false;
+			goto out;
 		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
-			if (IS_ERR(mirror->dss[dss_id].mirror_ds))
-				return false;
-			if (!mirror->dss[dss_id].mirror_ds)
+			mirror_ds = rcu_dereference(mirror->dss[dss_id].mirror_ds);
+			if (IS_ERR(mirror_ds))
+				goto out;
+			if (!mirror_ds)
 				continue;
-			devid = &mirror->dss[dss_id].mirror_ds->id_node;
-			if (nfs4_test_deviceid_unavailable(devid))
-				return false;
+			if (nfs4_test_deviceid_unavailable(&mirror_ds->id_node))
+				goto out;
 		}
 	}
-
-	return FF_LAYOUT_MIRROR_COUNT(lseg) != 0;
+	ret = FF_LAYOUT_MIRROR_COUNT(lseg) != 0;
+out:
+	rcu_read_unlock();
+	return ret;
 }
 
 static bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
-- 
2.53.0

