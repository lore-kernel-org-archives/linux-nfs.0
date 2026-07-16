Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7288416109
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 10:34:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784198044; cv=none; b=i8BXNoxOWZtgM0cl3yNdNdK/6J1kpWJVR33UUtWcHBr5d93JToP/R63qVj/5Kt1SzUp/8H7ZdaK9y7Jsk0Doe6FdinT6yRaFS3M+GhbNHYAm/C/+HPZEeXtCnrqUDNGy3IwPbNfGakT5eKwMBkSMPuF5iFRNqrugIE2CiE65oh8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784198044; c=relaxed/simple;
	bh=8mAs8CjHDy6ADQfzBV3CmvkxuOpNzft13utDVC1gV8E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=opxVbL0AnYoDUDbLA+lqGYaFtW6C8TJhpuPkmTnYr9FwB1H9JSEk2tXWt7ExIymPBSrx8gTEe4O0BscKKf9L8u4i3oLcJ00hnPvUlKCvHM6LykgxzeWelPyTlKcv8Kstx3eRS83irJvD36Z3c7o2gkDUVhmfUrSDLYFQ+KhjooI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ExlEYzYb; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ExlEYzYb"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1784198040;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=HLp2FucSNiA6ysOc5bGEhnTa4rmESbO8KZ0Iu6uIsZg=;
	b=ExlEYzYbqJNcVqU4LzmfcxuTmPR/AXi5sMyUcv/h3hvD60MY3fFeVc2n1maPOft4tcvjf1
	TCCeL1QTSdLEASvqapC/ixMLvd9s5SeQITHRcGLt5fV8Gy9/kwS4N88QNSbtCIrp25op0X
	Q1KLzBtFCv/TzQgw+82NXoix28GjGaw=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-7-dNu4R_umNze5fvIlGF-tBw-1; Thu,
 16 Jul 2026 06:33:57 -0400
X-MC-Unique: dNu4R_umNze5fvIlGF-tBw-1
X-Mimecast-MFC-AGG-ID: dNu4R_umNze5fvIlGF-tBw_1784198034
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 91BB6180066B;
	Thu, 16 Jul 2026 10:33:54 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.33.159])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id B4A971800286;
	Thu, 16 Jul 2026 10:33:48 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Steve French <sfrench@samba.org>,
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
Subject: [PATCH v6 23/24] netfs: Limit the minimum trigger for progress reporting
Date: Thu, 16 Jul 2026 11:30:22 +0100
Message-ID: <20260716103030.3065561-24-dhowells@redhat.com>
In-Reply-To: <20260716103030.3065561-1-dhowells@redhat.com>
References: <20260716103030.3065561-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

For really big read RPC ops that span multiple folios, netfslib allows the
filesystem to give progress notifications to wake up the collector thread
to do a collection of folios that have now been fetched, even if the RPC is
still ongoing, thereby allowing the application to make progress.

The trigger for this is that at least one folio has been downloaded since
the clean point.  If, however, the folios are small, this means the
collector thread is constantly being woken up - which has a negative
performance impact on the system.

Set a minimum trigger of 256KiB or the size of the folio at the front of
the queue, whichever is larger.

Also, fix the base to be the stream collection point, not the point at
which the collector has cleaned up to (which is currently 0 until something
has been collected).

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/read_collect.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index c0170f80d67f..51f361d82fa5 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -494,15 +494,15 @@ void netfs_read_collection_worker(struct work_struct *work)
 void netfs_read_subreq_progress(struct netfs_io_subrequest *subreq)
 {
 	struct netfs_io_request *rreq = subreq->rreq;
-	struct netfs_io_stream *stream = &rreq->io_streams[0];
-	size_t fsize = PAGE_SIZE << rreq->front_folio_order;
+	struct netfs_io_stream *stream = &rreq->io_streams[subreq->stream_nr];
+	size_t fsize = umax(PAGE_SIZE << rreq->front_folio_order, 256 * 1024);
 
 	trace_netfs_sreq(subreq, netfs_sreq_trace_progress);
 
 	/* If we are at the head of the queue, wake up the collector,
 	 * getting a ref to it if we were the ones to do so.
 	 */
-	if (subreq->start + subreq->transferred > rreq->cleaned_to + fsize &&
+	if (subreq->start + subreq->transferred >= stream->collected_to + fsize &&
 	    (rreq->origin == NETFS_READAHEAD ||
 	     rreq->origin == NETFS_READPAGE ||
 	     rreq->origin == NETFS_READ_FOR_WRITE) &&

