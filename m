Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2718E4E0B6F
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 12:53:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790772829; cv=none; b=bKy2B2PyX+gEYPi8uMR+WFPydrmYebuFFmw1Gp/9iIS7Sb8rgaSzjQiH/51ZJgOCGb12m8sw0EkmTiT8EmU0+B2sT9fIFikyT5eg0jlJk0RIJjIr60McwAPyaTzys9cX4yidk1oQBDH90aMV/ywLQSo9urx7G4Xt+RFj2m3yMM4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790772829; c=relaxed/simple;
	bh=tFtLZsaJPE8sqJ2COOwrK1bH6sL6xNDRGSOFVQQ9qbw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=B/VS8oX1ooNEZfLITAgJgYN3QdXQInO8oi/JvHjZZtKWOEyH2Y4ZxrGb8bgNK771BBS0wF2/KmZDr4QSbp2SX5KdssixT15gJQtFDgaAwjgLKi/dY+2b+Ut6pYZ5cVD+BtKBnleRpPKiq+/tx+g2IVXq+wHGICwTqC3QRX2JCzw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=h1ywXphu; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="h1ywXphu"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790772815;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=iIxh6oa1t+ivZmVm1C0ZH815pPFlipZpptfIulMQEMQ=;
	b=h1ywXphuh+zqwWs5cZk15LJn2VABWimIvWwadJnju5EdHEGpm/2Ksrx+E/cdTGt7XtwZYN
	bkKnviv5H9I1YiBaSwQT0CnEE07ERxpvIZtw7T9lj8ogA1KtIEWa5bvnJtkrjYC1aq3izY
	RdaLW2jpqj8IyQQhXn9ZsTIYedsdEqA=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-655-7AqjPE93M2SichTlcouhQw-1; Wed,
 30 Sep 2026 08:53:32 -0400
X-MC-Unique: 7AqjPE93M2SichTlcouhQw-1
X-Mimecast-MFC-AGG-ID: 7AqjPE93M2SichTlcouhQw_1790772809
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id BF6CE186FBA2;
	Wed, 30 Sep 2026 12:53:29 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 61C861800361;
	Wed, 30 Sep 2026 12:53:23 +0000 (UTC)
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
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v14 04/10] afs: Use a bvecq to hold dir content rather than folioq
Date: Wed, 30 Sep 2026 13:52:39 +0100
Message-ID: <20260930125247.3232130-5-dhowells@redhat.com>
In-Reply-To: <20260930125247.3232130-1-dhowells@redhat.com>
References: <20260930125247.3232130-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Use a bvecq to hold the contents of a directory rather than the folioq so
that the latter can be phased out.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-afs@lists.infradead.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/afs/dir.c           |  36 ++++-----
 fs/afs/dir_edit.c      |  43 +++++------
 fs/afs/dir_search.c    |  33 ++++-----
 fs/afs/inode.c         |   2 +-
 fs/afs/internal.h      |   6 +-
 fs/afs/symlink.c       |  38 +++++-----
 fs/netfs/write_issue.c | 165 ++++++-----------------------------------
 7 files changed, 99 insertions(+), 224 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 2db534a2c7cc..5fac02d2d281 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -140,9 +140,9 @@ static void afs_dir_dump(struct afs_vnode *dvnode)
 	pr_warn("DIR %llx:%llx is=%llx\n",
 		dvnode->fid.vid, dvnode->fid.vnode, i_size);
 
-	iov_iter_folio_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0, i_size);
-	iterate_folioq(&iter, iov_iter_count(&iter), NULL, NULL,
-		       afs_dir_dump_step);
+	iov_iter_bvec_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0, i_size);
+	iterate_bvecq(&iter, iov_iter_count(&iter), NULL, NULL,
+		      afs_dir_dump_step);
 }
 
 /*
@@ -203,9 +203,9 @@ static int afs_dir_check(struct afs_vnode *dvnode)
 	if (unlikely(!i_size))
 		return 0;
 
-	iov_iter_folio_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0, i_size);
-	checked = iterate_folioq(&iter, iov_iter_count(&iter), dvnode, NULL,
-				 afs_dir_check_step);
+	iov_iter_bvec_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0, i_size);
+	checked = iterate_bvecq(&iter, iov_iter_count(&iter), dvnode, NULL,
+				afs_dir_check_step);
 	if (checked != i_size) {
 		afs_dir_dump(dvnode);
 		return -EIO;
@@ -250,15 +250,15 @@ static ssize_t afs_do_read_single(struct afs_vnode *dvnode, struct file *file)
 	if (dvnode->directory_size < i_size) {
 		size_t cur_size = dvnode->directory_size;
 
-		ret = netfs_alloc_folioq_buffer(NULL,
-						&dvnode->directory, &cur_size, i_size,
-						mapping_gfp_mask(dvnode->netfs.inode.i_mapping));
+		ret = bvecq_expand_buffer(&dvnode->directory, &cur_size,
+					  round_up(i_size, PAGE_SIZE),
+					  mapping_gfp_mask(dvnode->netfs.inode.i_mapping));
 		dvnode->directory_size = cur_size;
 		if (ret < 0)
 			return ret;
 	}
 
-	iov_iter_folio_queue(&iter, ITER_DEST, dvnode->directory, 0, 0, dvnode->directory_size);
+	iov_iter_bvec_queue(&iter, ITER_DEST, dvnode->directory, 0, 0, dvnode->directory_size);
 
 	/* AFS requires us to perform the read of a directory synchronously as
 	 * a single unit to avoid issues with the directory contents being
@@ -294,8 +294,8 @@ static ssize_t afs_read_single(struct afs_vnode *dvnode, struct file *file)
 }
 
 /*
- * Read the directory into a folio_queue buffer in one go, scrubbing the
- * previous contents.  We return -ESTALE if the caller needs to call us again.
+ * Read the directory into the buffer in one go, scrubbing the previous
+ * contents.  We return -ESTALE if the caller needs to call us again.
  */
 ssize_t afs_read_dir(struct afs_vnode *dvnode, struct file *file)
 	__acquires(&dvnode->validate_lock)
@@ -483,7 +483,7 @@ static size_t afs_dir_iterate_step(void *iter_base, size_t progress, size_t len,
 }
 
 /*
- * Iterate through the directory folios.
+ * Iterate through the directory content.
  */
 static int afs_dir_iterate_contents(struct inode *dir, struct dir_context *dir_ctx)
 {
@@ -498,11 +498,11 @@ static int afs_dir_iterate_contents(struct inode *dir, struct dir_context *dir_c
 	if (i_size <= 0 || dir_ctx->pos >= i_size)
 		return 0;
 
-	iov_iter_folio_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0, i_size);
+	iov_iter_bvec_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0, i_size);
 	iov_iter_advance(&iter, round_down(dir_ctx->pos, AFS_DIR_BLOCK_SIZE));
 
-	iterate_folioq(&iter, iov_iter_count(&iter), dvnode, &ctx,
-		       afs_dir_iterate_step);
+	iterate_bvecq(&iter, iov_iter_count(&iter), dvnode, &ctx,
+		      afs_dir_iterate_step);
 
 	if (ctx.error == -ESTALE)
 		afs_invalidate_dir(dvnode, afs_dir_invalid_iter_stale);
@@ -2228,8 +2228,8 @@ static int afs_dir_writepages(struct address_space *mapping,
 	}
 
 	if (test_bit(AFS_VNODE_DIR_VALID, &dvnode->flags)) {
-		iov_iter_folio_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0,
-				     i_size_read(&dvnode->netfs.inode));
+		iov_iter_bvec_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0,
+				    i_size_read(&dvnode->netfs.inode));
 		ret = netfs_writeback_single(mapping, wbc, &iter);
 		if (ret == 1)
 			ret = 0; /* Skipped write due to lock conflict. */
diff --git a/fs/afs/dir_edit.c b/fs/afs/dir_edit.c
index c31303059444..de53d7ff82c3 100644
--- a/fs/afs/dir_edit.c
+++ b/fs/afs/dir_edit.c
@@ -10,7 +10,6 @@
 #include <linux/namei.h>
 #include <linux/pagemap.h>
 #include <linux/iversion.h>
-#include <linux/folio_queue.h>
 #include "internal.h"
 #include "xdr_fs.h"
 
@@ -110,9 +109,8 @@ static void afs_clear_contig_bits(union afs_xdr_dir_block *block,
  */
 static union afs_xdr_dir_block *afs_dir_get_block(struct afs_dir_iter *iter, size_t block)
 {
-	struct folio_queue *fq;
 	struct afs_vnode *dvnode = iter->dvnode;
-	struct folio *folio;
+	struct bvecq *bq;
 	size_t blpos = block * AFS_DIR_BLOCK_SIZE;
 	size_t blend = (block + 1) * AFS_DIR_BLOCK_SIZE, fpos = iter->fpos;
 	int ret;
@@ -120,41 +118,38 @@ static union afs_xdr_dir_block *afs_dir_get_block(struct afs_dir_iter *iter, siz
 	if (dvnode->directory_size < blend) {
 		size_t cur_size = dvnode->directory_size;
 
-		ret = netfs_alloc_folioq_buffer(
-			NULL, &dvnode->directory, &cur_size, blend,
-			mapping_gfp_mask(dvnode->netfs.inode.i_mapping));
+		ret = bvecq_expand_buffer(&dvnode->directory, &cur_size, blend,
+					  mapping_gfp_mask(dvnode->netfs.inode.i_mapping));
 		dvnode->directory_size = cur_size;
 		if (ret < 0)
 			goto fail;
 	}
 
-	fq = iter->fq;
-	if (!fq)
-		fq = dvnode->directory;
+	bq = iter->bq;
+	if (!bq)
+		bq = dvnode->directory;
 
-	/* Search the folio queue for the folio containing the block... */
-	for (; fq; fq = fq->next) {
-		for (int s = iter->fq_slot; s < folioq_count(fq); s++) {
-			size_t fsize = folioq_folio_size(fq, s);
+	/* Search the contents for the region containing the block... */
+	for (; bq; bq = bq->next) {
+		for (int s = iter->bq_slot; s < bq->nr_slots; s++) {
+			struct bio_vec *bv = &bq->bv[s];
+			size_t bsize = bv->bv_len;
 
-			if (blend <= fpos + fsize) {
+			if (blend <= fpos + bsize) {
 				/* ... and then return the mapped block. */
-				folio = folioq_folio(fq, s);
-				if (WARN_ON_ONCE(folio_pos(folio) != fpos))
-					goto fail;
-				iter->fq = fq;
-				iter->fq_slot = s;
+				iter->bq = bq;
+				iter->bq_slot = s;
 				iter->fpos = fpos;
-				return kmap_local_folio(folio, blpos - fpos);
+				return bvec_kmap_partial(bv, blpos - fpos);
 			}
-			fpos += fsize;
+			fpos += bsize;
 		}
-		iter->fq_slot = 0;
+		iter->bq_slot = 0;
 	}
 
 fail:
-	iter->fq = NULL;
-	iter->fq_slot = 0;
+	iter->bq = NULL;
+	iter->bq_slot = 0;
 	afs_invalidate_dir(dvnode, afs_dir_invalid_edit_get_block);
 	return NULL;
 }
diff --git a/fs/afs/dir_search.c b/fs/afs/dir_search.c
index 11ebdfffcb1d..e1f91b3ac6e2 100644
--- a/fs/afs/dir_search.c
+++ b/fs/afs/dir_search.c
@@ -66,12 +66,11 @@ bool afs_dir_init_iter(struct afs_dir_iter *iter, const struct qstr *name)
  */
 union afs_xdr_dir_block *afs_dir_find_block(struct afs_dir_iter *iter, size_t block)
 {
-	struct folio_queue *fq = iter->fq;
 	struct afs_vnode *dvnode = iter->dvnode;
-	struct folio *folio;
+	struct bvecq *bq = iter->bq;
 	size_t blpos = block * AFS_DIR_BLOCK_SIZE;
 	size_t blend = (block + 1) * AFS_DIR_BLOCK_SIZE, fpos = iter->fpos;
-	int slot = iter->fq_slot;
+	int slot = iter->bq_slot;
 
 	_enter("%zx,%d", block, slot);
 
@@ -80,36 +79,34 @@ union afs_xdr_dir_block *afs_dir_find_block(struct afs_dir_iter *iter, size_t bl
 	if (dvnode->directory_size < blend)
 		goto fail;
 
-	if (!fq || blpos < fpos) {
-		fq = dvnode->directory;
+	if (!bq || blpos < fpos) {
+		bq = dvnode->directory;
 		slot = 0;
 		fpos = 0;
 	}
 
 	/* Search the folio queue for the folio containing the block... */
-	for (; fq; fq = fq->next) {
-		for (; slot < folioq_count(fq); slot++) {
-			size_t fsize = folioq_folio_size(fq, slot);
+	for (; bq; bq = bq->next) {
+		for (; slot < bq->nr_slots; slot++) {
+			struct bio_vec *bv = &bq->bv[slot];
+			size_t bsize = bv->bv_len;
 
-			if (blend <= fpos + fsize) {
+			if (blend <= fpos + bsize) {
 				/* ... and then return the mapped block. */
-				folio = folioq_folio(fq, slot);
-				if (WARN_ON_ONCE(folio_pos(folio) != fpos))
-					goto fail;
-				iter->fq = fq;
-				iter->fq_slot = slot;
+				iter->bq = bq;
+				iter->bq_slot = slot;
 				iter->fpos = fpos;
-				iter->block = kmap_local_folio(folio, blpos - fpos);
+				iter->block = bvec_kmap_partial(bv, blpos - fpos);
 				return iter->block;
 			}
-			fpos += fsize;
+			fpos += bsize;
 		}
 		slot = 0;
 	}
 
 fail:
-	iter->fq = NULL;
-	iter->fq_slot = 0;
+	iter->bq = NULL;
+	iter->bq_slot = 0;
 	afs_invalidate_dir(dvnode, afs_dir_invalid_edit_get_block);
 	return NULL;
 }
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 14f39a9bea6c..634fbf8eb212 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -683,7 +683,7 @@ void afs_evict_inode(struct inode *inode)
 	flush_delayed_work(&vnode->lock_work);
 	netfs_wait_for_outstanding_io(inode);
 	truncate_inode_pages_final(&inode->i_data);
-	netfs_free_folioq_buffer(vnode->directory);
+	bvecq_put(vnode->directory);
 	if (vnode->symlink)
 		afs_evict_symlink(vnode);
 
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index d58273c00fbc..51078cc9b0e5 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -710,7 +710,7 @@ struct afs_vnode {
 #define AFS_VNODE_MODIFYING	10		/* Set if we're performing a modification op */
 #define AFS_VNODE_DIR_READ	11		/* Set if we've read a dir's contents */
 
-	struct folio_queue	*directory;	/* Directory contents */
+	struct bvecq		*directory;	/* Directory contents */
 	struct afs_symlink __rcu *symlink;	/* Symlink content */
 	struct list_head	wb_keys;	/* List of keys available for writeback */
 	struct list_head	pending_locks;	/* locks waiting to be granted */
@@ -991,9 +991,9 @@ static inline void afs_invalidate_cache(struct afs_vnode *vnode, unsigned int fl
 struct afs_dir_iter {
 	struct afs_vnode	*dvnode;
 	union afs_xdr_dir_block *block;
-	struct folio_queue	*fq;
+	struct bvecq		*bq;
 	unsigned int		fpos;
-	int			fq_slot;
+	int			bq_slot;
 	unsigned int		loop_check;
 	u8			nr_slots;
 	u8			bucket;
diff --git a/fs/afs/symlink.c b/fs/afs/symlink.c
index 6b8c122877ca..9a611efe6b26 100644
--- a/fs/afs/symlink.c
+++ b/fs/afs/symlink.c
@@ -56,7 +56,6 @@ void afs_evict_symlink(struct afs_vnode *vnode)
 void afs_init_new_symlink(struct afs_vnode *vnode, struct afs_operation *op)
 {
 	struct afs_symlink *symlink = op->create.symlink;
-	size_t dsize = 0;
 	size_t size = strlen(symlink->content) + 1;
 	char *p;
 
@@ -66,13 +65,18 @@ void afs_init_new_symlink(struct afs_vnode *vnode, struct afs_operation *op)
 	if (!fscache_cookie_enabled(netfs_i_cookie(&vnode->netfs)))
 		return;
 
-	if (netfs_alloc_folioq_buffer(NULL, &vnode->directory, &dsize, size,
-				      mapping_gfp_mask(vnode->netfs.inode.i_mapping)) < 0)
+	vnode->directory =
+		bvecq_alloc_buffer(PAGE_SIZE,
+				   mapping_gfp_mask(vnode->netfs.inode.i_mapping),
+				   false);
+	if (!vnode->directory)
 		return;
 
-	vnode->directory_size = dsize;
-	p = kmap_local_folio(folioq_folio(vnode->directory, 0), 0);
+	vnode->directory_size = size;
+	p = bvec_kmap_partial(&vnode->directory->bv[0], 0);
 	memcpy(p, symlink->content, size);
+	if (size < PAGE_SIZE)
+		memset(p + size, 0, PAGE_SIZE - size);
 	kunmap_local(p);
 	netfs_single_mark_inode_dirty(&vnode->netfs.inode);
 }
@@ -94,17 +98,13 @@ static ssize_t afs_do_read_symlink(struct afs_vnode *vnode)
 	}
 
 	if (!vnode->directory) {
-		size_t cur_size = 0;
-
-		ret = netfs_alloc_folioq_buffer(NULL,
-						&vnode->directory, &cur_size, PAGE_SIZE,
-						mapping_gfp_mask(vnode->netfs.inode.i_mapping));
-		vnode->directory_size = PAGE_SIZE - 1;
-		if (ret < 0)
-			return ret;
+		vnode->directory = bvecq_alloc_buffer(
+			PAGE_SIZE, mapping_gfp_mask(vnode->netfs.inode.i_mapping), false);
+		if (!vnode->directory)
+			return -ENOMEM;
 	}
 
-	iov_iter_folio_queue(&iter, ITER_DEST, vnode->directory, 0, 0, PAGE_SIZE);
+	iov_iter_bvec_queue(&iter, ITER_DEST, vnode->directory, 0, 0, PAGE_SIZE);
 
 	/* AFS requires us to perform the read of a symlink as a single unit to
 	 * avoid issues with the content being changed between reads.
@@ -126,7 +126,7 @@ static ssize_t afs_do_read_symlink(struct afs_vnode *vnode)
 		refcount_set(&symlink->ref, 1);
 		symlink->content[i_size] = 0;
 
-		const char *s = kmap_local_folio(folioq_folio(vnode->directory, 0), 0);
+		const char *s = bvec_kmap_partial(&vnode->directory->bv[0], 0);
 
 		memcpy(symlink->content, s, i_size);
 		kunmap_local(s);
@@ -135,7 +135,7 @@ static ssize_t afs_do_read_symlink(struct afs_vnode *vnode)
 	}
 
 	if (!fscache_cookie_enabled(netfs_i_cookie(&vnode->netfs))) {
-		netfs_free_folioq_buffer(vnode->directory);
+		bvecq_put(vnode->directory);
 		vnode->directory = NULL;
 		vnode->directory_size = 0;
 	}
@@ -248,14 +248,14 @@ int afs_symlink_writepages(struct address_space *mapping,
 
 	if (vnode->directory &&
 	    atomic64_read(&vnode->cb_expires_at) != AFS_NO_CB_PROMISE) {
-		iov_iter_folio_queue(&iter, ITER_SOURCE, vnode->directory, 0, 0,
-				     i_size_read(&vnode->netfs.inode));
+		iov_iter_bvec_queue(&iter, ITER_SOURCE, vnode->directory, 0, 0,
+				    i_size_read(&vnode->netfs.inode));
 		ret = netfs_writeback_single(mapping, wbc, &iter);
 	}
 
 	if (ret == 0) {
 		netfs_wb_begin(&vnode->netfs, false);
-		netfs_free_folioq_buffer(vnode->directory);
+		bvecq_put(vnode->directory);
 		vnode->directory = NULL;
 		vnode->directory_size = 0;
 		netfs_wb_end(&vnode->netfs);
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 3989b4ec0c4b..121f28268cf0 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -624,129 +624,11 @@ int netfs_writepages(struct address_space *mapping,
 }
 EXPORT_SYMBOL(netfs_writepages);
 
-/*
- * Write some of a pending folio data back to the server and/or the cache.
- */
-static int netfs_write_folio_single(struct netfs_io_request *wreq,
-				    struct folio *folio)
-{
-	struct netfs_io_stream *upload = &wreq->io_streams[0];
-	struct netfs_io_stream *cache  = &wreq->io_streams[1];
-	struct netfs_io_stream *stream;
-	size_t iter_off = 0;
-	size_t fsize = folio_size(folio), flen;
-	uoff_t fpos = folio_pos(folio);
-	ssize_t ret;
-	bool to_eof = false;
-	bool no_debug = false;
-
-	_enter("");
-
-	flen = folio_size(folio);
-	if (flen > wreq->i_size - fpos) {
-		flen = wreq->i_size - fpos;
-		folio_zero_segment(folio, flen, fsize);
-		to_eof = true;
-	} else if (flen == wreq->i_size - fpos) {
-		to_eof = true;
-	}
-
-	_debug("folio %zx/%zx", flen, fsize);
-
-	if (!upload->avail && !cache->avail) {
-		trace_netfs_folio(folio, netfs_folio_trace_cancel_store);
-		return 0;
-	}
-
-	if (!upload->construct)
-		trace_netfs_folio(folio, netfs_folio_trace_store);
-	else
-		trace_netfs_folio(folio, netfs_folio_trace_store_plus);
-
-	/* Attach the folio to the rolling buffer. */
-	folio_get(folio);
-	ret = rolling_buffer_append(&wreq->buffer, folio, NETFS_ROLLBUF_PUT_MARK, wreq->gfp);
-	if (ret < 0) {
-		folio_put(folio);
-		return ret;
-	}
-
-	/* Move the submission point forward to allow for write-streaming data
-	 * not starting at the front of the page.  We don't do write-streaming
-	 * with the cache as the cache requires DIO alignment.
-	 *
-	 * Also skip uploading for data that's been read and just needs copying
-	 * to the cache.
-	 */
-	for (int s = 0; s < NR_IO_STREAMS; s++) {
-		stream = &wreq->io_streams[s];
-		stream->submit_off = 0;
-		stream->submit_len = flen;
-		if (!stream->avail) {
-			stream->submit_off = UINT_MAX;
-			stream->submit_len = 0;
-		}
-	}
-
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
-			}
-		}
-
-		if (choose_s < 0)
-			break;
-		stream = &wreq->io_streams[choose_s];
-
-		/* Advance the iterator(s). */
-		if (stream->submit_off > iter_off) {
-			rolling_buffer_advance(&wreq->buffer, stream->submit_off - iter_off);
-			iter_off = stream->submit_off;
-		}
-
-		atomic64_set(&wreq->issued_to, fpos + stream->submit_off);
-		stream->submit_extendable_to = fsize - stream->submit_off;
-		part = netfs_advance_write(wreq, stream, fpos + stream->submit_off,
-					   stream->submit_len, to_eof);
-		stream->submit_off += part;
-		if (part > stream->submit_len)
-			stream->submit_len = 0;
-		else
-			stream->submit_len -= part;
-		if (part > 0)
-			no_debug = true;
-	}
-
-	wreq->buffer.iter.iov_offset = 0;
-	if (fsize > iter_off)
-		rolling_buffer_advance(&wreq->buffer, fsize - iter_off);
-	atomic64_set(&wreq->issued_to, fpos + fsize);
-
-	if (!no_debug)
-		kdebug("R=%x: No submit", wreq->debug_id);
-	_leave(" = 0");
-	return 0;
-}
-
 /**
  * netfs_writeback_single - Write back a monolithic payload
  * @mapping: The mapping to write from
  * @wbc: Hints from the VM
- * @iter: Data to write, must be ITER_FOLIOQ.
+ * @iter: Data to write.
  *
  * Write a monolithic, non-pagecache object back to the server and/or
  * the cache.
@@ -760,13 +642,8 @@ int netfs_writeback_single(struct address_space *mapping,
 {
 	struct netfs_io_request *wreq;
 	struct netfs_inode *ictx = netfs_inode(mapping->host);
-	struct folio_queue *fq;
-	size_t size = iov_iter_count(iter);
 	int ret;
 
-	if (WARN_ON_ONCE(!iov_iter_is_folioq(iter)))
-		return -EIO;
-
 	if (!netfs_wb_begin(ictx, wbc->sync_mode == WB_SYNC_NONE)) {
 		/* The VFS will have undirtied the inode. */
 		netfs_single_mark_inode_dirty(&ictx->inode);
@@ -779,36 +656,42 @@ int netfs_writeback_single(struct address_space *mapping,
 		goto couldnt_start;
 	}
 
+	wreq->buffer.iter = *iter;
+	wreq->len = iov_iter_count(iter);
+	wreq->submitted = wreq->len;
+
 	__set_bit(NETFS_RREQ_OFFLOAD_COLLECTION, &wreq->flags);
 	trace_netfs_write(wreq, netfs_write_trace_writeback_single);
 	netfs_stat(&netfs_n_wh_writepages);
 
-	if (__test_and_set_bit(NETFS_RREQ_UPLOAD_TO_SERVER, &wreq->flags))
+	if (test_bit(NETFS_RREQ_UPLOAD_TO_SERVER, &wreq->flags))
 		wreq->netfs_ops->begin_writeback(wreq);
 
-	for (fq = (struct folio_queue *)iter->folioq; fq; fq = fq->next) {
-		for (int slot = 0; slot < folioq_count(fq); slot++) {
-			struct folio *folio = folioq_folio(fq, slot);
-			size_t part = umin(folioq_folio_size(fq, slot), size);
+	for (int s = 0; s < NR_IO_STREAMS; s++) {
+		struct netfs_io_subrequest *subreq;
+		struct netfs_io_stream *stream = &wreq->io_streams[s];
 
-			_debug("wbiter %lx %llx", folio->index, atomic64_read(&wreq->issued_to));
+		if (!stream->avail)
+			continue;
 
-			ret = netfs_write_folio_single(wreq, folio);
-			if (ret < 0)
-				goto stop;
-			size -= part;
-			if (size <= 0)
-				goto stop;
-		}
+		netfs_prepare_write(wreq, stream, 0);
+
+		subreq = stream->construct;
+		subreq->len = wreq->len;
+		stream->submit_len = subreq->len;
+		stream->submit_extendable_to = round_up(wreq->len, PAGE_SIZE);
+
+		netfs_issue_write(wreq, stream);
 	}
 
-stop:
-	for (int s = 0; s < NR_IO_STREAMS; s++)
-		netfs_issue_write(wreq, &wreq->io_streams[s]);
 	netfs_all_subreqs_queued(wreq);
-
 	netfs_wake_collector(wreq);
 
+	/* TODO: Might want to be async here if WB_SYNC_NONE, but then need to
+	 * wait before modifying.
+	 */
+	ret = netfs_wait_for_write(wreq);
+
 	netfs_put_request(wreq, netfs_rreq_trace_put_return);
 	_leave(" = %d", ret);
 	return ret;

