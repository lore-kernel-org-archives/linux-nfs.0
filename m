Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61346371043
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:46:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787582773; cv=none; b=OCiQ8z7tSaqxGC+U9DS+KkkkP5lPyDJhCugEWmwZ5dPLGeEgWBa0oNhMRKv8oZdn0qeF6m0cON3QYnVgp3dNNmm6b89cfihvFtVgXFjNNzz0+cbb9arfJS+A/jkxP9O/7tRQtG1CzdZNQbDzediH5gTKPr8jIKVCR0tCSq3pNq8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787582773; c=relaxed/simple;
	bh=jLZOtodk8nbd9Up582gA9ylmJJboXVq9JuWLiXTb8Z4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CqzeOmCPL+/MoBz7eb1ud+7zIQIAbQE5Fo1ar1kIfM1YG4UgCYDH5Krq4MD6wDPI2GlqmEfr2i/Ogm9j2B99hylvWAeIhlodeO2oCxePHHAhaf3U/MqPwcFQqBhVHS7YXM7XpWwUAsW6pc7wf16rmmIWCOh5Zwm+YRuFvehqA5c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=XcRdJKMx; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="XcRdJKMx"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787582770;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=TDDdhH66HohUGjb0SYEEP34XQgxP3o5V8whXb/26vVw=;
	b=XcRdJKMxqjBjrWbYIh2123kGtH/OutS5AGyeDB9p2uK3okdD0rLZAoIjQvuVtso35Y2e9/
	mcbMkHgQmwMF29Lptd7fcDyPs38MoTnnCQc85Q7Hp06MxoAUcRpPDsTZ8ukrwk2o2wRayX
	YLcpeZSPHnRnN79VhRXENB1QPddWzzw=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-434-fVFbgLSmOnm4tY4YBQm-VQ-1; Mon,
 24 Aug 2026 10:46:04 -0400
X-MC-Unique: fVFbgLSmOnm4tY4YBQm-VQ-1
X-Mimecast-MFC-AGG-ID: fVFbgLSmOnm4tY4YBQm-VQ_1787582761
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5E2EC19541B1;
	Mon, 24 Aug 2026 14:46:01 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.15])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2B4B41971E53;
	Mon, 24 Aug 2026 14:45:54 +0000 (UTC)
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
Subject: [PATCH v10 31/35] netfs: Check for too much data being read
Date: Mon, 24 Aug 2026 15:41:24 +0100
Message-ID: <20260824144130.759997-32-dhowells@redhat.com>
In-Reply-To: <20260824144130.759997-1-dhowells@redhat.com>
References: <20260824144130.759997-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Put in a check in read subreq termination to detect more data being read
for a subrequest than was requested.  In the event that this happens, abort
the rest of the read request on the basis that some of the read buffer may
have been corrupted and return -EIO.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/read_collect.c      | 24 ++++++++++++++++++++++++
 include/trace/events/netfs.h |  1 +
 2 files changed, 25 insertions(+)

diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index a648e404ed04..e91f7962df04 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -339,6 +339,15 @@ static void netfs_collect_read_results(struct netfs_io_request *rreq)
 			notes |= HIT_PENDING;
 
 		transferred = READ_ONCE(front->transferred);
+		if (unlikely(transferred > front->len)) {
+			/* Ugh...  A subreq overran its allotted length.  It
+			 * may have corrupted the read buffer.
+			 */
+			stream->failed = true;
+			stream->error = -EIO;
+			rreq->error = -EIO;
+			goto abandon_request;
+		}
 
 		/* If we can collect the next folio from a pending op, do so,
 		 * but we should only do it if we don't otherwise need to wait
@@ -655,6 +664,21 @@ void netfs_read_subreq_terminated(struct netfs_io_subrequest *subreq)
 		break;
 	}
 
+	/* If the subrequest read more than it was supposed to, abort
+	 * the request with EIO as we may have clobbered other parts
+	 * of the buffer that are already read.
+	 */
+	if (subreq->transferred > subreq->len) {
+		trace_netfs_sreq(subreq, netfs_sreq_trace_too_much);
+		__set_bit(NETFS_SREQ_FAILED, &subreq->flags);
+		__clear_bit(NETFS_SREQ_NEED_RETRY, &subreq->flags);
+		subreq->error = -EIO;
+		trace_netfs_failure(rreq, subreq, subreq->error, netfs_fail_read);
+		trace_netfs_rreq(rreq, netfs_rreq_trace_set_pause);
+		set_bit(NETFS_RREQ_PAUSE, &rreq->flags);
+		goto skip_error_checks;
+	}
+
 	/* Deal with retry requests, short reads and errors.  If we retry
 	 * but don't make progress, we abandon the attempt.
 	 */
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index 4b2ffd14a1ca..312dc2214d92 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -133,6 +133,7 @@
 	EM(netfs_sreq_trace_submit,		"SUBMT")	\
 	EM(netfs_sreq_trace_superfluous,	"SPRFL")	\
 	EM(netfs_sreq_trace_terminated,		"TERM ")	\
+	EM(netfs_sreq_trace_too_much,		"!TOOM")	\
 	EM(netfs_sreq_trace_wait_for,		"_WAIT")	\
 	EM(netfs_sreq_trace_write,		"WRITE")	\
 	EM(netfs_sreq_trace_write_skip,		"SKIP ")	\

