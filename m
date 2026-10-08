Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5C9F52EEE92
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 07:44:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791445499; cv=none; b=LaeyKMAp4o3huFSa/nTwlFcTAdlTtcQLC9qivkFDbc6ZWogSM3wlts5PQs1o+8oncOt+wVyqgQDY7sWleZ2Wfh2y7kMPIiXDSSNPWieHMfrSXRsKU9hNPZ6Zuw5RKD/sXhoYQilKkf2O6pCqQBfel4bF5UUAv5abKYFppyhLs5c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791445499; c=relaxed/simple;
	bh=IlcoHN7JNkHXDwXm/mQtEmVYfwGaHkZnL0Ur5UE2D9I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uWVw+evi8syjhLYrfDw/MG1AsJiZqr5k5DGhGS1Qh8AP33vz0CtakgwKaDEVKnxJL1I/Wz2tuqs/l+ZWDUwEUPkBrKEsIhSSwHUKEuKYT3al5FV2+bttTZvxqcEAqdFNA5q/6V3INk3hOmPiVnoFItSJd+LcYVwUmbBVRFuzpZc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Lk/9P3AG; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Lk/9P3AG"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791445489;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=XjY1qM0ro5GHcAO7UW/UcTkVjogNTS68Zw5VIxT/jPo=;
	b=Lk/9P3AG4nOiZbxN78UaN9CT+lUg7T5c/QSEKT/n1s+wUMUbyIXmyGZLti2z6S9bIPaTFW
	gHHD8KpUHXaNVFchtekR74fjJpOC6/7xTNk/7XeuuGC4M7ONjm63BRU/wAmcjNOwKE+Zmx
	3iXvNeuKRsT1iRQWKptrcYfhc1o4htw=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-692-9kxAvVTxOTeDz36ABx4lGg-1; Thu,
 08 Oct 2026 03:44:43 -0400
X-MC-Unique: 9kxAvVTxOTeDz36ABx4lGg-1
X-Mimecast-MFC-AGG-ID: 9kxAvVTxOTeDz36ABx4lGg_1791445481
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 50D9D1955EBA;
	Thu,  8 Oct 2026 07:44:40 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 5D260180034C;
	Thu,  8 Oct 2026 07:44:34 +0000 (UTC)
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
	Shyam Prasad N <sprasad@microsoft.com>,
	Tom Talpey <tom@talpey.com>
Subject: [PATCH v15 6/8] netfs: Use bvecq_pos to hold the buffer positions
Date: Thu,  8 Oct 2026 08:43:42 +0100
Message-ID: <20261008074346.936909-7-dhowells@redhat.com>
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

Use struct bvecq_pos to hold the position in a buffer for various things,
including the point at which memory segments are loaded into a rolling
buffer or are cleaned up from that buffer and the point at which a
subrequest's slice of buffer begins.

The position recorded by a bvecq_pos is a tuple of { bvecq, slot, offset }.
This is lighter weight than using a full iov_iter, though that would also
suffice.  If not NULL, the position also holds a reference on the bvecq it
is pointing to.

For unbuffered/DIO reads and writes and various buffered reads including
readahead, the iterator is extracted into the queue up front.  For buffered
writeback, the folios are added to the queue as the operation proceeds,
much as it does now with folio_queues.  For buffered reads and writes
through the pagecache, bv_len is set to the length of the entire folio and
then slices of the relevant[*] parts are passed to subrequests.

 [*] What's relevant for writing to the cache isn't necessarily the same as
     what's relevant for uploading to the server.

When setting up a subrequest, netfslib will furnish it with a slice of the
main buffer queue as a bvecq_pos, and, for the moment, an ITER_BVECQ
iterator is set to cover the slice in subreq->io_iter - though this will be
moved down into the filesystem in a later patch.

Notes on the implementation:

 (1) There are three positions on the netfs_io_request struct.  Not all are
     used by every request type.

     Firstly, there's ->load_cursor, which is used by buffered write and
     pgpriv2-copy to point to the next slot to have a folio inserted into
     it (e.g. when loading from writeback_iter()).

     Secondly, there's ->dispatch_cursor, which is used to provide the
     position in the buffer from which we start dispatching a subrequest.

     Thirdly, there's the ->collect_cursor, which is used by the collection
     routines to point to the next memory segment to be cleaned up.

 (2) There's one position on the netfs_io_subrequest struct, ->io_buffer,
     that records the position from which a subrequest's buffer begins.
     This is also used as the base of the position from which to retry
     (advanced by ->transfer).  For that reason, the filesystem is not
     allowed to change ->io_buffer for the moment.

 (3) Maintenance of the positions is done with helper functions, such as
     bvecq_pos_attach(), to abstract the refcounting.

 (4) When sending a read or a write to the cache, the ends of the slice
     will be rounded up/down to the backing file's DIO block alignment.

 (5) bvecq_slice() is used to select a slice of the source buffer and
     assign it to a subrequest.  The source buffer position is advanced.

 (6) netfs_extract_iter() is used by unbuffered/direct I/O API functions to
     decant a chunk of the iov_iter supplied by the VFS into a bvecq chain
     - and to label the bvecqs with appropriate disposal information
     (e.g. unpin, free, nothing).

There are further options that can be explored in the future:

 (1) Allow the provision of a duplicated bvecq chain for a specific slice
     so that the filesystem can add bits on either end (such as adding
     protocol headers and trailers and gluing several things together into
     a compound operation).

 (2) If a filesystem supports vectored/sparse read and write ops, it can be
     given a chain with discontiguities in it to perform in a single op
     (Ceph, for example, can do this).

 (3) Make MSG_SPLICE_PAGES handling read the disposal info in the bvecq and
     use that to indicate how it should get rid of the stuff it pasted into
     a sk_buff.

 (4) If a bounce buffer is needed (encryption, for example), the bounce
     buffer can be held in a bvecq and sliced up instead of the main buffer
     queue.

 (5) Get rid of subreq->io_iter and move the iov_iter stuff down into the
     filesystem.  The I/O iterators are normally only needed transitorily,
     and the one currently in netfs_io_subrequest is unnecessary most of
     the time.

rolling_buffer will be removed in a follow up patch.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Namjae Jeon <linkinjeon@kernel.org>
cc: Shyam Prasad N <sprasad@microsoft.com>
cc: Tom Talpey <tom@talpey.com>
cc: linux-cifs@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/afs/dir.c                 |   5 +-
 fs/afs/symlink.c             |   6 +-
 fs/cachefiles/io.c           |  12 ---
 fs/netfs/Makefile            |   1 -
 fs/netfs/buffered_read.c     | 182 ++++++++++++++++++++---------------
 fs/netfs/direct_read.c       |  54 ++++-------
 fs/netfs/direct_write.c      |  44 +++++----
 fs/netfs/internal.h          |   4 +-
 fs/netfs/iterator.c          |   2 +
 fs/netfs/misc.c              |  18 ----
 fs/netfs/objects.c           |   7 +-
 fs/netfs/read_collect.c      |  91 +++++++++---------
 fs/netfs/read_pgpriv2.c      |  88 ++++++++++++-----
 fs/netfs/read_retry.c        |  87 ++++++++++-------
 fs/netfs/read_single.c       |  16 ++-
 fs/netfs/write_collect.c     |  73 ++++++++------
 fs/netfs/write_issue.c       | 166 +++++++++++++++++++++-----------
 fs/netfs/write_retry.c       |  73 ++++++++------
 include/linux/netfs.h        |  15 ++-
 include/trace/events/netfs.h |  32 +++++-
 20 files changed, 579 insertions(+), 397 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 5fac02d2d281..39cba3f37ecd 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -2229,8 +2229,9 @@ static int afs_dir_writepages(struct address_space *mapping,
 
 	if (test_bit(AFS_VNODE_DIR_VALID, &dvnode->flags)) {
 		iov_iter_bvec_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0,
-				    i_size_read(&dvnode->netfs.inode));
-		ret = netfs_writeback_single(mapping, wbc, &iter);
+				    dvnode->directory_size);
+		ret = netfs_writeback_single(mapping, wbc, &iter,
+					     i_size_read(&dvnode->netfs.inode));
 		if (ret == 1)
 			ret = 0; /* Skipped write due to lock conflict. */
 	}
diff --git a/fs/afs/symlink.c b/fs/afs/symlink.c
index 9a611efe6b26..ae03ceff42b8 100644
--- a/fs/afs/symlink.c
+++ b/fs/afs/symlink.c
@@ -248,9 +248,9 @@ int afs_symlink_writepages(struct address_space *mapping,
 
 	if (vnode->directory &&
 	    atomic64_read(&vnode->cb_expires_at) != AFS_NO_CB_PROMISE) {
-		iov_iter_bvec_queue(&iter, ITER_SOURCE, vnode->directory, 0, 0,
-				    i_size_read(&vnode->netfs.inode));
-		ret = netfs_writeback_single(mapping, wbc, &iter);
+		iov_iter_bvec_queue(&iter, ITER_SOURCE, vnode->directory, 0, 0, PAGE_SIZE);
+		ret = netfs_writeback_single(mapping, wbc, &iter,
+					     i_size_read(&vnode->netfs.inode));
 	}
 
 	if (ret == 0) {
diff --git a/fs/cachefiles/io.c b/fs/cachefiles/io.c
index d05059822288..788439ea6e1c 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -546,7 +546,6 @@ static void cachefiles_issue_write(struct netfs_io_subrequest *subreq)
 	struct netfs_cache_resources *cres = &wreq->cache_resources;
 	struct cachefiles_object *object = cachefiles_cres_object(cres);
 	struct cachefiles_cache *cache = object->volume->cache;
-	struct netfs_io_stream *stream = &wreq->io_streams[subreq->stream_nr];
 	const struct cred *saved_cred;
 	size_t off, pre, post, len = subreq->len;
 	uoff_t start = subreq->start;
@@ -571,17 +570,6 @@ static void cachefiles_issue_write(struct netfs_io_subrequest *subreq)
 	}
 
 	/* We also need to end on the cache granularity boundary */
-	if (start + len == wreq->i_size) {
-		size_t part = len & (cache->bsize - 1);
-		size_t need = cache->bsize - part;
-
-		if (part && stream->submit_extendable_to >= need) {
-			len += need;
-			subreq->len += need;
-			subreq->io_iter.count += need;
-		}
-	}
-
 	post = len & (cache->bsize - 1);
 	if (post) {
 		len -= post;
diff --git a/fs/netfs/Makefile b/fs/netfs/Makefile
index b1ea4439c1bb..421dd0be413b 100644
--- a/fs/netfs/Makefile
+++ b/fs/netfs/Makefile
@@ -14,7 +14,6 @@ netfs-y := \
 	read_collect.o \
 	read_retry.o \
 	read_single.o \
-	rolling_buffer.o \
 	write_collect.o \
 	write_issue.o \
 	write_retry.o
diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index 052684ce1e34..06f79ea6a10a 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -114,26 +114,21 @@ static int netfs_begin_cache_read(struct netfs_io_request *rreq, struct netfs_in
 static ssize_t netfs_prepare_read_iterator(struct netfs_io_subrequest *subreq)
 {
 	struct netfs_io_request *rreq = subreq->rreq;
+	struct netfs_io_stream *stream = &rreq->io_streams[0];
+	ssize_t extracted;
 	size_t rsize = subreq->len;
 
 	if (subreq->source == NETFS_DOWNLOAD_FROM_SERVER)
-		rsize = umin(rsize, rreq->io_streams[0].sreq_max_len);
-
-	subreq->len = rsize;
-	if (unlikely(rreq->io_streams[0].sreq_max_segs)) {
-		size_t limit = netfs_limit_iter(&rreq->buffer.iter, 0, rsize,
-						rreq->io_streams[0].sreq_max_segs);
-
-		if (limit < rsize) {
-			subreq->len = limit;
-			trace_netfs_sreq(subreq, netfs_sreq_trace_limited);
-		}
+		rsize = umin(rsize, stream->sreq_max_len);
+
+	bvecq_pos_set(&subreq->io_buffer, &rreq->dispatch_cursor);
+	extracted = bvecq_slice(&rreq->dispatch_cursor, rsize,
+				stream->sreq_max_segs, &subreq->nr_segs);
+	if (extracted < subreq->len) {
+		subreq->len = extracted;
+		trace_netfs_sreq(subreq, netfs_sreq_trace_limited);
 	}
 
-	subreq->io_iter	= rreq->buffer.iter;
-
-	iov_iter_truncate(&subreq->io_iter, subreq->len);
-	rolling_buffer_advance(&rreq->buffer, subreq->len);
 	return subreq->len;
 }
 
@@ -192,6 +187,9 @@ void netfs_queue_read(struct netfs_io_request *rreq,
 static void netfs_issue_read(struct netfs_io_request *rreq,
 			     struct netfs_io_subrequest *subreq)
 {
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->io_buffer.bvecq,
+			    subreq->io_buffer.slot, subreq->io_buffer.offset, subreq->len);
+
 	switch (subreq->source) {
 	case NETFS_DOWNLOAD_FROM_SERVER:
 		rreq->netfs_ops->issue_read(subreq);
@@ -200,10 +198,9 @@ static void netfs_issue_read(struct netfs_io_request *rreq,
 		netfs_read_cache_to_pagecache(rreq, subreq);
 		break;
 	default:
-		__set_bit(NETFS_SREQ_CLEAR_TAIL, &subreq->flags);
-		subreq->error = 0;
-		iov_iter_zero(subreq->len, &subreq->io_iter);
+		bvecq_zero(&subreq->io_buffer, subreq->len);
 		subreq->transferred = subreq->len;
+		subreq->error = 0;
 		netfs_read_subreq_terminated(subreq);
 		break;
 	}
@@ -215,31 +212,31 @@ static void netfs_issue_read(struct netfs_io_request *rreq,
  * otherwise we set the deprecated PG_private_2.
  */
 static void netfs_mark_copy_to_cache(struct netfs_io_request *rreq,
-				     struct bvecq **bq,
-				     unsigned int *offset,
-				     int *slot,
-				     size_t len,
-				     bool copy)
+				     struct bvecq_pos *mark, size_t len, bool copy)
 {
+	struct bvecq *bq = mark->bvecq;
+	unsigned int offset = mark->offset;
+	int slot = mark->slot;
+
 	while (len > 0) {
-		struct folio *folio;
 		size_t fsize, overlap;
 
-		if (!*bq)
+		if (!bq)
 			break;
-		if (!bvecq_acquire_slot(*bq, *slot)) {
-			*bq = bvecq_next(*bq);
-			*slot = 0;
-			*offset = 0;
+		if (!bvecq_acquire_slot(bq, slot)) {
+			bq = bq->next;
+			slot = 0;
+			offset = 0;
 			continue;
 		}
 
 		/* Determine how much the subreq overlaps the folio, if at all. */
-		fsize = (*bq)->bv[*slot].bv_len;
-		overlap = min(len, fsize - *offset);
+		fsize = bq->bv[slot].bv_len;
+		overlap = min(len, fsize - offset);
 
 		if (overlap > 0 && copy) {
-			folio = bvec_folio(&(*bq)->bv[*slot]);
+			struct folio *folio = bvec_folio(&bq->bv[slot]);
+
 			if (netfs_using_pgpriv2(rreq)) {
 				if (!folio_test_private_2(folio))
 					folio_start_private_2(folio);
@@ -251,12 +248,20 @@ static void netfs_mark_copy_to_cache(struct netfs_io_request *rreq,
 		}
 
 		len -= overlap;
-		*offset += overlap;
-		if (*offset >= fsize) {
-			*slot += 1;
-			*offset = 0;
+		offset += overlap;
+		if (offset >= fsize) {
+			slot += 1;
+			offset = 0;
 		}
 	}
+
+	if (bq) {
+		bvecq_pos_move(mark, bq);
+		mark->offset = offset;
+		mark->slot = slot;
+	} else {
+		bvecq_pos_unset(mark);
+	}
 }
 
 /*
@@ -275,11 +280,14 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 		.cached_to[1]	= ULLONG_MAX,
 	};
 	struct fscache_occupancy *occ = &_occ;
-	struct bvecq *bq = rreq->buffer.tail;
-	unsigned int offset = 0;
+	struct bvecq_pos mark_cursor;
 	ssize_t size = rreq->len;
 	uoff_t start = rreq->start;
-	int ret = 0, slot = 0;
+	int ret = 0;
+
+	_enter("R=%08x", rreq->debug_id);
+
+	bvecq_pos_set(&mark_cursor, &rreq->dispatch_cursor);
 
 	do {
 		int (*prepare_read)(struct netfs_io_subrequest *subreq) = NULL;
@@ -408,10 +416,10 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 		if (size <= 0)
 			netfs_all_subreqs_queued(rreq);
 
-		if (bq) {
+		if (mark_cursor.bvecq) {
 			/* See if the cache indicated this should be cached. */
 			copy = test_bit(NETFS_SREQ_COPY_TO_CACHE, &subreq->flags);
-			netfs_mark_copy_to_cache(rreq, &bq, &slot, &offset, slice, copy);
+			netfs_mark_copy_to_cache(rreq, &mark_cursor, slice, copy);
 		}
 
 		trace_netfs_sreq(subreq, netfs_sreq_trace_submit);
@@ -432,6 +440,9 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 
 	/* Defer error return as we may need to wait for outstanding I/O. */
 	cmpxchg(&rreq->error, 0, ret);
+
+	bvecq_pos_unset(&mark_cursor);
+	bvecq_pos_unset(&rreq->dispatch_cursor);
 }
 
 /**
@@ -479,7 +490,7 @@ void netfs_readahead(struct readahead_control *ractl)
 	 * acquires a ref on each folio that we will need to release later -
 	 * but we don't want to do that until after we've started the I/O.
 	 */
-	added = rolling_buffer_bulk_load_from_ra(&rreq->buffer, ractl, rreq->gfp);
+	added = bvecq_load_from_ra(&rreq->dispatch_cursor, ractl);
 	if (added < 0) {
 		ret = added;
 		goto cleanup_free;
@@ -488,6 +499,7 @@ void netfs_readahead(struct readahead_control *ractl)
 
 	rreq->submitted = rreq->start + added;
 	rreq->cleaned_to = rreq->start;
+	bvecq_pos_set(&rreq->collect_cursor, &rreq->dispatch_cursor);
 	netfs_read_set_unlock_at(rreq);
 
 	netfs_read_to_pagecache(rreq);
@@ -500,20 +512,26 @@ void netfs_readahead(struct readahead_control *ractl)
 EXPORT_SYMBOL(netfs_readahead);
 
 /*
- * Create a rolling buffer with a single occupying folio.
+ * Create a buffer queue with a single occupying folio.
  */
 static int netfs_create_singular_buffer(struct netfs_io_request *rreq, struct folio *folio)
 {
-	ssize_t added;
+	struct bvecq *bq;
+	size_t fsize = folio_size(folio);
 
-	if (rolling_buffer_init(&rreq->buffer, ITER_DEST, rreq->gfp, false) < 0)
+	bq = bvecq_alloc_one(1, rreq->gfp, false);
+	if (!bq)
 		return -ENOMEM;
 
-	added = rolling_buffer_append(&rreq->buffer, folio, rreq->gfp);
-	if (added < 0)
-		return added;
-	rreq->submitted = rreq->start + added;
-	rreq->progress_at = added;
+	rreq->dispatch_cursor.bvecq  = bq;
+	rreq->dispatch_cursor.slot   = 0;
+	rreq->dispatch_cursor.offset = 0;
+
+	bvec_set_folio(&bq->bv[0], folio, fsize, 0);
+	bvecq_filled_to(bq, 1);
+	bvecq_pos_set(&rreq->collect_cursor, &rreq->dispatch_cursor);
+	rreq->submitted = rreq->start + fsize;
+	rreq->progress_at = fsize;
 	return 0;
 }
 
@@ -527,14 +545,14 @@ static int netfs_read_gaps(struct file *file, struct folio *folio)
 	struct netfs_group *group = netfs_folio_group(folio);
 	struct netfs_folio *finfo = netfs_folio_info(folio);
 	struct netfs_inode *ctx = netfs_inode(mapping->host);
-	struct bio_vec *bvec = NULL;
+	struct bvecq *bq = NULL;
 	unsigned int from = finfo->dirty_offset;
 	unsigned int to = from + finfo->dirty_len;
 	unsigned int off = 0;
 	size_t flen = folio_size(folio);
 	size_t nr_bvec = flen / PAGE_SIZE + 2;
 	size_t part;
-	int ret, i = 0, sink_from = -1, sink_to = -1;
+	int ret, i = 0;
 
 	_enter("%lx", folio->index);
 
@@ -555,31 +573,48 @@ static int netfs_read_gaps(struct file *file, struct folio *folio)
 	 * end get copied to, but the middle is discarded.
 	 */
 	ret = -ENOMEM;
-	bvec = kmalloc_objs(*bvec, nr_bvec);
-	if (!bvec)
+	bq = bvecq_alloc_chain(nr_bvec, rreq->gfp, false);
+	if (!bq)
 		goto discard;
+	rreq->dispatch_cursor.bvecq = bq;
 
 	trace_netfs_folio(folio, netfs_folio_trace_read_gaps);
 
+	for (struct bvecq *p = bq; p; p = p->next)
+		p->mem_type = BVECQ_MEM_PAGECACHE;
+
 	if (from > 0) {
-		bvec_set_folio(&bvec[i++], folio, from, 0);
+		folio_get(folio);
+		bvec_set_folio(&bq->bv[i++], folio, from, 0);
 		off = from;
 	}
-	sink_from = i;
 	while (off < to) {
 		struct folio *sink = folio_alloc(GFP_KERNEL, 0);
 
-		if (!sink)
+		if (!sink) {
+			bvecq_filled_to(bq, i);
 			goto discard;
-		part = min_t(size_t, to - off, PAGE_SIZE);
-		bvec_set_folio(&bvec[i], sink, part, 0);
+		}
+		if (i >= bq->max_slots) {
+			bvecq_filled_to(bq, i);
+			bq = bq->next;
+			i = 0;
+		}
+		part = min(to - off, PAGE_SIZE);
+		bvec_set_folio(&bq->bv[i++], sink, part, 0);
 		off += part;
-		sink_to = i;
-		i++;
 	}
-	if (to < flen)
-		bvec_set_folio(&bvec[i++], folio, flen - to, to);
-	iov_iter_bvec(&rreq->buffer.iter, ITER_DEST, bvec, i, rreq->len);
+	if (to < flen) {
+		if (i >= bq->max_slots) {
+			bvecq_filled_to(bq, i);
+			bq = bq->next;
+			i = 0;
+		}
+		folio_get(folio);
+		bvec_set_folio(&bq->bv[i++], folio, flen - to, to);
+	}
+	bvecq_filled_to(bq, i);
+
 	rreq->submitted = rreq->start + flen;
 
 	netfs_read_to_pagecache(rreq);
@@ -587,11 +622,10 @@ static int netfs_read_gaps(struct file *file, struct folio *folio)
 	ret = netfs_wait_for_read(rreq);
 	if (ret >= 0) {
 		if (ret < flen) {
-			struct iov_iter iter;
-
-			iov_iter_bvec(&iter, ITER_DEST, bvec, i, flen);
-			iov_iter_advance(&iter, ret);
-			iov_iter_zero(flen - ret, &iter);
+			if (ret < from)
+				folio_zero_segments(folio, ret, from, to, flen);
+			else
+				folio_zero_segment(folio, max(to, ret), flen);
 		}
 		if (group)
 			folio_change_private(folio, group);
@@ -603,22 +637,16 @@ static int netfs_read_gaps(struct file *file, struct folio *folio)
 		folio_mark_uptodate(folio);
 	}
 
-	if (sink_to >= 0)
-		for (; sink_from <= sink_to; sink_from++)
-			folio_put(bvec_folio(&bvec[sink_from]));
-	kfree(bvec);
+	bvecq_pos_unset(&rreq->dispatch_cursor);
 	folio_unlock(folio);
 	netfs_put_request(rreq, netfs_rreq_trace_put_return);
 	return ret < 0 ? ret : 0;
 
 discard:
+	bvecq_pos_unset(&rreq->dispatch_cursor);
 	netfs_put_failed_request(rreq);
 alloc_error:
 	folio_unlock(folio);
-	if (sink_to >= 0)
-		for (; sink_from <= sink_to; sink_from++)
-			folio_put(bvec_folio(&bvec[sink_from]));
-	kfree(bvec);
 	return ret;
 }
 
diff --git a/fs/netfs/direct_read.c b/fs/netfs/direct_read.c
index 2b8eeb2d3c06..dae890e8df28 100644
--- a/fs/netfs/direct_read.c
+++ b/fs/netfs/direct_read.c
@@ -16,44 +16,21 @@
 #include <linux/netfs.h>
 #include "internal.h"
 
-static void netfs_prepare_dio_read_iterator(struct netfs_io_subrequest *subreq)
-{
-	struct netfs_io_request *rreq = subreq->rreq;
-	size_t rsize;
-
-	rsize = umin(subreq->len, rreq->io_streams[0].sreq_max_len);
-	subreq->len = rsize;
-
-	if (unlikely(rreq->io_streams[0].sreq_max_segs)) {
-		size_t limit = netfs_limit_iter(&rreq->buffer.iter, 0, rsize,
-						rreq->io_streams[0].sreq_max_segs);
-
-		if (limit < rsize) {
-			subreq->len = limit;
-			trace_netfs_sreq(subreq, netfs_sreq_trace_limited);
-		}
-	}
-
-	trace_netfs_sreq(subreq, netfs_sreq_trace_prepare);
-
-	subreq->io_iter	= rreq->buffer.iter;
-	iov_iter_truncate(&subreq->io_iter, subreq->len);
-	iov_iter_advance(&rreq->buffer.iter, subreq->len);
-}
-
 /*
  * Perform a read to a buffer from the server, slicing up the region to be read
  * according to the network rsize.
  */
 static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 {
+	struct netfs_io_stream *stream = &rreq->io_streams[0];
 	ssize_t size = rreq->len;
 	uoff_t start = rreq->start;
 	int ret;
 
+	bvecq_pos_set(&rreq->collect_cursor, &rreq->dispatch_cursor);
+
 	do {
 		struct netfs_io_subrequest *subreq;
-		ssize_t slice;
 
 		subreq = netfs_alloc_subrequest(rreq, NETFS_DOWNLOAD_FROM_SERVER);
 		if (!subreq) {
@@ -78,14 +55,22 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 			}
 		}
 
-		netfs_prepare_dio_read_iterator(subreq);
-		slice = subreq->len;
-		size -= slice;
-		start += slice;
-		rreq->submitted += slice;
+		bvecq_pos_set(&subreq->io_buffer, &rreq->dispatch_cursor);
+		subreq->len = bvecq_slice(&rreq->dispatch_cursor,
+					  umin(size, stream->sreq_max_len),
+					  stream->sreq_max_segs,
+					  &subreq->nr_segs);
+
+		size -= subreq->len;
+		start += subreq->len;
+		rreq->submitted += subreq->len;
 		if (size <= 0)
 			netfs_all_subreqs_queued(rreq);
 
+		iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->io_buffer.bvecq,
+				    subreq->io_buffer.slot, subreq->io_buffer.offset,
+				    subreq->len);
+
 		rreq->netfs_ops->issue_read(subreq);
 
 		if (test_bit(NETFS_RREQ_PAUSE, &rreq->flags))
@@ -99,6 +84,8 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 		netfs_all_subreqs_queued(rreq);
 		netfs_wake_collector(rreq);
 	}
+
+	bvecq_pos_unset(&rreq->dispatch_cursor);
 }
 
 /*
@@ -183,15 +170,12 @@ ssize_t netfs_unbuffered_read_iter_locked(struct kiocb *iocb, struct iov_iter *i
 	 * may end up truncated if ENOMEM is encountered.
 	 */
 	ret = netfs_extract_iter(iter, rreq->len, INT_MAX,
-				 &rreq->direct_bq, 0, rreq->gfp);
+				 &rreq->dispatch_cursor.bvecq, 0, rreq->gfp);
 	if (ret < 0)
 		goto error_put;
 
 	rreq->len = ret;
 
-	iov_iter_bvec_queue(&rreq->buffer.iter, ITER_DEST, rreq->direct_bq,
-			    0, 0, rreq->len);
-
 	// TODO: Set up bounce buffer if needed
 
 	if (!sync) {
diff --git a/fs/netfs/direct_write.c b/fs/netfs/direct_write.c
index b3ec1900d7a4..65c61fc67f9b 100644
--- a/fs/netfs/direct_write.c
+++ b/fs/netfs/direct_write.c
@@ -73,7 +73,11 @@ static void netfs_unbuffered_write_collect(struct netfs_io_request *wreq,
 	spin_unlock(&wreq->lock);
 
 	wreq->transferred += subreq->transferred;
-	iov_iter_advance(&wreq->buffer.iter, subreq->transferred);
+	if (subreq->transferred < subreq->len) {
+		bvecq_pos_unset(&wreq->dispatch_cursor);
+		bvecq_pos_transfer(&wreq->dispatch_cursor, &subreq->io_buffer);
+		bvecq_pos_advance(&wreq->dispatch_cursor, subreq->transferred);
+	}
 
 	stream->collected_to = subreq->start + subreq->transferred;
 	wreq->collected_to = stream->collected_to;
@@ -99,6 +103,8 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 
 	_enter("%llx", wreq->len);
 
+	bvecq_pos_set(&wreq->collect_cursor, &wreq->dispatch_cursor);
+
 	if (wreq->origin == NETFS_DIO_WRITE)
 		inode_dio_begin(wreq->inode);
 
@@ -116,6 +122,8 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 				break;
 			}
 			stream->construct = NULL;
+		} else {
+			bvecq_pos_set(&subreq->io_buffer, &wreq->dispatch_cursor);
 		}
 
 		/* Check if (re-)preparation failed. */
@@ -125,9 +133,16 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 			break;
 		}
 
-		iov_iter_truncate(&subreq->io_iter, wreq->len - wreq->transferred);
+		subreq->len = bvecq_slice(&wreq->dispatch_cursor, stream->sreq_max_len,
+					  stream->sreq_max_segs, &subreq->nr_segs);
+
+		iov_iter_bvec_queue(&subreq->io_iter, ITER_SOURCE,
+				    subreq->io_buffer.bvecq, subreq->io_buffer.slot,
+				    subreq->io_buffer.offset,
+				    subreq->len);
+
 		if (!iov_iter_count(&subreq->io_iter)) {
-			pr_warn("netfs: Unexpected zero-length iterator R=%08x\n",
+			pr_warn("netfs: Unexpected zero-length slice R=%08x\n",
 				wreq->debug_id);
 			__set_bit(NETFS_SREQ_FAILED, &subreq->flags);
 			netfs_write_subrequest_terminated(subreq, -EIO);
@@ -135,12 +150,6 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 			break;
 		}
 
-		subreq->len = netfs_limit_iter(&subreq->io_iter, 0,
-					       stream->sreq_max_len,
-					       stream->sreq_max_segs);
-		iov_iter_truncate(&subreq->io_iter, subreq->len);
-		stream->submit_extendable_to = subreq->len;
-
 		trace_netfs_sreq(subreq, netfs_sreq_trace_submit);
 		stream->issue_write(subreq);
 
@@ -175,9 +184,13 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 		 */
 		subreq->error = -EAGAIN;
 		trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
+
+		bvecq_pos_unset(&wreq->dispatch_cursor);
+		bvecq_pos_transfer(&wreq->dispatch_cursor, &subreq->io_buffer);
+
 		if (subreq->transferred > 0) {
-			iov_iter_advance(&wreq->buffer.iter, subreq->transferred);
 			wreq->transferred += subreq->transferred;
+			bvecq_pos_advance(&wreq->dispatch_cursor, subreq->transferred);
 		}
 
 		if (stream->source == NETFS_UPLOAD_TO_SERVER &&
@@ -188,7 +201,6 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 		__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
 		__clear_bit(NETFS_SREQ_BOUNDARY, &subreq->flags);
 		__clear_bit(NETFS_SREQ_FAILED, &subreq->flags);
-		subreq->io_iter		= wreq->buffer.iter;
 		subreq->start		= wreq->start + wreq->transferred;
 		subreq->len		= wreq->len   - wreq->transferred;
 		subreq->transferred	= 0;
@@ -204,6 +216,7 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 		netfs_stat(&netfs_n_wh_retry_write_subreq);
 	}
 
+	bvecq_pos_unset(&wreq->dispatch_cursor);
 	netfs_unbuffered_write_done(wreq);
 	_leave(" = %d", ret);
 	return ret;
@@ -262,7 +275,7 @@ ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *
 		 * request.
 		 */
 		ssize_t n = netfs_extract_iter(iter, len, INT_MAX,
-					       &wreq->direct_bq, 0, wreq->gfp);
+					       &wreq->dispatch_cursor.bvecq, 0, wreq->gfp);
 
 		if (n < 0) {
 			ret = n;
@@ -270,11 +283,8 @@ ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *
 		}
 		wreq->len = n;
 		_debug("dio-write %zx/%zx %u/%u",
-		       n, len, wreq->direct_bq->nr_slots,
-		       wreq->direct_bq->max_slots);
-
-		iov_iter_bvec_queue(&wreq->buffer.iter, ITER_SOURCE,
-				    wreq->direct_bq, 0, 0, wreq->len);
+		       n, len, wreq->dispatch_cursor.bvecq->nr_slots,
+		       wreq->dispatch_cursor.bvecq->max_slots);
 	}
 
 	__set_bit(NETFS_RREQ_USE_IO_ITER, &wreq->flags);
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index f2a86abae9b3..2760bce732b8 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -70,7 +70,6 @@ static inline void netfs_proc_del_rreq(struct netfs_io_request *rreq) {}
 /*
  * misc.c
  */
-void netfs_reset_iter(struct netfs_io_subrequest *subreq);
 void netfs_wake_collector(struct netfs_io_request *rreq);
 void netfs_subreq_clear_in_progress(struct netfs_io_subrequest *subreq);
 void netfs_wait_for_in_progress_stream(struct netfs_io_request *rreq,
@@ -239,8 +238,7 @@ void netfs_prepare_write(struct netfs_io_request *wreq,
 			 struct netfs_io_stream *stream,
 			 uoff_t start);
 void netfs_reissue_write(struct netfs_io_stream *stream,
-			 struct netfs_io_subrequest *subreq,
-			 struct iov_iter *source);
+			 struct netfs_io_subrequest *subreq);
 void netfs_issue_write(struct netfs_io_request *wreq,
 		       struct netfs_io_stream *stream);
 size_t netfs_advance_write(struct netfs_io_request *wreq,
diff --git a/fs/netfs/iterator.c b/fs/netfs/iterator.c
index 8cf2efe0cd6c..d9ff6646d5d1 100644
--- a/fs/netfs/iterator.c
+++ b/fs/netfs/iterator.c
@@ -156,6 +156,7 @@ ssize_t netfs_extract_iter(struct iov_iter *orig, size_t max_len, size_t max_pag
 }
 EXPORT_SYMBOL_GPL(netfs_extract_iter);
 
+#if 0 // TODO: Remove in subsequent patch
 /**
  * netfs_extract_user_iter - Extract the pages from a user iterator into a bvec
  * @orig: The original iterator
@@ -450,3 +451,4 @@ size_t netfs_limit_iter(const struct iov_iter *iter, size_t start_offset,
 	BUG();
 }
 EXPORT_SYMBOL(netfs_limit_iter);
+#endif
diff --git a/fs/netfs/misc.c b/fs/netfs/misc.c
index a0cc248a284d..130bd432b194 100644
--- a/fs/netfs/misc.c
+++ b/fs/netfs/misc.c
@@ -9,24 +9,6 @@
 #include <linux/rmap.h>
 #include "internal.h"
 
-/*
- * Reset the subrequest iterator to refer just to the region remaining to be
- * read.  The iterator may or may not have been advanced by socket ops or
- * extraction ops to an extent that may or may not match the amount actually
- * read.
- */
-void netfs_reset_iter(struct netfs_io_subrequest *subreq)
-{
-	struct iov_iter *io_iter = &subreq->io_iter;
-	size_t remain = subreq->len - subreq->transferred;
-
-	if (io_iter->count > remain)
-		iov_iter_advance(io_iter, io_iter->count - remain);
-	else if (io_iter->count < remain)
-		iov_iter_revert(io_iter, remain - io_iter->count);
-	iov_iter_truncate(&subreq->io_iter, remain);
-}
-
 /**
  * netfs_dirty_folio - Mark folio dirty and pin a cache object for writeback
  * @mapping: The mapping the folio belongs to.
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index f8a5b6a7a2a9..bf17dc31fd9d 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -147,8 +147,10 @@ static void netfs_deinit_request(struct netfs_io_request *rreq)
 		rreq->netfs_ops->free_request(rreq);
 	if (rreq->cache_resources.ops)
 		rreq->cache_resources.ops->end_operation(&rreq->cache_resources);
-	bvecq_put(rreq->direct_bq);
-	rolling_buffer_clear(&rreq->buffer);
+	bvecq_pos_unset(&rreq->load_cursor);
+	bvecq_pos_unset(&rreq->dispatch_cursor);
+	bvecq_pos_unset(&rreq->collect_cursor);
+	bvecq_put(rreq->spare);
 
 	if (atomic_dec_and_test(&ictx->io_count))
 		wake_up_var(&ictx->io_count);
@@ -242,6 +244,7 @@ static void netfs_free_subrequest(struct netfs_io_subrequest *subreq)
 	trace_netfs_sreq(subreq, netfs_sreq_trace_free);
 	if (rreq->netfs_ops->free_subrequest)
 		rreq->netfs_ops->free_subrequest(subreq);
+	bvecq_pos_unset(&subreq->io_buffer);
 	mempool_free(subreq, rreq->netfs_ops->subrequest_pool ?: &netfs_subrequest_pool);
 	netfs_stat_d(&netfs_n_rh_sreq);
 	netfs_put_request(rreq, netfs_rreq_trace_put_subreq);
diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index ab2f208cc8f9..801c8ef787d9 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -26,27 +26,33 @@
  */
 static void netfs_clear_unread(struct netfs_io_subrequest *subreq)
 {
-	netfs_reset_iter(subreq);
-	WARN_ON_ONCE(subreq->len - subreq->transferred != iov_iter_count(&subreq->io_iter));
-	iov_iter_zero(iov_iter_count(&subreq->io_iter), &subreq->io_iter);
+	struct iov_iter iter;
+
+	iov_iter_bvec_queue(&iter, ITER_DEST, subreq->io_buffer.bvecq,
+			    subreq->io_buffer.slot, subreq->io_buffer.offset, subreq->len);
+	iov_iter_advance(&iter, subreq->transferred);
+	iov_iter_zero(subreq->len, &iter);
+
 	if (subreq->start + subreq->transferred >= subreq->rreq->i_size)
 		__set_bit(NETFS_SREQ_HIT_EOF, &subreq->flags);
 }
 
 static void netfs_clear_unread_dio(struct netfs_io_subrequest *subreq)
 {
-	uoff_t pos = subreq->start + subreq->transferred;
 	struct netfs_io_request *rreq = subreq->rreq;
+	struct iov_iter iter;
+	uoff_t pos = subreq->start + subreq->transferred;
 	size_t fill;
 
 	if (pos >= rreq->i_size)
 		return;
 
-	fill = min_t(uoff_t, rreq->i_size - pos,
-		     subreq->len - subreq->transferred);
+	fill = umin(rreq->i_size - pos, subreq->len - subreq->transferred);
 
-	netfs_reset_iter(subreq);
-	subreq->transferred += iov_iter_zero(fill, &subreq->io_iter);
+	iov_iter_bvec_queue(&iter, ITER_DEST, subreq->io_buffer.bvecq,
+			    subreq->io_buffer.slot, subreq->io_buffer.offset, subreq->len);
+	iov_iter_advance(&iter, subreq->transferred);
+	iov_iter_zero(fill, &iter);
 }
 
 /*
@@ -138,8 +144,8 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
  */
 void netfs_read_set_unlock_at(struct netfs_io_request *rreq)
 {
-	const struct bvecq *bq = rreq->buffer.tail;
-	unsigned int slot = rreq->buffer.first_tail_slot;
+	const struct bvecq *bq = rreq->collect_cursor.bvecq;
+	unsigned int slot = rreq->collect_cursor.slot;
 	size_t cleaned_to = rreq->cleaned_to - rreq->start;
 	size_t progress_at = cleaned_to;
 	size_t minimum = 256 * 1024;
@@ -169,8 +175,8 @@ void netfs_read_set_unlock_at(struct netfs_io_request *rreq)
 static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 				     unsigned int *notes)
 {
-	struct bvecq *bq = rreq->buffer.tail;
-	unsigned int slot = rreq->buffer.first_tail_slot;
+	struct bvecq *bq = rreq->collect_cursor.bvecq;
+	unsigned int slot = rreq->collect_cursor.slot;
 	uoff_t collected_to = rreq->collected_to;
 
 	if (rreq->cleaned_to >= rreq->collected_to)
@@ -178,15 +184,6 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 
 	// TODO: Begin decryption
 
-	while (!bvecq_acquire_slot(bq, slot)) {
-		bq = rolling_buffer_delete_spent(&rreq->buffer);
-		if (!bq) {
-			WRITE_ONCE(rreq->progress_at, rreq->len);
-			return;
-		}
-		slot = 0;
-	}
-
 	/* We have to wait for readahead refs to have been released before we
 	 * can unlock any folios as the ref-dropper walks i_pages and the only
 	 * thing preventing these folios from being removed is the folio lock.
@@ -196,9 +193,24 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 
 	for (;;) {
 		struct folio *folio;
-		uoff_t fpos, fend;
+		uoff_t fpos = rreq->cleaned_to, fend;
 		size_t fsize;
 
+		/* Clean up the head bvecq segment.  If we clear an entire
+		 * segment, then we can get rid of it provided it's not also
+		 * the tail segment being filled by the issuer.
+		 */
+		if (!bvecq_acquire_slot(bq, slot)) {
+			rreq->collect_cursor.slot = slot;
+			if (!bvecq_delete_spent(&rreq->collect_cursor)) {
+				WRITE_ONCE(rreq->progress_at, rreq->len);
+				return;
+			}
+			bq = rreq->collect_cursor.bvecq;
+			slot  = rreq->collect_cursor.slot;
+			continue;
+		}
+
 		folio = bvec_folio(&bq->bv[slot]);
 		if (WARN_ONCE(!folio_test_locked(folio),
 			      "R=%08x: folio %lx is not locked\n",
@@ -206,7 +218,6 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 			trace_netfs_folio(folio, netfs_folio_trace_not_locked);
 
 		fsize = bq->bv[slot].bv_len;
-		fpos = folio_pos(folio);
 		fend = fpos + fsize;
 
 		trace_netfs_collect_folio(rreq, folio);
@@ -216,30 +227,16 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 			break;
 
 		netfs_unlock_read_folio(rreq, bq, slot);
-		WRITE_ONCE(rreq->cleaned_to, fpos + fsize);
-		*notes |= MADE_PROGRESS;
-
-		/* Clean up the head bq.  If we clear an entire bq, then
-		 * we can get rid of it provided it's not also the tail bq
-		 * being filled by the issuer.
-		 */
-		bq->bv[slot].bv_page = NULL;
 		slot++;
-		while (!bvecq_acquire_slot(bq, slot)) {
-			bq = rolling_buffer_delete_spent(&rreq->buffer);
-			if (!bq)
-				goto done;
-			slot = 0;
-		}
+		WRITE_ONCE(rreq->cleaned_to, fend);
+		*notes |= MADE_PROGRESS;
 
 		if (fpos + fsize >= collected_to)
 			break;
 	}
 
-	rreq->buffer.tail = bq;
-done:
-	rreq->buffer.first_tail_slot = slot;
-
+	bvecq_pos_move(&rreq->collect_cursor, bq);
+	rreq->collect_cursor.slot = slot;
 	netfs_read_set_unlock_at(rreq);
 }
 
@@ -422,7 +419,7 @@ static void netfs_rreq_assess_dio(struct netfs_io_request *rreq)
 
 	if (rreq->origin == NETFS_UNBUFFERED_READ ||
 	    rreq->origin == NETFS_DIO_READ) {
-		for (struct bvecq *bq = rreq->direct_bq; bq; bq = bvecq_next(bq)) {
+		for (struct bvecq *bq = rreq->collect_cursor.bvecq; bq; bq = bvecq_next(bq)) {
 			unsigned int nr_slots = bvecq_nr_slots_acquire(bq);
 			/* Read the slot count before the slots. */
 
@@ -526,7 +523,15 @@ bool netfs_read_collection(struct netfs_io_request *rreq)
 
 	trace_netfs_rreq(rreq, netfs_rreq_trace_done);
 	netfs_clear_subrequests(rreq);
-	netfs_unlock_abandoned_read_pages(rreq);
+	switch (rreq->origin) {
+	case NETFS_READAHEAD:
+	case NETFS_READPAGE:
+	case NETFS_READ_FOR_WRITE:
+		netfs_unlock_abandoned_read_pages(rreq);
+		break;
+	default:
+		break;
+	}
 	if (unlikely(rreq->copy_to_cache))
 		netfs_pgpriv2_end_copy_to_cache(rreq);
 	return true;
diff --git a/fs/netfs/read_pgpriv2.c b/fs/netfs/read_pgpriv2.c
index f8e5667e278e..d1ab47d88f3b 100644
--- a/fs/netfs/read_pgpriv2.c
+++ b/fs/netfs/read_pgpriv2.c
@@ -19,6 +19,9 @@
 static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio *folio)
 {
 	struct netfs_io_stream *cache = &creq->io_streams[1];
+	struct bvecq *queue;
+	unsigned int slot;
+	size_t dio_size = PAGE_SIZE;
 	size_t fsize = folio_size(folio), flen = fsize;
 	uoff_t fpos = folio_pos(folio), i_size;
 	bool to_eof = false;
@@ -48,18 +51,37 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 		to_eof = true;
 	}
 
+	flen = round_up(flen, dio_size);
+
 	_debug("folio %zx %zx", flen, fsize);
 
 	trace_netfs_folio(folio, netfs_folio_trace_store_copy);
 
-	/* Attach the folio to the rolling buffer. */
-	if (rolling_buffer_append(&creq->buffer, folio, creq->gfp) < 0) {
-		set_bit(NETFS_RREQ_CANCEL_CACHING, &creq->flags);
-		folio_end_private_2(folio);
-		return;
+	/* Institute a new bvec queue segment if the current one is full or if
+	 * we encounter a discontiguity.  The discontiguity break is important
+	 * when it comes to bulk unlocking folios by file range.
+	 */
+	queue = creq->load_cursor.bvecq;
+	if (bvecq_is_full(queue) ||
+	    (fpos != creq->last_end && creq->last_end > 0 && queue->nr_slots > 0)) {
+		bvecq_buffer_append(&creq->load_cursor, creq->spare);
+		creq->spare = NULL;
+
+		queue = creq->load_cursor.bvecq;
 	}
 
-	cache->submit_extendable_to = fsize;
+	/* Attach the folio to the rolling buffer. */
+	slot = queue->nr_slots;
+	bvec_set_folio(&queue->bv[slot], folio, fsize, 0);
+	trace_netfs_bv_slot(queue, slot);
+	slot++;
+	bvecq_filled_to(queue, slot);
+	creq->load_cursor.slot = slot;
+	creq->load_cursor.offset = 0;
+	creq->last_end = fpos + flen;
+
+	bvecq_pos_nudge(&creq->dispatch_cursor);
+
 	cache->submit_off = 0;
 	cache->submit_len = flen;
 
@@ -71,10 +93,9 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 	do {
 		ssize_t part;
 
-		creq->buffer.iter.iov_offset = cache->submit_off;
+		creq->dispatch_cursor.offset = cache->submit_off;
 
 		atomic64_set(&creq->issued_to, fpos + cache->submit_off);
-		cache->submit_extendable_to = fsize - cache->submit_off;
 		part = netfs_advance_write(creq, cache, fpos + cache->submit_off,
 					   cache->submit_len, to_eof);
 		cache->submit_off += part;
@@ -84,8 +105,7 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 			cache->submit_len -= part;
 	} while (cache->submit_len > 0);
 
-	creq->buffer.iter.iov_offset = 0;
-	rolling_buffer_advance(&creq->buffer, fsize);
+	bvecq_pos_step(&creq->dispatch_cursor);
 	atomic64_set(&creq->issued_to, fpos + fsize);
 
 	if (flen < fsize)
@@ -111,6 +131,11 @@ static struct netfs_io_request *netfs_pgpriv2_begin_copy_to_cache(
 	if (!creq->io_streams[1].avail)
 		goto cancel_put;
 
+	if (bvecq_buffer_init(&creq->load_cursor, creq->gfp, false) < 0)
+		goto cancel_put;
+	bvecq_pos_set(&creq->dispatch_cursor, &creq->load_cursor);
+	bvecq_pos_set(&creq->collect_cursor, &creq->dispatch_cursor);
+
 	__set_bit(NETFS_RREQ_OFFLOAD_COLLECTION, &creq->flags);
 	trace_netfs_copy2cache(rreq, creq);
 	trace_netfs_write(creq, netfs_write_trace_copy_to_cache);
@@ -143,6 +168,15 @@ void netfs_pgpriv2_copy_to_cache(struct netfs_io_request *rreq, struct folio *fo
 		return;
 	}
 
+	if (!creq->spare) {
+		creq->spare = bvecq_alloc_one(BVECQ_POOL_SLOTS, creq->gfp, false);
+		if (!creq->spare) {
+			set_bit(NETFS_RREQ_CANCEL_CACHING, &creq->flags);
+			netfs_cancel_copy_to_cache(rreq, folio);
+			return;
+		}
+	}
+
 	trace_netfs_folio(folio, netfs_folio_trace_pgpriv2_copy);
 	netfs_pgpriv2_copy_folio(creq, folio);
 }
@@ -173,16 +207,18 @@ void netfs_pgpriv2_end_copy_to_cache(struct netfs_io_request *rreq)
  */
 bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 {
-	struct bvecq *bq = creq->buffer.tail;
-	unsigned int slot = creq->buffer.first_tail_slot;
+	struct bvecq *bq = creq->collect_cursor.bvecq;
+	unsigned int slot;
 	uoff_t collected_to = creq->collected_to;
 	bool made_progress = false;
 
+	slot = creq->collect_cursor.slot;
 	while (!bvecq_acquire_slot(bq, slot)) {
-		bq = rolling_buffer_delete_spent(&creq->buffer);
-		if (!bq)
-			return false;
-		slot = 0;
+		creq->collect_cursor.slot = slot;
+		if (!bvecq_delete_spent(&creq->collect_cursor))
+			goto out;
+		bq   = creq->collect_cursor.bvecq;
+		slot = creq->collect_cursor.slot;
 	}
 
 	for (;;) {
@@ -213,25 +249,25 @@ bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 		creq->cleaned_to = fpos + fsize;
 		made_progress = true;
 
-		/* Clean up the head bq.  If we clear an entire bq, then
-		 * we can get rid of it provided it's not also the tail bq
-		 * being filled by the issuer.
+		/* Clean up the head segment.  If we clear an entire segment,
+		 * then we can get rid of it provided it's not also the tail
+		 * segment being filled by the issuer.
 		 */
 		bq->bv[slot].bv_page = NULL;
 		slot++;
 		while (!bvecq_acquire_slot(bq, slot)) {
-			bq = rolling_buffer_delete_spent(&creq->buffer);
-			if (!bq)
-				goto done;
-			slot = 0;
+			creq->collect_cursor.slot = slot;
+			if (!bvecq_delete_spent(&creq->collect_cursor))
+				goto out;
+			bq   = creq->collect_cursor.bvecq;
+			slot = creq->collect_cursor.slot;
 		}
 
 		if (fpos + fsize >= collected_to)
 			break;
 	}
 
-	creq->buffer.tail = bq;
-done:
-	creq->buffer.first_tail_slot = slot;
+	creq->collect_cursor.slot = slot;
+out:
 	return made_progress;
 }
diff --git a/fs/netfs/read_retry.c b/fs/netfs/read_retry.c
index 142c3fb8dab1..6082b1614502 100644
--- a/fs/netfs/read_retry.c
+++ b/fs/netfs/read_retry.c
@@ -12,6 +12,10 @@
 static void netfs_reissue_read(struct netfs_io_request *rreq,
 			       struct netfs_io_subrequest *subreq)
 {
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->io_buffer.bvecq,
+			    subreq->io_buffer.slot, subreq->io_buffer.offset, subreq->len);
+	iov_iter_advance(&subreq->io_iter, subreq->transferred);
+
 	subreq->error = 0;
 	__clear_bit(NETFS_SREQ_MADE_PROGRESS, &subreq->flags);
 	__set_bit(NETFS_SREQ_IN_PROGRESS, &subreq->flags);
@@ -27,6 +31,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 {
 	struct netfs_io_subrequest *subreq;
 	struct netfs_io_stream *stream = &rreq->io_streams[0];
+	struct bvecq_pos dispatch_cursor = {};
 	struct list_head *next;
 
 	_enter("R=%x", rreq->debug_id);
@@ -46,9 +51,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 			if (test_bit(NETFS_SREQ_FAILED, &subreq->flags))
 				break;
 			if (__test_and_clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags)) {
-				__clear_bit(NETFS_SREQ_MADE_PROGRESS, &subreq->flags);
 				subreq->retry_count++;
-				netfs_reset_iter(subreq);
 				netfs_get_subrequest(subreq, netfs_sreq_trace_get_resubmit);
 				netfs_reissue_read(rreq, subreq);
 			}
@@ -74,11 +77,12 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 
 	do {
 		struct netfs_io_subrequest *from, *to, *tmp;
-		struct iov_iter source;
 		uoff_t start, len;
 		size_t part;
 		bool boundary = false, subreq_superfluous = false;
 
+		bvecq_pos_unset(&dispatch_cursor);
+
 		/* Go through the subreqs and find the next span of contiguous
 		 * buffer that we then rejig (cifs, for example, needs the
 		 * rsize renegotiating) and reissue.
@@ -105,7 +109,8 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 				break;
 
 			subreq = list_entry(next, struct netfs_io_subrequest, rreq_link);
-			if (subreq->start + subreq->transferred != start + len ||
+			if (subreq->start != start + len ||
+			    subreq->transferred > 0 ||
 			    test_bit(NETFS_SREQ_BOUNDARY, &subreq->flags) ||
 			    !test_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags))
 				break;
@@ -118,11 +123,14 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 		/* Determine the set of buffers we're going to use.  Each
 		 * subreq gets a subset of a single overall contiguous buffer.
 		 */
-		netfs_reset_iter(from);
-		source = from->io_iter;
-		source.count = len;
+		bvecq_pos_transfer(&dispatch_cursor, &from->io_buffer);
+		bvecq_pos_advance(&dispatch_cursor, from->transferred);
+		from->transferred = 0;
 
-		/* Work through the sublist. */
+		/* Work through the sublist.  The chain of buffers we're going
+		 * to fill is attached to dispatch_cursor and we need to read
+		 * 'len' amount of data from 'start'.
+		 */
 		subreq = from;
 		list_for_each_entry_from(subreq, &stream->subrequests, rreq_link) {
 			if (!len) {
@@ -130,16 +138,21 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 				break;
 			}
 			subreq->source	= NETFS_DOWNLOAD_FROM_SERVER;
-			subreq->start	= start - subreq->transferred;
-			subreq->len	= len   + subreq->transferred;
+			subreq->start	= start;
+			subreq->len	= len;
 			__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
 			__clear_bit(NETFS_SREQ_MADE_PROGRESS, &subreq->flags);
 			subreq->retry_count++;
+			subreq->transferred = 0;
+
+			bvecq_pos_unset(&subreq->io_buffer);
+			bvecq_pos_set(&subreq->io_buffer, &dispatch_cursor);
 
 			trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
 
 			/* Renegotiate max_len (rsize) */
-			stream->sreq_max_len = subreq->len;
+			stream->sreq_max_len = len;
+			stream->sreq_max_segs = INT_MAX;
 			if (rreq->netfs_ops->prepare_read &&
 			    rreq->netfs_ops->prepare_read(subreq) < 0) {
 				trace_netfs_sreq(subreq, netfs_sreq_trace_reprep_failed);
@@ -147,13 +160,12 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 				goto abandon;
 			}
 
-			part = umin(len, stream->sreq_max_len);
-			if (unlikely(stream->sreq_max_segs))
-				part = netfs_limit_iter(&source, 0, part, stream->sreq_max_segs);
-			subreq->len = subreq->transferred + part;
-			subreq->io_iter = source;
-			iov_iter_truncate(&subreq->io_iter, part);
-			iov_iter_advance(&source, part);
+			part = bvecq_slice(&dispatch_cursor,
+					   umin(len, stream->sreq_max_len),
+					   stream->sreq_max_segs,
+					   &subreq->nr_segs);
+			subreq->len = part;
+
 			len -= part;
 			start += part;
 			if (!len) {
@@ -216,9 +228,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 			trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
 
 			stream->sreq_max_len	= umin(len, rreq->rsize);
-			stream->sreq_max_segs	= 0;
-			if (unlikely(stream->sreq_max_segs))
-				part = netfs_limit_iter(&source, 0, part, stream->sreq_max_segs);
+			stream->sreq_max_segs	= INT_MAX;
 
 			netfs_stat(&netfs_n_rh_download);
 			if (rreq->netfs_ops->prepare_read(subreq) < 0) {
@@ -227,11 +237,12 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 				goto abandon;
 			}
 
-			part = umin(len, stream->sreq_max_len);
-			subreq->len = subreq->transferred + part;
-			subreq->io_iter = source;
-			iov_iter_truncate(&subreq->io_iter, part);
-			iov_iter_advance(&source, part);
+			bvecq_pos_set(&subreq->io_buffer, &dispatch_cursor);
+			part = bvecq_slice(&dispatch_cursor,
+					   umin(len, stream->sreq_max_len),
+					   stream->sreq_max_segs,
+					   &subreq->nr_segs);
+			subreq->len = part;
 
 			len -= part;
 			start += part;
@@ -245,12 +256,14 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 
 	} while (!list_is_head(next, &stream->subrequests));
 
+out:
+	bvecq_pos_unset(&dispatch_cursor);
 	return;
 
 	/* If we hit an error, fail all remaining incomplete subrequests */
 abandon_after:
 	if (list_is_last(&subreq->rreq_link, &stream->subrequests))
-		return;
+		goto out;
 	subreq = list_next_entry(subreq, rreq_link);
 abandon:
 	list_for_each_entry_from(subreq, &stream->subrequests, rreq_link) {
@@ -261,6 +274,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 		__set_bit(NETFS_SREQ_FAILED, &subreq->flags);
 		__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
 	}
+	goto out;
 }
 
 /*
@@ -292,6 +306,7 @@ void netfs_retry_reads(struct netfs_io_request *rreq)
 void netfs_unlock_abandoned_read_pages(struct netfs_io_request *rreq)
 {
 	struct bvecq *p;
+	int slot = rreq->collect_cursor.slot;
 
 	/* We have to wait for readahead refs to have been released before we
 	 * can unlock any folios as the ref-dropper walks i_pages and the only
@@ -300,26 +315,24 @@ void netfs_unlock_abandoned_read_pages(struct netfs_io_request *rreq)
 	if (test_bit(NETFS_RREQ_NEED_PUT_RA_REFS, &rreq->flags))
 		netfs_wait_for_put_ra_refs(rreq);
 
-	for (p = rreq->buffer.tail; p; p = p->next) {
-		for (int slot = rreq->buffer.first_tail_slot;
-		     bvecq_acquire_slot(p, slot);
-		     slot++) {
-			struct folio *folio;
+	for (p = rreq->collect_cursor.bvecq; p; p = bvecq_next(p), slot = 0) {
+		unsigned int nr_slots = bvecq_nr_slots_acquire(p);
 
+		for (; slot < nr_slots; slot++) {
 			if (!p->bv[slot].bv_page)
 				continue;
 
-			folio = bvec_folio(&p->bv[slot]);
+			struct folio *folio = bvec_folio(&p->bv[slot]);
+
 			netfs_cancel_copy_to_cache(rreq, folio);
 
 			if (folio == rreq->no_unlock_folio &&
 			    test_bit(NETFS_RREQ_NO_UNLOCK_FOLIO, &rreq->flags)) {
 				_debug("no unlock");
-			} else {
-				trace_netfs_folio(folio, netfs_folio_trace_abandon);
-				folio_unlock(folio);
+				continue;
 			}
+			trace_netfs_folio(folio, netfs_folio_trace_abandon);
+			folio_unlock(folio);
 		}
-		rreq->buffer.first_tail_slot = 0;
 	}
 }
diff --git a/fs/netfs/read_single.c b/fs/netfs/read_single.c
index b248e34bd0c8..c70941121de0 100644
--- a/fs/netfs/read_single.c
+++ b/fs/netfs/read_single.c
@@ -101,7 +101,11 @@ static int netfs_single_dispatch_read(struct netfs_io_request *rreq)
 
 	subreq->start	= 0;
 	subreq->len	= rreq->len;
-	subreq->io_iter	= rreq->buffer.iter;
+
+	bvecq_pos_set(&subreq->io_buffer, &rreq->dispatch_cursor);
+
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->io_buffer.bvecq,
+			    subreq->io_buffer.slot, subreq->io_buffer.offset, subreq->len);
 
 	netfs_queue_read(rreq, subreq);
 
@@ -174,6 +178,15 @@ ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_ite
 	if (IS_ERR(rreq))
 		return PTR_ERR(rreq);
 
+	ret = netfs_extract_iter(iter, rreq->len, INT_MAX, &rreq->dispatch_cursor.bvecq,
+				 0, rreq->gfp);
+	if (ret < 0)
+		goto cleanup_free;
+	if (ret < rreq->len) {
+		ret = -EIO;
+		goto cleanup_free;
+	}
+
 	rreq->progress_at = rreq->len;
 
 	ret = netfs_single_begin_cache_read(rreq, ictx);
@@ -183,7 +196,6 @@ ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_ite
 	netfs_stat(&netfs_n_rh_read_single);
 	trace_netfs_read(rreq, 0, rreq->len, netfs_read_trace_read_single);
 
-	rreq->buffer.iter = *iter;
 	netfs_single_dispatch_read(rreq);
 
 	ret = netfs_wait_for_read(rreq);
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index 91b42820c892..f7f7c7cd764c 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -114,12 +114,12 @@ int netfs_folio_written_back(struct folio *folio)
 static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 					  unsigned int *notes)
 {
-	struct bvecq *bq = wreq->buffer.tail;
-	unsigned int slot = wreq->buffer.first_tail_slot;
+	struct bvecq *bq = wreq->collect_cursor.bvecq;
+	unsigned int slot = wreq->collect_cursor.slot;
 	uoff_t collected_to = wreq->collected_to;
 
 	if (WARN_ON_ONCE(!bq)) {
-		pr_err("[!] Writeback unlock found empty rolling buffer!\n");
+		pr_err("[!] Writeback unlock found empty buffer!\n");
 		netfs_dump_request(wreq);
 		return;
 	}
@@ -130,19 +130,28 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		return;
 	}
 
-	while (!bvecq_acquire_slot(bq, slot)) {
-		bq = rolling_buffer_delete_spent(&wreq->buffer);
-		if (!bq)
-			return;
-		slot = 0;
-	}
-
 	for (;;) {
 		struct folio *folio;
 		struct netfs_folio *finfo;
 		uoff_t fpos, fend;
 		size_t fsize, flen;
 
+		/* Try to clean up the head of the queue if it appears to be
+		 * used up, but we need to be very careful - the cleanup can
+		 * catch the dispatcher, which could lead to us having nothing
+		 * left in the queue, causing the front and back pointers to
+		 * end up on different tracks.  To avoid this, we must always
+		 * keep at least one segment in the queue.
+		 */
+		if (!bvecq_acquire_slot(bq, slot)) {
+			wreq->collect_cursor.slot = slot;
+			if (!bvecq_delete_spent(&wreq->collect_cursor))
+				return;
+			bq = wreq->collect_cursor.bvecq;
+			slot  = wreq->collect_cursor.slot;
+			continue;
+		}
+
 		folio = bvec_folio(&bq->bv[slot]);
 		if (WARN_ONCE(!folio_test_writeback(folio),
 			      "R=%08x: folio %lx is not under writeback\n",
@@ -166,26 +175,13 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		wreq->cleaned_to = fpos + fsize;
 		*notes |= MADE_PROGRESS;
 
-		/* Clean up the head bq.  If we clear an entire bq, then
-		 * we can get rid of it provided it's not also the tail bq
-		 * being filled by the issuer.
-		 */
 		bq->bv[slot].bv_page = NULL;
 		slot++;
-		while (!bvecq_acquire_slot(bq, slot)) {
-			bq = rolling_buffer_delete_spent(&wreq->buffer);
-			if (!bq)
-				goto done;
-			slot = 0;
-		}
-
 		if (fpos + fsize >= collected_to)
 			break;
 	}
 
-	wreq->buffer.tail = bq;
-done:
-	wreq->buffer.first_tail_slot = slot;
+	wreq->collect_cursor.slot = slot;
 }
 
 /*
@@ -230,7 +226,8 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 	trace_netfs_rreq(wreq, netfs_rreq_trace_collect);
 
 reassess_streams:
-	issued_to = atomic64_read(&wreq->issued_to);
+	/* Order reading the issued_to point before reading the queue it refers to. */
+	issued_to = atomic64_read_acquire(&wreq->issued_to);
 	smp_rmb();
 	collected_to = ULLONG_MAX;
 	if (wreq->origin == NETFS_WRITEBACK ||
@@ -560,8 +557,12 @@ void netfs_write_subrequest_terminated(void *_op, ssize_t transferred_or_error)
 			 * data is tracked.
 			 */
 			netfs_stat(&netfs_n_wh_write_failed);
-			if (test_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags))
-				break;
+			if (test_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags)) {
+				/* We don't retry failed cache writes. */
+				__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
+				if (!subreq->error)
+					subreq->error = -ENOBUFS;
+			}
 
 			trace_netfs_failure(wreq, subreq, transferred_or_error, netfs_fail_write);
 			__set_bit(NETFS_SREQ_CANCELLED, &subreq->flags);
@@ -599,8 +600,22 @@ void netfs_write_subrequest_terminated(void *_op, ssize_t transferred_or_error)
 		subreq->error = 0;
 		subreq->transferred += transferred_or_error;
 
-		if (subreq->transferred < subreq->len)
-			set_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
+		switch (subreq->source) {
+		case NETFS_WRITE_TO_CACHE:
+			/* Need to leave short cache writes to the cache's
+			 * ->collect_write() to deal with.  They're not
+			 * necessarily bad - the cache may just have run out of
+			 * space and can only store a part of the data.
+			 */
+			break;
+
+		case NETFS_UPLOAD_TO_SERVER:
+			if (subreq->transferred < subreq->len)
+				set_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
+			break;
+		default:
+			break;
+		}
 	}
 
 	trace_netfs_sreq(subreq, netfs_sreq_trace_terminated);
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index f0f478666651..8fab5cf00d7b 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -107,10 +107,6 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 	ictx = netfs_inode(wreq->inode);
 	if (is_cacheable)
 		fscache_begin_write_operation(&wreq->cache_resources, netfs_i_cookie(ictx));
-	if (rolling_buffer_init(&wreq->buffer, ITER_SOURCE, wreq->gfp,
-				(origin == NETFS_WRITEBACK ||
-				 origin == NETFS_WRITEBACK_SINGLE)) < 0)
-		goto nomem;
 
 	wreq->cleaned_to = wreq->start;
 	if (wreq->cache_resources.dio_size > 1)
@@ -135,9 +131,6 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 	}
 
 	return wreq;
-nomem:
-	netfs_put_failed_request(wreq);
-	return ERR_PTR(-ENOMEM);
 }
 
 /**
@@ -163,22 +156,14 @@ void netfs_prepare_write(struct netfs_io_request *wreq,
 			 uoff_t start)
 {
 	struct netfs_io_subrequest *subreq;
-	struct iov_iter *wreq_iter = &wreq->buffer.iter;
-
-	/* Make sure we don't point the iterator at a used-up bvecq struct
-	 * being used as a placeholder to prevent the queue from collapsing.
-	 * In such a case, extend the queue.
-	 */
-	if (iov_iter_is_bvecq(wreq_iter) &&
-	    !bvecq_acquire_slot(wreq_iter->bvecq, wreq_iter->bvecq_slot))
-		rolling_buffer_make_space(&wreq->buffer, wreq->gfp);
 
 	subreq = netfs_alloc_subrequest(wreq, stream->source);
 	if (!subreq)
 		return;
 	subreq->start		= start;
 	subreq->stream_nr	= stream->stream_nr;
-	subreq->io_iter		= *wreq_iter;
+
+	bvecq_pos_set(&subreq->io_buffer, &wreq->dispatch_cursor);
 
 	_enter("R=%x[%x]", wreq->debug_id, subreq->debug_index);
 
@@ -259,15 +244,14 @@ static void netfs_do_issue_write(struct netfs_io_stream *stream,
 }
 
 void netfs_reissue_write(struct netfs_io_stream *stream,
-			 struct netfs_io_subrequest *subreq,
-			 struct iov_iter *source)
+			 struct netfs_io_subrequest *subreq)
 {
-	size_t size = subreq->len - subreq->transferred;
-
 	// TODO: Use encrypted buffer
-	subreq->io_iter = *source;
-	iov_iter_advance(source, size);
-	iov_iter_truncate(&subreq->io_iter, size);
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_SOURCE,
+			    subreq->io_buffer.bvecq, subreq->io_buffer.slot,
+			    subreq->io_buffer.offset,
+			    subreq->len);
+	iov_iter_advance(&subreq->io_iter, subreq->transferred);
 
 	subreq->retry_count++;
 	subreq->error = 0;
@@ -285,8 +269,12 @@ void netfs_issue_write(struct netfs_io_request *wreq,
 	if (!subreq)
 		return;
 
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_SOURCE,
+			    subreq->io_buffer.bvecq, subreq->io_buffer.slot,
+			    subreq->io_buffer.offset,
+			    subreq->len);
+
 	stream->construct = NULL;
-	subreq->io_iter.count = subreq->len;
 	netfs_do_issue_write(stream, subreq);
 }
 
@@ -323,7 +311,6 @@ size_t netfs_advance_write(struct netfs_io_request *wreq,
 	_debug("part %zx/%zx %zx/%zx", subreq->len, stream->sreq_max_len, part, len);
 	subreq->len += part;
 	subreq->nr_segs++;
-	stream->submit_extendable_to -= part;
 
 	if (subreq->len >= stream->sreq_max_len ||
 	    subreq->nr_segs >= stream->sreq_max_segs ||
@@ -347,7 +334,8 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	struct netfs_io_stream *stream;
 	struct netfs_group *fgroup; /* TODO: Use this with ceph */
 	struct netfs_folio *finfo;
-	size_t iter_off = 0;
+	struct bvecq *queue = wreq->load_cursor.bvecq;
+	unsigned int slot;
 	size_t fsize = folio_size(folio), flen = fsize, foff = 0;
 	uoff_t fpos = folio_pos(folio), i_size;
 	bool to_eof = false, streamw = false;
@@ -355,12 +343,20 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 
 	_enter("");
 
-	if (rolling_buffer_make_space(&wreq->buffer, wreq->gfp) < 0)
-		return -ENOMEM;
+	if (!wreq->spare) {
+		wreq->spare = bvecq_alloc_one(BVECQ_POOL_SLOTS, wreq->gfp, true);
+		if (!wreq->spare)
+			return -ENOMEM;
+	}
 
-	/* netfs_perform_write() may shift i_size around the page or from out
-	 * of the page to beyond it, but cannot move i_size into or through the
-	 * page since we have it locked.
+	/* netfs_perform_write() may shift i_size around the folio or from out
+	 * of the folio to beyond it, but cannot move i_size into or through
+	 * the folio since we have it locked.
+	 *
+	 * Truncate could in theory move i_size into or before the folio, but
+	 * it should take steps to prevent writeback from happening
+	 * concurrently and should wait for any in-progress writebacks before
+	 * proceeding.
 	 */
 	i_size = i_size_read(wreq->inode);
 
@@ -452,8 +448,29 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 		trace_netfs_folio(folio, netfs_folio_trace_store_plus);
 	}
 
+	/* Institute a new bvec queue segment if the current one is full or if
+	 * we encounter a discontiguity.  The discontiguity break is important
+	 * when it comes to bulk unlocking folios by file range.
+	 */
+	if (bvecq_is_full(queue) ||
+	    (fpos != wreq->last_end && wreq->last_end > 0)) {
+		bvecq_buffer_append(&wreq->load_cursor, wreq->spare);
+		wreq->spare = NULL;
+
+		queue = wreq->load_cursor.bvecq;
+		bvecq_pos_move(&wreq->dispatch_cursor, queue);
+		wreq->dispatch_cursor.slot = 0;
+	}
+
 	/* Attach the folio to the rolling buffer. */
-	rolling_buffer_append(&wreq->buffer, folio, wreq->gfp);
+	slot = queue->nr_slots;
+	bvec_set_folio(&queue->bv[slot], folio, fsize, 0);
+	trace_netfs_bv_slot(queue, slot);
+	slot++;
+	bvecq_filled_to(queue, slot);
+	wreq->load_cursor.slot = slot;
+	wreq->load_cursor.offset = 0;
+	wreq->last_end = fpos + fsize;
 
 	/* Move the submission point forward to allow for write-streaming data
 	 * not starting at the front of the page.  We don't do write-streaming
@@ -462,10 +479,19 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	 * Also skip uploading for data that's been read and just needs copying
 	 * to the cache.
 	 */
+	bvecq_pos_nudge(&wreq->dispatch_cursor);
+
 	for (int s = 0; s < NR_IO_STREAMS; s++) {
+		size_t soff = foff, slen = flen, alignment = 1;
+
 		stream = &wreq->io_streams[s];
-		stream->submit_off = foff;
-		stream->submit_len = flen;
+		if (stream->source == NETFS_WRITE_TO_CACHE)
+			alignment = wreq->cache_resources.dio_size;
+		stream = &wreq->io_streams[s];
+		stream->submit_off = round_down(soff, alignment);
+		slen += foff - stream->submit_off;
+		stream->submit_len = round_up(slen, alignment);
+
 		if (!stream->avail ||
 		    (stream->source == NETFS_WRITE_TO_CACHE && streamw) ||
 		    (stream->source == NETFS_UPLOAD_TO_SERVER &&
@@ -499,14 +525,10 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 			break;
 		stream = &wreq->io_streams[choose_s];
 
-		/* Advance the iterator(s). */
-		if (stream->submit_off > iter_off) {
-			rolling_buffer_advance(&wreq->buffer, stream->submit_off - iter_off);
-			iter_off = stream->submit_off;
-		}
+		/* Advance the cursor. */
+		wreq->dispatch_cursor.offset = stream->submit_off;
 
 		atomic64_set(&wreq->issued_to, fpos + stream->submit_off);
-		stream->submit_extendable_to = fsize - stream->submit_off;
 		part = netfs_advance_write(wreq, stream, fpos + stream->submit_off,
 					   stream->submit_len, to_eof);
 		stream->submit_off += part;
@@ -518,9 +540,9 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 			debug = true;
 	}
 
-	if (fsize > iter_off)
-		rolling_buffer_advance(&wreq->buffer, fsize - iter_off);
-	atomic64_set(&wreq->issued_to, fpos + fsize);
+	bvecq_pos_step(&wreq->dispatch_cursor);
+	/* Order loading the queue before updating the issue_to point */
+	atomic64_set_release(&wreq->issued_to, fpos + fsize);
 
 	if (!debug)
 		kdebug("R=%x: No submit", wreq->debug_id);
@@ -581,6 +603,11 @@ int netfs_writepages(struct address_space *mapping,
 		goto couldnt_start;
 	}
 
+	if (bvecq_buffer_init(&wreq->load_cursor, wreq->gfp, true) < 0)
+		goto nomem;
+	bvecq_pos_set(&wreq->dispatch_cursor, &wreq->load_cursor);
+	bvecq_pos_set(&wreq->collect_cursor, &wreq->dispatch_cursor);
+
 	__set_bit(NETFS_RREQ_OFFLOAD_COLLECTION, &wreq->flags);
 	trace_netfs_write(wreq, netfs_write_trace_writeback);
 	netfs_stat(&netfs_n_wh_writepages);
@@ -605,12 +632,17 @@ int netfs_writepages(struct address_space *mapping,
 	} while ((folio = writeback_iter(mapping, wbc, folio, &error)));
 
 	netfs_end_issue_write(wreq);
+	bvecq_pos_unset(&wreq->load_cursor);
+	bvecq_pos_unset(&wreq->dispatch_cursor);
 	netfs_wake_collector(wreq);
 
 	netfs_put_request(wreq, netfs_rreq_trace_put_return);
 	_leave(" = %d", error);
 	return error;
 
+nomem:
+	error = -ENOMEM;
+	netfs_put_failed_request(wreq);
 couldnt_start:
 	if (error == -ENOMEM) {
 		folio_redirty_for_writepage(wbc, folio);
@@ -631,23 +663,28 @@ EXPORT_SYMBOL(netfs_writepages);
  * netfs_writeback_single - Write back a monolithic payload
  * @mapping: The mapping to write from
  * @wbc: Hints from the VM
- * @iter: Data to write.
+ * @iter: Buffer to write from
+ * @len: Amount to write from buffer
  *
  * Write a monolithic, non-pagecache object back to the server and/or the
- * cache.  The caller must explicitly set NETFS_RREQ_UPLOAD_TO_SERVER when
- * initialising the request if it wants the data to be written to the server
- * (for AFS directories and symlinks, this is not possible; things like mkdir,
- * symlink, rmdir and unlink must be used instead).
+ * cache. There's a maximum of one subrequest per stream.  The buffer should be
+ * rounded out sufficiently that it can accommodate cache DIO rounding.
+ *
+ * The caller must explicitly set NETFS_RREQ_UPLOAD_TO_SERVER when initialising
+ * the request if it wants the data to be written to the server (for AFS
+ * directories and symlinks, this is not possible; things like mkdir, symlink,
+ * rmdir and unlink must be used instead).
  *
  * Return: 0 if successful; 1 if skipped due to lock conflict and WB_SYNC_NONE;
  * or a negative error code.
  */
 int netfs_writeback_single(struct address_space *mapping,
 			   struct writeback_control *wbc,
-			   struct iov_iter *iter)
+			   struct iov_iter *iter, size_t len)
 {
 	struct netfs_io_request *wreq;
 	struct netfs_inode *ictx = netfs_inode(mapping->host);
+	size_t clen;
 	int ret;
 
 	if (!netfs_wb_begin(ictx, wbc->sync_mode == WB_SYNC_NONE)) {
@@ -661,10 +698,27 @@ int netfs_writeback_single(struct address_space *mapping,
 		ret = PTR_ERR(wreq);
 		goto couldnt_start;
 	}
+	wreq->len = len;
+	clen = len;
+
+	if (wreq->cache_resources.dio_size > 1) {
+		clen = round_up(len, wreq->cache_resources.dio_size);
+		if (clen > iov_iter_count(iter)) {
+			ret = -EIO;
+			goto cleanup_free;
+		}
+	}
 
-	wreq->buffer.iter = *iter;
-	wreq->len = iov_iter_count(iter);
-	wreq->submitted = wreq->len;
+	ret = netfs_extract_iter(iter, clen, INT_MAX, &wreq->dispatch_cursor.bvecq,
+				 0, wreq->gfp);
+	if (ret < 0)
+		goto cleanup_free;
+	if (ret < clen) {
+		ret = -EIO;
+		goto cleanup_free;
+	}
+
+	bvecq_pos_set(&wreq->collect_cursor, &wreq->dispatch_cursor);
 
 	__set_bit(NETFS_RREQ_OFFLOAD_COLLECTION, &wreq->flags);
 	trace_netfs_write(wreq, netfs_write_trace_writeback_single);
@@ -685,12 +739,14 @@ int netfs_writeback_single(struct address_space *mapping,
 
 		subreq = stream->construct;
 		subreq->len = wreq->len;
+		if (stream->source == NETFS_WRITE_TO_CACHE)
+			subreq->len = clen;
 		stream->submit_len = subreq->len;
-		stream->submit_extendable_to = round_up(wreq->len, PAGE_SIZE);
 
 		netfs_issue_write(wreq, stream);
 	}
 
+	wreq->submitted = wreq->len;
 	netfs_all_subreqs_queued(wreq);
 	netfs_wake_collector(wreq);
 
@@ -705,6 +761,8 @@ int netfs_writeback_single(struct address_space *mapping,
 	_leave(" = %d", ret);
 	return ret;
 
+cleanup_free:
+	netfs_put_failed_request(wreq);
 couldnt_start:
 	netfs_wb_end(ictx);
 	_leave(" = %d", ret);
diff --git a/fs/netfs/write_retry.c b/fs/netfs/write_retry.c
index 2f20577563e1..5352566b69d8 100644
--- a/fs/netfs/write_retry.c
+++ b/fs/netfs/write_retry.c
@@ -17,15 +17,17 @@
 static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 				     struct netfs_io_stream *stream)
 {
+	struct bvecq_pos dispatch_cursor = {};
 	struct list_head *next;
 
 	_enter("R=%x[%x:]", wreq->debug_id, stream->stream_nr);
 
 	if (list_empty(&stream->subrequests))
 		return;
+	if (WARN_ON_ONCE(stream->source != NETFS_UPLOAD_TO_SERVER))
+		return; /* Shouldn't be possible to get here to retry cache writes. */
 
-	if (stream->source == NETFS_UPLOAD_TO_SERVER &&
-	    wreq->netfs_ops->retry_request)
+	if (wreq->netfs_ops->retry_request)
 		wreq->netfs_ops->retry_request(wreq, stream);
 
 	if (unlikely(stream->failed))
@@ -39,12 +41,8 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 			if (test_bit(NETFS_SREQ_FAILED, &subreq->flags))
 				break;
 			if (__test_and_clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags)) {
-				struct iov_iter source;
-
-				netfs_reset_iter(subreq);
-				source = subreq->io_iter;
 				netfs_get_subrequest(subreq, netfs_sreq_trace_get_resubmit);
-				netfs_reissue_write(stream, subreq, &source);
+				netfs_reissue_write(stream, subreq);
 			}
 		}
 		return;
@@ -54,10 +52,11 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 
 	do {
 		struct netfs_io_subrequest *subreq = NULL, *from, *to, *tmp;
-		struct iov_iter source;
 		uoff_t start, len;
 		size_t part;
-		bool boundary = false;
+		bool boundary = false, subreq_superfluous = false;;
+
+		bvecq_pos_unset(&dispatch_cursor);
 
 		/* Go through the stream and find the next span of contiguous
 		 * data that we then rejig (cifs, for example, needs the wsize
@@ -70,7 +69,7 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 
 		if (test_bit(NETFS_SREQ_FAILED, &from->flags) ||
 		    !test_bit(NETFS_SREQ_NEED_RETRY, &from->flags))
-			return;
+			goto out;
 
 		for (;;) {
 			/* Read pointer to subreq before reading subreq state. */
@@ -79,7 +78,8 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 				break;
 
 			subreq = list_entry(next, struct netfs_io_subrequest, rreq_link);
-			if (subreq->start + subreq->transferred != start + len ||
+			if (subreq->start != start + len ||
+			    subreq->transferred > 0 ||
 			    test_bit(NETFS_SREQ_BOUNDARY, &subreq->flags) ||
 			    !test_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags))
 				break;
@@ -90,30 +90,40 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 		/* Determine the set of buffers we're going to use.  Each
 		 * subreq gets a subset of a single overall contiguous buffer.
 		 */
-		netfs_reset_iter(from);
-		source = from->io_iter;
-		source.count = len;
+		bvecq_pos_transfer(&dispatch_cursor, &from->io_buffer);
+		bvecq_pos_advance(&dispatch_cursor, from->transferred);
 
-		/* Work through the sublist. */
+		/* Work through the sublist.  The chain of buffers we're going
+		 * to fill is attached to dispatch_cursor and we need to read
+		 * 'len' amount of data from 'start'.
+		 */
 		subreq = from;
 		list_for_each_entry_from(subreq, &stream->subrequests, rreq_link) {
-			if (!len)
+			if (!len) {
+				subreq_superfluous = true;
 				break;
+			}
 
 			subreq->start	= start;
 			subreq->len	= len;
 			__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
 			trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
+			subreq->transferred = 0;
+
+			bvecq_pos_unset(&subreq->io_buffer);
 
 			/* Renegotiate max_len (wsize) */
 			stream->sreq_max_len = len;
+			stream->sreq_max_segs = INT_MAX;
 			stream->prepare_write(subreq);
 
-			part = umin(len, stream->sreq_max_len);
-			if (unlikely(stream->sreq_max_segs))
-				part = netfs_limit_iter(&source, 0, part, stream->sreq_max_segs);
+			bvecq_pos_set(&subreq->io_buffer, &dispatch_cursor);
+			part = bvecq_slice(&dispatch_cursor,
+					   umin(len, stream->sreq_max_len),
+					   stream->sreq_max_segs,
+					   &subreq->nr_segs);
 			subreq->len = part;
-			subreq->transferred = 0;
+
 			len -= part;
 			start += part;
 			if (len && subreq == to &&
@@ -121,16 +131,18 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 				boundary = true;
 
 			netfs_get_subrequest(subreq, netfs_sreq_trace_get_resubmit);
-			netfs_reissue_write(stream, subreq, &source);
-			if (subreq == to)
+			netfs_reissue_write(stream, subreq);
+			if (subreq == to) {
+				subreq_superfluous = false;
 				break;
+			}
 		}
 
 		/* If we managed to use fewer subreqs, we can discard the
 		 * excess; if we used the same number, then we're done.
 		 */
 		if (!len) {
-			if (subreq == to)
+			if (!subreq_superfluous)
 				continue;
 			list_for_each_entry_safe_from(subreq, tmp,
 						      &stream->subrequests, rreq_link) {
@@ -172,17 +184,19 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 				netfs_stat(&netfs_n_wh_upload);
 				stream->sreq_max_len = umin(len, wreq->wsize);
 				break;
-			case NETFS_WRITE_TO_CACHE:
-				netfs_stat(&netfs_n_wh_write);
-				break;
 			default:
 				WARN_ON_ONCE(1);
 			}
 
 			stream->prepare_write(subreq);
 
-			part = umin(len, stream->sreq_max_len);
+			bvecq_pos_set(&subreq->io_buffer, &dispatch_cursor);
+			part = bvecq_slice(&dispatch_cursor,
+					   umin(len, stream->sreq_max_len),
+					   stream->sreq_max_segs,
+					   &subreq->nr_segs);
 			subreq->len = subreq->transferred + part;
+
 			len -= part;
 			start += part;
 			if (!len && boundary) {
@@ -190,13 +204,16 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 				boundary = false;
 			}
 
-			netfs_reissue_write(stream, subreq, &source);
+			netfs_reissue_write(stream, subreq);
 			if (!len)
 				break;
 
 		} while (len);
 
 	} while (!list_is_head(next, &stream->subrequests));
+
+out:
+	bvecq_pos_unset(&dispatch_cursor);
 }
 
 /*
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index aa305fe2d4e1..f3249d0573c4 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -19,10 +19,12 @@
 #include <linux/pagemap.h>
 #include <linux/bvecq.h>
 #include <linux/uio.h>
-#include <linux/rolling_buffer.h>
 
 enum netfs_sreq_ref_trace;
 typedef struct mempool mempool_t;
+struct readahead_control;
+struct netfs_io_request;
+struct netfs_io_subrequest;
 struct fscache_occupancy;
 
 /**
@@ -144,7 +146,6 @@ struct netfs_io_stream {
 	unsigned int		sreq_max_segs;	/* 0 or max number of segments in an iterator */
 	unsigned int		submit_off;	/* Folio offset we're submitting from */
 	unsigned int		submit_len;	/* Amount of data left to submit */
-	unsigned int		submit_extendable_to; /* Amount I/O can be rounded up to */
 	void (*prepare_write)(struct netfs_io_subrequest *subreq);
 	void (*issue_write)(struct netfs_io_subrequest *subreq);
 	/* Collection tracking */
@@ -187,6 +188,7 @@ struct netfs_io_subrequest {
 	struct netfs_io_request *rreq;		/* Supervising I/O request */
 	struct work_struct	work;
 	struct list_head	rreq_link;	/* Link in rreq->subrequests */
+	struct bvecq_pos	io_buffer;	/* Bookmark in the combined queue of the start */
 	struct iov_iter		io_iter;	/* Iterator for this subrequest */
 	uoff_t			start;		/* Where to start the I/O */
 	size_t			len;		/* Size of the I/O */
@@ -247,11 +249,14 @@ struct netfs_io_request {
 	struct netfs_io_stream	io_streams[2];	/* Streams of parallel I/O operations */
 #define NR_IO_STREAMS 2 //wreq->nr_io_streams
 	struct netfs_group	*group;		/* Writeback group being written back */
-	struct rolling_buffer	buffer;		/* Unencrypted buffer */
+	struct bvecq		*spare;		/* Advance allocation of bvecq */
+	struct bvecq_pos	load_cursor;	/* Point at which new folios are loaded in */
+	struct bvecq_pos	dispatch_cursor; /* Point from which buffers are dispatched */
+	struct bvecq_pos	collect_cursor;	/* Clear-up point of I/O buffer */
 	wait_queue_head_t	waitq;		/* Processor waiter */
 	void			*netfs_priv;	/* Private data for the netfs */
 	void			*netfs_priv2;	/* Private data for the netfs */
-	struct bvecq		*direct_bq;	/* DIO buffer list (when handling iovec-iter) */
+	uoff_t			last_end;	/* End pos of last folio submitted */
 	uoff_t			submitted;	/* Amount submitted for I/O so far */
 	uoff_t			len;		/* Length of the request */
 	size_t			transferred;	/* Amount to be indicated as transferred */
@@ -425,7 +430,7 @@ void netfs_single_mark_inode_dirty(struct inode *inode);
 ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_iter *iter);
 int netfs_writeback_single(struct address_space *mapping,
 			   struct writeback_control *wbc,
-			   struct iov_iter *iter);
+			   struct iov_iter *iter, size_t len);
 
 /* Address operations API */
 struct readahead_control;
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index e80c27c49ce2..81a3b7aaa187 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -229,7 +229,9 @@
 	EM(netfs_folio_trace_sched_copy,	"sched-copy")	\
 	EM(netfs_folio_trace_store,		"store")	\
 	EM(netfs_folio_trace_store_copy,	"store-copy")	\
-	E_(netfs_folio_trace_store_plus,	"store+")
+	EM(netfs_folio_trace_store_plus,	"store+")	\
+	EM(netfs_folio_trace_zero,		"zero")		\
+	E_(netfs_folio_trace_zero_ra,		"zero-ra")
 
 #define netfs_collect_contig_traces				\
 	EM(netfs_contig_trace_collect,		"Collect")	\
@@ -386,10 +388,10 @@ TRACE_EVENT(netfs_sreq,
 		    __entry->len	= sreq->len;
 		    __entry->transferred = sreq->transferred;
 		    __entry->start	= sreq->start;
-		    __entry->slot	= sreq->io_iter.bvecq_slot;
+		    __entry->slot	= sreq->io_buffer.slot;
 			   ),
 
-	    TP_printk("R=%08x[%x] %s %s f=%03x s=%llx %zx/%zx s=%u e=%d",
+	    TP_printk("R=%08x[%x] %s %s f=%03x s=%llx %zx/%zx bv=%u e=%d",
 		      __entry->rreq, __entry->index,
 		      __print_symbolic(__entry->source, netfs_sreq_sources),
 		      __print_symbolic(__entry->what, netfs_sreq_traces),
@@ -782,6 +784,30 @@ TRACE_EVENT(netfs_read_progress_at,
 		      __entry->rreq, __entry->cleaned_to, __entry->progress_at)
 	    );
 
+TRACE_EVENT(netfs_bv_slot,
+	    TP_PROTO(const struct bvecq *bq, int slot),
+
+	    TP_ARGS(bq, slot),
+
+	    TP_STRUCT__entry(
+		    __field(unsigned long,		pfn)
+		    __field(unsigned int,		offset)
+		    __field(unsigned int,		len)
+		    __field(unsigned int,		slot)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->slot = slot;
+		    __entry->pfn = page_to_pfn(bq->bv[slot].bv_page);
+		    __entry->offset = bq->bv[slot].bv_offset;
+		    __entry->len = bq->bv[slot].bv_len;
+			   ),
+
+	    TP_printk("bq[%x] p=%lx %x-%x",
+		      __entry->slot,
+		      __entry->pfn, __entry->offset, __entry->offset + __entry->len)
+	    );
+
 #undef EM
 #undef E_
 #endif /* _TRACE_NETFS_H */

