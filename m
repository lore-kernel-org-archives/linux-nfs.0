Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8A9343553A
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:42:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787582563; cv=none; b=qyF0qjc6yYvTxZ2RS3S4xX544tzqCkejdLyx7uJa8uV4GVIv0nV99q5Oe1524ql+Tpluggx0kHnfaiAYb9zLHj8do711K4PRfy+KU/a3/6oi+8H9sj6WM/3L2HUrifp+XNSTyU4u6umraGs0hH3ntbbUtjoLVDscVcojmEBz5a4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787582563; c=relaxed/simple;
	bh=IoCOVwvaVi7H2FOBtgmH7faEMiEZHzm7roB7mQtntF0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JKyO9eTXZ5cXsBjlx1DddfUXs/0KOXbmfpsHEaXUxpjI5VWRMfMrlLPCEPh2+PyaDZiEeXi3BRbatrPc7cmDgTk9wyOd4ieBkxQtvNMjHqIYqylbSZTzJHaj9FWPwIIkWubHS50Y0pfvuf5QVBX3Kp5NH+VZ3u0UecmyCnxaldc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=B/35XUsa; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="B/35XUsa"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787582554;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6Ewi4qSsSL5b4R0l90oASgZKuTI8wz/A21/TicXS79Y=;
	b=B/35XUsaNSHAkewkCkMUkMdm/BhGbLm7tJn9kvUYskktSbFZdG83qyE/MFrc4xac1VJfBw
	N+1/NA4xKJqD0caUBpuhdQ0j21qaV9AQyS56dL5kLmW1KWATDBRCJXTZRO4B2ctlVOpthy
	OAb/XftCRDT/YBB8f7xKGMn3nFFbekQ=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-115-1b2yRGiCNy6p8i-FUIM80A-1; Mon,
 24 Aug 2026 10:42:30 -0400
X-MC-Unique: 1b2yRGiCNy6p8i-FUIM80A-1
X-Mimecast-MFC-AGG-ID: 1b2yRGiCNy6p8i-FUIM80A_1787582548
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 137941977535;
	Mon, 24 Aug 2026 14:42:28 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.15])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2D2D01955F09;
	Mon, 24 Aug 2026 14:42:20 +0000 (UTC)
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
Subject: [PATCH v10 05/35] netfs: Use uoff_t instead of unsigned long long and loff_t
Date: Mon, 24 Aug 2026 15:40:58 +0100
Message-ID: <20260824144130.759997-6-dhowells@redhat.com>
In-Reply-To: <20260824144130.759997-1-dhowells@redhat.com>
References: <20260824144130.759997-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Use uoff_t instead of unsigned long long and loff_t for file positions that
can't be negative.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/afs/file.c                     |  4 +-
 fs/cachefiles/interface.c         | 10 ++--
 fs/cachefiles/internal.h          |  4 +-
 fs/cachefiles/io.c                | 24 +++++-----
 fs/ceph/addr.c                    |  4 +-
 fs/netfs/buffered_read.c          | 24 +++++-----
 fs/netfs/buffered_write.c         | 10 ++--
 fs/netfs/direct_read.c            |  2 +-
 fs/netfs/direct_write.c           |  8 ++--
 fs/netfs/fscache_cookie.c         |  8 ++--
 fs/netfs/fscache_io.c             |  8 ++--
 fs/netfs/internal.h               | 10 ++--
 fs/netfs/iterator.c               |  2 +-
 fs/netfs/misc.c                   |  8 ++--
 fs/netfs/objects.c                |  2 +-
 fs/netfs/read_collect.c           |  4 +-
 fs/netfs/read_pgpriv2.c           |  8 ++--
 fs/netfs/read_retry.c             |  2 +-
 fs/netfs/write_collect.c          | 10 ++--
 fs/netfs/write_issue.c            | 10 ++--
 fs/netfs/write_retry.c            |  2 +-
 include/linux/fscache-cache.h     |  2 +-
 include/linux/fscache.h           | 36 +++++++--------
 include/linux/netfs.h             | 74 ++++++++++++++---------------
 include/trace/events/cachefiles.h | 30 ++++++------
 include/trace/events/fscache.h    | 10 ++--
 include/trace/events/netfs.h      | 77 +++++++++++++++----------------
 27 files changed, 196 insertions(+), 197 deletions(-)

diff --git a/fs/afs/file.c b/fs/afs/file.c
index 0467742bfeee..3380a0d20c0f 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -413,7 +413,7 @@ static int afs_init_request(struct netfs_io_request *rreq, struct file *file)
 	return 0;
 }
 
-static int afs_check_write_begin(struct file *file, loff_t pos, unsigned len,
+static int afs_check_write_begin(struct file *file, uoff_t pos, unsigned len,
 				 struct folio **foliop, void **_fsdata)
 {
 	struct afs_vnode *vnode = AFS_FS_I(file_inode(file));
@@ -451,7 +451,7 @@ void afs_set_i_size(struct afs_vnode *vnode, loff_t new_i_size)
 	fscache_update_cookie(afs_vnode_cache(vnode), NULL, &new_i_size);
 }
 
-static void afs_update_i_size(struct inode *inode, loff_t new_i_size)
+static void afs_update_i_size(struct inode *inode, uoff_t new_i_size)
 {
 	afs_set_i_size(AFS_FS_I(inode), new_i_size);
 }
diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index 50a000310a8c..a160d5c3e74c 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -111,7 +111,7 @@ static int cachefiles_adjust_size(struct cachefiles_object *object)
 	struct iattr newattrs;
 	struct file *file = object->file;
 	uint64_t ni_size;
-	loff_t oi_size;
+	uoff_t oi_size;
 	int ret;
 
 	ni_size = object->cookie->object_size;
@@ -225,11 +225,11 @@ static bool cachefiles_lookup_cookie(struct fscache_cookie *cookie)
  * any unused granules.
  */
 static bool cachefiles_shorten_object(struct cachefiles_object *object,
-				      struct file *file, loff_t new_size)
+				      struct file *file, uoff_t new_size)
 {
 	struct cachefiles_cache *cache = object->volume->cache;
 	struct inode *inode = file_inode(file);
-	loff_t i_size, dio_size;
+	uoff_t i_size, dio_size;
 	int ret;
 
 	dio_size = round_up(new_size, CACHEFILES_DIO_BLOCK_SIZE);
@@ -271,14 +271,14 @@ static bool cachefiles_shorten_object(struct cachefiles_object *object,
  * Resize the backing object.
  */
 static void cachefiles_resize_cookie(struct netfs_cache_resources *cres,
-				     loff_t new_size)
+				     uoff_t new_size)
 {
 	struct cachefiles_object *object = cachefiles_cres_object(cres);
 	struct cachefiles_cache *cache = object->volume->cache;
 	struct fscache_cookie *cookie = object->cookie;
 	const struct cred *saved_cred;
 	struct file *file = cachefiles_cres_file(cres);
-	loff_t old_size = cookie->object_size;
+	uoff_t old_size = cookie->object_size;
 
 	_enter("%llu->%llu", old_size, new_size);
 
diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
index c93324e0f98c..60bd801ada04 100644
--- a/fs/cachefiles/internal.h
+++ b/fs/cachefiles/internal.h
@@ -203,11 +203,11 @@ extern bool cachefiles_begin_operation(struct netfs_cache_resources *cres,
 				       enum fscache_want_state want_state);
 extern int __cachefiles_prepare_write(struct cachefiles_object *object,
 				      struct file *file,
-				      loff_t *_start, size_t *_len, size_t upper_len,
+				      uoff_t *_start, size_t *_len, size_t upper_len,
 				      bool no_space_allocated_yet);
 extern int __cachefiles_write(struct cachefiles_object *object,
 			      struct file *file,
-			      loff_t start_pos,
+			      uoff_t start_pos,
 			      struct iov_iter *iter,
 			      netfs_io_terminated_t term_func,
 			      void *term_func_priv);
diff --git a/fs/cachefiles/io.c b/fs/cachefiles/io.c
index 9540ec25b3cb..7de8069d15b6 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -19,7 +19,7 @@
 struct cachefiles_kiocb {
 	struct kiocb		iocb;
 	refcount_t		ki_refcnt;
-	loff_t			start;
+	uoff_t			start;
 	union {
 		size_t		skipped;
 		size_t		len;
@@ -73,7 +73,7 @@ static void cachefiles_read_complete(struct kiocb *iocb, long ret)
  * Initiate a read from the cache.
  */
 static int cachefiles_read(struct netfs_cache_resources *cres,
-			   loff_t start_pos,
+			   uoff_t start_pos,
 			   struct iov_iter *iter,
 			   enum netfs_read_from_hole read_hole,
 			   netfs_io_terminated_t term_func,
@@ -197,8 +197,8 @@ static int cachefiles_read(struct netfs_cache_resources *cres,
  * of data starts and how long it is.
  */
 static int cachefiles_query_occupancy(struct netfs_cache_resources *cres,
-				      loff_t start, size_t len, size_t granularity,
-				      loff_t *_data_start, size_t *_data_len)
+				      uoff_t start, size_t len, size_t granularity,
+				      uoff_t *_data_start, size_t *_data_len)
 {
 	struct cachefiles_object *object;
 	struct file *file;
@@ -280,7 +280,7 @@ static void cachefiles_write_complete(struct kiocb *iocb, long ret)
  */
 int __cachefiles_write(struct cachefiles_object *object,
 		       struct file *file,
-		       loff_t start_pos,
+		       uoff_t start_pos,
 		       struct iov_iter *iter,
 		       netfs_io_terminated_t term_func,
 		       void *term_func_priv)
@@ -357,7 +357,7 @@ int __cachefiles_write(struct cachefiles_object *object,
 }
 
 static int cachefiles_write(struct netfs_cache_resources *cres,
-			    loff_t start_pos,
+			    uoff_t start_pos,
 			    struct iov_iter *iter,
 			    netfs_io_terminated_t term_func,
 			    void *term_func_priv)
@@ -377,7 +377,7 @@ static int cachefiles_write(struct netfs_cache_resources *cres,
 
 static inline enum netfs_io_source
 cachefiles_do_prepare_read(struct netfs_cache_resources *cres,
-			   loff_t start, size_t *_len, loff_t i_size,
+			   uoff_t start, size_t *_len, loff_t i_size,
 			   unsigned long *_flags, ino_t netfs_ino)
 {
 	enum cachefiles_prepare_read_trace why;
@@ -483,7 +483,7 @@ cachefiles_do_prepare_read(struct netfs_cache_resources *cres,
  * boundary as appropriate.
  */
 static enum netfs_io_source cachefiles_prepare_read(struct netfs_io_subrequest *subreq,
-						    unsigned long long i_size)
+						    uoff_t i_size)
 {
 	return cachefiles_do_prepare_read(&subreq->rreq->cache_resources,
 					  subreq->start, &subreq->len, i_size,
@@ -495,7 +495,7 @@ static enum netfs_io_source cachefiles_prepare_read(struct netfs_io_subrequest *
  */
 int __cachefiles_prepare_write(struct cachefiles_object *object,
 			       struct file *file,
-			       loff_t *_start, size_t *_len, size_t upper_len,
+			       uoff_t *_start, size_t *_len, size_t upper_len,
 			       bool no_space_allocated_yet)
 {
 	struct cachefiles_cache *cache = object->volume->cache;
@@ -577,8 +577,8 @@ int __cachefiles_prepare_write(struct cachefiles_object *object,
 }
 
 static int cachefiles_prepare_write(struct netfs_cache_resources *cres,
-				    loff_t *_start, size_t *_len, size_t upper_len,
-				    loff_t i_size, bool no_space_allocated_yet)
+				    uoff_t *_start, size_t *_len, size_t upper_len,
+				    uoff_t i_size, bool no_space_allocated_yet)
 {
 	struct cachefiles_object *object = cachefiles_cres_object(cres);
 	struct cachefiles_cache *cache = object->volume->cache;
@@ -628,7 +628,7 @@ static void cachefiles_issue_write(struct netfs_io_subrequest *subreq)
 	struct netfs_io_stream *stream = &wreq->io_streams[subreq->stream_nr];
 	const struct cred *saved_cred;
 	size_t off, pre, post, len = subreq->len;
-	loff_t start = subreq->start;
+	uoff_t start = subreq->start;
 	int ret;
 
 	_enter("W=%x[%x] %llx-%llx",
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index ecf33b66610c..6586f6c1dc73 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -65,7 +65,7 @@
 	(CONGESTION_ON_THRESH(congestion_kb) -				\
 	 (CONGESTION_ON_THRESH(congestion_kb) >> 2))
 
-static int ceph_netfs_check_write_begin(struct file *file, loff_t pos, unsigned int len,
+static int ceph_netfs_check_write_begin(struct file *file, uoff_t pos, unsigned int len,
 					struct folio **foliop, void **_fsdata);
 
 static inline struct ceph_snap_context *page_snap_context(struct page *page)
@@ -1854,7 +1854,7 @@ ceph_find_incompatible(struct folio *folio)
 	return NULL;
 }
 
-static int ceph_netfs_check_write_begin(struct file *file, loff_t pos, unsigned int len,
+static int ceph_netfs_check_write_begin(struct file *file, uoff_t pos, unsigned int len,
 					struct folio **foliop, void **_fsdata)
 {
 	struct inode *inode = file_inode(file);
diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index 3c32ef41a27f..7e58aec6cdff 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -10,9 +10,9 @@
 #include "internal.h"
 
 static void netfs_cache_expand_readahead(struct netfs_io_request *rreq,
-					 unsigned long long *_start,
-					 unsigned long long *_len,
-					 unsigned long long i_size)
+					 uoff_t *_start,
+					 uoff_t *_len,
+					 uoff_t i_size)
 {
 	struct netfs_cache_resources *cres = &rreq->cache_resources;
 
@@ -134,7 +134,7 @@ static ssize_t netfs_prepare_read_iterator(struct netfs_io_subrequest *subreq,
 
 static enum netfs_io_source netfs_cache_prepare_read(struct netfs_io_request *rreq,
 						     struct netfs_io_subrequest *subreq,
-						     loff_t i_size)
+						     uoff_t i_size)
 {
 	struct netfs_cache_resources *cres = &rreq->cache_resources;
 	enum netfs_io_source source;
@@ -214,8 +214,8 @@ static void netfs_issue_read(struct netfs_io_request *rreq,
 static void netfs_read_to_pagecache(struct netfs_io_request *rreq,
 				    struct readahead_control *ractl)
 {
-	unsigned long long start = rreq->start;
 	ssize_t size = rreq->len;
+	uoff_t start = rreq->start;
 	int ret = 0;
 
 	do {
@@ -237,8 +237,8 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq,
 		source = netfs_cache_prepare_read(rreq, subreq, rreq->i_size);
 		subreq->source = source;
 		if (source == NETFS_DOWNLOAD_FROM_SERVER) {
-			unsigned long long zero_point = netfs_read_zero_point(rreq->inode);
-			unsigned long long zp = umin(zero_point, rreq->i_size);
+			uoff_t zero_point = netfs_read_zero_point(rreq->inode);
+			uoff_t zp = umin(zero_point, rreq->i_size);
 			size_t len = subreq->len;
 
 			if (unlikely(rreq->origin == NETFS_READ_SINGLE))
@@ -342,7 +342,7 @@ void netfs_readahead(struct readahead_control *ractl)
 {
 	struct netfs_io_request *rreq;
 	struct netfs_inode *ictx = netfs_inode(ractl->mapping->host);
-	unsigned long long start = readahead_pos(ractl);
+	uoff_t start = readahead_pos(ractl);
 	size_t size = readahead_length(ractl);
 	int ret;
 
@@ -564,11 +564,11 @@ EXPORT_SYMBOL(netfs_read_folio);
  * If any of these criteria are met, then zero out the unwritten parts
  * of the folio and return true. Otherwise, return false.
  */
-static bool netfs_skip_folio_read(struct folio *folio, loff_t pos, size_t len,
+static bool netfs_skip_folio_read(struct folio *folio, uoff_t pos, size_t len,
 				 bool always_fill)
 {
 	struct inode *inode = folio_inode(folio);
-	loff_t i_size = i_size_read(inode);
+	uoff_t i_size = i_size_read(inode);
 	size_t offset = offset_in_folio(folio, pos);
 	size_t plen = folio_size(folio);
 
@@ -633,7 +633,7 @@ static bool netfs_skip_folio_read(struct folio *folio, loff_t pos, size_t len,
  */
 int netfs_write_begin(struct netfs_inode *ctx,
 		      struct file *file, struct address_space *mapping,
-		      loff_t pos, unsigned int len, struct folio **_folio,
+		      uoff_t pos, unsigned int len, struct folio **_folio,
 		      void **_fsdata)
 {
 	struct netfs_io_request *rreq;
@@ -729,7 +729,7 @@ int netfs_prefetch_for_write(struct file *file, struct folio *folio,
 	struct netfs_io_request *rreq;
 	struct address_space *mapping = folio->mapping;
 	struct netfs_inode *ctx = netfs_inode(mapping->host);
-	unsigned long long start = folio_pos(folio);
+	uoff_t start = folio_pos(folio);
 	size_t flen = folio_size(folio);
 	int ret;
 
diff --git a/fs/netfs/buffered_write.c b/fs/netfs/buffered_write.c
index 2cdb68e6b16f..df496873e4f4 100644
--- a/fs/netfs/buffered_write.c
+++ b/fs/netfs/buffered_write.c
@@ -17,7 +17,7 @@
  * as possible to hold as much of the remaining length as possible in one go.
  */
 static struct folio *netfs_grab_folio_for_write(struct address_space *mapping,
-						loff_t pos, size_t part)
+						uoff_t pos, size_t part)
 {
 	pgoff_t index = pos / PAGE_SIZE;
 	fgf_t fgp_flags = FGP_WRITEBEGIN;
@@ -35,9 +35,9 @@ static struct folio *netfs_grab_folio_for_write(struct address_space *mapping,
  * the values actually are.
  */
 void netfs_update_i_size(struct netfs_inode *ctx, struct inode *inode,
-			 loff_t pos, size_t copied)
+			 uoff_t pos, size_t copied)
 {
-	loff_t i_size, end = pos + copied;
+	uoff_t i_size, end = pos + copied;
 	blkcnt_t add;
 	size_t gap;
 
@@ -102,7 +102,7 @@ ssize_t netfs_perform_write(struct kiocb *iocb, struct iov_iter *iter,
 	struct folio *folio = NULL, *writethrough = NULL;
 	unsigned int bdp_flags = (iocb->ki_flags & IOCB_NOWAIT) ? BDP_ASYNC : 0;
 	ssize_t written = 0, ret, ret2;
-	loff_t pos = iocb->ki_pos;
+	uoff_t pos = iocb->ki_pos;
 	size_t max_chunk = mapping_max_folio_size(mapping);
 	bool maybe_trouble = false;
 
@@ -134,7 +134,7 @@ ssize_t netfs_perform_write(struct kiocb *iocb, struct iov_iter *iter,
 		enum netfs_folio_trace trace;
 		struct netfs_folio *finfo;
 		struct netfs_group *group;
-		unsigned long long fpos;
+		uoff_t fpos;
 		size_t flen;
 		size_t offset;	/* Offset into pagecache folio */
 		size_t part;	/* Bytes to write to folio */
diff --git a/fs/netfs/direct_read.c b/fs/netfs/direct_read.c
index 6a8fb0d55e04..aa10af5171a8 100644
--- a/fs/netfs/direct_read.c
+++ b/fs/netfs/direct_read.c
@@ -47,8 +47,8 @@ static void netfs_prepare_dio_read_iterator(struct netfs_io_subrequest *subreq)
  */
 static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 {
-	unsigned long long start = rreq->start;
 	ssize_t size = rreq->len;
+	uoff_t start = rreq->start;
 	int ret;
 
 	do {
diff --git a/fs/netfs/direct_write.c b/fs/netfs/direct_write.c
index b04019097ab8..47ec47e3a95b 100644
--- a/fs/netfs/direct_write.c
+++ b/fs/netfs/direct_write.c
@@ -216,9 +216,9 @@ ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *
 						  struct netfs_group *netfs_group)
 {
 	struct netfs_io_request *wreq;
-	unsigned long long start = iocb->ki_pos;
-	unsigned long long end = start + iov_iter_count(iter);
 	ssize_t ret, n;
+	uoff_t start = iocb->ki_pos;
+	uoff_t end = start + iov_iter_count(iter);
 	size_t len = iov_iter_count(iter);
 	bool async = !is_sync_kiocb(iocb);
 
@@ -327,8 +327,8 @@ ssize_t netfs_unbuffered_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct inode *inode = mapping->host;
 	struct netfs_inode *ictx = netfs_inode(inode);
 	ssize_t ret;
-	loff_t pos = iocb->ki_pos;
-	unsigned long long end = pos + iov_iter_count(from) - 1;
+	uoff_t pos = iocb->ki_pos;
+	uoff_t end = pos + iov_iter_count(from) - 1;
 
 	_enter("%llx,%zx,%llx", pos, iov_iter_count(from), i_size_read(inode));
 
diff --git a/fs/netfs/fscache_cookie.c b/fs/netfs/fscache_cookie.c
index 3d56fc73435f..5a226f9cbdea 100644
--- a/fs/netfs/fscache_cookie.c
+++ b/fs/netfs/fscache_cookie.c
@@ -327,7 +327,7 @@ static struct fscache_cookie *fscache_alloc_cookie(
 	u8 advice,
 	const void *index_key, size_t index_key_len,
 	const void *aux_data, size_t aux_data_len,
-	loff_t object_size)
+	uoff_t object_size)
 {
 	struct fscache_cookie *cookie;
 
@@ -452,7 +452,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	u8 advice,
 	const void *index_key, size_t index_key_len,
 	const void *aux_data, size_t aux_data_len,
-	loff_t object_size)
+	uoff_t object_size)
 {
 	struct fscache_cookie *cookie;
 
@@ -663,7 +663,7 @@ static void fscache_unuse_cookie_locked(struct fscache_cookie *cookie)
  * Stop using the cookie for I/O.
  */
 void __fscache_unuse_cookie(struct fscache_cookie *cookie,
-			    const void *aux_data, const loff_t *object_size)
+			    const void *aux_data, const uoff_t *object_size)
 {
 	unsigned int debug_id = cookie->debug_id;
 	unsigned int r = refcount_read(&cookie->ref);
@@ -1049,7 +1049,7 @@ static void fscache_perform_invalidation(struct fscache_cookie *cookie)
  * Invalidate an object.
  */
 void __fscache_invalidate(struct fscache_cookie *cookie,
-			  const void *aux_data, loff_t new_size,
+			  const void *aux_data, uoff_t new_size,
 			  unsigned int flags)
 {
 	bool is_caching;
diff --git a/fs/netfs/fscache_io.c b/fs/netfs/fscache_io.c
index 37f05b4d3469..8bca63721eeb 100644
--- a/fs/netfs/fscache_io.c
+++ b/fs/netfs/fscache_io.c
@@ -162,7 +162,7 @@ EXPORT_SYMBOL(__fscache_begin_write_operation);
 struct fscache_write_request {
 	struct netfs_cache_resources cache_resources;
 	struct address_space	*mapping;
-	loff_t			start;
+	uoff_t			start;
 	size_t			len;
 	bool			set_bits;
 	bool			using_pgpriv2;
@@ -171,7 +171,7 @@ struct fscache_write_request {
 };
 
 void __fscache_clear_page_bits(struct address_space *mapping,
-			       loff_t start, size_t len)
+			       uoff_t start, size_t len)
 {
 	pgoff_t first = start / PAGE_SIZE;
 	pgoff_t last = (start + len - 1) / PAGE_SIZE;
@@ -208,7 +208,7 @@ static void fscache_wreq_done(void *priv, ssize_t transferred_or_error)
 
 void __fscache_write_to_cache(struct fscache_cookie *cookie,
 			      struct address_space *mapping,
-			      loff_t start, size_t len, loff_t i_size,
+			      uoff_t start, size_t len, uoff_t i_size,
 			      netfs_io_terminated_t term_func,
 			      void *term_func_priv,
 			      bool using_pgpriv2, bool cond)
@@ -267,7 +267,7 @@ EXPORT_SYMBOL(__fscache_write_to_cache);
 /*
  * Change the size of a backing object.
  */
-void __fscache_resize_cookie(struct fscache_cookie *cookie, loff_t new_size)
+void __fscache_resize_cookie(struct fscache_cookie *cookie, uoff_t new_size)
 {
 	struct netfs_cache_resources cres;
 
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index f92281a611de..4ea3ef8b3bb0 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -33,7 +33,7 @@ int netfs_prefetch_for_write(struct file *file, struct folio *folio,
  * buffered_write.c
  */
 void netfs_update_i_size(struct netfs_inode *ctx, struct inode *inode,
-			 loff_t pos, size_t copied);
+			 uoff_t pos, size_t copied);
 
 /*
  * main.c
@@ -85,7 +85,7 @@ void netfs_wait_for_paused_write(struct netfs_io_request *rreq);
  */
 struct netfs_io_request *netfs_alloc_request(struct address_space *mapping,
 					     struct file *file,
-					     loff_t start, size_t len,
+					     uoff_t start, size_t len,
 					     enum netfs_io_origin origin);
 void netfs_get_request(struct netfs_io_request *rreq, enum netfs_rreq_ref_trace what);
 void netfs_clear_subrequests(struct netfs_io_request *rreq);
@@ -201,11 +201,11 @@ void netfs_write_collection_worker(struct work_struct *work);
  */
 struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 						struct file *file,
-						loff_t start,
+						uoff_t start,
 						enum netfs_io_origin origin);
 void netfs_prepare_write(struct netfs_io_request *wreq,
 			 struct netfs_io_stream *stream,
-			 loff_t start);
+			 uoff_t start);
 void netfs_reissue_write(struct netfs_io_stream *stream,
 			 struct netfs_io_subrequest *subreq,
 			 struct iov_iter *source);
@@ -213,7 +213,7 @@ void netfs_issue_write(struct netfs_io_request *wreq,
 		       struct netfs_io_stream *stream);
 size_t netfs_advance_write(struct netfs_io_request *wreq,
 			   struct netfs_io_stream *stream,
-			   loff_t start, size_t len, bool to_eof);
+			   uoff_t start, size_t len, bool to_eof);
 struct netfs_io_request *netfs_begin_writethrough(struct kiocb *iocb, size_t len);
 int netfs_advance_writethrough(struct netfs_io_request *wreq, struct writeback_control *wbc,
 			       struct folio *folio, size_t copied, bool to_page_end,
diff --git a/fs/netfs/iterator.c b/fs/netfs/iterator.c
index b375567e0520..eb1efb17f53a 100644
--- a/fs/netfs/iterator.c
+++ b/fs/netfs/iterator.c
@@ -209,7 +209,7 @@ static size_t netfs_limit_xarray(const struct iov_iter *iter, size_t start_offse
 {
 	struct folio *folio;
 	unsigned int nsegs = 0;
-	loff_t pos = iter->xarray_start + iter->iov_offset;
+	uoff_t pos = iter->xarray_start + iter->iov_offset;
 	pgoff_t index = pos / PAGE_SIZE;
 	size_t span = 0, n = iter->count;
 
diff --git a/fs/netfs/misc.c b/fs/netfs/misc.c
index 5d554512ed23..f58a0d45e614 100644
--- a/fs/netfs/misc.c
+++ b/fs/netfs/misc.c
@@ -193,7 +193,7 @@ void netfs_clear_inode_writeback(struct inode *inode, const void *aux)
 	struct fscache_cookie *cookie = netfs_i_cookie(netfs_inode(inode));
 
 	if (inode_state_read_once(inode) & I_PINNING_NETFS_WB) {
-		loff_t i_size = i_size_read(inode);
+		uoff_t i_size = i_size_read(inode);
 		fscache_unuse_cookie(cookie, aux, &i_size);
 	}
 }
@@ -218,8 +218,8 @@ void netfs_invalidate_folio(struct folio *folio, size_t offset, size_t length)
 	_enter("{%lx},%zx,%zx", folio->index, offset, length);
 
 	if (offset == 0 && length == flen) {
-		unsigned long long i_size, remote_i_size, zero_point;
-		unsigned long long fpos = folio_pos(folio), end;
+		uoff_t i_size, remote_i_size, zero_point;
+		uoff_t fpos = folio_pos(folio), end;
 
 		netfs_read_sizes(inode, &i_size, &remote_i_size, &zero_point);
 		end = umin(fpos + flen, i_size);
@@ -305,7 +305,7 @@ bool netfs_release_folio(struct folio *folio, gfp_t gfp)
 {
 	struct inode *inode = folio_inode(folio);
 	struct netfs_inode *ctx = netfs_inode(inode);
-	unsigned long long i_size, remote_i_size, zero_point, end;
+	uoff_t i_size, remote_i_size, zero_point, end;
 
 	if (folio_test_dirty(folio))
 		return false;
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 7f6a3e912602..3460aa1c4af1 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -16,7 +16,7 @@ static void netfs_free_request(struct work_struct *work);
  */
 struct netfs_io_request *netfs_alloc_request(struct address_space *mapping,
 					     struct file *file,
-					     loff_t start, size_t len,
+					     uoff_t start, size_t len,
 					     enum netfs_io_origin origin)
 {
 	static atomic_t debug_ids;
diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index 723b479ef606..a29b694ce1e8 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -130,8 +130,8 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 				     unsigned int *notes)
 {
 	struct folio_queue *folioq = rreq->buffer.tail;
-	unsigned long long collected_to = rreq->collected_to;
 	unsigned int slot = rreq->buffer.first_tail_slot;
+	uoff_t collected_to = rreq->collected_to;
 
 	if (rreq->cleaned_to >= rreq->collected_to)
 		return;
@@ -149,7 +149,7 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 
 	for (;;) {
 		struct folio *folio;
-		unsigned long long fpos = rreq->cleaned_to, fend;
+		uoff_t fpos = rreq->cleaned_to, fend;
 		size_t fsize;
 
 		if (*notes & COPY_TO_CACHE)
diff --git a/fs/netfs/read_pgpriv2.c b/fs/netfs/read_pgpriv2.c
index c31190993b76..ac16bb8210d1 100644
--- a/fs/netfs/read_pgpriv2.c
+++ b/fs/netfs/read_pgpriv2.c
@@ -20,7 +20,7 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 {
 	struct netfs_io_stream *cache = &creq->io_streams[1];
 	size_t fsize = folio_size(folio), flen = fsize;
-	loff_t fpos = folio_pos(folio), i_size;
+	uoff_t fpos = folio_pos(folio), i_size;
 	bool to_eof = false;
 
 	_enter("");
@@ -172,8 +172,8 @@ void netfs_pgpriv2_end_copy_to_cache(struct netfs_io_request *rreq)
 bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 {
 	struct folio_queue *folioq = creq->buffer.tail;
-	unsigned long long collected_to = creq->collected_to;
 	unsigned int slot = creq->buffer.first_tail_slot;
+	uoff_t collected_to = creq->collected_to;
 	bool made_progress = false;
 
 	if (slot >= folioq_nr_slots(folioq)) {
@@ -183,7 +183,7 @@ bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 
 	for (;;) {
 		struct folio *folio;
-		unsigned long long fpos, fend;
+		uoff_t fpos, fend;
 		size_t fsize, flen;
 
 		folio = folioq_folio(folioq, slot);
@@ -196,7 +196,7 @@ bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 		fsize = folio_size(folio);
 		flen = fsize;
 
-		fend = min_t(unsigned long long, fpos + flen, creq->i_size);
+		fend = min_t(uoff_t, fpos + flen, creq->i_size);
 
 		trace_netfs_collect_folio(creq, folio, fend, collected_to);
 
diff --git a/fs/netfs/read_retry.c b/fs/netfs/read_retry.c
index 2b42758e01ec..f5c5ed12dd02 100644
--- a/fs/netfs/read_retry.c
+++ b/fs/netfs/read_retry.c
@@ -75,7 +75,7 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 	do {
 		struct netfs_io_subrequest *from, *to, *tmp;
 		struct iov_iter source;
-		unsigned long long start, len;
+		uoff_t start, len;
 		size_t part;
 		bool boundary = false, subreq_superfluous = false;
 
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index 210eb8f3958d..100a5038c61e 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -67,7 +67,7 @@ int netfs_folio_written_back(struct folio *folio)
 		/* Streaming writes cannot be redirtied whilst under writeback,
 		 * so discard the streaming record.
 		 */
-		unsigned long long fend;
+		uoff_t fend;
 
 		fend = folio_pos(folio) + finfo->dirty_offset + finfo->dirty_len;
 		spin_lock(&ictx->inode.i_lock);
@@ -115,8 +115,8 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 					  unsigned int *notes)
 {
 	struct folio_queue *folioq = wreq->buffer.tail;
-	unsigned long long collected_to = wreq->collected_to;
 	unsigned int slot = wreq->buffer.first_tail_slot;
+	uoff_t collected_to = wreq->collected_to;
 
 	if (WARN_ON_ONCE(!folioq)) {
 		pr_err("[!] Writeback unlock found empty rolling buffer!\n");
@@ -140,7 +140,7 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 	for (;;) {
 		struct folio *folio;
 		struct netfs_folio *finfo;
-		unsigned long long fpos, fend;
+		uoff_t fpos, fend;
 		size_t fsize, flen;
 
 		folio = folioq_folio(folioq, slot);
@@ -154,7 +154,7 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		finfo = netfs_folio_info(folio);
 		flen = finfo ? finfo->dirty_offset + finfo->dirty_len : fsize;
 
-		fend = min_t(unsigned long long, fpos + flen, wreq->i_size);
+		fend = min_t(uoff_t, fpos + flen, wreq->i_size);
 
 		trace_netfs_collect_folio(wreq, folio, fend, collected_to);
 
@@ -201,8 +201,8 @@ static void netfs_collect_write_results(struct netfs_io_request *wreq)
 {
 	struct netfs_io_subrequest *front, *remove;
 	struct netfs_io_stream *stream;
-	unsigned long long collected_to, issued_to;
 	unsigned int notes;
+	uoff_t collected_to, issued_to;
 	int s;
 
 	_enter("%llx-%llx", wreq->start, wreq->start + wreq->len);
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 2d9cfcd43658..1a1f4efcaefd 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -89,7 +89,7 @@ static void netfs_kill_dirty_pages(struct address_space *mapping,
  */
 struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 						struct file *file,
-						loff_t start,
+						uoff_t start,
 						enum netfs_io_origin origin)
 {
 	struct netfs_io_request *wreq;
@@ -156,7 +156,7 @@ EXPORT_SYMBOL(netfs_prepare_write_failed);
  */
 void netfs_prepare_write(struct netfs_io_request *wreq,
 			 struct netfs_io_stream *stream,
-			 loff_t start)
+			 uoff_t start)
 {
 	struct netfs_io_subrequest *subreq;
 	struct iov_iter *wreq_iter = &wreq->buffer.iter;
@@ -277,7 +277,7 @@ void netfs_issue_write(struct netfs_io_request *wreq,
  */
 size_t netfs_advance_write(struct netfs_io_request *wreq,
 			   struct netfs_io_stream *stream,
-			   loff_t start, size_t len, bool to_eof)
+			   uoff_t start, size_t len, bool to_eof)
 {
 	struct netfs_io_subrequest *subreq = stream->construct;
 	size_t part;
@@ -328,7 +328,7 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	struct netfs_folio *finfo;
 	size_t iter_off = 0;
 	size_t fsize = folio_size(folio), flen = fsize, foff = 0;
-	loff_t fpos = folio_pos(folio), i_size;
+	uoff_t fpos = folio_pos(folio), i_size;
 	bool to_eof = false, streamw = false;
 	bool debug = false;
 
@@ -719,7 +719,7 @@ static int netfs_write_folio_single(struct netfs_io_request *wreq,
 	struct netfs_io_stream *stream;
 	size_t iter_off = 0;
 	size_t fsize = folio_size(folio), flen;
-	loff_t fpos = folio_pos(folio);
+	uoff_t fpos = folio_pos(folio);
 	ssize_t ret;
 	bool to_eof = false;
 	bool no_debug = false;
diff --git a/fs/netfs/write_retry.c b/fs/netfs/write_retry.c
index 058bc7a166a5..6cd584242af2 100644
--- a/fs/netfs/write_retry.c
+++ b/fs/netfs/write_retry.c
@@ -55,7 +55,7 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 	do {
 		struct netfs_io_subrequest *subreq = NULL, *from, *to, *tmp;
 		struct iov_iter source;
-		unsigned long long start, len;
+		uoff_t start, len;
 		size_t part;
 		bool boundary = false;
 
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 4c91a019972b..ee524c863fa9 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -67,7 +67,7 @@ struct fscache_cache_ops {
 
 	/* Change the size of a data object */
 	void (*resize_cookie)(struct netfs_cache_resources *cres,
-			      loff_t new_size);
+			      uoff_t new_size);
 
 	/* Invalidate an object */
 	bool (*invalidate_cookie)(struct fscache_cookie *cookie);
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index 58fdb9605425..e19fca38382b 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -112,7 +112,7 @@ struct fscache_cookie {
 	struct list_head		proc_link;	/* Link in proc list */
 	struct list_head		commit_link;	/* Link in commit queue */
 	struct work_struct		work;		/* Commit/relinq/withdraw work */
-	loff_t				object_size;	/* Size of the netfs object */
+	uoff_t				object_size;	/* Size of the netfs object */
 	unsigned long			unused_at;	/* Time at which unused (jiffies) */
 	unsigned long			flags;
 #define FSCACHE_COOKIE_RELINQUISHED	0		/* T if cookie has been relinquished */
@@ -163,22 +163,22 @@ extern struct fscache_cookie *__fscache_acquire_cookie(
 	u8,
 	const void *, size_t,
 	const void *, size_t,
-	loff_t);
+	uoff_t);
 extern void __fscache_use_cookie(struct fscache_cookie *, bool);
-extern void __fscache_unuse_cookie(struct fscache_cookie *, const void *, const loff_t *);
+extern void __fscache_unuse_cookie(struct fscache_cookie *, const void *, const uoff_t *);
 extern void __fscache_relinquish_cookie(struct fscache_cookie *, bool);
-extern void __fscache_resize_cookie(struct fscache_cookie *, loff_t);
-extern void __fscache_invalidate(struct fscache_cookie *, const void *, loff_t, unsigned int);
+extern void __fscache_resize_cookie(struct fscache_cookie *, uoff_t);
+extern void __fscache_invalidate(struct fscache_cookie *, const void *, uoff_t, unsigned int);
 extern int __fscache_begin_read_operation(struct netfs_cache_resources *, struct fscache_cookie *);
 extern int __fscache_begin_write_operation(struct netfs_cache_resources *, struct fscache_cookie *);
 
 void __fscache_write_to_cache(struct fscache_cookie *cookie,
 			      struct address_space *mapping,
-			      loff_t start, size_t len, loff_t i_size,
+			      uoff_t start, size_t len, uoff_t i_size,
 			      netfs_io_terminated_t term_func,
 			      void *term_func_priv,
 			      bool using_pgpriv2, bool cond);
-extern void __fscache_clear_page_bits(struct address_space *, loff_t, size_t);
+extern void __fscache_clear_page_bits(struct address_space *, uoff_t, size_t);
 
 /**
  * fscache_acquire_volume - Register a volume as desiring caching services
@@ -249,7 +249,7 @@ struct fscache_cookie *fscache_acquire_cookie(struct fscache_volume *volume,
 					      size_t index_key_len,
 					      const void *aux_data,
 					      size_t aux_data_len,
-					      loff_t object_size)
+					      uoff_t object_size)
 {
 	if (!fscache_volume_valid(volume))
 		return NULL;
@@ -286,7 +286,7 @@ static inline void fscache_use_cookie(struct fscache_cookie *cookie,
  */
 static inline void fscache_unuse_cookie(struct fscache_cookie *cookie,
 					const void *aux_data,
-					const loff_t *object_size)
+					const uoff_t *object_size)
 {
 	if (fscache_cookie_valid(cookie))
 		__fscache_unuse_cookie(cookie, aux_data, object_size);
@@ -327,7 +327,7 @@ static inline void *fscache_get_aux(struct fscache_cookie *cookie)
  */
 static inline
 void fscache_update_aux(struct fscache_cookie *cookie,
-			const void *aux_data, const loff_t *object_size)
+			const void *aux_data, const uoff_t *object_size)
 {
 	void *p = fscache_get_aux(cookie);
 
@@ -343,7 +343,7 @@ extern atomic_t fscache_n_updates;
 
 static inline
 void __fscache_update_cookie(struct fscache_cookie *cookie, const void *aux_data,
-			     const loff_t *object_size)
+			     const uoff_t *object_size)
 {
 #ifdef CONFIG_FSCACHE_STATS
 	atomic_inc(&fscache_n_updates);
@@ -369,7 +369,7 @@ void __fscache_update_cookie(struct fscache_cookie *cookie, const void *aux_data
  */
 static inline
 void fscache_update_cookie(struct fscache_cookie *cookie, const void *aux_data,
-			   const loff_t *object_size)
+			   const uoff_t *object_size)
 {
 	if (fscache_cookie_enabled(cookie))
 		__fscache_update_cookie(cookie, aux_data, object_size);
@@ -386,7 +386,7 @@ void fscache_update_cookie(struct fscache_cookie *cookie, const void *aux_data,
  * description.
  */
 static inline
-void fscache_resize_cookie(struct fscache_cookie *cookie, loff_t new_size)
+void fscache_resize_cookie(struct fscache_cookie *cookie, uoff_t new_size)
 {
 	if (fscache_cookie_enabled(cookie))
 		__fscache_resize_cookie(cookie, new_size);
@@ -413,7 +413,7 @@ void fscache_resize_cookie(struct fscache_cookie *cookie, loff_t new_size)
  */
 static inline
 void fscache_invalidate(struct fscache_cookie *cookie,
-			const void *aux_data, loff_t size, unsigned int flags)
+			const void *aux_data, uoff_t size, unsigned int flags)
 {
 	if (fscache_cookie_enabled(cookie))
 		__fscache_invalidate(cookie, aux_data, size, flags);
@@ -502,7 +502,7 @@ static inline void fscache_end_operation(struct netfs_cache_resources *cres)
  */
 static inline
 int fscache_read(struct netfs_cache_resources *cres,
-		 loff_t start_pos,
+		 uoff_t start_pos,
 		 struct iov_iter *iter,
 		 enum netfs_read_from_hole read_hole,
 		 netfs_io_terminated_t term_func,
@@ -561,7 +561,7 @@ int fscache_begin_write_operation(struct netfs_cache_resources *cres,
  */
 static inline
 int fscache_write(struct netfs_cache_resources *cres,
-		  loff_t start_pos,
+		  uoff_t start_pos,
 		  struct iov_iter *iter,
 		  netfs_io_terminated_t term_func,
 		  void *term_func_priv)
@@ -581,7 +581,7 @@ int fscache_write(struct netfs_cache_resources *cres,
  * waiting.
  */
 static inline void fscache_clear_page_bits(struct address_space *mapping,
-					   loff_t start, size_t len,
+					   uoff_t start, size_t len,
 					   bool caching)
 {
 	if (caching)
@@ -615,7 +615,7 @@ static inline void fscache_clear_page_bits(struct address_space *mapping,
  */
 static inline void fscache_write_to_cache(struct fscache_cookie *cookie,
 					  struct address_space *mapping,
-					  loff_t start, size_t len, loff_t i_size,
+					  uoff_t start, size_t len, uoff_t i_size,
 					  netfs_io_terminated_t term_func,
 					  void *term_func_priv,
 					  bool using_pgpriv2, bool caching)
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index a8702bd52d3a..8c78c91fefd9 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -62,8 +62,8 @@ struct netfs_inode {
 	struct fscache_cookie	*cache;
 #endif
 	struct list_head	wb_queue;	/* Queue of processes wanting to do writeback */
-	loff_t			_remote_i_size;	/* Size of the remote file */
-	loff_t			_zero_point;	/* Size after which we assume there's no data
+	uoff_t			_remote_i_size;	/* Size of the remote file */
+	uoff_t			_zero_point;	/* Size after which we assume there's no data
 						 * on the server */
 	spinlock_t		lock;		/* Lock covering wb_queue */
 	atomic_t		io_count;	/* Number of outstanding reqs */
@@ -142,7 +142,7 @@ struct netfs_io_stream {
 	void (*issue_write)(struct netfs_io_subrequest *subreq);
 	/* Collection tracking */
 	struct list_head	subrequests;	/* Contributory I/O operations */
-	unsigned long long	collected_to;	/* Position we've collected results to */
+	uoff_t			collected_to;	/* Position we've collected results to */
 	size_t			transferred;	/* The amount transferred from this stream */
 	unsigned short		error;		/* Aggregate error for the stream */
 	enum netfs_io_source	source;		/* Where to read from/write to */
@@ -177,7 +177,7 @@ struct netfs_io_subrequest {
 	struct work_struct	work;
 	struct list_head	rreq_link;	/* Link in rreq->subrequests */
 	struct iov_iter		io_iter;	/* Iterator for this subrequest */
-	unsigned long long	start;		/* Where to start the I/O */
+	uoff_t			start;		/* Where to start the I/O */
 	size_t			len;		/* Size of the I/O */
 	size_t			transferred;	/* Amount of data transferred */
 	refcount_t		ref;
@@ -243,17 +243,17 @@ struct netfs_io_request {
 	void			*netfs_priv;	/* Private data for the netfs */
 	void			*netfs_priv2;	/* Private data for the netfs */
 	struct bio_vec		*direct_bv;	/* DIO buffer list (when handling iovec-iter) */
-	unsigned long long	submitted;	/* Amount submitted for I/O so far */
-	unsigned long long	len;		/* Length of the request */
+	uoff_t			submitted;	/* Amount submitted for I/O so far */
+	uoff_t			len;		/* Length of the request */
 	size_t			transferred;	/* Amount to be indicated as transferred */
 	size_t			progress_at;	/* Report read progress when hit this much read */
 	long			error;		/* 0 or error that occurred */
-	unsigned long long	i_size;		/* Size of the file */
-	unsigned long long	start;		/* Start position */
+	uoff_t			i_size;		/* Size of the file */
+	uoff_t			start;		/* Start position */
 	atomic64_t		issued_to;	/* Write issuer folio cursor */
-	unsigned long long	collected_to;	/* Point we've collected to */
-	unsigned long long	cleaned_to;	/* Position we've cleaned folios to */
-	unsigned long long	abandon_to;	/* Position to abandon folios to */
+	uoff_t			collected_to;	/* Point we've collected to */
+	uoff_t			cleaned_to;	/* Position we've cleaned folios to */
+	uoff_t			abandon_to;	/* Position to abandon folios to */
 	const struct folio	*no_unlock_folio; /* Don't unlock this folio after read */
 	gfp_t			gfp;		/* GFP flags to use */
 	unsigned int		direct_bv_count; /* Number of elements in direct_bv[] */
@@ -298,12 +298,12 @@ struct netfs_request_ops {
 	int (*prepare_read)(struct netfs_io_subrequest *subreq);
 	void (*issue_read)(struct netfs_io_subrequest *subreq);
 	bool (*is_still_valid)(struct netfs_io_request *rreq);
-	int (*check_write_begin)(struct file *file, loff_t pos, unsigned len,
+	int (*check_write_begin)(struct file *file, uoff_t pos, unsigned len,
 				 struct folio **foliop, void **_fsdata);
 	void (*done)(struct netfs_io_request *rreq);
 
 	/* Modification handling */
-	void (*update_i_size)(struct inode *inode, loff_t i_size);
+	void (*update_i_size)(struct inode *inode, uoff_t i_size);
 	void (*post_modify)(struct inode *inode);
 
 	/* Write request handling */
@@ -331,7 +331,7 @@ struct netfs_cache_ops {
 
 	/* Read data from the cache */
 	int (*read)(struct netfs_cache_resources *cres,
-		    loff_t start_pos,
+		    uoff_t start_pos,
 		    struct iov_iter *iter,
 		    enum netfs_read_from_hole read_hole,
 		    netfs_io_terminated_t term_func,
@@ -339,7 +339,7 @@ struct netfs_cache_ops {
 
 	/* Write data to the cache */
 	int (*write)(struct netfs_cache_resources *cres,
-		     loff_t start_pos,
+		     uoff_t start_pos,
 		     struct iov_iter *iter,
 		     netfs_io_terminated_t term_func,
 		     void *term_func_priv);
@@ -349,15 +349,15 @@ struct netfs_cache_ops {
 
 	/* Expand readahead request */
 	void (*expand_readahead)(struct netfs_cache_resources *cres,
-				 unsigned long long *_start,
-				 unsigned long long *_len,
-				 unsigned long long i_size);
+				 uoff_t *_start,
+				 uoff_t *_len,
+				 uoff_t i_size);
 
 	/* Prepare a read operation, shortening it to a cached/uncached
 	 * boundary as appropriate.
 	 */
 	enum netfs_io_source (*prepare_read)(struct netfs_io_subrequest *subreq,
-					     unsigned long long i_size);
+					     uoff_t i_size);
 
 	/* Prepare a write subrequest, working out if we're allowed to do it
 	 * and finding out the maximum amount of data to gather before
@@ -370,15 +370,15 @@ struct netfs_cache_ops {
 	 * actually do.
 	 */
 	int (*prepare_write)(struct netfs_cache_resources *cres,
-			     loff_t *_start, size_t *_len, size_t upper_len,
-			     loff_t i_size, bool no_space_allocated_yet);
+			     uoff_t *_start, size_t *_len, size_t upper_len,
+			     uoff_t i_size, bool no_space_allocated_yet);
 
 	/* Query the occupancy of the cache in a region, returning where the
 	 * next chunk of data starts and how long it is.
 	 */
 	int (*query_occupancy)(struct netfs_cache_resources *cres,
-			       loff_t start, size_t len, size_t granularity,
-			       loff_t *_data_start, size_t *_data_len);
+			       uoff_t start, size_t len, size_t granularity,
+			       uoff_t *_data_start, size_t *_data_len);
 };
 
 /* High-level read API. */
@@ -409,7 +409,7 @@ struct readahead_control;
 void netfs_readahead(struct readahead_control *);
 int netfs_read_folio(struct file *, struct folio *);
 int netfs_write_begin(struct netfs_inode *, struct file *,
-		      struct address_space *, loff_t pos, unsigned int len,
+		      struct address_space *, uoff_t pos, unsigned int len,
 		      struct folio **, void **fsdata);
 int netfs_writepages(struct address_space *mapping,
 		     struct writeback_control *wbc);
@@ -487,10 +487,10 @@ static inline struct netfs_inode *netfs_inode(struct inode *inode)
  * cmpxchg8b without the need of the lock prefix).  For SMP compiles and 64bit
  * archs it makes no difference if preempt is enabled or not.
  */
-static inline unsigned long long netfs_read_remote_i_size(const struct inode *inode)
+static inline uoff_t netfs_read_remote_i_size(const struct inode *inode)
 {
 	const struct netfs_inode *ictx = container_of(inode, struct netfs_inode, inode);
-	unsigned long long remote_i_size;
+	uoff_t remote_i_size;
 
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	unsigned int seq;
@@ -525,7 +525,7 @@ static inline unsigned long long netfs_read_remote_i_size(const struct inode *in
  * spinning forever.
  */
 static inline void netfs_write_remote_i_size(struct inode *inode,
-					     unsigned long long remote_i_size)
+					     uoff_t remote_i_size)
 {
 	struct netfs_inode *ictx = netfs_inode(inode);
 
@@ -562,10 +562,10 @@ static inline void netfs_write_remote_i_size(struct inode *inode,
  * cmpxchg8b without the need of the lock prefix).  For SMP compiles and 64bit
  * archs it makes no difference if preempt is enabled or not.
  */
-static inline unsigned long long netfs_read_zero_point(const struct inode *inode)
+static inline uoff_t netfs_read_zero_point(const struct inode *inode)
 {
 	struct netfs_inode *ictx = container_of(inode, struct netfs_inode, inode);
-	unsigned long long zero_point;
+	uoff_t zero_point;
 
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	unsigned int seq;
@@ -600,7 +600,7 @@ static inline unsigned long long netfs_read_zero_point(const struct inode *inode
  * forever.
  */
 static inline void netfs_write_zero_point(struct inode *inode,
-					  unsigned long long zero_point)
+					  uoff_t zero_point)
 {
 	struct netfs_inode *ictx = netfs_inode(inode);
 
@@ -641,9 +641,9 @@ static inline void netfs_write_zero_point(struct inode *inode,
  * archs it makes no difference if preempt is enabled or not.
  */
 static inline void netfs_read_sizes(const struct inode *inode,
-				    unsigned long long *i_size,
-				    unsigned long long *remote_i_size,
-				    unsigned long long *zero_point)
+				    uoff_t *i_size,
+				    uoff_t *remote_i_size,
+				    uoff_t *zero_point)
 {
 	const struct netfs_inode *ictx = container_of(inode, struct netfs_inode, inode);
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
@@ -689,9 +689,9 @@ static inline void netfs_read_sizes(const struct inode *inode,
  * forever.
  */
 static inline void netfs_write_sizes(struct inode *inode,
-				     unsigned long long i_size,
-				     unsigned long long remote_i_size,
-				     unsigned long long zero_point)
+				     uoff_t i_size,
+				     uoff_t remote_i_size,
+				     uoff_t zero_point)
 {
 	struct netfs_inode *ictx = netfs_inode(inode);
 
@@ -759,7 +759,7 @@ static inline void netfs_inode_init(struct netfs_inode *ctx,
  * Inform the netfs lib that a file got resized so that it can adjust its state.
  */
 static inline void netfs_resize_file(struct netfs_inode *ictx,
-				     unsigned long long new_i_size,
+				     uoff_t new_i_size,
 				     bool changed_on_server)
 {
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
diff --git a/include/trace/events/cachefiles.h b/include/trace/events/cachefiles.h
index 927338f8fe85..4412d8344182 100644
--- a/include/trace/events/cachefiles.h
+++ b/include/trace/events/cachefiles.h
@@ -449,7 +449,7 @@ TRACE_EVENT(cachefiles_vol_coherency,
 
 TRACE_EVENT(cachefiles_prep_read,
 	    TP_PROTO(struct cachefiles_object *obj,
-		     loff_t start,
+		     uoff_t start,
 		     size_t len,
 		     unsigned short flags,
 		     enum netfs_io_source source,
@@ -464,7 +464,7 @@ TRACE_EVENT(cachefiles_prep_read,
 		    __field(enum netfs_io_source,	source)
 		    __field(enum cachefiles_prepare_read_trace,	why)
 		    __field(size_t,			len)
-		    __field(loff_t,			start)
+		    __field(uoff_t,			start)
 		    __field(unsigned int,		netfs_inode)
 		    __field(unsigned int,		cache_inode)
 			     ),
@@ -492,16 +492,16 @@ TRACE_EVENT(cachefiles_prep_read,
 TRACE_EVENT(cachefiles_read,
 	    TP_PROTO(struct cachefiles_object *obj,
 		     struct inode *backer,
-		     loff_t start,
+		     uoff_t start,
 		     size_t len),
 
 	    TP_ARGS(obj, backer, start, len),
 
 	    TP_STRUCT__entry(
-		    __field(unsigned int,			obj)
-		    __field(unsigned int,			backer)
-		    __field(size_t,				len)
-		    __field(loff_t,				start)
+		    __field(unsigned int,	obj)
+		    __field(unsigned int,	backer)
+		    __field(size_t,		len)
+		    __field(uoff_t,		start)
 			     ),
 
 	    TP_fast_assign(
@@ -521,16 +521,16 @@ TRACE_EVENT(cachefiles_read,
 TRACE_EVENT(cachefiles_write,
 	    TP_PROTO(struct cachefiles_object *obj,
 		     struct inode *backer,
-		     loff_t start,
+		     uoff_t start,
 		     size_t len),
 
 	    TP_ARGS(obj, backer, start, len),
 
 	    TP_STRUCT__entry(
-		    __field(unsigned int,			obj)
-		    __field(unsigned int,			backer)
-		    __field(size_t,				len)
-		    __field(loff_t,				start)
+		    __field(unsigned int,	obj)
+		    __field(unsigned int,	backer)
+		    __field(size_t,		len)
+		    __field(uoff_t,		start)
 			     ),
 
 	    TP_fast_assign(
@@ -549,7 +549,7 @@ TRACE_EVENT(cachefiles_write,
 
 TRACE_EVENT(cachefiles_trunc,
 	    TP_PROTO(struct cachefiles_object *obj, struct inode *backer,
-		     loff_t from, loff_t to, enum cachefiles_trunc_trace why),
+		     uoff_t from, uoff_t to, enum cachefiles_trunc_trace why),
 
 	    TP_ARGS(obj, backer, from, to, why),
 
@@ -557,8 +557,8 @@ TRACE_EVENT(cachefiles_trunc,
 		    __field(unsigned int,			obj)
 		    __field(unsigned int,			backer)
 		    __field(enum cachefiles_trunc_trace,	why)
-		    __field(loff_t,				from)
-		    __field(loff_t,				to)
+		    __field(uoff_t,				from)
+		    __field(uoff_t,				to)
 			     ),
 
 	    TP_fast_assign(
diff --git a/include/trace/events/fscache.h b/include/trace/events/fscache.h
index f1a73aa83fbb..8735d428ebd9 100644
--- a/include/trace/events/fscache.h
+++ b/include/trace/events/fscache.h
@@ -460,13 +460,13 @@ TRACE_EVENT(fscache_relinquish,
 	    );
 
 TRACE_EVENT(fscache_invalidate,
-	    TP_PROTO(struct fscache_cookie *cookie, loff_t new_size),
+	    TP_PROTO(struct fscache_cookie *cookie, uoff_t new_size),
 
 	    TP_ARGS(cookie, new_size),
 
 	    TP_STRUCT__entry(
 		    __field(unsigned int,		cookie		)
-		    __field(loff_t,			new_size	)
+		    __field(uoff_t,			new_size	)
 			     ),
 
 	    TP_fast_assign(
@@ -479,14 +479,14 @@ TRACE_EVENT(fscache_invalidate,
 	    );
 
 TRACE_EVENT(fscache_resize,
-	    TP_PROTO(struct fscache_cookie *cookie, loff_t new_size),
+	    TP_PROTO(struct fscache_cookie *cookie, uoff_t new_size),
 
 	    TP_ARGS(cookie, new_size),
 
 	    TP_STRUCT__entry(
 		    __field(unsigned int,		cookie		)
-		    __field(loff_t,			old_size	)
-		    __field(loff_t,			new_size	)
+		    __field(uoff_t,			old_size	)
+		    __field(uoff_t,			new_size	)
 			     ),
 
 	    TP_fast_assign(
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index 8ec10c076875..4f5a447d92b1 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -296,7 +296,7 @@ netfs_folioq_traces;
 
 TRACE_EVENT(netfs_read,
 	    TP_PROTO(struct netfs_io_request *rreq,
-		     loff_t start, size_t len,
+		     uoff_t start, size_t len,
 		     enum netfs_read_trace what),
 
 	    TP_ARGS(rreq, start, len, what),
@@ -304,8 +304,8 @@ TRACE_EVENT(netfs_read,
 	    TP_STRUCT__entry(
 		    __field(unsigned int,		rreq)
 		    __field(unsigned int,		cookie)
-		    __field(loff_t,			i_size)
-		    __field(loff_t,			start)
+		    __field(uoff_t,			i_size)
+		    __field(uoff_t,			start)
 		    __field(size_t,			len)
 		    __field(enum netfs_read_trace,	what)
 		    __field(u64,			netfs_inode)
@@ -372,7 +372,7 @@ TRACE_EVENT(netfs_sreq,
 		    __field(u8,				slot)
 		    __field(size_t,			len)
 		    __field(size_t,			transferred)
-		    __field(loff_t,			start)
+		    __field(uoff_t,			start)
 			     ),
 
 	    TP_fast_assign(
@@ -413,7 +413,7 @@ TRACE_EVENT(netfs_failure,
 		    __field(enum netfs_failure,		what)
 		    __field(size_t,			len)
 		    __field(size_t,			transferred)
-		    __field(loff_t,			start)
+		    __field(uoff_t,			start)
 			     ),
 
 	    TP_fast_assign(
@@ -519,10 +519,10 @@ TRACE_EVENT(netfs_write_iter,
 	    TP_ARGS(iocb, from),
 
 	    TP_STRUCT__entry(
-		    __field(unsigned long long,		start)
-		    __field(size_t,			len)
-		    __field(unsigned int,		flags)
-		    __field(unsigned int,		ino)
+		    __field(uoff_t,		start)
+		    __field(size_t,		len)
+		    __field(unsigned int,	flags)
+		    __field(unsigned int,	ino)
 			     ),
 
 	    TP_fast_assign(
@@ -547,8 +547,8 @@ TRACE_EVENT(netfs_write,
 		    __field(unsigned int,		cookie)
 		    __field(unsigned int,		ino)
 		    __field(enum netfs_write_trace,	what)
-		    __field(unsigned long long,		start)
-		    __field(unsigned long long,		len)
+		    __field(uoff_t,			start)
+		    __field(uoff_t,			len)
 			     ),
 
 	    TP_fast_assign(
@@ -577,10 +577,10 @@ TRACE_EVENT(netfs_copy2cache,
 	    TP_ARGS(rreq, creq),
 
 	    TP_STRUCT__entry(
-		    __field(unsigned int,		rreq)
-		    __field(unsigned int,		creq)
-		    __field(unsigned int,		cookie)
-		    __field(unsigned int,		ino)
+		    __field(unsigned int,	rreq)
+		    __field(unsigned int,	creq)
+		    __field(unsigned int,	cookie)
+		    __field(unsigned int,	ino)
 			     ),
 
 	    TP_fast_assign(
@@ -605,10 +605,10 @@ TRACE_EVENT(netfs_collect,
 	    TP_ARGS(wreq),
 
 	    TP_STRUCT__entry(
-		    __field(unsigned int,		wreq)
-		    __field(unsigned int,		len)
-		    __field(unsigned long long,		transferred)
-		    __field(unsigned long long,		start)
+		    __field(unsigned int,	wreq)
+		    __field(unsigned int,	len)
+		    __field(uoff_t,		transferred)
+		    __field(uoff_t,		start)
 			     ),
 
 	    TP_fast_assign(
@@ -631,12 +631,12 @@ TRACE_EVENT(netfs_collect_sreq,
 	    TP_ARGS(wreq, subreq),
 
 	    TP_STRUCT__entry(
-		    __field(unsigned int,		wreq)
-		    __field(unsigned int,		subreq)
-		    __field(unsigned int,		stream)
-		    __field(unsigned int,		len)
-		    __field(unsigned int,		transferred)
-		    __field(unsigned long long,		start)
+		    __field(unsigned int,	wreq)
+		    __field(unsigned int,	subreq)
+		    __field(unsigned int,	stream)
+		    __field(unsigned int,	len)
+		    __field(unsigned int,	transferred)
+		    __field(uoff_t,		start)
 			     ),
 
 	    TP_fast_assign(
@@ -656,17 +656,16 @@ TRACE_EVENT(netfs_collect_sreq,
 TRACE_EVENT(netfs_collect_folio,
 	    TP_PROTO(const struct netfs_io_request *wreq,
 		     const struct folio *folio,
-		     unsigned long long fend,
-		     unsigned long long collected_to),
+		     uoff_t fend, uoff_t collected_to),
 
 	    TP_ARGS(wreq, folio, fend, collected_to),
 
 	    TP_STRUCT__entry(
 		    __field(unsigned int,	wreq)
 		    __field(unsigned long,	index)
-		    __field(unsigned long long,	fend)
-		    __field(unsigned long long,	cleaned_to)
-		    __field(unsigned long long,	collected_to)
+		    __field(uoff_t,		fend)
+		    __field(uoff_t,		cleaned_to)
+		    __field(uoff_t,		collected_to)
 			     ),
 
 	    TP_fast_assign(
@@ -679,13 +678,13 @@ TRACE_EVENT(netfs_collect_folio,
 
 	    TP_printk("R=%08x ix=%05lx r=%llx-%llx t=%llx/%llx",
 		      __entry->wreq, __entry->index,
-		      (unsigned long long)__entry->index * PAGE_SIZE, __entry->fend,
+		      (uoff_t)__entry->index * PAGE_SIZE, __entry->fend,
 		      __entry->cleaned_to, __entry->collected_to)
 	    );
 
 TRACE_EVENT(netfs_collect_state,
 	    TP_PROTO(const struct netfs_io_request *wreq,
-		     unsigned long long collected_to,
+		     uoff_t collected_to,
 		     unsigned int notes),
 
 	    TP_ARGS(wreq, collected_to, notes),
@@ -693,8 +692,8 @@ TRACE_EVENT(netfs_collect_state,
 	    TP_STRUCT__entry(
 		    __field(unsigned int,	wreq)
 		    __field(unsigned int,	notes)
-		    __field(unsigned long long,	collected_to)
-		    __field(unsigned long long,	cleaned_to)
+		    __field(uoff_t,		collected_to)
+		    __field(uoff_t,		cleaned_to)
 			     ),
 
 	    TP_fast_assign(
@@ -713,7 +712,7 @@ TRACE_EVENT(netfs_collect_state,
 TRACE_EVENT(netfs_collect_gap,
 	    TP_PROTO(const struct netfs_io_request *wreq,
 		     const struct netfs_io_stream *stream,
-		     unsigned long long jump_to, char type),
+		     uoff_t jump_to, char type),
 
 	    TP_ARGS(wreq, stream, jump_to, type),
 
@@ -721,8 +720,8 @@ TRACE_EVENT(netfs_collect_gap,
 		    __field(unsigned int,	wreq)
 		    __field(unsigned char,	stream)
 		    __field(unsigned char,	type)
-		    __field(unsigned long long,	from)
-		    __field(unsigned long long,	to)
+		    __field(uoff_t,		from)
+		    __field(uoff_t,		to)
 			     ),
 
 	    TP_fast_assign(
@@ -747,8 +746,8 @@ TRACE_EVENT(netfs_collect_stream,
 	    TP_STRUCT__entry(
 		    __field(unsigned int,	wreq)
 		    __field(unsigned char,	stream)
-		    __field(unsigned long long,	collected_to)
-		    __field(unsigned long long,	issued_to)
+		    __field(uoff_t,		collected_to)
+		    __field(uoff_t,		issued_to)
 			     ),
 
 	    TP_fast_assign(

