Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FE3B4AD7DA
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:36:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370594; cv=none; b=j3+47KSLoKFhicIg30Ii/UQDeVbCUX954yx6tj+s3xEZPQwzlB4CNqL7ssJgRIvEz+P3W4lSQ30SQga5sRo7ZWvEi0DMkYFoNn67lsuI8KsL/ustOyr8dzDt7nTDGcHzDVeAhMQnFoppBhUJDYLlcdTT2SasA6bfzgeOUukRYxI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370594; c=relaxed/simple;
	bh=NBorPGSrFvCD9HAE9r1IHFN680e94k/zE275c401tv0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ed2ff5P6NyX0szSUwqvFe2eLjB0EkmYsk7sG91xpxIpYVIvXcN75NYzZYc21ldGKBsMh2CH2eZD4O7fFS7h4PcsPYoAGRLFrLpk1SVbO8oIuidCsGKdRoEuK0zKrX5ZDuLIRCN3uGW1+7Kbl6o6eF1tkcX9/X8ans1ebItvNWLQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=KLMyU3C3; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KLMyU3C3"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370590;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=VzgbonUbMWBI9znSQsZtTUYpYOVdw2vkszBDVrYmKXU=;
	b=KLMyU3C3La/Iv59Hfu+k+HIBnBB6NVlxcIQGZ+B54LSnd7q4pJJF13afxhNH17uy3DujQ6
	f0eZSnVljjJTzx16fYHrfGifbS1GaIefxXP+Sh8nhAV2h2sxQAOkIG9+0kOpIU7kHa+2dO
	mJLeRjoR/vbETIVvjeG5TtRf4a/TeXI=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-595-TuMeXvnlOyCzfPNYh9woBg-1; Wed,
 02 Sep 2026 13:36:24 -0400
X-MC-Unique: TuMeXvnlOyCzfPNYh9woBg-1
X-Mimecast-MFC-AGG-ID: TuMeXvnlOyCzfPNYh9woBg_1788370582
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0B50E1955D7A;
	Wed,  2 Sep 2026 17:36:22 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 24BF51955D8D;
	Wed,  2 Sep 2026 17:36:15 +0000 (UTC)
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
Subject: [PATCH v11 17/36] netfs: Add some functions to wrap the all-queued handling
Date: Wed,  2 Sep 2026 18:33:29 +0100
Message-ID: <20260902173350.3468672-18-dhowells@redhat.com>
In-Reply-To: <20260902173350.3468672-1-dhowells@redhat.com>
References: <20260902173350.3468672-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Add some helper functions to wrap the handling of the NETFS_RREQ_ALL_QUEUED
flag and to insert the appropriate barriers.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/buffered_read.c     |  9 +++------
 fs/netfs/direct_read.c       |  9 +++------
 fs/netfs/internal.h          | 19 +++++++++++++++++++
 fs/netfs/misc.c              |  2 +-
 fs/netfs/read_collect.c      |  4 +---
 fs/netfs/read_pgpriv2.c      |  3 +--
 fs/netfs/read_single.c       |  9 +++------
 fs/netfs/write_collect.c     |  3 +--
 fs/netfs/write_issue.c       |  7 ++-----
 include/trace/events/netfs.h |  1 +
 10 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index 61cf82b4b60d..e7fa30376862 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -355,10 +355,8 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 		}
 		start += slice;
 		size -= slice;
-		if (size <= 0) {
-			smp_wmb(); /* Write lists before ALL_QUEUED. */
-			set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
-		}
+		if (size <= 0)
+			netfs_all_subreqs_queued(rreq);
 
 		if (fq) {
 			/* See if the cache indicated this should be cached. */
@@ -378,8 +376,7 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 	} while (size > 0);
 
 	if (unlikely(size > 0)) {
-		smp_wmb(); /* Write lists before ALL_QUEUED. */
-		set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
+		netfs_all_subreqs_queued(rreq);
 		netfs_wake_collector(rreq);
 	}
 
diff --git a/fs/netfs/direct_read.c b/fs/netfs/direct_read.c
index aa10af5171a8..5405e108b7a3 100644
--- a/fs/netfs/direct_read.c
+++ b/fs/netfs/direct_read.c
@@ -84,10 +84,8 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 		size -= slice;
 		start += slice;
 		rreq->submitted += slice;
-		if (size <= 0) {
-			smp_wmb(); /* Write lists before ALL_QUEUED. */
-			set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
-		}
+		if (size <= 0)
+			netfs_all_subreqs_queued(rreq);
 
 		rreq->netfs_ops->issue_read(subreq);
 
@@ -99,8 +97,7 @@ static void netfs_dispatch_unbuffered_reads(struct netfs_io_request *rreq)
 	} while (size > 0);
 
 	if (unlikely(size > 0)) {
-		smp_wmb(); /* Write lists before ALL_QUEUED. */
-		set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
+		netfs_all_subreqs_queued(rreq);
 		netfs_wake_collector(rreq);
 	}
 }
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index 67f2406e00cd..1346e750075a 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -315,6 +315,25 @@ static inline bool netfs_check_subreq_in_progress(const struct netfs_io_subreque
 	return test_bit_acquire(NETFS_SREQ_IN_PROGRESS, &subreq->flags);
 }
 
+/*
+ * Indicate that we've generated and queued all the subrequests we're going to.
+ */
+static inline void netfs_all_subreqs_queued(struct netfs_io_request *rreq)
+{
+	smp_wmb(); /* Write lists before ALL_QUEUED. */
+	set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
+	trace_netfs_rreq(rreq, netfs_rreq_trace_all_queued);
+}
+
+/*
+ * Query if all subrequests are queued.
+ */
+static inline bool netfs_are_all_subreqs_queued(const struct netfs_io_request *rreq)
+{
+	/* Read lists after ALL_QUEUED. */
+	return test_bit_acquire(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
+}
+
 /*
  * fscache-cache.c
  */
diff --git a/fs/netfs/misc.c b/fs/netfs/misc.c
index eafc4edae6a0..a3cd76d584b8 100644
--- a/fs/netfs/misc.c
+++ b/fs/netfs/misc.c
@@ -424,7 +424,7 @@ static int netfs_collect_in_app(struct netfs_io_request *rreq,
 			need_collect = true;
 			break;
 		}
-		if (subreq || !test_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags))
+		if (subreq || !netfs_are_all_subreqs_queued(rreq))
 			done = false;
 	}
 
diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index 61f2664de6d3..7420b90233e6 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -462,10 +462,8 @@ bool netfs_read_collection(struct netfs_io_request *rreq)
 	/* We're done when the app thread has finished posting subreqs and the
 	 * queue is empty.
 	 */
-	if (!test_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags))
+	if (!netfs_are_all_subreqs_queued(rreq))
 		return false;
-	smp_rmb(); /* Read ALL_QUEUED before subreq lists. */
-
 	if (!list_empty(&stream->subrequests))
 		return false;
 
diff --git a/fs/netfs/read_pgpriv2.c b/fs/netfs/read_pgpriv2.c
index bf4d9d6877d7..5280b606fda4 100644
--- a/fs/netfs/read_pgpriv2.c
+++ b/fs/netfs/read_pgpriv2.c
@@ -158,8 +158,7 @@ void netfs_pgpriv2_end_copy_to_cache(struct netfs_io_request *rreq)
 		return;
 
 	netfs_issue_write(creq, &creq->io_streams[1]);
-	smp_wmb(); /* Write lists before ALL_QUEUED. */
-	set_bit(NETFS_RREQ_ALL_QUEUED, &creq->flags);
+	netfs_all_subreqs_queued(creq);
 	trace_netfs_rreq(rreq, netfs_rreq_trace_end_copy_to_cache);
 	if (list_empty_careful(&creq->io_streams[1].subrequests))
 		netfs_wake_collector(creq);
diff --git a/fs/netfs/read_single.c b/fs/netfs/read_single.c
index de67ac41548d..ccb5fc809d99 100644
--- a/fs/netfs/read_single.c
+++ b/fs/netfs/read_single.c
@@ -113,14 +113,12 @@ static int netfs_single_dispatch_read(struct netfs_io_request *rreq)
 				goto cancel;
 		}
 
-		smp_wmb(); /* Write lists before ALL_QUEUED. */
-		set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
+		netfs_all_subreqs_queued(rreq);
 		rreq->netfs_ops->issue_read(subreq);
 		rreq->submitted += subreq->len;
 		break;
 	case NETFS_READ_FROM_CACHE:
-		smp_wmb(); /* Write lists before ALL_QUEUED. */
-		set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
+		netfs_all_subreqs_queued(rreq);
 		trace_netfs_sreq(subreq, netfs_sreq_trace_submit);
 		netfs_single_read_cache(rreq, subreq);
 		rreq->submitted += subreq->len;
@@ -136,8 +134,7 @@ static int netfs_single_dispatch_read(struct netfs_io_request *rreq)
 	return ret;
 cancel:
 	netfs_cancel_read(subreq, ret);
-	smp_wmb(); /* Write lists before ALL_QUEUED. */
-	set_bit(NETFS_RREQ_ALL_QUEUED, &rreq->flags);
+	netfs_all_subreqs_queued(rreq);
 	netfs_wake_collector(rreq);
 	return ret;
 }
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index e01233de41f5..b328463a73d9 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -422,9 +422,8 @@ bool netfs_write_collection(struct netfs_io_request *wreq)
 	/* We're done when the app thread has finished posting subreqs and all
 	 * the queues in all the streams are empty.
 	 */
-	if (!test_bit(NETFS_RREQ_ALL_QUEUED, &wreq->flags))
+	if (!netfs_are_all_subreqs_queued(wreq))
 		return false;
-	smp_rmb(); /* Read ALL_QUEUED before lists. */
 
 	transferred = LONG_MAX;
 	for (s = 0; s < NR_IO_STREAMS; s++) {
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index c3db732a20af..2783cf8a408b 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -520,8 +520,7 @@ static void netfs_end_issue_write(struct netfs_io_request *wreq)
 {
 	bool needs_poke = true;
 
-	smp_wmb(); /* Write subreq lists before ALL_QUEUED. */
-	set_bit(NETFS_RREQ_ALL_QUEUED, &wreq->flags);
+	netfs_all_subreqs_queued(wreq);
 
 	for (int s = 0; s < NR_IO_STREAMS; s++) {
 		struct netfs_io_stream *stream = &wreq->io_streams[s];
@@ -667,9 +666,7 @@ int netfs_writeback_single(struct address_space *mapping,
 		netfs_issue_write(wreq, stream);
 	}
 
-	smp_wmb(); /* Write lists before ALL_QUEUED. */
-	set_bit(NETFS_RREQ_ALL_QUEUED, &wreq->flags);
-
+	netfs_all_subreqs_queued(wreq);
 	netfs_wake_collector(wreq);
 
 	/* TODO: Might want to be async here if WB_SYNC_NONE, but then need to
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index b18952627f16..e94df94abf8c 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -47,6 +47,7 @@
 	E_(NETFS_PGPRIV2_COPY_TO_CACHE,		"2C")
 
 #define netfs_rreq_traces					\
+	EM(netfs_rreq_trace_all_queued,		"ALL-Q  ")	\
 	EM(netfs_rreq_trace_assess,		"ASSESS ")	\
 	EM(netfs_rreq_trace_collect,		"COLLECT")	\
 	EM(netfs_rreq_trace_complete,		"COMPLET")	\

