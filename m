Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E3F64AF671
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:37:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370674; cv=none; b=EAAnNwUUjm1iN+eK6CkAWo3YAsy0e/ugL7hgDZMWdbtnWDV7lbDzXRl7yYL0fWEwaHhFE8WjtuSFfd8FrYHd0tMGbr1WdFA4OxFfPHyQjfTVe5bNjWvAzmnJFLcuAS4j1eIhDQl+fzs1ZNOSrcumkGiEkw4VoyL265RxpooFNhg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370674; c=relaxed/simple;
	bh=FUXaauPXtPuCb80+1ZtU/FMli7cv5Et7C88hQgryohQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IdydEA+0B4kJxi5OlrCxNll/rKheqmWVqQ4DZ2RrLpcdwcT13yMqxLMH720TbGfAWXqWMGtG6m1929ffe9aQLiHiROavK9hUSLzJ3KWmgQDA9y5RNQ8Uz4sDhOdIaaUlu+I2bMWUTxpa8HrWZShLiy3Te8W29hHJnw2bxSIGnsM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Thw0wV2M; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Thw0wV2M"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370667;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=OWo8c6WjqRImiYHeCnsCZom5HLYQsCVqoMX/bWd/beo=;
	b=Thw0wV2MwsBwQ6tosQpsgXi6+jnTn7iG7z0mqHwj8/Wz+mHVZETIJDEbMIFnCUXy5zrVzt
	3PJyim/qXoGthR2Ff+jW4L5JayjJQACYEIHlMlQAyf6x3p/Uah5WNDICPI15GD4yKz/9wp
	SislGJWRUILAf8foVFufVEj0HlxOo1Q=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-655-IFXODkQnOYWNFvY8KjLEEw-1; Wed,
 02 Sep 2026 13:37:43 -0400
X-MC-Unique: IFXODkQnOYWNFvY8KjLEEw-1
X-Mimecast-MFC-AGG-ID: IFXODkQnOYWNFvY8KjLEEw_1788370661
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E7108195DE46;
	Wed,  2 Sep 2026 17:37:40 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 10CF118005BA;
	Wed,  2 Sep 2026 17:37:34 +0000 (UTC)
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
Subject: [PATCH v11 27/36] netfs: Build a list of regions undergoing writeback
Date: Wed,  2 Sep 2026 18:33:39 +0100
Message-ID: <20260902173350.3468672-28-dhowells@redhat.com>
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

Build a linked list of the regions of file position that are involved in a
writeback whilst processing the folios to be written back.  These will be
used in a subsequent patch to work out which folios need unlocking rather
than walking the bvecq list of folios.

This will mean that the folio list need not be maintained as a single list
of folios, but can instead be made into multiple lists and have various
roundings applied to it - and can be ignored by the collector, except when
various pins are pulled out of it by subrequest cleanup.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/internal.h    |  1 +
 fs/netfs/main.c        |  7 +++++++
 fs/netfs/objects.c     |  7 +++++++
 fs/netfs/write_issue.c | 20 ++++++++++++++++++++
 include/linux/netfs.h  | 12 ++++++++++++
 5 files changed, 47 insertions(+)

diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index 8d91748ae257..e6e768ad9648 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -44,6 +44,7 @@ extern struct list_head netfs_io_requests;
 extern spinlock_t netfs_proc_lock;
 extern mempool_t netfs_request_pool;
 extern mempool_t netfs_subrequest_pool;
+extern mempool_t netfs_writeback_pool;
 extern mempool_t netfs_bvecq_pool;
 
 #ifdef CONFIG_PROC_FS
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 5d8b87f71888..b8da5e85cc67 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -28,6 +28,7 @@ static struct kmem_cache *netfs_request_slab;
 static struct kmem_cache *netfs_subrequest_slab;
 mempool_t netfs_request_pool;
 mempool_t netfs_subrequest_pool;
+mempool_t netfs_writeback_pool;
 mempool_t netfs_bvecq_pool;
 
 #ifdef CONFIG_PROC_FS
@@ -110,6 +111,9 @@ static int __init netfs_init(void)
 
 	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool, 100, BVECQ_STD_SIZE) < 0)
 		goto error_bvecq_pool;
+	if (mempool_init_kmalloc_pool(&netfs_writeback_pool, 100,
+				      sizeof(struct netfs_writeback)) < 0)
+		goto error_writeback_pool;
 
 	netfs_request_slab = kmem_cache_create("netfs_request",
 					       sizeof(struct netfs_io_request), 0,
@@ -163,6 +167,8 @@ static int __init netfs_init(void)
 error_reqpool:
 	kmem_cache_destroy(netfs_request_slab);
 error_req:
+	mempool_exit(&netfs_writeback_pool);
+error_writeback_pool:
 	mempool_exit(&netfs_bvecq_pool);
 error_bvecq_pool:
 	return ret;
@@ -177,6 +183,7 @@ static void __exit netfs_exit(void)
 	kmem_cache_destroy(netfs_subrequest_slab);
 	mempool_exit(&netfs_request_pool);
 	kmem_cache_destroy(netfs_request_slab);
+	mempool_exit(&netfs_writeback_pool);
 	mempool_exit(&netfs_bvecq_pool);
 }
 module_exit(netfs_exit);
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 740971955198..763be168d6b1 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -151,6 +151,13 @@ static void netfs_deinit_request(struct netfs_io_request *rreq)
 	bvecq_pos_unset(&rreq->dispatch_cursor);
 	bvecq_pos_unset(&rreq->collect_cursor);
 	bvecq_put(rreq->spare);
+	while (rreq->writebacks) {
+		struct netfs_writeback *wback = rreq->writebacks;
+
+		rreq->writebacks = wback->next;
+		mempool_free(wback, &netfs_bvecq_pool);
+		
+	}
 
 	if (atomic_dec_and_test(&ictx->io_count))
 		wake_up_var(&ictx->io_count);
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 60a417026e10..ace790b127ca 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -335,6 +335,7 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	struct netfs_io_stream *upload = &wreq->io_streams[0];
 	struct netfs_io_stream *cache  = &wreq->io_streams[1];
 	struct netfs_io_stream *stream;
+	struct netfs_writeback *wback;
 	struct netfs_group *fgroup; /* TODO: Use this with ceph */
 	struct netfs_folio *finfo;
 	struct bvecq *queue = wreq->load_cursor.bvecq;
@@ -433,6 +434,25 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	folio_start_writeback(folio);
 	folio_unlock(folio);
 
+	/* Keep track of what we will need to unlock. */
+	wback = wreq->writebacks_tail;
+	if (!wback || fpos != wback->start + wback->len || wback->len > LONG_MAX) {
+		wback = mempool_alloc(&netfs_writeback_pool, wreq->gfp);
+		wback->next = NULL;
+		wback->start = fpos;
+		wback->len = fsize;
+
+		if (wreq->writebacks)
+			/* Order write of next after last write of len in old tail. */
+			smp_store_release(&wreq->writebacks_tail->next, wback);
+		else
+			wreq->writebacks = wback;
+		wreq->writebacks_tail = wback;
+	} else {
+		/* Order update of len after setting pointer. */
+		smp_store_release(&wback->len, wback->len + fsize);
+	}
+ 
 	if (fgroup == NETFS_FOLIO_COPY_TO_CACHE) {
 		if (!cache->avail) {
 			trace_netfs_folio(folio, netfs_folio_trace_cancel_copy);
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 8d5f548a77c3..70eb32f073f8 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -134,6 +134,16 @@ enum netfs_cache_collect {
 	NETFS_CACHE_COLLECT_WRITE_CANCEL,	/* Currently collecting cancelled writes */
 };
 
+/*
+ * Record of a contiguous region undergoing writeback.  The tail region (ie. if
+ * next is NULL) may be extended dynamically.
+ */
+struct netfs_writeback {
+	struct netfs_writeback	*next;		/* Next extent in list */
+	uoff_t			start;		/* Start position */
+	size_t			len;		/* Total size (can increase) */
+};
+
 /*
  * Stream of I/O subrequests going to a particular destination, such as the
  * server or the local cache.  This is mainly intended for writing where we may
@@ -249,6 +259,8 @@ struct netfs_io_request {
 #endif
 	struct netfs_io_stream	io_streams[2];	/* Streams of parallel I/O operations */
 #define NR_IO_STREAMS 2 //wreq->nr_io_streams
+	struct netfs_writeback	*writebacks;	/* List of regions undergoing writeback */
+	struct netfs_writeback	*writebacks_tail; /* Tail of region list */
 	struct netfs_group	*group;		/* Writeback group being written back */
 	struct bvecq		*spare;		/* Advance allocation of bvecq */
 	struct bvecq_pos	load_cursor;	/* Point at which new folios are loaded in */

