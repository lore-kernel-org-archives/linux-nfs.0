Received: from mail-pj2-f39.google.com (mail-pj2-f39.google.com [74.125.227.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDF3547CA8D
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 08:38:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.167
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790584697; cv=none; b=HLnO9B7W4snvQT4msoykrwM0gSXFAKnxxxNWPO6hLslDa4GSI/1Dte8RJStPna+MWvzbFD6+YiZqthAiIHJ6Adb8jall0bgViDCUsoLwJCjF+TxLOzbsrfrGVQPMm3j8MwLypEKdCcDby8l9pInTNEBfoNUyN8hf9zWGjYGcnfE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790584697; c=relaxed/simple;
	bh=yJBb4xVl//U5Sk6wt5j2lAbpqYiGv7stPLbjGcwf2MQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=kR2uHg7SkFJkR/LV+kDt4OlqIO+M2RnQ0wU05pe4iWO4UFpGBMQOQwhP4XdMsF3Spt/N0KNokLiyIClYqyJzorzakUVBOXIrla+fs5pTNcbN4gQbbl/jiLir4EVFG8jN/FUurK54n3XBpXLgoaeB5No4NZHlW61gOT2VfVJxl9k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ZnbPQuY+; arc=none smtp.client-ip=74.125.227.167
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZnbPQuY+"
Received: by mail-pj2-f39.google.com with SMTP id 98e67ed59e1d1-3a47d6146d1so126446a91.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 01:38:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790584694; x=1791189494; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=cRwn21UOlpB5OURip2/M6tQx+++UP+1c7noiZ6QeChg=;
        b=ZnbPQuY+c/zNFblsuvcHBIXiH1Mh4w6y/IBfNK9dx2GL7NHTDFEKEQtET3sevm+6Cr
         O8y1/EgYYrEixXi391Td7lk3mMnvPbOihB9TbrD+veHykgSf3F6I/of7oclqIA7wIBVl
         qn3VbTSXw+VHPM8xfN/Hnf7heEO24cQrpgIOnUmn1PTNQlVJYxCr4ZzxiRpXGBC5oK/P
         oixBAK0LMa0eeo2I7i2tRv1A9nzw8cQrQFeUl2SfUQMJXwP78nlRTcfxNajwLajbLlrB
         cuRnh8fImCnziYQonXMVOn494ipU2bkn2vPaCaS8vDGySCUVSNz8YkTPkc1TJrGrDLIN
         7dmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790584694; x=1791189494;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=cRwn21UOlpB5OURip2/M6tQx+++UP+1c7noiZ6QeChg=;
        b=mCmoA7X15AlyQ5lzQUu5kOfS4i9jgmvaNBBfFZ3tLwJR0de8sqWuU0Fbvwfaj5naPZ
         4ej/9Bx22X6Oi823tyugro2+OLO4t2pMsDEaDSjQX9vox/qQk8GDVdRdu3XdEenV4Npe
         AcIR/4wThHq2BuCo+WQJNW8LqJdI4RCMRSYT/83KMcJGlE0+iQddVJQhXY/bAJb+KMCt
         BRBagDAlpc1sTvJ/lzHJFhKOXxBCkaHIiFR0mPPd5S9R8sn4rNtubklYyk8aS6BkG/XV
         0SIHl2bAqXaVaS1eRo+pdW1oWdRjNgTvYuabNGGEWEvpB/uVU90au22uYc6haMVN/dyg
         ucsg==
X-Gm-Message-State: AFq9FYKwYdDuBJX34J74kcpcOtsdZAsR6GPZSbfcp83D3pkWq//3eExi
	KilEZelZyKOKmMgQ2NjfgGC09XR4XlZ3xvqPpOyTaSnGXp6xktlPql/FcxmvTnGKp3Y=
X-Gm-Gg: AYBFou2Vx/TrbbNiV2qmjZ8BBhd3oGy0ho3PI26kHMS1fE31wRE8WFyY2wI/4sdjG1H
	q8F9RfA+6/5v7vvgw960b1oXk4U5wJoT6HNkeWXXiLeoUBiox0TXDlHGNEkNVaYdxKv2pheLrKg
	2n8+AI6jfcRhPOEWK3UaO8YY3Md+4/qfbdrZB6F7TL4touuRFU/nAAnAw91tuw2mLleIE9PQum7
	37oY6poB9pe3evSjbwr+YeoaDqd1wlmRcKPHUM7PaqBimIgJh/BeyRhxZDJTDt4NOwYvBl4Yf+f
	70ZMoeSsAhuvyczrxvXPcsi50UbthucQxVZdgJ4wXpMHKJeBwvJsr/isd4DshELc4wQs2U4bk1w
	bmb6073NZJOyTBrFB4AR0r2F79MeXqFLpkxpSM58qg3AEjaxBeykR+rdy3yO3iQcQ0ImSvacQi6
	pC5teKB0twxU3fAUS1SrMtpoKlB8fBOuk3a4Kfi1OYxQG/UBD07obs6eJ/jliZYXHMqfhzqxh9r
	rBGgwQ=
X-Received: by 2002:a17:90a:10c8:b0:3a0:aa50:48bb with SMTP id 98e67ed59e1d1-3a0aa504bbfmr4945427a91.29.1790584693658;
        Mon, 28 Sep 2026 01:38:13 -0700 (PDT)
Received: from bintable.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a0b99917besm19235885a91.14.2026.09.28.01.38.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Sep 2026 01:38:13 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com,
	Jinpyo Lee <bint4b13@gmail.com>
Subject: [PATCH v2] nfsd: drain pNFS fence work during state teardown
Date: Mon, 28 Sep 2026 17:37:39 +0900
Message-ID: <20260928083739.643010-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The pNFS layout-recall timeout path holds a layout stateid reference
while a delayed fence worker runs and retries. A stateid reference does
not retain sc_client, so client expiry can free the nfs4_client while
the worker still uses client-owned state and eventually releases the
stateid through the stale client pointer.

Keeping only the client alive is not sufficient. The worker also uses
clp->net, and neither the stateid nor a client reference prevents NFSD
per-net state or module code from being torn down while a retry is
pending.

Prevent new fence work from being scheduled once layout teardown starts,
and synchronously cancel or drain an existing worker before releasing
the layout's client association. Check the stop state under ls_lock at
both the initial scheduling point and the retry point so cancellation
cannot miss a newly queued retry. Serialize teardown callers so only one
of them disposes of the worker-owned stateid reference.

The worker clears ls_fence_inflight before its final nfs4_put_stid(), so
that flag alone does not prove the worker has finished. Always synchronize
with the delayed work during teardown, even when the flag is already
clear. Release the worker-owned stateid reference in the teardown path
only when pending work was actually canceled.

nfsd4_return_all_client_layouts() is reached from __destroy_client(), so
the drain covers administrator expiry, laundromat expiry, client
replacement during CREATE_SESSION, and nfs4_state_shutdown_net().
Stopping revoked layout stateids separately also prevents a worker from
escaping the client list before shutdown. Module unload reaches the same
per-net state shutdown path before the pNFS caches and module text are
released.

The reproducer uses a pNFS SCSI export and a failed storage fence to keep
the retry pending. A source reproducer and the complete KASAN log are
available privately on request.

The original KASAN use-after-free was reproduced in nfs4_put_stid() on
the unpatched nfsd-testing tree. The patched x86_64 kernel was built
and boot-tested with Generic KASAN, lockdep, modular NFSD, and pNFS block
and SCSI layout support. Targeted runs covered administrator expiry,
natural lease expiry followed by courtesy-client shrinker reclamation,
CREATE_SESSION replacement, per-net shutdown, module unload, retry, and
successful storage fencing. No KASAN, lockdep, or refcount report occurred.

Named-netns removal followed by explicit NFSD shutdown and final
namespace exit also produced no KASAN, lockdep, or refcount report.
A test-only run confirmed teardown waited for the worker's final
stateid release.

Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests passed. The full
kernel and modules were built with GCC 13.3 without new compiler warnings.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: f52792f484ba ("NFSD: Enforce timeout on layout recall and integrate lease manager fencing")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v2:
- Replace client pinning with synchronized fence-work shutdown that blocks
  initial scheduling and retries and waits for the final stateid release.
- Handle revoked layout stateids and client, per-net, and module teardown.
- Describe targeted runtime validation and its limits.

Validation details for reviewers:

- NFSD holds a network namespace reference until nfs4_state_destroy_net(),
  after client teardown has drained fence work. Removing a namespace name
  during a pending retry did not destroy it; explicit rpc.nfsd 0 drained
  the worker before final namespace exit. This does not test namespace
  destruction while the worker runs.
- Test-only instrumentation widened the interval between clearing
  ls_fence_inflight and the final nfs4_put_stid(). During expiry,
  cancel_delayed_work_sync() waited for worker completion (2.027 seconds).
  The test-only changes are not in this patch.
- Matching unpatched runs also logged GETDEVICEINFO nfserrno() warnings
  (values 2 and 917504). This patch does not modify that path.

 fs/nfsd/nfs4layouts.c | 106 +++++++++++++++++++++++++++++++++---------
 fs/nfsd/nfs4state.c   |   2 +
 fs/nfsd/pnfs.h        |   5 ++
 fs/nfsd/state.h       |   2 +
 4 files changed, 94 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 12acb68cb..7ac379fd5 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -246,6 +246,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	spin_lock_init(&ls->ls_lock);
 	INIT_LIST_HEAD(&ls->ls_layouts);
 	mutex_init(&ls->ls_mutex);
+	mutex_init(&ls->ls_fence_mutex);
 	ls->ls_layout_type = layout_type;
 	nfsd4_init_cb(&ls->ls_recall, clp, &nfsd4_cb_layout_ops,
 			NFSPROC4_CLNT_CB_LAYOUT);
@@ -265,6 +266,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 
 	ls->ls_fenced = false;
 	ls->ls_fence_inflight = false;
+	ls->ls_fence_stopped = false;
 	ls->ls_fence_delay = 0;
 	INIT_DELAYED_WORK(&ls->ls_fence_work, nfsd4_layout_fence_worker);
 
@@ -602,13 +604,35 @@ nfsd4_return_all_layouts(struct nfs4_layout_stateid *ls,
 void
 nfsd4_return_all_client_layouts(struct nfs4_client *clp)
 {
-	struct nfs4_layout_stateid *ls, *n;
+	struct nfs4_layout_stateid *ls;
 	LIST_HEAD(reaplist);
 
-	spin_lock(&clp->cl_lock);
-	list_for_each_entry_safe(ls, n, &clp->cl_lo_states, ls_perclnt)
+	/*
+	 * A fence worker dereferences sc_client and clp->net.  Drain every
+	 * worker before client or per-net state can be released.  Take a
+	 * temporary stateid reference because stopping a worker can sleep.
+	 */
+	for (;;) {
+		spin_lock(&clp->cl_lock);
+		ls = list_first_entry_or_null(&clp->cl_lo_states,
+					      struct nfs4_layout_stateid,
+					      ls_perclnt);
+		if (!ls) {
+			spin_unlock(&clp->cl_lock);
+			break;
+		}
+		if (!refcount_inc_not_zero(&ls->ls_stid.sc_count)) {
+			spin_unlock(&clp->cl_lock);
+			cond_resched();
+			continue;
+		}
+		list_del_init(&ls->ls_perclnt);
+		spin_unlock(&clp->cl_lock);
+
+		nfsd4_stop_layout_fence(ls);
 		nfsd4_return_all_layouts(ls, &reaplist);
-	spin_unlock(&clp->cl_lock);
+		nfs4_put_stid(&ls->ls_stid);
+	}
 
 	nfsd4_free_layouts(&reaplist);
 }
@@ -792,8 +816,47 @@ nfsd4_layout_lm_open_conflict(struct file *filp, int arg)
 	return 0;
 }
 
-static void
-nfsd4_layout_fence_worker(struct work_struct *work)
+static void nfsd4_layout_fence_done(struct nfs4_layout_stateid *ls)
+{
+	/* Unlock the lease so that tasks waiting on it can proceed. */
+	nfsd4_close_layout(ls);
+
+	spin_lock(&ls->ls_lock);
+	ls->ls_fenced = true;
+	ls->ls_fence_inflight = false;
+	spin_unlock(&ls->ls_lock);
+	nfs4_put_stid(&ls->ls_stid);
+}
+
+void nfsd4_stop_layout_fence(struct nfs4_layout_stateid *ls)
+{
+	/* Serialize teardown callers which can arrive through different paths. */
+	mutex_lock(&ls->ls_fence_mutex);
+	spin_lock(&ls->ls_lock);
+	if (ls->ls_fence_stopped) {
+		spin_unlock(&ls->ls_lock);
+		mutex_unlock(&ls->ls_fence_mutex);
+		return;
+	}
+	ls->ls_fence_stopped = true;
+	spin_unlock(&ls->ls_lock);
+
+	/*
+	 * The worker clears ls_fence_inflight before its final nfs4_put_stid().
+	 * Always wait for it, even if that flag is already clear.  New work
+	 * cannot be queued after ls_fence_stopped is set under ls_lock.
+	 * If pending work was canceled, release its stateid reference here.
+	 */
+	if (cancel_delayed_work_sync(&ls->ls_fence_work))
+		nfsd4_layout_fence_done(ls);
+
+	spin_lock(&ls->ls_lock);
+	WARN_ON_ONCE(ls->ls_fence_inflight);
+	spin_unlock(&ls->ls_lock);
+	mutex_unlock(&ls->ls_fence_mutex);
+}
+
+static void nfsd4_layout_fence_worker(struct work_struct *work)
 {
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct nfs4_layout_stateid *ls = container_of(dwork,
@@ -804,18 +867,10 @@ nfsd4_layout_fence_worker(struct work_struct *work)
 	struct nfsd_net *nn;
 
 	spin_lock(&ls->ls_lock);
-	if (list_empty(&ls->ls_layouts)) {
+	if (ls->ls_fence_stopped || list_empty(&ls->ls_layouts)) {
 		spin_unlock(&ls->ls_lock);
 dispose:
-		cancel_delayed_work(&ls->ls_fence_work);
-		/* unlock the lease so that tasks waiting on it can proceed */
-		nfsd4_close_layout(ls);
-
-		ls->ls_fenced = true;
-		spin_lock(&ls->ls_lock);
-		ls->ls_fence_inflight = false;
-		spin_unlock(&ls->ls_lock);
-		nfs4_put_stid(&ls->ls_stid);
+		nfsd4_layout_fence_done(ls);
 		return;
 	}
 	spin_unlock(&ls->ls_lock);
@@ -862,12 +917,19 @@ dispose:
 	 *    clid: is the unique client identifier displayed in
 	 *          the warning message above.
 	 */
+	spin_lock(&ls->ls_lock);
+	if (ls->ls_fence_stopped || list_empty(&ls->ls_layouts)) {
+		spin_unlock(&ls->ls_lock);
+		goto dispose;
+	}
 	if (!ls->ls_fence_delay)
 		ls->ls_fence_delay = HZ;
 	else
 		ls->ls_fence_delay = min(ls->ls_fence_delay << 1,
 					 MAX_FENCE_DELAY);
-	mod_delayed_work(system_dfl_wq, &ls->ls_fence_work, ls->ls_fence_delay);
+	mod_delayed_work(system_dfl_wq, &ls->ls_fence_work,
+			 ls->ls_fence_delay);
+	spin_unlock(&ls->ls_lock);
 }
 
 /**
@@ -897,8 +959,7 @@ nfsd4_layout_lm_breaker_timedout(struct file_lease *fl)
 {
 	struct nfs4_layout_stateid *ls = fl->c.flc_owner;
 
-	if ((!nfsd4_layout_ops[ls->ls_layout_type]->fence_client) ||
-			ls->ls_fenced)
+	if (!nfsd4_layout_ops[ls->ls_layout_type]->fence_client)
 		return true;
 	/*
 	 * Make sure layout has not been returned yet before
@@ -910,6 +971,10 @@ nfsd4_layout_lm_breaker_timedout(struct file_lease *fl)
 	 * fresh schedule that takes an extra unmatched reference.
 	 */
 	spin_lock(&ls->ls_lock);
+	if (ls->ls_fenced || ls->ls_fence_stopped) {
+		spin_unlock(&ls->ls_lock);
+		return true;
+	}
 	if (ls->ls_fence_inflight) {
 		spin_unlock(&ls->ls_lock);
 		return false;
@@ -920,9 +985,8 @@ nfsd4_layout_lm_breaker_timedout(struct file_lease *fl)
 		return true;
 	}
 	ls->ls_fence_inflight = true;
-	spin_unlock(&ls->ls_lock);
-
 	mod_delayed_work(system_dfl_wq, &ls->ls_fence_work, 0);
+	spin_unlock(&ls->ls_lock);
 	return false;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0f9340eb2..4075db57e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2082,6 +2082,7 @@ static void revoke_one_stid(struct nfsd_net *nn, struct nfs4_client *clp,
 			atomic_inc(&clp->cl_admin_revoked);
 		}
 		spin_unlock(&clp->cl_lock);
+		nfsd4_stop_layout_fence(layoutstateid(stid));
 		nfsd4_close_layout(layoutstateid(stid));
 		drop_stid_export(clp, stid);
 		break;
@@ -5861,6 +5862,7 @@ static void nfsd4_drop_revoked_stid(struct nfs4_stid *s)
 		ls = layoutstateid(s);
 		list_del_init(&ls->ls_perclnt);
 		spin_unlock(&cl->cl_lock);
+		nfsd4_stop_layout_fence(ls);
 		nfs4_put_stid(s);
 		break;
 	default:
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index f7bee4dc5..559df0e5b 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -78,6 +78,7 @@ void nfsd4_return_all_client_layouts(struct nfs4_client *);
 void nfsd4_return_all_file_layouts(struct nfs4_client *clp,
 		struct nfs4_file *fp);
 void nfsd4_close_layout(struct nfs4_layout_stateid *ls);
+void nfsd4_stop_layout_fence(struct nfs4_layout_stateid *ls);
 int nfsd4_init_pnfs(void);
 void nfsd4_exit_pnfs(void);
 #else
@@ -99,6 +100,10 @@ static inline void nfsd4_return_all_file_layouts(struct nfs4_client *clp,
 static inline void nfsd4_close_layout(struct nfs4_layout_stateid *ls)
 {
 }
+
+static inline void nfsd4_stop_layout_fence(struct nfs4_layout_stateid *ls)
+{
+}
 static inline void nfsd4_exit_pnfs(void)
 {
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cd9294f02..209ea43a2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -861,9 +861,11 @@ struct nfs4_layout_stateid {
 	struct mutex			ls_mutex;
 
 	struct delayed_work		ls_fence_work;
+	struct mutex			ls_fence_mutex; /* serializes fence shutdown */
 	unsigned int			ls_fence_delay;
 	bool				ls_fenced;
 	bool				ls_fence_inflight;
+	bool				ls_fence_stopped;
 };
 
 static inline struct nfs4_layout_stateid *layoutstateid(struct nfs4_stid *s)

base-commit: cab95e6be3ba82bcf4c8be27c2eb20e55238aa41
-- 
2.50.1 (Apple Git-155)
