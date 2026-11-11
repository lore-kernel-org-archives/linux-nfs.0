Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794429115;
	b=k2yzvbzP352GMDiFW61y5tX5dH5y2T4TtFDBqQp4XLJSC8IPymeWoB1scD3KoHnX3qel
	 E6L2LhEff0nB1GRjijfDVdYe5KLLAJA9CwLDlLpK3dZMYzYzhlopVeQgS0HCg0LkQVIU8
	 vjWwO1g/Xk8DW7+HogUTRErk3y+eJYiK3z5oVCl3ZH9wpnbm2gqzD/qKd4eCzQHfi3zmK
	 Pr8QUslOCkLihyz8TLA6qFrFJtQwgzNecY7E0kQf3zZgEtvpYqUJc7tYjk5tVVB7hIFGA
	 B38oVzu7TzM1PpL8lRiiI0yeG9uV+Ag2AKjp0D+oQulXp8HtEOWiQ40OLbOW949/jYw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794429115;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=ixmMQzdasAf2NVsHQAdIHHEVS3hvRQgzpLvuaZdFCPM=;
	b=pZHDXAwx0xUZip/IPZOSGLnp1wQj6PyQl5IHzSJHVd/6ddR+/INiMeCL1ATy7rnFsEEN
	 rM7r7ifr5uE/1fKR7tNwHuQI2ic0tR1FmRFG07vSIh08BH5A7J0GlQb5C4OPe9ie42URq
	 ABUHp3tc9OeMenTwnAZtWXC2RIGSeYI7ahgi0pYg6gYDBG+brMnCD7cCoBm9yuI59Vslf
	 GTNqqD1eNYnHw3EF3h7n5QKcPkARqFaP8iBbiLkTdbJMkdRGAhUhzoiH1YEvBc3g5XLh/
	 ZVjOIUjCjlxcPGyccZgUA3pbUTUVifNIMbEXTb24W6KjzwSOuesbMbPsuqxx4cCCL2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=DGh9tbwn;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47FFE606B248
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 20:31:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 47FFE606B248
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=DGh9tbwn
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794429113;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ixmMQzdasAf2NVsHQAdIHHEVS3hvRQgzpLvuaZdFCPM=;
	b=DGh9tbwnna8lTdRZP9z/2Al3ECRb4uDKtvQaAFV0zW9YxF4B7avBcxu0Lg9pzjEntuZePW
	Uf7X0W/f7GsXSIVa3PGjWjY1N/wafud9ltdIvetsGlwQUDugkFK3ebGAri4AK7noDEzCOa
	MCQ2xas2ckyTpywhPmTDOJ0is3P8C8c=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-590-0Zoj6SYSOvycRv_hrAliqw-1; Wed,
 11 Nov 2026 15:31:48 -0500
X-MC-Unique: 0Zoj6SYSOvycRv_hrAliqw-1
X-Mimecast-MFC-AGG-ID: 0Zoj6SYSOvycRv_hrAliqw_1794429105
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 820B41977695;
	Wed, 11 Nov 2026 20:31:45 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id CAB21180054A;
	Wed, 11 Nov 2026 20:31:41 +0000 (UTC)
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
Subject: [PATCH v17 11/17] afs: Use a bvecq to hold dir content rather than folioq
Date: Wed, 11 Nov 2026 20:30:24 +0000
Message-ID: <20261111203034.2126314-12-dhowells@redhat.com>
In-Reply-To: <20261111203034.2126314-1-dhowells@redhat.com>
References: <20261111203034.2126314-1-dhowells@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Use a bvecq to hold the contents of a directory rather than the folioq so
that the latter can be phased out.  This is also applied to the symlink I/O
buffer.

Also use the bvecq chain being refcounted to fix an issue in afs directory
handling and netfs_writeback_single() whereby the application of
third-party induced invalidation can race with the writeback code because
afs doesn't hold the vnode validate_lock when updating the inode info.

Now, AFS FS RPC calls typically return a status update any time they access
a vnode (file) on the server and the Linux afs fs driver applies it
directly in the postprocessing of the RPC and, ideally, it would take the
vnode's validate_lock whilst doing so - unfortunately, however, the caller
may already be holding the validate_lock, as does afs_dir_writepages().

Worse, afs_dir_writepages() takes a shared lock so the inode info can't be
updated exclusively under that lock.

Fix this by getting the directory contents, dir buffer size and inode size
inside the cb_lock so that the set is at least consistent (if not currently
valid).  Invalidation will replace the cachefile anyway to discard
in-progress old writebacks.

Further, in netfs_alloc_request() called from netfs_writeback_single(), use
the content length parameter rather than i_size (we don't care about the
cachefile size) on behalf of single-writeback.

Link: https://sashiko.dev/#/patchset/20261107160823.1465553-1-dhowells%40redhat.com

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-afs@lists.infradead.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/afs/dir.c        | 54 ++++++++++++++++++++++++++-------------------
 fs/afs/dir_edit.c   | 44 +++++++++++++++++-------------------
 fs/afs/dir_search.c | 33 +++++++++++++--------------
 fs/afs/inode.c      |  2 +-
 fs/afs/internal.h   |  6 ++---
 fs/afs/symlink.c    | 42 +++++++++++++++++------------------
 fs/netfs/objects.c  |  4 ++++
 7 files changed, 95 insertions(+), 90 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 51c158d8f723..9cefd90fd4f8 100644
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
@@ -250,16 +250,16 @@ static ssize_t afs_do_read_single(struct afs_vnode *dvnode, struct file *file)
 	if (dvnode->directory_size < i_size) {
 		size_t cur_size = dvnode->directory_size;
 
-		ret = netfs_alloc_folioq_buffer(NULL,
-						&dvnode->directory, &cur_size, i_size,
-						mapping_gfp_mask(dvnode->netfs.inode.i_mapping) |
-						__GFP_ZERO);
+		ret = bvecq_expand_buffer(&dvnode->directory, &cur_size,
+					  round_up(i_size, PAGE_SIZE),
+					  mapping_gfp_mask(dvnode->netfs.inode.i_mapping) |
+					  __GFP_ZERO);
 		dvnode->directory_size = cur_size;
 		if (ret < 0)
 			return ret;
 	}
 
-	iov_iter_folio_queue(&iter, ITER_DEST, dvnode->directory, 0, 0, dvnode->directory_size);
+	iov_iter_bvec_queue(&iter, ITER_DEST, dvnode->directory, 0, 0, dvnode->directory_size);
 
 	/* AFS requires us to perform the read of a directory synchronously as
 	 * a single unit to avoid issues with the directory contents being
@@ -281,8 +281,8 @@ static ssize_t afs_do_read_single(struct afs_vnode *dvnode, struct file *file)
 		}
 
 		if (ret >= 0 && ret < dvnode->directory_size) {
-			iov_iter_folio_queue(&iter, ITER_DEST, dvnode->directory,
-					     0, 0, dvnode->directory_size);
+			iov_iter_bvec_queue(&iter, ITER_DEST, dvnode->directory,
+					    0, 0, dvnode->directory_size);
 			iov_iter_advance(&iter, ret);
 			iov_iter_zero(dvnode->directory_size - ret, &iter);
 		}
@@ -302,8 +302,8 @@ static ssize_t afs_read_single(struct afs_vnode *dvnode, struct file *file)
 }
 
 /*
- * Read the directory into a folio_queue buffer in one go, scrubbing the
- * previous contents.  We return -ESTALE if the caller needs to call us again.
+ * Read the directory into the buffer in one go, scrubbing the previous
+ * contents.  We return -ESTALE if the caller needs to call us again.
  */
 ssize_t afs_read_dir(struct afs_vnode *dvnode, struct file *file)
 	__acquires(&dvnode->validate_lock)
@@ -491,7 +491,7 @@ static size_t afs_dir_iterate_step(void *iter_base, size_t progress, size_t len,
 }
 
 /*
- * Iterate through the directory folios.
+ * Iterate through the directory content.
  */
 static int afs_dir_iterate_contents(struct inode *dir, struct dir_context *dir_ctx)
 {
@@ -506,11 +506,11 @@ static int afs_dir_iterate_contents(struct inode *dir, struct dir_context *dir_c
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
@@ -2220,6 +2220,7 @@ static int afs_dir_writepages(struct address_space *mapping,
 			      struct writeback_control *wbc)
 {
 	struct afs_vnode *dvnode = AFS_FS_I(mapping->host);
+	struct bvecq *directory = NULL;
 	struct iov_iter iter;
 	int ret = 0;
 
@@ -2236,14 +2237,21 @@ static int afs_dir_writepages(struct address_space *mapping,
 	}
 
 	if (test_bit(AFS_VNODE_DIR_VALID, &dvnode->flags)) {
-		iov_iter_folio_queue(&iter, ITER_SOURCE, dvnode->directory,
-				     0, 0, dvnode->directory_size);
-		ret = netfs_writeback_single(mapping, wbc, &iter,
-					     i_size_read(&dvnode->netfs.inode));
+		size_t i_size, d_size;
+
+		read_seqlock_excl(&dvnode->cb_lock);
+		i_size = i_size_read(&dvnode->netfs.inode);
+		d_size = dvnode->directory_size;
+		directory = bvecq_get(dvnode->directory);
+		read_sequnlock_excl(&dvnode->cb_lock);
+
+		iov_iter_bvec_queue(&iter, ITER_SOURCE, directory, 0, 0, d_size);
+		ret = netfs_writeback_single(mapping, wbc, &iter, i_size);
 		if (ret == 1)
 			ret = 0; /* Skipped write due to lock conflict. */
 	}
 
 	up_read(&dvnode->validate_lock);
+	bvecq_put(directory);
 	return ret;
 }
diff --git a/fs/afs/dir_edit.c b/fs/afs/dir_edit.c
index 185e8819e424..870921f32fc8 100644
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
@@ -120,41 +118,39 @@ static union afs_xdr_dir_block *afs_dir_get_block(struct afs_dir_iter *iter, siz
 	if (dvnode->directory_size < blend) {
 		size_t cur_size = dvnode->directory_size;
 
-		ret = netfs_alloc_folioq_buffer(
-			NULL, &dvnode->directory, &cur_size, blend,
-			mapping_gfp_mask(dvnode->netfs.inode.i_mapping) | __GFP_ZERO);
+		ret = bvecq_expand_buffer(&dvnode->directory, &cur_size, blend,
+					  mapping_gfp_mask(dvnode->netfs.inode.i_mapping) |
+					  __GFP_ZERO);
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
index 0733abff77a5..af95640da03f 100644
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
index 7cea5ba0d20d..2a8b029b4d69 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -712,7 +712,7 @@ struct afs_vnode {
 #define AFS_VNODE_MODIFYING	10		/* Set if we're performing a modification op */
 #define AFS_VNODE_DIR_READ	11		/* Set if we've read a dir's contents */
 
-	struct folio_queue	*directory;	/* Directory contents */
+	struct bvecq		*directory;	/* Directory contents */
 	struct afs_symlink __rcu *symlink;	/* Symlink content */
 	struct list_head	wb_keys;	/* List of keys available for writeback */
 	struct list_head	pending_locks;	/* locks waiting to be granted */
@@ -993,9 +993,9 @@ static inline void afs_invalidate_cache(struct afs_vnode *vnode, unsigned int fl
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
index c18e4f806423..f437c3108c6c 100644
--- a/fs/afs/symlink.c
+++ b/fs/afs/symlink.c
@@ -56,7 +56,6 @@ void afs_evict_symlink(struct afs_vnode *vnode)
 void afs_init_new_symlink(struct afs_vnode *vnode, struct afs_operation *op)
 {
 	struct afs_symlink *symlink = op->create.symlink;
-	size_t dsize = 0;
 	size_t size = strlen(symlink->content) + 1;
 	char *p;
 
@@ -66,12 +65,15 @@ void afs_init_new_symlink(struct afs_vnode *vnode, struct afs_operation *op)
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
+	vnode->directory_size = PAGE_SIZE;
+	p = bvec_kmap_partial(&vnode->directory->bv[0], 0);
 	memcpy(p, symlink->content, size);
 	kunmap_local(p);
 	netfs_single_mark_inode_dirty(&vnode->netfs.inode);
@@ -94,17 +96,14 @@ static ssize_t afs_do_read_symlink(struct afs_vnode *vnode)
 	}
 
 	if (!vnode->directory) {
-		size_t cur_size = 0;
-
-		ret = netfs_alloc_folioq_buffer(NULL,
-						&vnode->directory, &cur_size, PAGE_SIZE,
-						mapping_gfp_mask(vnode->netfs.inode.i_mapping));
+		vnode->directory = bvecq_alloc_buffer(
+			PAGE_SIZE, mapping_gfp_mask(vnode->netfs.inode.i_mapping), false);
+		if (!vnode->directory)
+			return -ENOMEM;
 		vnode->directory_size = PAGE_SIZE;
-		if (ret < 0)
-			return ret;
 	}
 
-	iov_iter_folio_queue(&iter, ITER_DEST, vnode->directory, 0, 0, PAGE_SIZE);
+	iov_iter_bvec_queue(&iter, ITER_DEST, vnode->directory, 0, 0, PAGE_SIZE);
 
 	/* AFS requires us to perform the read of a symlink as a single unit to
 	 * avoid issues with the content being changed between reads.
@@ -125,7 +124,7 @@ static ssize_t afs_do_read_symlink(struct afs_vnode *vnode)
 		refcount_set(&symlink->ref, 1);
 		symlink->content[i_size] = 0;
 
-		const char *s = kmap_local_folio(folioq_folio(vnode->directory, 0), 0);
+		const char *s = bvec_kmap_partial(&vnode->directory->bv[0], 0);
 
 		memcpy(symlink->content, s, i_size);
 		kunmap_local(s);
@@ -134,7 +133,7 @@ static ssize_t afs_do_read_symlink(struct afs_vnode *vnode)
 	}
 
 	if (!fscache_cookie_enabled(netfs_i_cookie(&vnode->netfs))) {
-		netfs_free_folioq_buffer(vnode->directory);
+		bvecq_put(vnode->directory);
 		vnode->directory = NULL;
 		vnode->directory_size = 0;
 	}
@@ -195,7 +194,7 @@ const char *afs_get_link(struct dentry *dentry, struct inode *inode,
 	}
 
 	downgrade_write(&vnode->validate_lock);
-	
+
 good:
 	symlink = rcu_dereference_protected(vnode->symlink,
 					    lockdep_is_held(&vnode->validate_lock));
@@ -254,19 +253,20 @@ int afs_symlink_writepages(struct address_space *mapping,
 		size_t i_size = i_size_read(&vnode->netfs.inode);
 
 		if (i_size < vnode->directory_size) {
-			iov_iter_folio_queue(&iter, ITER_DEST, vnode->directory, 0, 0,
-					     vnode->directory_size);
+			iov_iter_bvec_queue(&iter, ITER_DEST, vnode->directory, 0, 0,
+					    vnode->directory_size);
 			iov_iter_advance(&iter, i_size);
 			iov_iter_zero(vnode->directory_size - i_size, &iter);
 		}
-		iov_iter_folio_queue(&iter, ITER_SOURCE, vnode->directory, 0, 0,
-				     vnode->directory_size);
+
+		iov_iter_bvec_queue(&iter, ITER_SOURCE, vnode->directory, 0, 0,
+				    vnode->directory_size);
 		ret = netfs_writeback_single(mapping, wbc, &iter, i_size);
 	}
 
 	if (ret == 0) {
 		netfs_wb_begin(&vnode->netfs, false);
-		netfs_free_folioq_buffer(vnode->directory);
+		bvecq_put(vnode->directory);
 		vnode->directory = NULL;
 		vnode->directory_size = 0;
 		netfs_wb_end(&vnode->netfs);
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 6d7839c0498d..9895cf662bca 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -78,6 +78,10 @@ struct netfs_io_request *netfs_alloc_request(struct address_space *mapping,
 		rreq->io_streams[0].avail = true;
 	} else {
 		INIT_WORK(&rreq->work, netfs_write_collection_worker);
+
+		/* For single-type, we disregard the previous content. */
+		if (origin == NETFS_WRITEBACK_SINGLE)
+			rreq->i_size = rreq->len;
 	}
 
 	__set_bit(NETFS_RREQ_IN_PROGRESS, &rreq->flags);

