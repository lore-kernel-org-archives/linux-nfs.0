Received: from mail-oi1-f176.google.com (mail-oi1-f176.google.com [209.85.167.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2206C493635
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329785; cv=none; b=sTW/l4elyEK/jkIPIVFhIkCwf2TBHWMCppmB2hC4vHhoXGFzHPfbL1t/VdNEUK7hEJHdokn0+TZCyXxOyHjneo9UpX+Cie8m5Eq5JVx3b0sUmv1eEIljE9Q4XZBeN6TTr4GipQxNUkNe8Duk9Ggtj4ee9jGt3PTuZOKt5WAT7Ck=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329785; c=relaxed/simple;
	bh=/VVM+rBXYYpXutmhFAcIq0ixh17keWxHYhgaMWeb8s4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EOAO5AY+C0N90piaM8FgACkU2jolsPZUEmZLTTeV2LVd83aT7UOw4Gl8hoOf3oJm+yIQaKI7/fDW9bhdBJviZDhdLI4TB1nMfWMHUwMT1CprCw5DoIuGlUrK+Zde7+Cfo2Kz9dd27OGq/aq7PLJlXIeIG1EcOG/5iRwUJFK1T8M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=lciqlpnA; arc=none smtp.client-ip=209.85.167.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="lciqlpnA"
Received: by mail-oi1-f176.google.com with SMTP id 5614622812f47-4b28d9537bcso862462b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329783; x=1787934583; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=rK0Kq8iM3ZxZuEloJnTh0CYor8+HosAPGJEVTajXr74=;
        b=lciqlpnAqv5QyQkV985p8qy35TsnQUK5lOTilP0Jl7hZSSqSZjWjvZyCZ3ux2bRX3K
         NBZey38L2J8znAQutFGIrcQERelntDLTO5+8sU8D1JO8Zgh/UfRRyZMTRD1ltxDOpz7l
         DPWIg0Fs/120XUPXSqZqICVGuKHBouFd3TD2U3CvN5ZOQzY5R3ARiRexglISqxk1hIV+
         bM/Mm4y7dppfImTq65LTXQhcMqdlZ6agGggO2SvPssyUz00xGOb4brXSYSFebX6hhnbQ
         aN1W2biS1o+lPZTm4S/cbyMgst3kDZDXtp7Qvc91VGf3i9RePV90ictn60ilUvK0H27l
         lxyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329783; x=1787934583;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=rK0Kq8iM3ZxZuEloJnTh0CYor8+HosAPGJEVTajXr74=;
        b=YP5f/fy8ROqH7M1ImWxy7RfRa7oUNbY9OVeqAWi0Np/p0XBFnjrqKUIIDYAhOjaR5J
         fbHARXOaTCFCmaXI8JfnwejdmyoCISs0uTHKXz7y0XWlUtLSDZqBmlvFHfT+izWkHsZo
         v2szKpHfrYzcNaS3aXWgIuyuAYMjnKqtKJalVUa3RiNbANDsB2z0HMq/8LOpzXD7ztvP
         OHCzCSVlS9On4iUPZg/hCUfGKP/sf0KoBFmE5SXC9Qlk7mdDLHe0LDFAExjhB1/3b8Rb
         S9dqjdNYwhPL0OTm/bg/swbvZW6PaLTISEzxHvSeTHeS+TxG4VS0ScdU2LMY345GztDd
         NsnA==
X-Gm-Message-State: AOJu0YyJ1sREtHU5/2STp5DcxGI7vpEuNeO42+461uH9Dt8dOxCqgnrr
	ujMa26PmIHwm7H9Q+iKuL99drF/MzaoPV9DeHslDaCcw3oab38yxO/DsqSxiagDSDK4=
X-Gm-Gg: AR+sD11aMjn7B9gH4iBy3anbadNxNkywLB1BSRQNaiTaJVxhgXP+1Yoyj0YrVCMzHSg
	BymhpWRpSjkuvfsWG+lzK/C8r5zwxtGmGmUR7/4O17cak3TNLd5VeB7O36WaSySGlN2jSHi2E1c
	YUi16oPlOTUowbQO9NmhcxrEyowlaiijve4wIDj7Qy1WvHPB8R317oaJxZ2Bgx+rj29sysTweFu
	CTuwhbLvfUa4luNvXN2wgyp5CDxkSk6Ckzi/DboTrVqqtLSyMNeM740pnCPctt8WVzAS8xC24uy
	QnSv53y9XG3K/gsf21FIFhisnf70Kp/1JFgggJWA3m4ZefcfOW8uFTDU/6MHYt7FUcOjpVod4TR
	jHg92R5+QHaZaPWjMy9nQC3LsSDV0f2wUqexTH5hJQCeSJuy40h0hUZ779iNC+iypeseMw8fpUE
	T1J9+18a6x8Sk75VpMiQrGSHabgc9zbd2cZy1NK0PKrrYtXLvFrIvJd156MPAe4QiFei4rmVDEo
	5cGmzd47k422OaUQ/6PekGa+etzwOjCQoIH3cEa2OFW4pw=
X-Received: by 2002:a05:6808:4f6b:b0:4a4:64b0:bf5e with SMTP id 5614622812f47-4b2ef4afd2amr6103652b6e.2.1787329782810;
        Fri, 21 Aug 2026 09:29:42 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:41 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 10/23] NFSv4/flexfiles: Make the pinned device node pointer RCU-managed
Date: Fri, 21 Aug 2026 12:29:14 -0400
Message-ID: <4e4f73676be9ae7669719ff5ed16bf20ddbb8ee5.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
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
index 947bb277c4ef..3572324630df 100644
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
@@ -2479,22 +2481,29 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
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
@@ -2956,12 +2965,13 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
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
@@ -2971,10 +2981,8 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
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
@@ -3003,6 +3011,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			i++;
 		}
 	}
+	rcu_read_unlock();
 	return i;
 }
 
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
index 54349d9a89db..f0254ee6a9a8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -333,35 +333,54 @@ ff_layout_get_mirror_ds(struct pnfs_layout_hdr *lo,
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
@@ -584,49 +603,60 @@ unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
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

