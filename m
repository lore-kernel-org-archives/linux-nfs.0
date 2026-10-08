Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07A0B3D3301
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 07:44:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791445475; cv=none; b=AUZ738L0a/C7/2DHDFtMM1N72BjqN3uLtxsEpdyJkdvFbhVQKo3pmxD1Oa3L0gWq4/qean3k+huJC+S4J3yvqxKJGNE3CZAbs4yD2dQJ10lQMAqhnFVQhNkkBYZt/2xELuoHcPeOZBqPl8QpwCKt3N4AviJkqdsghx+KkEms74w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791445475; c=relaxed/simple;
	bh=/r1m+BCw6KS6hsbs/1ArzXU7L011g7y1Wbz9qwiQ5ww=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XlJd7CUGW27uP5sGJwjAnr8OHXOvQt6WUt3GRs7SKd+khKcyUoXFqP9d7umksRoxY0R0LD8VftG/VJ9DMYR/40bVsao+N+IsBGd98O2+5wq1pnujKIXs4lg44WeNQN1H2cmx1D982BHI76tvju85u+Tk4xYuRYJrDJPowEpYAVU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=WpBR1Bjc; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="WpBR1Bjc"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791445472;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=CTRW2UXkjpp1+xSf7Qb60zWfqjM4LUsLs/HHbXv6PTA=;
	b=WpBR1BjcWXd/zYF6S4l/06N+2TOZs3uulbHnPw15uzhiLVi7KNZEJGpNWbezLffmYE0dLZ
	Wza2YNdviaz7Zn7+vRR2FfMlsC0NhV4eJTCT7lOAHHEJg7kUaFiD6tHVLfKdJToVfQm/Ip
	SefruHM7VGbA93fpUPFY2OwxkquDhG0=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-424-sYaeW7HkPXSBUrY7N4707w-1; Thu,
 08 Oct 2026 03:44:28 -0400
X-MC-Unique: sYaeW7HkPXSBUrY7N4707w-1
X-Mimecast-MFC-AGG-ID: sYaeW7HkPXSBUrY7N4707w_1791445466
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id DFBE41955D74;
	Thu,  8 Oct 2026 07:44:25 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id BE99E1800446;
	Thu,  8 Oct 2026 07:44:20 +0000 (UTC)
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
Subject: [PATCH v15 4/8] netfs: Add some tools for managing a position in a bvecq chain
Date: Thu,  8 Oct 2026 08:43:40 +0100
Message-ID: <20261008074346.936909-5-dhowells@redhat.com>
In-Reply-To: <20261008074346.936909-1-dhowells@redhat.com>
References: <20261008074346.936909-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Provide a selection of tools for holding and managing a position within a
bvec queue chain.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/bvecq.c      | 261 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/bvecq.h | 184 +++++++++++++++++++++++++++++
 2 files changed, 445 insertions(+)

diff --git a/fs/netfs/bvecq.c b/fs/netfs/bvecq.c
index 5b747f6b5938..d0e2b9ccda3e 100644
--- a/fs/netfs/bvecq.c
+++ b/fs/netfs/bvecq.c
@@ -342,3 +342,264 @@ int bvecq_expand_buffer(struct bvecq **_buffer, size_t *_cur_size, size_t size,
 	return 0;
 }
 EXPORT_SYMBOL(bvecq_expand_buffer);
+
+/**
+ * bvecq_buffer_init - Initialise a buffer and set position
+ * @pos: The position to point at the new buffer.
+ * @gfp: The allocation constraints.
+ * @for_writeback: True if allocating for writeback
+ *
+ * Initialise a rolling buffer.  We allocate an unpopulated bvecq node to so
+ * that the pointers can be independently driven by the producer and the
+ * consumer.
+ *
+ * Return 0 if successful; -ENOMEM on allocation failure.
+ */
+int bvecq_buffer_init(struct bvecq_pos *pos, gfp_t gfp, bool for_writeback)
+{
+	struct bvecq *bq;
+
+	bq = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, for_writeback);
+	if (!bq)
+		return -ENOMEM;
+
+	pos->bvecq  = bq; /* Comes with a ref. */
+	pos->slot   = 0;
+	pos->offset = 0;
+	return 0;
+}
+
+/**
+ * bvecq_buffer_append - Append a new bvecq node to a buffer
+ * @pos: The position of the last node.
+ * @bq: The buffer to add.
+ *
+ * Add a new node on to the buffer chain at the specified position, either
+ * because the previous one is full or because we have a discontiguity to
+ * contend with, and update @pos to point to it.
+ */
+void bvecq_buffer_append(struct bvecq_pos *pos, struct bvecq *bq)
+{
+	struct bvecq *head = pos->bvecq;
+
+	pos->bvecq = bvecq_get(bq);
+	pos->slot = 0;
+	pos->offset = 0;
+
+	/* [!] NOTE: After we set head->next, the consumer is at liberty to
+	 * immediately delete the old head.
+	 */
+	bvecq_append(head, bq);
+	bvecq_put(head);
+}
+
+/**
+ * bvecq_pos_advance - Advance a bvecq position
+ * @pos: The position to advance.
+ * @amount: The amount of bytes to advance by.
+ *
+ * Advance the specified bvecq position by @amount bytes.  @pos is updated and
+ * bvecq ref counts may have been manipulated.  If the position hits the end of
+ * the queue, then it is left pointing beyond the last slot of the last bvecq
+ * so that it doesn't break the chain.
+ */
+void bvecq_pos_advance(struct bvecq_pos *pos, size_t amount)
+{
+	struct bvecq *bq = pos->bvecq, *next;
+	unsigned int slot = pos->slot;
+	size_t offset = pos->offset;
+
+	while (amount) {
+		size_t part;
+
+		if (!bvecq_acquire_slot(bq, slot)) {
+			next = bvecq_next(bq);
+			if (!next) {
+				/* We should not see the end of the list yet as
+				 * the chain must already have been populated
+				 * with sufficient slots to provide @amount of
+				 * bufferage before calling this function.
+				 */
+				WARN_ON_ONCE(amount > 0);
+				break;
+			}
+			if (bvecq_acquire_slot(bq, slot))
+				continue; /* More slots got added. */
+			bq = next;
+			slot = 0;
+			offset = 0;
+			continue;
+		}
+
+		part = bq->bv[slot].bv_len - offset;
+
+		if (part > amount) {
+			offset += amount;
+			break;
+		}
+		amount -= part;
+		offset = 0;
+		slot++;
+	}
+
+	pos->slot   = slot;
+	pos->offset = offset;
+	bvecq_pos_move(pos, bq);
+}
+
+/*
+ * Clear part of the memory pointed to by a bio_vec.
+ */
+static void bvec_zero(const struct bio_vec *bv, size_t offset, size_t len)
+{
+	struct page *page = bv->bv_page;
+
+	offset += bv->bv_offset;
+
+	page  += offset / PAGE_SIZE;
+	offset = offset % PAGE_SIZE;
+
+	while (len) {
+		size_t part = min(len, PAGE_SIZE - offset);
+		char *p = kmap_local_page(page);
+
+		memset(p + offset, 0, part);
+		kunmap_local(p);
+
+		len -= part;
+		offset = 0;
+		page++;
+	}
+}
+
+/**
+ * bvecq_zero - Clear memory starting at the bvecq position.
+ * @pos: The position in the bvecq chain to start clearing.
+ * @amount: The number of bytes to clear.
+ *
+ * Clear memory fragments pointed to by a bvec queue.  @pos is updated and
+ * bvecq ref counts may have been manipulated.  If the position hits the end of
+ * the queue, then it is left pointing beyond the last slot of the last bvecq
+ * so that it doesn't break the chain.
+ *
+ * Return: The number of bytes cleared.
+ */
+ssize_t bvecq_zero(struct bvecq_pos *pos, size_t amount)
+{
+	struct bvecq *bq = pos->bvecq, *next;
+	unsigned int slot = pos->slot;
+	ssize_t cleared = 0;
+	size_t offset = pos->offset;
+
+	while (amount) {
+		const struct bio_vec *bv;
+		size_t part;
+
+		if (!bvecq_acquire_slot(bq, slot)) {
+			next = bvecq_next(bq);
+			if (!next) {
+				/* We should not see the end of the list yet as
+				 * the chain must already have been populated
+				 * with sufficient slots to provide @amount of
+				 * bufferage before calling this function.
+				 */
+				WARN_ON_ONCE(amount > 0);
+				break;
+			}
+			if (bvecq_acquire_slot(bq, slot))
+				continue; /* More slots got added. */
+			bq = next;
+			slot = 0;
+			offset = 0;
+			continue;
+		}
+
+		bv = &bq->bv[slot];
+		if (offset >= bv->bv_len) {
+			slot++;
+			offset = 0;
+			continue;
+		}
+
+		part = min(bv->bv_len - offset, amount);
+		if (part > 0)
+			bvec_zero(bv, offset, part);
+		cleared += part;
+		offset += part;
+		amount -= part;
+	}
+
+	pos->slot   = slot;
+	pos->offset = offset;
+	bvecq_pos_move(pos, bq);
+	return cleared;
+}
+
+/**
+ * bvecq_slice - Find a slice of a bvecq queue
+ * @pos: The position to start at.
+ * @max_size: The maximum size of the slice (or ULONG_MAX).
+ * @max_slots: The maximum number of slots in the slice (or INT_MAX).
+ * @_nr_slots: Where to put the number of slots (updated).
+ *
+ * Determine the size and number of slots that can be obtained the next slice
+ * of bvec queue up to the maximum size and slot count specified.
+ *
+ * @pos is updated to the end of the slice.  If the position hits the end of
+ * the queue, then it is left pointing beyond the last slot of the last bvecq
+ * so that it doesn't break the chain.
+ *
+ * Return: The number of bytes in the slice.
+ */
+size_t bvecq_slice(struct bvecq_pos *pos, size_t max_size,
+		   unsigned int max_slots, unsigned int *_nr_slots)
+{
+	struct bvecq *bq, *next;
+	unsigned int slot = pos->slot, nslots = 0;
+	size_t size = 0, offset = pos->offset;
+
+	bq = pos->bvecq;
+	for (;;) {
+		for (; slot < bvecq_nr_slots_acquire(bq); slot++) {
+			const struct bio_vec *bvec = &bq->bv[slot];
+
+			if (offset < bvec->bv_len && bvec->bv_page) {
+				size_t part = min(bvec->bv_len - offset, max_size);
+
+				size += part;
+				offset += part;
+				max_size -= part;
+				nslots++;
+				if (!max_size || nslots >= max_slots)
+					goto out;
+			}
+			offset = 0;
+		}
+
+		/* pos->bvecq isn't allowed to go NULL as the queue may get
+		 * extended and we would lose our place.
+		 */
+		next = bvecq_next(bq);
+		if (!next)
+			break;
+		if (bvecq_acquire_slot(bq, slot))
+			continue; /* More slots got added. */
+		slot = 0;
+		bq = next;
+	}
+
+out:
+	*_nr_slots = nslots;
+	if (slot == bvecq_nr_slots_acquire(bq)) {
+		next = bvecq_next(bq);
+		if (next) {
+			bq = next;
+			slot = 0;
+			offset = 0;
+		}
+	}
+	bvecq_pos_move(pos, bq);
+	pos->slot = slot;
+	pos->offset = offset;
+	return size;
+}
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
index b984aaa44908..484c787a50f9 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -54,6 +54,16 @@ struct bvecq {
 /* Number of slots in a 4K bvecq. */
 #define BVECQ_4KB_SLOTS  ((4096 - sizeof(struct bvecq)) / sizeof(struct bio_vec))
 
+/*
+ * Position in a bio_vec queue.  The bvecq holds a ref on the queue segment it
+ * points to.
+ */
+struct bvecq_pos {
+	struct bvecq		*bvecq;		/* The first bvecq */
+	unsigned int		offset;		/* The offset within the starting slot */
+	u16			slot;		/* The starting slot */
+};
+
 void bvecq_dump(const struct bvecq *bq);
 struct bvecq *bvecq_alloc_one(size_t nr_slots, gfp_t gfp, bool for_writeback);
 struct bvecq *bvecq_alloc_chain(size_t nr_slots, gfp_t gfp, bool for_writeback);
@@ -61,6 +71,12 @@ struct bvecq *bvecq_alloc_buffer2(size_t size, unsigned int pre_slots, gfp_t gfp
 				  bool for_writeback);
 void bvecq_put(struct bvecq *bq);
 int bvecq_expand_buffer(struct bvecq **_buffer, size_t *_cur_size, size_t size, gfp_t gfp);
+int bvecq_buffer_init(struct bvecq_pos *pos, gfp_t gfp, bool for_writeback);
+void bvecq_buffer_append(struct bvecq_pos *pos, struct bvecq *bq);
+void bvecq_pos_advance(struct bvecq_pos *pos, size_t amount);
+ssize_t bvecq_zero(struct bvecq_pos *pos, size_t amount);
+size_t bvecq_slice(struct bvecq_pos *pos, size_t max_size,
+		   unsigned int max_slots, unsigned int *_nr_slots);
 
 /**
  * bvecq_alloc_buffer - Allocate a bvecq chain and populate with buffers
@@ -163,4 +179,172 @@ static inline struct bvecq *bvecq_next(const struct bvecq *bq)
 	return smp_load_acquire(&bq->next);
 }
 
+/**
+ * bvecq_pos_set - Set one position to be the same as another
+ * @pos: The position object to set
+ * @at: The source position.
+ *
+ * Set @pos to have the same position as @at.  This may take a ref on the
+ * bvecq pointed to.
+ */
+static inline void bvecq_pos_set(struct bvecq_pos *pos, const struct bvecq_pos *at)
+{
+	*pos = *at;
+	bvecq_get(pos->bvecq);
+}
+
+/**
+ * bvecq_pos_unset - Unset a position
+ * @pos: The position object to unset
+ *
+ * Unset @pos.  This does any needed ref cleanup.
+ */
+static inline void bvecq_pos_unset(struct bvecq_pos *pos)
+{
+	bvecq_put(pos->bvecq);
+	pos->bvecq = NULL;
+	pos->slot = 0;
+	pos->offset = 0;
+}
+
+/**
+ * bvecq_pos_transfer - Transfer one position to another, clearing the first
+ * @pos: The position object to set
+ * @from: The source position to clear.
+ *
+ * Set @pos to have the same position as @from and then clear @from.  This may
+ * transfer a ref on the bvecq pointed to.
+ */
+static inline void bvecq_pos_transfer(struct bvecq_pos *pos, struct bvecq_pos *from)
+{
+	*pos = *from;
+	from->bvecq = NULL;
+	from->slot = 0;
+	from->offset = 0;
+}
+
+/**
+ * bvecq_pos_move - Update a position to a new bvecq
+ * @pos: The position object to update.
+ * @to: The new bvecq to point at.
+ *
+ * Update @pos to point to @to if it doesn't already do so.  This may
+ * manipulate refs on the bvecqs pointed to.
+ */
+static inline void bvecq_pos_move(struct bvecq_pos *pos, struct bvecq *to)
+{
+	struct bvecq *old = pos->bvecq;
+
+	if (old != to) {
+		pos->bvecq = bvecq_get(to);
+		bvecq_put(old);
+	}
+}
+
+/**
+ * bvecq_pos_nudge - Nudge a position onto the next segment if current used up
+ * @pos: The position object to nudge.
+ *
+ * Update @pos to point to the next segment in the chain if we've used up the
+ * current segment.  This may manipulate refs on the bvecqs pointed to.
+ *
+ * Return: true if found a new segment, false if hit the end.
+ */
+static inline bool bvecq_pos_nudge(struct bvecq_pos *pos)
+{
+	struct bvecq *bq = pos->bvecq, *next;
+
+	for (;;) {
+		if (!bvecq_acquire_slot(bq, pos->slot)) {
+			next = bvecq_next(bq);
+			if (!next)
+				return false;
+			if (bvecq_acquire_slot(next, pos->slot))
+				continue; /* More slots got added. */
+			bq = next;
+			bvecq_pos_move(pos, bq);
+			pos->slot = 0;
+			pos->offset = 0;
+			continue;
+		}
+		if (pos->offset >= bq->bv[pos->slot].bv_len) {
+			pos->slot++;
+			pos->offset = 0;
+			continue;
+		}
+		return true;
+	}
+}
+
+/**
+ * bvecq_pos_step - Step a position to the next slot if possible
+ * @pos: The position object to step.
+ *
+ * Update @pos to point to the next slot in the queue if not at the end.  This
+ * may manipulate refs on the bvecqs pointed to.
+ *
+ * Return: true if successful, false if was at the end.
+ */
+static inline bool bvecq_pos_step(struct bvecq_pos *pos)
+{
+	struct bvecq *bq = pos->bvecq, *next;
+
+	pos->slot++;
+	pos->offset = 0;
+	if (bvecq_acquire_slot(bq, pos->slot))
+		return true;
+	next = bvecq_next(bq);
+	if (!next)
+		return false;
+	if (bvecq_acquire_slot(bq, pos->slot))
+		return true;
+	bvecq_pos_move(pos, next);
+	pos->slot = 0;
+	return true;
+}
+
+/**
+ * bvecq_delete_spent - Delete the bvecq at the front if possible
+ * @pos: The position object to update.
+ *
+ * Delete the used up bvecq at the front of the queue that @pos points to if it
+ * is not the last node in the queue; if it is the last node in the queue, it
+ * is kept so that the queue doesn't become detached from the other end.  This
+ * may manipulate refs on the bvecqs pointed to.  It is also possible that the
+ * producer will fill more slots in the current bvecq.
+ *
+ * Also, we have to be very careful: the consumer can catch the producer, which
+ * could lead to us having nothing left in the queue, causing the front and
+ * back pointers to end up on different tracks.  To avoid this, we must always
+ * keep at least one segment in the queue.
+ *
+ * The caller must reload from @pos after calling this.
+ *
+ * Return: true if there's more available; false if not.
+ */
+static inline bool bvecq_delete_spent(struct bvecq_pos *pos)
+{
+	struct bvecq *spent = pos->bvecq;
+	struct bvecq *next;
+	unsigned int slot = pos->slot;
+
+again:
+	/* Read the contents of the queue node after the pointer to it. */
+	next = bvecq_next(spent);
+	if (slot < bvecq_nr_slots_acquire(spent))
+		return true; /* The producer added more. */
+	if (!next)
+		return false; /* Nothing more to consume at the moment. */
+	next->prev = NULL;
+	bvecq_pos_move(pos, next);
+	pos->slot = 0;
+	pos->offset = 0;
+	if (!bvecq_acquire_slot(next, 0)) {
+		spent = next;
+		slot = 0;
+		goto again;
+	}
+	return true;
+}
+
 #endif /* _LINUX_BVECQ_H */

