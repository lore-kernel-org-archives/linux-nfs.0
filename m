Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F5D9382F13
	for <linux-nfs@vger.kernel.org>; Thu, 26 Mar 2026 10:46:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774521995; cv=none; b=dru6rRAIJfKj4zT/w4Blflrn6KhPsoLJxGtye8K1X7DA74oHMlB87DXHwtA2fG0lQ/EoHyQF0e+5fZtCaP+Kq3WxgmlK/FmvbLgSb8LMJVSr3fC6WK6xWjkEkOpgXteW66ZDvCGaMCtbSLnNZagn+PLBLoZJYb686aMyigBiskI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774521995; c=relaxed/simple;
	bh=gvz/gcDuW+KetAIQBj5BeJWsKHNMDr4LBMHJoJ7MhWM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PyI1Y9xuxqBBxVw/quFIvRFCVoM5xyTjEcL24ap7EDJXTWZBor3MbVJMD2Au1JrJ+CHaCXjKWWcqycV48ud8Vfx+PMdB3x7adO42hqhv4wzIC1yaY80fAaZElEguLDYF1MxZZzmNMTy3dNpN06/T0eDJUEAEbUxt87ceiEdKtko=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=KMpRow1I; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KMpRow1I"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1774521993;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=MVVzRK3Tmywza1SU8JPOcR6dARnvIl+M3c8pioBtMpU=;
	b=KMpRow1I0ytgwqfiM15ZP1oRhxIY/hf2Xmfy2/Fw5qdNQiUuKHip8WtNWpjNwKVdIf1L2l
	28A9BU/rOvUDbOQliVtTs9kQMQI3lLqKypm5lzj4PC6TLPjRwTeue753YIEovZP4N49apQ
	PaYtJvkuUIfEfGwM25juOsMXxAWWNe0=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-532-bkvv3eYQNDWdQ1hrbBSehg-1; Thu,
 26 Mar 2026 06:46:28 -0400
X-MC-Unique: bkvv3eYQNDWdQ1hrbBSehg-1
X-Mimecast-MFC-AGG-ID: bkvv3eYQNDWdQ1hrbBSehg_1774521985
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 6D192195608B;
	Thu, 26 Mar 2026 10:46:23 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.33.121])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 81831180075C;
	Thu, 26 Mar 2026 10:46:15 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.com>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Steve French <sfrench@samba.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	Trond Myklebust <trondmy@kernel.org>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Deepanshu Kartikey <kartikey406@gmail.com>,
	syzbot+9c058f0d63475adc97fd@syzkaller.appspotmail.com,
	Deepanshu Kartikey <Kartikey406@gmail.com>
Subject: [PATCH 02/26] netfs: Fix kernel BUG in netfs_limit_iter() for ITER_KVEC iterators
Date: Thu, 26 Mar 2026 10:45:17 +0000
Message-ID: <20260326104544.509518-3-dhowells@redhat.com>
In-Reply-To: <20260326104544.509518-1-dhowells@redhat.com>
References: <20260326104544.509518-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

From: Deepanshu Kartikey <kartikey406@gmail.com>

When a process crashes and the kernel writes a core dump to a 9P
filesystem, __kernel_write() creates an ITER_KVEC iterator. This
iterator reaches netfs_limit_iter() via netfs_unbuffered_write(), which
only handles ITER_FOLIOQ, ITER_BVEC and ITER_XARRAY iterator types,
hitting the BUG() for any other type.

Fix this by adding netfs_limit_kvec() following the same pattern as
netfs_limit_bvec(), since both kvec and bvec are simple segment arrays
with pointer and length fields. Dispatch it from netfs_limit_iter() when
the iterator type is ITER_KVEC.

Fixes: cae932d3aee5 ("netfs: Add func to calculate pagecount/size-limited span of an iterator")
Reported-by: syzbot+9c058f0d63475adc97fd@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=9c058f0d63475adc97fd
Tested-by: syzbot+9c058f0d63475adc97fd@syzkaller.appspotmail.com
Signed-off-by: Deepanshu Kartikey <Kartikey406@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---
 fs/netfs/iterator.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/fs/netfs/iterator.c b/fs/netfs/iterator.c
index 72a435e5fc6d..154a14bb2d7f 100644
--- a/fs/netfs/iterator.c
+++ b/fs/netfs/iterator.c
@@ -142,6 +142,47 @@ static size_t netfs_limit_bvec(const struct iov_iter *iter, size_t start_offset,
 	return min(span, max_size);
 }
 
+/*
+ * Select the span of a kvec iterator we're going to use.  Limit it by both
+ * maximum size and maximum number of segments.  Returns the size of the span
+ * in bytes.
+ */
+static size_t netfs_limit_kvec(const struct iov_iter *iter, size_t start_offset,
+			       size_t max_size, size_t max_segs)
+{
+	const struct kvec *kvecs = iter->kvec;
+	unsigned int nkv = iter->nr_segs, ix = 0, nsegs = 0;
+	size_t len, span = 0, n = iter->count;
+	size_t skip = iter->iov_offset + start_offset;
+
+	if (WARN_ON(!iov_iter_is_kvec(iter)) ||
+	    WARN_ON(start_offset > n) ||
+	    n == 0)
+		return 0;
+
+	while (n && ix < nkv && skip) {
+		len = kvecs[ix].iov_len;
+		if (skip < len)
+			break;
+		skip -= len;
+		n -= len;
+		ix++;
+	}
+
+	while (n && ix < nkv) {
+		len = min3(n, kvecs[ix].iov_len - skip, max_size);
+		span += len;
+		nsegs++;
+		ix++;
+		if (span >= max_size || nsegs >= max_segs)
+			break;
+		skip = 0;
+		n -= len;
+	}
+
+	return min(span, max_size);
+}
+
 /*
  * Select the span of an xarray iterator we're going to use.  Limit it by both
  * maximum size and maximum number of segments.  It is assumed that segments
@@ -245,6 +286,8 @@ size_t netfs_limit_iter(const struct iov_iter *iter, size_t start_offset,
 		return netfs_limit_bvec(iter, start_offset, max_size, max_segs);
 	if (iov_iter_is_xarray(iter))
 		return netfs_limit_xarray(iter, start_offset, max_size, max_segs);
+	if (iov_iter_is_kvec(iter))
+		return netfs_limit_kvec(iter, start_offset, max_size, max_segs);
 	BUG();
 }
 EXPORT_SYMBOL(netfs_limit_iter);

