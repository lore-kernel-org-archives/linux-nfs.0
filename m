Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794936084;
	b=PdhO+Z9nqlITF4H/Tm42Favplu2A1k6WSNdiENDiZUYMbavAZf05eCVkNCs492s5j9ef
	 3oEILbivyzwekn9RmMDo0U7fyCgG/8YnJWpvTvP6uRcfkjHerMHGdER0noBy8DefZo8IZ
	 0Xd9ttyUub5C2/k4BaTCgwv6kEPfaYeVYlJby+x6WsiS98l4OSWZ13QxWTe143NVCugQr
	 S2zka9uef4iYe+AHOK/p5paLJH1K0RAap5wqPl3AvwjTUAXDHHxsASutWG4ZRIgRHrjLj
	 lj6vAxOzcMsqjHc1csnPvhA+SgHm5DDPbYuPYnLtdxO83aJFfoSphP4CVGTfbTmnZUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794936084;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=ZUkx4OaXOF6YZXsR0sLEGuaFMGKluKkbp9xVjv6nwmI=;
	b=avXDaZdYV3xw/KNeTsvMZ2dmO5Y+etwNidSBlIVjYByuirt7drDVop434x8k1iomawuv
	 E+CwufMSkFOGnljpC7l8Bem9oYzsnKB0uMLAtBijQdUNrDHov9o4Vc6c+aphWDsAJw28l
	 KfK231Scf3cpNFkXr0gg5djm8dcL4nvJR6lIhoweEmub3gg1wHn3vMYIOIAkGY0HYX0aW
	 aMNQWMqKd54ofRdk3CDVPgC5yUouOpuDNwFCWQwdmECIz+VuFyAp1V6Pg4StyKTf8C856
	 D3t0TFA0Cw87ZgZle//3QswBolHOOR6WR8WTbT+1itYOdLDmQPvW3CPHhVZgqzXUO6g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=P+UuNDRU;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B52060A3820
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 17:21:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2B52060A3820
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=P+UuNDRU
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794936082;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ZUkx4OaXOF6YZXsR0sLEGuaFMGKluKkbp9xVjv6nwmI=;
	b=P+UuNDRUQbxSVAXjct/LwkOVQELwboU+vei/4AXJ6TmKQFxf9w41p/XqXvJTPvTSYDHFkO
	qfjGf16ahszgCx3dvvBYtXpxK6ldq3hfGZ/kM98xvZCnqZoVshiJAqe7jrn0VdXT83T001
	jrSirxnFhSNQ+I+fNf2G5L2N/fMBF5c=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-637-Nl19TvFoOcqegg0-tONHWw-1; Tue,
 17 Nov 2026 12:21:17 -0500
X-MC-Unique: Nl19TvFoOcqegg0-tONHWw-1
X-Mimecast-MFC-AGG-ID: Nl19TvFoOcqegg0-tONHWw_1794936075
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 32BFD180055C;
	Tue, 17 Nov 2026 17:21:15 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 189F8195B3C5;
	Tue, 17 Nov 2026 17:21:10 +0000 (UTC)
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
	Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-block@vger.kernel.org
Subject: [PATCH v18 10/17] netfs: Pass the write length to request creation where appropriate
Date: Tue, 17 Nov 2026 17:19:08 +0000
Message-ID: <20261117171958.2982801-11-dhowells@redhat.com>
In-Reply-To: <20261117171958.2982801-1-dhowells@redhat.com>
References: <20261117171958.2982801-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

For unbuffered/DIO writes and writes to single-type objects, pass the
length down into the request creation function so that wreq->len gets set
correctly.  For buffered writeback and pgpriv2 copying, this remains 0 as
we don't know in advance how big the request will be.

A subsequent patch will use this to set as the i_size on single-type
objects (e.g. afs directories) as we don't care what the old i_size was and
we don't want to see inode->i_size in the netfs file changing due to
third-party invalidation before we update fscache to say how big the object
is going to be.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara (Red Hat) <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-block@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/direct_write.c | 4 ++--
 fs/netfs/internal.h     | 2 +-
 fs/netfs/read_pgpriv2.c | 2 +-
 fs/netfs/write_issue.c  | 9 +++++----
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/netfs/direct_write.c b/fs/netfs/direct_write.c
index cc46b7d9321f..ff1795e1f0cb 100644
--- a/fs/netfs/direct_write.c
+++ b/fs/netfs/direct_write.c
@@ -222,7 +222,7 @@ static void netfs_unbuffered_write_async(struct work_struct *work)
  * encrypted file.  This can also be used for direct I/O writes.
  */
 ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *iter,
-						  struct netfs_group *netfs_group)
+					   struct netfs_group *netfs_group)
 {
 	struct netfs_io_request *wreq;
 	ssize_t ret, n;
@@ -241,7 +241,7 @@ ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *
 
 	_debug("uw %llx-%llx", start, end);
 
-	wreq = netfs_create_write_req(iocb->ki_filp->f_mapping, iocb->ki_filp, start,
+	wreq = netfs_create_write_req(iocb->ki_filp->f_mapping, iocb->ki_filp, start, len,
 				      iocb->ki_flags & IOCB_DIRECT ?
 				      NETFS_DIO_WRITE : NETFS_UNBUFFERED_WRITE);
 	if (IS_ERR(wreq))
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index 10688314660f..3a2fd263946e 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -240,7 +240,7 @@ void netfs_write_collection_worker(struct work_struct *work);
  */
 struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 						struct file *file,
-						uoff_t start,
+						uoff_t start, size_t len,
 						enum netfs_io_origin origin);
 void netfs_prepare_write(struct netfs_io_request *wreq,
 			 struct netfs_io_stream *stream,
diff --git a/fs/netfs/read_pgpriv2.c b/fs/netfs/read_pgpriv2.c
index 5280b606fda4..85084aad9e31 100644
--- a/fs/netfs/read_pgpriv2.c
+++ b/fs/netfs/read_pgpriv2.c
@@ -103,7 +103,7 @@ static struct netfs_io_request *netfs_pgpriv2_begin_copy_to_cache(
 	if (!fscache_resources_valid(&rreq->cache_resources))
 		goto cancel;
 
-	creq = netfs_create_write_req(rreq->mapping, NULL, folio_pos(folio),
+	creq = netfs_create_write_req(rreq->mapping, NULL, folio_pos(folio), 0,
 				      NETFS_PGPRIV2_COPY_TO_CACHE);
 	if (IS_ERR(creq))
 		goto cancel;
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 0fcfb5ab49bd..7787ecdbcd39 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -89,7 +89,7 @@ static void netfs_kill_dirty_pages(struct address_space *mapping,
  */
 struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 						struct file *file,
-						uoff_t start,
+						uoff_t start, size_t len,
 						enum netfs_io_origin origin)
 {
 	struct netfs_io_request *wreq;
@@ -98,7 +98,7 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 			     origin == NETFS_WRITEBACK_SINGLE ||
 			     origin == NETFS_PGPRIV2_COPY_TO_CACHE);
 
-	wreq = netfs_alloc_request(mapping, file, start, 0, origin);
+	wreq = netfs_alloc_request(mapping, file, start, len, origin);
 	if (IS_ERR(wreq))
 		return wreq;
 
@@ -575,7 +575,8 @@ int netfs_writepages(struct address_space *mapping,
 	if (!folio)
 		goto out;
 
-	wreq = netfs_create_write_req(mapping, NULL, folio_pos(folio), NETFS_WRITEBACK);
+	wreq = netfs_create_write_req(mapping, NULL, folio_pos(folio), 0,
+				      NETFS_WRITEBACK);
 	if (IS_ERR(wreq)) {
 		error = PTR_ERR(wreq);
 		goto couldnt_start;
@@ -661,7 +662,7 @@ int netfs_writeback_single(struct address_space *mapping,
 		return 1;
 	}
 
-	wreq = netfs_create_write_req(mapping, NULL, 0, NETFS_WRITEBACK_SINGLE);
+	wreq = netfs_create_write_req(mapping, NULL, 0, len, NETFS_WRITEBACK_SINGLE);
 	if (IS_ERR(wreq)) {
 		ret = PTR_ERR(wreq);
 		goto couldnt_start;

