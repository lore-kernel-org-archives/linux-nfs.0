Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D01343CE66
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:46:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787582778; cv=none; b=T8KPYMR1/6C6p7iEHDAV/y+TElXn2u6LsYVlLl7/uPFypTpqrGiDSJHMCFxg8srIzfziYQwOXi+JNpWJkvE9NtuNQoRF0ip/AYet0O8YG25NvKIabqzkScEQgbLwxw5piZpjeMWKUDspm+gCMVFbcq2Q/vclz1tYvx4BVSxWO3A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787582778; c=relaxed/simple;
	bh=NK/vt55ATgBFX0JsjLVJlNfG+2hQn7dcB6piAdLfrFU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jxZfwRad4GKyAIrLg49LUclnt8bR1KsrckRUq+Q5Nt2hbUrRFnyl5b3VipiLmTe8Y5hvMpR+LY9ZVGV733+2XF8u1NE8vrRG9ftKujDGWrFTF/49Dgz3tDR1RkHd9d0zCITpvE3Mfwih7a1ogJEGzzpHQJ3hRfnRQgI54MWoxTY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=aa5S51yQ; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="aa5S51yQ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787582775;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=GoClngj4Ddh9NN9Yes/xcG/KivXCKdaPGjH/7gZPero=;
	b=aa5S51yQQ/ZFDgs+8R25rv5WPp2qkBPxPXn+2OLI75R24fenjDR8N6AEvks8mMKBMixBGs
	kNbTKAYE/EkCqD/tUhgP1rPuRWIYoYYq/zrnZyDKQHY7dIk0aYD6oN/SJpJpxRj4NmV/l7
	qiRuRaNKYsZBxeWRfa6z53cyA1AxoFQ=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-385-v3g5PefYO7CcJHuGWl16Gg-1; Mon,
 24 Aug 2026 10:46:11 -0400
X-MC-Unique: v3g5PefYO7CcJHuGWl16Gg-1
X-Mimecast-MFC-AGG-ID: v3g5PefYO7CcJHuGWl16Gg_1787582769
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3339A183458E;
	Mon, 24 Aug 2026 14:46:09 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.15])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 1699818001D0;
	Mon, 24 Aug 2026 14:46:02 +0000 (UTC)
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
Subject: [PATCH v10 32/35] netfs: Add a method to get an estimate of the amount that can be written
Date: Mon, 24 Aug 2026 15:41:25 +0100
Message-ID: <20260824144130.759997-33-dhowells@redhat.com>
In-Reply-To: <20260824144130.759997-1-dhowells@redhat.com>
References: <20260824144130.759997-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Add a method, both to the netfs cache API and the netfs filesystem API,
that allows netfslib to query how much can be written to a stream in one
go.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/9p/vfs_addr.c       | 17 +++++++++++++++++
 fs/afs/file.c          |  2 +-
 fs/afs/internal.h      |  3 +++
 fs/afs/write.c         | 17 +++++++++++++++++
 fs/cachefiles/io.c     | 15 ++++++++++++++-
 fs/netfs/write_issue.c |  2 ++
 fs/smb/client/file.c   | 14 ++++++++++++++
 include/linux/netfs.h  | 22 ++++++++++++++++++++++
 8 files changed, 90 insertions(+), 2 deletions(-)

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 2129fcb0f65c..9b163a13ec3f 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -48,6 +48,22 @@ static void v9fs_begin_writeback(struct netfs_io_request *wreq)
 	wreq->io_streams[0].avail = true;
 }
 
+/*
+ * Estimate how much data should be accumulated before we start issuing
+ * write subrequests.
+ */
+static int v9fs_estimate_write(struct netfs_io_request *wreq,
+			       struct netfs_io_stream *stream,
+			       struct netfs_write_estimate *estimate)
+{
+	struct p9_fid *fid = wreq->netfs_priv;
+	unsigned long long limit = ULLONG_MAX - stream->issue_from;
+	unsigned long long max_len = fid->clnt->msize - P9_IOHDRSZ;
+
+	estimate->issue_at = stream->issue_from + umin(max_len, limit);
+	return 0;
+}
+
 /*
  * Issue a subrequest to write to the server.
  */
@@ -185,6 +201,7 @@ const struct netfs_request_ops v9fs_req_ops = {
 	.free_request		= v9fs_free_request,
 	.issue_read		= v9fs_issue_read,
 	.begin_writeback	= v9fs_begin_writeback,
+	.estimate_write		= v9fs_estimate_write,
 	.issue_write		= v9fs_issue_write,
 };
 
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 11695be8c4a5..4a412e0472ec 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -469,7 +469,7 @@ const struct netfs_request_ops afs_req_ops = {
 	.update_i_size		= afs_update_i_size,
 	.invalidate_cache	= afs_netfs_invalidate_cache,
 	.begin_writeback	= afs_begin_writeback,
-	.prepare_write		= afs_prepare_write,
+	.estimate_write		= afs_estimate_write,
 	.issue_write		= afs_issue_write,
 	.retry_request		= afs_retry_request,
 };
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 556e7e7777f2..ae2bc699bfde 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -1698,6 +1698,9 @@ extern int afs_check_volume_status(struct afs_volume *, struct afs_operation *);
 /*
  * write.c
  */
+int afs_estimate_write(struct netfs_io_request *wreq,
+		       struct netfs_io_stream *stream,
+		       struct netfs_write_estimate *estimate);
 void afs_prepare_write(struct netfs_io_subrequest *subreq);
 void afs_issue_write(struct netfs_io_subrequest *subreq);
 void afs_begin_writeback(struct netfs_io_request *wreq);
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 7f34b939706a..a0c9916f594b 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -82,6 +82,23 @@ static const struct afs_operation_ops afs_store_data_operation = {
 	.success	= afs_store_data_success,
 };
 
+/*
+ * Estimate the maximum size of a write we can send to the server.
+ */
+int afs_estimate_write(struct netfs_io_request *wreq,
+		       struct netfs_io_stream *stream,
+		       struct netfs_write_estimate *estimate)
+{
+	unsigned long long limit = ULLONG_MAX - stream->issue_from;
+	unsigned long long max_len = 256 * 1024 * 1024;
+
+	//if (test_bit(NETFS_SREQ_RETRYING, &subreq->flags))
+	//	max_len = 512 * 1024;
+
+	estimate->issue_at = stream->issue_from + umin(max_len, limit);
+	return 0;
+}
+
 /*
  * Prepare a subrequest to write to the server.  This sets the max_len
  * parameter.
diff --git a/fs/cachefiles/io.c b/fs/cachefiles/io.c
index 23007f450ef4..91b69be78c6b 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -26,7 +26,10 @@ struct cachefiles_kiocb {
 	};
 	struct cachefiles_object *object;
 	netfs_io_terminated_t	term_func;
-	void			*term_func_priv;
+	union {
+		struct netfs_io_subrequest *subreq;
+		void			*term_func_priv;
+	};
 	bool			was_async;
 	unsigned int		inval_counter;	/* Copy of cookie->inval_counter */
 	u64			b_writing;
@@ -611,6 +614,15 @@ static int cachefiles_prepare_write(struct netfs_cache_resources *cres,
 	return ret;
 }
 
+static int cachefiles_estimate_write(struct netfs_io_request *wreq,
+				     struct netfs_io_stream *stream,
+				     struct netfs_write_estimate *estimate)
+{
+	estimate->issue_at = stream->issue_from + MAX_RW_COUNT;
+	estimate->max_segs = BIO_MAX_VECS;
+	return 0;
+}
+
 static void cachefiles_prepare_write_subreq(struct netfs_io_subrequest *subreq)
 {
 	struct netfs_io_request *wreq = subreq->rreq;
@@ -898,6 +910,7 @@ static const struct netfs_cache_ops cachefiles_netfs_cache_ops = {
 	.issue_write		= cachefiles_issue_write,
 	.prepare_write		= cachefiles_prepare_write,
 	.prepare_write_subreq	= cachefiles_prepare_write_subreq,
+	.estimate_write		= cachefiles_estimate_write,
 	.query_occupancy	= cachefiles_query_occupancy,
 	.collect_write		= cachefiles_collect_write,
 };
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index a5c5ba5deb43..025ea5763fda 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -114,6 +114,7 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 
 	wreq->io_streams[0].stream_nr		= 0;
 	wreq->io_streams[0].source		= NETFS_UPLOAD_TO_SERVER;
+	wreq->io_streams[0].estimate_write	= ictx->ops->estimate_write;
 	wreq->io_streams[0].prepare_write	= ictx->ops->prepare_write;
 	wreq->io_streams[0].issue_write		= ictx->ops->issue_write;
 	wreq->io_streams[0].collected_to	= start;
@@ -126,6 +127,7 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 	if (fscache_resources_valid(&wreq->cache_resources)) {
 		wreq->io_streams[1].avail	= true;
 		wreq->io_streams[1].active	= true;
+		wreq->io_streams[1].estimate_write = wreq->cache_resources.ops->estimate_write;
 		wreq->io_streams[1].prepare_write = wreq->cache_resources.ops->prepare_write_subreq;
 		wreq->io_streams[1].issue_write = wreq->cache_resources.ops->issue_write;
 	}
diff --git a/fs/smb/client/file.c b/fs/smb/client/file.c
index ac89c1ba56b1..7ad464782439 100644
--- a/fs/smb/client/file.c
+++ b/fs/smb/client/file.c
@@ -39,6 +39,19 @@
 
 static int cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush);
 
+/*
+ * Estimate the amount of data that can be written in one RPC op.
+ */
+static int cifs_estimate_write(struct netfs_io_request *wreq,
+			       struct netfs_io_stream *stream,
+			       struct netfs_write_estimate *estimate)
+{
+	struct cifs_sb_info *cifs_sb = CIFS_SB(wreq->inode->i_sb);
+
+	estimate->issue_at = stream->issue_from + cifs_sb->ctx->wsize;
+	return 0;
+}
+
 /*
  * Prepare a subrequest to upload to the server.  We need to allocate credits
  * so that we know the maximum amount of data that we can include in it.
@@ -362,6 +375,7 @@ const struct netfs_request_ops cifs_req_ops = {
 	.issue_read		= cifs_issue_read,
 	.done			= cifs_rreq_done,
 	.begin_writeback	= cifs_begin_writeback,
+	.estimate_write		= cifs_estimate_write,
 	.prepare_write		= cifs_prepare_write,
 	.issue_write		= cifs_issue_write,
 	.invalidate_cache	= cifs_netfs_invalidate_cache,
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 6ee3891845e9..656f4f3f80b6 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -134,6 +134,16 @@ enum netfs_cache_collect {
 	NETFS_CACHE_COLLECT_WRITE_CANCEL,	/* Currently collecting cancelled writes */
 };
 
+/*
+ * Estimate of maximum write subrequest for writeback.  The filesystem is
+ * responsible for filling this in when called from ->estimate_write(), though
+ * netfslib will preset infinite defaults.
+ */
+struct netfs_write_estimate {
+	uoff_t			issue_at;	/* Point at which we must submit */
+	int			max_segs;	/* Max number of segments in a single RPC */
+};
+
 /*
  * Stream of I/O subrequests going to a particular destination, such as the
  * server or the local cache.  This is mainly intended for writing where we may
@@ -142,10 +152,14 @@ enum netfs_cache_collect {
 struct netfs_io_stream {
 	/* Submission tracking */
 	struct netfs_io_subrequest *construct;	/* Op being constructed */
+	uoff_t			issue_from;	/* Current issue point */
 	size_t			sreq_max_len;	/* Maximum size of a subrequest */
 	unsigned int		sreq_max_segs;	/* 0 or max number of segments in an iterator */
 	unsigned int		submit_off;	/* Folio offset we're submitting from */
 	unsigned int		submit_len;	/* Amount of data left to submit */
+	int (*estimate_write)(struct netfs_io_request *wreq,
+			      struct netfs_io_stream *stream,
+			      struct netfs_write_estimate *estimate);
 	void (*prepare_write)(struct netfs_io_subrequest *subreq);
 	void (*issue_write)(struct netfs_io_subrequest *subreq);
 	/* Collection tracking */
@@ -328,6 +342,9 @@ struct netfs_request_ops {
 
 	/* Write request handling */
 	void (*begin_writeback)(struct netfs_io_request *wreq);
+	int (*estimate_write)(struct netfs_io_request *wreq,
+			      struct netfs_io_stream *stream,
+			      struct netfs_write_estimate *estimate);
 	void (*prepare_write)(struct netfs_io_subrequest *subreq);
 	void (*issue_write)(struct netfs_io_subrequest *subreq);
 	void (*retry_request)(struct netfs_io_request *wreq, struct netfs_io_stream *stream);
@@ -364,6 +381,11 @@ struct netfs_cache_ops {
 		     netfs_io_terminated_t term_func,
 		     void *term_func_priv);
 
+	/* Estimate the amount of data that can be written in an op. */
+	int (*estimate_write)(struct netfs_io_request *wreq,
+			      struct netfs_io_stream *stream,
+			      struct netfs_write_estimate *estimate);
+
 	/* Write data to the cache from a netfs subrequest. */
 	void (*issue_write)(struct netfs_io_subrequest *subreq);
 

