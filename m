Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA483426EB8
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 14:51:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786373473; cv=none; b=aHHjLbpOneSFD7CNZhYRSIxbUAbj4eVrMfZraG/podZAsED8oAeRVY2TU8AEJhZ564zBTRC74b6GnhV2b9ATZOu0tcfqS7cR8kFXZyh5zE3X2t3TRUPDIpe0erp/rsP3jSaOD4AbhKw4HyvsC2jsRgfCOYdplSimc+8Gp3e6Abw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786373473; c=relaxed/simple;
	bh=mlanOmHU8sKtERLRe01oLN9O9Fn/vxkzFx6my+544/Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fR9EdjIqbOuUXHVhHptLlktQF4/Jrq0ASrDoTKkZ+9WPpq6YWK9P8QA4L0biM3t+jmDzUKX5l3b9TQF3KomTXqiEnDkr9MOuz7iHKDTVeWQkyxc3XsKTjz6M+tUWQ7ZOr7W+Ia4x+dCF6YT9PEYEaRAPe6qR/QV4i7JAjJ40R84=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=O5+imLzb; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="O5+imLzb"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786373470;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=zCKCHVU4x1+k2/6kAbaEEPJTYyTGEg0cSKfx7OBMmiQ=;
	b=O5+imLzbLt9tw6ccL6g00Af14KPydL7xrETq1ZO/vHvPCTTES/RoIzm6Px3fvf8+9dCZDb
	3kJxpqJfC7e+XxeLBbiRkRwPgiG3gTKfl4tHfBb20/5/Ptlj/a2nKJkmexlTSiH9RTmSrd
	iU4hLpSnnVAyTd/E4RFUJ9qMuoHj9jk=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-297-nWL5YjxwOEyHVhodz7oNqw-1; Mon,
 10 Aug 2026 10:51:04 -0400
X-MC-Unique: nWL5YjxwOEyHVhodz7oNqw-1
X-Mimecast-MFC-AGG-ID: nWL5YjxwOEyHVhodz7oNqw_1786373462
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E18581800578;
	Mon, 10 Aug 2026 14:51:01 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.32.44])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2768719560AB;
	Mon, 10 Aug 2026 14:50:55 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Steve French <sfrench@samba.org>,
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
Subject: [PATCH v9 23/26] netfs: Simplify read abandonment
Date: Mon, 10 Aug 2026 15:47:40 +0100
Message-ID: <20260810144746.574036-24-dhowells@redhat.com>
In-Reply-To: <20260810144746.574036-1-dhowells@redhat.com>
References: <20260810144746.574036-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Currently, if one or more of the subrequests in a read request fails, the
read collection algorithm will attempt to salvage folios that are fully
downloaded but that span multiple subreqs, provided all of the contributory
subreqs succeeded, but this makes the algorithm quite complicated as a
subreq can contribute to multiple folios and a folio can be contributed to
by multiple subreqs.

Simplify this by just abandoning the rest of a read request once a
permanently failed subreq is hit.  This is what read_folio, DIO/unbuffered
read, gap filling, RMW and write preload all need to do; readahead is the
odd one out as it doesn't have any return other than unlocking folios.

With this change, even for readahead, the rest of the read is simply
abandoned; read() and suchlike will call ->read_folio() on each
non-uptodate folio to retry and retrieve the error.

Note that retryable failures still get retried by netfslib as part of the
request as before.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/read_collect.c | 190 ++++++++++++++++++++++++++++------------
 include/linux/netfs.h   |   1 +
 2 files changed, 137 insertions(+), 54 deletions(-)

diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index 5d0a8a75ce26..cf7c36037edc 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -19,8 +19,8 @@
 #define MADE_PROGRESS	0x04	/* Made progress cleaning up a stream or the folio set */
 #define BUFFERED	0x08	/* The pagecache needs cleaning up */
 #define NEED_RETRY	0x10	/* A front op requests retrying */
-#define COPY_TO_CACHE	0x40	/* Need to copy subrequest to cache */
-#define ABANDON_SREQ	0x80	/* Need to abandon untransferred part of subrequest */
+#define COPY_TO_CACHE	0x20	/* Need to copy subrequest to cache */
+#define ABANDON_RREQ	0x40	/* Need to abandon the rest of a request */
 
 /*
  * Clear the unread part of an I/O request.
@@ -174,6 +174,78 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 	rreq->collect_cursor.slot = slot;
 }
 
+/*
+ * Abandon all remaining read results.  Once we've hit a permanent failure, we
+ * assume that the file is probably unusable.  In the event of readahead, in
+ * theory we might manage to read some data later in the file, that we could
+ * still unlock, but ->read_folio() will be called again.
+ */
+static void netfs_abandon_read_results(struct netfs_io_request *rreq)
+{
+	struct netfs_io_stream *stream = &rreq->io_streams[0];
+	unsigned int notes = ABANDON_RREQ;
+
+	_enter("%llx-%llx", rreq->start, rreq->start + rreq->len);
+	trace_netfs_rreq(rreq, netfs_rreq_trace_collect);
+	trace_netfs_collect(rreq);
+
+	if (rreq->origin == NETFS_READAHEAD ||
+	    rreq->origin == NETFS_READPAGE ||
+	    rreq->origin == NETFS_READ_FOR_WRITE)
+		notes |= BUFFERED;
+
+	/* Remove completed subrequests from the front of the stream and
+	 * advance the completion point.  We stop when we hit something that's
+	 * in progress.  The issuer thread may be adding stuff to the tail
+	 * whilst we're doing this.
+	 */
+	for (;;) {
+		struct netfs_io_subrequest *front;
+		unsigned long front_flags;
+
+		front = list_first_entry_or_null_acquire(&stream->subrequests,
+							 struct netfs_io_subrequest, rreq_link);
+		/* Read first subreq pointer before IN_PROGRESS flag. */
+		if (!front)
+			break;
+
+		front_flags = smp_load_acquire(&front->flags);
+		/* Order read of flags before read of anything else, such as error. */
+
+		/* Wait for each subreq to complete. */
+		if (test_bit(NETFS_SREQ_IN_PROGRESS, &front_flags)) {
+			notes |= HIT_PENDING;
+			break;
+		}
+
+		/* The subreq now belongs to us. */
+		if (!stream->failed) {
+			stream->failed = true;
+			stream->error = front->error;
+			rreq->error = front->error;
+			trace_netfs_rreq(rreq, netfs_rreq_trace_set_abandon);
+		}
+
+		stream->collected_to = front->start + front->len;
+		trace_netfs_sreq(front, netfs_sreq_trace_abandoned);
+
+		spin_lock(&rreq->lock);
+		list_del_init(&front->rreq_link);
+		spin_unlock(&rreq->lock);
+		netfs_put_subrequest(front, netfs_sreq_trace_put_abandon);
+	}
+
+	rreq->collected_to = stream->collected_to;
+	rreq->abandon_to = rreq->collected_to;
+	if (notes & BUFFERED)
+		netfs_read_unlock_folios(rreq, &notes);
+	else
+		rreq->cleaned_to = rreq->collected_to;
+
+	trace_netfs_collect_stream(rreq, stream);
+	trace_netfs_collect_state(rreq, rreq->collected_to, notes);
+}
+
 /*
  * Collect and assess the results of various read subrequests.  We may need to
  * retry some of the results.
@@ -193,6 +265,9 @@ static void netfs_collect_read_results(struct netfs_io_request *rreq)
 	trace_netfs_collect(rreq);
 
 reassess:
+	if (test_bit(NETFS_RREQ_ABANDON_REQ, &rreq->flags))
+		goto abandon_request;
+
 	if (rreq->origin == NETFS_READAHEAD ||
 	    rreq->origin == NETFS_READPAGE ||
 	    rreq->origin == NETFS_READ_FOR_WRITE)
@@ -210,7 +285,9 @@ static void netfs_collect_read_results(struct netfs_io_request *rreq)
 	/* Read first subreq pointer before IN_PROGRESS flag. */
 
 	while (front) {
+		unsigned long front_flags;
 		size_t transferred;
+		uoff_t unlock_at = rreq->start + rreq->progress_at;
 
 		trace_netfs_collect_sreq(rreq, front);
 		_debug("sreq [%x] %llx %zx/%zx",
@@ -221,25 +298,63 @@ static void netfs_collect_read_results(struct netfs_io_request *rreq)
 			stream->collected_to = front->start;
 		}
 
-		if (netfs_check_subreq_in_progress(front))
+		front_flags = smp_load_acquire(&front->flags);
+		/* Order read of flags before read of anything else, such as error. */
+
+		if (test_bit(NETFS_SREQ_FAILED, &front_flags))
+			goto abandon_request;
+		if (test_bit(NETFS_SREQ_IN_PROGRESS, &front_flags))
 			notes |= HIT_PENDING;
-		smp_rmb(); /* Read counters after IN_PROGRESS flag. */
+
 		transferred = READ_ONCE(front->transferred);
 
+		/* If we can collect the next folio from a pending op, do so,
+		 * but we should only do it if we don't otherwise need to wait
+		 * for completion.
+		 */
+		if ((notes & HIT_PENDING) &&
+		    (notes & BUFFERED) &&
+		    !test_bit(NETFS_SREQ_HIT_EOF, &front_flags) &&
+		    front->error == 0 &&
+		    transferred < front->len
+		    ) {
+			stream->collected_to = front->start + transferred;
+			rreq->collected_to = stream->collected_to;
+
+			if (test_bit(NETFS_SREQ_COPY_TO_CACHE, &front_flags))
+				notes |= COPY_TO_CACHE;
+			if (front->start + transferred >= unlock_at)
+				netfs_read_unlock_folios(rreq, &notes);
+		}
+
+		/* Stall if the front is still undergoing I/O. */
+		if (notes & HIT_PENDING)
+			break;
+
+		if (test_bit(NETFS_SREQ_NEED_RETRY, &front_flags)) {
+			stream->need_retry = true;
+			notes |= NEED_RETRY | MADE_PROGRESS;
+			break;
+		} else if (test_bit(NETFS_RREQ_SHORT_TRANSFER, &rreq->flags)) {
+			notes |= MADE_PROGRESS;
+		} else {
+			stream->transferred += transferred;
+			stream->transferred_valid = true;
+			if (front->transferred < front->len)
+				set_bit(NETFS_RREQ_SHORT_TRANSFER, &rreq->flags);
+			notes |= MADE_PROGRESS;
+		}
+
 		/* If we can now collect the next folio, do so.  We don't want
 		 * to defer this as we have to decide whether we need to copy
 		 * to the cache or not, and that may differ between adjacent
 		 * subreqs.
 		 */
 		if (notes & BUFFERED) {
-			uoff_t unlock_at = rreq->start + rreq->progress_at;
-
 			/* Clear the tail of a short read. */
-			if (!(notes & HIT_PENDING) &&
-			    front->error == 0 &&
-			    transferred < front->len &&
-			    (test_bit(NETFS_SREQ_HIT_EOF, &front->flags) ||
-			     test_bit(NETFS_SREQ_CLEAR_TAIL, &front->flags))) {
+			if (transferred < front->len &&
+			    (test_bit(NETFS_SREQ_HIT_EOF, &front_flags) ||
+			     test_bit(NETFS_SREQ_CLEAR_TAIL, &front_flags))) {
 				netfs_clear_unread(front);
 				transferred = front->transferred = front->len;
 				trace_netfs_sreq(front, netfs_sreq_trace_clear);
@@ -248,67 +363,28 @@ static void netfs_collect_read_results(struct netfs_io_request *rreq)
 			stream->collected_to = front->start + transferred;
 			rreq->collected_to = stream->collected_to;
 
-			if (test_bit(NETFS_SREQ_COPY_TO_CACHE, &front->flags))
+			if (test_bit(NETFS_SREQ_COPY_TO_CACHE, &front_flags))
 				notes |= COPY_TO_CACHE;
 
-			if (test_bit(NETFS_SREQ_FAILED, &front->flags)) {
-				rreq->abandon_to = front->start + front->len;
-				front->transferred = front->len;
-				transferred = front->len;
-				trace_netfs_rreq(rreq, netfs_rreq_trace_set_abandon);
-			}
 			if (front->start + transferred >= unlock_at ||
-			    test_bit(NETFS_SREQ_HIT_EOF, &front->flags))
+			    test_bit(NETFS_SREQ_HIT_EOF, &front_flags))
 				netfs_read_unlock_folios(rreq, &notes);
 		} else {
 			stream->collected_to = front->start + transferred;
 			rreq->collected_to = stream->collected_to;
 		}
 
-		/* Stall if the front is still undergoing I/O. */
-		if (notes & HIT_PENDING)
-			break;
-
-		if (test_bit(NETFS_SREQ_FAILED, &front->flags)) {
-			if (!stream->failed) {
-				stream->error = front->error;
-				rreq->error = front->error;
-				set_bit(NETFS_RREQ_FAILED, &rreq->flags);
-				stream->failed = true;
-			}
-			notes |= MADE_PROGRESS | ABANDON_SREQ;
-		} else if (test_bit(NETFS_SREQ_NEED_RETRY, &front->flags)) {
-			stream->need_retry = true;
-			notes |= NEED_RETRY | MADE_PROGRESS;
-			break;
-		} else if (test_bit(NETFS_RREQ_SHORT_TRANSFER, &rreq->flags)) {
-			notes |= MADE_PROGRESS;
-		} else {
-			if (!stream->failed) {
-				stream->transferred += transferred;
-				stream->transferred_valid = true;
-			}
-			if (front->transferred < front->len)
-				set_bit(NETFS_RREQ_SHORT_TRANSFER, &rreq->flags);
-			notes |= MADE_PROGRESS;
-		}
-
 		/* Remove if completely consumed. */
 		stream->source = front->source;
 		spin_lock(&rreq->lock);
 
 		remove = front;
-		trace_netfs_sreq(front,
-				 notes & ABANDON_SREQ ?
-				 netfs_sreq_trace_abandoned : netfs_sreq_trace_consumed);
+		trace_netfs_sreq(front, netfs_sreq_trace_consumed);
 		list_del_init(&front->rreq_link);
 		front = list_first_entry_or_null(&stream->subrequests,
 						 struct netfs_io_subrequest, rreq_link);
 		spin_unlock(&rreq->lock);
-		netfs_put_subrequest(remove,
-				     notes & ABANDON_SREQ ?
-				     netfs_sreq_trace_put_abandon :
-				     netfs_sreq_trace_put_done);
+		netfs_put_subrequest(remove, netfs_sreq_trace_put_done);
 	}
 
 	trace_netfs_collect_stream(rreq, stream);
@@ -337,6 +413,12 @@ static void netfs_collect_read_results(struct netfs_io_request *rreq)
 	_debug("retry");
 	netfs_retry_reads(rreq);
 	goto out;
+
+abandon_request:
+	set_bit(NETFS_RREQ_FAILED, &rreq->flags);
+	set_bit(NETFS_RREQ_ABANDON_REQ, &rreq->flags);
+	netfs_wake_rreq_flag(rreq, NETFS_RREQ_PAUSE, netfs_rreq_trace_unpause);
+	return netfs_abandon_read_results(rreq);
 }
 
 /*
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 43696fc67a2a..f277c187c408 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -281,6 +281,7 @@ struct netfs_io_request {
 #define NETFS_RREQ_FAILED		3	/* The request failed */
 #define NETFS_RREQ_RETRYING		4	/* Set if we're in the retry path */
 #define NETFS_RREQ_SHORT_TRANSFER	5	/* Set if we have a short transfer */
+#define NETFS_RREQ_ABANDON_REQ		6	/* Set if the request is to be abandoned */
 #define NETFS_RREQ_CACHE_STOP		8	/* Set to stop caching (ENOBUFS or error) */
 #define NETFS_RREQ_CACHE_ERROR		9	/* Set if we got an error from the cache */
 #define NETFS_RREQ_OFFLOAD_COLLECTION	12	/* Offload collection to workqueue */

