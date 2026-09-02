Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77137383985
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:35:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370531; cv=none; b=DTZQjjlwY01AyKjJWoCk02sQbXfBxE98QHIMs7hl3de0cZpXgZy5Jn5OMKgfqkrGiSgsfMs9uuBWyzHlwrL1xnrK63a++j6ndTTablqgT1UOlaSOHfuj437fFFl/QdUfIxWsN7jG0wkqyUYfnk7yXbcwMXi9008M78yLXYk4apw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370531; c=relaxed/simple;
	bh=9pYp6kLpCaTlW/semM7hDUQf5J5kbzqiSxyWt0SHbSg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gJqm5yHS+FkvLHTXGhkYhh1/kVmtFTkGHMLuE13KqJFoXePG76WjKXJyN8a5tH0azYXx25i8IsZuZ+ryazymJectVuznE5eBEfVLyzUB3SyUIN7BRQqI+jWmNwIgHVxFNw0yURfxtEtAmSa/tdFtk+2WicFOjUUBofocYJOLMmo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=QLEOZnjP; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="QLEOZnjP"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370528;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=3V3OD3nT0V6U72OmpSYHtRK3iKHj2x5V79xiNQUQCgQ=;
	b=QLEOZnjPI0icP49Rdr3NP7aVfcyMLAyVO9hiiICAevOXOcE7r9nbyui5wBXc093QJ09oUU
	OFIP6GZ4JPd19n0CO7u2Nx7yBbNox5RyjCTc5EJH+m0drtcg1+UDdr3MbI78mT1xpOt0wz
	xJr3EMqU4u6DYIpyp0V1DdC59LxYAsM=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-671-9e5O7xjaN3ySDs1lrB8c3g-1; Wed,
 02 Sep 2026 13:35:23 -0400
X-MC-Unique: 9e5O7xjaN3ySDs1lrB8c3g-1
X-Mimecast-MFC-AGG-ID: 9e5O7xjaN3ySDs1lrB8c3g_1788370520
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 29DD0192DD6D;
	Wed,  2 Sep 2026 17:35:20 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id EF17B1800643;
	Wed,  2 Sep 2026 17:35:13 +0000 (UTC)
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
Subject: [PATCH v11 09/36] netfs: Make mempool available for bvecq
Date: Wed,  2 Sep 2026 18:33:21 +0100
Message-ID: <20260902173350.3468672-10-dhowells@redhat.com>
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

Make a mempool available for allocating bvecq structs.  Use it
automatically if anything other than GFP_KERNEL (with GFP_ZONEMASK flags
masked off) is specified.  Reading from a file can use GFP_KERNEL as the
failure mode is straightforward and the same for DIO reads and writes.
When it comes to writeback, however, the writeback_iter() API does not
permit temporary failure, including ENOMEM, if WB_SYNC_ALL is set and the
caller must process all folios to completion.  (I'm not sure if EINTR
constitutes an acceptable failure).

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/bvecq.c      | 39 +++++++++++++++++++++++++++++++++------
 fs/netfs/internal.h   |  1 +
 fs/netfs/main.c       |  7 +++++++
 include/linux/bvecq.h |  3 +++
 4 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/fs/netfs/bvecq.c b/fs/netfs/bvecq.c
index 6905c84ea351..7b0aedafeda9 100644
--- a/fs/netfs/bvecq.c
+++ b/fs/netfs/bvecq.c
@@ -44,8 +44,9 @@ EXPORT_SYMBOL(bvecq_dump);
  *
  * Allocate a single bvecq node and initialise the header.  A number of inline
  * slots are also allocated, rounded up to fit after the header in a power-of-2
- * slab object of up to 512 bytes (up to 29 slots on a 64-bit cpu).  The slot
- * array is not initialised.
+ * slab object of up to 512 bytes (up to 29 slots on a 64-bit cpu).  The caller
+ * should be aware that the number of slots allocated may be more or less than
+ * the number requested.  The slot array is not initialised.
  *
  * Return: The node pointer or NULL on allocation failure.
  */
@@ -56,16 +57,39 @@ struct bvecq *bvecq_alloc_one(size_t nr_slots, gfp_t gfp, bool for_writeback)
 	const size_t max_slots = (max_size - sizeof(*bq)) / sizeof(bq->__bv[0]);
 	size_t part = min(nr_slots, max_slots);
 	size_t size = roundup_pow_of_two(struct_size(bq, __bv, part));
+	bool from_pool = false;
 
-	bq = kmalloc(size, gfp & ~GFP_ZONEMASK);
-	if (!bq)
-		return bq;
+	gfp &= ~(GFP_ZONEMASK | __GFP_THISNODE);
+
+	if (for_writeback) {
+		if (size != BVECQ_STD_SIZE) {
+			gfp_t gfp_temp = gfp;
 
+			gfp_temp |= __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN;
+			gfp_temp &= ~(__GFP_DIRECT_RECLAIM | __GFP_IO);
+			bq = kmalloc(size, gfp_temp);
+			if (bq)
+				goto success;
+		}
+
+		bq = mempool_alloc(&netfs_bvecq_pool, gfp);
+		if (!bq)
+			return bq;
+		from_pool = true;
+		size = BVECQ_STD_SIZE;
+	} else {
+		bq = kmalloc(size, gfp);
+		if (!bq)
+			return bq;
+	}
+
+success:
 	*bq = (struct bvecq) {
 		.ref		= REFCOUNT_INIT(1),
 		.bv		= bq->__bv,
 		.inline_bv	= true,
 		.max_slots	= (size - sizeof(*bq)) / sizeof(bq->__bv[0]),
+		.from_pool	= from_pool,
 	};
 	netfs_stat(&netfs_n_bvecq);
 	return bq;
@@ -245,7 +269,10 @@ void bvecq_put(struct bvecq *bq)
 			bvecq_free_slot(bq, slot);
 		next = bq->next;
 		netfs_stat_d(&netfs_n_bvecq);
-		kfree(bq);
+		if (bq->from_pool)
+			mempool_free(bq, &netfs_bvecq_pool);
+		else
+			kfree(bq);
 	}
 }
 EXPORT_SYMBOL(bvecq_put);
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index ef08f0096192..6d40a69e032f 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -43,6 +43,7 @@ extern struct list_head netfs_io_requests;
 extern spinlock_t netfs_proc_lock;
 extern mempool_t netfs_request_pool;
 extern mempool_t netfs_subrequest_pool;
+extern mempool_t netfs_bvecq_pool;
 extern mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 927badf3989d..9f72e5054aff 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -28,6 +28,7 @@ static struct kmem_cache *netfs_request_slab;
 static struct kmem_cache *netfs_subrequest_slab;
 mempool_t netfs_request_pool;
 mempool_t netfs_subrequest_pool;
+mempool_t netfs_bvecq_pool;
 mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
@@ -112,6 +113,9 @@ static int __init netfs_init(void)
 	if (mempool_init_kmalloc_pool(&netfs_folioq_pool, 100, sizeof(struct folio_queue)) < 0)
 		goto error_folioq_pool;
 
+	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool, 100, BVECQ_STD_SIZE) < 0)
+		goto error_bvecq_pool;
+
 	netfs_request_slab = kmem_cache_create("netfs_request",
 					       sizeof(struct netfs_io_request), 0,
 					       SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT,
@@ -164,6 +168,8 @@ static int __init netfs_init(void)
 error_reqpool:
 	kmem_cache_destroy(netfs_request_slab);
 error_req:
+	mempool_exit(&netfs_bvecq_pool);
+error_bvecq_pool:
 	mempool_exit(&netfs_folioq_pool);
 error_folioq_pool:
 	return ret;
@@ -178,6 +184,7 @@ static void __exit netfs_exit(void)
 	kmem_cache_destroy(netfs_subrequest_slab);
 	mempool_exit(&netfs_request_pool);
 	kmem_cache_destroy(netfs_request_slab);
+	mempool_exit(&netfs_bvecq_pool);
 	mempool_exit(&netfs_folioq_pool);
 }
 module_exit(netfs_exit);
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
index 22fc7995f3ee..8adfdd43b865 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -43,15 +43,18 @@ struct bvecq {
 	u16		max_slots;	/* Number of elements allocated in bv[] */
 	enum bvecq_mem	mem_type:3;	/* What sort of memory and how to free it */
 	bool		inline_bv:1;	/* T if __bv[] is being used */
+	bool		from_pool:1;	/* T if bvecq from mempool */
 	struct bio_vec	*bv;		/* Pointer to array of page fragments */
 	struct bio_vec	__bv[];		/* Default array (if ->inline_bv) */
 };
 
 #if BITS_PER_LONG == 64
 /* Number of slots in __bv[] for a bvecq in a 512-byte kmalloc block. */
+#define BVECQ_STD_SIZE		512
 #define BVECQ_STD_SLOTS		29	/* 2 words/slot; 32 slots; bvecq is 6 words (3 slots) */
 #elif  BITS_PER_LONG == 32
 /* Number of slots in __bv[] for a bvecq in a 256-byte kmalloc block. */
+#define BVECQ_STD_SIZE		256
 #define BVECQ_STD_SLOTS		18	/* 3 words/slot; 21 slots; bvecq is 9 words (3 slots) */
 #else
 #error BVECQ_STD_SLOTS undetermined

