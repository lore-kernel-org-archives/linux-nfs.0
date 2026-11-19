Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795077594;
	b=jDhBFwrzLYHQcL1vC0yTxHv/gFqsixVHzsUQ7V+jlOPtZS0HPZQXyl+ITT/2opoKPUj2
	 7JDazIeuPdmdHLGg0rTDTVWCMI9nreLV3tH344/hCtUv/1ILIMZx0NHJDsb1wT5uSb/fB
	 jZi7Z+3zlm2JPlyUrieKokWSAl/JARQ1ulJOgbDwbygATjwfOonNq3kmTnKnt6XLrLCvZ
	 LleinXZWWCKYYcvp7nb5CvXQqwvhNqbuEUqXj3i2fAhWQxCPpk7IMJHg4+R9k4YSZDpJe
	 5Wd+CLvcERhZ0fzNgIKOudWr0DtLBpTI5AwPOdCYEKvLLVxWaXwAviQhrHz/eqQqPBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795077594;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=9dk9kL49guxKer+r/d3oR1NNShzzS7x0RBJAR6pZ1HE=;
	b=v6fCQwSO1TEW8E0nUNzncXIJPrc08Ogs1z7kwax3NnDoRjw4oOcdbVzMbX7qOtv/qYih
	 imah0TtKsGFRpO3EI/kSa3+kxJFzXDKgpkUDFtZWJ6WpfJ6Fk8Lbok2dzqRDmMwBK+vWh
	 0qxgC7X/0yqJFyF17ppIHCENKGUDwF8iJoSwsrYQPWlhuAVu9g3+3nTHYWXoUr5xQ/jFU
	 o7AnnCeWbOie0CvtDGFuFihIZk7+jC2WkEsphEtlmGlQ5S9W9Bl5VHcuvQ3AZf6euIwZs
	 Kb0FDzc1SQox6O16ZMAmAdGvBYudkA3w2L2DGFJW93g6dBa9AoPWyFHfOhyUQdLwbBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=QCoOG9aA;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A7AF60A5BC1
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 08:39:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8A7AF60A5BC1
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=QCoOG9aA
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795077592;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=9dk9kL49guxKer+r/d3oR1NNShzzS7x0RBJAR6pZ1HE=;
	b=QCoOG9aAKUps8xe0P2Bhs3LUY/UNlz0dH7nKNoNY19jiBKuQrxyiUVA4lJjfrURvvYpoae
	qB5Tp9K6gZP+kB05Rab1PindAdmqtCqjPwVDqHMVQ61WfEHE9Ff+i9T7YMfL64QsdkCYyq
	IWeVcoPHIy3FrO0OWKPo2avmFtk57wA=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-237-XzaoHC6XMK--suRoHKmAMQ-1; Thu,
 19 Nov 2026 03:39:48 -0500
X-MC-Unique: XzaoHC6XMK--suRoHKmAMQ-1
X-Mimecast-MFC-AGG-ID: XzaoHC6XMK--suRoHKmAMQ_1795077586
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id F35F619560A6;
	Thu, 19 Nov 2026 08:39:45 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 4AF4B1956088;
	Thu, 19 Nov 2026 08:39:42 +0000 (UTC)
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
Subject: [PATCH v19 08/17] netfs: Explicitly pass tail padding to netfs_writeback_single()
Date: Thu, 19 Nov 2026 08:38:39 +0000
Message-ID: <20261119083851.3306418-9-dhowells@redhat.com>
In-Reply-To: <20261119083851.3306418-1-dhowells@redhat.com>
References: <20261119083851.3306418-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Change netfs_writeback_single() so that the function is now given an
explicit content length in addition to the buffer iterator.  The buffer
must be rounded out to the cache DIO block size and netfslib will then draw
on this excess space to write padding into the cache beyond the content
length specified.  The caller must also now clear the padding space.

AFS directory code is modified to comply with this, including allocating
pre-zeroed buffer space and clearing excess buffer space if the content is
shrunk by a third party.  It's not done during writeback as that may happen
many times for a directory.

AFS symlink code, however, is modified such that the clearing is done when
the content is written to the cache (expected to be a one-off per symlink,
if it happens).

A further patch will make better use of the two different lengths.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-afs@lists.infradead.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 Documentation/filesystems/netfs_library.rst | 47 +++++++++++++++------
 fs/afs/dir.c                                | 17 ++++++--
 fs/afs/dir_edit.c                           |  2 +-
 fs/afs/symlink.c                            | 16 ++++++-
 fs/netfs/write_issue.c                      | 13 ++++--
 include/linux/netfs.h                       |  2 +-
 6 files changed, 73 insertions(+), 24 deletions(-)

diff --git a/Documentation/filesystems/netfs_library.rst b/Documentation/filesystems/netfs_library.rst
index 215a6621f3d3..1fe110ceb3f1 100644
--- a/Documentation/filesystems/netfs_library.rst
+++ b/Documentation/filesystems/netfs_library.rst
@@ -437,22 +437,43 @@ Monolithic Files API
 
 There is also a special API set for files for which the content must be read in
 a single RPC (and not written back) and is maintained as a monolithic blob
-(e.g. an AFS directory), though it can be stored and updated in the local cache::
+(e.g. an AFS directory), though it can be stored and updated in the local
+cache.
+
+To start with, there's a function to synchronously read the contents of such a
+file into a buffer in a single operation::
+
+	ssize_t netfs_read_single(struct inode *inode,
+				  struct file *file,
+				  struct iov_iter *iter);
+
+If such a file is modified locally, it can be marked dirty with::
 
-	ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_iter *iter);
 	void netfs_single_mark_inode_dirty(struct inode *inode);
+
+which will schedule it for writeback later.  When the writeback eventually
+happens, the filesystem should call::
+
 	int netfs_writeback_single(struct address_space *mapping,
 				   struct writeback_control *wbc,
-				   struct iov_iter *iter);
+				   struct iov_iter *iter,
+				   size_t len);
+
+to write the data to the cache from its writepages method.
 
-The first function reads from a file into the given buffer, reading from the
-cache in preference if the data is cached there; the second function allows the
-inode to be marked dirty, causing a later writeback; and the third function can
-be called from the writeback code to write the data to the cache, if there is
-one.
+In both the read and writeback functions, the buffer needs to be rounded up to
+a multiple of the cache DIO size, with ``iter->count`` indicating the size of
+the buffer.  For the write function, ``len`` should indicate the size of the
+content which may be less than the buffer size.  The gap between ``len`` and the
+buffer size should be cleared by the filesystem as this will be used as padding
+if the write size has to be increased (e.g. for the cache DIO).
+
+Note that, for the moment, rounding the buffer up to a multiple of PAGE_SIZE
+instead of the cache DIO size should suffice.  DIO size > PAGE_SIZE is not
+currently supported.
 
 The inode should be marked ``NETFS_ICTX_SINGLE_NO_UPLOAD`` if this API is to be
-used.  The writeback function requires the buffer to be of ITER_FOLIOQ type.
+used.
 
 Clearing Stale Post-EOF Pagecache
 ---------------------------------
@@ -859,12 +880,12 @@ The methods defined in the table are:
    paths to ask the filesystem to update its idea of the file size.  If not
    given, netfslib will set i_size and i_blocks and update the local cache
    cookie.
-   
+
  * ``post_modify()``
 
    [Optional] This is called after netfslib writes to the pagecache or when it
    allows an mmap'd page to be marked as writable.
-   
+
  * ``begin_writeback()``
 
    [Optional] Netfslib calls this when processing a writeback request if it
@@ -872,7 +893,7 @@ The methods defined in the table are:
    indicating it must be written to the server.  This allows the filesystem to
    only set up writeback resources when it knows it's going to have to perform
    a write.
-   
+
  * ``prepare_write()``
 
    [Optional] This is called to allow the filesystem to limit the size of a
@@ -911,7 +932,7 @@ The methods defined in the table are:
    allows the filesystem to examine the state of the request, the subrequests
    in the indicated stream and of its own data and make adjustments or
    renegotiate resources.
-   
+
  * ``invalidate_cache()``
 
    [Optional] This is called by netfslib to invalidate data stored in the local
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 75f8f70cfeff..51c158d8f723 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -252,7 +252,8 @@ static ssize_t afs_do_read_single(struct afs_vnode *dvnode, struct file *file)
 
 		ret = netfs_alloc_folioq_buffer(NULL,
 						&dvnode->directory, &cur_size, i_size,
-						mapping_gfp_mask(dvnode->netfs.inode.i_mapping));
+						mapping_gfp_mask(dvnode->netfs.inode.i_mapping) |
+						__GFP_ZERO);
 		dvnode->directory_size = cur_size;
 		if (ret < 0)
 			return ret;
@@ -278,6 +279,13 @@ static ssize_t afs_do_read_single(struct afs_vnode *dvnode, struct file *file)
 			if (ret2 < 0)
 				ret = ret2;
 		}
+
+		if (ret >= 0 && ret < dvnode->directory_size) {
+			iov_iter_folio_queue(&iter, ITER_DEST, dvnode->directory,
+					     0, 0, dvnode->directory_size);
+			iov_iter_advance(&iter, ret);
+			iov_iter_zero(dvnode->directory_size - ret, &iter);
+		}
 	}
 
 	return ret;
@@ -2228,9 +2236,10 @@ static int afs_dir_writepages(struct address_space *mapping,
 	}
 
 	if (test_bit(AFS_VNODE_DIR_VALID, &dvnode->flags)) {
-		iov_iter_folio_queue(&iter, ITER_SOURCE, dvnode->directory, 0, 0,
-				     i_size_read(&dvnode->netfs.inode));
-		ret = netfs_writeback_single(mapping, wbc, &iter);
+		iov_iter_folio_queue(&iter, ITER_SOURCE, dvnode->directory,
+				     0, 0, dvnode->directory_size);
+		ret = netfs_writeback_single(mapping, wbc, &iter,
+					     i_size_read(&dvnode->netfs.inode));
 		if (ret == 1)
 			ret = 0; /* Skipped write due to lock conflict. */
 	}
diff --git a/fs/afs/dir_edit.c b/fs/afs/dir_edit.c
index c31303059444..185e8819e424 100644
--- a/fs/afs/dir_edit.c
+++ b/fs/afs/dir_edit.c
@@ -122,7 +122,7 @@ static union afs_xdr_dir_block *afs_dir_get_block(struct afs_dir_iter *iter, siz
 
 		ret = netfs_alloc_folioq_buffer(
 			NULL, &dvnode->directory, &cur_size, blend,
-			mapping_gfp_mask(dvnode->netfs.inode.i_mapping));
+			mapping_gfp_mask(dvnode->netfs.inode.i_mapping) | __GFP_ZERO);
 		dvnode->directory_size = cur_size;
 		if (ret < 0)
 			goto fail;
diff --git a/fs/afs/symlink.c b/fs/afs/symlink.c
index a1dbd552ddff..c18e4f806423 100644
--- a/fs/afs/symlink.c
+++ b/fs/afs/symlink.c
@@ -228,6 +228,10 @@ int afs_readlink(struct dentry *dentry, char __user *buffer, int buflen)
 /*
  * Write the symlink contents to the cache as a single blob.  We then throw
  * away the page we used to receive it.
+ *
+ * Note that the buffer tail is cleared under a shared lock on ->validate_lock
+ * - though hopefully there won't be racing writers since the only
+ * 'modification' is to be either read from the server or locally created.
  */
 int afs_symlink_writepages(struct address_space *mapping,
 			   struct writeback_control *wbc)
@@ -247,9 +251,17 @@ int afs_symlink_writepages(struct address_space *mapping,
 
 	if (vnode->directory &&
 	    atomic64_read(&vnode->cb_expires_at) != AFS_NO_CB_PROMISE) {
+		size_t i_size = i_size_read(&vnode->netfs.inode);
+
+		if (i_size < vnode->directory_size) {
+			iov_iter_folio_queue(&iter, ITER_DEST, vnode->directory, 0, 0,
+					     vnode->directory_size);
+			iov_iter_advance(&iter, i_size);
+			iov_iter_zero(vnode->directory_size - i_size, &iter);
+		}
 		iov_iter_folio_queue(&iter, ITER_SOURCE, vnode->directory, 0, 0,
-				     i_size_read(&vnode->netfs.inode));
-		ret = netfs_writeback_single(mapping, wbc, &iter);
+				     vnode->directory_size);
+		ret = netfs_writeback_single(mapping, wbc, &iter, i_size);
 	}
 
 	if (ret == 0) {
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index f23364116421..63b0e2599c3c 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -749,26 +749,33 @@ static int netfs_write_folio_single(struct netfs_io_request *wreq,
  * netfs_writeback_single - Write back a monolithic payload
  * @mapping: The mapping to write from
  * @wbc: Hints from the VM
- * @iter: Data to write, must be ITER_FOLIOQ.
+ * @iter: Data buffer to write from, must be ITER_FOLIOQ.
+ * @len: Amount of data to write.
  *
  * Write a monolithic, non-pagecache object back to the server and/or
  * the cache.
  *
+ * The data buffer may be bigger than @len (as set in @iter's count), and if
+ * so, this function will use the extra as needed to provide padding into the
+ * cache to handle DIO rounding, so the caller should clear it.
+ *
  * Return: 0 if successful; 1 if skipped due to lock conflict and WB_SYNC_NONE;
  * or a negative error code.
  */
 int netfs_writeback_single(struct address_space *mapping,
 			   struct writeback_control *wbc,
-			   struct iov_iter *iter)
+			   struct iov_iter *iter, size_t len)
 {
 	struct netfs_io_request *wreq;
 	struct netfs_inode *ictx = netfs_inode(mapping->host);
 	struct folio_queue *fq;
-	size_t size = iov_iter_count(iter);
+	size_t size = len;
 	int ret;
 
 	if (WARN_ON_ONCE(!iov_iter_is_folioq(iter)))
 		return -EIO;
+	if (WARN_ON_ONCE(iov_iter_count(iter) < len))
+		return -EIO;
 
 	if (!netfs_wb_begin(ictx, wbc->sync_mode == WB_SYNC_NONE)) {
 		/* The VFS will have undirtied the inode. */
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 2cf1163aafa6..375fd415b4e5 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -430,7 +430,7 @@ void netfs_single_mark_inode_dirty(struct inode *inode);
 ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_iter *iter);
 int netfs_writeback_single(struct address_space *mapping,
 			   struct writeback_control *wbc,
-			   struct iov_iter *iter);
+			   struct iov_iter *iter, size_t len);
 
 /* Address operations API */
 struct readahead_control;

