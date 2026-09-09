Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0920471246
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 07:22:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788938554; cv=none; b=QDmbZSLK0aRHYDpQqL9i80d1jaCb6D5vjWP8f1MNuqi6uWd5S2fTajkNpYWngE6Pw+B58zfWyuq2y+n98Dp5VsybsyKlKhZb2yuJm3mXMB7qJgWrOXsCiCNCe0UxVxndGVuWKmaFDy/pKp4ju6qwhQSCDLKt7GugzbnyGeokdHU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788938554; c=relaxed/simple;
	bh=LZ2hS8A6llV8NkvAufdH9wFQBoDVrgr/5hAQg36CjfM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GZK/1TXjnq2izety1WOef7eriwf7F/HHH1JQjbmA5roZfohPq3wIben6n+Ut5lPZEpcQ2hCAkMEY2WdRbovpvycSDWAdppwUC2TdRCwrIffRhak0xefP2pPXXei/+TgzQWKaOlufYwXzuwQOFLupRnLIzfoYjC1X+Ir1LBJNcz8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=a/o7Clzu; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="a/o7Clzu"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788938550;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=/xgppktK1ya3AHkXZxi9vPI0IjVoDDvwcSOEfPSvP+w=;
	b=a/o7Clzulgr1l1xPXLDoyhKGV2nAdW4nd7EeU9Rh7ugVBF3LpSbnFSj899G0GCdROjqRzX
	kQ7V08U6MaUejg/WS0BChKgP1KkYqZSqjgtRc91y6f6j7MACF85rNGz21TaLvtimX1+YBz
	SP9LGoDJIOO9vH2DGeNa0dWH2LeBrFk=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-488-jc9DiHqrPbe-2bcDCqYZSQ-1; Wed,
 09 Sep 2026 03:22:27 -0400
X-MC-Unique: jc9DiHqrPbe-2bcDCqYZSQ-1
X-Mimecast-MFC-AGG-ID: jc9DiHqrPbe-2bcDCqYZSQ_1788938544
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D94681800598;
	Wed,  9 Sep 2026 07:22:23 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 57C9A195608C;
	Wed,  9 Sep 2026 07:22:18 +0000 (UTC)
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
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v13 8/8] netfs: Set subrequest->source at alloc before trace emission
Date: Wed,  9 Sep 2026 08:21:02 +0100
Message-ID: <20260909072105.1663687-9-dhowells@redhat.com>
In-Reply-To: <20260909072105.1663687-1-dhowells@redhat.com>
References: <20260909072105.1663687-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Set subrequest->source in netfs_alloc_subrequest() before we emit the trace
line indicating we allocated the subrequest.  Note that this requires the
allocation of the subreq in netfs_read_to_pagecache() to be pushed to after
the decision about what sort of subreq it should be.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
cc: linux-mm@kvack.org
---
 fs/netfs/buffered_read.c | 4 ++--
 fs/netfs/direct_read.c   | 3 +--
 fs/netfs/internal.h      | 3 ++-
 fs/netfs/objects.c       | 4 +++-
 fs/netfs/read_retry.c    | 3 +--
 fs/netfs/read_single.c   | 3 +--
 fs/netfs/write_issue.c   | 3 +--
 fs/netfs/write_retry.c   | 3 +--
 8 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index 887d45f3745a..68496e1a171f 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -276,10 +276,10 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 
 	do {
 		struct netfs_io_subrequest *subreq;
-		enum netfs_io_source source = NETFS_SOURCE_UNKNOWN;
+		enum netfs_io_source source;
 		ssize_t slice;
 
-		subreq = netfs_alloc_subrequest(rreq);
+		subreq = netfs_alloc_subrequest(rreq, NETFS_SOURCE_UNKNOWN);
 		if (!subreq) {
 			ret = -ENOMEM;
 			break;
diff --git a/fs/netfs/direct_read.c b/fs/netfs/direct_read.c
index 5405e108b7a3..8c15f3079723 100644
--- a/fs/netfs/direct_read.c
+++ b/fs/netfs/direct_read.c
@@ -55,7 +55,7 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 		struct netfs_io_subrequest *subreq;
 		ssize_t slice;
 
-		subreq = netfs_alloc_subrequest(rreq);
+		subreq = netfs_alloc_subrequest(rreq, NETFS_DOWNLOAD_FROM_SERVER);
 		if (!subreq) {
 			/* Stash the error in the request if there's not
 			 * already an error set.
@@ -64,7 +64,6 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 			break;
 		}
 
-		subreq->source	= NETFS_DOWNLOAD_FROM_SERVER;
 		subreq->start	= start;
 		subreq->len	= size;
 
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index d579c5d79609..4891e6e3c5db 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -92,7 +92,8 @@ void netfs_get_request(struct netfs_io_request *rreq, enum netfs_rreq_ref_trace
 void netfs_clear_subrequests(struct netfs_io_request *rreq);
 void netfs_put_request(struct netfs_io_request *rreq, enum netfs_rreq_ref_trace what);
 void netfs_put_failed_request(struct netfs_io_request *rreq);
-struct netfs_io_subrequest *netfs_alloc_subrequest(struct netfs_io_request *rreq);
+struct netfs_io_subrequest *netfs_alloc_subrequest(struct netfs_io_request *rreq,
+						   enum netfs_io_source source);
 
 static inline void netfs_see_request(struct netfs_io_request *rreq,
 				     enum netfs_rreq_ref_trace what)
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 3460aa1c4af1..9c6ea718692a 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -207,7 +207,8 @@ void netfs_put_failed_request(struct netfs_io_request *rreq)
 /*
  * Allocate and partially initialise an I/O request structure.
  */
-struct netfs_io_subrequest *netfs_alloc_subrequest(struct netfs_io_request *rreq)
+struct netfs_io_subrequest *netfs_alloc_subrequest(struct netfs_io_request *rreq,
+						   enum netfs_io_source source)
 {
 	struct netfs_io_subrequest *subreq;
 	mempool_t *mempool = rreq->netfs_ops->subrequest_pool ?: &netfs_subrequest_pool;
@@ -224,6 +225,7 @@ struct netfs_io_subrequest *netfs_alloc_subrequest(struct netfs_io_request *rreq
 	INIT_WORK(&subreq->work, NULL);
 	INIT_LIST_HEAD(&subreq->rreq_link);
 	refcount_set(&subreq->ref, 2);
+	subreq->source = source;
 	subreq->rreq = rreq;
 	subreq->debug_index = atomic_inc_return(&rreq->subreq_counter);
 	netfs_get_request(rreq, netfs_rreq_trace_get_subreq);
diff --git a/fs/netfs/read_retry.c b/fs/netfs/read_retry.c
index 46810d29f0c0..396a05432a7e 100644
--- a/fs/netfs/read_retry.c
+++ b/fs/netfs/read_retry.c
@@ -195,12 +195,11 @@ static void netfs_retry_read_subrequests(struct netfs_io_request *rreq)
 		 * and insert them after.
 		 */
 		do {
-			subreq = netfs_alloc_subrequest(rreq);
+			subreq = netfs_alloc_subrequest(rreq, NETFS_DOWNLOAD_FROM_SERVER);
 			if (!subreq) {
 				subreq = to;
 				goto abandon_after;
 			}
-			subreq->source		= NETFS_DOWNLOAD_FROM_SERVER;
 			subreq->start		= start;
 			subreq->len		= len;
 			subreq->stream_nr	= stream->stream_nr;
diff --git a/fs/netfs/read_single.c b/fs/netfs/read_single.c
index ccb5fc809d99..81295c055ced 100644
--- a/fs/netfs/read_single.c
+++ b/fs/netfs/read_single.c
@@ -92,11 +92,10 @@ static int netfs_single_dispatch_read(struct netfs_io_request *rreq)
 	struct netfs_io_subrequest *subreq;
 	int ret = 0;
 
-	subreq = netfs_alloc_subrequest(rreq);
+	subreq = netfs_alloc_subrequest(rreq, NETFS_SOURCE_UNKNOWN);
 	if (!subreq)
 		return -ENOMEM;
 
-	subreq->source	= NETFS_SOURCE_UNKNOWN;
 	subreq->start	= 0;
 	subreq->len	= rreq->len;
 	subreq->io_iter	= rreq->buffer.iter;
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 9a528da4bf9f..e7cb496f6324 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -168,10 +168,9 @@ void netfs_prepare_write(struct netfs_io_request *wreq,
 	    wreq_iter->folioq_slot >= folioq_nr_slots(wreq_iter->folioq))
 		rolling_buffer_make_space(&wreq->buffer, wreq->gfp);
 
-	subreq = netfs_alloc_subrequest(wreq);
+	subreq = netfs_alloc_subrequest(wreq, stream->source);
 	if (!subreq)
 		return;
-	subreq->source		= stream->source;
 	subreq->start		= start;
 	subreq->stream_nr	= stream->stream_nr;
 	subreq->io_iter		= *wreq_iter;
diff --git a/fs/netfs/write_retry.c b/fs/netfs/write_retry.c
index 6cd584242af2..d7d5348496fc 100644
--- a/fs/netfs/write_retry.c
+++ b/fs/netfs/write_retry.c
@@ -149,8 +149,7 @@ static void netfs_retry_write_stream(struct netfs_io_request *wreq,
 		 * and insert them after.
 		 */
 		do {
-			subreq = netfs_alloc_subrequest(wreq);
-			subreq->source		= to->source;
+			subreq = netfs_alloc_subrequest(wreq, stream->source);
 			subreq->start		= start;
 			subreq->stream_nr	= to->stream_nr;
 			subreq->retry_count	= 1;

