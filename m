Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 711F24AF9E6
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:37:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370682; cv=none; b=HoPFyUDtGlk0Oo2arXfKOZwEGI9/EsZNAO0Dv03cvRyEF5kewDd87JPXyr+bJJ1oczr7ORqKd+MoFvuiHf7040TFRJFwpi2N7PMVvP8whMq97fInG6f8Kp4anvv743wnrhC6OQ2y73upBeUTOm5ONNiPO/BpcymHKlAsM792zG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370682; c=relaxed/simple;
	bh=DIfju+TM6MueFY++AyRPpNAtsfDvSsYOpQsx8IZAucs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PhlKPti8KTs2eV+djUcZGnvSP+1C5A4wr2QAc+/3f7oYiXCEScyRCqNx3QY6M/LE9h+RBUqvZqHmFyG5W4nU4UtUGnOerGKZOER7lccjWGYhIicqDhVvKYXI77dcforYJi/R3THNTucaPCesYYlTGJfYgl4vnsF9mKctQAOPyqU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Hplgxsx0; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Hplgxsx0"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370677;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Ew9nu7cBNXv+hfXx2Pt0ix5LB6J6r3dBooqv2HjEtcg=;
	b=Hplgxsx0pI1swMHUFNQQ59vyOws1xFnzRo+TEkoE5SR65Bm3gsiPgIQTVFhG5lpHVxTNwJ
	3n4Mr7wgc0x49Jx68pQYOrRT6YoSl51EZKQeK2A/3Y2sD4IEQDqkn7On4Fs19e9Ym1JAYL
	hGR4WpknKpBnVA0iBAAMIqWxT91p7hk=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-161-L3wsW3FQP2uxUOTwNVDzeg-1; Wed,
 02 Sep 2026 13:37:51 -0400
X-MC-Unique: L3wsW3FQP2uxUOTwNVDzeg-1
X-Mimecast-MFC-AGG-ID: L3wsW3FQP2uxUOTwNVDzeg_1788370668
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 79EFF192DD66;
	Wed,  2 Sep 2026 17:37:48 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 919031800643;
	Wed,  2 Sep 2026 17:37:42 +0000 (UTC)
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
Subject: [PATCH v11 28/36] netfs: Simplify writeback cleanup
Date: Wed,  2 Sep 2026 18:33:40 +0100
Message-ID: <20260902173350.3468672-29-dhowells@redhat.com>
In-Reply-To: <20260902173350.3468672-1-dhowells@redhat.com>
References: <20260902173350.3468672-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Currently, the netfslib buffered writeback algorithm walks the list of
folios, using that to determine the folios that need to be unlocked.  This
is tricky, however, as different streams really want different folios or
different parts of folios (e.g. data that's read from the server will be
written to the cache, but not written back to the server, and a small
region that can be written to the server may need to be rounded out for DIO
write to the cache).

Further, the collector thread may be walking the folio list at the same
time that the application thread is filling it - and at the same time as
things are doing I/O to or from it.

Finally, it requires careful cleanup during collection, such that there's
always at least one link remaining in the bvecq chain so that the consumer
never gets disconnected from the producer.

Instead, use the end-writeback iteration tool to simplify the cleanup of
writeback by walking the inode's pagecache xarray to find the folios that
will be unmarked rather than looking in the list of bio_vecs that refer to
those folios.

This makes use of the list of file sections under writeback to keep track
of what needs to be dealt with.

Using the end-writeback iterator affords the possibility of improving
efficiency of the process by doing bulk access and bulk modification of the
xarray and stats.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/internal.h          |   2 +-
 fs/netfs/write_collect.c     | 170 +++++++++++++----------------------
 fs/netfs/write_issue.c       |   6 +-
 include/trace/events/netfs.h |  30 +++++++
 4 files changed, 97 insertions(+), 111 deletions(-)

diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index e6e768ad9648..b62c5b7e43d9 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -222,7 +222,7 @@ static inline void netfs_stat_d(atomic_t *stat)
 /*
  * write_collect.c
  */
-int netfs_folio_written_back(struct folio *folio);
+void netfs_folio_written_back(struct netfs_io_request *wreq, struct folio *folio);
 bool netfs_write_collection(struct netfs_io_request *wreq);
 void netfs_write_collection_worker(struct work_struct *work);
 
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index 40f8b1485992..2510d3dd2d58 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -21,57 +21,6 @@
 #define NEED_RETRY		0x10	/* A front op requests retrying */
 #define SAW_FAILURE		0x20	/* One stream or hit a permanent failure */
 
-struct end_writeback_ctrl {
-	struct xa_state xas;
-	uoff_t fend;
-};
-
-/**
- * end_writeback_iter - End writeback for the folios within the range
- * @mapping: The pagecache to modify
- * @from: Pointer to the starting position
- * @to: The end position (exclusive)
- * @ctrl: Iterator state
- * @folio: The last return from this function or NULL if first call
- *
- * Remove the writeback mark on folios that are entirely within in the given
- * range, where @from is included in the range, but @to is excluded from the
- * range.
- *
- * Return: The folio to end writeback upon or NULL if the next folio isn't
- * wholly within the range.  Note that this does not necessarily imply that the
- * ending is complete.  @ctrl->fend is updated to point directly beyond the
- * folio that was considered and may be negative if cast to loff_t.
- */
-static
-struct folio *end_writeback_iter(struct address_space *mapping,
-				 uoff_t from, uoff_t to,
-				 struct end_writeback_ctrl *ctrl,
-				 struct folio *folio)
-{
-	if (!folio) {
-		lockdep_assert_in_rcu_read_lock();
-		ctrl->xas = (struct xa_state)
-			__XA_STATE(&mapping->i_pages, from / PAGE_SIZE, 0, 0);
-		folio = xas_find(&ctrl->xas, (to - 1) / PAGE_SIZE);
-	} else {
-		folio_end_writeback(folio);
-	retry:
-		folio = xas_next_entry(&ctrl->xas, (to - 1) / PAGE_SIZE);
-	}
-
-	if (xas_retry(&ctrl->xas, folio))
-		goto retry;
-
-	if (!folio)
-		return NULL;
-
-	ctrl->fend = folio_next_pos(folio);
-	if (ctrl->fend > to)
-		folio = NULL;
-	return folio;
-}
-
 static void netfs_dump_request(const struct netfs_io_request *rreq)
 {
 	pr_err("Request R=%08x r=%d fl=%lx or=%x e=%ld\n",
@@ -105,14 +54,22 @@ static void netfs_dump_request(const struct netfs_io_request *rreq)
  * that we are not allowed to lock the folio here on pain of deadlocking with
  * truncate.
  */
-int netfs_folio_written_back(struct folio *folio)
+void netfs_folio_written_back(struct netfs_io_request *wreq, struct folio *folio)
 {
 	enum netfs_folio_trace why = netfs_folio_trace_endwb;
 	struct inode *inode = folio_inode(folio);
 	struct netfs_inode *ictx = netfs_inode(inode);
 	struct netfs_folio *finfo;
 	struct netfs_group *group = NULL;
-	int gcount = 0;
+
+	if (WARN_ONCE(!folio_test_writeback(folio),
+		      "R=%08x: folio %lx is not under writeback\n",
+		      wreq->debug_id, folio->index)) {
+		trace_netfs_folio(folio, netfs_folio_trace_not_under_wback);
+		netfs_dump_request(wreq);
+	}
+
+	trace_netfs_collect_folio(wreq, folio);
 
 	if ((finfo = netfs_folio_info(folio))) {
 		/* Streaming writes cannot be redirtied whilst under writeback,
@@ -128,7 +85,7 @@ int netfs_folio_written_back(struct folio *folio)
 
 		folio_detach_private(folio);
 		group = finfo->netfs_group;
-		gcount++;
+		wreq->nr_group_rel++;
 		kfree(finfo);
 		why = netfs_folio_trace_endwb_s;
 		goto end_wb;
@@ -148,15 +105,34 @@ int netfs_folio_written_back(struct folio *folio)
 		why = netfs_folio_trace_redirtied;
 		if (!folio_test_dirty(folio)) {
 			folio_detach_private(folio);
-			gcount++;
+			wreq->nr_group_rel++;
 			why = netfs_folio_trace_endwb_g;
 		}
 	}
 
 end_wb:
 	trace_netfs_folio(folio, why);
-	folio_end_writeback(folio);
-	return gcount;
+}
+
+static bool netfs_writeback_unlock_range(struct netfs_io_request *wreq, uoff_t stop_at)
+{
+	struct end_writeback_ctrl ctrl = {};
+	struct folio *folio = NULL;
+	bool progress = false;
+
+	rcu_read_lock();
+	for (;;) {
+		folio = end_writeback_iter(wreq->mapping, &ctrl,
+					   wreq->cleaned_to, stop_at, folio);
+		if (!folio)
+			break;
+		netfs_folio_written_back(wreq, folio);
+		wreq->cleaned_to = ctrl.fend;
+		progress = true;
+	}
+	rcu_read_unlock();
+
+	return progress;
 }
 
 /*
@@ -165,15 +141,7 @@ int netfs_folio_written_back(struct folio *folio)
 static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 					  unsigned int *notes)
 {
-	struct bvecq *bvecq = wreq->collect_cursor.bvecq;
-	unsigned int slot = wreq->collect_cursor.slot;
-	uoff_t collected_to = wreq->collected_to;
-
-	if (WARN_ON_ONCE(!bvecq)) {
-		pr_err("[!] Writeback unlock found empty buffer!\n");
-		netfs_dump_request(wreq);
-		return;
-	}
+	struct netfs_writeback *wback, *next;
 
 	if (wreq->origin == NETFS_PGPRIV2_COPY_TO_CACHE) {
 		if (netfs_pgpriv2_unlock_copied_folios(wreq))
@@ -181,57 +149,45 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		return;
 	}
 
+	wback = wreq->writebacks;
+
 	for (;;) {
-		struct folio *folio;
-		struct netfs_folio *finfo;
-		uoff_t fpos, fend;
-		size_t fsize, flen;
-
-		/* Try to clean up the head of the queue if it appears to be
-		 * used up, but we need to be very careful - the cleanup can
-		 * catch the dispatcher, which could lead to us having nothing
-		 * left in the queue, causing the front and back pointers to
-		 * end up on different tracks.  To avoid this, we must always
-		 * keep at least one segment in the queue.
-		 */
-		if (!bvecq_acquire_slot(bvecq, slot)) {
-			wreq->collect_cursor.slot = slot;
-			if (!bvecq_delete_spent(&wreq->collect_cursor))
-				return;
-			bvecq = wreq->collect_cursor.bvecq;
-			slot  = wreq->collect_cursor.slot;
-		}
+		uoff_t stop_at;
+		size_t len;
 
-		folio = page_folio(bvecq->bv[slot].bv_page);
-		if (WARN_ONCE(!folio_test_writeback(folio),
-			      "R=%08x: folio %lx is not under writeback\n",
-			      wreq->debug_id, folio->index))
-			trace_netfs_folio(folio, netfs_folio_trace_not_under_wback);
+		/* Jump over discontiguities. */
+		if (wreq->cleaned_to < wback->start)
+			wreq->cleaned_to = wback->start;
 
-		fpos = folio_pos(folio);
-		fsize = folio_size(folio);
-		finfo = netfs_folio_info(folio);
-		flen = finfo ? finfo->dirty_offset + finfo->dirty_len : fsize;
+		if (wreq->collected_to <= wreq->cleaned_to)
+			break;
 
-		fend = min_t(uoff_t, fpos + flen, wreq->i_size);
+		/* Order read of region length before reading folios. */
+		len = smp_load_acquire(&wback->len);
 
-		trace_netfs_collect_folio(wreq, folio);
+		if (wreq->cleaned_to >= wback->start + len) {
+			/* Order read of next before recheck length. */
+			next = smp_load_acquire(&wback->next);
+			if (!next)
+				break; /* We don't remove the tail writeback. */
 
-		/* Unlock any folio we've transferred all of. */
-		if (collected_to < fend)
-			break;
+			/* Order read of region length before reading folios. */
+			if (len != smp_load_acquire(&wback->len))
+				continue; /* len/next update race. */
 
-		wreq->nr_group_rel += netfs_folio_written_back(folio);
-		wreq->cleaned_to = fpos + fsize;
-		*notes |= MADE_PROGRESS;
+			mempool_free(wback, &netfs_bvecq_pool);
+			wreq->writebacks = next;
+			wback = next;
+			continue;
+		}
+
+		stop_at = min(wreq->collected_to, wback->start + len);
 
-		bvecq->bv[slot].bv_page = NULL;
-		slot++;
-		if (fpos + fsize >= collected_to)
+		trace_netfs_collect_folios(wreq, wback->start, len);
+		if (!netfs_writeback_unlock_range(wreq, stop_at))
 			break;
+		*notes |= MADE_PROGRESS;
 	}
-
-	wreq->collect_cursor.slot = slot;
 }
 
 /*
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index ace790b127ca..086869bd0db1 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -369,7 +369,7 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 		_debug("beyond eof");
 		folio_start_writeback(folio);
 		folio_unlock(folio);
-		wreq->nr_group_rel += netfs_folio_written_back(folio);
+		netfs_folio_written_back(wreq, folio);
 		netfs_put_group_many(wreq->group, wreq->nr_group_rel);
 		wreq->nr_group_rel = 0;
 		return 0;
@@ -457,13 +457,13 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 		if (!cache->avail) {
 			trace_netfs_folio(folio, netfs_folio_trace_cancel_copy);
 			netfs_issue_write(wreq, upload);
-			netfs_folio_written_back(folio);
+			netfs_folio_written_back(wreq, folio);
 			return 0;
 		}
 		trace_netfs_folio(folio, netfs_folio_trace_store_copy);
 	} else if (!upload->avail && !cache->avail) {
 		trace_netfs_folio(folio, netfs_folio_trace_cancel_store);
-		netfs_folio_written_back(folio);
+		netfs_folio_written_back(wreq, folio);
 		return 0;
 	} else if (!upload->construct) {
 		trace_netfs_folio(folio, netfs_folio_trace_store);
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index 444ae7d3a01a..006bd2c73670 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -773,6 +773,36 @@ TRACE_EVENT(netfs_collect_stream,
 		      __entry->collected_to, __entry->issued_to)
 	    );
 
+TRACE_EVENT(netfs_collect_folios,
+	    TP_PROTO(const struct netfs_io_request *wreq,
+		     uoff_t range_start, size_t range_len),
+
+	    TP_ARGS(wreq, range_start, range_len),
+
+	    TP_STRUCT__entry(
+		    __field(unsigned int,	wreq)
+		    __field(size_t,		range_len)
+		    __field(uoff_t,		range_start)
+		    __field(uoff_t,		cleaned_to)
+		    __field(uoff_t,		collected_to)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->wreq		= wreq->debug_id;
+		    __entry->range_len		= range_len;
+		    __entry->range_start	= range_start;
+		    __entry->cleaned_to		= wreq->cleaned_to;
+		    __entry->collected_to	= wreq->collected_to;
+			   ),
+
+	    TP_printk("R=%08x r=%llx-%llx cln=%llx col=%llx",
+		      __entry->wreq,
+		      __entry->range_start,
+		      __entry->range_start + __entry->range_len,
+		      __entry->cleaned_to,
+		      __entry->collected_to)
+	    );
+
 TRACE_EVENT(netfs_bvecq,
 	    TP_PROTO(const struct bvecq *bq,
 		     enum netfs_bvecq_trace trace),

