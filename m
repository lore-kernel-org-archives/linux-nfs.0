Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3AFC63B2D00
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 21:01:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791320462; cv=none; b=BfXSqouQ/AFhCkLwij6+6rjFeKdD9FFKlL0WtiYX1X01PPKVKv3GKjkzBmnnuNHX9EnogoIYpH90f4MohTUmPE9FsXpsSYjzc6aWFROFlA2NlifHEG0vkbde+dh3wYxnqRNzOfsCDVIe59ahBGmV+WDSI6DtiH/ok+R5BH+kpKo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791320462; c=relaxed/simple;
	bh=xhsGtCbtQodwqRexuobUDqMM+XhIRJKSVIyLoDoP9C0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=C8Pk/61tMfFEp22ZQoHn5CEoIbMx123q9QRFie1U3PR5/ZcaPuVxbjvOgL3LiGi+4FfUdt+TQPmrHK+dy4ciczbZoFsgjHDNfwgy1LS/FBsTCEKbknEapMyqdvxhAZJQhA4fGGsz7q/11gbLsK1fE2xuf5R5wmbtHxV0V4LddIo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ARR+ARqI; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ARR+ARqI"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791320458;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=TCfftdu3Rz0V3sHWcyb6LVLBLqYA4Wq6Mp5f6Oy0tgY=;
	b=ARR+ARqIFFxwP0+KTQPY+rITSo1klPJOThdrU2IugOG1QDtJ4HpMGLLQ3IrN45WKjcdNey
	uJVr94PuGVEAz+mqkUfvRtPErul1D6MVzBrnERd+sZWHnAblwK4hQEVLPd66xF6qL/PqXf
	c22yBO0mn01Hr8xklQlWTzib+GaXSsM=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-428-1FoN3fy1M--wgVSkLGjgkg-1; Tue,
 06 Oct 2026 17:00:52 -0400
X-MC-Unique: 1FoN3fy1M--wgVSkLGjgkg-1
X-Mimecast-MFC-AGG-ID: 1FoN3fy1M--wgVSkLGjgkg_1791320449
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7BE83195608B;
	Tue,  6 Oct 2026 21:00:49 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8FFAB427;
	Tue,  6 Oct 2026 21:00:44 +0000 (UTC)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH v13 7/8] netfs: Remove the rolling_buffer implementation
Date: Tue,  6 Oct 2026 21:59:43 +0100
Message-ID: <20261006205947.608356-8-dhowells@redhat.com>
In-Reply-To: <20261006205947.608356-1-dhowells@redhat.com>
References: <20261006205947.608356-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Remove the rolling_buffer implementation as it has been replaced with the
use of bvecq_pos.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/rolling_buffer.c      | 182 ---------------------------------
 include/linux/rolling_buffer.h |  47 ---------
 2 files changed, 229 deletions(-)
 delete mode 100644 fs/netfs/rolling_buffer.c
 delete mode 100644 include/linux/rolling_buffer.h

diff --git a/fs/netfs/rolling_buffer.c b/fs/netfs/rolling_buffer.c
deleted file mode 100644
index 66ce9add4012..000000000000
--- a/fs/netfs/rolling_buffer.c
+++ /dev/null
@@ -1,182 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0-or-later
-/* Rolling buffer helpers
- *
- * Copyright (C) 2024 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- */
-
-#include <linux/bitops.h>
-#include <linux/mempool.h>
-#include <linux/pagemap.h>
-#include <linux/rolling_buffer.h>
-#include <linux/slab.h>
-#include "internal.h"
-
-/*
- * Initialise a rolling buffer.  We allocate an empty folio queue struct to so
- * that the pointers can be independently driven by the producer and the
- * consumer.
- */
-int rolling_buffer_init(struct rolling_buffer *roll, unsigned int direction,
-			gfp_t gfp, bool for_writeback)
-{
-	struct bvecq *bq;
-
-	roll->for_writeback = for_writeback;
-
-	bq = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, for_writeback);
-	if (!bq)
-		return -ENOMEM;
-
-	roll->head = bq;
-	roll->tail = bq;
-	iov_iter_bvec_queue(&roll->iter, direction, bq, 0, 0, 0);
-	return 0;
-}
-
-/*
- * Add another bvecq to a rolling buffer if there's no space left.
- */
-int rolling_buffer_make_space(struct rolling_buffer *roll, gfp_t gfp)
-{
-	struct bvecq *bq, *head = roll->head;
-
-	if (!bvecq_is_full(head))
-		return 0;
-
-	bq = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, roll->for_writeback);
-	if (!bq)
-		return -ENOMEM;
-
-	roll->head = bq;
-	if (bvecq_is_full(head)) {
-		/* Make sure we don't leave the master iterator pointing to a
-		 * block that might get immediately consumed.
-		 */
-		if (roll->iter.bvecq == head &&
-		    roll->iter.bvecq_slot == head->nr_slots) {
-			roll->iter.bvecq = bq;
-			roll->iter.bvecq_slot = 0;
-		}
-	}
-
-	/* Make sure the initialisation is stored before the next pointer.
-	 *
-	 * [!] NOTE: After we set head->next, the consumer is at liberty to
-	 * immediately delete the old head.
-	 */
-	bvecq_append(head, bq);
-	return 0;
-}
-
-/*
- * Decant the entire list of folios to read into a rolling buffer.
- */
-ssize_t rolling_buffer_bulk_load_from_ra(struct rolling_buffer *roll,
-					 struct readahead_control *ractl,
-					 gfp_t gfp)
-{
-	struct bvecq *bq;
-	size_t loaded = 0;
-
-	while (ractl->_nr_pages - ractl->_batch_count > 0) {
-		struct page **pages;
-		unsigned int nr;
-
-		/* Allocate a bvecq to put some folios into and attach it to
-		 * the rolling buffer.
-		 */
-		bq = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, false);
-		if (!bq)
-			goto nomem_unlock;
-		bq->mem_type = BVECQ_MEM_EXTERNAL; /* Folio cleanup handled separately. */
-
-		if (!roll->tail)
-			roll->tail = bq;
-		else
-			bvecq_append(roll->head, bq);
-		roll->head = bq;
-
-		/* Get a bunch of folios and note their sizes. */
-		pages = (struct page **)(bq->bv + bq->max_slots);
-		pages -= bq->max_slots;
-		nr = __readahead_batch(ractl, pages, bq->max_slots);
-		if (WARN_ON_ONCE(!nr))
-			break;
-
-		for (int slot = 0; slot < nr; slot++) {
-			struct folio *folio = page_folio(pages[slot]);
-			size_t len = folio_size(folio);
-
-			bvec_set_folio(&bq->bv[slot], folio, len, 0);
-			loaded += len;
-			trace_netfs_folio(folio, netfs_folio_trace_read);
-		}
-
-		bvecq_filled_to(bq, nr);
-	}
-
-	WRITE_ONCE(roll->iter.count, loaded);
-	iov_iter_bvec_queue(&roll->iter, ITER_DEST, roll->tail, 0, 0, loaded);
-	return loaded;
-
-nomem_unlock:
-	for (bq = roll->tail; bq; bq = bq->next) {
-		for (int slot = 0; slot < bq->nr_slots; slot++) {
-			struct folio *folio = bvec_folio(&bq->bv[slot]);
-
-			folio_unlock(folio);
-			folio_put(folio);
-		}
-	}
-	rolling_buffer_clear(roll);
-	roll->head = NULL;
-	roll->tail = NULL;
-	return -ENOMEM;
-}
-
-/*
- * Append a folio to the rolling buffer.
- */
-ssize_t rolling_buffer_append(struct rolling_buffer *roll, struct folio *folio,
-			      gfp_t gfp)
-{
-	ssize_t size = folio_size(folio);
-	int slot;
-
-	if (rolling_buffer_make_space(roll, gfp) < 0)
-		return -ENOMEM;
-
-	slot = roll->head->nr_slots;
-	bvec_set_folio(&roll->head->bv[slot], folio, size, 0);
-	bvecq_filled_to(roll->head, slot + 1);
-
-	WRITE_ONCE(roll->iter.count, roll->iter.count + size);
-	return size;
-}
-
-/*
- * Delete a spent buffer from a rolling queue and return the next in line.  We
- * don't return the last buffer to keep the pointers independent, but return
- * NULL instead.
- */
-struct bvecq *rolling_buffer_delete_spent(struct rolling_buffer *roll)
-{
-	struct bvecq *spent = roll->tail, *next = bvecq_next(spent);
-
-	if (!next)
-		return NULL;
-	next->prev = NULL;
-	roll->tail = next;
-	spent->next = NULL;
-	bvecq_put(spent);
-	return next;
-}
-
-/*
- * Clear out a rolling queue.
- */
-void rolling_buffer_clear(struct rolling_buffer *roll)
-{
-	bvecq_put(roll->tail);
-}
diff --git a/include/linux/rolling_buffer.h b/include/linux/rolling_buffer.h
deleted file mode 100644
index 5c0bc4221f01..000000000000
--- a/include/linux/rolling_buffer.h
+++ /dev/null
@@ -1,47 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0-or-later */
-/* Rolling buffer of folios
- *
- * Copyright (C) 2024 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- */
-
-#ifndef _ROLLING_BUFFER_H
-#define _ROLLING_BUFFER_H
-
-#include <linux/bvecq.h>
-#include <linux/uio.h>
-
-/*
- * Rolling buffer.  Whilst the buffer is live and in use, folios and bvecq
- * segments can be added to one end by one thread and removed from the other
- * end by another thread.  The buffer isn't allowed to be empty; it must always
- * have at least one bvecq in it so that neither side has to modify both queue
- * pointers.
- *
- * The iterator in the buffer is extended as buffers are inserted.  It can be
- * snapshotted to use a segment of the buffer.
- */
-struct rolling_buffer {
-	struct bvecq		*head;		/* Producer's insertion point */
-	struct bvecq		*tail;		/* Consumer's removal point */
-	struct iov_iter		iter;		/* Iterator tracking what's left in the buffer */
-	u8			first_tail_slot; /* First slot in ->tail */
-	bool			for_writeback;	/* T if being used for writeback */
-};
-
-int rolling_buffer_init(struct rolling_buffer *roll, unsigned int direction,
-			gfp_t gfp, bool for_writeback);
-int rolling_buffer_make_space(struct rolling_buffer *roll, gfp_t gfp);
-ssize_t rolling_buffer_bulk_load_from_ra(struct rolling_buffer *roll,
-					 struct readahead_control *ractl,
-					 gfp_t gfp);
-ssize_t rolling_buffer_append(struct rolling_buffer *roll, struct folio *folio, gfp_t gfp);
-struct bvecq *rolling_buffer_delete_spent(struct rolling_buffer *roll);
-void rolling_buffer_clear(struct rolling_buffer *roll);
-
-static inline void rolling_buffer_advance(struct rolling_buffer *roll, size_t amount)
-{
-	iov_iter_advance(&roll->iter, amount);
-}
-
-#endif /* _ROLLING_BUFFER_H */

