Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com [209.85.218.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8502407597
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 15:03:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785423809; cv=none; b=JBe4JfWBxkRU5EHO2vOabwmNH9ycXSSgq3pD6Pr2Uj8iSzIY4rpHMwoLbcBZVOt26B8Lbsg5giM9MAW9yHGR9dulC2QvDYrqkLs+UMynJU/cy4H5fo571v+CfB4cdwVItF26atnpE4je837+K4FO1In8oTWLXNU1BlreakgDMZ4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785423809; c=relaxed/simple;
	bh=YkONpgjarkoyetvAWGsRSwGxKORs8lGBbP3iuK2k+jI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Vnq66RuhNF3lX0iguSoU5Gm/gRc7iorLDabVCbNr85ZDsW8kcmhrpVR9PNYMp0tM7ouN05qjS/EGjrsM+c52oVD5leTyLdhWz1XIJCzm3KUvRLF/K/U13v928ArThObB1k1nnOxyNpUmT2KHZdh4Srlf7aeal1+S4IqYD0XtNxU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=cO8M5QRu; arc=none smtp.client-ip=209.85.218.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cO8M5QRu"
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-c15cf78d1a2so274186266b.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 08:03:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785423806; x=1786028606; darn=vger.kernel.org;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4YrtHMEYPI1tjDQiF/FNeUbCwB0JCeO1sQzq3zX3f00=;
        b=cO8M5QRu+q2DFDsZVmc3dQebQjmTX/DT4tkxiRAB95wysc9lgXswKjTpcMquE0HipM
         DQNpWHTBrbvwrra9iTPENZDemX+VWToafXnjyAVJhCeEv5JEcROHGretoeYCZnkQyVPd
         B6+Awp6MKZ75ymLz1pIkH7S1wIHELCTbd8Esj6zmJgKiY85rg7Fb4J0lZ2N6aXPAxvYv
         ub4sN2i7yhIeDdSurTV8NWEyhqnEx05R8dLxjjy/kcIfkjtPfrNOPGaUPiSCkTu4Kzuu
         qW9TSEDlbVnJxbTjlzvsyYbcVTNbGAtHHl5bW5qmx7NAcS3PVlHFj2/mYC4hNMx+U1Yv
         6l/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785423806; x=1786028606;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=4YrtHMEYPI1tjDQiF/FNeUbCwB0JCeO1sQzq3zX3f00=;
        b=hGlCDrGYuTklHZsR380gCFDFMxUNJ//8nUsEgo2F5cMs06O4l5yimTRB2K4wowl37C
         Vodr/pDR3ma637Ym+7szqVMWNh00MziO0hH0c9yLHrwhK6pyR5duNkQpeLSILAzXkb69
         fuEmniH7GJlGf71dpQ09gPi1Y8h9GP53XF0mEZz1mmJiciH++dYR2RlxZNQDZnVjMVXy
         cY3/h67RDAosWVs08awVUF2Xnt/qxyD9k+CRMzFNU5ostLLL1uWKAXmKawlOBgrwATZo
         s9ncs5Z/I6v0s7OW7mflIzHUuiu3mjJL/AOfsYRMC5OStFUfFu4Co3OxLWPonR8U1WYo
         sZDw==
X-Forwarded-Encrypted: i=1; AHgh+Rrh3nn8TM5iRjRpKJ/0Y05QcgRPkS0+ELAa4kzolRrsOKEJXWTu+XMMyRsXO+D7CZ6IcYxenKyPbAI=@vger.kernel.org
X-Gm-Message-State: AOJu0YxpPVOSqqThAADsEvvdBagcTg6YsoMJZ0ixaAdODceDP0SktdMZ
	jTvHbDy6EgR0pXGoxeiJt0iZssastj2ui/QZTdXiRwMZ33Nq9Ac8HB5f
X-Gm-Gg: AR+sD11WQvMX42ioHp54qxtvWoYS2JFBZJegBzckBLnk6J1fqWBYAItf3cJEZB8/pM4
	6L9rqYN/7Fk//b4iFUP9FGM8V8NHXAqQpdcDkirfGWszegUSvmFM8eKE8fR1xqNtbRjNel7gwfd
	Kfwx15BajsxtJd3IgX7v5vKOlAUmQ5yzQ8UsQn4fUpae/sYKdrMZqEoVKtXgEPaIIxmAxG/qBhF
	tSZkAm36gHzeaBWrIFPYysek2ypJbV1hz/XeZ5NS/jUPqggjFzg9Fwj70K4+4ScOWEr4cRGHnaa
	u7D7PQMSe4oUYkOH+rQp/CofEtbT9PZUREkRpdOi7BnP6jNFDB+K8gIcWVq0+vpSu3ds+b0pf4/
	BdIL42PRwKCHdCAxulONirxkbJ1G9hDOqotsBwIhJ/+4XH41okR/G/xETHl58lcCLuauxr1HsGo
	G+1bTsO0PpvfBxhBg237wFDDbvTV8lq8VkY3uzZ9HLb4JHNThA388glpaP8tMecX9L2OVyp75Nb
	B2PHAT9fQm80y59OHe9PRLZwr4TG/5qWg==
X-Received: by 2002:a17:907:3c83:b0:c17:cf99:6154 with SMTP id a640c23a62f3a-c1fa55db339mr152575066b.16.1785423805407;
        Thu, 30 Jul 2026 08:03:25 -0700 (PDT)
Received: from [127.0.1.1] (h-62-63-197-109.NA.cust.bahnhof.se. [62.63.197.109])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6a07bf18ff8sm729116a12.0.2026.07.30.08.03.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 30 Jul 2026 08:03:24 -0700 (PDT)
From: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Date: Thu, 30 Jul 2026 17:02:58 +0200
Subject: [PATCH RFC v2 2/3] mm: new migrate_mode flag for async using
 non-temporal stores
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260730-rfc-nt-demote-v2-2-452dbe3b5073@zptcorp.com>
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
In-Reply-To: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
To: Thomas Gleixner <tglx@kernel.org>, Ingo Molnar <mingo@redhat.com>, 
 Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 David Hildenbrand <david@kernel.org>, 
 Lorenzo Stoakes <lorenzo.stoakes@oracle.com>, 
 "Liam R. Howlett" <Liam.Howlett@oracle.com>, 
 Vlastimil Babka <vbabka@kernel.org>, Mike Rapoport <rppt@kernel.org>, 
 Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Zi Yan <ziy@nvidia.com>, Matthew Brost <matthew.brost@intel.com>, 
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, 
 Byungchul Park <byungchul@sk.com>, Gregory Price <gourry@gourry.net>, 
 Ying Huang <ying.huang@linux.alibaba.com>, 
 Alistair Popple <apopple@nvidia.com>, Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Brendan Jackman <jackmanb@google.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, 
 Davidlohr Bueso <dave@stgolabs.net>, Fan Ni <nifan.cxl@gmail.com>, 
 Frank van der Linden <fvdl@google.com>, Jonathan Cameron <jic23@kernel.org>, 
 Raghavendra K T <rkodsara@amd.com>, 
 "Rao, Bharata Bhasker" <bharata@amd.com>, SeongJae Park <sj@kernel.org>, 
 Wei Xu <weixugc@google.com>, Xuezheng Chu <xuezhengchu@huawei.com>, 
 Yiannis Nikolakopoulos <yiannis@zptcorp.com>, dimitrios@palyvos.net, 
 Ryan Roberts <ryan.roberts@arm.com>, Huan Nguyen <nhuhuan@google.com>, 
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, 
 linux-trace-kernel@vger.kernel.org, 
 Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>, 
 Alirad Malek <alirad.malek@zptcorp.com>
X-Mailer: b4 0.15.2

From: Alirad Malek <alirad.malek@zptcorp.com>

In preparation for the following patch, add a new migrate_mode which is
still async but will use non-temporal stores. Add a helper function
that checks for both async modes and replace all plain checks of
MIGRATE_ASYNC.

Signed-off-by: Alirad Malek <alirad.malek@zptcorp.com>
Co-developed-by: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Signed-off-by: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
---
 fs/nfs/write.c                 |  2 +-
 include/linux/migrate_mode.h   |  9 +++++++++
 include/trace/events/migrate.h |  1 +
 mm/compaction.c                | 18 +++++++++---------
 mm/migrate.c                   | 12 ++++++------
 5 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1ed4b3590b1a..beae4441e080 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -2119,7 +2119,7 @@ int nfs_migrate_folio(struct address_space *mapping, struct folio *dst,
 	}
 
 	if (folio_test_private_2(src)) { /* [DEPRECATED] */
-		if (mode == MIGRATE_ASYNC)
+		if (migrate_mode_is_async(mode))
 			return -EBUSY;
 		folio_wait_private_2(src);
 	}
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 265c4328b36a..f7186e705b48 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -3,6 +3,8 @@
 #define MIGRATE_MODE_H_INCLUDED
 /*
  * MIGRATE_ASYNC means never block
+ * MIGRATE_ASYNC_NON_TEMPORAL_STORES means never block and use non-temporal
+ * stores if supported by the architecture
  * MIGRATE_SYNC_LIGHT in the current implementation means to allow blocking
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
@@ -10,10 +12,17 @@
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
+	MIGRATE_ASYNC_NON_TEMPORAL_STORES,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
 };
 
+static inline bool migrate_mode_is_async(enum migrate_mode mode)
+{
+	return mode == MIGRATE_ASYNC ||
+		mode == MIGRATE_ASYNC_NON_TEMPORAL_STORES;
+}
+
 enum migrate_reason {
 	MR_COMPACTION,
 	MR_MEMORY_FAILURE,
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index cd01dd7b3640..e493207a3f46 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -9,6 +9,7 @@
 
 #define MIGRATE_MODE						\
 	EM( MIGRATE_ASYNC,	"MIGRATE_ASYNC")		\
+	EM(MIGRATE_ASYNC_NON_TEMPORAL_STORES,		"MIGRATE_ASYNC_NON_TEMPORAL_STORES")	\
 	EM( MIGRATE_SYNC_LIGHT,	"MIGRATE_SYNC_LIGHT")		\
 	EMe(MIGRATE_SYNC,	"MIGRATE_SYNC")
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 1e8f8eca318c..cd26781b7376 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -444,7 +444,7 @@ static void update_cached_migrate(struct compact_control *cc, unsigned long pfn)
 	/* Update where async and sync compaction should restart */
 	if (pfn > zone->compact_cached_migrate_pfn[0])
 		zone->compact_cached_migrate_pfn[0] = pfn;
-	if (cc->mode != MIGRATE_ASYNC &&
+	if (!migrate_mode_is_async(cc->mode) &&
 	    pfn > zone->compact_cached_migrate_pfn[1])
 		zone->compact_cached_migrate_pfn[1] = pfn;
 }
@@ -507,7 +507,7 @@ static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
 	__acquires(lock)
 {
 	/* Track if the lock is contended in async mode */
-	if (cc->mode == MIGRATE_ASYNC && !cc->contended) {
+	if (migrate_mode_is_async(cc->mode) && !cc->contended) {
 		if (spin_trylock_irqsave(lock, *flags))
 			return true;
 
@@ -864,7 +864,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			return -EAGAIN;
 
 		/* async migration should just abort */
-		if (cc->mode == MIGRATE_ASYNC)
+		if (migrate_mode_is_async(cc->mode))
 			return -EAGAIN;
 
 		reclaim_throttle(pgdat, VMSCAN_THROTTLE_ISOLATED);
@@ -875,7 +875,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 	cond_resched();
 
-	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
+	if (cc->direct_compaction && migrate_mode_is_async(cc->mode)) {
 		skip_on_failure = true;
 		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
 	}
@@ -1364,7 +1364,7 @@ static bool suitable_migration_source(struct compact_control *cc,
 	if (pageblock_skip_persistent(page))
 		return false;
 
-	if ((cc->mode != MIGRATE_ASYNC) || !cc->direct_compaction)
+	if (!migrate_mode_is_async(cc->mode) || !cc->direct_compaction)
 		return true;
 
 	block_mt = get_pageblock_migratetype(page);
@@ -1465,7 +1465,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn)
 		return;
 
 	/* Minimise scanning during async compaction */
-	if (cc->direct_compaction && cc->mode == MIGRATE_ASYNC)
+	if (cc->direct_compaction && migrate_mode_is_async(cc->mode))
 		return;
 
 	/* Pageblock boundaries */
@@ -1705,7 +1705,7 @@ static void isolate_freepages(struct compact_control *cc)
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
 	low_pfn = pageblock_end_pfn(cc->migrate_pfn);
-	stride = cc->mode == MIGRATE_ASYNC ? COMPACT_CLUSTER_MAX : 1;
+	stride = migrate_mode_is_async(cc->mode) ? COMPACT_CLUSTER_MAX : 1;
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -2514,7 +2514,7 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 	unsigned long start_pfn = cc->zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
-	const bool sync = cc->mode != MIGRATE_ASYNC;
+	const bool sync = !migrate_mode_is_async(cc->mode);
 	bool update_cached;
 	unsigned int nr_succeeded = 0, nr_migratepages;
 	int order;
@@ -2537,7 +2537,7 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 		ret = compaction_suit_allocation_order(cc->zone, cc->order,
 						       cc->highest_zoneidx,
 						       cc->alloc_flags,
-						       cc->mode == MIGRATE_ASYNC,
+						       migrate_mode_is_async(cc->mode),
 						       !cc->direct_compaction);
 		if (ret != COMPACT_CONTINUE)
 			return ret;
diff --git a/mm/migrate.c b/mm/migrate.c
index 2c3d489ecf51..ff6cf50e7b0b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -907,7 +907,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 
 	do {
 		if (!trylock_buffer(bh)) {
-			if (mode == MIGRATE_ASYNC)
+			if (migrate_mode_is_async(mode))
 				goto unlock;
 			if (mode == MIGRATE_SYNC_LIGHT && !buffer_uptodate(bh))
 				goto unlock;
@@ -1220,7 +1220,7 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 	dst->private = NULL;
 
 	if (!folio_trylock(src)) {
-		if (mode == MIGRATE_ASYNC)
+		if (migrate_mode_is_async(mode))
 			goto out;
 
 		/*
@@ -1325,7 +1325,7 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 		/* Establish migration ptes */
 		VM_BUG_ON_FOLIO(folio_test_anon(src) &&
 			       !folio_test_ksm(src) && !anon_vma, src);
-		try_to_migrate(src, mode == MIGRATE_ASYNC ? TTU_BATCH_FLUSH : 0);
+		try_to_migrate(src, migrate_mode_is_async(mode) ? TTU_BATCH_FLUSH : 0);
 		old_page_state |= PAGE_WAS_MAPPED;
 	}
 
@@ -1565,7 +1565,7 @@ static inline int try_split_folio(struct folio *folio, struct list_head *split_f
 {
 	int rc;
 
-	if (mode == MIGRATE_ASYNC) {
+	if (migrate_mode_is_async(mode)) {
 		if (!folio_trylock(folio))
 			return -EAGAIN;
 	} else {
@@ -1799,7 +1799,7 @@ static int migrate_pages_batch(struct list_head *from,
 	LIST_HEAD(dst_folios);
 	bool nosplit = (reason == MR_NUMA_MISPLACED);
 
-	VM_WARN_ON_ONCE(mode != MIGRATE_ASYNC &&
+	VM_WARN_ON_ONCE(!migrate_mode_is_async(mode) &&
 			!list_empty(from) && !list_is_singular(from));
 
 	for (pass = 0; pass < nr_pass && retry; pass++) {
@@ -2107,7 +2107,7 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 		list_cut_before(&folios, from, &folio2->lru);
 	else
 		list_splice_init(from, &folios);
-	if (mode == MIGRATE_ASYNC)
+	if (migrate_mode_is_async(mode))
 		rc = migrate_pages_batch(&folios, get_new_folio, put_new_folio,
 				private, mode, reason, &ret_folios,
 				&split_folios, &stats,

-- 
2.43.0

