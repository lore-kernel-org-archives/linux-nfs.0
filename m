Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5888F3B5835
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2026 10:09:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781604558; cv=none; b=k2j780oAUbp8djVuTMJnn7++zwOZjl/DKtwNQXxAf0qVkDGTJsxXDUo33CNjPz2P4KpqFmbSwskZnGs3DpbRsK3kHQSWobvT0HisTsXRyyCQkzV9X90l8t62DATU9F93GzAmFxl1M/RkZbp7dSx3xCHYVKjT83GDfCy235mNYQo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781604558; c=relaxed/simple;
	bh=CXb4scghqG9bFlw210zzKTVnfTq+PEMbzIEvZiOlPoE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=d7/DrzhfY46qlatkQg4dctpB5zthsEY3knFhBlyNibGVI2o+uEKwNzYIEvKRfVP0sZ4OQ9BpAPHk/Zf0IN/3SvklGNN2evMlmph25OS9TUxyPlzSCDnc8Q2sq6UiiGZJZZCYFd8oGjTb+kSq7eMZzquD39/IlA45NoPz9AyayJ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=fhKmo/aK; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="fhKmo/aK"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1781604556;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ElRcRW2ORewxJR51AX9zH5/PcYxatkHyMOGHJQJeHbA=;
	b=fhKmo/aKsHXqkR6wJPovEQXe3tdU/0jJ4/Ti4G0wIEnOWitR4P82KiVeID0q7rh9duBtx/
	4/1OYi4o1Jk9xzyBG8ZTYODalVUTTy1gvhYetiYlNpjv7CYyRsCxe+SCKli5EPUoXzlP2F
	0xuWqHXzXXI6ZvDJzz7qDb0mq/chQ48=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-591-A1lN4myLMPuZ_6M-3L4OAg-1; Tue,
 16 Jun 2026 06:09:13 -0400
X-MC-Unique: A1lN4myLMPuZ_6M-3L4OAg-1
X-Mimecast-MFC-AGG-ID: A1lN4myLMPuZ_6M-3L4OAg_1781604549
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7E5C3180025E;
	Tue, 16 Jun 2026 10:09:09 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.50.44])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8E001180034F;
	Tue, 16 Jun 2026 10:09:02 +0000 (UTC)
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
	Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v4 04/30] iov_iter: Fix missing alloc fail check in iov_iter_extract_bvec_pages()
Date: Tue, 16 Jun 2026 11:07:53 +0100
Message-ID: <20260616100821.2062304-5-dhowells@redhat.com>
In-Reply-To: <20260616100821.2062304-1-dhowells@redhat.com>
References: <20260616100821.2062304-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Fix iov_iter_extract_bvec_pages() to check if want_pages_array() fails and,
if so, return -ENOMEM appropriately.

Fixes: e4e535bff2bc ("iov_iter: don't require contiguous pages in iov_iter_extract_bvec_pages")
Link: https://sashiko.dev/#/patchset/20260608145432.681865-1-dhowells%40redhat.com
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Ming Lei <ming.lei@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 lib/iov_iter.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index dc9c6eb21bdb..6386ae4ef491 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -1631,6 +1631,8 @@ static ssize_t iov_iter_extract_bvec_pages(struct iov_iter *i,
 	bi.bi_bvec_done = skip;
 
 	maxpages = want_pages_array(pages, maxsize, skip, maxpages);
+	if (!maxpages)
+		return -ENOMEM;
 
 	while (bi.bi_size && bi.bi_idx < i->nr_segs) {
 		struct bio_vec bv = bvec_iter_bvec(i->bvec, bi);

