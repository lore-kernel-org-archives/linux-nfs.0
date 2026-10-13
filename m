Received: from mail-pj1-f44.google.com (mail-pj1-f44.google.com [209.85.216.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBBC43CBE89
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 06:00:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791871238; cv=none; b=Gi6ryIgpYFY786bhQJl6Rn2QdXeLLDOPM2SXfghN/ug+2FH+EwPj0W/QJK76NOYPHj79ZxxVcUYQMRWYNgWAVoe7pmF7WFFhTp8LbJA9rZXqvkGPSI+4aH6cvxVWLul+HkfbZ/TKA+5bem5VRuX78fKqzY4JTxxif/OdgAmwPak=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791871238; c=relaxed/simple;
	bh=YYRWZl4u3Uh21mQ++xbyke7rOxG/1RLoQw/Of8q5WT0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hvq0R22niThwTiq2pehnVf3Hu+P075XsYi/HbH3nke51Qi1ktTf7R6oQJ2XvUlzqN1tZfP6I/EP8XrZizvdC/Bdlfbv7IwLHN9MMZj1k9S+8vJBgtZKUSjaVI/bB+qPaj/hY0mV2LTEySm7EOZVK/BvnbBgw53R0lILNJJziO28=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=qFOu6A/R; arc=none smtp.client-ip=209.85.216.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qFOu6A/R"
Received: by mail-pj1-f44.google.com with SMTP id 98e67ed59e1d1-3a7fecf8440so1283293a91.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 23:00:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791871236; x=1792476036; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=odGcP4OG/NlpBPBL4aEpmzbDePI14gC8lqg8uBJDoEU=;
        b=qFOu6A/RWATz+hD+o5rlQDy8IKPe1gYF/OUeGQ8SRlis0lPrxRqepGrNC47ghZneE1
         f/98oT656fr+UgPyUsKJdDJNiHSW6Nh5oaesb/o6eZSJaDQhnlBUUYmBLKtYRCJPOCS+
         TcRtvEKNSUMEitpTUnhsmxLCnS8T5ZBM84z0DWBmjhGkQuAKarkuZoCV6BoCfem8lT5+
         wkMq4eqwrb8v381BKGWxWmrCk7uHzY7fjs5XQ59hFQGvHm8006kbwrGpkaFxBS5RTvV6
         Epx/nCCfCB76P+VxCpVAujkGNgG4ER94aJYsN8uwm1OTteRqGxY23JloSRRmkdD5Cz93
         0Llw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791871236; x=1792476036;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=odGcP4OG/NlpBPBL4aEpmzbDePI14gC8lqg8uBJDoEU=;
        b=dohO2bkZqcn+x380196luV9bRPNeuN9AuQwwjjg5J6NECFGJJ34a0TJvs51nYz6aT+
         wOs+Wy/pS9VsoituPKx8E25mwq8JIQtKDpEG3tjBWOmaAwVdS3diX7+ooOMUz2wNOfaf
         2qjfWeW0S8nc7TuBpqkuCRj6ZdQsx3UAyn+SIhTfptiR59SKxvIvHikYxOAgrvFKkGjZ
         4oD+WTv33YLN+yge+srsEZ/ZC3awupBRASxhc1jJsEyK9acXB3hOZnAyKx379IILBEJN
         xBPq/aZ/XB6c+LuvXbxWkh4nwapd1oSTzzvmTZZKdeNtibv6g47RRqVHJwcWm/D8h/Ue
         S5sQ==
X-Gm-Message-State: AFq9FYIMv+T/DYPKHzO7Aux/1UQIgGFXzl3Km0PfeYGwL+OinL8RniwQ
	5coWpByZpREeZuwQT+EmMB2j18v1y5o3JSmLyjvB2AsoFt9hdeH/yrJEIF5muaVn5XU=
X-Gm-Gg: AYBFou0QE2wiseq3GgtWU1S62o+YV0/rAxy3ATl1Xw4DO1iWVJEFthddvSyQEL6xp4g
	rznN3Nmc2dW1qv1/NL6bvEALn2fgDvDiPUARaE0qPA3mbIqkglpUI4/5AMq38piv987LrOzX7h0
	Ve/pSYF6Q3qre95TYTpSWYhj4CgxDHcRiKQ1yMqk0ODgVabtZxtnWi5F1E5DERHmCaEqojNiVzQ
	oNp3/58TZb14HWZuuOGWn24s34UJ9xf+Pu+epdaews2aa3g/Ruq5/sz5MIvV7YU/oHdFe/yW3w7
	MQRNGh8bnecCnQq0OWGROY1FgyJdIdPNjnKQ0L5W/MxV0U0DxhKYZX2rbdTRtdcommUVocRRwfc
	/5s1cecRoHA3w6vObZh6Vdm+I/aTNA/Wgsntr63lUsdLMlVnCdyPzfdmiqndhvHqDUcatBJAMqh
	Uef2aJIDR5cL9sD4TQpYQiUc4ynOlM9O/bTo5OauTNgEorVswAXLi3SauQNjIkCMMuOT3TMZD74
	KGQ2RU=
X-Received: by 2002:a17:90a:e704:b0:3aa:fc22:8aaa with SMTP id 98e67ed59e1d1-3ab3b0951e9mr9730377a91.67.1791871236081;
        Mon, 12 Oct 2026 23:00:36 -0700 (PDT)
Received: from bintable.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ab38ddac6dsm18592915a91.7.2026.10.12.23.00.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 12 Oct 2026 23:00:35 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-kernel@vger.kernel.org,
	bobtobabz@gmail.com,
	stable@vger.kernel.org
Subject: [PATCH v2] nfsd: prevent a double put of revoked layout stateids
Date: Tue, 13 Oct 2026 15:00:21 +0900
Message-ID: <20261013060021.46543-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <133aa8197620ef4f36a48faa62c207f5ee12c0a0.camel@kernel.org>
References: <133aa8197620ef4f36a48faa62c207f5ee12c0a0.camel@kernel.org>
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

Mark the layout stateid CLOSED under cl_lock so only one disposal caller
proceeds. Take a temporary reference before dropping cl_lock and hold it
while stopping fence work and draining the remaining layout segments,
then release that reference with the final put. This keeps the stateid
alive even though its IDR owns no reference and its layout segments are
being removed.

Use cl_lock for the CLOSED update in LAYOUTRETURN as well, matching the
common stateid locking rule. Retain ls_mutex from the last segment removal
through the CLOSED update, and recheck CLOSED under cl_lock after taking
ls_mutex in LAYOUTGET. This prevents a stale LAYOUTGET from adding a
segment after the drain. Also make the newly allocated layout stateid the
error-path put target and update the status-locking comment.

Restrict nfs40_clean_admin_revoked() to NFSv4.0 clients. Its timer is
armed only by v4.0 revocations, while session clients dispose of revoked
stateids through FREE_STATEID. Skipping session clients prevents the scan
from repeatedly selecting a CLOSED stateid that remains in the IDR while
an in-flight operation holds a reference.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 86b9898920a6 ("NFSD: Handle layout stid in nfsd4_drop_revoked_stid()")
Suggested-by: Chuck Lever <cel@kernel.org>
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes since v1:
- Address Jeff Layton's concern by using cl_lock for layout CLOSED
  checks and updates, without a type-dependent stateid status helper.
- Move LAYOUTRETURN's CLOSED update outside ls_lock while retaining
  ls_mutex, and update the status-locking documentation.
- Clarify the LAYOUTGET serialization and v4.0 cleanup restriction.
- Credit Chuck Lever's suggestion and mark the fix for stable review.
- Rebase onto nfsd-testing c807415bc69013a5f162264ee0e14f8742c182f7.

Validated on the above nfsd-testing base (2026-10-13):
- Applied cleanly, passed strict checkpatch, and built and booted an x86_64
  kernel with GCC 13.3, W=1, Generic KASAN, lockdep, and pNFS block and
  SCSI layouts enabled.
- Loopback pNFS SCSI read, shrink, integrity, revocation, and cleanup tests
  passed, as did NFSv4.2, NFSv4.0, and NFSv3 read/write, fio CRC32C, and
  unmount tests. Tracing observed two successful LAYOUTRETURNs reach the
  modified CLOSED update and release their stateids.
- Two concurrent FREE_STATEID requests from different slots of one NFSv4.1
  session returned one success and one NFS4ERR_BAD_STATEID. A test-only
  two-second pause forced the losing request into the disposal window;
  tracing observed CLOSED, exactly one revoked-layout drain, and one
  layout-state free.
- No KASAN, lockdep, refcount, list-corruption, WARNING, or Oops report
  occurred, and kernel taint remained zero through fixture cleanup.

Build note: Existing format-truncation warnings in target_core_transport.c
were excluded from WERROR; W=1 and WERROR remained enabled otherwise.

The full xfstests suite was not run. Earlier v1 runtime results are not
used as validation of this revision.

 fs/nfsd/nfs4layouts.c | 34 ++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c   | 14 ++++++++++++++
 fs/nfsd/pnfs.h        |  6 ++++++
 fs/nfsd/state.h       |  5 ++---
 4 files changed, 54 insertions(+), 5 deletions(-)

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
index 26d2d56a5..1740b86eb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5873,9 +5873,21 @@ static void nfsd4_drop_revoked_stid(struct nfs4_stid *s)
 		break;
 	case SC_TYPE_LAYOUT:
 		ls = layoutstateid(s);
+		if (s->sc_status & SC_STATUS_CLOSED) {
+			spin_unlock(&cl->cl_lock);
+			break;
+		}
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
@@ -7901,6 +7913,8 @@ static void nfs40_clean_admin_revoked(struct nfsd_net *nn,
 		unsigned long id, tmp;
 		struct nfs4_stid *stid;
 
+		if (clp->cl_minorversion != 0)
+			continue;
 		if (atomic_read(&clp->cl_admin_revoked) == 0)
 			continue;
 		if (is_client_expired(clp))
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
index 79dfa47b8..63b581104 100644
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

base-commit: c807415bc69013a5f162264ee0e14f8742c182f7
-- 
2.50.1 (Apple Git-155)
