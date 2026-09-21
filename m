Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD1E7405F7;
	Mon, 21 Sep 2026 04:09:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789963745; cv=none; b=t8fJXUq0Xvim3UhbfICjHvCyzilxMzi2UVE49JU+G9vfOGGH42oFyVK+T5E3KPYZ/nuI9g/TdCZoK5NnGiujze64rAjnblikQ2ETBxvmFneuzlQotkOcFeeOiAFj11f4mlzdqTuA6hZAdkSamJhEsLX8f3OPIxexjp9GYyuoYUU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789963745; c=relaxed/simple;
	bh=jiFSmehS/aLx34tFQmus2QM3ICkWqUWOkBZm3R49EqE=;
	h=Date:From:To:Cc:Subject:Message-Id:In-Reply-To:References:
	 Mime-Version:Content-Type; b=ibV5/iO1RzN808fpcHlhzi0CB/e19UhYyf7OblbCIUrA64Q9Zp9WJcv/rh0cps5BFtc+N2YXI4YheN2Hz+oPpz+adK2SBa9t+fF6vltQ+deNjl0ycZV4H0/B0PSPnr3mqWwUH+JW1+cN8h9gr2hKTIOSg0hdvSgzOTfekYAmH7Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=fgqpk7b6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="fgqpk7b6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 63C301F000FF;
	Mon, 21 Sep 2026 04:09:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux-foundation.org; s=korg; t=1789963743;
	bh=LZ736WQSm180sbvHtkV3uFqBg4iSSs3xixQmjdddUBk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=fgqpk7b6eCfprR7zmZiJy9qBQZJsbM5f8s3hI8e6nM8wYRmEU0CAVWtHGL4kzcQi0
	 wEjzAZst11LRJ9q6W6kXCFZAXji7jeST+bAFloveBQOKkO+TvLOqlAUkcR9HD/Se9Q
	 iZwtpMlXm4chDCNpRM7SRsEPxwlhnoNITtr0Iqy0=
Date: Sun, 20 Sep 2026 21:08:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Zi Yan <ziy@nvidia.com>
Cc: David Hildenbrand <david@kernel.org>, "Matthew Wilcox (Oracle)"
 <willy@infradead.org>, Muchun Song <muchun.song@linux.dev>, Lorenzo Stoakes
 <ljs@kernel.org>, "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka
 <vbabka@kernel.org>, Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan
 <surenb@google.com>, Michal Hocko <mhocko@suse.com>, Baolin Wang
 <baolin.wang@linux.alibaba.com>, Nico Pache <nico.pache@linux.dev>, Ryan
 Roberts <ryan.roberts@arm.com>, Dev Jain <dev.jain@arm.com>, Barry Song
 <baohua@kernel.org>, Lance Yang <lance.yang@linux.dev>, Usama Arif
 <usama.arif@linux.dev>, Gregory Price <gourry@gourry.net>, Ying Huang
 <ying.huang@linux.alibaba.com>, Alistair Popple <apopple@nvidia.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Qi Zheng <qi.zheng@linux.dev>,
 Shakeel Butt <shakeel.butt@linux.dev>, Kairui Song <kasong@tencent.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim
 <minchan@kernel.org>, Sergey Senozhatsky <senozhatsky@chromium.org>, Peter
 Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo
 Carvalho de Melo <acme@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
 Thomas Gleixner <tglx@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave
 Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Mark Rutland
 <mark.rutland@arm.com>, Alexander Shishkin
 <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@kernel.org>, Ian
 Rogers <irogers@google.com>, Adrian Hunter <adrian.hunter@intel.com>, James
 Clark <james.clark@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>,
 linux-perf-users@vger.kernel.org, Juergen Gross <jgross@suse.com>, Stefano
 Stabellini <sstabellini@kernel.org>, Oleksandr Tyshchenko
 <oleksandr_tyshchenko@epam.com>, xen-devel@lists.xenproject.org, Eric
 Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk
 Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Oscar Salvador
 <osalvador@suse.de>, Chao Yu <chao@kernel.org>,
 linux-f2fs-devel@lists.sourceforge.net, Tal Zussman <tz2294@columbia.edu>,
 Gao Xiang <xiang@kernel.org>, Jan Kara <jack@suse.cz>, Yue Hu
 <zbestahu@gmail.com>, Jeffle Xu <jefflexu@linux.alibaba.com>, Sandeep
 Dhavale <dhavale@google.com>, Hongbo Li <hongbohbli@tencent.com>, Chunhai
 Guo <guochunhai@vivo.com>, linux-erofs@lists.ozlabs.org,
 linux-fsdevel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Masami
 Hiramatsu <mhiramat@kernel.org>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Matthew Brost <matthew.brost@intel.com>,
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>,
 Byungchul Park <byungchul@sk.com>, Axel Rasmussen
 <axelrasmussen@google.com>, Yuanchu Xie <yuanchu@google.com>, Wei Xu
 <weixugc@google.com>, linux-trace-kernel@vger.kernel.org, Trond Myklebust
 <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, Alex Markuze
 <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>,
 ceph-devel@vger.kernel.org, Richard Weinberger <richard@nod.at>, Zhihao
 Cheng <chengzhihao1@huawei.com>, linux-mtd@lists.infradead.org, Baoquan He
 <baoquan.he@linux.dev>, Pasha Tatashin <pasha.tatashin@soleen.com>,
 Pratyush Yadav <pratyush@kernel.org>, Jonathan Corbet <corbet@lwn.net>,
 Dave Young <ruirui.yang@linux.dev>, Shuah Khan <skhan@linuxfoundation.org>,
 kexec@lists.infradead.org, linux-doc@vger.kernel.org
Subject: Re: [PATCH v5 00/17] Remove PG_private by using page/folio->private
 checks instead
Message-Id: <20260920210859.a0f75483dc4a12202c8b9516@linux-foundation.org>
In-Reply-To: <20260920-remove-pg_private-v5-0-bb68b6a21869@nvidia.com>
References: <20260920-remove-pg_private-v5-0-bb68b6a21869@nvidia.com>
X-Mailer: Sylpheed 3.8.0beta1 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Sun, 20 Sep 2026 22:27:56 -0400 Zi Yan <ziy@nvidia.com> wrote:

> Hi all,
> 
> This patchset removes PG_private to make space for upcoming PG_folio for
> identifying pages from a folio (more details in Note below). Instead of
> checking PG_private, all code is changed to check page/folio->private !=
> NULL instead.

Thanks, I updated mm-unstable to this version.

> Changes in v5:
> 1. replaced md patches (patch 13 and 14 in v4) with Matthew Wilcox's
>    version (see Matthew's replies to v4).
> 2. used data_race() inside folio_test_private() and PagePrivate(), so that
>    the new versions can be used without KCSAN warnings while not holding
>    folio lock like before.
> 3. moved folio_has_attached_private() implementation detail comment next to
>    the code.

Here's how v5 altered mm.git:


 drivers/md/md-bitmap.c         |   17 ++++++++---------
 fs/buffer.c                    |    8 --------
 include/linux/buffer_head.h    |    2 +-
 include/linux/mm.h             |    3 +--
 include/linux/page-flags.h     |   30 +++++++++++++++++++-----------
 include/trace/events/pagemap.h |    3 +--
 mm/huge_memory.c               |    3 +--
 mm/page-writeback.c            |    3 +--
 8 files changed, 32 insertions(+), 37 deletions(-)

--- a/drivers/md/md-bitmap.c~b
+++ a/drivers/md/md-bitmap.c
@@ -516,7 +516,8 @@ static void end_bitmap_write(struct bio
 
 static void write_file_page(struct bitmap *bitmap, struct page *page, int wait)
 {
-	struct buffer_head *bh = (struct buffer_head *)page_private(page);
+	struct folio *folio = page_folio(page);
+	struct buffer_head *bh = folio_buffers(folio);
 
 	while (bh && bh->b_blocknr) {
 		atomic_inc(&bitmap->pending_writes);
@@ -533,18 +534,15 @@ static void write_file_page(struct bitma
 
 static void free_buffers(struct page *page)
 {
-	struct buffer_head *bh = (struct buffer_head *)page_private(page);
-
-	if (!bh)
-		return;
+	struct folio *folio = page_folio(page);
+	struct buffer_head *bh = folio_detach_private(folio);
 
 	while (bh) {
 		struct buffer_head *next = bh->b_this_page;
 		free_buffer_head(bh);
 		bh = next;
 	}
-	detach_page_private(page);
-	put_page(page);
+	folio_put(folio);
 }
 
 /* read a page from a file.
@@ -559,6 +557,7 @@ static int read_file_page(struct file *f
 {
 	int ret = 0;
 	struct inode *inode = file_inode(file);
+	struct folio *folio = page_folio(page);
 	struct buffer_head *bh;
 	sector_t block, blk_cur;
 	unsigned long blocksize = i_blocksize(inode);
@@ -566,12 +565,12 @@ static int read_file_page(struct file *f
 	pr_debug("read bitmap file (%dB @ %llu)\n", (int)PAGE_SIZE,
 		 (unsigned long long)index << PAGE_SHIFT);
 
-	bh = alloc_page_buffers(page, blocksize);
+	bh = folio_alloc_buffers(folio, blocksize, GFP_NOFS | __GFP_ACCOUNT);
 	if (!bh) {
 		ret = -ENOMEM;
 		goto out;
 	}
-	attach_page_private(page, bh);
+	folio_attach_private(folio, bh);
 	blk_cur = index << (PAGE_SHIFT - inode->i_blkbits);
 	while (bh) {
 		block = blk_cur;
--- a/fs/buffer.c~b
+++ a/fs/buffer.c
@@ -773,14 +773,6 @@ no_grow:
 }
 EXPORT_SYMBOL_GPL(folio_alloc_buffers);
 
-struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size)
-{
-	gfp_t gfp = GFP_NOFS | __GFP_ACCOUNT;
-
-	return folio_alloc_buffers(page_folio(page), size, gfp);
-}
-EXPORT_SYMBOL_GPL(alloc_page_buffers);
-
 static inline void link_dev_buffers(struct folio *folio,
 		struct buffer_head *head)
 {
--- a/include/linux/buffer_head.h~b
+++ a/include/linux/buffer_head.h
@@ -175,6 +175,7 @@ static inline unsigned long bh_offset(co
 	return (unsigned long)(bh)->b_data & (page_size(bh->b_page) - 1);
 }
 
+/* If we *know* folio->private refers to buffer_heads */
 #define folio_buffers(folio)		folio_get_private(folio)
 
 void buffer_check_dirty_writeback(struct folio *folio,
@@ -191,7 +192,6 @@ void folio_set_bh(struct buffer_head *bh
 		  unsigned long offset);
 struct buffer_head *folio_alloc_buffers(struct folio *folio, unsigned long size,
 					gfp_t gfp);
-struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size);
 struct buffer_head *create_empty_buffers(struct folio *folio,
 		unsigned long blocksize, unsigned long b_state);
 void end_buffer_read_sync(struct buffer_head *bh, int uptodate);
--- a/include/linux/mm.h~b
+++ a/include/linux/mm.h
@@ -3052,9 +3052,8 @@ static inline int folio_expected_ref_cou
 		ref_count += !!data_race(folio->mapping) << order;
 		/*
 		 * One reference from filesystem private data.
-		 * Use data_race() since folio might not be locked.
 		 */
-		ref_count += data_race(folio_has_attached_private(folio));
+		ref_count += folio_has_attached_private(folio);
 	}
 
 	/* One reference per page table mapping. */
--- a/include/linux/page-flags.h~b
+++ a/include/linux/page-flags.h
@@ -576,7 +576,12 @@ FOLIO_FLAG(swapbacked, FOLIO_HEAD_PAGE)
 
 static __always_inline bool folio_test_private(const struct folio *folio)
 {
-	return folio->private;
+	/*
+	 * data_race() is added for readers without holding the folio lock.
+	 * Only the NULL/non-NULL answer is used and both are valid while
+	 * private is being attached or detached, so the race is benign.
+	 */
+	return data_race(folio->private);
 }
 
 FOLIO_FLAG(private_2, FOLIO_HEAD_PAGE)
@@ -1199,20 +1204,23 @@ static __always_inline void __ClearPageA
  * @folio: The folio to check.
  *
  * Use this in code that may encounter swapcache or hugetlb folios but only
- * wants to detect attached private data. Swapcache stores swp_entry_t in
- * folio->swap, a union with folio->private, and hugetlb stores its own flags
- * in folio->private; both are excluded.
- *
- * NOTE: For swapcache, folio->swap.val PG_swapcache are not set as a whole,
- * so folio_test_swapcache() is not reliable to exclude swapcache.
- * Use folio_test_swapbacked() instead, since it remains set when a folio is
- * added to/removed from swapcache.
+ * wants to detect attached private data.
  *
- * Return: true if folio->private is set and the folio is neither swapcache
- * nor hugetlb.
+ * Return: true if the folio has private data attached.
  */
 static inline bool folio_has_attached_private(const struct folio *folio)
 {
+	/*
+	 * Swapcache stores swp_entry_t in folio->swap, a union with
+	 * folio->private, and hugetlb stores its own flags in folio->private;
+	 * both are excluded.
+	 *
+	 * NOTE: For swapcache, folio->swap.val PG_swapcache are not set as
+	 * a whole, so folio_test_swapcache() is not reliable to exclude
+	 * swapcache. Use folio_test_swapbacked() instead, since it remains set
+	 * when a folio is added to/removed from swapcache.
+	 */
+
 	return folio_test_private(folio) && !folio_test_swapbacked(folio) &&
 	       !folio_test_hugetlb(folio);
 }
--- a/include/trace/events/pagemap.h~b
+++ a/include/trace/events/pagemap.h
@@ -22,8 +22,7 @@
 	(folio_test_swapcache(folio)	? PAGEMAP_SWAPCACHE  : 0) | \
 	(folio_test_swapbacked(folio)	? PAGEMAP_SWAPBACKED : 0) | \
 	(folio_test_mappedtodisk(folio)	? PAGEMAP_MAPPEDDISK : 0) | \
-	/* data_race() is used to read attached private locklessly */ \
-	(data_race(folio_has_attached_private(folio))	? PAGEMAP_BUFFERS    : 0) \
+	(folio_has_attached_private(folio)	? PAGEMAP_BUFFERS    : 0) \
 	)
 
 TRACE_EVENT(mm_lru_insertion,
--- a/mm/huge_memory.c~b
+++ a/mm/huge_memory.c
@@ -4845,9 +4845,8 @@ static int split_huge_pages_pid(int pid,
 		 * For folios with private, split_huge_page_to_list_to_order()
 		 * will try to drop it before split and then check if the folio
 		 * can be split or not. So skip the check here.
-		 * data_race() is used to read attached private locklessly.
 		 */
-		if (!data_race(folio_has_attached_private(folio)) &&
+		if (!folio_has_attached_private(folio) &&
 		    folio_expected_ref_count(folio) != folio_ref_count(folio))
 			goto next;
 
--- a/mm/page-writeback.c~b
+++ a/mm/page-writeback.c
@@ -2705,8 +2705,7 @@ bool filemap_dirty_folio(struct address_
 	if (folio_test_set_dirty(folio))
 		return false;
 
-	/* data_race() is used to read attached private locklessly */
-	__folio_mark_dirty(folio, mapping, !data_race(folio_has_attached_private(folio)));
+	__folio_mark_dirty(folio, mapping, !folio_has_attached_private(folio));
 
 	if (mapping->host) {
 		/* !PageAnon && !swapper_space */
_

