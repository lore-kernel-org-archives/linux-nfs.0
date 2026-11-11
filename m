Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794429085;
	b=DhvCTQJOLyNcTLlvJGDAqLC8MihREpa+hocoSNXVpoZMEU0v/m2sHnEXh2oNY+tM9kqo
	 OldN2iVZ2dvJWw7e0QZXUFZil3Ex9UwsmYTmMXxcFw43ax5b5BXH3Cj8Sb7yLx/paq8fG
	 RKYnKamErEp2sEZjw6NNlI0dSbqG0kf0uxwXNVQE/Nc2afEU5NtZOUvoafks1l8XR1A7v
	 yav7UFRUp5/aib4cq+ggGQITBJ73HMLkXoD90yvfmQ7TgnkXxcoU4x0ogFUNk4OJ7bcaY
	 7Vr7XbHy3S3wqNpF+hwZj0d32uErH6SbZu5aa/eVdwKP6OeYzBQaLcRllFwm6z8eXxA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794429085;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=4epxfFkeNiORjk5SpUCQViX5ep7Wh1OUzhnqYEnkKnA=;
	b=4mcs5KCdj4aFo9EkH5pEBorcJmx8bz4xDDQgXmYLeEKdQLELZO3sj4nlUFHrHC6UJjeT
	 dgEYZjIhGrXAo/mvDMOFteUT726S5dTyK2GjWZaR3QJetRkwSznQQ5yChNiM6l4PlSUhq
	 l6lcXm4kWxlGdlCjN8Y4rkk8RwnaVucprXVjj+XVQt9C9BKmuX/mEOlNLx1IMkN7BNRXG
	 Hh0msYq5Z5ubTRX1o5gil/TAjvc5+ZVZjc9GQtratkhBkz9MFaOvh0GsXMRWusxrgpRCS
	 thppqP5CGdpJp+Ovm3xV9xbZfnsmvoqWG9Cj+6YMU5AhV1hZAxz4uiRQsxLDq3F0+Pg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=OWcRbDLq;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1F4E606A337
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 20:31:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F1F4E606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=OWcRbDLq
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794429084;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4epxfFkeNiORjk5SpUCQViX5ep7Wh1OUzhnqYEnkKnA=;
	b=OWcRbDLqh0pFaOioVX9w4bV1JB0bjbdiKIvcWYFTmXS/IVoklZ+IIu+9zAgReILv6v4/mc
	4EKyFc96sZSHdUm5KpqLhDwPrwvfT9bGKNzl0kpr5nVkoqt9/BcFsDwcCNyPA7sUQTkvu5
	SeEYsgHgV7kYRXMuYJvY2cjAjA8PkR0=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-537-qbDZ1xjJN8eIqHB3wL1a4Q-1; Wed,
 11 Nov 2026 15:31:18 -0500
X-MC-Unique: qbDZ1xjJN8eIqHB3wL1a4Q-1
X-Mimecast-MFC-AGG-ID: qbDZ1xjJN8eIqHB3wL1a4Q_1794429074
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 6E4E91956089;
	Wed, 11 Nov 2026 20:31:13 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 201791800546;
	Wed, 11 Nov 2026 20:31:08 +0000 (UTC)
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
	Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-block@vger.kernel.org
Subject: [PATCH v17 05/17] iov_iter: Add an API document for the bvecq structure
Date: Wed, 11 Nov 2026 20:30:18 +0000
Message-ID: <20261111203034.2126314-6-dhowells@redhat.com>
In-Reply-To: <20261111203034.2126314-1-dhowells@redhat.com>
References: <20261111203034.2126314-1-dhowells@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Add an API description document for the bvecq structure.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara (Red Hat) <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-block@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 Documentation/core-api/bvecq.rst | 229 +++++++++++++++++++++++++++++++
 Documentation/core-api/index.rst |   1 +
 MAINTAINERS                      |   1 +
 fs/netfs/bvecq.c                 |   2 +
 include/linux/bvecq.h            |   2 +
 5 files changed, 235 insertions(+)
 create mode 100644 Documentation/core-api/bvecq.rst

diff --git a/Documentation/core-api/bvecq.rst b/Documentation/core-api/bvecq.rst
new file mode 100644
index 000000000000..4a2b3e288982
--- /dev/null
+++ b/Documentation/core-api/bvecq.rst
@@ -0,0 +1,229 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+=========================================
+bvecq - Chainable bio_vec queue structure
+=========================================
+
+Author: David Howells <dhowells@redhat.com>
+
+.. Contents:
+
+ * Overview
+ * Allocating bvecqs
+ * Refcounting
+ * Expandable buffer
+ * Producer functions
+ * Consumer functions
+ * Utility functions
+ * I/O iterators
+ * API Function Reference
+
+
+Overview
+========
+
+The ``bvecq`` struct can be used to form chains of arrays of ``bio_vec``
+structures - kind of a single layer of indirection.  Each bvecq segment points
+to the previous and next bvecq segments in the chain, but is not intended to
+form a circular queue as there are applications where the producer is adding to
+one end whilst the consumer is taking off the other.
+
+To use this, the caller should do::
+
+	#include <linux/bvecq.h>
+
+The publicly accessible members of the structure are::
+
+	struct bvecq {
+		struct bvecq	*next;
+		struct bvecq	*prev;
+		u32		priv;
+		u16		nr_slots;
+		u16		max_slots;
+		enum bvecq_mem	mem_type:3;
+		struct bio_vec	*bv;
+		...
+	};
+
+A pair of pointers are provided, ``next`` and ``prev``, that point to the
+segments on either side of the segment being accessed.  Whilst this is a
+doubly-linked list, it is intentionally not a circular list; the outward
+sibling pointers in terminal segments should be NULL.
+
+The ``priv`` member is for the owner of the bvecq to use as they will.
+
+The ``bv`` pointer points at an array of bio_vecs that list a number of regions
+of memory.  ``max_slots`` indicates how large the array is and ``nr_slots``
+says how much of the array is being used.  Note that there are access functions
+for nr_slots that insert appropriate barriering in the case that there are
+separate producer and consumer threads.
+
+The ``mem_type`` member informs bvecq_put() of how to clean up the bio_vecs
+attached to this segment.  It can be one of:
+
+ * ``BVECQ_MEM_EXTERNAL`` - Externally managed; no cleanup.
+ * ``BVECQ_MEM_PAGECACHE`` - Part of pagecache; put_page() used.
+ * ``BVECQ_MEM_GUP`` - Pinned userspace memory; unpin_user_page() used.
+ * ``BVECQ_MEM_ALLOCED`` - Allocated page; __free_pages() used, may be pooled.
+
+
+Allocating bvecqs
+=================
+
+A number of functions are provided to allocate bvecqs::
+
+	struct bvecq *bvecq_alloc_one(size_t nr_slots,
+				      gfp_t gfp,
+				      bool for_writeback);
+	struct bvecq *bvecq_alloc_chain(size_t nr_slots,
+					gfp_t gfp,
+					bool for_writeback);
+	struct bvecq *bvecq_alloc_buffer(size_t size,
+					 gfp_t gfp,
+					 bool for_writeback);
+	struct bvecq *bvecq_alloc_buffer2(size_t size,
+					  unsigned int pre_slots,
+					  gfp_t gfp,
+					  bool for_writeback);
+
+The first of these, ``bvecq_alloc_one()`` allocates a single bvecq with at
+least the requested number of inline slots.  The size of the object is rounded
+up to the size of the slab granule that it will be allocated in and the number
+of slots increased appropriately to match.  If ``for_writeback`` is set, then
+the netfslib writeback bvecq pool will be used to backstop the allocation if
+the initial slab request fails; in such a case, the number of slots will get
+reduced to ``BVECQ_POOL_SLOTS``.
+
+Two convenience slot count constants are provided:
+
+ * ``BVECQ_POOL_SLOTS`` - The right number of slots to alloc from the mempool
+ * ``BVECQ_4KB_SLOTS`` - The right number of slots to get a 4K allocation
+
+``bvecq_alloc_chain()`` will allocate a sufficiently large chain of bvecqs to
+hold the requested number of slots, capping each allocation at 4K.
+
+``bvecq_alloc_buffer()`` will allocate a chain and populate it, allocating
+sufficient pages to provide a buffer of the specified size attached to the
+chain.  ``bvecq_alloc_buffer2()`` is similar, but it reserves some unused
+slots at the front of the chain.  Note that these functions may add multipage
+pages in the future.
+
+
+Refcounting
+===========
+
+Each bvecq has a refcount and two functions are provided to handle that::
+
+	struct bvecq *bvecq_get(struct bvecq *bq);
+	void bvecq_put(struct bvecq *bq);
+
+The first of these gets a new reference and the second drops a reference.  When
+the refcount hits zero, the second iteratively drops the refs along the chain
+until it hits a segment that has a refcount that doesn't reduce to zero.
+
+
+Expandable buffer
+=================
+
+This facility provides a function to manage an expandable buffer::
+
+	int bvecq_expand_buffer(struct bvecq **_buffer,
+				size_t *_cur_size,
+				size_t size,
+				gfp_t gfp);
+
+Pages are added to the bvecq chain and the chain expanded such that, on
+returning, it holds ``size`` amount of space (without losing any content).  The
+caller needs to retain ``*_cur_size`` between calls as that tracks the amount
+of space currently allocated.  Note that pages in the chain may be allocated as
+compound pages larger than PAGE_SIZE.
+
+
+Producer functions
+==================
+
+When building and filling a bvecq, there are a number of utility functions that
+can be used to provide the correct barriering and to query the fields in the
+bvecq currently being filled.
+
+Firstly, there's a function to check to see if a bvecq has any spare slots
+left::
+
+	bool bvecq_is_full(const struct bvecq *bvecq);
+
+If not, ``bvecq_alloc_one()`` can be called to allocate a new segment which can
+be initialised and then added to the chain with::
+
+	void bvecq_append(struct bvecq *to, struct bvecq *add);
+
+bio_vec slots in the segment can then be filled and the number of occupied
+slots updated by calling::
+
+	void bvecq_filled_to(struct bvecq *bvecq,
+			     unsigned int to);
+
+to insert the appropriate barrier.
+
+
+Consumer functions
+==================
+
+When consuming and destroying a bvecq, there are some utility functions for
+that too, providing the needed barriering.  Firstly, there's a function to find
+out how many slots have been used in the current bvecq::
+
+	unsigned int bvecq_nr_slots_acquire(const struct bvecq *bvecq);
+
+Or, more conveniently, if the current slot position is valid within the bvecq::
+
+	bool bvecq_acquire_slot(const struct bvecq *bvecq,
+				unsigned int slot);
+
+If this returns true, the slot is valid and can be looked at; if it returns
+false, the bvecq may have been consumed.  If it has, the next bvecq can be
+obtained by calling::
+
+	struct bvecq *bvecq_next(const struct bvecq *bq);
+
+which inserts the appropriate barrier - though bvecq_acquire_slot should be
+rechecked after calling this in case the producer added more slots and then
+extended the list.
+
+
+Utility functions
+=================
+
+A utility function is provided to list the bio_vecs pointed to by a bvecq
+chain::
+
+	void bvecq_dump(const struct bvecq *bq);
+
+
+I/O iterators
+=============
+
+bvecq chains can be used with the ``iov_iter`` facility too.  An iterator can
+be initialised to point at a chain by calling::
+
+	void iov_iter_bvec_queue(struct iov_iter *i,
+				 unsigned int direction,
+				 const struct bvecq *bvecq,
+				 unsigned int first_slot,
+				 unsigned int offset,
+				 size_t count);
+
+In addition to setting the iterator, direction and count, the first bvecq in
+the chain to be iterated over is set, along with the starting slot in that
+iterator and the offset into the slot.  Once the iterator is set up, it can be
+treated like any other I/O iterator.
+
+In a producer/consumer environment, it is expected that when an iterator is set
+up, all the bvecqs and all the slots within the count of the iterator must
+exist and must be populated before this function is called.
+
+
+API Function Reference
+======================
+
+.. kernel-doc:: include/linux/bvecq.h
+.. kernel-doc:: fs/netfs/bvecq.c
diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index 92f91c6a0d79..e39edef58ab6 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -39,6 +39,7 @@ Library functionality that is used throughout the kernel.
    kref
    cleanup
    assoc_array
+   bvecq
    folio_queue
    xarray
    maple_tree
diff --git a/MAINTAINERS b/MAINTAINERS
index 6fa777744163..9cb3785a5bd2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10382,6 +10382,7 @@ M:	Paulo Alcantara <pc@manguebit.org>
 L:	netfs@lists.linux.dev
 L:	linux-fsdevel@vger.kernel.org
 S:	Supported
+F:	Documentation/core-api/bvecq.rst
 F:	Documentation/filesystems/caching/
 F:	Documentation/filesystems/netfs_library.rst
 F:	fs/netfs/
diff --git a/fs/netfs/bvecq.c b/fs/netfs/bvecq.c
index 1d4da3de9b9d..f1264ae52033 100644
--- a/fs/netfs/bvecq.c
+++ b/fs/netfs/bvecq.c
@@ -3,6 +3,8 @@
  *
  * Copyright (C) 2026 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
+ *
+ * See also Documentation/core-api/bvecq.rst
  */
 
 #include <linux/bvecq.h>
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
index d9d3dd487a27..90e6eb9588bf 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -3,6 +3,8 @@
  *
  * Copyright (C) 2026 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
+ *
+ * See also Documentation/core-api/bvecq.rst
  */
 
 #ifndef _LINUX_BVECQ_H

