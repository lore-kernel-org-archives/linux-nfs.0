Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793745113;
	b=Aqi8s7uj3M4EFsxwQKf5tHkR612VmuZRigL5X/xB/rKN93fM5pdVOC+XpksE1je2qCeU
	 ViYV4oBpEbDL7pqOmczFNGYRycte4YlL3qWmzzsueUh7TvlrSCp8TV2X/B15L/a/orS7t
	 6E3Hn86Okz98YiihT+/QpPe/qhDpOLyA2RrRC5PWtpxB3+fiLgPE3BKfrkCKjQHzsnnCT
	 SmLLOROcc+p9C1kiKvP/cZsty1qYuZVByAVOYfaCWfY8Gg1JaBLmw/GUz5vyjPSm2xftX
	 at5fxZl9WiO3pfx0CNHLwJhHcYcSnYmWWYTVoQiqnbNtP4FEJnUoYUmECUHYzqFM6wA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793745113;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=yiLjmo0Ku8al3hMMt8KalpT5YKclAs+wJ9YFfzSDu7o=;
	b=2HvqvPkwCL/EizeMXbPB5al95H9H+I9UXZJwfi+fo4V073k+f2+9LulYztEEmPDEJCnX
	 zqIh8tnaTjnUxZ4NiPW/tyPHKX7RWhWhDqHxqrS0VRIjihCq670J+UIy+YQv/0xKqiVe/
	 tDOZOpExtbwZKkYyuXWQZxLlVYoODGUOiYcXkDBke0v42u/VQcU7V6GlSUF04cvp8cnVp
	 n+bF/cbxFhtPr0VU6aLjUc04JEHyaFewnsiwFLMDS589spujuzVzeCqMto+5Z8A2j8MQH
	 nPyR52fr7DHn/QHvQvAwnzmQewgobTM971z/anfEIIs0uhXxqQCrByBYChKZazQR6SA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--nhuhuan.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=GEp3ZJLU;
	arc=none smtp.remote-ip=74.125.82.71
Received: from mail-dl1-f71.google.com (mail-dl1-f71.google.com [74.125.82.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0ED55606A337
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 22:31:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0ED55606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--nhuhuan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=GEp3ZJLU
Received: by mail-dl1-f71.google.com with SMTP id a92af1059eb24-15c16792146so127636c88.1
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2026 14:31:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793745112; x=1794349912; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=yiLjmo0Ku8al3hMMt8KalpT5YKclAs+wJ9YFfzSDu7o=;
        b=GEp3ZJLUlvl3ji3CiAIx3mbesyNOJD4HeygwWRq8optnqkmc43zFw5raauDCiZO5vw
         yZTyJeFAoQz8GyM4pfKoO/wSIldJmg7w4ZnGNdoFAlhRuXpjD8tfRnryYkZjjIflveS/
         B4DxUyl5WkTK8g9u/7sbNaP6BEYQDqkcmtpiejvIDec5D9SZGA+zbjqvAGWn4MYKBfPf
         3hPDfitkR/qLk8TOqD/fk7ygFmalGF8Nb6gls/ERLmQp84OzYXUGBb8UetFvmE360izs
         +E6cuj87VrQVHwXReOTlORn827N6nNNa5dBY51r7Ffnrb23Ca08rYNdlN8FOO4fgYjWo
         ZSjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793745112; x=1794349912;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=yiLjmo0Ku8al3hMMt8KalpT5YKclAs+wJ9YFfzSDu7o=;
        b=TqNRgC3nXo/thh9zfzkq9Nu4v44cvq8xkObW1HaQ8BcVdEAWieo1ROUSDUYZkAVJve
         dpELdjO6gkXrp1Dt6DFapmRd7W2W2nwqHgBIMIyqPNEmW11Qd9bm1DMsRNIGSdW8Cr0T
         +Me3ti+85djpxOo3PYdJ2Y1ls9KkTho6nfWY8Owb7sLXWaReyEbdA23XrcLepY0EYiZ5
         6JhJ3I2Y5AN54MtPNx3A2HPm3g0BSlDW4FHhfeVRAafxVATHZXxhu4kdURZW1KgVAzWC
         DUpOVlfZlwGUTknPqsItIz8G+1X9M/kcrDKIDU7j1eTLHIOPjowsbQ4CSNZMiJCTOkWN
         oY9Q==
X-Forwarded-Encrypted: i=1; AKwUvBxNq613bRf5/JN+HYPUZo30Dg4UqUijXm1kkFBzrPlBchElzYUUrMUVUckthLosKS8C/BZW/4YR3jk=@vger.kernel.org
X-Gm-Message-State: APuU4Z9ThYzzu771rjfATFGCUg9hk6Y1GaQoHxOac1kZ3iDTaG0dRXE6
	AQV+esleM9du/sTGrIWmHiT+cbyaNt/GI94IxxsbiI0ecz79RlCxxjm60Qqj3oIlOCmWpthULkj
	u7iSZBtnzFg==
X-Received: from dlep20-n1.prod.google.com ([2002:a05:701b:4594:10b0:19c:1243:1e3d])
 (user=nhuhuan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:7022:ea46:20b0:1a6:53cc:7454
 with SMTP id a92af1059eb24-1ac5d4b2ad9mr23818615c88.27.1793745111665; Tue, 03
 Nov 2026 14:31:51 -0800 (PST)
Date: Tue,  3 Nov 2026 14:30:24 -0800
In-Reply-To: <20261103223025.2482227-1-nhuhuan@google.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com> <20261103223025.2482227-1-nhuhuan@google.com>
X-Mailer: git-send-email 2.56.0.398.g882cbad275-goog
Message-ID: <20261103223025.2482227-3-nhuhuan@google.com>
Subject: [RFC PATCH v3 2/3] mm/migrate: introduce async non-temporal migration mode
From: Huan Nguyen <nhuhuan@google.com>
To: tglx@kernel.org, mingo@redhat.com, bp@alien8.de, 
	dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, 
	akpm@linux-foundation.org, david@kernel.org, ljs@kernel.org, 
	Liam.Howlett@oracle.com, vbabka@kernel.org, rppt@kernel.org, 
	surenb@google.com, mhocko@suse.com, trondmy@kernel.org, anna@kernel.org, 
	ziy@nvidia.com, matthew.brost@intel.com, joshua.hahnjy@gmail.com, 
	rakie.kim@sk.com, byungchul@sk.com, gourry@gourry.net, 
	ying.huang@linux.alibaba.com, apopple@nvidia.com, rostedt@goodmis.org, 
	mhiramat@kernel.org, mathieu.desnoyers@efficios.com, jackmanb@google.com, 
	hannes@cmpxchg.org, shivankg@amd.com
Cc: rientjes@google.com, dave@stgolabs.net, nifan.cxl@gmail.com, 
	fvdl@google.com, jic23@kernel.org, rkodsara@amd.com, bharata@amd.com, 
	sj@kernel.org, weixugc@google.com, xuezhengchu@huawei.com, 
	yiannis@zptcorp.com, yiannis.nikolakop@gmail.com, 
	dimitrios.palyvos@zptcorp.com, alirad.malek@zptcorp.com, ryan.roberts@arm.com, 
	nhuhuan@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-nfs@vger.kernel.org, linux-trace-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Introduce MIGRATE_ASYNC_NONTEMPORAL to migrate cold folios using
non-temporal stores, avoiding CPU cache pollution.

Existing callers check "mode == MIGRATE_ASYNC" directly, which would
cause new asynchronous modes to fall back to synchronous handling.
Introduce migrate_is_async() and update callers across compaction,
NFS, and migration.

In __migrate_folio(), invoke folio_mc_copy_nt() when the migration
mode is MIGRATE_ASYNC_NONTEMPORAL.

Suggested-by: Alirad Malek <alirad.malek@zptcorp.com>
Suggested-by: Dimitrios Palyvos-Giannas <dimitrios.palyvos@zptcorp.com>
Signed-off-by: Huan Nguyen <nhuhuan@google.com>
---
 fs/nfs/write.c                 |  2 +-
 include/linux/migrate.h        |  5 +++++
 include/linux/migrate_mode.h   |  1 +
 include/trace/events/migrate.h |  1 +
 mm/compaction.c                | 18 +++++++++---------
 mm/migrate.c                   | 29 ++++++++++++++++++-----------
 6 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0b42d31f7a75..ad28ff48e541 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -2128,7 +2128,7 @@ int nfs_migrate_folio(struct address_space *mapping, struct folio *dst,
 	}
 
 	if (folio_test_private_2(src)) { /* [DEPRECATED] */
-		if (mode == MIGRATE_ASYNC)
+		if (migrate_is_async(mode))
 			return -EBUSY;
 		folio_wait_private_2(src);
 	}
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 78424b3824c2..188f9d891a0a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -51,6 +51,11 @@ struct movable_operations {
 /* Defined in mm/debug.c: */
 extern const char *migrate_reason_names[MR_TYPES];
 
+static inline bool migrate_is_async(enum migrate_mode mode)
+{
+	return mode == MIGRATE_ASYNC || mode == MIGRATE_ASYNC_NONTEMPORAL;
+}
+
 #ifdef CONFIG_MIGRATION
 
 void putback_movable_pages(struct list_head *l);
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 05102d4d2490..fd752fddc972 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -12,6 +12,7 @@ enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
+	MIGRATE_ASYNC_NONTEMPORAL,
 };
 
 enum migrate_reason {
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index 15ee2ef201b5..0bb2444211af 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -9,6 +9,7 @@
 
 #define MIGRATE_MODE						\
 	EM( MIGRATE_ASYNC,	"MIGRATE_ASYNC")		\
+	EM( MIGRATE_ASYNC_NONTEMPORAL, "MIGRATE_ASYNC_NONTEMPORAL") \
 	EM( MIGRATE_SYNC_LIGHT,	"MIGRATE_SYNC_LIGHT")		\
 	EMe(MIGRATE_SYNC,	"MIGRATE_SYNC")
 
diff --git a/mm/compaction.c b/mm/compaction.c
index f1b2060eb201..c11739e6891f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -445,7 +445,7 @@ static void update_cached_migrate(struct compact_control *cc, unsigned long pfn)
 	/* Update where async and sync compaction should restart */
 	if (pfn > zone->compact_cached_migrate_pfn[0])
 		zone->compact_cached_migrate_pfn[0] = pfn;
-	if (cc->mode != MIGRATE_ASYNC &&
+	if (!migrate_is_async(cc->mode) &&
 	    pfn > zone->compact_cached_migrate_pfn[1])
 		zone->compact_cached_migrate_pfn[1] = pfn;
 }
@@ -508,7 +508,7 @@ static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
 	__acquires(lock)
 {
 	/* Track if the lock is contended in async mode */
-	if (cc->mode == MIGRATE_ASYNC && !cc->contended) {
+	if (migrate_is_async(cc->mode) && !cc->contended) {
 		if (spin_trylock_irqsave(lock, *flags))
 			return true;
 
@@ -882,7 +882,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			return -EAGAIN;
 
 		/* async migration should just abort */
-		if (cc->mode == MIGRATE_ASYNC)
+		if (migrate_is_async(cc->mode))
 			return -EAGAIN;
 
 		reclaim_throttle(pgdat, VMSCAN_THROTTLE_ISOLATED);
@@ -893,7 +893,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 	cond_resched();
 
-	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
+	if (cc->direct_compaction && migrate_is_async(cc->mode)) {
 		skip_on_failure = true;
 		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
 	}
@@ -1409,7 +1409,7 @@ static bool suitable_migration_source(struct compact_control *cc,
 	 * allocator fallbacks. For non-movable requests, this helps a
 	 * lot, as they can finally scan movable blocks.
 	 */
-	if (cc->mode != MIGRATE_ASYNC)
+	if (!migrate_is_async(cc->mode))
 		return true;
 
 	/*
@@ -1514,7 +1514,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn)
 		return;
 
 	/* Minimise scanning during async compaction */
-	if (cc->direct_compaction && cc->mode == MIGRATE_ASYNC)
+	if (cc->direct_compaction && migrate_is_async(cc->mode))
 		return;
 
 	/* Pageblock boundaries */
@@ -1753,7 +1753,7 @@ static void isolate_freepages(struct compact_control *cc)
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
 	low_pfn = pageblock_end_pfn(cc->migrate_pfn);
-	stride = cc->mode == MIGRATE_ASYNC ? COMPACT_CLUSTER_MAX : 1;
+	stride = migrate_is_async(cc->mode) ? COMPACT_CLUSTER_MAX : 1;
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -2565,7 +2565,7 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 	unsigned long start_pfn = cc->zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
-	const bool sync = cc->mode != MIGRATE_ASYNC;
+	const bool sync = !migrate_is_async(cc->mode);
 	bool update_cached;
 	unsigned int nr_succeeded = 0, nr_migratepages;
 	int order;
@@ -2588,7 +2588,7 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 		ret = compaction_suit_allocation_order(cc->zone, cc->order,
 						       cc->highest_zoneidx,
 						       cc->alloc_flags,
-						       cc->mode == MIGRATE_ASYNC,
+						       migrate_is_async(cc->mode),
 						       !cc->direct_compaction);
 		if (ret != COMPACT_CONTINUE)
 			return ret;
diff --git a/mm/migrate.c b/mm/migrate.c
index 7bdcdb57652f..18470de10857 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -876,9 +876,15 @@ static int __migrate_folio(struct address_space *mapping, struct folio *dst,
 	if (folio_ref_count(src) != expected_count)
 		return -EAGAIN;
 
-	rc = folio_mc_copy(dst, src);
-	if (unlikely(rc))
-		return rc;
+	if (mode == MIGRATE_ASYNC_NONTEMPORAL) {
+		rc = folio_mc_copy_nt(dst, src);
+		if (unlikely(rc))
+			return rc;
+	} else {
+		rc = folio_mc_copy(dst, src);
+		if (unlikely(rc))
+			return rc;
+	}
 
 	rc = __folio_migrate_mapping(mapping, dst, src, expected_count);
 	if (rc)
@@ -921,7 +927,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 
 	do {
 		if (!trylock_buffer(bh)) {
-			if (mode == MIGRATE_ASYNC)
+			if (migrate_is_async(mode))
 				goto unlock;
 			if (mode == MIGRATE_SYNC_LIGHT && !buffer_uptodate(bh))
 				goto unlock;
@@ -1229,7 +1235,7 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 	dst->migrate_info = 0;
 
 	if (!folio_trylock(src)) {
-		if (mode == MIGRATE_ASYNC)
+		if (migrate_is_async(mode))
 			goto out;
 
 		/*
@@ -1334,7 +1340,7 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 		/* Establish migration ptes */
 		VM_BUG_ON_FOLIO(folio_test_anon(src) &&
 			       !folio_test_ksm(src) && !anon_vma, src);
-		try_to_migrate(src, mode == MIGRATE_ASYNC ? TTU_BATCH_FLUSH : 0);
+		try_to_migrate(src, migrate_is_async(mode) ? TTU_BATCH_FLUSH : 0);
 		old_folio_state |= FOLIO_WAS_MAPPED;
 	}
 
@@ -1592,7 +1598,7 @@ static inline int try_split_folio(struct folio *folio, struct list_head *split_f
 {
 	int rc;
 
-	if (mode == MIGRATE_ASYNC) {
+	if (migrate_is_async(mode)) {
 		if (!folio_trylock(folio))
 			return -EAGAIN;
 	} else {
@@ -1826,7 +1832,7 @@ static int migrate_pages_batch(struct list_head *from,
 	LIST_HEAD(dst_folios);
 	bool nosplit = (reason == MR_NUMA_MISPLACED);
 
-	VM_WARN_ON_ONCE(mode != MIGRATE_ASYNC &&
+	VM_WARN_ON_ONCE(!migrate_is_async(mode) &&
 			!list_empty(from) && !list_is_singular(from));
 
 	for (pass = 0; pass < nr_pass && retry; pass++) {
@@ -2134,7 +2140,7 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 		list_cut_before(&folios, from, &folio2->lru);
 	else
 		list_splice_init(from, &folios);
-	if (mode == MIGRATE_ASYNC)
+	if (migrate_is_async(mode))
 		rc = migrate_pages_batch(&folios, get_new_folio, put_new_folio,
 				private, mode, reason, &ret_folios,
 				&split_folios, &stats,
@@ -2156,8 +2162,9 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 		 * with minimal effort, force MIGRATE_ASYNC mode and retry once.
 		 */
 		migrate_pages_batch(&split_folios, get_new_folio,
-				put_new_folio, private, MIGRATE_ASYNC, reason,
-				&ret_folios, NULL, &stats, 1);
+				put_new_folio, private,
+				migrate_is_async(mode) ? mode : MIGRATE_ASYNC,
+				reason, &ret_folios, NULL, &stats, 1);
 		list_splice_tail_init(&split_folios, &ret_folios);
 	}
 	rc_gather += rc;
-- 
2.56.0.398.g882cbad275-goog

