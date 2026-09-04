Received: from mail-qv1-f47.google.com (mail-qv1-f47.google.com [209.85.219.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEE1350AC3B
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540818; cv=none; b=dsR9dfOykU2N3uIE4XCRk8CiEeTfZXC2Ns20MYUrjwf68Lrjz6ceihN9x00NvSG7dFI6Ov7Xo1ctaeYanvZkrum13djU0jnR0Yiv4m7qqLhmPXXU+TaIIkKlPx/IlyYUyxOlDgwS+FLAq1gipS7JSHyksVKszdEZUwr/58rGgR4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540818; c=relaxed/simple;
	bh=NsS/wBdgVphBehzfPZ4E+J3aHO8TnNl8akohe/pLCTY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=A3zkUDSifDRWjao7EoLNg/e+NhDN9PX8+1vW3UEMcWZ3BjP9/uAZUM3UVWAFlZjGSWnRiXJ1iLNSLwyO9mxCSXfE06iJe2V39Pe00qcCA+RPwSxPzqMdYr5mKAsj51lfOJM7TT8iYdQM8fMtfFA0cIDP0XFt9WwZk57kScBTwPU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=gV5Zti1u; arc=none smtp.client-ip=209.85.219.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gV5Zti1u"
Received: by mail-qv1-f47.google.com with SMTP id 6a1803df08f44-90ce08834feso18028576d6.0
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540815; x=1789145615; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FCUkdn4GlCBy4F6HhgzKuTpOMuxKg5g3TVFBVpDgo6w=;
        b=gV5Zti1usht12XqwjPlHt7OGWPC24F1N5IFdY+3acRxJfyxRabkPwsOaGG6Kn3AwLx
         kvGWRi0W25NF27GHWyLMLR8JzJbu7mBJ3aZnNvsjhWId54xSO50PNS+CK4bfA1a9MdXv
         i4ttnIc9tq7hTlg8UGfs1RIb5NMTbm52bOS34lL0bSfaRlsRyzaHYZmxuFUeQUbC45u0
         2JMaD1rXAKkEoWwxQLshXByY/tBSkOc+93Sab7k+N+ZAlROENDCNJZwbX9AnntO8lmqt
         hcKqUryFBNaDGMxt3Uz5fF9D12GkW5WBrK0xADa84/FLFM9W4UeoJxcLL57TLG3MAhT1
         v5/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540815; x=1789145615;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=FCUkdn4GlCBy4F6HhgzKuTpOMuxKg5g3TVFBVpDgo6w=;
        b=R8gx98D+X/4kT7OP1hJ8DBBALeGLkjb1aEcBI4hNo92LNRHRXvvkGTkRIQPL47YtNB
         9XhKavHliBwS4mdJbZuq3NnwZOCbcxtvFrtTkdGIVekHHrUPomDHbrzed0tQD8Md0LKr
         4AvtFvQywazcbskHMA7iBrayfJsGl5NLrarF2OQFrs3y5nmIX8xb3r+CVXreYzuF2Tv3
         GwE7ti3wQLuaBdQ1bkmxAZ8g0Am8YaJj+Fb1WHLc8riYSL1ZWZpLkL6xJvsm02h7ac0h
         XE2ULgNsfe9hqZgntyGFJdVzkPeiRcz8NUttGXzFhMqHzlG6sUv2fQmXMI2HnPoINZbx
         VqGw==
X-Gm-Message-State: AFuF++kmlIbdn8b80SR36Y4Ur+p5zaofalzhgrlhFEpLXLy7o6niSf3Y
	ZSn+JOeH2ZimvdO2fQfq2MG1DWse3FVPd8JIpl4DuOdJr1rc/l7fJSI6LO8pvmhgLI4=
X-Gm-Gg: AYBFou0yqEhrLcUEqRl+eho+Q50IIAYmTe5EQt9wHA0Ktop9KqEUsYx/ik12TVrABjH
	yd1p4aFHg0W5Mw03WWlII2OPvz40kt1oZVkKg1zmTWTPsYvbHvnhBpGuoghPappVd5P4Ciippzb
	rtA6dlwoCTOhYQJAZ+zgLHOmBfqQMALcVlSq+4N7GxC93nH1U3Cr3bp+wlXvyxQHpMM99WdccOV
	ajz3sUFO/RHPbeM9XCsPo0eyuifGPERYLIEzxflszf+OzFc28ewgQddO/J/LnFh3DZdntYbr0Rz
	O4aLZgZVPXMZpbV2nrFYXFJCsVkqOL0ETC8U03/M3Zfm2NlMm2pj1+o1Qp9aeQBx5IQj9Q2XbYF
	XFalxFSD6aV3jcbRlBBRWjvtRw42/UzdntZjAtOEzMquHmooMkB+5b0YMseIXre/oNWtMCDtteL
	OUEBmfE22B2VuR29AKH7zceaVCGOF25AtUri7YyzD4pQd6OAg00M58xJck3HhIN3ls0Sa1NyNWO
	LRp2VtRSD6V42kwZp9rF9bf
X-Received: by 2002:a05:620a:690e:b0:939:6de8:43de with SMTP id af79cd13be357-939804e9754mr677750485a.50.1788540814313;
        Fri, 04 Sep 2026 09:53:34 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 11/24] NFSv4/flexfiles: Make the pinned device node pointer RCU-managed
Date: Fri,  4 Sep 2026 12:53:10 -0400
Message-ID: <99101deee644125ecc91a8cd3f9435a0d8593df0.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
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
   with atomic_inc_not_zero(), retrying if it races a reset.  The
   resolve path takes the caller's reference before publishing the node
   with cmpxchg(), so a concurrent reset cannot drop the last reference
   under the caller: one reference is held for the installed pointer and
   one for the caller, and the pointer's reference is released elsewhere
   by xchg + put.
 - The availability scans hold rcu_read_lock() across the walk; they
   only test flags on the RCU-freed node.
 - ff_layout_cancel_io() holds a reference across the cancel and
   disconnect calls.  Both of its callers hold i_lock and nothing on
   that path sleeps, so the reference is not about blocking: it is
   what keeps the node alive between the RCU-protected read and the
   use of mirror_ds->ds.  The final put is never reached here, because
   the mirror's own pin outlives the loop -- which matters, since that
   put ends in nfs_put_client() and cannot run under a spinlock.
 - ff_layout_mirror_prepare_stats() reads the pointer with
   rcu_dereference() under rcu_read_lock().  i_lock, which both callers
   hold, is what excludes the re-pointing walk added later in this
   series; it does not exclude the resolve path's cmpxchg(), which runs
   from I/O submission, so the read cannot claim i_lock as its update-
   side lock.  A non-NULL pointer read there is stable regardless: the
   resolve path only ever installs over NULL.
 - ff_layout_free_mirror() tears down the last reference; no concurrency.

The pointer is still only ever set once per mirror lifetime, so there is
no behavior change; this commit makes the subsequent in-place re-resolve
on CB_NOTIFY_DEVICEID CHANGE safe to introduce.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    |  35 ++++---
 fs/nfs/flexfilelayout/flexfilelayout.h    |   2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 110 ++++++++++++++--------
 3 files changed, 93 insertions(+), 54 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 015428fd6937..eeda084d20dd 100644
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
@@ -2498,22 +2500,29 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
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
 			if (!rpc_cancel_tasks(clnt, -ECANCELED,
 					      ff_layout_match_io, lseg))
-				continue;
+				goto next;
 			rpc_clnt_disconnect(clnt);
+next:
+			nfs4_ff_layout_put_deviceid(mirror_ds);
 		}
 	}
 }
@@ -2975,12 +2984,13 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 	struct nfs4_ff_layout_ds *mirror_ds;
 	int i = 0, dss_id;
 
+	rcu_read_lock();
 	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
 		for (dss_id = 0; dss_id < mirror->dss_count; ++dss_id) {
 			dss_info = &mirror->dss[dss_id];
 			if (i >= dev_limit)
 				break;
-			mirror_ds = dss_info->mirror_ds;
+			mirror_ds = rcu_dereference(dss_info->mirror_ds);
 			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
 			if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL,
@@ -2990,10 +3000,8 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			/* mirror refcount put in cleanup_layoutstats */
 			if (!refcount_inc_not_zero(&mirror->ref))
 				continue;
-			/*
-			 * The mirror's pin holds the node while we're under
-			 * i_lock; take a reference for the encode, put in
-			 * ff_layout_free_layoutstats().
+			/* The pin holds a reference; it is exchanged out only
+			 * under i_lock.  Put in ff_layout_free_layoutstats().
 			 */
 			atomic_inc(&mirror_ds->id_node.ref);
 			memcpy(&devinfo->dev_id,
@@ -3022,6 +3030,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			i++;
 		}
 	}
+	rcu_read_unlock();
 	return i;
 }
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 8b42a98a2c4c..72b11034851a 100644
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
index ebcfba447879..5cb09e5e2138 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -321,35 +321,54 @@ ff_layout_get_mirror_ds(struct pnfs_layout_hdr *lo,
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
+retry:
+	rcu_read_lock();
+	mirror_ds = rcu_dereference(mirror->dss[dss_id].mirror_ds);
+	if (mirror_ds && !IS_ERR(mirror_ds) &&
+	    atomic_inc_not_zero(&mirror_ds->id_node.ref)) {
+		rcu_read_unlock();
+		return mirror_ds;
+	}
+	rcu_read_unlock();
+	if (IS_ERR(mirror_ds))
+		return mirror_ds;
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
+		 * Take the caller's reference before the pointer becomes
+		 * visible below, so a concurrent reset of the installed
+		 * pointer cannot drop the last reference under us.
+		 */
+		atomic_inc(&node->ref);
+	} else {
 		mirror_ds = ERR_PTR(-ENODEV);
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
 	}
 
-	if (IS_ERR(mirror_ds))
+	/* check for race with another call to this function */
+	old = unrcu_pointer(cmpxchg(&mirror->dss[dss_id].mirror_ds,
+				    NULL, RCU_INITIALIZER(mirror_ds)));
+	if (old == NULL)
 		return mirror_ds;
-	if (!atomic_inc_not_zero(&mirror_ds->id_node.ref))
-		return ERR_PTR(-ENODEV);
-	return mirror_ds;
+
+	/* lost the race; use the winner's node instead */
+	if (node) {
+		nfs4_put_deviceid_node(node);
+		nfs4_put_deviceid_node(node);
+	}
+	goto retry;
 }
 
 /**
@@ -573,49 +592,60 @@ unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
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

