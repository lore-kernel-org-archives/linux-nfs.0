Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5115A4B514D
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 14:21:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791382890; cv=none; b=AuafecFT0V1vsSMFRJgcAgmlcYfImDCBTCvmtYHk5Ct0PYQFivRIBZIGayy7f7uZpXImliukW93XKqkUrpjbTQ3r43c2/M1PqynZmyrcyyFXcG8OEHZzIodh1dEW7IiT0Gbhq9d0XmK5vTrlJACetOV6y1GezTiXHa+vghkteGM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791382890; c=relaxed/simple;
	bh=sPtZ+yN9shpCVoqwt2RXAJS/54SQGRz1fY5Q7nGZQrk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dx6CMct4g0avZmCuJtoOWurSdDtyRdsfXWCH+lIXKKnEn4aDEHMSwnAvhpqNJb7FNTKDaq340zFncpkM0Fws5Yg1n34Ui5QwIk8fEd82y1GHkngodTKVqBKYb0eTtj7SBnuWEMBOyejFgNfrdYqnP01/dt9Sko28lbdepdAwhMc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=fjJrQyPk; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="fjJrQyPk"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791382881;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=jMN0IlS8EIrypli+QxcpLH63aFUppXF0So/Ub+VN9hg=;
	b=fjJrQyPk+AaR7zcBogdzEVA2fWrGAhig5+bbR5tRoXJjCLH9QM0qS0e5Dd/nBsY+LloTP9
	VMBe/sbDSDtmscMjKpAT9NsqdI5Zz1vfO/rST4KiB4TMaazp4p8eWq8TtYZO7PhGcCcRDE
	O97I2CbLOOMUzviXSSXL0rj7MQY5FRE=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-523-JUdW85LdN5uvpdLKqSZ_xQ-1; Wed,
 07 Oct 2026 10:21:16 -0400
X-MC-Unique: JUdW85LdN5uvpdLKqSZ_xQ-1
X-Mimecast-MFC-AGG-ID: JUdW85LdN5uvpdLKqSZ_xQ_1791382873
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id BE52B1904AAF;
	Wed,  7 Oct 2026 14:20:38 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id EC6BB180061C;
	Wed,  7 Oct 2026 14:20:29 +0000 (UTC)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH v14 3/8] netfs: Make unbuffered/DIO read and write use bvecq
Date: Wed,  7 Oct 2026 15:19:54 +0100
Message-ID: <20261007142001.851620-4-dhowells@redhat.com>
In-Reply-To: <20261007142001.851620-1-dhowells@redhat.com>
References: <20261007142001.851620-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Make unbuffered and DIO read and write in netfslib use bvecq.  The idea is
to only use bvecq in talking to the filesystem and not pass iterators at
all as the filesystem may just end up extracting them.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/direct_read.c  | 31 +++++++++++++------------------
 fs/netfs/direct_write.c | 33 ++++++++++++++-------------------
 fs/netfs/objects.c      | 11 +----------
 fs/netfs/read_collect.c | 17 +++++++++++------
 include/linux/netfs.h   |  4 +---
 5 files changed, 40 insertions(+), 56 deletions(-)

diff --git a/fs/netfs/direct_read.c b/fs/netfs/direct_read.c
index 8c15f3079723..2b8eeb2d3c06 100644
--- a/fs/netfs/direct_read.c
+++ b/fs/netfs/direct_read.c
@@ -177,25 +177,20 @@ ssize_t netfs_unbuffered_read_iter_locked(struct kiocb *iocb, struct iov_iter *i
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
+				 &rreq->direct_bq, 0, rreq->gfp);
+	if (ret < 0)
+		goto error_put;
+
+	rreq->len = ret;
+
+	iov_iter_bvec_queue(&rreq->buffer.iter, ITER_DEST, rreq->direct_bq,
+			    0, 0, rreq->len);
 
 	// TODO: Set up bounce buffer if needed
 
diff --git a/fs/netfs/direct_write.c b/fs/netfs/direct_write.c
index cc46b7d9321f..b3ec1900d7a4 100644
--- a/fs/netfs/direct_write.c
+++ b/fs/netfs/direct_write.c
@@ -222,10 +222,10 @@ static void netfs_unbuffered_write_async(struct work_struct *work)
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
@@ -261,25 +261,20 @@ ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *
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
+		ssize_t n = netfs_extract_iter(iter, len, INT_MAX,
+					       &wreq->direct_bq, 0, wreq->gfp);
+
+		if (n < 0) {
+			ret = n;
+			goto error_put;
 		}
+		wreq->len = n;
+		_debug("dio-write %zx/%zx %u/%u",
+		       n, len, wreq->direct_bq->nr_slots,
+		       wreq->direct_bq->max_slots);
 
-		wreq->len = iov_iter_count(&wreq->buffer.iter);
+		iov_iter_bvec_queue(&wreq->buffer.iter, ITER_SOURCE,
+				    wreq->direct_bq, 0, 0, wreq->len);
 	}
 
 	__set_bit(NETFS_RREQ_USE_IO_ITER, &wreq->flags);
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 4b8d20559b0e..f8a5b6a7a2a9 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -133,7 +133,6 @@ static void netfs_free_request_rcu(struct rcu_head *rcu)
 static void netfs_deinit_request(struct netfs_io_request *rreq)
 {
 	struct netfs_inode *ictx = netfs_inode(rreq->inode);
-	unsigned int i;
 
 	trace_netfs_rreq(rreq, netfs_rreq_trace_free);
 
@@ -148,15 +147,7 @@ static void netfs_deinit_request(struct netfs_io_request *rreq)
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
+	bvecq_put(rreq->direct_bq);
 	rolling_buffer_clear(&rreq->buffer);
 
 	if (atomic_dec_and_test(&ictx->io_count))
diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index 75c8874ec459..ab2f208cc8f9 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -422,12 +422,17 @@ static void netfs_rreq_assess_dio(struct netfs_io_request *rreq)
 
 	if (rreq->origin == NETFS_UNBUFFERED_READ ||
 	    rreq->origin == NETFS_DIO_READ) {
-		for (i = 0; i < rreq->direct_bv_count; i++) {
-			flush_dcache_page(rreq->direct_bv[i].bv_page);
-			// TODO: cifs marks pages in the destination buffer
-			// dirty under some circumstances after a read.  Do we
-			// need to do that too?
-			set_page_dirty(rreq->direct_bv[i].bv_page);
+		for (struct bvecq *bq = rreq->direct_bq; bq; bq = bvecq_next(bq)) {
+			unsigned int nr_slots = bvecq_nr_slots_acquire(bq);
+			/* Read the slot count before the slots. */
+
+			/* Mark the target buffers dirty. */
+			for (i = 0; i < nr_slots; i++) {
+				flush_dcache_page(bq->bv[i].bv_page);
+				if (bq->mem_type == BVECQ_MEM_GUP ||
+				    bq->mem_type == BVECQ_MEM_PAGECACHE)
+					set_page_dirty(bq->bv[i].bv_page);
+			}
 		}
 	}
 
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index aca192bc5675..aa305fe2d4e1 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -251,7 +251,7 @@ struct netfs_io_request {
 	wait_queue_head_t	waitq;		/* Processor waiter */
 	void			*netfs_priv;	/* Private data for the netfs */
 	void			*netfs_priv2;	/* Private data for the netfs */
-	struct bio_vec		*direct_bv;	/* DIO buffer list (when handling iovec-iter) */
+	struct bvecq		*direct_bq;	/* DIO buffer list (when handling iovec-iter) */
 	uoff_t			submitted;	/* Amount submitted for I/O so far */
 	uoff_t			len;		/* Length of the request */
 	size_t			transferred;	/* Amount to be indicated as transferred */
@@ -266,7 +266,6 @@ struct netfs_io_request {
 	uoff_t			abandon_to;	/* Position to abandon folios to */
 	const struct folio	*no_unlock_folio; /* Don't unlock this folio after read */
 	gfp_t			gfp;		/* GFP flags to use */
-	unsigned int		direct_bv_count; /* Number of elements in direct_bv[] */
 	unsigned int		debug_id;
 	unsigned int		rsize;		/* Maximum read size (0 for none) */
 	unsigned int		wsize;		/* Maximum write size (0 for none) */
@@ -274,7 +273,6 @@ struct netfs_io_request {
 	unsigned int		nr_group_rel;	/* Number of refs to release on ->group */
 	spinlock_t		lock;		/* Lock for queuing subreqs */
 	enum netfs_io_origin	origin;		/* Origin of the request */
-	bool			direct_bv_unpin; /* T if direct_bv[] must be unpinned */
 	refcount_t		ref;
 	unsigned long		flags;
 #define NETFS_RREQ_IN_PROGRESS		0	/* Unlocked when the request completes (has ref) */

