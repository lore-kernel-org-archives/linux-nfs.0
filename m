Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E29313749FE
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:36:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370570; cv=none; b=uiYsYdmDKy5aCThv1g5Gyw5cNXLc65K49sW6LffyHDM+cOnBKrwqeUJvHrQE8cgvq12alvkltCTLfSy+olgUAdc5JaXBMdpzsh29odQB+m9bpxGqFJPJ/AsBTXFedT/0uOVynaJ868S6oPS3S/uRuGi2v4ee2hUf6lk9gR/Qru8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370570; c=relaxed/simple;
	bh=abVgwzB7Uc3gdT0msDfTei5yjPAsi0MGGJP/Ou9gYdA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ulpsWAde1oSHyqvyi6qXIQHMFDkhgjZTFGOooDXu3D/0XA9xHlN/d76zkjPRk3ysPkRFHl3VYntZXijxD6jzIiByazeZI8/kqwtGR6gn2vq108C0ckpFacRccfbpOf25rRNeFWrFF3BevdX5tC3DJQ2zmquDNmrc0VN90JCtsMg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=EeWv0qZi; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="EeWv0qZi"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370566;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DGTmuQg0N2IjBOF4e+gvgsqJmNFDlFfUz+wMzY3v7bU=;
	b=EeWv0qZilJcUEELJJSq0nFU20oeca6ZD7KPMOz+g/KHC/PHrbKgttjV9+m7VCEnlxLJys4
	BM0R0Bn63/ERj1fmilMzvV9jLS/jXeO3kzFYskcMsuMe+4QTvxqF9WC8hJWIcm5Yij5FUd
	5w1wjMF6dTZZSiHEUZcz0jkeA+liWv4=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-668-aiORzU0zNuapdisWSEWJDQ-1; Wed,
 02 Sep 2026 13:36:02 -0400
X-MC-Unique: aiORzU0zNuapdisWSEWJDQ-1
X-Mimecast-MFC-AGG-ID: aiORzU0zNuapdisWSEWJDQ_1788370559
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 50F3918009B9;
	Wed,  2 Sep 2026 17:35:59 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 65EC91800643;
	Wed,  2 Sep 2026 17:35:53 +0000 (UTC)
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
Subject: [PATCH v11 14/36] netfs: Remove the writethrough code
Date: Wed,  2 Sep 2026 18:33:26 +0100
Message-ID: <20260902173350.3468672-15-dhowells@redhat.com>
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

Remove the netfs writethrough code as it's very tricky to get the locking
right and it will probably deadlock if used in conjunction with Ceph
snapshots because it excludes writeback for the duration, but to flush out
old snapshots, it does a synchronous flush that invokes writeback.

Instead, O_SYNC writes do a flush after performing the write - which is
already there as the callers of netfs_perform_write() all call
generic_write_sync().

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/9p/vfs_addr.c             |   1 -
 fs/afs/file.c                |   1 -
 fs/netfs/buffered_write.c    |  56 ++-----------------
 fs/netfs/internal.h          |   7 ---
 fs/netfs/main.c              |   1 -
 fs/netfs/stats.c             |   4 +-
 fs/netfs/write_collect.c     |   2 -
 fs/netfs/write_issue.c       | 104 +----------------------------------
 include/linux/netfs.h        |   1 -
 include/trace/events/netfs.h |   8 +--
 10 files changed, 9 insertions(+), 176 deletions(-)

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 1ac0b3dcc077..2129fcb0f65c 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -124,7 +124,6 @@ static int v9fs_init_request(struct netfs_io_request *rreq, struct file *file)
 	struct p9_fid *fid;
 	struct dentry *dentry;
 	bool writing = (rreq->origin == NETFS_READ_FOR_WRITE ||
-			rreq->origin == NETFS_WRITETHROUGH ||
 			rreq->origin == NETFS_UNBUFFERED_WRITE ||
 			rreq->origin == NETFS_DIO_WRITE);
 
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 3380a0d20c0f..99987f6bbc36 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -400,7 +400,6 @@ static int afs_init_request(struct netfs_io_request *rreq, struct file *file)
 		}
 		break;
 	case NETFS_WRITEBACK:
-	case NETFS_WRITETHROUGH:
 	case NETFS_UNBUFFERED_WRITE:
 	case NETFS_DIO_WRITE:
 		if (S_ISREG(rreq->inode->i_mode))
diff --git a/fs/netfs/buffered_write.c b/fs/netfs/buffered_write.c
index df496873e4f4..ead22980075f 100644
--- a/fs/netfs/buffered_write.c
+++ b/fs/netfs/buffered_write.c
@@ -91,44 +91,14 @@ ssize_t netfs_perform_write(struct kiocb *iocb, struct iov_iter *iter,
 	struct inode *inode = file_inode(file);
 	struct address_space *mapping = inode->i_mapping;
 	struct netfs_inode *ctx = netfs_inode(inode);
-	struct writeback_control wbc = {
-		.sync_mode	= WB_SYNC_NONE,
-		.for_sync	= true,
-		.nr_to_write	= LONG_MAX,
-		.range_start	= iocb->ki_pos,
-		.range_end	= iocb->ki_pos + iter->count,
-	};
-	struct netfs_io_request *wreq = NULL;
-	struct folio *folio = NULL, *writethrough = NULL;
+	struct folio *folio = NULL;
 	unsigned int bdp_flags = (iocb->ki_flags & IOCB_NOWAIT) ? BDP_ASYNC : 0;
-	ssize_t written = 0, ret, ret2;
+	ssize_t written = 0, ret;
 	uoff_t pos = iocb->ki_pos;
 	size_t max_chunk = mapping_max_folio_size(mapping);
 	bool maybe_trouble = false;
 
-	if (unlikely(iocb->ki_flags & (IOCB_DSYNC | IOCB_SYNC))
-	    ) {
-		wbc_attach_fdatawrite_inode(&wbc, mapping->host);
-
-		ret = filemap_write_and_wait_range(mapping, pos, pos + iter->count);
-		if (ret < 0) {
-			wbc_detach_inode(&wbc);
-			goto out;
-		}
-
-		wreq = netfs_begin_writethrough(iocb, iter->count);
-		if (IS_ERR(wreq)) {
-			wbc_detach_inode(&wbc);
-			ret = PTR_ERR(wreq);
-			wreq = NULL;
-			goto out;
-		}
-		if (!is_sync_kiocb(iocb))
-			wreq->iocb = iocb;
-		netfs_stat(&netfs_n_wh_writethrough);
-	} else {
-		netfs_stat(&netfs_n_wh_buffered_write);
-	}
+	netfs_stat(&netfs_n_wh_buffered_write);
 
 	do {
 		enum netfs_folio_trace trace;
@@ -390,15 +360,8 @@ ssize_t netfs_perform_write(struct kiocb *iocb, struct iov_iter *iter,
 		pos += copied;
 		written += copied;
 
-		if (likely(!wreq)) {
-			folio_mark_dirty(folio);
-			folio_unlock(folio);
-		} else {
-			netfs_advance_writethrough(wreq, &wbc, folio, copied,
-						   offset + copied == flen,
-						   &writethrough);
-			/* Folio unlocked */
-		}
+		folio_mark_dirty(folio);
+		folio_unlock(folio);
 	retry:
 		folio_put(folio);
 		folio = NULL;
@@ -420,15 +383,6 @@ ssize_t netfs_perform_write(struct kiocb *iocb, struct iov_iter *iter,
 			ctx->ops->post_modify(inode);
 	}
 
-	if (unlikely(wreq)) {
-		ret2 = netfs_end_writethrough(wreq, &wbc, writethrough);
-		wbc_detach_inode(&wbc);
-		if (ret2 == -EIOCBQUEUED)
-			return ret2;
-		if (ret == 0 && ret2 < 0)
-			ret = ret2;
-	}
-
 	iocb->ki_pos += written;
 	_leave(" = %zd [%zd]", written, ret);
 	return written ? written : ret;
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index 6d40a69e032f..67f2406e00cd 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -158,7 +158,6 @@ extern atomic_t netfs_n_rh_write_zskip;
 extern atomic_t netfs_n_rh_retry_read_req;
 extern atomic_t netfs_n_rh_retry_read_subreq;
 extern atomic_t netfs_n_wh_buffered_write;
-extern atomic_t netfs_n_wh_writethrough;
 extern atomic_t netfs_n_wh_dio_write;
 extern atomic_t netfs_n_wh_writepages;
 extern atomic_t netfs_n_wh_copy_to_cache;
@@ -218,12 +217,6 @@ void netfs_issue_write(struct netfs_io_request *wreq,
 size_t netfs_advance_write(struct netfs_io_request *wreq,
 			   struct netfs_io_stream *stream,
 			   uoff_t start, size_t len, bool to_eof);
-struct netfs_io_request *netfs_begin_writethrough(struct kiocb *iocb, size_t len);
-int netfs_advance_writethrough(struct netfs_io_request *wreq, struct writeback_control *wbc,
-			       struct folio *folio, size_t copied, bool to_page_end,
-			       struct folio **writethrough_cache);
-ssize_t netfs_end_writethrough(struct netfs_io_request *wreq, struct writeback_control *wbc,
-			       struct folio *writethrough_cache);
 
 /*
  * write_retry.c
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 9f72e5054aff..3908ea2422c8 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -45,7 +45,6 @@ static const char *netfs_origins[nr__netfs_io_origin] = {
 	[NETFS_DIO_READ]		= "DR",
 	[NETFS_WRITEBACK]		= "WB",
 	[NETFS_WRITEBACK_SINGLE]	= "W1",
-	[NETFS_WRITETHROUGH]		= "WT",
 	[NETFS_UNBUFFERED_WRITE]	= "UW",
 	[NETFS_DIO_WRITE]		= "DW",
 	[NETFS_PGPRIV2_COPY_TO_CACHE]	= "2C",
diff --git a/fs/netfs/stats.c b/fs/netfs/stats.c
index 84c2a4bcc762..a10d34f88597 100644
--- a/fs/netfs/stats.c
+++ b/fs/netfs/stats.c
@@ -32,7 +32,6 @@ atomic_t netfs_n_rh_write_zskip;
 atomic_t netfs_n_rh_retry_read_req;
 atomic_t netfs_n_rh_retry_read_subreq;
 atomic_t netfs_n_wh_buffered_write;
-atomic_t netfs_n_wh_writethrough;
 atomic_t netfs_n_wh_dio_write;
 atomic_t netfs_n_wh_writepages;
 atomic_t netfs_n_wh_copy_to_cache;
@@ -59,9 +58,8 @@ int netfs_stats_show(struct seq_file *m, void *v)
 		   atomic_read(&netfs_n_rh_read_single),
 		   atomic_read(&netfs_n_rh_write_begin),
 		   atomic_read(&netfs_n_rh_write_zskip));
-	seq_printf(m, "Writes : BW=%u WT=%u DW=%u WP=%u 2C=%u\n",
+	seq_printf(m, "Writes : BW=%u DW=%u WP=%u 2C=%u\n",
 		   atomic_read(&netfs_n_wh_buffered_write),
-		   atomic_read(&netfs_n_wh_writethrough),
 		   atomic_read(&netfs_n_wh_dio_write),
 		   atomic_read(&netfs_n_wh_writepages),
 		   atomic_read(&netfs_n_wh_copy_to_cache));
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index 1a19ee97beed..c92aba14a0b5 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -265,7 +265,6 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 	smp_rmb();
 	collected_to = ULLONG_MAX;
 	if (wreq->origin == NETFS_WRITEBACK ||
-	    wreq->origin == NETFS_WRITETHROUGH ||
 	    wreq->origin == NETFS_PGPRIV2_COPY_TO_CACHE)
 		notes = NEED_UNLOCK;
 	else
@@ -462,7 +461,6 @@ bool netfs_write_collection(struct netfs_io_request *wreq)
 	switch (wreq->origin) {
 	case NETFS_WRITEBACK:
 	case NETFS_WRITEBACK_SINGLE:
-	case NETFS_WRITETHROUGH:
 		netfs_wb_end(ictx);
 		break;
 	default:
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 550642dba507..c3db732a20af 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -96,7 +96,6 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 	struct netfs_inode *ictx;
 	bool is_cacheable = (origin == NETFS_WRITEBACK ||
 			     origin == NETFS_WRITEBACK_SINGLE ||
-			     origin == NETFS_WRITETHROUGH ||
 			     origin == NETFS_PGPRIV2_COPY_TO_CACHE);
 
 	wreq = netfs_alloc_request(mapping, file, start, 0, origin);
@@ -367,11 +366,7 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 		streamw = true;
 	}
 
-	if (wreq->origin == NETFS_WRITETHROUGH) {
-		to_eof = false;
-		if (flen > i_size - fpos)
-			flen = i_size - fpos;
-	} else if (flen > i_size - fpos) {
+	if (flen > i_size - fpos) {
 		flen = i_size - fpos;
 		if (!streamw)
 			folio_zero_segment(folio, flen, fsize);
@@ -613,103 +608,6 @@ int netfs_writepages(struct address_space *mapping,
 }
 EXPORT_SYMBOL(netfs_writepages);
 
-/*
- * Begin a write operation for writing through the pagecache.
- */
-struct netfs_io_request *netfs_begin_writethrough(struct kiocb *iocb, size_t len)
-{
-	struct netfs_io_request *wreq = NULL;
-	struct netfs_inode *ictx = netfs_inode(file_inode(iocb->ki_filp));
-
-	netfs_wb_begin(ictx, false);
-
-	wreq = netfs_create_write_req(iocb->ki_filp->f_mapping, iocb->ki_filp,
-				      iocb->ki_pos, NETFS_WRITETHROUGH);
-	if (IS_ERR(wreq)) {
-		netfs_wb_end(ictx);
-		return wreq;
-	}
-
-	wreq->io_streams[0].avail = true;
-	__set_bit(NETFS_RREQ_OFFLOAD_COLLECTION, &wreq->flags);
-	trace_netfs_write(wreq, netfs_write_trace_writethrough);
-	return wreq;
-}
-
-/*
- * Advance the state of the write operation used when writing through the
- * pagecache.  Data has been copied into the pagecache that we need to append
- * to the request.  If we've added more than wsize then we need to create a new
- * subrequest.
- */
-int netfs_advance_writethrough(struct netfs_io_request *wreq, struct writeback_control *wbc,
-			       struct folio *folio, size_t copied, bool to_page_end,
-			       struct folio **writethrough_cache)
-{
-	int ret;
-
-	_enter("R=%x ic=%zu ws=%u cp=%zu tp=%u",
-	       wreq->debug_id, wreq->buffer.iter.count, wreq->wsize, copied, to_page_end);
-
-	/* The folio is locked. */
-
-	if (*writethrough_cache != folio) {
-		if (*writethrough_cache) {
-			/* Did the folio get moved? */
-			folio_put(*writethrough_cache);
-			*writethrough_cache = NULL;
-		}
-		/* We can make multiple writes to the folio... */
-		if (wreq->len == 0)
-			trace_netfs_folio(folio, netfs_folio_trace_wthru);
-		else
-			trace_netfs_folio(folio, netfs_folio_trace_wthru_plus);
-		*writethrough_cache = folio;
-		folio_get(folio);
-	}
-
-	wreq->len += copied;
-
-	if (!to_page_end) {
-		folio_mark_dirty(folio);
-		folio_unlock(folio);
-		return 0;
-	}
-
-	ret = netfs_write_folio(wreq, wbc, folio);
-	folio_put(*writethrough_cache);
-	*writethrough_cache = NULL;
-	wreq->submitted = wreq->len;
-	return ret;
-}
-
-/*
- * End a write operation used when writing through the pagecache.
- */
-ssize_t netfs_end_writethrough(struct netfs_io_request *wreq, struct writeback_control *wbc,
-			       struct folio *writethrough_cache)
-{
-	ssize_t ret;
-
-	_enter("R=%x", wreq->debug_id);
-
-	if (writethrough_cache) {
-		folio_lock(writethrough_cache);
-		netfs_write_folio(wreq, wbc, writethrough_cache);
-		folio_put(writethrough_cache);
-		wreq->submitted = wreq->len;
-	}
-
-	netfs_end_issue_write(wreq);
-
-	if (wreq->iocb)
-		ret = -EIOCBQUEUED;
-	else
-		ret = netfs_wait_for_write(wreq);
-	netfs_put_request(wreq, netfs_rreq_trace_put_return);
-	return ret;
-}
-
 /**
  * netfs_writeback_single - Write back a monolithic payload
  * @mapping: The mapping to write from
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 7d8a08baf093..558e03e0d07a 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -209,7 +209,6 @@ enum netfs_io_origin {
 	NETFS_DIO_READ,			/* This is a direct I/O read */
 	NETFS_WRITEBACK,		/* This write was triggered by writepages */
 	NETFS_WRITEBACK_SINGLE,		/* This monolithic write was triggered by writepages */
-	NETFS_WRITETHROUGH,		/* This write was made by netfs_perform_write() */
 	NETFS_UNBUFFERED_WRITE,		/* This is an unbuffered write */
 	NETFS_DIO_WRITE,		/* This is a direct I/O write */
 	NETFS_PGPRIV2_COPY_TO_CACHE,	/* [DEPRECATED] This is writing read data to the cache */
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index 756b8bf52ff7..1c99fa753fe8 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -30,8 +30,7 @@
 	EM(netfs_write_trace_dio_write,		"DIO-WRITE")	\
 	EM(netfs_write_trace_unbuffered_write,	"UNB-WRITE")	\
 	EM(netfs_write_trace_writeback,		"WRITEBACK")	\
-	EM(netfs_write_trace_writeback_single,	"WB-SINGLE") \
-	E_(netfs_write_trace_writethrough,	"WRITETHRU")
+	E_(netfs_write_trace_writeback_single,	"WB-SINGLE")
 
 #define netfs_rreq_origins					\
 	EM(NETFS_READAHEAD,			"RA")		\
@@ -43,7 +42,6 @@
 	EM(NETFS_DIO_READ,			"DR")		\
 	EM(NETFS_WRITEBACK,			"WB")		\
 	EM(NETFS_WRITEBACK_SINGLE,		"W1")		\
-	EM(NETFS_WRITETHROUGH,			"WT")		\
 	EM(NETFS_UNBUFFERED_WRITE,		"UW")		\
 	EM(NETFS_DIO_WRITE,			"DW")		\
 	E_(NETFS_PGPRIV2_COPY_TO_CACHE,		"2C")
@@ -223,9 +221,7 @@
 	EM(netfs_folio_trace_sched_copy,	"sched-copy")	\
 	EM(netfs_folio_trace_store,		"store")	\
 	EM(netfs_folio_trace_store_copy,	"store-copy")	\
-	EM(netfs_folio_trace_store_plus,	"store+")	\
-	EM(netfs_folio_trace_wthru,		"wthru")	\
-	E_(netfs_folio_trace_wthru_plus,	"wthru+")
+	E_(netfs_folio_trace_store_plus,	"store+")
 
 #define netfs_collect_contig_traces				\
 	EM(netfs_contig_trace_collect,		"Collect")	\

