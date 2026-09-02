Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF1774ADD9B
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:36:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370602; cv=none; b=EX9PpUdMpXpORikx4kBZ2CrjOwb9/WvfITNKkv81SsNyGj213Bmt+DN8NKowD7v++S32PISgcUDd8icMa0f0vCjCXTrfURoTj+qeWeDQuTCXclVtbU6fLrsYrKqsFc/eyWZ34TX8/St1tHMdfqz0JZf7QBIrHQYnPa+2tU4jY7U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370602; c=relaxed/simple;
	bh=UCD7hT3sCrYRzDEoiQnNRERcnROQZ49aEd7lMipPmSE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KCRqUFRcQwTZuU7ZCZMo8HFyxq7W+VmXm1/Dw5LcjcR1QkAxkisMUdSo2hW367CiRM7p2JEJBLm6ffa42BqVN+eHVBJ4XSlq4WekBl5xdTYm92WCwnGP92eReGS1t/woSbT3grit24jqYixtaVnZn7Ddz5qh43lX+hN01/ypyN8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=XgGLfSQB; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="XgGLfSQB"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370600;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=XbU3KgPae9/zKiESWBDoQklZ0aJbXSfgOvZHTF9rxR8=;
	b=XgGLfSQBIUuMXIWF+D6saBfkqrd08+XYIeAwgdH1PSgXoG+CZUYlowv6zKhkUI9k3HiW0v
	vAlNmscNJJN3Nyn+827Ea5jvtPROGruXFG+SR7h3A9ICvPuWs/Fq8gTRDKRJlj5aHl7Pgg
	33n8/t0O5d2Y38kbmXQOgZW2xKbRNeI=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-635-lk8LF7C_NFa3PcQP0dVxOQ-1; Wed,
 02 Sep 2026 13:36:33 -0400
X-MC-Unique: lk8LF7C_NFa3PcQP0dVxOQ-1
X-Mimecast-MFC-AGG-ID: lk8LF7C_NFa3PcQP0dVxOQ_1788370590
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 9D7B8195C241;
	Wed,  2 Sep 2026 17:36:30 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id B142C1955F04;
	Wed,  2 Sep 2026 17:36:23 +0000 (UTC)
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
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>
Subject: [PATCH v11 18/36] netfs: Make deprecated PG_private_2 support optional
Date: Wed,  2 Sep 2026 18:33:30 +0100
Message-ID: <20260902173350.3468672-19-dhowells@redhat.com>
In-Reply-To: <20260902173350.3468672-1-dhowells@redhat.com>
References: <20260902173350.3468672-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Make the deprecated PG_private_2 support optional, requiring it to be
selected by the filesystems that might want to use it.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: Trond Myklebust <trondmy@kernel.org>
cc: Anna Schumaker <anna@kernel.org>
cc: Ilya Dryomov <idryomov@gmail.com>
cc: Alex Markuze <amarkuze@redhat.com>
cc: Viacheslav Dubeyko <slava@dubeyko.com>
cc: netfs@lists.linux.dev
cc: linux-nfs@vger.kernel.org
cc: ceph-devel@vger.kernel.org
cc: linux-fsdevel@vger.kernel.org
---
 fs/ceph/Kconfig         |  1 +
 fs/netfs/Kconfig        |  3 +++
 fs/netfs/Makefile       |  2 +-
 fs/netfs/internal.h     | 28 ++++++++++++++++++++++++++++
 fs/netfs/read_collect.c |  4 ++--
 fs/nfs/Kconfig          |  1 +
 include/linux/netfs.h   |  2 ++
 7 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/fs/ceph/Kconfig b/fs/ceph/Kconfig
index 3d64a316ca31..aa6ccd7794d2 100644
--- a/fs/ceph/Kconfig
+++ b/fs/ceph/Kconfig
@@ -4,6 +4,7 @@ config CEPH_FS
 	depends on INET
 	select CEPH_LIB
 	select NETFS_SUPPORT
+	select NETFS_PGPRIV2
 	select FS_ENCRYPTION_ALGS if FS_ENCRYPTION
 	default n
 	help
diff --git a/fs/netfs/Kconfig b/fs/netfs/Kconfig
index 7701c037c328..d0e7b0971fa3 100644
--- a/fs/netfs/Kconfig
+++ b/fs/netfs/Kconfig
@@ -22,6 +22,9 @@ config NETFS_STATS
 	  between CPUs.  On the other hand, the stats are very useful for
 	  debugging purposes.  Saying 'Y' here is recommended.
 
+config NETFS_PGPRIV2
+	bool
+
 config NETFS_DEBUG
 	bool "Enable dynamic debugging netfslib and FS-Cache"
 	depends on NETFS_SUPPORT
diff --git a/fs/netfs/Makefile b/fs/netfs/Makefile
index e1f12ecb5abf..b1ea4439c1bb 100644
--- a/fs/netfs/Makefile
+++ b/fs/netfs/Makefile
@@ -12,7 +12,6 @@ netfs-y := \
 	misc.o \
 	objects.o \
 	read_collect.o \
-	read_pgpriv2.o \
 	read_retry.o \
 	read_single.o \
 	rolling_buffer.o \
@@ -20,6 +19,7 @@ netfs-y := \
 	write_issue.o \
 	write_retry.o
 
+netfs-$(CONFIG_NETFS_PGPRIV2) += read_pgpriv2.o
 netfs-$(CONFIG_NETFS_STATS) += stats.o
 
 netfs-$(CONFIG_FSCACHE) += \
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index 1346e750075a..e6c204a3cb3e 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -121,9 +121,37 @@ void netfs_cache_read_terminated(void *priv, ssize_t transferred_or_error);
 /*
  * read_pgpriv2.c
  */
+#ifdef CONFIG_NETFS_PGPRIV2
+int netfs_prepare_pgpriv2_write_buffer(struct netfs_io_subrequest *subreq,
+				       unsigned int max_segs);
 void netfs_pgpriv2_copy_to_cache(struct netfs_io_request *rreq, struct folio *folio);
 void netfs_pgpriv2_end_copy_to_cache(struct netfs_io_request *rreq);
 bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *wreq);
+static inline bool netfs_using_pgpriv2(const struct netfs_io_request *rreq)
+{
+	return test_bit(NETFS_RREQ_USE_PGPRIV2, &rreq->flags);
+}
+#else
+static inline int netfs_prepare_pgpriv2_write_buffer(struct netfs_io_subrequest *subreq,
+						     unsigned int max_segs)
+{
+	return -EIO;
+}
+static inline void netfs_pgpriv2_copy_to_cache(struct netfs_io_request *rreq, struct folio *folio)
+{
+}
+static inline void netfs_pgpriv2_end_copy_to_cache(struct netfs_io_request *rreq)
+{
+}
+static inline bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *wreq)
+{
+	return true;
+}
+static inline bool netfs_using_pgpriv2(const struct netfs_io_request *rreq)
+{
+	return false;
+}
+#endif
 
 /*
  * read_retry.c
diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index 7420b90233e6..cb97dedad170 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -38,7 +38,7 @@ static void netfs_clear_unread(struct netfs_io_subrequest *subreq)
  */
 void netfs_cancel_copy_to_cache(struct netfs_io_request *rreq, struct folio *folio)
 {
-	if (!test_bit(NETFS_RREQ_USE_PGPRIV2, &rreq->flags)) {
+	if (!netfs_using_pgpriv2(rreq)) {
 		if (folio_get_private(folio) == NETFS_FOLIO_COPY_TO_CACHE) {
 			folio_detach_private(folio);
 			trace_netfs_folio(folio, netfs_folio_trace_cancel_copy);
@@ -81,7 +81,7 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
 	if (unlikely(test_bit(NETFS_RREQ_CANCEL_CACHING, &rreq->flags)))
 		netfs_cancel_copy_to_cache(rreq, folio);
 
-	if (!test_bit(NETFS_RREQ_USE_PGPRIV2, &rreq->flags)) {
+	if (!netfs_using_pgpriv2(rreq)) {
 		if (netfs_folio_group(folio) == NETFS_FOLIO_COPY_TO_CACHE)  {
 			trace_netfs_folio(folio, netfs_folio_trace_sched_copy);
 			folio_mark_dirty(folio);
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6bb30543eff0..e7862f35b72c 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -174,6 +174,7 @@ config NFS_FSCACHE
 	bool "Provide NFS client caching support"
 	depends on NFS_FS
 	select NETFS_SUPPORT
+	select NETFS_PGPRIV2
 	select FSCACHE
 	help
 	  Say Y here if you want NFS data to be cached locally on disc through
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 558e03e0d07a..1e044f62027b 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -279,8 +279,10 @@ struct netfs_io_request {
 #define NETFS_RREQ_UPLOAD_TO_SERVER	11	/* Need to write to the server */
 #define NETFS_RREQ_USE_IO_ITER		12	/* Use ->io_iter rather than ->i_pages */
 #define NETFS_RREQ_NEED_PUT_RA_REFS	17	/* Need to put the folio refs RA gave us */
+#ifdef CONFIG_NETFS_PGPRIV2
 #define NETFS_RREQ_USE_PGPRIV2		31	/* [DEPRECATED] Use PG_private_2 to mark
 						 * write to cache on read */
+#endif
 	const struct netfs_request_ops *netfs_ops;
 };
 

