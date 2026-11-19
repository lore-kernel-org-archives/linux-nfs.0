Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795077577;
	b=5LDTh3XUl784R+k/UpCwfM3x62vSPXvptRa2zoo9iQVoqhpjKm6R2m/UH8t9P2WcfEy2
	 3URRZ/l0jSh+bWrmlo0ofqNtGda0tAVk700qCo7RYql7Te/MrcqkV8XXOuPuvg+bv3Ru9
	 e7J05yWRDWM0p33wfJDqJ3WZUzyRw1rd73rqqx6D1Mmw4si4o/XQmu0T3JX71y2DrtWKg
	 srun4FMqPfkL26DPjCh8z7LtQnIKfiSqZz9VFHaHThwuFEA9bOfWBi6UQz/ZIiHN0mg4g
	 bYfMm0tKeQzm+49dnSATI8k8H6icPJmp5TaJQfAhiptdAWAvDsH0WfaQAUNti/JiGlQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795077577;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=9rZs/kVoqWwbdXCKmjPqC1JbQ/GWaqCvbtg+S62dX6k=;
	b=oQfylnvQ40fEVtmCse2NcZ3t8wOFsq39xsRryBc6+6xKAxiC0h+cMCpaSzz0VKNTgXI/
	 2t3Mcc8ENAxRHHPu1jqG3kFJ4nhGVNvykZ/KWIU3sapqCbqrV1y9wXRGsHnZJACU/RCSp
	 EK75tKIa+cgyG+8V+gIGKvDxH+9Cwg4cvduwfyz8/YWAxysXKGxfSJco29LuWsNwEgeND
	 vFn5VkLr5j5GdP/d76C5al7EC+oYpHLPjqOhP/TlaiY3HXFxrkZFJAmx6Ho7OcbsIp1wx
	 3QvnenBm+87/FkZqZzYiuJotvrzFWLT4Mf6cMUWjOEi/hySt8nBH5A4zEmxeCW5AMRg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cxtk6wfh;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D365606A32F
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 08:39:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4D365606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cxtk6wfh
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795077576;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=9rZs/kVoqWwbdXCKmjPqC1JbQ/GWaqCvbtg+S62dX6k=;
	b=cxtk6wfhBkAovaRw3dKxE/ys/VqoRt49GYEvdR2VJCLeyChkYxVrC9HPYugwVOsbxnsXWz
	I3Vy4wJU4f+cIMBSXNzV/18y8w8OPkdgXEF/ILkmB8HyEHMwej/V/d70xGkbrBIoqxQuqv
	uWrEo8LQFxP165mxgoD5WWO12lIO/h8=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-400-ZU1akQXfNG-sbf3u1sfRmA-1; Thu,
 19 Nov 2026 03:39:32 -0500
X-MC-Unique: ZU1akQXfNG-sbf3u1sfRmA-1
X-Mimecast-MFC-AGG-ID: ZU1akQXfNG-sbf3u1sfRmA_1795077570
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id B2BE81800556;
	Thu, 19 Nov 2026 08:39:29 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 347A030000E8;
	Thu, 19 Nov 2026 08:39:25 +0000 (UTC)
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
Subject: [PATCH v19 05/17] iov_iter: Add an API document for the bvecq structure
Date: Thu, 19 Nov 2026 08:38:36 +0000
Message-ID: <20261119083851.3306418-6-dhowells@redhat.com>
In-Reply-To: <20261119083851.3306418-1-dhowells@redhat.com>
References: <20261119083851.3306418-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

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
 Documentation/core-api/bvecq.rst | 259 +++++++++++++++++++++++++++++++
 Documentation/core-api/index.rst |   1 +
 MAINTAINERS                      |   1 +
 fs/netfs/bvecq.c                 |   2 +
 include/linux/bvecq.h            |   2 +
 5 files changed, 265 insertions(+)
 create mode 100644 Documentation/core-api/bvecq.rst

diff --git a/Documentation/core-api/bvecq.rst b/Documentation/core-api/bvecq.rst
new file mode 100644
index 000000000000..7e06ca81512a
--- /dev/null
+++ b/Documentation/core-api/bvecq.rst
@@ -0,0 +1,259 @@
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
+				      unsigned int *flags);
+	struct bvecq *bvecq_alloc_chain(size_t nr_slots,
+					gfp_t gfp,
+					unsigned int *flags);
+	struct bvecq *bvecq_alloc_buffer(size_t size,
+					 gfp_t gfp,
+					 unsigned int *flags);
+	struct bvecq *bvecq_alloc_buffer2(size_t size,
+					  unsigned int pre_slots,
+					  gfp_t gfp,
+					  unsigned int *flags);
+
+The first of these, ``bvecq_alloc_one()`` allocates a single bvecq with at
+least the requested number of inline slots.  The size of the object is rounded
+up to the size of the slab granule that it will be allocated in and the number
+of slots increased appropriately to match.
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
+chain.  ``bvecq_alloc_buffer2()`` is similar, but it reserves some unused slots
+at the front of the chain.  Note that these functions may add multipage pages
+in the future.
+
+With regard to the ``*flags``, if ``BVECQ_USE_REQ_POOL`` or
+``BVECQ_USE_SUBREQ_POOL`` is set therein, then the netfslib writeback bvecq
+pools will be used to backstop the allocation if the initial slab request
+fails; in such a case, the number of slots in the affected bvecq will be
+``BVECQ_POOL_SLOTS`` and ``*flags`` will have ``BVECQ_HIT_OOM`` set in it.
+
+There are two pools, one for use at the request level and one at the subrequest
+level so that a process which has allocated at one level won't then deadlock
+against the other.  The request-level pool allows 50 processes in and offers
+them 2 bvecqs each.  The subrequest-level pool allows 2 processes in and offers
+them sufficient bvecqs to point at 16MiB worth of pages each.
+
+For the chain and buffer allocation functions, if ``BVECQ_SHORT_OKAY`` is set
+in ``*flags`` then the returned chain may be shorter than requested if an OOM
+condition is hit but the appropriate mempool is tapped.  In such a case,
+``BVECQ_HIT_OOM`` will have been set in ``*flags``.
+
+Access to the bvecq mempools are throttled.  Only a certain number of processes
+may be using each pool at any one time and if the calling process is granted
+access, ``BVECQ_HOLD_POOL_SEM`` is set in the flags.  To end the emergency pool
+state, the caller must call::
+
+	void bvecq_pool_unlock(unsigned int *flags);
+
+after it is done allocating with the flags left by the last allocation call.
+It is not required that a process has returned all the objects from the pool
+when it calls this - but it is required to have returned all the objects before
+it can allocate from the pool again.
+
+Whilst holding a count on the semaphore, it may over-allocate a little from the
+pool, but must return what it has allocated as soon as possible and may then
+continue allocating as long as it holds the semaphore.
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
index 250d0e324d49..a57adc745196 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10386,6 +10386,7 @@ M:	Paulo Alcantara <pc@manguebit.org>
 L:	netfs@lists.linux.dev
 L:	linux-fsdevel@vger.kernel.org
 S:	Supported
+F:	Documentation/core-api/bvecq.rst
 F:	Documentation/filesystems/caching/
 F:	Documentation/filesystems/netfs_library.rst
 F:	fs/netfs/
diff --git a/fs/netfs/bvecq.c b/fs/netfs/bvecq.c
index b140cd47a1fa..4109bf4490ed 100644
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
index f670a031ac44..1519de6d679b 100644
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

