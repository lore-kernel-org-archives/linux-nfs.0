Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF2EC34D4E9
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:45:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787582721; cv=none; b=hOg3NmoThk5pBMOuQy3GBaLyQhEvhg0Jkdza7WyD0Ek4U56I59AzAUdjCXRsML72bnsCZbgfeqYz1GV1aarlO8r0NP5g+e3nwFqQOzTjfR3qMpiGXj7v/hTeiA32Pds1to8Sj9ShscCNF7W+zs2/ZaMp9+2AM9aZhvN9F2xmXfY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787582721; c=relaxed/simple;
	bh=uxGicCKUp4L9Q4cXMZwHIssV/cZPQSbdjYxowJjzhHk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=G5B055bMv9xq0Q2t8YgkB6BhARr/079dKbVwzGaSs9V0tTurMv6sVUOocuMcLany/ehGmI0KDaX+ODcgpAyWLdtBkcEhayHcFlzPWMRYynDjulkoKKtafNPulejPagSsJWrCDzbC0FpFiNEAGkWmNJuOHugxvpSDmGh4Jr5UZ6c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Chjz99Fm; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Chjz99Fm"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787582716;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ewRjjJtQSsQHPDzITGXupEXzwZctJOCmrWbevwVivH8=;
	b=Chjz99Fmp6hTqYpJO5RInHxJbS8pEXaFO5ZxiOvDSdzyNzNXXTm+w44WRiMXndciqpRWs5
	ab2H7jQpr0iIVf8YtlRuLwMYZHZt+nrwpOt20CvmJVQNF0RdxGllFwtgeu5n+saVZYs5im
	RVbt36GpzeDNfn9QvdkqQxWFPe6u0n4=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-140-4ylE14V5MPmPHugzkfmKkQ-1; Mon,
 24 Aug 2026 10:45:11 -0400
X-MC-Unique: 4ylE14V5MPmPHugzkfmKkQ-1
X-Mimecast-MFC-AGG-ID: 4ylE14V5MPmPHugzkfmKkQ_1787582704
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 84894195F16C;
	Mon, 24 Aug 2026 14:45:04 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.15])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 1148730002ED;
	Mon, 24 Aug 2026 14:44:56 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Paulo Alcantara <pc@manguebit.org>
Cc: David Howells <dhowells@redhat.com>,
	Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
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
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Shyam Prasad N <sprasad@microsoft.com>,
	Tom Talpey <tom@talpey.com>
Subject: [PATCH v10 24/35] netfs: Switch to using bvecq rather than folio_queue and rolling_buffer
Date: Mon, 24 Aug 2026 15:41:17 +0100
Message-ID: <20260824144130.759997-25-dhowells@redhat.com>
In-Reply-To: <20260824144130.759997-1-dhowells@redhat.com>
References: <20260824144130.759997-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Switch netfslib to using bvecq, a segmented bio_vec[] queue, instead of the
folio_queue and rolling_buffer constructs, to keep track of the regions of
memory it is performing I/O upon.

For unbuffered/direct I/O, the iterator is extracted into the queue up
front.  For buffered I/O, the folios are added to the queue as the
operation proceeds, much as it does now with folio_queues.  For buffered
reads and writes through the pagecache, bv_len is set to the length of the
entire folio and then slices of the relevant parts are passed to
subrequests.

The bvecq structs are marked with information as to how the regions
contained therein should be disposed of (unlock-only, free, unpin).

When setting up a subrequest, netfslib will furnish it with a slice of the
main buffer queue as a pointer to starting bvecq, slot and offset and, for
the moment, an ITER_BVECQ iterator is set to cover the slice in
subreq->io_iter.

Notes on the implementation:

 (1) This patch uses the concept of a 'bvecq position', which is a tuple of
     { bvecq, slot, offset }.  This is lighter weight than using a full
     iov_iter, though that would also suffice.  If not NULL, the position
     also holds a reference on the bvecq it is pointing to.  This is
     probably overkill as only the hindmost position (that of collection)
     needs to hold a reference.

 (2) There are three positions on the netfs_io_request struct.  Not all are
     used by every request type.

     Firstly, there's ->load_cursor, which is used by buffered read and
     write to point to the next slot to have a folio inserted into it
     (either loaded from the readahead_control or from writeback_iter()).

     Secondly, there's ->dispatch_cursor, which is used to provide the
     position in the buffer from which we start dispatching a subrequest.

     Thirdly, there's the ->collect_cursor, which is used by the collection
     routines to point to the next memory region to be cleaned up.

 (3) There are two positions on the netfs_io_subrequest struct.

     Firstly, there's ->dispatch_pos, which indicates the position from
     which a subrequest's buffer begins.  This is used as the base of the
     position from which to retry (advanced by ->transfer).

     Secondly, there's ->content, which is normally the same as
     ->dispatch_pos but if the bvecq chain got duplicated or the content
     got copied, then this will point to that and will that will be
     disposed of on retry.  The filesystem may modify ->content, but not
     ->dispatch_pos.

 (4) Maintenance of the position structs is done with helper functions,
     such as bvecq_pos_attach() to hide the refcounting.

 (5) When sending a write to the cache, the ends of the slice will be
     rounded up/down to the backing file's DIO block alignment.

 (6) bvecq_slice() is used to select a slice of the source buffer and
     assign it to a subrequest.  The source buffer position is advanced.

 (7) netfs_extract_iter() is used by unbuffered/direct I/O API functions to
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

folio_queue and rolling_buffer will be removed in a follow up patch.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
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
 fs/netfs/buffered_read.c     | 123 +++++++++++++++-----------
 fs/netfs/direct_read.c       |  78 +++++++----------
 fs/netfs/direct_write.c      |  69 ++++++++-------
 fs/netfs/internal.h          |  10 +--
 fs/netfs/iterator.c          |   2 +
 fs/netfs/main.c              |   6 --
 fs/netfs/misc.c              |  20 +----
 fs/netfs/objects.c           |  17 ++--
 fs/netfs/read_collect.c      | 116 +++++++++++++------------
 fs/netfs/read_pgpriv2.c      |  91 +++++++++++++-------
 fs/netfs/read_retry.c        | 102 +++++++++++++---------
 fs/netfs/read_single.c       |  17 +++-
 fs/netfs/stats.c             |   4 +-
 fs/netfs/write_collect.c     |  60 ++++++-------
 fs/netfs/write_issue.c       | 162 ++++++++++++++++++++++++-----------
 fs/netfs/write_retry.c       |  62 ++++++++------
 include/linux/netfs.h        |  27 +++---
 include/trace/events/netfs.h |  46 +++++-----
 22 files changed, 575 insertions(+), 461 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 1dff50323b56..b2eb5bce3e9f 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -2228,8 +2228,9 @@ static int afs_dir_writepages(struct address_space *mapping,
 
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
index 7fd4f985c441..71de59173ea5 100644
--- a/fs/afs/symlink.c
+++ b/fs/afs/symlink.c
@@ -245,9 +245,9 @@ int afs_symlink_writepages(struct address_space *mapping,
 
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
index a43fe168127a..23007f450ef4 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -636,7 +636,6 @@ static void cachefiles_issue_write(struct netfs_io_subrequest *subreq)
 	struct netfs_cache_resources *cres = &wreq->cache_resources;
 	struct cachefiles_object *object = cachefiles_cres_object(cres);
 	struct cachefiles_cache *cache = object->volume->cache;
-	struct netfs_io_stream *stream = &wreq->io_streams[subreq->stream_nr];
 	const struct cred *saved_cred;
 	size_t off, pre, post, len = subreq->len;
 	uoff_t start = subreq->start;
@@ -661,17 +660,6 @@ static void cachefiles_issue_write(struct netfs_io_subrequest *subreq)
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
index 5af849b2f283..8a843822d47b 100644
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
+	bvecq_pos_set(&subreq->dispatch_pos, &rreq->dispatch_cursor);
+	extracted = bvecq_slice(&rreq->dispatch_cursor, rsize,
+				stream->sreq_max_segs, &subreq->nr_segs);
+	if (extracted < rsize) {
+		subreq->len = extracted;
+		trace_netfs_sreq(subreq, netfs_sreq_trace_limited);
 	}
 
-	subreq->io_iter	= rreq->buffer.iter;
-
-	iov_iter_truncate(&subreq->io_iter, subreq->len);
-	rolling_buffer_advance(&rreq->buffer, subreq->len);
 	return subreq->len;
 }
 
@@ -192,6 +187,10 @@ void netfs_queue_read(struct netfs_io_request *rreq,
 static void netfs_issue_read(struct netfs_io_request *rreq,
 			     struct netfs_io_subrequest *subreq)
 {
+	bvecq_pos_set(&subreq->content, &subreq->dispatch_pos);
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->content.bvecq,
+			    subreq->content.slot, subreq->content.offset, subreq->len);
+
 	switch (subreq->source) {
 	case NETFS_DOWNLOAD_FROM_SERVER:
 		rreq->netfs_ops->issue_read(subreq);
@@ -200,7 +199,8 @@ static void netfs_issue_read(struct netfs_io_request *rreq,
 		netfs_read_cache_to_pagecache(rreq, subreq);
 		break;
 	default:
-		__set_bit(NETFS_SREQ_CLEAR_TAIL, &subreq->flags);
+		bvecq_zero(&subreq->content, subreq->len);
+		subreq->transferred = subreq->len;
 		subreq->error = 0;
 		iov_iter_zero(subreq->len, &subreq->io_iter);
 		subreq->transferred = subreq->len;
@@ -229,6 +229,10 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 	uoff_t start = rreq->start;
 	int ret = 0;
 
+	_enter("R=%08x", rreq->debug_id);
+
+	bvecq_pos_set(&rreq->dispatch_cursor, &rreq->load_cursor);
+
 	do {
 		int (*prepare_read)(struct netfs_io_subrequest *subreq) = NULL;
 		struct netfs_io_subrequest *subreq;
@@ -373,6 +377,9 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 
 	/* Defer error return as we may need to wait for outstanding I/O. */
 	cmpxchg(&rreq->error, 0, ret);
+
+	bvecq_pos_unset(&rreq->load_cursor);
+	bvecq_pos_unset(&rreq->dispatch_cursor);
 }
 
 /**
@@ -420,8 +427,7 @@ void netfs_readahead(struct readahead_control *ractl)
 	 * acquires a ref on each folio that we will need to release later -
 	 * but we don't want to do that until after we've started the I/O.
 	 */
-	added = rolling_buffer_bulk_load_from_ra(&rreq->buffer, ractl,
-						 rreq->debug_id, rreq->gfp);
+	added = bvecq_load_from_ra(&rreq->load_cursor, ractl);
 	if (added < 0) {
 		ret = added;
 		goto cleanup_free;
@@ -430,6 +436,7 @@ void netfs_readahead(struct readahead_control *ractl)
 
 	rreq->submitted = rreq->start + added;
 	rreq->cleaned_to = rreq->start;
+	bvecq_pos_set(&rreq->collect_cursor, &rreq->load_cursor);
 	netfs_read_set_unlock_at(rreq);
 
 	netfs_read_to_pagecache(rreq);
@@ -442,21 +449,21 @@ void netfs_readahead(struct readahead_control *ractl)
 EXPORT_SYMBOL(netfs_readahead);
 
 /*
- * Create a rolling buffer with a single occupying folio.
+ * Create a buffer queue with a single occupying folio.
  */
-static int netfs_create_singular_buffer(struct netfs_io_request *rreq, struct folio *folio,
-					unsigned int rollbuf_flags)
+static int netfs_create_singular_buffer(struct netfs_io_request *rreq, struct folio *folio)
 {
-	ssize_t added;
+	struct bvecq *bq;
+	size_t fsize = folio_size(folio);
 
-	if (rolling_buffer_init(&rreq->buffer, rreq->debug_id, ITER_DEST, rreq->gfp) < 0)
+	if (bvecq_buffer_init(&rreq->load_cursor, rreq->gfp, false) < 0)
 		return -ENOMEM;
 
-	added = rolling_buffer_append(&rreq->buffer, folio, rollbuf_flags, rreq->gfp);
-	if (added < 0)
-		return added;
-	rreq->submitted = rreq->start + added;
-	rreq->progress_at = added;
+	bq = rreq->load_cursor.bvecq;
+	bvec_set_folio(&bq->bv[0], folio, fsize, 0);
+	bvecq_filled_to(bq, 1);
+	rreq->submitted = rreq->start + fsize;
+	rreq->progress_at = fsize;
 	return 0;
 }
 
@@ -470,11 +477,11 @@ static int netfs_read_gaps(struct file *file, struct folio *folio)
 	struct netfs_group *group = netfs_folio_group(folio);
 	struct netfs_folio *finfo = netfs_folio_info(folio);
 	struct netfs_inode *ctx = netfs_inode(mapping->host);
-	struct folio *sink = NULL;
-	struct bio_vec *bvec;
+	struct bvecq *bq = NULL;
+	struct page *sink = NULL;
 	unsigned int from = finfo->dirty_offset;
 	unsigned int to = from + finfo->dirty_len;
-	unsigned int off = 0, i = 0;
+	unsigned int off = 0, slot = 0;
 	size_t flen = folio_size(folio);
 	size_t nr_bvec = flen / PAGE_SIZE + 2;
 	size_t part;
@@ -499,32 +506,47 @@ static int netfs_read_gaps(struct file *file, struct folio *folio)
 	 * end get copied to, but the middle is discarded.
 	 */
 	ret = -ENOMEM;
-	bvec = kmalloc_objs(*bvec, nr_bvec);
-	if (!bvec)
+	bq = bvecq_alloc_chain(nr_bvec, rreq->gfp, false);
+	if (!bq)
 		goto discard;
+	rreq->load_cursor.bvecq = bq;
 
-	sink = folio_alloc(GFP_KERNEL, 0);
-	if (!sink) {
-		kfree(bvec);
+	sink = alloc_page(rreq->gfp);
+	if (!sink)
 		goto discard;
-	}
 
 	trace_netfs_folio(folio, netfs_folio_trace_read_gaps);
 
-	rreq->direct_bv = bvec;
-	rreq->direct_bv_count = nr_bvec;
+	for (struct bvecq *p = bq; p; p = p->next)
+		p->mem_type = BVECQ_MEM_PAGECACHE;
+
 	if (from > 0) {
-		bvec_set_folio(&bvec[i++], folio, from, 0);
+		folio_get(folio);
+		bvec_set_folio(&bq->bv[slot++], folio, from, 0);
 		off = from;
 	}
 	while (off < to) {
-		part = min_t(size_t, to - off, PAGE_SIZE);
-		bvec_set_folio(&bvec[i++], sink, part, 0);
+		if (slot >= bq->max_slots) {
+			bvecq_filled_to(bq, slot);
+			bq = bq->next;
+			slot = 0;
+		}
+		part = min(to - off, PAGE_SIZE);
+		get_page(sink);
+		bvec_set_page(&bq->bv[slot++], sink, part, 0);
 		off += part;
 	}
-	if (to < flen)
-		bvec_set_folio(&bvec[i++], folio, flen - to, to);
-	iov_iter_bvec(&rreq->buffer.iter, ITER_DEST, bvec, i, rreq->len);
+	if (to < flen) {
+		if (slot >= bq->max_slots) {
+			bvecq_filled_to(bq, slot);
+			bq = bq->next;
+			slot = 0;
+		}
+		folio_get(folio);
+		bvec_set_folio(&bq->bv[slot++], folio, flen - to, to);
+	}
+	bvecq_filled_to(bq, slot);
+
 	rreq->submitted = rreq->start + flen;
 
 	netfs_read_to_pagecache(rreq);
@@ -541,13 +563,14 @@ static int netfs_read_gaps(struct file *file, struct folio *folio)
 		folio_mark_uptodate(folio);
 	}
 
-	if (sink)
-		folio_put(sink);
+	put_page(sink);
 	folio_unlock(folio);
 	netfs_put_request(rreq, netfs_rreq_trace_put_return);
 	return ret < 0 ? ret : 0;
 
 discard:
+	if (sink)
+		put_page(sink);
 	netfs_put_failed_request(rreq);
 alloc_error:
 	folio_unlock(folio);
@@ -598,7 +621,7 @@ int netfs_read_folio(struct file *file, struct folio *folio)
 	trace_netfs_read(rreq, rreq->start, rreq->len, netfs_read_trace_readpage);
 
 	/* Set up the output buffer */
-	ret = netfs_create_singular_buffer(rreq, folio, 0);
+	ret = netfs_create_singular_buffer(rreq, folio);
 	if (ret < 0)
 		goto discard;
 
@@ -755,7 +778,7 @@ int netfs_write_begin(struct netfs_inode *ctx,
 	trace_netfs_read(rreq, pos, len, netfs_read_trace_write_begin);
 
 	/* Set up the output buffer */
-	ret = netfs_create_singular_buffer(rreq, folio, 0);
+	ret = netfs_create_singular_buffer(rreq, folio);
 	if (ret < 0)
 		goto error_put;
 
@@ -820,7 +843,7 @@ int netfs_prefetch_for_write(struct file *file, struct folio *folio,
 	trace_netfs_read(rreq, start, flen, netfs_read_trace_prefetch_for_write);
 
 	/* Set up the output buffer */
-	ret = netfs_create_singular_buffer(rreq, folio, NETFS_ROLLBUF_PAGECACHE_MARK);
+	ret = netfs_create_singular_buffer(rreq, folio);
 	if (ret < 0)
 		goto error_put;
 
diff --git a/fs/netfs/direct_read.c b/fs/netfs/direct_read.c
index 5405e108b7a3..058cc6bb7124 100644
--- a/fs/netfs/direct_read.c
+++ b/fs/netfs/direct_read.c
@@ -16,44 +16,22 @@
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
 
+	bvecq_pos_set(&rreq->dispatch_cursor, &rreq->load_cursor);
+	bvecq_pos_transfer(&rreq->collect_cursor, &rreq->load_cursor);
+
 	do {
 		struct netfs_io_subrequest *subreq;
-		ssize_t slice;
 
 		subreq = netfs_alloc_subrequest(rreq);
 		if (!subreq) {
@@ -79,14 +57,22 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 			}
 		}
 
-		netfs_prepare_dio_read_iterator(subreq);
-		slice = subreq->len;
-		size -= slice;
-		start += slice;
-		rreq->submitted += slice;
+		bvecq_pos_set(&subreq->dispatch_pos, &rreq->dispatch_cursor);
+		bvecq_pos_set(&subreq->content, &rreq->dispatch_cursor);
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
 
+		iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->content.bvecq,
+				    subreq->content.slot, subreq->content.offset, subreq->len);
+
 		rreq->netfs_ops->issue_read(subreq);
 
 		if (test_bit(NETFS_RREQ_PAUSE, &rreq->flags))
@@ -100,6 +86,8 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 		netfs_all_subreqs_queued(rreq);
 		netfs_wake_collector(rreq);
 	}
+
+	bvecq_pos_unset(&rreq->dispatch_cursor);
 }
 
 /*
@@ -178,25 +166,17 @@ ssize_t netfs_unbuffered_read_iter_locked(struct kiocb *iocb, struct iov_iter *i
 	 * buffer for ourselves as the caller's iterator will be trashed when
 	 * we return.
 	 *
-	 * In such a case, extract an iterator to represent as much of the the
-	 * output buffer as we can manage.  Note that the extraction might not
-	 * be able to allocate a sufficiently large bvec array and may shorten
-	 * the request.
+	 * Extract a buffer queue to represent as much of the output buffer as
+	 * we can manage.  The fragments are extracted into a bvecq which will
+	 * have sufficient nodes allocated to hold all the data, though this
+	 * may end up truncated if ENOMEM is encountered.
 	 */
-	if (user_backed_iter(iter)) {
-		ret = netfs_extract_user_iter(iter, rreq->len, &rreq->buffer.iter, 0);
-		if (ret < 0)
-			goto error_put;
-		rreq->direct_bv = (struct bio_vec *)rreq->buffer.iter.bvec;
-		rreq->direct_bv_count = ret;
-		rreq->direct_bv_unpin = iov_iter_extract_will_pin(iter);
-		rreq->len = iov_iter_count(&rreq->buffer.iter);
-	} else {
-		rreq->buffer.iter = *iter;
-		rreq->len = orig_count;
-		rreq->direct_bv_unpin = false;
-		iov_iter_advance(iter, orig_count);
-	}
+	ret = netfs_extract_iter(iter, rreq->len, INT_MAX,
+				 &rreq->load_cursor.bvecq, 0, rreq->gfp);
+	if (ret < 0)
+		goto error_put;
+
+	rreq->len = ret;
 
 	// TODO: Set up bounce buffer if needed
 
diff --git a/fs/netfs/direct_write.c b/fs/netfs/direct_write.c
index 47ec47e3a95b..5bc3ec261f6c 100644
--- a/fs/netfs/direct_write.c
+++ b/fs/netfs/direct_write.c
@@ -73,7 +73,11 @@ static void netfs_unbuffered_write_collect(struct netfs_io_request *wreq,
 	spin_unlock(&wreq->lock);
 
 	wreq->transferred += subreq->transferred;
-	iov_iter_advance(&wreq->buffer.iter, subreq->transferred);
+	if (subreq->transferred < subreq->len) {
+		bvecq_pos_unset(&wreq->dispatch_cursor);
+		bvecq_pos_transfer(&wreq->dispatch_cursor, &subreq->dispatch_pos);
+		bvecq_pos_advance(&wreq->dispatch_cursor, subreq->transferred);
+	}
 
 	stream->collected_to = subreq->start + subreq->transferred;
 	wreq->collected_to = stream->collected_to;
@@ -99,6 +103,9 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 
 	_enter("%llx", wreq->len);
 
+	bvecq_pos_set(&wreq->dispatch_cursor, &wreq->load_cursor);
+	bvecq_pos_set(&wreq->collect_cursor, &wreq->dispatch_cursor);
+
 	if (wreq->origin == NETFS_DIO_WRITE)
 		inode_dio_begin(wreq->inode);
 
@@ -111,6 +118,8 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 			netfs_prepare_write(wreq, stream, wreq->start + wreq->transferred);
 			subreq = stream->construct;
 			stream->construct = NULL;
+		} else {
+			bvecq_pos_set(&subreq->dispatch_pos, &wreq->dispatch_cursor);
 		}
 
 		/* Check if (re-)preparation failed. */
@@ -120,16 +129,18 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 			break;
 		}
 
-		iov_iter_truncate(&subreq->io_iter, wreq->len - wreq->transferred);
+		subreq->len = bvecq_slice(&wreq->dispatch_cursor, stream->sreq_max_len,
+					  stream->sreq_max_segs, &subreq->nr_segs);
+		bvecq_pos_set(&subreq->content, &subreq->dispatch_pos);
+
+		iov_iter_bvec_queue(&subreq->io_iter, ITER_SOURCE,
+				    subreq->content.bvecq, subreq->content.slot,
+				    subreq->content.offset,
+				    subreq->len);
+
 		if (!iov_iter_count(&subreq->io_iter))
 			break;
 
-		subreq->len = netfs_limit_iter(&subreq->io_iter, 0,
-					       stream->sreq_max_len,
-					       stream->sreq_max_segs);
-		iov_iter_truncate(&subreq->io_iter, subreq->len);
-		stream->submit_extendable_to = subreq->len;
-
 		trace_netfs_sreq(subreq, netfs_sreq_trace_submit);
 		stream->issue_write(subreq);
 
@@ -166,9 +177,14 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 		 */
 		subreq->error = -EAGAIN;
 		trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
+
+		bvecq_pos_unset(&subreq->content);
+		bvecq_pos_unset(&wreq->dispatch_cursor);
+		bvecq_pos_transfer(&wreq->dispatch_cursor, &subreq->dispatch_pos);
+
 		if (subreq->transferred > 0) {
-			iov_iter_advance(&wreq->buffer.iter, subreq->transferred);
 			wreq->transferred += subreq->transferred;
+			bvecq_pos_advance(&wreq->dispatch_cursor, subreq->transferred);
 		}
 
 		if (stream->source == NETFS_UPLOAD_TO_SERVER &&
@@ -179,7 +195,6 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 		__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
 		__clear_bit(NETFS_SREQ_BOUNDARY, &subreq->flags);
 		__clear_bit(NETFS_SREQ_FAILED, &subreq->flags);
-		subreq->io_iter		= wreq->buffer.iter;
 		subreq->start		= wreq->start + wreq->transferred;
 		subreq->len		= wreq->len   - wreq->transferred;
 		subreq->transferred	= 0;
@@ -195,6 +210,8 @@ static int netfs_unbuffered_write(struct netfs_io_request *wreq)
 		netfs_stat(&netfs_n_wh_retry_write_subreq);
 	}
 
+	bvecq_pos_unset(&wreq->dispatch_cursor);
+	bvecq_pos_unset(&wreq->load_cursor);
 	netfs_unbuffered_write_done(wreq);
 	_leave(" = %d", ret);
 	return ret;
@@ -213,10 +230,10 @@ static void netfs_unbuffered_write_async(struct work_struct *work)
  * encrypted file.  This can also be used for direct I/O writes.
  */
 ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *iter,
-						  struct netfs_group *netfs_group)
+					   struct netfs_group *netfs_group)
 {
 	struct netfs_io_request *wreq;
-	ssize_t ret, n;
+	ssize_t ret;
 	uoff_t start = iocb->ki_pos;
 	uoff_t end = start + iov_iter_count(iter);
 	size_t len = iov_iter_count(iter);
@@ -252,25 +269,17 @@ ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *
 		 * allocate a sufficiently large bvec array and may shorten the
 		 * request.
 		 */
-		if (user_backed_iter(iter)) {
-			n = netfs_extract_user_iter(iter, len, &wreq->buffer.iter, 0);
-			if (n < 0) {
-				ret = n;
-				goto error_put;
-			}
-			wreq->direct_bv = (struct bio_vec *)wreq->buffer.iter.bvec;
-			wreq->direct_bv_count = n;
-			wreq->direct_bv_unpin = iov_iter_extract_will_pin(iter);
-		} else {
-			/* If this is a kernel-generated async DIO request,
-			 * assume that any resources the iterator points to
-			 * (eg. a bio_vec array) will persist till the end of
-			 * the op.
-			 */
-			wreq->buffer.iter = *iter;
-		}
+		ssize_t n = netfs_extract_iter(iter, len, INT_MAX,
+					       &wreq->load_cursor.bvecq, 0, wreq->gfp);
 
-		wreq->len = iov_iter_count(&wreq->buffer.iter);
+		if (n < 0) {
+			ret = n;
+			goto error_put;
+		}
+		wreq->len = n;
+		_debug("dio-write %zx/%zx %u/%u",
+		       n, len, wreq->load_cursor.bvecq->nr_slots,
+		       wreq->load_cursor.bvecq->max_slots);
 	}
 
 	__set_bit(NETFS_RREQ_USE_IO_ITER, &wreq->flags);
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index 5c05b0dcb143..b402b504a370 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -7,7 +7,6 @@
 
 #include <linux/slab.h>
 #include <linux/seq_file.h>
-#include <linux/folio_queue.h>
 #include <linux/netfs.h>
 #include <linux/fscache.h>
 #include <linux/fscache-cache.h>
@@ -71,9 +70,8 @@ static inline void netfs_proc_del_rreq(struct netfs_io_request *rreq) {}
 /*
  * misc.c
  */
-struct folio_queue *netfs_buffer_make_space(struct netfs_io_request *rreq,
-					    enum netfs_folioq_trace trace);
-void netfs_reset_iter(struct netfs_io_subrequest *subreq);
+struct bvecq *netfs_buffer_make_space(struct netfs_io_request *rreq,
+				      enum netfs_bvecq_trace trace);
 void netfs_wake_collector(struct netfs_io_request *rreq);
 void netfs_subreq_clear_in_progress(struct netfs_io_subrequest *subreq);
 void netfs_wait_for_in_progress_stream(struct netfs_io_request *rreq,
@@ -201,7 +199,6 @@ extern atomic_t netfs_n_wh_retry_write_req;
 extern atomic_t netfs_n_wh_retry_write_subreq;
 extern atomic_t netfs_n_wb_lock_skip;
 extern atomic_t netfs_n_wb_lock_wait;
-extern atomic_t netfs_n_folioq;
 extern atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v);
@@ -239,8 +236,7 @@ void netfs_prepare_write(struct netfs_io_request *wreq,
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
index e66c589ca3b0..c207eacd5c5d 100644
--- a/fs/netfs/iterator.c
+++ b/fs/netfs/iterator.c
@@ -156,6 +156,7 @@ ssize_t netfs_extract_iter(struct iov_iter *orig, size_t max_len, size_t max_pag
 }
 EXPORT_SYMBOL_GPL(netfs_extract_iter);
 
+#if 0
 /**
  * netfs_extract_user_iter - Extract the pages from a user iterator into a bvec
  * @orig: The original iterator
@@ -449,3 +450,4 @@ size_t netfs_limit_iter(const struct iov_iter *iter, size_t start_offset,
 	BUG();
 }
 EXPORT_SYMBOL(netfs_limit_iter);
+#endif
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 3908ea2422c8..041810707eb4 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -109,9 +109,6 @@ static int __init netfs_init(void)
 {
 	int ret = -ENOMEM;
 
-	if (mempool_init_kmalloc_pool(&netfs_folioq_pool, 100, sizeof(struct folio_queue)) < 0)
-		goto error_folioq_pool;
-
 	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool, 100, BVECQ_STD_SIZE) < 0)
 		goto error_bvecq_pool;
 
@@ -169,8 +166,6 @@ static int __init netfs_init(void)
 error_req:
 	mempool_exit(&netfs_bvecq_pool);
 error_bvecq_pool:
-	mempool_exit(&netfs_folioq_pool);
-error_folioq_pool:
 	return ret;
 }
 fs_initcall(netfs_init);
@@ -184,6 +179,5 @@ static void __exit netfs_exit(void)
 	mempool_exit(&netfs_request_pool);
 	kmem_cache_destroy(netfs_request_slab);
 	mempool_exit(&netfs_bvecq_pool);
-	mempool_exit(&netfs_folioq_pool);
 }
 module_exit(netfs_exit);
diff --git a/fs/netfs/misc.c b/fs/netfs/misc.c
index a3cd76d584b8..a2a2aeb1bb0d 100644
--- a/fs/netfs/misc.c
+++ b/fs/netfs/misc.c
@@ -8,6 +8,7 @@
 #include <linux/swap.h>
 #include "internal.h"
 
+#if 0
 /**
  * netfs_alloc_folioq_buffer - Allocate buffer space into a folio queue
  * @mapping: Address space to set on the folio (or NULL).
@@ -103,24 +104,7 @@ void netfs_free_folioq_buffer(struct folio_queue *fq)
 	folio_batch_release(&fbatch);
 }
 EXPORT_SYMBOL(netfs_free_folioq_buffer);
-
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
+#endif
 
 /**
  * netfs_dirty_folio - Mark folio dirty and pin a cache object for writeback
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 13816a02a798..740971955198 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -133,7 +133,6 @@ static void netfs_free_request_rcu(struct rcu_head *rcu)
 static void netfs_deinit_request(struct netfs_io_request *rreq)
 {
 	struct netfs_inode *ictx = netfs_inode(rreq->inode);
-	unsigned int i;
 
 	trace_netfs_rreq(rreq, netfs_rreq_trace_free);
 
@@ -148,16 +147,10 @@ static void netfs_deinit_request(struct netfs_io_request *rreq)
 		rreq->netfs_ops->free_request(rreq);
 	if (rreq->cache_resources.ops)
 		rreq->cache_resources.ops->end_operation(&rreq->cache_resources);
-	if (rreq->direct_bv) {
-		for (i = 0; i < rreq->direct_bv_count; i++) {
-			if (rreq->direct_bv[i].bv_page) {
-				if (rreq->direct_bv_unpin)
-					unpin_user_page(rreq->direct_bv[i].bv_page);
-			}
-		}
-		kvfree(rreq->direct_bv);
-	}
-	rolling_buffer_clear(&rreq->buffer);
+	bvecq_pos_unset(&rreq->load_cursor);
+	bvecq_pos_unset(&rreq->dispatch_cursor);
+	bvecq_pos_unset(&rreq->collect_cursor);
+	bvecq_put(rreq->spare);
 
 	if (atomic_dec_and_test(&ictx->io_count))
 		wake_up_var(&ictx->io_count);
@@ -249,6 +242,8 @@ static void netfs_free_subrequest(struct netfs_io_subrequest *subreq)
 	trace_netfs_sreq(subreq, netfs_sreq_trace_free);
 	if (rreq->netfs_ops->free_subrequest)
 		rreq->netfs_ops->free_subrequest(subreq);
+	bvecq_pos_unset(&subreq->dispatch_pos);
+	bvecq_pos_unset(&subreq->content);
 	mempool_free(subreq, rreq->netfs_ops->subrequest_pool ?: &netfs_subrequest_pool);
 	netfs_stat_d(&netfs_n_rh_sreq);
 	netfs_put_request(rreq, netfs_rreq_trace_put_subreq);
diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index f773579692ab..ea01b2f1f1f8 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -27,9 +27,13 @@
  */
 static void netfs_clear_unread(struct netfs_io_subrequest *subreq)
 {
-	netfs_reset_iter(subreq);
-	WARN_ON_ONCE(subreq->len - subreq->transferred != iov_iter_count(&subreq->io_iter));
-	iov_iter_zero(iov_iter_count(&subreq->io_iter), &subreq->io_iter);
+	struct iov_iter iter;
+
+	iov_iter_bvec_queue(&iter, ITER_DEST, subreq->content.bvecq,
+			    subreq->content.slot, subreq->content.offset, subreq->len);
+	iov_iter_advance(&iter, subreq->transferred);
+	iov_iter_zero(subreq->len, &iter);
+
 	if (subreq->start + subreq->transferred >= subreq->rreq->i_size)
 		__set_bit(NETFS_SREQ_HIT_EOF, &subreq->flags);
 }
@@ -40,11 +44,11 @@ static void netfs_clear_unread(struct netfs_io_subrequest *subreq)
  * dirty and let writeback handle it.
  */
 static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
-				    struct folio_queue *folioq,
+				    struct bvecq *bvecq,
 				    int slot)
 {
 	struct netfs_folio *finfo;
-	struct folio *folio = folioq_folio(folioq, slot);
+	struct folio *folio = page_folio(bvecq->bv[slot].bv_page);
 
 	if (unlikely(folio_pos(folio) < rreq->abandon_to)) {
 		trace_netfs_folio(folio, netfs_folio_trace_abandon);
@@ -75,7 +79,7 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
 			trace_netfs_folio(folio, netfs_folio_trace_read_done);
 		}
 
-		folioq_clear(folioq, slot);
+		bvecq->bv[slot].bv_page = NULL;
 	} else {
 		// TODO: Use of PG_private_2 is deprecated.
 		if (test_bit(NETFS_RREQ_FOLIO_COPY_TO_CACHE, &rreq->flags))
@@ -91,7 +95,7 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
 		folio_unlock(folio);
 	}
 
-	folioq_clear(folioq, slot);
+	bvecq->bv[slot].bv_page = NULL;
 }
 
 /*
@@ -99,21 +103,25 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
  */
 void netfs_read_set_unlock_at(struct netfs_io_request *rreq)
 {
-	struct folio_queue *folioq = rreq->buffer.tail;
-	unsigned int slot = rreq->buffer.first_tail_slot;
+	const struct bvecq *bq = rreq->collect_cursor.bvecq;
+	unsigned int slot = rreq->collect_cursor.slot;
 	size_t cleaned_to = rreq->cleaned_to - rreq->start;
 	size_t progress_at = cleaned_to;
 	size_t minimum = 256 * 1024;
 
 	while (progress_at < rreq->len) {
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = folioq->next;
-			if (!folioq)
+		if (!bvecq_acquire_slot(bq, slot)) {
+			const struct bvecq *next = bvecq_next(bq);
+
+			if (!next)
 				break;
+			if (bvecq_acquire_slot(bq, slot))
+				continue; /* More slots got added. */
+			bq = next;
 			slot = 0;
 		}
 
-		progress_at += folioq_folio_size(folioq, slot);
+		progress_at += bq->bv[slot].bv_len;
 		if (progress_at - cleaned_to >= minimum)
 			break;
 		slot++;
@@ -129,8 +137,8 @@ void netfs_read_set_unlock_at(struct netfs_io_request *rreq)
 static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 				     unsigned int *notes)
 {
-	struct folio_queue *folioq = rreq->buffer.tail;
-	unsigned int slot = rreq->buffer.first_tail_slot;
+	struct bvecq *bvecq = rreq->collect_cursor.bvecq;
+	unsigned int slot = rreq->collect_cursor.slot;
 	uoff_t collected_to = rreq->collected_to;
 
 	if (rreq->cleaned_to >= rreq->collected_to)
@@ -138,15 +146,6 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 
 	// TODO: Begin decryption
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = rolling_buffer_delete_spent(&rreq->buffer);
-		if (!folioq) {
-			WRITE_ONCE(rreq->progress_at, ULONG_MAX);
-			return;
-		}
-		slot = 0;
-	}
-
 	/* We have to wait for readahead refs to have been released before we
 	 * can unlock any folios as the ref-dropper walks i_pages and the only
 	 * thing preventing these folios from being removed is the folio lock.
@@ -159,17 +158,30 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 		uoff_t fpos = rreq->cleaned_to, fend;
 		size_t fsize;
 
+		/* Clean up the head bvecq segment.  If we clear an entire
+		 * segment, then we can get rid of it provided it's not also
+		 * the tail segment being filled by the issuer.
+		 */
+		if (!bvecq_acquire_slot(bvecq, slot)) {
+			rreq->collect_cursor.slot = slot;
+			if (!bvecq_delete_spent(&rreq->collect_cursor)) {
+				WRITE_ONCE(rreq->progress_at, ULONG_MAX);
+				return;
+			}
+			bvecq = rreq->collect_cursor.bvecq;
+			slot  = rreq->collect_cursor.slot;
+		}
+
 		if (*notes & COPY_TO_CACHE)
 			set_bit(NETFS_RREQ_FOLIO_COPY_TO_CACHE, &rreq->flags);
 
-		folio = folioq_folio(folioq, slot);
+		folio = page_folio(bvecq->bv[slot].bv_page);
 		if (WARN_ONCE(!folio_test_locked(folio),
 			      "R=%08x: folio %lx is not locked\n",
 			      rreq->debug_id, folio->index))
 			trace_netfs_folio(folio, netfs_folio_trace_not_locked);
 
-		fsize = folioq_folio_size(folioq, slot);
-		fpos = folio_pos(folio);
+		fsize = bvecq->bv[slot].bv_len;
 		fend = fpos + fsize;
 
 		trace_netfs_collect_folio(rreq, folio);
@@ -178,34 +190,19 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 		if (collected_to < fend)
 			break;
 
-		netfs_unlock_read_folio(rreq, folioq, slot);
+		netfs_unlock_read_folio(rreq, bvecq, slot);
+		slot++;
 		WRITE_ONCE(rreq->cleaned_to, fend);
 		*notes |= MADE_PROGRESS;
 
 		clear_bit(NETFS_RREQ_FOLIO_COPY_TO_CACHE, &rreq->flags);
 
-		/* Clean up the head folioq.  If we clear an entire folioq, then
-		 * we can get rid of it provided it's not also the tail folioq
-		 * being filled by the issuer.
-		 */
-		folioq_clear(folioq, slot);
-		slot++;
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = rolling_buffer_delete_spent(&rreq->buffer);
-			if (!folioq)
-				goto done;
-			slot = 0;
-			trace_netfs_folioq(folioq, netfs_trace_folioq_read_progress);
-		}
-
 		if (fpos + fsize >= collected_to)
 			break;
 	}
 
-	rreq->buffer.tail = folioq;
-done:
-	rreq->buffer.first_tail_slot = slot;
-
+	bvecq_pos_move(&rreq->collect_cursor, bvecq);
+	rreq->collect_cursor.slot = slot;
 	netfs_read_set_unlock_at(rreq);
 }
 
@@ -383,12 +380,17 @@ static void netfs_rreq_assess_dio(struct netfs_io_request *rreq)
 
 	if (rreq->origin == NETFS_UNBUFFERED_READ ||
 	    rreq->origin == NETFS_DIO_READ) {
-		for (i = 0; i < rreq->direct_bv_count; i++) {
-			flush_dcache_page(rreq->direct_bv[i].bv_page);
-			// TODO: cifs marks pages in the destination buffer
-			// dirty under some circumstances after a read.  Do we
-			// need to do that too?
-			set_page_dirty(rreq->direct_bv[i].bv_page);
+		for (struct bvecq *bq = rreq->collect_cursor.bvecq; bq; bq = bvecq_next(bq)) {
+			unsigned int nr_slots = bvecq_nr_slots_acquire(bq);
+			/* Read the slot count before the slots. */
+
+			for (i = 0; i < nr_slots; i++) {
+				flush_dcache_page(bq->bv[i].bv_page);
+				// TODO: cifs marks pages in the destination buffer
+				// dirty under some circumstances after a read.  Do we
+				// need to do that too?
+				set_page_dirty(bq->bv[i].bv_page);
+			}
 		}
 	}
 
@@ -477,7 +479,15 @@ bool netfs_read_collection(struct netfs_io_request *rreq)
 
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
index aab156d00031..2e4eab1e327f 100644
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
-	if (rolling_buffer_append(&creq->buffer, folio, 0, creq->gfp) < 0) {
-		folio_end_private_2(folio);
-		clear_bit(NETFS_RREQ_FOLIO_COPY_TO_CACHE, &creq->flags);
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
@@ -139,6 +164,14 @@ void netfs_pgpriv2_copy_to_cache(struct netfs_io_request *rreq, struct folio *fo
 	if (IS_ERR(creq))
 		return;
 
+	if (!creq->spare) {
+		creq->spare = bvecq_alloc_one(BVECQ_STD_SLOTS, creq->gfp, false);
+		if (!creq->spare) {
+			clear_bit(NETFS_RREQ_FOLIO_COPY_TO_CACHE, &creq->flags);
+			return;
+		}
+	}
+
 	trace_netfs_folio(folio, netfs_folio_trace_copy_to_cache);
 	folio_start_private_2(folio);
 	netfs_pgpriv2_copy_folio(creq, folio);
@@ -170,22 +203,27 @@ void netfs_pgpriv2_end_copy_to_cache(struct netfs_io_request *rreq)
  */
 bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 {
-	struct folio_queue *folioq = creq->buffer.tail;
-	unsigned int slot = creq->buffer.first_tail_slot;
+	struct bvecq *bq = creq->collect_cursor.bvecq;
+	unsigned int slot;
 	uoff_t collected_to = creq->collected_to;
 	bool made_progress = false;
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = rolling_buffer_delete_spent(&creq->buffer);
-		slot = 0;
-	}
+	slot = creq->collect_cursor.slot;
 
 	for (;;) {
 		struct folio *folio;
 		uoff_t fpos, fend;
 		size_t fsize, flen;
 
-		folio = folioq_folio(folioq, slot);
+		if (!bvecq_acquire_slot(bq, slot)) {
+			creq->collect_cursor.slot = slot;
+			if (!bvecq_delete_spent(&creq->collect_cursor))
+				goto out;
+			bq   = creq->collect_cursor.bvecq;
+			slot = creq->collect_cursor.slot;
+		}
+
+		folio = page_folio(bq->bv[slot].bv_page);
 		if (WARN_ONCE(!folio_test_private_2(folio),
 			      "R=%08x: folio %lx is not marked private_2\n",
 			      creq->debug_id, folio->index))
@@ -208,25 +246,18 @@ bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 		creq->cleaned_to = fpos + fsize;
 		made_progress = true;
 
-		/* Clean up the head folioq.  If we clear an entire folioq, then
-		 * we can get rid of it provided it's not also the tail folioq
-		 * being filled by the issuer.
+		/* Clean up the head segment.  If we clear an entire segment,
+		 * then we can get rid of it provided it's not also the tail
+		 * segment being filled by the issuer.
 		 */
-		folioq_clear(folioq, slot);
+		bq->bv[slot].bv_page = NULL;
 		slot++;
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = rolling_buffer_delete_spent(&creq->buffer);
-			if (!folioq)
-				goto done;
-			slot = 0;
-		}
 
 		if (fpos + fsize >= collected_to)
 			break;
 	}
 
-	creq->buffer.tail = folioq;
-done:
-	creq->buffer.first_tail_slot = slot;
+	creq->collect_cursor.slot = slot;
+out:
 	return made_progress;
 }
diff --git a/fs/netfs/read_retry.c b/fs/netfs/read_retry.c
index 96223f62516a..733d9ff452c7 100644
--- a/fs/netfs/read_retry.c
+++ b/fs/netfs/read_retry.c
@@ -12,6 +12,12 @@
 static void netfs_reissue_read(struct netfs_io_request *rreq,
 			       struct netfs_io_subrequest *subreq)
 {
+	bvecq_pos_unset(&subreq->content);
+	bvecq_pos_set(&subreq->content, &subreq->dispatch_pos);
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->content.bvecq,
+			    subreq->content.slot, subreq->content.offset, subreq->len);
+	iov_iter_advance(&subreq->io_iter, subreq->transferred);
+
 	subreq->error = 0;
 	__clear_bit(NETFS_SREQ_MADE_PROGRESS, &subreq->flags);
 	__set_bit(NETFS_SREQ_IN_PROGRESS, &subreq->flags);
@@ -27,6 +33,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 {
 	struct netfs_io_subrequest *subreq;
 	struct netfs_io_stream *stream = &rreq->io_streams[0];
+	struct bvecq_pos dispatch_cursor = {};
 	struct list_head *next;
 
 	_enter("R=%x", rreq->debug_id);
@@ -46,9 +53,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 			if (test_bit(NETFS_SREQ_FAILED, &subreq->flags))
 				break;
 			if (__test_and_clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags)) {
-				__clear_bit(NETFS_SREQ_MADE_PROGRESS, &subreq->flags);
 				subreq->retry_count++;
-				netfs_reset_iter(subreq);
 				netfs_get_subrequest(subreq, netfs_sreq_trace_get_resubmit);
 				netfs_reissue_read(rreq, subreq);
 			}
@@ -74,11 +79,12 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 
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
@@ -105,7 +111,8 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 				break;
 
 			subreq = list_entry(next, struct netfs_io_subrequest, rreq_link);
-			if (subreq->start + subreq->transferred != start + len ||
+			if (subreq->start != start + len ||
+			    subreq->transferred > 0 ||
 			    test_bit(NETFS_SREQ_BOUNDARY, &subreq->flags) ||
 			    !test_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags))
 				break;
@@ -118,11 +125,14 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 		/* Determine the set of buffers we're going to use.  Each
 		 * subreq gets a subset of a single overall contiguous buffer.
 		 */
-		netfs_reset_iter(from);
-		source = from->io_iter;
-		source.count = len;
+		bvecq_pos_transfer(&dispatch_cursor, &from->dispatch_pos);
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
@@ -130,16 +140,22 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
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
+			bvecq_pos_unset(&subreq->content);
+			bvecq_pos_unset(&subreq->dispatch_pos);
+			bvecq_pos_set(&subreq->dispatch_pos, &dispatch_cursor);
 
 			trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
 
 			/* Renegotiate max_len (rsize) */
-			stream->sreq_max_len = subreq->len;
+			stream->sreq_max_len = len;
+			stream->sreq_max_segs = INT_MAX;
 			if (rreq->netfs_ops->prepare_read &&
 			    rreq->netfs_ops->prepare_read(subreq) < 0) {
 				trace_netfs_sreq(subreq, netfs_sreq_trace_reprep_failed);
@@ -147,13 +163,12 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
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
@@ -217,9 +232,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 			trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
 
 			stream->sreq_max_len	= umin(len, rreq->rsize);
-			stream->sreq_max_segs	= 0;
-			if (unlikely(stream->sreq_max_segs))
-				part = netfs_limit_iter(&source, 0, part, stream->sreq_max_segs);
+			stream->sreq_max_segs	= INT_MAX;
 
 			netfs_stat(&netfs_n_rh_download);
 			if (rreq->netfs_ops->prepare_read(subreq) < 0) {
@@ -228,11 +241,12 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 				goto abandon;
 			}
 
-			part = umin(len, stream->sreq_max_len);
-			subreq->len = subreq->transferred + part;
-			subreq->io_iter = source;
-			iov_iter_truncate(&subreq->io_iter, part);
-			iov_iter_advance(&source, part);
+			bvecq_pos_set(&subreq->dispatch_pos, &dispatch_cursor);
+			part = bvecq_slice(&dispatch_cursor,
+					   umin(len, stream->sreq_max_len),
+					   stream->sreq_max_segs,
+					   &subreq->nr_segs);
+			subreq->len = part;
 
 			len -= part;
 			start += part;
@@ -246,12 +260,14 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 
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
@@ -262,6 +278,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 		__set_bit(NETFS_SREQ_FAILED, &subreq->flags);
 		__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
 	}
+	goto out;
 }
 
 /*
@@ -292,7 +309,7 @@ void netfs_retry_reads(struct netfs_io_request *rreq)
  */
 void netfs_unlock_abandoned_read_pages(struct netfs_io_request *rreq)
 {
-	struct folio_queue *p;
+	struct bvecq *p;
 
 	/* We have to wait for readahead refs to have been released before we
 	 * can unlock any folios as the ref-dropper walks i_pages and the only
@@ -301,21 +318,22 @@ void netfs_unlock_abandoned_read_pages(struct netfs_io_request *rreq)
 	if (test_bit(NETFS_RREQ_NEED_PUT_RA_REFS, &rreq->flags))
 		netfs_wait_for_put_ra_refs(rreq);
 
-	for (p = rreq->buffer.tail; p; p = p->next) {
-		for (int slot = 0; slot < folioq_count(p); slot++) {
-			struct folio *folio = folioq_folio(p, slot);
-
-			if (folio && !folioq_is_marked2(p, slot)) {
-				if (folio == rreq->no_unlock_folio &&
-				    test_bit(NETFS_RREQ_NO_UNLOCK_FOLIO,
-					     &rreq->flags)) {
-					_debug("no unlock");
-				} else {
-					trace_netfs_folio(folio,
-						netfs_folio_trace_abandon);
-					folio_unlock(folio);
-				}
+	for (p = rreq->collect_cursor.bvecq; p; p = bvecq_next(p)) {
+		unsigned int nr_slots = bvecq_nr_slots_acquire(p);
+
+		for (int slot = 0; slot < nr_slots; slot++) {
+			if (!p->bv[slot].bv_page)
+				continue;
+
+			struct folio *folio = page_folio(p->bv[slot].bv_page);
+
+			if (folio == rreq->no_unlock_folio &&
+			    test_bit(NETFS_RREQ_NO_UNLOCK_FOLIO, &rreq->flags)) {
+				_debug("no unlock");
+				continue;
 			}
+			trace_netfs_folio(folio, netfs_folio_trace_abandon);
+			folio_unlock(folio);
 		}
 	}
 }
diff --git a/fs/netfs/read_single.c b/fs/netfs/read_single.c
index b370a8534324..9fd07dbb08b5 100644
--- a/fs/netfs/read_single.c
+++ b/fs/netfs/read_single.c
@@ -93,7 +93,12 @@ static int netfs_single_dispatch_read(struct netfs_io_request *rreq)
 	subreq->source	= NETFS_DOWNLOAD_FROM_SERVER;
 	subreq->start	= 0;
 	subreq->len	= rreq->len;
-	subreq->io_iter	= rreq->buffer.iter;
+
+	bvecq_pos_set(&subreq->dispatch_pos, &rreq->dispatch_cursor);
+	bvecq_pos_set(&subreq->content, &rreq->dispatch_cursor);
+
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_DEST, subreq->content.bvecq,
+			    subreq->content.slot, subreq->content.offset, subreq->len);
 
 	netfs_queue_read(rreq, subreq);
 
@@ -174,6 +179,15 @@ ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_ite
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
@@ -183,7 +197,6 @@ ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_ite
 	netfs_stat(&netfs_n_rh_read_single);
 	trace_netfs_read(rreq, 0, rreq->len, netfs_read_trace_read_single);
 
-	rreq->buffer.iter = *iter;
 	netfs_single_dispatch_read(rreq);
 
 	ret = netfs_wait_for_read(rreq);
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
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index 6e8ea534230d..b980a65441dc 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -114,12 +114,12 @@ int netfs_folio_written_back(struct folio *folio)
 static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 					  unsigned int *notes)
 {
-	struct folio_queue *folioq = wreq->buffer.tail;
-	unsigned int slot = wreq->buffer.first_tail_slot;
+	struct bvecq *bvecq = wreq->collect_cursor.bvecq;
+	unsigned int slot = wreq->collect_cursor.slot;
 	uoff_t collected_to = wreq->collected_to;
 
-	if (WARN_ON_ONCE(!folioq)) {
-		pr_err("[!] Writeback unlock found empty rolling buffer!\n");
+	if (WARN_ON_ONCE(!bvecq)) {
+		pr_err("[!] Writeback unlock found empty buffer!\n");
 		netfs_dump_request(wreq);
 		return;
 	}
@@ -130,20 +130,28 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		return;
 	}
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = rolling_buffer_delete_spent(&wreq->buffer);
-		if (!folioq)
-			return;
-		slot = 0;
-	}
-
 	for (;;) {
 		struct folio *folio;
 		struct netfs_folio *finfo;
 		uoff_t fpos, fend;
 		size_t fsize, flen;
 
-		folio = folioq_folio(folioq, slot);
+		/* Try to clean up the head of the queue if it appears to be
+		 * used up, but we need to be very careful - the cleanup can
+		 * catch the dispatcher, which could lead to us having nothing
+		 * left in the queue, causing the front and back pointers to
+		 * end up on different tracks.  To avoid this, we must always
+		 * keep at least one segment in the queue.
+		 */
+		if (!bvecq_acquire_slot(bvecq, slot)) {
+			wreq->collect_cursor.slot = slot;
+			if (!bvecq_delete_spent(&wreq->collect_cursor))
+				return;
+			bvecq = wreq->collect_cursor.bvecq;
+			slot  = wreq->collect_cursor.slot;
+		}
+
+		folio = page_folio(bvecq->bv[slot].bv_page);
 		if (WARN_ONCE(!folio_test_writeback(folio),
 			      "R=%08x: folio %lx is not under writeback\n",
 			      wreq->debug_id, folio->index))
@@ -166,26 +174,13 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		wreq->cleaned_to = fpos + fsize;
 		*notes |= MADE_PROGRESS;
 
-		/* Clean up the head folioq.  If we clear an entire folioq, then
-		 * we can get rid of it provided it's not also the tail folioq
-		 * being filled by the issuer.
-		 */
-		folioq_clear(folioq, slot);
+		bvecq->bv[slot].bv_page = NULL;
 		slot++;
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = rolling_buffer_delete_spent(&wreq->buffer);
-			if (!folioq)
-				goto done;
-			slot = 0;
-		}
-
 		if (fpos + fsize >= collected_to)
 			break;
 	}
 
-	wreq->buffer.tail = folioq;
-done:
-	wreq->buffer.first_tail_slot = slot;
+	wreq->collect_cursor.slot = slot;
 }
 
 /*
@@ -230,7 +225,8 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 	trace_netfs_rreq(wreq, netfs_rreq_trace_collect);
 
 reassess_streams:
-	issued_to = atomic64_read(&wreq->issued_to);
+	/* Order reading the issued_to point before reading the queue it refers to. */
+	issued_to = atomic64_read_acquire(&wreq->issued_to);
 	smp_rmb();
 	collected_to = ULLONG_MAX;
 	if (wreq->origin == NETFS_WRITEBACK ||
@@ -560,8 +556,12 @@ void netfs_write_subrequest_terminated(void *_op, ssize_t transferred_or_error)
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
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 638f0122315c..a5c5ba5deb43 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -107,8 +107,6 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 	ictx = netfs_inode(wreq->inode);
 	if (is_cacheable)
 		fscache_begin_write_operation(&wreq->cache_resources, netfs_i_cookie(ictx));
-	if (rolling_buffer_init(&wreq->buffer, wreq->debug_id, ITER_SOURCE, wreq->gfp) < 0)
-		goto nomem;
 
 	wreq->cleaned_to = wreq->start;
 	if (wreq->cache_resources.dio_size > 1)
@@ -133,9 +131,6 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 	}
 
 	return wreq;
-nomem:
-	netfs_put_failed_request(wreq);
-	return ERR_PTR(-ENOMEM);
 }
 
 /**
@@ -160,21 +155,13 @@ void netfs_prepare_write(struct netfs_io_request *wreq,
 			 uoff_t start)
 {
 	struct netfs_io_subrequest *subreq;
-	struct iov_iter *wreq_iter = &wreq->buffer.iter;
-
-	/* Make sure we don't point the iterator at a used-up folio_queue
-	 * struct being used as a placeholder to prevent the queue from
-	 * collapsing.  In such a case, extend the queue.
-	 */
-	if (iov_iter_is_folioq(wreq_iter) &&
-	    wreq_iter->folioq_slot >= folioq_nr_slots(wreq_iter->folioq))
-		rolling_buffer_make_space(&wreq->buffer, wreq->gfp);
 
 	subreq = netfs_alloc_subrequest(wreq);
 	subreq->source		= stream->source;
 	subreq->start		= start;
 	subreq->stream_nr	= stream->stream_nr;
-	subreq->io_iter		= *wreq_iter;
+
+	bvecq_pos_set(&subreq->dispatch_pos, &wreq->dispatch_cursor);
 
 	_enter("R=%x[%x]", wreq->debug_id, subreq->debug_index);
 
@@ -255,15 +242,16 @@ static void netfs_do_issue_write(struct netfs_io_stream *stream,
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
+	bvecq_pos_unset(&subreq->content);
+	bvecq_pos_set(&subreq->content, &subreq->dispatch_pos);
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_SOURCE,
+			    subreq->content.bvecq, subreq->content.slot,
+			    subreq->content.offset,
+			    subreq->len);
+	iov_iter_advance(&subreq->io_iter, subreq->transferred);
 
 	subreq->retry_count++;
 	subreq->error = 0;
@@ -281,8 +269,13 @@ void netfs_issue_write(struct netfs_io_request *wreq,
 	if (!subreq)
 		return;
 
+	bvecq_pos_set(&subreq->content, &subreq->dispatch_pos);
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_SOURCE,
+			    subreq->content.bvecq, subreq->content.slot,
+			    subreq->content.offset,
+			    subreq->len);
+
 	stream->construct = NULL;
-	subreq->io_iter.count = subreq->len;
 	netfs_do_issue_write(stream, subreq);
 }
 
@@ -319,7 +312,6 @@ size_t netfs_advance_write(struct netfs_io_request *wreq,
 	_debug("part %zx/%zx %zx/%zx", subreq->len, stream->sreq_max_len, part, len);
 	subreq->len += part;
 	subreq->nr_segs++;
-	stream->submit_extendable_to -= part;
 
 	if (subreq->len >= stream->sreq_max_len ||
 	    subreq->nr_segs >= stream->sreq_max_segs ||
@@ -343,7 +335,8 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	struct netfs_io_stream *stream;
 	struct netfs_group *fgroup; /* TODO: Use this with ceph */
 	struct netfs_folio *finfo;
-	size_t iter_off = 0;
+	struct bvecq *queue = wreq->load_cursor.bvecq;
+	unsigned int slot;
 	size_t fsize = folio_size(folio), flen = fsize, foff = 0;
 	uoff_t fpos = folio_pos(folio), i_size;
 	bool to_eof = false, streamw = false;
@@ -351,12 +344,20 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 
 	_enter("");
 
-	if (rolling_buffer_make_space(&wreq->buffer, wreq->gfp) < 0)
-		return -ENOMEM;
+	if (!wreq->spare) {
+		wreq->spare = bvecq_alloc_one(BVECQ_STD_SLOTS, wreq->gfp, true);
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
 
@@ -448,8 +449,29 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
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
-	rolling_buffer_append(&wreq->buffer, folio, 0, wreq->gfp);
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
@@ -458,10 +480,18 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	 * Also skip uploading for data that's been read and just needs copying
 	 * to the cache.
 	 */
+	bvecq_pos_nudge(&wreq->dispatch_cursor);
+	
 	for (int s = 0; s < NR_IO_STREAMS; s++) {
+		size_t soff = foff, slen = flen, alignment = 1;
+
+		if (stream->source == NETFS_WRITE_TO_CACHE)
+			alignment = wreq->cache_resources.dio_size;
 		stream = &wreq->io_streams[s];
-		stream->submit_off = foff;
-		stream->submit_len = flen;
+		stream->submit_off = round_down(soff, alignment);
+		slen += foff - stream->submit_off;
+		stream->submit_len = round_up(slen, alignment);
+
 		if (!stream->avail ||
 		    (stream->source == NETFS_WRITE_TO_CACHE && streamw) ||
 		    (stream->source == NETFS_UPLOAD_TO_SERVER &&
@@ -495,14 +525,10 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
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
@@ -514,9 +540,9 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
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
@@ -577,6 +603,11 @@ int netfs_writepages(struct address_space *mapping,
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
@@ -601,12 +632,17 @@ int netfs_writepages(struct address_space *mapping,
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
@@ -627,20 +663,24 @@ EXPORT_SYMBOL(netfs_writepages);
  * netfs_writeback_single - Write back a monolithic payload
  * @mapping: The mapping to write from
  * @wbc: Hints from the VM
- * @iter: Data to write.
+ * @iter: Buffer to write from
+ * @len: Amount to write from buffer
  *
- * Write a monolithic, non-pagecache object back to the server and/or
- * the cache.
+ * Write a monolithic, non-pagecache object back to the server and/or the
+ * cache.  There's a maximum of one subrequest per stream.  The buffer should
+ * be rounded out sufficiently that it can accommodate cache DIO rounding.
  *
  * Return: 0 if successful; 1 if skipped due to lock conflict and WB_SYNC_NONE;
  * or a negative error code.
+ * the cache.  There's a maximum of one subrequest per stream.
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
@@ -654,9 +694,27 @@ int netfs_writeback_single(struct address_space *mapping,
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
@@ -676,12 +734,14 @@ int netfs_writeback_single(struct address_space *mapping,
 
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
 
@@ -689,11 +749,15 @@ int netfs_writeback_single(struct address_space *mapping,
 	 * wait before modifying.
 	 */
 	ret = netfs_wait_for_write(wreq);
+	if (ret > 0)
+		ret = 0;
 
 	netfs_put_request(wreq, netfs_rreq_trace_put_return);
 	_leave(" = %d", ret);
 	return ret;
 
+cleanup_free:
+	netfs_put_failed_request(wreq);
 couldnt_start:
 	netfs_wb_end(ictx);
 	_leave(" = %d", ret);
diff --git a/fs/netfs/write_retry.c b/fs/netfs/write_retry.c
index 747d57467b4f..c61bed687244 100644
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
+		return; /* Shouldn't be retrying cache writes. */
 
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
@@ -54,11 +52,12 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 
 	do {
 		struct netfs_io_subrequest *subreq = NULL, *from, *to, *tmp;
-		struct iov_iter source;
 		uoff_t start, len;
 		size_t part;
 		bool boundary = false;
 
+		bvecq_pos_unset(&dispatch_cursor);
+
 		/* Go through the stream and find the next span of contiguous
 		 * data that we then rejig (cifs, for example, needs the wsize
 		 * renegotiating) and reissue.
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
@@ -90,11 +90,13 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 		/* Determine the set of buffers we're going to use.  Each
 		 * subreq gets a subset of a single overall contiguous buffer.
 		 */
-		netfs_reset_iter(from);
-		source = from->io_iter;
-		source.count = len;
+		bvecq_pos_transfer(&dispatch_cursor, &from->dispatch_pos);
+		bvecq_pos_advance(&dispatch_cursor, from->transferred);
 
-		/* Work through the sublist. */
+		/* Work through the sublist.  The chain of buffers we're going
+		 * to fill is attached to dispatch_cursor and we need to read
+		 * 'len' amount of data from 'start'.
+		 */
 		subreq = from;
 		list_for_each_entry_from(subreq, &stream->subrequests, rreq_link) {
 			if (!len)
@@ -104,16 +106,23 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 			subreq->len	= len;
 			__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
 			trace_netfs_sreq(subreq, netfs_sreq_trace_retry);
+			subreq->transferred = 0;
+
+			bvecq_pos_unset(&subreq->content);
+			bvecq_pos_unset(&subreq->dispatch_pos);
 
 			/* Renegotiate max_len (wsize) */
 			stream->sreq_max_len = len;
+			stream->sreq_max_segs = INT_MAX;
 			stream->prepare_write(subreq);
 
-			part = umin(len, stream->sreq_max_len);
-			if (unlikely(stream->sreq_max_segs))
-				part = netfs_limit_iter(&source, 0, part, stream->sreq_max_segs);
+			bvecq_pos_set(&subreq->dispatch_pos, &dispatch_cursor);
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
@@ -121,7 +130,7 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 				boundary = true;
 
 			netfs_get_subrequest(subreq, netfs_sreq_trace_get_resubmit);
-			netfs_reissue_write(stream, subreq, &source);
+			netfs_reissue_write(stream, subreq);
 			if (subreq == to)
 				break;
 		}
@@ -173,17 +182,19 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
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
+			bvecq_pos_set(&subreq->dispatch_pos, &dispatch_cursor);
+			part = bvecq_slice(&dispatch_cursor,
+					   umin(len, stream->sreq_max_len),
+					   stream->sreq_max_segs,
+					   &subreq->nr_segs);
 			subreq->len = subreq->transferred + part;
+
 			len -= part;
 			start += part;
 			if (!len && boundary) {
@@ -191,13 +202,16 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
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
index ef1068a274a8..a58d2b6914ea 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -19,12 +19,13 @@
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
-struct folio_queue;
 
 /**
  * folio_start_private_2 - Start an fscache write on a folio.  [DEPRECATED]
@@ -145,7 +146,6 @@ struct netfs_io_stream {
 	unsigned int		sreq_max_segs;	/* 0 or max number of segments in an iterator */
 	unsigned int		submit_off;	/* Folio offset we're submitting from */
 	unsigned int		submit_len;	/* Amount of data left to submit */
-	unsigned int		submit_extendable_to; /* Amount I/O can be rounded up to */
 	void (*prepare_write)(struct netfs_io_subrequest *subreq);
 	void (*issue_write)(struct netfs_io_subrequest *subreq);
 	/* Collection tracking */
@@ -188,6 +188,8 @@ struct netfs_io_subrequest {
 	struct netfs_io_request *rreq;		/* Supervising I/O request */
 	struct work_struct	work;
 	struct list_head	rreq_link;	/* Link in rreq->subrequests */
+	struct bvecq_pos	dispatch_pos;	/* Bookmark in the combined queue of the start */
+	struct bvecq_pos	content;	/* The (copied) content of the subrequest */
 	struct iov_iter		io_iter;	/* Iterator for this subrequest */
 	uoff_t			start;		/* Where to start the I/O */
 	size_t			len;		/* Size of the I/O */
@@ -248,13 +250,14 @@ struct netfs_io_request {
 	struct netfs_io_stream	io_streams[2];	/* Streams of parallel I/O operations */
 #define NR_IO_STREAMS 2 //wreq->nr_io_streams
 	struct netfs_group	*group;		/* Writeback group being written back */
-	struct rolling_buffer	buffer;		/* Unencrypted buffer */
-#define NETFS_ROLLBUF_PUT_MARK		ROLLBUF_MARK_1
-#define NETFS_ROLLBUF_PAGECACHE_MARK	ROLLBUF_MARK_2
+	struct bvecq		*spare;		/* Advance allocation of bvecq */
+	struct bvecq_pos	load_cursor;	/* Point at which new folios are loaded in */
+	struct bvecq_pos	dispatch_cursor; /* Point from which buffers are dispatched */
+	struct bvecq_pos	collect_cursor;	/* Clear-up point of I/O buffer */
 	wait_queue_head_t	waitq;		/* Processor waiter */
 	void			*netfs_priv;	/* Private data for the netfs */
 	void			*netfs_priv2;	/* Private data for the netfs */
-	struct bio_vec		*direct_bv;	/* DIO buffer list (when handling iovec-iter) */
+	uoff_t			last_end;	/* End pos of last folio submitted */
 	uoff_t			submitted;	/* Amount submitted for I/O so far */
 	uoff_t			len;		/* Length of the request */
 	size_t			transferred;	/* Amount to be indicated as transferred */
@@ -269,7 +272,6 @@ struct netfs_io_request {
 	uoff_t			abandon_to;	/* Position to abandon folios to */
 	const struct folio	*no_unlock_folio; /* Don't unlock this folio after read */
 	gfp_t			gfp;		/* GFP flags to use */
-	unsigned int		direct_bv_count; /* Number of elements in direct_bv[] */
 	unsigned int		debug_id;
 	unsigned int		rsize;		/* Maximum read size (0 for none) */
 	unsigned int		wsize;		/* Maximum write size (0 for none) */
@@ -277,7 +279,6 @@ struct netfs_io_request {
 	unsigned int		nr_group_rel;	/* Number of refs to release on ->group */
 	spinlock_t		lock;		/* Lock for queuing subreqs */
 	enum netfs_io_origin	origin;		/* Origin of the request */
-	bool			direct_bv_unpin; /* T if direct_bv[] must be unpinned */
 	refcount_t		ref;
 	unsigned long		flags;
 #define NETFS_RREQ_IN_PROGRESS		0	/* Unlocked when the request completes (has ref) */
@@ -428,7 +429,7 @@ void netfs_single_mark_inode_dirty(struct inode *inode);
 ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_iter *iter);
 int netfs_writeback_single(struct address_space *mapping,
 			   struct writeback_control *wbc,
-			   struct iov_iter *iter);
+			   struct iov_iter *iter, size_t len);
 
 /* Address operations API */
 struct readahead_control;
@@ -473,12 +474,6 @@ void netfs_end_io_write(struct inode *inode);
 int netfs_start_io_direct(struct inode *inode);
 void netfs_end_io_direct(struct inode *inode);
 
-/* Miscellaneous APIs. */
-struct folio_queue *netfs_folioq_alloc(unsigned int rreq_id, gfp_t gfp,
-				       unsigned int trace /*enum netfs_folioq_trace*/);
-void netfs_folioq_free(struct folio_queue *folioq,
-		       unsigned int trace /*enum netfs_trace_folioq*/);
-
 /* Buffer wrangling helpers API. */
 int netfs_alloc_folioq_buffer(struct address_space *mapping,
 			      struct folio_queue **_buffer,
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index 927287a7290c..4b2ffd14a1ca 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -227,7 +227,9 @@
 	EM(netfs_folio_trace_redirtied,		"redirtied")	\
 	EM(netfs_folio_trace_store,		"store")	\
 	EM(netfs_folio_trace_store_copy,	"store-copy")	\
-	E_(netfs_folio_trace_store_plus,	"store+")
+	EM(netfs_folio_trace_store_plus,	"store+")	\
+	EM(netfs_folio_trace_zero,		"zero")		\
+	E_(netfs_folio_trace_zero_ra,		"zero-ra")
 
 #define netfs_collect_contig_traces				\
 	EM(netfs_contig_trace_collect,		"Collect")	\
@@ -240,13 +242,13 @@
 	EM(netfs_trace_donate_to_next,		"to-next")	\
 	E_(netfs_trace_donate_to_deferred_next,	"defer-next")
 
-#define netfs_folioq_traces					\
-	EM(netfs_trace_folioq_alloc_buffer,	"alloc-buf")	\
-	EM(netfs_trace_folioq_clear,		"clear")	\
-	EM(netfs_trace_folioq_delete,		"delete")	\
-	EM(netfs_trace_folioq_make_space,	"make-space")	\
-	EM(netfs_trace_folioq_rollbuf_init,	"roll-init")	\
-	E_(netfs_trace_folioq_read_progress,	"r-progress")
+#define netfs_bvecq_traces					\
+	EM(netfs_trace_bvecq_alloc_buffer,	"alloc-buf")	\
+	EM(netfs_trace_bvecq_clear,		"clear")	\
+	EM(netfs_trace_bvecq_delete,		"delete")	\
+	EM(netfs_trace_bvecq_make_space,	"make-space")	\
+	EM(netfs_trace_bvecq_rollbuf_init,	"roll-init")	\
+	E_(netfs_trace_bvecq_read_progress,	"r-progress")
 
 #ifndef __NETFS_DECLARE_TRACE_ENUMS_ONCE_ONLY
 #define __NETFS_DECLARE_TRACE_ENUMS_ONCE_ONLY
@@ -266,7 +268,7 @@ enum netfs_sreq_ref_trace { netfs_sreq_ref_traces } __mode(byte);
 enum netfs_folio_trace { netfs_folio_traces } __mode(byte);
 enum netfs_collect_contig_trace { netfs_collect_contig_traces } __mode(byte);
 enum netfs_donate_trace { netfs_donate_traces } __mode(byte);
-enum netfs_folioq_trace { netfs_folioq_traces } __mode(byte);
+enum netfs_bvecq_trace { netfs_bvecq_traces } __mode(byte);
 
 #endif
 
@@ -290,7 +292,7 @@ netfs_sreq_ref_traces;
 netfs_folio_traces;
 netfs_collect_contig_traces;
 netfs_donate_traces;
-netfs_folioq_traces;
+netfs_bvecq_traces;
 
 /*
  * Now redefine the EM() and E_() macros to map the enums to the strings that
@@ -394,10 +396,10 @@ TRACE_EVENT(netfs_sreq,
 		    __entry->len	= sreq->len;
 		    __entry->transferred = sreq->transferred;
 		    __entry->start	= sreq->start;
-		    __entry->slot	= sreq->io_iter.folioq_slot;
+		    __entry->slot	= sreq->content.slot;
 			   ),
 
-	    TP_printk("R=%08x[%x] %s %s f=%03x s=%llx %zx/%zx s=%u e=%d",
+	    TP_printk("R=%08x[%x] %s %s f=%03x s=%llx %zx/%zx bv=%u e=%d",
 		      __entry->rreq, __entry->index,
 		      __print_symbolic(__entry->source, netfs_sreq_sources),
 		      __print_symbolic(__entry->what, netfs_sreq_traces),
@@ -769,27 +771,25 @@ TRACE_EVENT(netfs_collect_stream,
 		      __entry->collected_to, __entry->issued_to)
 	    );
 
-TRACE_EVENT(netfs_folioq,
-	    TP_PROTO(const struct folio_queue *fq,
-		     enum netfs_folioq_trace trace),
+TRACE_EVENT(netfs_bvecq,
+	    TP_PROTO(const struct bvecq *bq,
+		     enum netfs_bvecq_trace trace),
 
-	    TP_ARGS(fq, trace),
+	    TP_ARGS(bq, trace),
 
 	    TP_STRUCT__entry(
-		    __field(unsigned int,		rreq)
 		    __field(unsigned int,		id)
-		    __field(enum netfs_folioq_trace,	trace)
+		    __field(enum netfs_bvecq_trace,	trace)
 			     ),
 
 	    TP_fast_assign(
-		    __entry->rreq	= fq ? fq->rreq_id : 0;
-		    __entry->id		= fq ? fq->debug_id : 0;
+		    __entry->id		= bq ? bq->priv : 0;
 		    __entry->trace	= trace;
 			   ),
 
-	    TP_printk("R=%08x fq=%x %s",
-		      __entry->rreq, __entry->id,
-		      __print_symbolic(__entry->trace, netfs_folioq_traces))
+	    TP_printk("bq=%x %s",
+		      __entry->id,
+		      __print_symbolic(__entry->trace, netfs_bvecq_traces))
 	    );
 
 TRACE_EVENT(netfs_read_progress_at,

