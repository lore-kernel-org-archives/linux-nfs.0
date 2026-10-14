Received: from mail-pj1-f51.google.com (mail-pj1-f51.google.com [209.85.216.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 258A43168EF
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 06:12:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791958352; cv=none; b=ryTH2JnVpR6hCVceU9XFfq2iIXXZMC40RO268JIEXDvhT1TFHQ1S+bOto3nXu+ZPyWHzIabu5uUPCvcnS4vIFwqAW3yvRSsjR33W7WhfR+OTE95VhY1gzuFLZ6x0eq1wFOasYyNmLguT5BP8dwxSoESphFIhmZnrI+A4GnDGQ48=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791958352; c=relaxed/simple;
	bh=i3dgU2b+aUuuCJEajR/vwhAVTF5qBQLno5WkrLeCgsM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CvNa/+VuUBTVMcdXxu/KTD0XS9HG8Ku3zG671cIS3WMY0QPCd1e55rU6R+I0fWWfW5hjdmRwBB8uDbAjBG32NXMpq+r8k2FWdDTKXu8/nbVrLbJrd42tHlhd2hRRSHUpC+S26s3gAPQMt5S8ngGEOgVFJBVRYZhn+xnhCnw0HjU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Tv5KA3MB; arc=none smtp.client-ip=209.85.216.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Tv5KA3MB"
Received: by mail-pj1-f51.google.com with SMTP id 98e67ed59e1d1-3ac77270fbfso101502a91.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 23:12:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791958350; x=1792563150; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=z00McG2/XHo1Y/v09p/B0SZ9bgqX+Fj9s0hH8a70oC4=;
        b=Tv5KA3MBoaf4WElDWqpffL2D8NBnnXO2AUMAbTlunaemHOs3VCLQdY/m+2vJLSmzUr
         eopj7eY3C+HMALYRc/sI06TICGyucpoXemfn0bkPd68O50q1pkF/yO3elLKNWRZj3z5o
         IqEd4db/mGUv2sVjXx6V9HT+WY27nWGktuq6gY+0jzXMrB0eqnZIvY/VPGiUhWRITQMQ
         7uX31E+80uLnMsymuuvM9sgkT7m180OPEcd/yJ8J3xdLVF4BeymTEeEDNbvQBkLHqy/B
         2hf6ugJc9OtLSQTFVaQNY2hGySB3NZPhDJ369G0Te5rF9BshoVkBiQw8mGrwXf92SXdl
         fgeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791958350; x=1792563150;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=z00McG2/XHo1Y/v09p/B0SZ9bgqX+Fj9s0hH8a70oC4=;
        b=kRBogjm2sOkVnZ2FeC1CmegghTE9iDoOgfDr3D0i+TTTZ5R1LQoczAmRUYr1R/07Bj
         4O3cvWUaNNaMAacfLT1kvw2688gokJC2Kp/RLufyTeIn0JLJwZZyWdzGXLTnKG6W6C8B
         0o4rV+/CpyesIxaqQNuFiv9JUtB3W4fV5M1qEnupxc0+VF9E+v6kB4YdRhIhn1zZWN9C
         CF37ycY3Ub3J4+lcxUtR/WjnB/uYowb47u/oAz5ehI+OPimFZAijcmOKXvEAboqHlVIp
         CkR7Y2+14Zocmxgo8rxIUnkoN7HOyNKNIcRbS5PU2f+q75BOTbAgmHn9QpHCtohBR8p7
         lbMw==
X-Gm-Message-State: AFq9FYJuiBPcy9UelAepMNsJ0UseXyhVG6HhAqALd7fc9kh85OPkYEVC
	0AnYe/4w+E+FJyMoHl3CN3bl7YpE8tmbSLHG/bNJeSsAC/h4xAwAkZn1IULGlgyb2tg=
X-Gm-Gg: AYBFou1ZvPSubutmbrXeUDMBrHZz12BoNZ42wj8qrZw0nurz4gyRz/oAOaHXBKN2xde
	OahnLmmI367VaTwrIoBRhhWX5BsZbI/wmHRrXdLRql1uZnIg3HQEqxcB2aAmyzSs+TRY9RGOL4x
	pNx0g40NJsmKOFUr7SAKLB+MZQO6vfblicJF9QBWe6rub6d9bL0Q70DWXnizviuB4UHHtNWF++x
	5fk/mSTbMXCP/Sh6lqDec59EAcuYOCkuEMin9JMH2u3pwbISvzDJOjNYoUlNIWIYLBpCG4yVkdY
	5udxM6mFVr+/wHAd/I1/qFknfdoNOcUR4KkDmaKxj17tVrmFvHwJIcx9HQg7/a76fjaA66xljY8
	W3Oc2cDgkhbzRVEXN8N6q0hLPBoLxCW22S/SV+FZidnANipaJ4F++Lb9+yQjctHQquF4z0M4wZF
	9PrkhUNML7o9DrL6pmXI5nxb1rY7/LnrNJFxmVs1x9SXLpPextuE2X5PBLeGcdgtlVaEBCGxXzb
	KqsW4L/BReQ4Zc=
X-Received: by 2002:a17:90a:4ca2:b0:3ab:7031:d962 with SMTP id 98e67ed59e1d1-3ab70412990mr7653511a91.41.1791958350288;
        Tue, 13 Oct 2026 23:12:30 -0700 (PDT)
Received: from bintable.tail83b815.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ac7321cc5bsm2086827a91.14.2026.10.13.23.12.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Oct 2026 23:12:29 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	bobtobabz@gmail.com
Subject: [PATCH v3] nfsd: prevent a double put of revoked layout stateids
Date: Wed, 14 Oct 2026 15:12:18 +0900
Message-ID: <20261014061218.102648-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <3a6b84453aaa75b654155a699d4f85735df9c48d.camel@kernel.org>
References: <3a6b84453aaa75b654155a699d4f85735df9c48d.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_free_stateid() finds an admin-revoked layout stateid with
find_stateid_locked(), which does not acquire a reference. The layout
case drops cl_lock without marking the stateid closed, then stops fence
work and calls nfs4_put_stid() without owning a reference. Concurrent
disposal can therefore access a freed layout stateid or drop a reference
owned by another holder.

Mark the layout stateid CLOSED under cl_lock. Take a temporary reference
before dropping cl_lock and hold it while stopping fence work and
draining the remaining layout segments, then release it with the final
put. The IDR owns no layout reference.

Use cl_lock for the CLOSED update in LAYOUTRETURN as well, matching the
common stateid locking rule. Retain ls_mutex through that update and
recheck CLOSED under cl_lock after taking ls_mutex in LAYOUTGET, so a
stale LAYOUTGET cannot add a segment after the drain. Also make the newly
allocated layout stateid the error-path put target.

Make revoked-stateid disposal idempotent with SC_STATUS_FREED under
cl_lock. An in-flight reference can keep an admin-revoked OPEN, LOCK, or
DELEG stateid in the IDR after disposal. Restrict
nfs40_clean_admin_revoked() to v4.0 clients and skip FREED entries so its
retry loop cannot repeatedly select the same stateid or consume references
owned by other callers. Use FREED rather than CLOSED to guard disposal:
delegation recall rejection can set CLOSED before the first disposal call.

Reject FREED stateids in FREE_STATEID and TEST_STATEID as well, so a
stateid retained by an in-flight reference returns BAD_STATEID after
successful disposal instead of success or ADMIN_REVOKED.

Validation used nfsd-testing at c32fef6c476d. The patched x86_64 kernel
and modules were built with GCC 12.2 and booted with Generic KASAN,
lockdep, modular NFSD, and pNFS SCSI layout support. Basic NFSv4.2,
NFSv4.0, and NFSv3 read/write/unmount smoke tests passed.

Targeted runs forced concurrent two-slot FREE_STATEID, LAYOUTGET and
LAYOUTRETURN overlaps around ls_mutex, and an NFSv4.0 cleaner retry while
a READ held an OPEN stateid reference. Stateids were reaped once, stale
requests returned BAD_STATEID, and the NFSv4.0 cleaner did not process
the NFSv4.1 client. No KASAN, lockdep, refcount, list-corruption, Oops, or
kernel BUG report occurred; kernel taint remained zero.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 86b9898920a6 ("NFSD: Handle layout stid in nfsd4_drop_revoked_stid()")
Suggested-by: Chuck Lever <cel@kernel.org>
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v3:

- Address the v4.0 disposal issue reported by Sashiko and forwarded by
  Jeff Layton: claim disposal with FREED under cl_lock and skip FREED
  stateids in the admin-revocation scan.
- Preserve first-time disposal of delegations already marked CLOSED, and
  reject FREED stateids in FREE_STATEID and TEST_STATEID.
- Rebase onto nfsd-testing c32fef6c476daa5830f600614657baee59c83339
  and add targeted runtime validation.

 fs/nfsd/nfs4layouts.c | 34 ++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c   | 29 +++++++++++++++++++++++++----
 fs/nfsd/pnfs.h        |  6 ++++++
 fs/nfsd/state.h       |  6 +++---
 4 files changed, 66 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 898776c9d..749ace97e 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -312,6 +312,7 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 		status = nfserr_jukebox;
 		if (!ls)
 			goto out;
+		stid = &ls->ls_stid;
 		mutex_lock(&ls->ls_mutex);
 	} else {
 		ls = container_of(stid, struct nfs4_layout_stateid, ls_stid);
@@ -324,6 +325,15 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 			goto out_unlock_stid;
 	}
 
+	/* A new or looked-up stateid may have been closed before ls_mutex. */
+	spin_lock(&stid->sc_client->cl_lock);
+	if (stid->sc_status & SC_STATUS_CLOSED) {
+		spin_unlock(&stid->sc_client->cl_lock);
+		status = nfserr_bad_stateid;
+		goto out_unlock_stid;
+	}
+	spin_unlock(&stid->sc_client->cl_lock);
+
 	*lsp = ls;
 	return 0;
 
@@ -537,12 +547,18 @@ nfsd4_return_file_layouts(struct svc_rqst *rqstp,
 			nfs4_inc_and_copy_stateid(&lrp->lr_sid, &ls->ls_stid);
 		lrp->lrs_present = true;
 	} else {
-		trace_nfsd_layoutstate_unhash(&ls->ls_stid.sc_stateid);
-		ls->ls_stid.sc_status |= SC_STATUS_CLOSED;
 		lrp->lrs_present = false;
 	}
 	spin_unlock(&ls->ls_lock);
 
+	if (!lrp->lrs_present) {
+		/* ls_mutex prevents a LAYOUTGET from adding another segment. */
+		spin_lock(&ls->ls_stid.sc_client->cl_lock);
+		ls->ls_stid.sc_status |= SC_STATUS_CLOSED;
+		spin_unlock(&ls->ls_stid.sc_client->cl_lock);
+		trace_nfsd_layoutstate_unhash(&ls->ls_stid.sc_stateid);
+	}
+
 	mutex_unlock(&ls->ls_mutex);
 	nfs4_put_stid(&ls->ls_stid);
 	nfsd4_free_layouts(&reaplist);
@@ -594,6 +610,20 @@ nfsd4_return_all_layouts(struct nfs4_layout_stateid *ls,
 	spin_unlock(&ls->ls_lock);
 }
 
+void nfsd4_return_revoked_layout(struct nfs4_layout_stateid *ls)
+{
+	LIST_HEAD(reaplist);
+
+	/*
+	 * The caller holds a stateid reference until segment draining ends.
+	 * Wait for any LAYOUTGET that passed the CLOSED check.
+	 */
+	mutex_lock(&ls->ls_mutex);
+	nfsd4_return_all_layouts(ls, &reaplist);
+	mutex_unlock(&ls->ls_mutex);
+	nfsd4_free_layouts(&reaplist);
+}
+
 void
 nfsd4_return_all_client_layouts(struct nfs4_client *clp)
 {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 26d2d56a5..0f1641eab 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5849,6 +5849,17 @@ static void nfsd4_drop_revoked_stid(struct nfs4_stid *s)
 	struct nfs4_delegation *dp;
 	bool unhashed;
 
+	/*
+	 * In-flight references can keep a disposed stateid in the IDR.
+	 * CLOSED alone is not sufficient: a delegation may be closed
+	 * before its first call here.
+	 */
+	if (s->sc_status & SC_STATUS_FREED) {
+		spin_unlock(&cl->cl_lock);
+		return;
+	}
+	s->sc_status |= SC_STATUS_FREED;
+
 	switch (s->sc_type) {
 	case SC_TYPE_OPEN:
 		stp = openlockstateid(s);
@@ -5867,15 +5878,22 @@ static void nfsd4_drop_revoked_stid(struct nfs4_stid *s)
 	case SC_TYPE_DELEG:
 		dp = delegstateid(s);
 		list_del_init(&dp->dl_recall_lru);
-		s->sc_status |= SC_STATUS_FREED;
 		spin_unlock(&cl->cl_lock);
 		nfs4_put_stid(s);
 		break;
 	case SC_TYPE_LAYOUT:
 		ls = layoutstateid(s);
+		s->sc_status |= SC_STATUS_CLOSED;
+		/*
+		 * The IDR does not own a layout stateid reference. Keep ls
+		 * alive while draining worker and segment references below;
+		 * the final put releases this temporary reference.
+		 */
+		refcount_inc(&s->sc_count);
 		list_del_init(&ls->ls_perclnt);
 		spin_unlock(&cl->cl_lock);
 		nfsd4_stop_layout_fence(ls);
+		nfsd4_return_revoked_layout(ls);
 		nfs4_put_stid(s);
 		break;
 	default:
@@ -7901,6 +7919,8 @@ static void nfs40_clean_admin_revoked(struct nfsd_net *nn,
 		unsigned long id, tmp;
 		struct nfs4_stid *stid;
 
+		if (clp->cl_minorversion != 0)
+			continue;
 		if (atomic_read(&clp->cl_admin_revoked) == 0)
 			continue;
 		if (is_client_expired(clp))
@@ -7908,7 +7928,8 @@ static void nfs40_clean_admin_revoked(struct nfsd_net *nn,
 
 		spin_lock(&clp->cl_lock);
 		idr_for_each_entry_ul(&clp->cl_stateids, stid, tmp, id)
-			if (stid->sc_status & SC_STATUS_ADMIN_REVOKED) {
+			if ((stid->sc_status & SC_STATUS_ADMIN_REVOKED) &&
+			    !(stid->sc_status & SC_STATUS_FREED)) {
 				refcount_inc(&stid->sc_count);
 				atomic_inc(&clp->cl_rpc_users);
 				spin_unlock(&nn->client_lock);
@@ -8340,7 +8361,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 		return status;
 	spin_lock(&cl->cl_lock);
 	s = find_stateid_locked(cl, stateid);
-	if (!s)
+	if (!s || s->sc_status & SC_STATUS_FREED)
 		goto out_unlock;
 	status = nfsd4_stid_check_stateid_generation(stateid, s, 1);
 	if (status)
@@ -8725,7 +8746,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	spin_lock(&cl->cl_lock);
 	s = find_stateid_locked(cl, stateid);
-	if (!s || s->sc_status & SC_STATUS_CLOSED)
+	if (!s || s->sc_status & (SC_STATUS_CLOSED | SC_STATUS_FREED))
 		goto out_unlock;
 	if (s->sc_status & SC_STATUS_ADMIN_REVOKED) {
 		nfsd4_drop_revoked_stid(s);
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index 559df0e5b..9b0f17a4d 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -75,6 +75,7 @@ struct nfsd4_deviceid_map *nfsd4_find_devid_map(int idx);
 #ifdef CONFIG_NFSD_PNFS
 void nfsd4_setup_layout_type(struct svc_export *exp);
 void nfsd4_return_all_client_layouts(struct nfs4_client *);
+void nfsd4_return_revoked_layout(struct nfs4_layout_stateid *ls);
 void nfsd4_return_all_file_layouts(struct nfs4_client *clp,
 		struct nfs4_file *fp);
 void nfsd4_close_layout(struct nfs4_layout_stateid *ls);
@@ -93,6 +94,11 @@ static inline void nfsd4_setup_layout_type(struct svc_export *exp)
 static inline void nfsd4_return_all_client_layouts(struct nfs4_client *clp)
 {
 }
+
+static inline void nfsd4_return_revoked_layout(struct nfs4_layout_stateid *ls)
+{
+}
+
 static inline void nfsd4_return_all_file_layouts(struct nfs4_client *clp,
 		struct nfs4_file *fp)
 {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 79dfa47b8..924a98af7 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -148,9 +148,8 @@ struct nfs4_stid {
  * nn->deleg_lock protects sc_status for hashed delegation stateids.
  * ->cl_lock protects the bits set as one is disposed of
  * (SC_STATUS_CLOSED, SC_STATUS_FREEABLE, SC_STATUS_FREED) and
- * sc_status for open and lock stateids. ->st_mutex also protects
- * sc_status for open stateids. ->ls_lock protects sc_status for
- * layout stateids.
+ * sc_status for open, lock, and layout stateids. ->st_mutex also protects
+ * sc_status for open stateids.
  */
 /*
  * For an open stateid kept around *only* to process close replays.
@@ -161,6 +160,7 @@ struct nfs4_stid {
 #define SC_STATUS_REVOKED	BIT(1)
 #define SC_STATUS_ADMIN_REVOKED	BIT(2)
 #define SC_STATUS_FREEABLE	BIT(3)
+/* Disposal has been claimed; in-flight references may still exist. */
 #define SC_STATUS_FREED		BIT(4)
 	unsigned short		sc_status;
 

base-commit: c32fef6c476daa5830f600614657baee59c83339
