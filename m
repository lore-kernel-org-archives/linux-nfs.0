Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4180F4AE8AF
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:37:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370644; cv=none; b=u66+xeL1XCxw4afsBh2/fRXEiQJNC4T6fvD/4iiuE6tyziPqQOyVm72cXMV88v9YnRkK1qNLv1bqAs501i3ecQb5YiJ0uLalArZbSnMLHGkfiU5ydD/wtzPMqWmmSyNUOoFzmVwiekeGL12+AZPWi0mB5G3qkso5pgnDK31n6CU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370644; c=relaxed/simple;
	bh=YO36vuDXDsGIHBmaLo5Mh2Q25MHjy/mDsXLIXdv5ZEw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ncz53OA1RShH79px2aIJ7qowThM864lxUN+keawPccYUEzj/+C2G8BsfnQ68L3XFtHUylcNIeSyquiA4HO2XEOWB1goZX3HfxCRjjciTAOjBT5RC5NjOnHy0gDyK95+/2ALHcFqxGZgihmVwv6g0uIFFR2i6eFxi/jTQ3JVf+L0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=YpFSDy3x; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="YpFSDy3x"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370637;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=+cm1ZXWH8JmTVtcf8m+rg+i5L45a4X17bCNd5KUTnfw=;
	b=YpFSDy3xE9vDBHdCgi2wSelso9xOcXNgXNH9IiFJOyB4T4kE/MVD5w83/t7RVcb1vKRSCW
	E1iPSpEpkkUvotq4MSD3Ub1CmPFo4Sg5rROnY8H5dx5/0azjP1NEue7AiTdVG2L4jd1OCe
	iEZMNtAgXk67SVtToVTApDuUa3iFWvQ=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-460-r3ZPBjHUPjCyE5r47wThgQ-1; Wed,
 02 Sep 2026 13:37:13 -0400
X-MC-Unique: r3ZPBjHUPjCyE5r47wThgQ-1
X-Mimecast-MFC-AGG-ID: r3ZPBjHUPjCyE5r47wThgQ_1788370630
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 4AB6319774E5;
	Wed,  2 Sep 2026 17:37:10 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 641F018005BA;
	Wed,  2 Sep 2026 17:37:04 +0000 (UTC)
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
Subject: [PATCH v11 23/36] netfs: Remove netfs_alloc/free_folioq_buffer()
Date: Wed,  2 Sep 2026 18:33:35 +0100
Message-ID: <20260902173350.3468672-24-dhowells@redhat.com>
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

Remove netfs_alloc/free_folioq_buffer() as bvecq_alloc_*() and bvecq_put()
should now be used instead.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: Namjae Jeon <linkinjeon@kernel.org>
cc: linux-cifs@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/afs/dir_edit.c       |  1 -
 fs/netfs/misc.c         | 98 -----------------------------------------
 fs/smb/client/smb2ops.c |  1 -
 include/linux/netfs.h   |  6 ---
 4 files changed, 106 deletions(-)

diff --git a/fs/afs/dir_edit.c b/fs/afs/dir_edit.c
index 01c6265e8865..31fdef23c6b6 100644
--- a/fs/afs/dir_edit.c
+++ b/fs/afs/dir_edit.c
@@ -10,7 +10,6 @@
 #include <linux/namei.h>
 #include <linux/pagemap.h>
 #include <linux/iversion.h>
-#include <linux/folio_queue.h>
 #include "internal.h"
 #include "xdr_fs.h"
 
diff --git a/fs/netfs/misc.c b/fs/netfs/misc.c
index a2a2aeb1bb0d..4fa09560fb4b 100644
--- a/fs/netfs/misc.c
+++ b/fs/netfs/misc.c
@@ -8,104 +8,6 @@
 #include <linux/swap.h>
 #include "internal.h"
 
-#if 0
-/**
- * netfs_alloc_folioq_buffer - Allocate buffer space into a folio queue
- * @mapping: Address space to set on the folio (or NULL).
- * @_buffer: Pointer to the folio queue to add to (may point to a NULL; updated).
- * @_cur_size: Current size of the buffer (updated).
- * @size: Target size of the buffer.
- * @gfp: The allocation constraints.
- */
-int netfs_alloc_folioq_buffer(struct address_space *mapping,
-			      struct folio_queue **_buffer,
-			      size_t *_cur_size, ssize_t size, gfp_t gfp)
-{
-	struct folio_queue *tail = *_buffer, *p;
-
-	size = round_up(size, PAGE_SIZE);
-	if (*_cur_size >= size)
-		return 0;
-
-	if (tail)
-		while (tail->next)
-			tail = tail->next;
-
-	do {
-		struct folio *folio;
-		int order = 0, slot;
-
-		if (!tail || folioq_full(tail)) {
-			p = netfs_folioq_alloc(0, GFP_NOFS, netfs_trace_folioq_alloc_buffer);
-			if (!p)
-				return -ENOMEM;
-			if (tail) {
-				tail->next = p;
-				p->prev = tail;
-			} else {
-				*_buffer = p;
-			}
-			tail = p;
-		}
-
-		if (size - *_cur_size > PAGE_SIZE)
-			order = umin(ilog2(size - *_cur_size) - PAGE_SHIFT,
-				     MAX_PAGECACHE_ORDER);
-
-		folio = folio_alloc(gfp, order);
-		if (!folio && order > 0)
-			folio = folio_alloc(gfp, 0);
-		if (!folio)
-			return -ENOMEM;
-
-		folio->mapping = mapping;
-		folio->index = *_cur_size / PAGE_SIZE;
-		trace_netfs_folio(folio, netfs_folio_trace_alloc_buffer);
-		slot = folioq_append_mark(tail, folio);
-		*_cur_size += folioq_folio_size(tail, slot);
-	} while (*_cur_size < size);
-
-	return 0;
-}
-EXPORT_SYMBOL(netfs_alloc_folioq_buffer);
-
-/**
- * netfs_free_folioq_buffer - Free a folio queue.
- * @fq: The start of the folio queue to free
- *
- * Free up a chain of folio_queues and, if marked, the marked folios they point
- * to.
- */
-void netfs_free_folioq_buffer(struct folio_queue *fq)
-{
-	struct folio_queue *next;
-	struct folio_batch fbatch;
-
-	folio_batch_init(&fbatch);
-
-	for (; fq; fq = next) {
-		for (int slot = 0; slot < folioq_count(fq); slot++) {
-			struct folio *folio = folioq_folio(fq, slot);
-
-			if (!folio ||
-			    !folioq_is_marked(fq, slot))
-				continue;
-
-			trace_netfs_folio(folio, netfs_folio_trace_put);
-			if (folio_batch_add(&fbatch, folio))
-				folio_batch_release(&fbatch);
-		}
-
-		netfs_stat_d(&netfs_n_folioq);
-		next = fq->next;
-		kfree(fq);
-	}
-
-	folio_batch_release(&fbatch);
-}
-EXPORT_SYMBOL(netfs_free_folioq_buffer);
-#endif
-
 /**
  * netfs_dirty_folio - Mark folio dirty and pin a cache object for writeback
  * @mapping: The mapping the folio belongs to.
diff --git a/fs/smb/client/smb2ops.c b/fs/smb/client/smb2ops.c
index 885f0cc861ed..97823bcf198c 100644
--- a/fs/smb/client/smb2ops.c
+++ b/fs/smb/client/smb2ops.c
@@ -13,7 +13,6 @@
 #include <linux/sort.h>
 #include <crypto/aead.h>
 #include <linux/fiemap.h>
-#include <linux/folio_queue.h>
 #include <uapi/linux/magic.h>
 #include "cifsfs.h"
 #include "cifsglob.h"
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 68f358dae0d5..269c2f2bd32d 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -474,12 +474,6 @@ void netfs_end_io_write(struct inode *inode);
 int netfs_start_io_direct(struct inode *inode);
 void netfs_end_io_direct(struct inode *inode);
 
-/* Buffer wrangling helpers API. */
-int netfs_alloc_folioq_buffer(struct address_space *mapping,
-			      struct folio_queue **_buffer,
-			      size_t *_cur_size, ssize_t size, gfp_t gfp);
-void netfs_free_folioq_buffer(struct folio_queue *fq);
-
 /* Writeback exclusion API. */
 bool netfs_wb_begin(struct netfs_inode *ictx, bool nowait);
 void netfs_wb_end(struct netfs_inode *ictx);

