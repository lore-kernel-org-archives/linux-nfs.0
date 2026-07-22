Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B78829D29F
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 13:02:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784725373; cv=none; b=ksSJb2ln613Q0ZUyB+IrqDcK8Xj3mAPNtXCA9k4kiYuVg2wHZR2Tyz8tVy8TIOu+HLJlX06qWMyziOuyLlJCYdv53LhntgyO7kcGFDsczUttaSa+HuEAYRtHijg7x5jaejZSwTUCKt1RG+4YcNu+zQuUG5aUaOcZQgyvn8Cvmdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784725373; c=relaxed/simple;
	bh=9QSB2VcYohSkUGe3vsdtMud4lVx7Qo+LdiRdtpNDZYs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bafwZhbmr4h5N2rqXdi2SoLsqFIouRret0N+Mvp49Kz6zkuhzs+I1OYCK6S8TSP0gxpN2iIpM3nyddsB5HfweBc02zaOMm1hT4FZDbdf6h6TkymUudUZMCghJlvUphAwHNaDwLeuyI55XN5fkA1R+t3qjOoqTFY/EXrqIyME9Og=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=HMbN5kZl; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="HMbN5kZl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1784725371;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=vprsViKY72rawZWltum/UMfZGzgPWXZ8iTQuEYnb2yU=;
	b=HMbN5kZlhKjRQE71yUm1YiAg7OgB2RJS2vhvX08BJroVKu/mqSb3aqbSFS30rQyfdK/KW8
	xgK2vZGJYKkbPIxcLzqsmWk4GGW0FEK6pY+yUtkZZumjmXzaS4OW80RxRfJieQyDF5/FCC
	YIM8vICRuwT/04yoODYe0RxRBH7mVzU=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-649-GphHkRAXMoOOxTVmcFV2PA-1; Wed,
 22 Jul 2026 09:02:47 -0400
X-MC-Unique: GphHkRAXMoOOxTVmcFV2PA-1
X-Mimecast-MFC-AGG-ID: GphHkRAXMoOOxTVmcFV2PA_1784725364
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id BC9E71800756;
	Wed, 22 Jul 2026 13:02:41 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.33.159])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 3EF5F1955D88;
	Wed, 22 Jul 2026 13:02:32 +0000 (UTC)
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
	linux-kernel@vger.kernel.org,
	Yichong Chen <chenyichong@uniontech.com>
Subject: [PATCH v7 01/29] netfs: clear PG_private_2 on copy-to-cache append failure
Date: Wed, 22 Jul 2026 14:01:48 +0100
Message-ID: <20260722130218.78958-2-dhowells@redhat.com>
In-Reply-To: <20260722130218.78958-1-dhowells@redhat.com>
References: <20260722130218.78958-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

From: Yichong Chen <chenyichong@uniontech.com>

netfs_pgpriv2_copy_to_cache() marks the folio with PG_private_2 before
netfs_pgpriv2_copy_folio() appends it to the copy-to-cache rolling
buffer.

If the append fails, the folio is not queued for cache writeback, so
the PG_private_2 state and its reference must be released immediately.

Fixes: e2d46f2ec332 ("netfs: Change the read result collector to only use one work item")
Signed-off-by: Yichong Chen <chenyichong@uniontech.com>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/read_pgpriv2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/netfs/read_pgpriv2.c b/fs/netfs/read_pgpriv2.c
index a1489aa29f78..7eacc58abadb 100644
--- a/fs/netfs/read_pgpriv2.c
+++ b/fs/netfs/read_pgpriv2.c
@@ -54,6 +54,7 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 
 	/* Attach the folio to the rolling buffer. */
 	if (rolling_buffer_append(&creq->buffer, folio, 0) < 0) {
+		folio_end_private_2(folio);
 		clear_bit(NETFS_RREQ_FOLIO_COPY_TO_CACHE, &creq->flags);
 		return;
 	}

