Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B71344AFE36
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:38:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370710; cv=none; b=bw/NnUYqd/0F38GHIi1fy+UxK6VHzRaS5p4GzXt/ZsGrcYJZ+fFnghQ5eaG0TZ5RubszoGnEqVyQgGTCur9Jix2Xz2gXJBtIf2r+KnwPSklwa6cLgDzAlSDT3B0ZCfsLEiZh8+ktl+wIS8gTqqhed/Mf18A4yO2s5OqQSchSr+Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370710; c=relaxed/simple;
	bh=JbGxXBjXzI9mugHu6pPWkYpoeu/0OmaITEGCsgyU2Xo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VKEvUuTb33XfxH0f3hzZ/FTTpNChyicNozfp9RlEafjG1AQQHySpqoiID+ZL1RI2ffJ2T4dAsmAcnw13NdYQWxENXZOBLHFVQxVvPuSmbPr50s+GX0cDolZGNX4VAwYza5Y6Xw5bg8wMGPnrWT2SeA4dT0iOF6311yYsYRzq6tA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=DZa8YeL/; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="DZa8YeL/"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370705;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Mgk4bKBB6wLNBkX+d/5oaCnTWUKHaLL1TuELDn07WVE=;
	b=DZa8YeL/y9fx21THM2AvIKShCeaYR1IcTZjCR7gKlLqfhtylY9z4zD0TpEH2hkaKk7Xtrb
	W1Zma3l6Frt0vdsktEXyKGwIgfM5wyrSaYgmISbmbj6hYIqiTThEQW1vlVcdwBe44fQpcw
	lzLnphzZynIH7iOZNikXD7cKVS8VEn8=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-156-8SNMLGSdMjSPGTxyDjUkCQ-1; Wed,
 02 Sep 2026 13:38:23 -0400
X-MC-Unique: 8SNMLGSdMjSPGTxyDjUkCQ-1
X-Mimecast-MFC-AGG-ID: 8SNMLGSdMjSPGTxyDjUkCQ_1788370699
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 2F4C6195398D;
	Wed,  2 Sep 2026 17:38:19 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D123F18005BA;
	Wed,  2 Sep 2026 17:38:12 +0000 (UTC)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH v11 32/36] netfs: Rework writeback to estimate
Date: Wed,  2 Sep 2026 18:33:44 +0100
Message-ID: <20260902173350.3468672-33-dhowells@redhat.com>
In-Reply-To: <20260902173350.3468672-1-dhowells@redhat.com>
References: <20260902173350.3468672-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

The current netfslib writeback algorithm goes through every folio,
preparing a subrequest for each stream when it has been determined that
part of the current folio needs to go to that stream, and repeating this
within and across contiguous folios; then issues subrequests as they become
full or hit boundaries after first setting up the buffer.

However, the way this is implemented becomes a problem when content
encryption is added as we may not have enough memory to encrypt a large
folio to a bounce buffer in one go, but have to use a bunch of smaller
bounce buffers and wait for them to become available again.

Fix this by changing how netfs writeback builds buffers and creates and
dispatches subrequests.  With this patch, it now accumulates buffers and
attaches them to each stream when they become valid for that stream, then
flushes the stream when a limit or a boundary is hit.

The issuing code in netfs then loops around creating and issuing
subrequests without calling a separate prepare stage up to an estimate
supplied by the filesystem.  The filesystem (or cache) then gets to take a
slice of the master bvecq chain as its I/O buffer for each subrequest.

This will make it easier to feed small bounce buffers into the list and
pull the flush if we hit ENOMEM.  This will be dealt with in a later patch
series.

Also, as ->estimate_write is now being used to work out how much bufferage
can be accumulated before a flush is required, the { ->prepare_write(),
buffer selection, ->issue_write() } combination are now moved into one
place, preparatory to combining those in the filesystem in a subsequent
patch.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/buffered_read.c     |   1 +
 fs/netfs/internal.h          |   2 +
 fs/netfs/objects.c           |   5 +
 fs/netfs/read_pgpriv2.c      |   4 +-
 fs/netfs/write_collect.c     |  49 ++-
 fs/netfs/write_issue.c       | 626 +++++++++++++++++++++++++----------
 include/linux/netfs.h        |  17 +-
 include/trace/events/netfs.h |   9 +-
 8 files changed, 513 insertions(+), 200 deletions(-)

diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index b203f15a1f83..94bf9a2c2321 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -531,6 +531,7 @@ static int netfs_create_singular_buffer(struct netfs_io_request *rreq, struct fo
 	bvecq_filled_to(bq, 1);
 	rreq->submitted = rreq->start + fsize;
 	rreq->progress_at = fsize;
+	bvecq_pos_set(&rreq->collect_cursor, &rreq->load_cursor);
 	return 0;
 }
 
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index b62c5b7e43d9..bdf0f1ddcfec 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -233,6 +233,8 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 						struct file *file,
 						uoff_t start,
 						enum netfs_io_origin origin);
+struct netfs_io_subrequest *netfs_alloc_write_subreq(struct netfs_io_request *wreq,
+						     struct netfs_io_stream *stream);
 void netfs_prepare_write(struct netfs_io_request *wreq,
 			 struct netfs_io_stream *stream,
 			 uoff_t start);
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 763be168d6b1..6852fa27eeb3 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -66,6 +66,8 @@ struct netfs_io_request *netfs_alloc_request(struct address_space *mapping,
 
 		INIT_LIST_HEAD(&stream->subrequests);
 		stream->collected_to = rreq->start;
+		stream->issue_from = rreq->start;
+		stream->alignment = 1;
 	}
 
 	if (origin == NETFS_READAHEAD ||
@@ -159,6 +161,9 @@ static void netfs_deinit_request(struct netfs_io_request *rreq)
 		
 	}
 
+	for (int i = 0; i < NR_IO_STREAMS; i++)
+		bvecq_pos_unset(&rreq->io_streams[i].dispatch_cursor);
+
 	if (atomic_dec_and_test(&ictx->io_count))
 		wake_up_var(&ictx->io_count);
 }
diff --git a/fs/netfs/read_pgpriv2.c b/fs/netfs/read_pgpriv2.c
index 891dd0cb12ec..6a81a394eeac 100644
--- a/fs/netfs/read_pgpriv2.c
+++ b/fs/netfs/read_pgpriv2.c
@@ -95,7 +95,7 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 
 		creq->dispatch_cursor.offset = cache->submit_off;
 
-		atomic64_set(&creq->issued_to, fpos + cache->submit_off);
+		atomic64_set(&cache->issued_to, fpos + cache->submit_off);
 		part = netfs_advance_write(creq, cache, fpos + cache->submit_off,
 					   cache->submit_len, to_eof);
 		cache->submit_off += part;
@@ -106,7 +106,7 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 	} while (cache->submit_len > 0);
 
 	bvecq_pos_step(&creq->dispatch_cursor);
-	atomic64_set(&creq->issued_to, fpos + fsize);
+	atomic64_set(&cache->issued_to, fpos + fsize);
 
 	if (flen < fsize)
 		netfs_issue_write(creq, cache);
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index 2510d3dd2d58..b8caf15b2a8c 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -28,8 +28,8 @@ static void netfs_dump_request(const struct netfs_io_request *rreq)
 	       rreq->origin, rreq->error);
 	pr_err("  st=%llx tsl=%zx/%llx/%llx\n",
 	       rreq->start, rreq->transferred, rreq->submitted, rreq->len);
-	pr_err("  cci=%llx/%llx/%llx\n",
-	       rreq->cleaned_to, rreq->collected_to, atomic64_read(&rreq->issued_to));
+	pr_err("  cci=%llx/%llx\n",
+	       rreq->cleaned_to, rreq->collected_to);
 	pr_err("  iw=%pSR\n", rreq->netfs_ops->issue_write);
 	for (int i = 0; i < NR_IO_STREAMS; i++) {
 		const struct netfs_io_subrequest *sreq;
@@ -38,8 +38,9 @@ static void netfs_dump_request(const struct netfs_io_request *rreq)
 		pr_err("  str[%x] s=%x e=%d acnf=%u,%u,%u,%u\n",
 		       s->stream_nr, s->source, s->error,
 		       s->avail, s->active, s->need_retry, s->failed);
-		pr_err("  str[%x] ct=%llx t=%zx\n",
-		       s->stream_nr, s->collected_to, s->transferred);
+		pr_err("  str[%x] it=%llx ct=%llx t=%zx\n",
+		       s->stream_nr, atomic64_read(&s->issued_to),
+		       s->collected_to, s->transferred);
 		list_for_each_entry(sreq, &s->subrequests, rreq_link) {
 			pr_err("  sreq[%x:%x] sc=%u s=%llx t=%zx/%zx r=%d f=%lx\n",
 			       sreq->stream_nr, sreq->debug_index, sreq->source,
@@ -232,9 +233,7 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 	trace_netfs_rreq(wreq, netfs_rreq_trace_collect);
 
 reassess_streams:
-	/* Order reading the issued_to point before reading the queue it refers to. */
-	issued_to = atomic64_read_acquire(&wreq->issued_to);
-	smp_rmb();
+	issued_to = ULLONG_MAX;
 	collected_to = ULLONG_MAX;
 	if (wreq->origin == NETFS_WRITEBACK ||
 	    wreq->origin == NETFS_PGPRIV2_COPY_TO_CACHE)
@@ -248,19 +247,34 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 	 * to the tail whilst we're doing this.
 	 */
 	for (s = 0; s < NR_IO_STREAMS; s++) {
+		uoff_t s_issued_to;
+
 		stream = &wreq->io_streams[s];
-		/* Read active flag before list pointers */
+		/* Read active flag before issued_to */
 		if (!smp_load_acquire(&stream->active))
 			continue;
 
-		front = list_first_entry_or_null_acquire(&stream->subrequests,
-							 struct netfs_io_subrequest, rreq_link);
-		/* Read first subreq pointer before IN_PROGRESS flag. */
-
-		while (front) {
+		for (;;) {
 			enum netfs_cache_collect cache_collect;
 
-			trace_netfs_collect_sreq(wreq, front);
+			/* Order reading the issued_to point before reading the
+			 * queue it refers to.
+			 */
+			s_issued_to = atomic64_read_acquire(&stream->issued_to);
+			if (s_issued_to < issued_to)
+				issued_to = s_issued_to;
+
+			front = list_first_entry_or_null_acquire(&stream->subrequests,
+								 struct netfs_io_subrequest,
+								 rreq_link);
+			/* Read first subreq pointer before IN_PROGRESS flag. */
+			if (!front) {
+				if (stream->source == NETFS_UPLOAD_TO_SERVER &&
+				    test_bit(NETFS_RREQ_PAUSE, &wreq->flags))
+					notes |= MADE_PROGRESS;
+				break;
+			}
+
 			//_debug("sreq [%x] %llx %zx/%zx",
 			//       front->debug_index, front->start, front->transferred, front->len);
 
@@ -279,13 +293,17 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 				break;
 			}
 
+			trace_netfs_collect_sreq(wreq, front);
+
 			if (stream->failed) {
-				stream->collected_to = front->start + front->len;
+				stream->collected_to = front->start + front->len + front->post_gap;
 				notes |= MADE_PROGRESS | SAW_FAILURE;
 				goto cancel;
 			}
 			if (front->start + front->transferred > stream->collected_to) {
 				stream->collected_to = front->start + front->transferred;
+				if (front->transferred == front->len)
+					stream->collected_to += front->post_gap;
 				stream->transferred = stream->collected_to - wreq->start;
 				stream->transferred_valid = true;
 				notes |= MADE_PROGRESS;
@@ -335,6 +353,7 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 
 		cancel:
 			/* Remove if completely consumed. */
+			stream->collected_to = front->start + front->len + front->post_gap;
 			spin_lock(&wreq->lock);
 
 			remove = front;
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 061d41284deb..a12846a66a3c 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -36,6 +36,38 @@
 #include <linux/pagemap.h>
 #include "internal.h"
 
+#define NOTE_UPLOAD_AVAIL	0x001	/* Upload is available */
+#define NOTE_CACHE_AVAIL	0x002	/* Local cache is available */
+#define NOTE_CACHE_COPY		0x004	/* Copy folio to cache */
+#define NOTE_UPLOAD		0x008	/* Upload folio to server */
+#define NOTE_UPLOAD_STARTED	0x010	/* Upload started */
+#define NOTE_STREAMW		0x020	/* Folio is from a streaming write */
+#define NOTE_FLUSH_ANYWAY	0x040	/* Flush data, even if not hit estimated limit */
+
+#define NOTES__KEEP_MASK (NOTE_UPLOAD_AVAIL | NOTE_CACHE_AVAIL | NOTE_UPLOAD_STARTED)
+
+struct netfs_wb_params {
+	uoff_t			fpos;
+	unsigned int		notes;		/* Notes on applicability */
+
+	/* When we're using a bounce buffer, the outer data window is all of
+	 * the data we encrypted, rounded out to the largest alignment; the
+	 * inner data window is all the data that got changed, rounded out to
+	 * the smallest alignment.
+	 *
+	 * We have two alignments at play: the size of chunk which we encrypt
+	 * in one go (typically 4KiB) and the local cache DIO size.
+	 */
+	unsigned int		inner_align;	/* Smallest alignment */
+	unsigned int		inner_off;	/* Start of inner data window */
+	unsigned int		inner_end;	/* End of inner data window */
+	unsigned int		outer_align;	/* Largest alignment */
+	unsigned int		outer_off;	/* Start of outer data window */
+	unsigned int		outer_end;	/* End of outer data window */
+
+	struct netfs_write_estimate estimates[NR_IO_STREAMS];
+};
+
 /*
  * Kill all dirty folios in the event of an unrecoverable error, starting with
  * a locked folio we've already obtained from writeback_iter().
@@ -114,6 +146,7 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 
 	wreq->io_streams[0].stream_nr		= 0;
 	wreq->io_streams[0].source		= NETFS_UPLOAD_TO_SERVER;
+	wreq->io_streams[0].applicable		= NOTE_UPLOAD;
 	wreq->io_streams[0].estimate_write	= ictx->ops->estimate_write;
 	wreq->io_streams[0].prepare_write	= ictx->ops->prepare_write;
 	wreq->io_streams[0].issue_write		= ictx->ops->issue_write;
@@ -122,6 +155,7 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 
 	wreq->io_streams[1].stream_nr		= 1;
 	wreq->io_streams[1].source		= NETFS_WRITE_TO_CACHE;
+	wreq->io_streams[1].applicable		= NOTE_CACHE_COPY;
 	wreq->io_streams[1].collected_to	= start;
 	wreq->io_streams[1].transferred		= 0;
 	if (fscache_resources_valid(&wreq->cache_resources)) {
@@ -130,6 +164,7 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 		wreq->io_streams[1].estimate_write = wreq->cache_resources.ops->estimate_write;
 		wreq->io_streams[1].prepare_write = wreq->cache_resources.ops->prepare_write_subreq;
 		wreq->io_streams[1].issue_write = wreq->cache_resources.ops->issue_write;
+		wreq->io_streams[1].alignment	= wreq->cache_resources.dio_size;
 	}
 
 	return wreq;
@@ -148,6 +183,58 @@ void netfs_prepare_write_failed(struct netfs_io_subrequest *subreq)
 }
 EXPORT_SYMBOL(netfs_prepare_write_failed);
 
+/*
+ * Allocate and prepare a write subrequest.  Will only return NULL if not
+ * performing writeback; if performing writeback, mempools may be accessed and
+ * the allocator may wait forever.
+ */
+struct netfs_io_subrequest *netfs_alloc_write_subreq(struct netfs_io_request *wreq,
+						     struct netfs_io_stream *stream)
+{
+	struct netfs_io_subrequest *subreq;
+
+	subreq = netfs_alloc_subrequest(wreq);
+	if (!subreq)
+		return subreq;
+
+	subreq->source		= stream->source;
+	subreq->start		= stream->issue_from;
+	subreq->len		= stream->buffered;
+	subreq->stream_nr	= stream->stream_nr;
+
+	_enter("R=%x[%x]", wreq->debug_id, subreq->debug_index);
+
+	trace_netfs_sreq(subreq, netfs_sreq_trace_prepare);
+
+	switch (stream->source) {
+	case NETFS_UPLOAD_TO_SERVER:
+		netfs_stat(&netfs_n_wh_upload);
+		break;
+	case NETFS_WRITE_TO_CACHE:
+		netfs_stat(&netfs_n_wh_write);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+
+	__set_bit(NETFS_SREQ_IN_PROGRESS, &subreq->flags);
+
+	/* We add to the end of the list whilst the collector may be walking
+	 * the list.  The collector only goes nextwards and uses the lock to
+	 * remove entries off of the front.
+	 */
+	spin_lock(&wreq->lock);
+	/* Write IN_PROGRESS before pointer to new subreq */
+	list_add_tail_release(&subreq->rreq_link, &stream->subrequests);
+	if (list_is_first(&subreq->rreq_link, &stream->subrequests) &&
+	    stream->collected_to == 0)
+		stream->collected_to = subreq->start;
+
+	spin_unlock(&wreq->lock);
+	return subreq;
+}
+
 /*
  * Prepare a write subrequest.  We need to allocate a new subrequest
  * if we don't have one.
@@ -211,6 +298,51 @@ void netfs_prepare_write(struct netfs_io_request *wreq,
 	stream->construct = subreq;
 }
 
+/*
+ * Advance the state of the amount of data buffered on a stream.
+ */
+static void netfs_advance_stream(struct netfs_io_request *wreq,
+				 struct netfs_io_stream *stream,
+				 struct netfs_io_subrequest *subreq)
+{
+	stream->issue_from += subreq->len;
+	stream->buffered   -= subreq->len;
+	if (stream->buffered == 0) {
+		subreq->post_gap = stream->post_gap;
+		stream->post_gap = 0;
+		stream->buffering = false;
+		bvecq_pos_unset(&stream->dispatch_cursor);
+	}
+	/* Order loading the queue before updating the issue_to point */
+	atomic64_set_release(&stream->issued_to, stream->issue_from);
+}
+
+/*
+ * Prepare the buffer for a buffered write.
+ */
+static int netfs_prepare_buffered_write_buffer(struct netfs_io_subrequest *subreq,
+					       unsigned int max_segs)
+{
+	struct netfs_io_request *wreq = subreq->rreq;
+	struct netfs_io_stream *stream = &wreq->io_streams[subreq->stream_nr];
+	ssize_t len;
+
+	_enter("%zx,{,%u,%u},%u",
+	       subreq->len, stream->dispatch_cursor.slot, stream->dispatch_cursor.offset, max_segs);
+
+	bvecq_pos_set(&subreq->dispatch_pos, &stream->dispatch_cursor);
+	bvecq_pos_set(&subreq->content, &stream->dispatch_cursor);
+
+	len = bvecq_slice(&stream->dispatch_cursor, subreq->len, max_segs, &subreq->nr_segs);
+	if (len < subreq->len) {
+		subreq->len = len;
+		trace_netfs_sreq(subreq, netfs_sreq_trace_limited);
+	}
+
+	netfs_advance_stream(wreq, stream, subreq);
+	return 0;
+}
+
 /*
  * Set the I/O iterator for the filesystem/cache to use and dispatch the I/O
  * operation.  The operation may be asynchronous and should call
@@ -328,32 +460,242 @@ size_t netfs_advance_write(struct netfs_io_request *wreq,
 }
 
 /*
- * Write some of a pending folio data back to the server.
+ * Prepare and issue a subrequest.
+ * TODO: Replace with combined ->prepare/->issue call().
+ */
+static int netfs_prep_and_issue_subreq(struct netfs_io_request *wreq,
+				       struct netfs_io_stream *stream,
+				       struct netfs_io_subrequest *subreq)
+{
+	stream->sreq_max_len	= UINT_MAX;
+	stream->sreq_max_segs	= INT_MAX;
+	switch (stream->source) {
+	case NETFS_UPLOAD_TO_SERVER:
+		netfs_stat(&netfs_n_wh_upload);
+		stream->sreq_max_len = wreq->wsize;
+		break;
+	case NETFS_WRITE_TO_CACHE:
+		netfs_stat(&netfs_n_wh_write);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+
+	if (stream->prepare_write)
+		stream->prepare_write(subreq);
+	netfs_prepare_buffered_write_buffer(subreq, stream->sreq_max_segs);
+	iov_iter_bvec_queue(&subreq->io_iter, ITER_SOURCE,
+			    subreq->content.bvecq, subreq->content.slot,
+			    subreq->content.offset,
+			    subreq->len);
+	trace_netfs_sreq(subreq, netfs_sreq_trace_submit);
+	stream->issue_write(subreq);
+	return 0;
+}
+
+/*
+ * Issue writes for a stream.
+ */
+static void netfs_writeback_flush(struct netfs_io_request *wreq,
+				  struct netfs_io_stream *stream,
+				  struct netfs_wb_params *params)
+{
+	struct netfs_write_estimate *estimate = &params->estimates[stream->stream_nr];
+
+	for (;;) {
+		struct netfs_io_subrequest *subreq;
+		int ret;
+
+		if (test_bit(NETFS_RREQ_PAUSE, &wreq->flags))
+			netfs_wait_for_paused_write(wreq);
+
+		subreq = netfs_alloc_write_subreq(wreq, stream);
+		/* subreq allocation in a writeback is backed by a mempool and
+		 * will wait for an new one to come available.
+		 */
+
+		if (stream->source == NETFS_WRITE_TO_CACHE &&
+		    unlikely(test_bit(NETFS_RREQ_CACHE_STOP, &wreq->flags))) {
+			estimate->issue_at = ULLONG_MAX;
+			estimate->max_segs = INT_MAX;
+			__set_bit(NETFS_SREQ_CANCELLED, &subreq->flags);
+			netfs_advance_stream(wreq, stream, subreq);
+			netfs_write_subrequest_terminated(subreq, subreq->len);
+			return;
+		}
+
+		ret = netfs_prep_and_issue_subreq(wreq, stream, subreq);
+		if (ret < 0) {
+			/* Ownership of subreq was returned to us. */
+			trace_netfs_sreq(subreq, netfs_sreq_trace_fail);
+			bvecq_pos_advance(&stream->dispatch_cursor, subreq->len);
+			netfs_advance_stream(wreq, stream, subreq);
+			netfs_write_subrequest_terminated(subreq, ret);
+		}
+		/* We no longer own subreq. */
+
+		if (stream->buffered == 0) {
+			if (stream->stream_nr == 0)
+				params->notes &= ~NOTE_UPLOAD_STARTED;
+			return;
+		}
+
+		if (!(params->notes & NOTE_FLUSH_ANYWAY)) {
+			estimate->issue_at = ULLONG_MAX;
+			estimate->max_segs = INT_MAX;
+			stream->estimate_write(wreq, stream, estimate);
+			if (stream->issue_from + stream->buffered < estimate->issue_at &&
+			    estimate->max_segs > 0)
+				return;
+		}
+	}
+}
+
+/*
+ * End the issuing of writes, let the collector know we're done.
+ */
+static void netfs_writeback_end(struct netfs_io_request *wreq,
+				struct netfs_wb_params *params)
+{
+	bool needs_poke = true;
+
+	params->notes |= NOTE_FLUSH_ANYWAY;
+
+	for (int s = 0; s < NR_IO_STREAMS; s++) {
+		struct netfs_io_stream *stream = &wreq->io_streams[s];
+
+		if (stream->buffering) {
+			netfs_writeback_flush(wreq, stream, params);
+			stream->buffering = false;
+		}
+	}
+
+	netfs_all_subreqs_queued(wreq);
+
+	for (int s = 0; s < NR_IO_STREAMS; s++) {
+		struct netfs_io_stream *stream = &wreq->io_streams[s];
+
+		if (!stream->active)
+			continue;
+		if (!list_empty(&stream->subrequests))
+			needs_poke = false;
+	}
+
+	if (needs_poke)
+		netfs_wake_collector(wreq);
+}
+
+/*
+ * Add a single, physically contiguous segment of data to a writeback stream
+ * and dispatch subrequests when we hit a discontiguity or have accumulated
+ * sufficient data to hit the estimated dispatch point.
+ */
+static void netfs_writeback_add_seg_to_stream(struct netfs_io_request *wreq,
+					      struct netfs_io_stream *stream,
+					      struct netfs_wb_params *params,
+					      uoff_t start, size_t len,
+					      unsigned int post_gap)
+{
+	struct netfs_write_estimate *estimate = &params->estimates[stream->stream_nr];
+
+	_enter("%llx,%zx", start, len);
+
+	params->notes &= ~NOTE_FLUSH_ANYWAY;
+
+	/* Flush if not contiguous with the previous slice. */
+	if (stream->buffering && start != stream->last_end) {
+		params->notes |= NOTE_FLUSH_ANYWAY;
+		netfs_writeback_flush(wreq, stream, params);
+		params->notes &= ~NOTE_FLUSH_ANYWAY;
+	}
+
+	/* Begin the assembly of a slice and get an estimate of how much we can
+	 * accumulate before we have to flush.
+	 */
+	if (!stream->buffering) {
+		stream->issue_from = start;
+		bvecq_pos_set(&stream->dispatch_cursor, &wreq->load_cursor);
+		stream->buffering = true;
+		stream->buffered = 0;
+		estimate->issue_at = ULLONG_MAX;
+		estimate->max_segs = INT_MAX;
+		stream->estimate_write(wreq, stream, estimate);
+	}
+
+	stream->buffered += len;
+	stream->last_end = start + len;
+	stream->post_gap = post_gap;
+	estimate->max_segs--;
+
+	_debug("[%u] %llx + %zx >= %llx, %u %x",
+	       stream->stream_nr, stream->issue_from, stream->buffered,
+	       estimate->issue_at, estimate->max_segs, params->notes);
+
+	if (stream->issue_from + stream->buffered >= estimate->issue_at ||
+	    estimate->max_segs <= 0)
+		netfs_writeback_flush(wreq, stream, params);
+}
+
+/*
+ * Add a folio directly to the writeback streams and dispatch subrequests as
+ * needed.
  */
-static int netfs_write_folio(struct netfs_io_request *wreq,
-			     struct writeback_control *wbc,
-			     struct folio *folio)
+static void netfs_writeback_add_folio_to_stream(struct netfs_io_request *wreq,
+						struct netfs_wb_params *params,
+						struct folio *folio)
+{
+	size_t fsize = folio_size(folio);
+	uoff_t fpos = params->fpos;
+
+	/* Attach the folio to the rolling buffer. */
+	bvecq_append_page(&wreq->load_cursor, &folio->page, 0, fsize, wreq->gfp, true);
+	wreq->load_cursor.slot--;
+
+	trace_netfs_bv_slot(wreq->load_cursor.bvecq, wreq->load_cursor.slot - 1);
+
+	for (int s = 0; s < NR_IO_STREAMS; s++) {
+		struct netfs_io_stream *stream = &wreq->io_streams[s];
+		size_t off, end;
+
+		if (!stream->active || !(params->notes & stream->applicable))
+			continue;
+
+		/* Select the appropriately sized chunk. */
+		if (stream->source == NETFS_WRITE_TO_CACHE) {
+			off = params->outer_off;
+			end = params->outer_end;
+		} else {
+			off = params->inner_off;
+			end = params->inner_end;
+		}
+
+		wreq->load_cursor.offset = off;
+		netfs_writeback_add_seg_to_stream(wreq, stream, params, fpos + off, end - off,
+						  fsize - end);
+	}
+
+
+	/* Advance the load cursor after copying to the dispatch cursor. */
+	wreq->load_cursor.slot++;
+	wreq->load_cursor.offset = 0;
+}
+
+/*
+ * Queue a folio for writeback.
+ */
+static void netfs_writeback_folio(struct netfs_io_request *wreq,
+				  struct writeback_control *wbc,
+				  struct folio *folio,
+				  struct netfs_wb_params *params)
 {
-	struct netfs_io_stream *upload = &wreq->io_streams[0];
-	struct netfs_io_stream *cache  = &wreq->io_streams[1];
-	struct netfs_io_stream *stream;
 	struct netfs_writeback *wback;
 	struct netfs_group *fgroup; /* TODO: Use this with ceph */
 	struct netfs_folio *finfo;
-	struct bvecq *queue = wreq->load_cursor.bvecq;
-	unsigned int slot;
-	size_t fsize = folio_size(folio), flen = fsize, foff = 0;
+	size_t fsize = folio_size(folio), fend = fsize, foff = 0;
 	uoff_t fpos = folio_pos(folio), i_size;
-	bool to_eof = false, streamw = false;
-	bool debug = false;
-
-	_enter("");
 
-	if (!wreq->spare) {
-		wreq->spare = bvecq_alloc_one(BVECQ_STD_SLOTS, wreq->gfp, true);
-		if (!wreq->spare)
-			return -ENOMEM;
-	}
+	_enter("%x", params->notes);
 
 	/* netfs_perform_write() may shift i_size around the folio or from out
 	 * of the folio to beyond it, but cannot move i_size into or through
@@ -366,6 +708,7 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	 */
 	i_size = i_size_read(wreq->inode);
 
+	params->fpos = fpos;
 	if (fpos >= i_size) {
 		/* mmap beyond eof. */
 		_debug("beyond eof");
@@ -374,7 +717,7 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 		netfs_folio_written_back(wreq, folio);
 		netfs_put_group_many(wreq->group, wreq->nr_group_rel);
 		wreq->nr_group_rel = 0;
-		return 0;
+		return;
 	}
 
 	if (fpos + fsize > wreq->i_size)
@@ -384,21 +727,23 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	finfo = netfs_folio_info(folio);
 	if (finfo) {
 		foff = finfo->dirty_offset;
-		flen = foff + finfo->dirty_len;
-		streamw = true;
+		fend = foff + finfo->dirty_len;
+		params->notes |= NOTE_STREAMW;
 	}
 
-	if (flen > i_size - fpos) {
-		flen = i_size - fpos;
-		if (!streamw)
-			folio_zero_segment(folio, flen, fsize);
-		to_eof = true;
-	} else if (flen == i_size - fpos) {
-		to_eof = true;
+	if (fend > i_size - fpos) {
+		fend = i_size - fpos;
+		if (!(params->notes & NOTE_STREAMW))
+			folio_zero_segment(folio, fend, fsize);
 	}
-	flen -= foff;
 
-	_debug("folio %zx %zx %zx", foff, flen, fsize);
+	/* Account for cache and crypto alignments. */
+	params->inner_off = round_down(foff, params->inner_align);
+	params->inner_end = round_up  (fend, params->inner_align);
+	params->outer_off = round_down(foff, params->outer_align);
+	params->outer_end = round_up  (fend, params->outer_align);
+
+	_debug("folio %zx %zx %zx", foff, fend - foff, fsize);
 
 	/* Deal with discontinuities in the stream of dirty pages.  These can
 	 * arise from a number of sources:
@@ -417,22 +762,32 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	 *     write-back group.
 	 */
 	if (fgroup == NETFS_FOLIO_COPY_TO_CACHE) {
-		netfs_issue_write(wreq, upload);
+		if (!(params->notes & NOTE_CACHE_AVAIL)) {
+			trace_netfs_folio(folio, netfs_folio_trace_cancel_copy);
+			goto cancel_folio;
+		}
+		params->notes |= NOTE_CACHE_COPY;
+		trace_netfs_folio(folio, netfs_folio_trace_store_copy);
 	} else if (fgroup != wreq->group) {
 		/* We can't write this page to the server yet. */
 		kdebug("wrong group");
-		folio_redirty_for_writepage(wbc, folio);
-		folio_unlock(folio);
-		netfs_issue_write(wreq, upload);
-		netfs_issue_write(wreq, cache);
-		return 0;
+		goto skip_folio;
+	} else if (!(params->notes & (NOTE_UPLOAD_AVAIL | NOTE_CACHE_AVAIL))) {
+		trace_netfs_folio(folio, netfs_folio_trace_cancel_store);
+		goto cancel_folio_discard;
+	} else {
+		if (params->notes & NOTE_UPLOAD_STARTED) {
+			params->notes |= NOTE_UPLOAD;
+			trace_netfs_folio(folio, netfs_folio_trace_store_plus);
+		} else {
+			params->notes |= NOTE_UPLOAD | NOTE_UPLOAD_STARTED;
+			trace_netfs_folio(folio, netfs_folio_trace_store);
+		}
+		if ((params->notes & NOTE_CACHE_AVAIL) &&
+		    !(params->notes & NOTE_STREAMW))
+			params->notes |= NOTE_CACHE_COPY;
 	}
 
-	if (foff > 0)
-		netfs_issue_write(wreq, upload);
-	if (streamw)
-		netfs_issue_write(wreq, cache);
-
 	folio_start_writeback(folio);
 	folio_unlock(folio);
 
@@ -454,132 +809,46 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 		/* Order update of len after setting pointer. */
 		smp_store_release(&wback->len, wback->len + fsize);
 	}
- 
-	if (fgroup == NETFS_FOLIO_COPY_TO_CACHE) {
-		if (!cache->avail) {
-			trace_netfs_folio(folio, netfs_folio_trace_cancel_copy);
-			netfs_issue_write(wreq, upload);
-			netfs_folio_written_back(wreq, folio);
-			return 0;
-		}
-		trace_netfs_folio(folio, netfs_folio_trace_store_copy);
-	} else if (!upload->avail && !cache->avail) {
-		trace_netfs_folio(folio, netfs_folio_trace_cancel_store);
-		netfs_folio_written_back(wreq, folio);
-		return 0;
-	} else if (!upload->construct) {
-		trace_netfs_folio(folio, netfs_folio_trace_store);
-	} else {
-		trace_netfs_folio(folio, netfs_folio_trace_store_plus);
-	}
-
-	/* Institute a new bvec queue segment if the current one is full or if
-	 * we encounter a discontiguity.  The discontiguity break is important
-	 * when it comes to bulk unlocking folios by file range.
-	 */
-	if (bvecq_is_full(queue) ||
-	    (fpos != wreq->last_end && wreq->last_end > 0)) {
-		bvecq_buffer_append(&wreq->load_cursor, wreq->spare);
-		wreq->spare = NULL;
-
-		queue = wreq->load_cursor.bvecq;
-		bvecq_pos_move(&wreq->dispatch_cursor, queue);
-		wreq->dispatch_cursor.slot = 0;
-	}
-
-	/* Attach the folio to the rolling buffer. */
-	slot = queue->nr_slots;
-	bvec_set_folio(&queue->bv[slot], folio, fsize, 0);
-	trace_netfs_bv_slot(queue, slot);
-	slot++;
-	bvecq_filled_to(queue, slot);
-	wreq->load_cursor.slot = slot;
-	wreq->load_cursor.offset = 0;
-	wreq->last_end = fpos + fsize;
 
-	/* Move the submission point forward to allow for write-streaming data
-	 * not starting at the front of the page.  We don't do write-streaming
-	 * with the cache as the cache requires DIO alignment.
-	 *
-	 * Also skip uploading for data that's been read and just needs copying
-	 * to the cache.
-	 */
-	bvecq_pos_nudge(&wreq->dispatch_cursor);
-	
+	/* Flush any streams not being used for this folio. */
 	for (int s = 0; s < NR_IO_STREAMS; s++) {
-		size_t soff = foff, slen = flen, alignment = 1;
-
-		stream = &wreq->io_streams[s];
-		if (stream->source == NETFS_WRITE_TO_CACHE)
-			alignment = wreq->cache_resources.dio_size;
-		stream = &wreq->io_streams[s];
-		stream->submit_off = round_down(soff, alignment);
-		slen += foff - stream->submit_off;
-		stream->submit_len = round_up(slen, alignment);
-
-		if (!stream->avail ||
-		    (stream->source == NETFS_WRITE_TO_CACHE && streamw) ||
-		    (stream->source == NETFS_UPLOAD_TO_SERVER &&
-		     fgroup == NETFS_FOLIO_COPY_TO_CACHE)) {
-			stream->submit_off = UINT_MAX;
-			stream->submit_len = 0;
-		}
-	}
+		struct netfs_io_stream *stream = &wreq->io_streams[s];
 
-	/* Attach the folio to one or more subrequests.  For a big folio, we
-	 * could end up with thousands of subrequests if the wsize is small -
-	 * but we might need to wait during the creation of subrequests for
-	 * network resources (eg. SMB credits).
-	 */
-	for (;;) {
-		ssize_t part;
-		size_t lowest_off = ULONG_MAX;
-		int choose_s = -1;
-
-		/* Always add to the lowest-submitted stream first. */
-		for (int s = 0; s < NR_IO_STREAMS; s++) {
-			stream = &wreq->io_streams[s];
-			if (stream->submit_len > 0 &&
-			    stream->submit_off < lowest_off) {
-				lowest_off = stream->submit_off;
-				choose_s = s;
+		if (!stream->active || !(params->notes & stream->applicable)) {
+			if (stream->buffering) {
+				params->notes |= NOTE_FLUSH_ANYWAY;
+				netfs_writeback_flush(wreq, stream, params);
 			}
+			atomic64_set_release(&stream->issued_to, fpos + params->outer_end);
 		}
-
-		if (choose_s < 0)
-			break;
-		stream = &wreq->io_streams[choose_s];
-
-		/* Advance the cursor. */
-		wreq->dispatch_cursor.offset = stream->submit_off;
-
-		atomic64_set(&wreq->issued_to, fpos + stream->submit_off);
-		part = netfs_advance_write(wreq, stream, fpos + stream->submit_off,
-					   stream->submit_len, to_eof);
-		stream->submit_off += part;
-		if (part > stream->submit_len)
-			stream->submit_len = 0;
-		else
-			stream->submit_len -= part;
-		if (part > 0)
-			debug = true;
 	}
 
-	bvecq_pos_step(&wreq->dispatch_cursor);
-	/* Order loading the queue before updating the issue_to point */
-	atomic64_set_release(&wreq->issued_to, fpos + fsize);
-
-	if (!debug)
-		kdebug("R=%x: No submit", wreq->debug_id);
+	/* Initiate or extend the dispatch of each selected stream.  At this
+	 * point we may need to copy the data to a bounce buffer and push the
+	 * bounce bits instead.
+	 */
+	// TODO: Do bouncing if selected.
+	netfs_writeback_add_folio_to_stream(wreq, params, folio);
 
-	if (foff + flen < fsize)
-		for (int s = 0; s < NR_IO_STREAMS; s++)
-			netfs_issue_write(wreq, &wreq->io_streams[s]);
+out:
+	_leave(" = %x", params->notes);
+	return;
 
-	_leave(" = 0");
-	return 0;
+skip_folio:
+	folio_redirty_for_writepage(wbc, folio);
+	folio_unlock(folio);
+	goto out;
+cancel_folio_discard:
+	netfs_put_group(fgroup);
+cancel_folio:
+	folio_detach_private(folio);
+	kfree(finfo);
+	folio_unlock(folio);
+	folio_cancel_dirty(folio);
+	goto out;
 }
 
+#if 0 // TODO: Remove
 /*
  * End the issuing of writes, letting the collector know we're done.
  */
@@ -602,6 +871,7 @@ static void netfs_end_issue_write(struct netfs_io_request *wreq)
 	if (needs_poke)
 		netfs_wake_collector(wreq);
 }
+#endif
 
 /*
  * Write some of the pending data back to the server
@@ -611,6 +881,7 @@ int netfs_writepages(struct address_space *mapping,
 {
 	struct netfs_inode *ictx = netfs_inode(mapping->host);
 	struct netfs_io_request *wreq = NULL;
+	struct netfs_wb_params params = {};
 	struct folio *folio;
 	int error = 0;
 
@@ -628,46 +899,50 @@ int netfs_writepages(struct address_space *mapping,
 		goto couldnt_start;
 	}
 
-	if (bvecq_buffer_init(&wreq->load_cursor, wreq->gfp, true) < 0)
-		goto nomem;
-	bvecq_pos_set(&wreq->dispatch_cursor, &wreq->load_cursor);
-	bvecq_pos_set(&wreq->collect_cursor, &wreq->dispatch_cursor);
+	bvecq_buffer_init(&wreq->load_cursor, GFP_NOFS, true);
 
 	__set_bit(NETFS_RREQ_OFFLOAD_COLLECTION, &wreq->flags);
 	trace_netfs_write(wreq, netfs_write_trace_writeback);
 	netfs_stat(&netfs_n_wh_writepages);
 
-	do {
-		_debug("wbiter %lx %llx", folio->index, atomic64_read(&wreq->issued_to));
+	params.inner_align = 1;
+	params.outer_align = 1;
 
-		/* It appears we don't have to handle cyclic writeback wrapping. */
-		WARN_ON_ONCE(wreq && folio_pos(folio) < atomic64_read(&wreq->issued_to));
+	if (wreq->io_streams[1].avail) {
+		params.notes |= NOTE_CACHE_AVAIL;
+		params.outer_align = wreq->cache_resources.dio_size;
+	}
+	// TODO: Adjust alignments for crypto
+
+	do {
+		_debug("wbiter %lx", folio->index);
 
 		if (netfs_folio_group(folio) != NETFS_FOLIO_COPY_TO_CACHE &&
 		    unlikely(!test_bit(NETFS_RREQ_UPLOAD_TO_SERVER, &wreq->flags))) {
 			set_bit(NETFS_RREQ_UPLOAD_TO_SERVER, &wreq->flags);
 			wreq->netfs_ops->begin_writeback(wreq);
+			if (wreq->io_streams[0].avail) {
+				params.notes |= NOTE_UPLOAD_AVAIL;
+				/* Order setting the active flag after other fields. */
+				smp_store_release(&wreq->io_streams[0].active, true);
+			}
 		}
 
-		error = netfs_write_folio(wreq, wbc, folio);
-		if (error == -ENOMEM) {
-			folio_redirty_for_writepage(wbc, folio);
-			folio_unlock(folio);
-		}
+		params.notes &= NOTES__KEEP_MASK;
+		netfs_writeback_folio(wreq, wbc, folio, &params);
 	} while ((folio = writeback_iter(mapping, wbc, folio, &error)));
 
-	netfs_end_issue_write(wreq);
+	netfs_writeback_end(wreq, &params);
+
 	bvecq_pos_unset(&wreq->load_cursor);
-	bvecq_pos_unset(&wreq->dispatch_cursor);
+	for (int i = 0; i < NR_IO_STREAMS; i++)
+		bvecq_pos_unset(&wreq->io_streams[i].dispatch_cursor);
 	netfs_wake_collector(wreq);
 
 	netfs_put_request(wreq, netfs_rreq_trace_put_return);
 	_leave(" = %d", error);
 	return error;
 
-nomem:
-	error = -ENOMEM;
-	netfs_put_failed_request(wreq);
 couldnt_start:
 	if (error == -ENOMEM) {
 		folio_redirty_for_writepage(wbc, folio);
@@ -761,7 +1036,6 @@ int netfs_writeback_single(struct address_space *mapping,
 		subreq->len = wreq->len;
 		if (stream->source == NETFS_WRITE_TO_CACHE)
 			subreq->len = clen;
-		stream->submit_len = subreq->len;
 
 		netfs_issue_write(wreq, stream);
 	}
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 2cd8f6a9c440..23c13eb178fb 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -160,23 +160,32 @@ struct netfs_write_estimate {
  * have to write to multiple destinations concurrently.
  */
 struct netfs_io_stream {
-	/* Submission tracking */
+	/* Submission tracking (main dispatch only; not retry) */
+	struct bvecq_pos	dispatch_cursor; /* Point from which buffers are dispatched */
 	struct netfs_io_subrequest *construct;	/* Op being constructed */
 	uoff_t			issue_from;	/* Current issue point */
+	uoff_t			last_end;	/* End file pos of last folio added */
+	size_t			buffered;	/* Amount in buffer */
+	size_t			post_gap;	/* Length of partial folio tail */
 	size_t			sreq_max_len;	/* Maximum size of a subrequest */
 	unsigned int		sreq_max_segs;	/* 0 or max number of segments in an iterator */
 	unsigned int		submit_off;	/* Folio offset we're submitting from */
 	unsigned int		submit_len;	/* Amount of data left to submit */
+	unsigned int            alignment;      /* Required alignment */
+	u8			applicable;	/* What sources are applicable (NOTE_* mask) */
+	bool			buffering;	/* T if buffering on this stream */
 	int (*estimate_write)(struct netfs_io_request *wreq,
 			      struct netfs_io_stream *stream,
 			      struct netfs_write_estimate *estimate);
 	void (*prepare_write)(struct netfs_io_subrequest *subreq);
 	void (*issue_write)(struct netfs_io_subrequest *subreq);
+	atomic64_t		issued_to;	/* Point to which can be considered issued */
+
 	/* Collection tracking */
 	struct list_head	subrequests;	/* Contributory I/O operations */
 	uoff_t			collected_to;	/* Position we've collected results to */
 	size_t			transferred;	/* The amount transferred from this stream */
-	unsigned short		error;		/* Aggregate error for the stream */
+	short			error;		/* Aggregate error for the stream */
 	enum netfs_io_source	source;		/* Where to read from/write to */
 	unsigned char		stream_nr;	/* Index of stream in parent table */
 	bool			avail;		/* T if stream is available */
@@ -217,11 +226,12 @@ struct netfs_io_subrequest {
 	struct iov_iter		io_iter;	/* Iterator for this subrequest */
 	uoff_t			start;		/* Where to start the I/O */
 	size_t			len;		/* Size of the I/O */
+	size_t			post_gap;	/* Length of partial folio tail */
 	size_t			transferred;	/* Amount of data transferred */
 	refcount_t		ref;
 	short			error;		/* 0 or error that occurred */
 	unsigned short		debug_index;	/* Index in list (for debugging output) */
-	unsigned int		nr_segs;	/* Number of segs in io_iter */
+	unsigned int		nr_segs;	/* Number of segments in content */
 	u8			retry_count;	/* The number of retries (0 on initial pass) */
 	enum netfs_io_source	source;		/* Where to read from/write to */
 	unsigned char		stream_nr;	/* I/O stream this belongs to */
@@ -291,7 +301,6 @@ struct netfs_io_request {
 	long			error;		/* 0 or error that occurred */
 	uoff_t			i_size;		/* Size of the file */
 	uoff_t			start;		/* Start position */
-	atomic64_t		issued_to;	/* Write issuer folio cursor */
 	uoff_t			collected_to;	/* Point we've collected to */
 	uoff_t			cache_coll_to;	/* Point the cache has collected to */
 	uoff_t			cleaned_to;	/* Position we've cleaned folios to */
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index d098978623f7..ea4721cc41ac 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -654,6 +654,7 @@ TRACE_EVENT(netfs_collect_sreq,
 		    __field(unsigned int,	stream)
 		    __field(unsigned int,	len)
 		    __field(unsigned int,	transferred)
+		    __field(unsigned int,	post_gap)
 		    __field(uoff_t,		start)
 			     ),
 
@@ -663,12 +664,14 @@ TRACE_EVENT(netfs_collect_sreq,
 		    __entry->stream	= subreq->stream_nr;
 		    __entry->start	= subreq->start;
 		    __entry->len	= subreq->len;
+		    __entry->post_gap	= subreq->post_gap;
 		    __entry->transferred = subreq->transferred;
 			   ),
 
-	    TP_printk("R=%08x[%u:%02x] s=%llx t=%x/%x",
+	    TP_printk("R=%08x[%u:%02x] s=%llx t=%x/%x gap=%x",
 		      __entry->wreq, __entry->stream, __entry->subreq,
-		      __entry->start, __entry->transferred, __entry->len)
+		      __entry->start, __entry->transferred, __entry->len,
+		      __entry->post_gap)
 	    );
 
 TRACE_EVENT(netfs_collect_folio,
@@ -766,7 +769,7 @@ TRACE_EVENT(netfs_collect_stream,
 		    __entry->wreq	= wreq->debug_id;
 		    __entry->stream	= stream->stream_nr;
 		    __entry->collected_to = stream->collected_to;
-		    __entry->issued_to	= atomic64_read(&wreq->issued_to);
+		    __entry->issued_to	= atomic64_read(&stream->issued_to);
 			   ),
 
 	    TP_printk("R=%08x[%x:] cto=%llx ito=%llx",

