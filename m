Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B24851AEC1
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:35:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790678185; cv=none; b=ESHSB+HoWRBTqbXuaKeDbndq82zSN2MyZkBPg5JxXMA8WIPVZ0iYD7psWymGU5JgRTzsFwMGoAA+VdmME3Tj1hUh7To0I80/8i0rY/DY4bJ2TdDbqH3i9d7Eq7FamXlY4HVkDRQCRbKbdLRSr7VQCsSfOvFwIZkA1h/yTRmMLP0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790678185; c=relaxed/simple;
	bh=zJR1ng4fC/ozAHALzH1L5gebH4t6F5Q2i2EVY3e5sgw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Jn30DMQKPRgFQ6L6/6AI1V7V/cOrOqjy0KL9g/5DmQ2GZSHFM6ggGhfZ9fKIrZ/sfhF2NqGJlbqjyYyyjrk7xPNt8TV9XmehMPrric3AEizBMikPatnUGItuUVuA9K2/G93KLEP5uyAP2gYuMJ4MCKelj2j3BLKapG7BR4xZVrM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=R0mWceG3; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="R0mWceG3"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790678147;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DrkIJfR0EuqlvPbiC0igcPb9UEvgB3/iIFF25DT7iWg=;
	b=R0mWceG3C+cXuGB2v9+w26RrPnGEbkOyMeSwCgr+5htim9jspV3RzCoT3QtAy7vdlWuAls
	voAfEeCEBISK3zFPRU/hb7r4gptb204zcc5yzfpcxNh/gx71NnN+qm16LWfAG1iFL6clni
	7VSxlLuu8/t6flp9zbKJiliCwPQgF0U=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-185-AOi1tP0ZNpy6AnEoPTyMnA-1; Tue,
 29 Sep 2026 06:35:40 -0400
X-MC-Unique: AOi1tP0ZNpy6AnEoPTyMnA-1
X-Mimecast-MFC-AGG-ID: AOi1tP0ZNpy6AnEoPTyMnA_1790678138
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 68DF21955BCD;
	Tue, 29 Sep 2026 10:35:38 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 3006E1956095;
	Tue, 29 Sep 2026 10:35:32 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v13 10/10] netfs: Remove folio_queue
Date: Tue, 29 Sep 2026 11:34:10 +0100
Message-ID: <20260929103412.2807494-11-dhowells@redhat.com>
In-Reply-To: <20260929103412.2807494-1-dhowells@redhat.com>
References: <20260929103412.2807494-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Remove folio_queue as it's no longer used.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 Documentation/core-api/folio_queue.rst      | 209 ---------------
 Documentation/core-api/index.rst            |   1 -
 Documentation/filesystems/netfs_library.rst |   2 +-
 fs/netfs/internal.h                         |   5 -
 fs/netfs/main.c                             |   7 -
 fs/netfs/misc.c                             |  96 -------
 fs/netfs/rolling_buffer.c                   |  46 ----
 fs/netfs/stats.c                            |   4 +-
 include/linux/folio_queue.h                 | 282 --------------------
 include/linux/netfs.h                       |  13 -
 include/trace/events/netfs.h                |  33 ---
 kernel/bpf/btf.c                            |   2 -
 12 files changed, 2 insertions(+), 698 deletions(-)
 delete mode 100644 Documentation/core-api/folio_queue.rst
 delete mode 100644 include/linux/folio_queue.h

diff --git a/Documentation/core-api/folio_queue.rst b/Documentation/core-api/folio_queue.rst
deleted file mode 100644
index b7628896d2b6..000000000000
--- a/Documentation/core-api/folio_queue.rst
+++ /dev/null
@@ -1,209 +0,0 @@
-.. SPDX-License-Identifier: GPL-2.0+
-
-===========
-Folio Queue
-===========
-
-:Author: David Howells <dhowells@redhat.com>
-
-.. Contents:
-
- * Overview
- * Initialisation
- * Adding and removing folios
- * Querying information about a folio
- * Querying information about a folio_queue
- * Folio queue iteration
- * Folio marks
- * Lockless simultaneous production/consumption issues
-
-
-Overview
-========
-
-The folio_queue struct forms a single segment in a segmented list of folios
-that can be used to form an I/O buffer.  As such, the list can be iterated over
-using the ITER_FOLIOQ iov_iter type.
-
-The publicly accessible members of the structure are::
-
-	struct folio_queue {
-		struct folio_queue *next;
-		struct folio_queue *prev;
-		...
-	};
-
-A pair of pointers are provided, ``next`` and ``prev``, that point to the
-segments on either side of the segment being accessed.  Whilst this is a
-doubly-linked list, it is intentionally not a circular list; the outward
-sibling pointers in terminal segments should be NULL.
-
-Each segment in the list also stores:
-
- * an ordered sequence of folio pointers,
- * the size of each folio and
- * three 1-bit marks per folio,
-
-but these should not be accessed directly as the underlying data structure may
-change, but rather the access functions outlined below should be used.
-
-The facility can be made accessible by::
-
-	#include <linux/folio_queue.h>
-
-and to use the iterator::
-
-	#include <linux/uio.h>
-
-
-Initialisation
-==============
-
-A segment should be initialised by calling::
-
-	void folioq_init(struct folio_queue *folioq);
-
-with a pointer to the segment to be initialised.  Note that this will not
-necessarily initialise all the folio pointers, so care must be taken to check
-the number of folios added.
-
-
-Adding and removing folios
-==========================
-
-Folios can be set in the next unused slot in a segment struct by calling one
-of::
-
-	unsigned int folioq_append(struct folio_queue *folioq,
-				   struct folio *folio);
-
-	unsigned int folioq_append_mark(struct folio_queue *folioq,
-					struct folio *folio);
-
-Both functions update the stored folio count, store the folio and note its
-size.  The second function also sets the first mark for the folio added.  Both
-functions return the number of the slot used.  [!] Note that no attempt is made
-to check that the capacity wasn't overrun and the list will not be extended
-automatically.
-
-A folio can be excised by calling::
-
-	void folioq_clear(struct folio_queue *folioq, unsigned int slot);
-
-This clears the slot in the array and also clears all the marks for that folio,
-but doesn't change the folio count - so future accesses of that slot must check
-if the slot is occupied.
-
-
-Querying information about a folio
-==================================
-
-Information about the folio in a particular slot may be queried by the
-following function::
-
-	struct folio *folioq_folio(const struct folio_queue *folioq,
-				   unsigned int slot);
-
-If a folio has not yet been set in that slot, this may yield an undefined
-pointer.  The size of the folio in a slot may be queried with either of::
-
-	unsigned int folioq_folio_order(const struct folio_queue *folioq,
-					unsigned int slot);
-
-	size_t folioq_folio_size(const struct folio_queue *folioq,
-				 unsigned int slot);
-
-The first function returns the size as an order and the second as a number of
-bytes.
-
-
-Querying information about a folio_queue
-========================================
-
-Information may be retrieved about a particular segment with the following
-functions::
-
-	unsigned int folioq_nr_slots(const struct folio_queue *folioq);
-
-	unsigned int folioq_count(struct folio_queue *folioq);
-
-	bool folioq_full(struct folio_queue *folioq);
-
-The first function returns the maximum capacity of a segment.  It must not be
-assumed that this won't vary between segments.  The second returns the number
-of folios added to a segments and the third is a shorthand to indicate if the
-segment has been filled to capacity.
-
-Not that the count and fullness are not affected by clearing folios from the
-segment.  These are more about indicating how many slots in the array have been
-initialised, and it assumed that slots won't get reused, but rather the segment
-will get discarded as the queue is consumed.
-
-
-Folio marks
-===========
-
-Folios within a queue can also have marks assigned to them.  These marks can be
-used to note information such as if a folio needs folio_put() calling upon it.
-There are three marks available to be set for each folio.
-
-The marks can be set by::
-
-	void folioq_mark(struct folio_queue *folioq, unsigned int slot);
-	void folioq_mark2(struct folio_queue *folioq, unsigned int slot);
-
-Cleared by::
-
-	void folioq_unmark(struct folio_queue *folioq, unsigned int slot);
-	void folioq_unmark2(struct folio_queue *folioq, unsigned int slot);
-
-And the marks can be queried by::
-
-	bool folioq_is_marked(const struct folio_queue *folioq, unsigned int slot);
-	bool folioq_is_marked2(const struct folio_queue *folioq, unsigned int slot);
-
-The marks can be used for any purpose and are not interpreted by this API.
-
-
-Folio queue iteration
-=====================
-
-A list of segments may be iterated over using the I/O iterator facility using
-an ``iov_iter`` iterator of ``ITER_FOLIOQ`` type.  The iterator may be
-initialised with::
-
-	void iov_iter_folio_queue(struct iov_iter *i, unsigned int direction,
-				  const struct folio_queue *folioq,
-				  unsigned int first_slot, unsigned int offset,
-				  size_t count);
-
-This may be told to start at a particular segment, slot and offset within a
-queue.  The iov iterator functions will follow the next pointers when advancing
-and prev pointers when reverting when needed.
-
-
-Lockless simultaneous production/consumption issues
-===================================================
-
-If properly managed, the list can be extended by the producer at the head end
-and shortened by the consumer at the tail end simultaneously without the need
-to take locks.  The ITER_FOLIOQ iterator inserts appropriate barriers to aid
-with this.
-
-Care must be taken when simultaneously producing and consuming a list.  If the
-last segment is reached and the folios it refers to are entirely consumed by
-the IOV iterators, an iov_iter struct will be left pointing to the last segment
-with a slot number equal to the capacity of that segment.  The iterator will
-try to continue on from this if there's another segment available when it is
-used again, but care must be taken lest the segment got removed and freed by
-the consumer before the iterator was advanced.
-
-It is recommended that the queue always contain at least one segment, even if
-that segment has never been filled or is entirely spent.  This prevents the
-head and tail pointers from collapsing.
-
-
-API Function Reference
-======================
-
-.. kernel-doc:: include/linux/folio_queue.h
diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index 92f91c6a0d79..956f6803d2a2 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -39,7 +39,6 @@ Library functionality that is used throughout the kernel.
    kref
    cleanup
    assoc_array
-   folio_queue
    xarray
    maple_tree
    idr
diff --git a/Documentation/filesystems/netfs_library.rst b/Documentation/filesystems/netfs_library.rst
index 0c9786ffe192..ebf07a37922e 100644
--- a/Documentation/filesystems/netfs_library.rst
+++ b/Documentation/filesystems/netfs_library.rst
@@ -452,7 +452,7 @@ be called from the writeback code to write the data to the cache, if there is
 one.
 
 The inode should be marked ``NETFS_ICTX_SINGLE_NO_UPLOAD`` if this API is to be
-used.  The writeback function requires the buffer to be of ITER_FOLIOQ type.
+used.
 
 High-Level VM API
 ==================
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index dd20a9f201be..583ffa967d5a 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -7,7 +7,6 @@
 
 #include <linux/slab.h>
 #include <linux/seq_file.h>
-#include <linux/folio_queue.h>
 #include <linux/netfs.h>
 #include <linux/fscache.h>
 #include <linux/fscache-cache.h>
@@ -46,7 +45,6 @@ extern spinlock_t netfs_proc_lock;
 extern mempool_t netfs_request_pool;
 extern mempool_t netfs_subrequest_pool;
 extern mempool_t netfs_bvecq_pool;
-extern mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
 static inline void netfs_proc_add_rreq(struct netfs_io_request *rreq)
@@ -71,8 +69,6 @@ static inline void netfs_proc_del_rreq(struct netfs_io_request *rreq) {}
 /*
  * misc.c
  */
-struct folio_queue *netfs_buffer_make_space(struct netfs_io_request *rreq,
-					    enum netfs_folioq_trace trace);
 void netfs_reset_iter(struct netfs_io_subrequest *subreq);
 void netfs_wake_collector(struct netfs_io_request *rreq);
 void netfs_subreq_clear_in_progress(struct netfs_io_subrequest *subreq);
@@ -203,7 +199,6 @@ extern atomic_t netfs_n_wh_retry_write_req;
 extern atomic_t netfs_n_wh_retry_write_subreq;
 extern atomic_t netfs_n_wb_lock_skip;
 extern atomic_t netfs_n_wb_lock_wait;
-extern atomic_t netfs_n_folioq;
 extern atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v);
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 5c8517a66dde..36a1d98e593a 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -29,7 +29,6 @@ static struct kmem_cache *netfs_subrequest_slab;
 mempool_t netfs_request_pool;
 mempool_t netfs_subrequest_pool;
 mempool_t netfs_bvecq_pool;
-mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
 LIST_HEAD(netfs_io_requests);
@@ -109,9 +108,6 @@ static int __init netfs_init(void)
 {
 	int ret = -ENOMEM;
 
-	if (mempool_init_kmalloc_pool(&netfs_folioq_pool, 100, sizeof(struct folio_queue)) < 0)
-		goto error_folioq_pool;
-
 	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool, 100,
 				      struct_size_t(struct bvecq, __bv, BVECQ_POOL_SLOTS)) < 0)
 		goto error_bvecq_pool;
@@ -170,8 +166,6 @@ static int __init netfs_init(void)
 error_req:
 	mempool_exit(&netfs_bvecq_pool);
 error_bvecq_pool:
-	mempool_exit(&netfs_folioq_pool);
-error_folioq_pool:
 	return ret;
 }
 fs_initcall(netfs_init);
@@ -185,6 +179,5 @@ static void __exit netfs_exit(void)
 	mempool_exit(&netfs_request_pool);
 	kmem_cache_destroy(netfs_request_slab);
 	mempool_exit(&netfs_bvecq_pool);
-	mempool_exit(&netfs_folioq_pool);
 }
 module_exit(netfs_exit);
diff --git a/fs/netfs/misc.c b/fs/netfs/misc.c
index a3cd76d584b8..40e0ff649132 100644
--- a/fs/netfs/misc.c
+++ b/fs/netfs/misc.c
@@ -8,102 +8,6 @@
 #include <linux/swap.h>
 #include "internal.h"
 
-/**
- * netfs_alloc_folioq_buffer - Allocate buffer space into a folio queue
- * @mapping: Address space to set on the folio (or NULL).
- * @_buffer: Pointer to the folio queue to add to (may point to a NULL; updated).
- * @_cur_size: Current size of the buffer (updated).
- * @size: Target size of the buffer.
- * @gfp: The allocation constraints.
- */
-int netfs_alloc_folioq_buffer(struct address_space *mapping,
-			      struct folio_queue **_buffer,
-			      size_t *_cur_size, ssize_t size, gfp_t gfp)
-{
-	struct folio_queue *tail = *_buffer, *p;
-
-	size = round_up(size, PAGE_SIZE);
-	if (*_cur_size >= size)
-		return 0;
-
-	if (tail)
-		while (tail->next)
-			tail = tail->next;
-
-	do {
-		struct folio *folio;
-		int order = 0, slot;
-
-		if (!tail || folioq_full(tail)) {
-			p = netfs_folioq_alloc(0, GFP_NOFS, netfs_trace_folioq_alloc_buffer);
-			if (!p)
-				return -ENOMEM;
-			if (tail) {
-				tail->next = p;
-				p->prev = tail;
-			} else {
-				*_buffer = p;
-			}
-			tail = p;
-		}
-
-		if (size - *_cur_size > PAGE_SIZE)
-			order = umin(ilog2(size - *_cur_size) - PAGE_SHIFT,
-				     MAX_PAGECACHE_ORDER);
-
-		folio = folio_alloc(gfp, order);
-		if (!folio && order > 0)
-			folio = folio_alloc(gfp, 0);
-		if (!folio)
-			return -ENOMEM;
-
-		folio->mapping = mapping;
-		folio->index = *_cur_size / PAGE_SIZE;
-		trace_netfs_folio(folio, netfs_folio_trace_alloc_buffer);
-		slot = folioq_append_mark(tail, folio);
-		*_cur_size += folioq_folio_size(tail, slot);
-	} while (*_cur_size < size);
-
-	return 0;
-}
-EXPORT_SYMBOL(netfs_alloc_folioq_buffer);
-
-/**
- * netfs_free_folioq_buffer - Free a folio queue.
- * @fq: The start of the folio queue to free
- *
- * Free up a chain of folio_queues and, if marked, the marked folios they point
- * to.
- */
-void netfs_free_folioq_buffer(struct folio_queue *fq)
-{
-	struct folio_queue *next;
-	struct folio_batch fbatch;
-
-	folio_batch_init(&fbatch);
-
-	for (; fq; fq = next) {
-		for (int slot = 0; slot < folioq_count(fq); slot++) {
-			struct folio *folio = folioq_folio(fq, slot);
-
-			if (!folio ||
-			    !folioq_is_marked(fq, slot))
-				continue;
-
-			trace_netfs_folio(folio, netfs_folio_trace_put);
-			if (folio_batch_add(&fbatch, folio))
-				folio_batch_release(&fbatch);
-		}
-
-		netfs_stat_d(&netfs_n_folioq);
-		next = fq->next;
-		kfree(fq);
-	}
-
-	folio_batch_release(&fbatch);
-}
-EXPORT_SYMBOL(netfs_free_folioq_buffer);
-
 /*
  * Reset the subrequest iterator to refer just to the region remaining to be
  * read.  The iterator may or may not have been advanced by socket ops or
diff --git a/fs/netfs/rolling_buffer.c b/fs/netfs/rolling_buffer.c
index 76429fbb6920..66ce9add4012 100644
--- a/fs/netfs/rolling_buffer.c
+++ b/fs/netfs/rolling_buffer.c
@@ -12,52 +12,6 @@
 #include <linux/slab.h>
 #include "internal.h"
 
-static atomic_t debug_ids;
-
-/**
- * netfs_folioq_alloc - Allocate a folio_queue struct
- * @rreq_id: Associated debugging ID for tracing purposes
- * @gfp: Allocation constraints
- * @trace: Trace tag to indicate the purpose of the allocation
- *
- * Allocate, initialise and account the folio_queue struct and log a trace line
- * to mark the allocation.
- */
-struct folio_queue *netfs_folioq_alloc(unsigned int rreq_id, gfp_t gfp,
-				       unsigned int /*enum netfs_folioq_trace*/ trace)
-{
-	struct folio_queue *fq;
-
-	if (gfp == GFP_KERNEL)
-		fq = mempool_alloc_noreserve(&netfs_folioq_pool, gfp);
-	else
-		fq = mempool_alloc(&netfs_folioq_pool, gfp);
-	if (fq) {
-		netfs_stat(&netfs_n_folioq);
-		folioq_init(fq, rreq_id);
-		fq->debug_id = atomic_inc_return(&debug_ids);
-		trace_netfs_folioq(fq, trace);
-	}
-	return fq;
-}
-EXPORT_SYMBOL(netfs_folioq_alloc);
-
-/**
- * netfs_folioq_free - Free a folio_queue struct
- * @folioq: The object to free
- * @trace: Trace tag to indicate which free
- *
- * Free and unaccount the folio_queue struct.
- */
-void netfs_folioq_free(struct folio_queue *folioq,
-		       unsigned int /*enum netfs_trace_folioq*/ trace)
-{
-	trace_netfs_folioq(folioq, trace);
-	netfs_stat_d(&netfs_n_folioq);
-	mempool_free(folioq, &netfs_folioq_pool);
-}
-EXPORT_SYMBOL(netfs_folioq_free);
-
 /*
  * Initialise a rolling buffer.  We allocate an empty folio queue struct to so
  * that the pointers can be independently driven by the producer and the
diff --git a/fs/netfs/stats.c b/fs/netfs/stats.c
index a10d34f88597..0ba6ce9295b2 100644
--- a/fs/netfs/stats.c
+++ b/fs/netfs/stats.c
@@ -46,7 +46,6 @@ atomic_t netfs_n_wh_retry_write_req;
 atomic_t netfs_n_wh_retry_write_subreq;
 atomic_t netfs_n_wb_lock_skip;
 atomic_t netfs_n_wb_lock_wait;
-atomic_t netfs_n_folioq;
 atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v)
@@ -89,11 +88,10 @@ int netfs_stats_show(struct seq_file *m, void *v)
 		   atomic_read(&netfs_n_rh_retry_read_subreq),
 		   atomic_read(&netfs_n_wh_retry_write_req),
 		   atomic_read(&netfs_n_wh_retry_write_subreq));
-	seq_printf(m, "Objs   : rr=%u sr=%u bq=%u foq=%u wsc=%u\n",
+	seq_printf(m, "Objs   : rr=%u sr=%u bq=%u wsc=%u\n",
 		   atomic_read(&netfs_n_rh_rreq),
 		   atomic_read(&netfs_n_rh_sreq),
 		   atomic_read(&netfs_n_bvecq),
-		   atomic_read(&netfs_n_folioq),
 		   atomic_read(&netfs_n_wh_wstream_conflict));
 	seq_printf(m, "WbLock : skip=%u wait=%u\n",
 		   atomic_read(&netfs_n_wb_lock_skip),
diff --git a/include/linux/folio_queue.h b/include/linux/folio_queue.h
deleted file mode 100644
index f6d5f1f127c9..000000000000
--- a/include/linux/folio_queue.h
+++ /dev/null
@@ -1,282 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0-or-later */
-/* Queue of folios definitions
- *
- * Copyright (C) 2024 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * See:
- *
- *	Documentation/core-api/folio_queue.rst
- *
- * for a description of the API.
- */
-
-#ifndef _LINUX_FOLIO_QUEUE_H
-#define _LINUX_FOLIO_QUEUE_H
-
-#include <linux/folio_batch.h>
-#include <linux/mm.h>
-
-/*
- * Segment in a queue of running buffers.  Each segment can hold a number of
- * folios and a portion of the queue can be referenced with the ITER_FOLIOQ
- * iterator.  The possibility exists of inserting non-folio elements into the
- * queue (such as gaps).
- *
- * Explicit prev and next pointers are used instead of a list_head to make it
- * easier to add segments to tail and remove them from the head without the
- * need for a lock.
- */
-struct folio_queue {
-	struct folio_batch	vec;		/* Folios in the queue segment */
-	u8			orders[FOLIO_BATCH_SIZE]; /* Order of each folio */
-	struct folio_queue	*next;		/* Next queue segment or NULL */
-	struct folio_queue	*prev;		/* Previous queue segment of NULL */
-	unsigned long		marks;		/* 1-bit mark per folio */
-	unsigned long		marks2;		/* Second 1-bit mark per folio */
-#if FOLIO_BATCH_SIZE > BITS_PER_LONG
-#error marks is not big enough
-#endif
-	unsigned int		rreq_id;
-	unsigned int		debug_id;
-};
-
-/**
- * folioq_init - Initialise a folio queue segment
- * @folioq: The segment to initialise
- * @rreq_id: The request identifier to use in tracelines.
- *
- * Initialise a folio queue segment and set an identifier to be used in traces.
- *
- * Note that the folio pointers are left uninitialised.
- */
-static inline void folioq_init(struct folio_queue *folioq, unsigned int rreq_id)
-{
-	folio_batch_init(&folioq->vec);
-	folioq->next = NULL;
-	folioq->prev = NULL;
-	folioq->marks = 0;
-	folioq->marks2 = 0;
-	folioq->rreq_id = rreq_id;
-	folioq->debug_id = 0;
-}
-
-/**
- * folioq_nr_slots: Query the capacity of a folio queue segment
- * @folioq: The segment to query
- *
- * Query the number of folios that a particular folio queue segment might hold.
- * [!] NOTE: This must not be assumed to be the same for every segment!
- */
-static inline unsigned int folioq_nr_slots(const struct folio_queue *folioq)
-{
-	return FOLIO_BATCH_SIZE;
-}
-
-/**
- * folioq_count: Query the occupancy of a folio queue segment
- * @folioq: The segment to query
- *
- * Query the number of folios that have been added to a folio queue segment.
- * Note that this is not decreased as folios are removed from a segment.
- */
-static inline unsigned int folioq_count(struct folio_queue *folioq)
-{
-	return folio_batch_count(&folioq->vec);
-}
-
-/**
- * folioq_full: Query if a folio queue segment is full
- * @folioq: The segment to query
- *
- * Query if a folio queue segment is fully occupied.  Note that this does not
- * change if folios are removed from a segment.
- */
-static inline bool folioq_full(struct folio_queue *folioq)
-{
-	//return !folio_batch_space(&folioq->vec);
-	return folioq_count(folioq) >= folioq_nr_slots(folioq);
-}
-
-/**
- * folioq_is_marked: Check first folio mark in a folio queue segment
- * @folioq: The segment to query
- * @slot: The slot number of the folio to query
- *
- * Determine if the first mark is set for the folio in the specified slot in a
- * folio queue segment.
- */
-static inline bool folioq_is_marked(const struct folio_queue *folioq, unsigned int slot)
-{
-	return test_bit(slot, &folioq->marks);
-}
-
-/**
- * folioq_mark: Set the first mark on a folio in a folio queue segment
- * @folioq: The segment to modify
- * @slot: The slot number of the folio to modify
- *
- * Set the first mark for the folio in the specified slot in a folio queue
- * segment.
- */
-static inline void folioq_mark(struct folio_queue *folioq, unsigned int slot)
-{
-	set_bit(slot, &folioq->marks);
-}
-
-/**
- * folioq_unmark: Clear the first mark on a folio in a folio queue segment
- * @folioq: The segment to modify
- * @slot: The slot number of the folio to modify
- *
- * Clear the first mark for the folio in the specified slot in a folio queue
- * segment.
- */
-static inline void folioq_unmark(struct folio_queue *folioq, unsigned int slot)
-{
-	clear_bit(slot, &folioq->marks);
-}
-
-/**
- * folioq_is_marked2: Check second folio mark in a folio queue segment
- * @folioq: The segment to query
- * @slot: The slot number of the folio to query
- *
- * Determine if the second mark is set for the folio in the specified slot in a
- * folio queue segment.
- */
-static inline bool folioq_is_marked2(const struct folio_queue *folioq, unsigned int slot)
-{
-	return test_bit(slot, &folioq->marks2);
-}
-
-/**
- * folioq_mark2: Set the second mark on a folio in a folio queue segment
- * @folioq: The segment to modify
- * @slot: The slot number of the folio to modify
- *
- * Set the second mark for the folio in the specified slot in a folio queue
- * segment.
- */
-static inline void folioq_mark2(struct folio_queue *folioq, unsigned int slot)
-{
-	set_bit(slot, &folioq->marks2);
-}
-
-/**
- * folioq_unmark2: Clear the second mark on a folio in a folio queue segment
- * @folioq: The segment to modify
- * @slot: The slot number of the folio to modify
- *
- * Clear the second mark for the folio in the specified slot in a folio queue
- * segment.
- */
-static inline void folioq_unmark2(struct folio_queue *folioq, unsigned int slot)
-{
-	clear_bit(slot, &folioq->marks2);
-}
-
-/**
- * folioq_append: Add a folio to a folio queue segment
- * @folioq: The segment to add to
- * @folio: The folio to add
- *
- * Add a folio to the tail of the sequence in a folio queue segment, increasing
- * the occupancy count and returning the slot number for the folio just added.
- * The folio size is extracted and stored in the queue and the marks are left
- * unmodified.
- *
- * Note that it's left up to the caller to check that the segment capacity will
- * not be exceeded and to extend the queue.
- */
-static inline unsigned int folioq_append(struct folio_queue *folioq, struct folio *folio)
-{
-	unsigned int slot = folioq->vec.nr++;
-
-	folioq->vec.folios[slot] = folio;
-	folioq->orders[slot] = folio_order(folio);
-	return slot;
-}
-
-/**
- * folioq_append_mark: Add a folio to a folio queue segment
- * @folioq: The segment to add to
- * @folio: The folio to add
- *
- * Add a folio to the tail of the sequence in a folio queue segment, increasing
- * the occupancy count and returning the slot number for the folio just added.
- * The folio size is extracted and stored in the queue, the first mark is set
- * and and the second and third marks are left unmodified.
- *
- * Note that it's left up to the caller to check that the segment capacity will
- * not be exceeded and to extend the queue.
- */
-static inline unsigned int folioq_append_mark(struct folio_queue *folioq, struct folio *folio)
-{
-	unsigned int slot = folioq->vec.nr++;
-
-	folioq->vec.folios[slot] = folio;
-	folioq->orders[slot] = folio_order(folio);
-	folioq_mark(folioq, slot);
-	return slot;
-}
-
-/**
- * folioq_folio: Get a folio from a folio queue segment
- * @folioq: The segment to access
- * @slot: The folio slot to access
- *
- * Retrieve the folio in the specified slot from a folio queue segment.  Note
- * that no bounds check is made and if the slot hasn't been added into yet, the
- * pointer will be undefined.  If the slot has been cleared, NULL will be
- * returned.
- */
-static inline struct folio *folioq_folio(const struct folio_queue *folioq, unsigned int slot)
-{
-	return folioq->vec.folios[slot];
-}
-
-/**
- * folioq_folio_order: Get the order of a folio from a folio queue segment
- * @folioq: The segment to access
- * @slot: The folio slot to access
- *
- * Retrieve the order of the folio in the specified slot from a folio queue
- * segment.  Note that no bounds check is made and if the slot hasn't been
- * added into yet, the order returned will be 0.
- */
-static inline unsigned int folioq_folio_order(const struct folio_queue *folioq, unsigned int slot)
-{
-	return folioq->orders[slot];
-}
-
-/**
- * folioq_folio_size: Get the size of a folio from a folio queue segment
- * @folioq: The segment to access
- * @slot: The folio slot to access
- *
- * Retrieve the size of the folio in the specified slot from a folio queue
- * segment.  Note that no bounds check is made and if the slot hasn't been
- * added into yet, the size returned will be PAGE_SIZE.
- */
-static inline size_t folioq_folio_size(const struct folio_queue *folioq, unsigned int slot)
-{
-	return PAGE_SIZE << folioq_folio_order(folioq, slot);
-}
-
-/**
- * folioq_clear: Clear a folio from a folio queue segment
- * @folioq: The segment to clear
- * @slot: The folio slot to clear
- *
- * Clear a folio from a sequence in a folio queue segment and clear its marks.
- * The occupancy count is left unchanged.
- */
-static inline void folioq_clear(struct folio_queue *folioq, unsigned int slot)
-{
-	folioq->vec.folios[slot] = NULL;
-	folioq_unmark(folioq, slot);
-	folioq_unmark2(folioq, slot);
-}
-
-#endif /* _LINUX_FOLIO_QUEUE_H */
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 1723bcda86ba..31a80f4377d7 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -24,7 +24,6 @@
 enum netfs_sreq_ref_trace;
 typedef struct mempool mempool_t;
 struct fscache_occupancy;
-struct folio_queue;
 
 /**
  * folio_start_private_2 - Start an fscache write on a folio.  [DEPRECATED]
@@ -470,18 +469,6 @@ void netfs_end_io_write(struct inode *inode);
 int netfs_start_io_direct(struct inode *inode);
 void netfs_end_io_direct(struct inode *inode);
 
-/* Miscellaneous APIs. */
-struct folio_queue *netfs_folioq_alloc(unsigned int rreq_id, gfp_t gfp,
-				       unsigned int trace /*enum netfs_folioq_trace*/);
-void netfs_folioq_free(struct folio_queue *folioq,
-		       unsigned int trace /*enum netfs_trace_folioq*/);
-
-/* Buffer wrangling helpers API. */
-int netfs_alloc_folioq_buffer(struct address_space *mapping,
-			      struct folio_queue **_buffer,
-			      size_t *_cur_size, ssize_t size, gfp_t gfp);
-void netfs_free_folioq_buffer(struct folio_queue *fq);
-
 /* Writeback exclusion API. */
 bool netfs_wb_begin(struct netfs_inode *ictx, bool nowait);
 void netfs_wb_end(struct netfs_inode *ictx);
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index 41f7f0733bfa..1f92a653d3bf 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -244,14 +244,6 @@
 	EM(netfs_trace_donate_to_next,		"to-next")	\
 	E_(netfs_trace_donate_to_deferred_next,	"defer-next")
 
-#define netfs_folioq_traces					\
-	EM(netfs_trace_folioq_alloc_buffer,	"alloc-buf")	\
-	EM(netfs_trace_folioq_clear,		"clear")	\
-	EM(netfs_trace_folioq_delete,		"delete")	\
-	EM(netfs_trace_folioq_make_space,	"make-space")	\
-	EM(netfs_trace_folioq_rollbuf_init,	"roll-init")	\
-	E_(netfs_trace_folioq_read_progress,	"r-progress")
-
 #ifndef __NETFS_DECLARE_TRACE_ENUMS_ONCE_ONLY
 #define __NETFS_DECLARE_TRACE_ENUMS_ONCE_ONLY
 
@@ -270,7 +262,6 @@ enum netfs_sreq_ref_trace { netfs_sreq_ref_traces } __mode(byte);
 enum netfs_folio_trace { netfs_folio_traces } __mode(byte);
 enum netfs_collect_contig_trace { netfs_collect_contig_traces } __mode(byte);
 enum netfs_donate_trace { netfs_donate_traces } __mode(byte);
-enum netfs_folioq_trace { netfs_folioq_traces } __mode(byte);
 
 #endif
 
@@ -294,7 +285,6 @@ netfs_sreq_ref_traces;
 netfs_folio_traces;
 netfs_collect_contig_traces;
 netfs_donate_traces;
-netfs_folioq_traces;
 
 /*
  * Now redefine the EM() and E_() macros to map the enums to the strings that
@@ -773,29 +763,6 @@ TRACE_EVENT(netfs_collect_stream,
 		      __entry->collected_to, __entry->issued_to)
 	    );
 
-TRACE_EVENT(netfs_folioq,
-	    TP_PROTO(const struct folio_queue *fq,
-		     enum netfs_folioq_trace trace),
-
-	    TP_ARGS(fq, trace),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,		rreq)
-		    __field(unsigned int,		id)
-		    __field(enum netfs_folioq_trace,	trace)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->rreq	= fq ? fq->rreq_id : 0;
-		    __entry->id		= fq ? fq->debug_id : 0;
-		    __entry->trace	= trace;
-			   ),
-
-	    TP_printk("R=%08x fq=%x %s",
-		      __entry->rreq, __entry->id,
-		      __print_symbolic(__entry->trace, netfs_folioq_traces))
-	    );
-
 TRACE_EVENT(netfs_read_progress_at,
 	    TP_PROTO(const struct netfs_io_request *rreq),
 
diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
index d870bc5e50bc..63fd6156ffa7 100644
--- a/kernel/bpf/btf.c
+++ b/kernel/bpf/btf.c
@@ -6803,8 +6803,6 @@ static const struct bpf_raw_tp_null_args raw_tp_null_args[] = {
 	/* amdgpu */
 	{ "amdgpu_vm_bo_map", 0x1 },
 	{ "amdgpu_vm_bo_unmap", 0x1 },
-	/* netfs */
-	{ "netfs_folioq", 0x1 },
 	/* xfs from xfs_defer_pending_class */
 	{ "xfs_defer_create_intent", 0x1 },
 	{ "xfs_defer_cancel_list", 0x1 },

