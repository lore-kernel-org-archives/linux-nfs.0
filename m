Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D03A352017
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:45:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787582724; cv=none; b=VritSY0npbgZPrTAqbIKRLFOR7rSbuvkbDc4ilUDVOfJY3c6k0PaYVCEpRKdSDXYoTzUx3ZXAbe7K9jwJrEySNC8U04W2/JthylSH3ywPSAdkn8FSRqJxSlf1WymBvb7opoc8XRjtXdnVntN5nJNL4oGaPLIKHIOqFPoZUnmPTU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787582724; c=relaxed/simple;
	bh=5zSMz6OLTUHrQTCIhBj7aLAr9qMlQqWCFMxBwsTGFEU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Zg3+HeHYK7j1cBl8RbkiD2se6RSXR32dQJhQUs/B5xlVWAghjLCnUFfLfrspcodygdYsJD7LWddNV9jmjvOaKGGcnvp6+xL85vzJbwDE0xaTUqvHJP7mOAPyGenkWSOWaIX0E5qxgTaJeb0E75vDuovua+oYxw5eu7VFQ0WbjqU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=gLxL+k2S; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gLxL+k2S"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787582720;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=uz94seJkld4/VYmPIzePLWpyWumrSoaTR2JUNJSPhWI=;
	b=gLxL+k2SKHBo6xmIjwz5hfbeKHDZFI+foaXttoWVPu8KB+PuUD/PFt2dwMDi5za+aIAj2R
	LHrgdx0ohvoyv56tnX5BsrHrdO3Jo2F915j22CPXJbMkGL7uQ3+Y5ZVfCsH3mhiMbtSgsv
	rJLD/mENOjN4cCFwSJ+G57guJkvI7J0=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-103-mDOs-YwvM82jIQKWZb6chA-1; Mon,
 24 Aug 2026 10:45:16 -0400
X-MC-Unique: mDOs-YwvM82jIQKWZb6chA-1
X-Mimecast-MFC-AGG-ID: mDOs-YwvM82jIQKWZb6chA_1787582713
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D3E731944B30;
	Mon, 24 Aug 2026 14:45:12 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.15])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2B9EF30002ED;
	Mon, 24 Aug 2026 14:45:05 +0000 (UTC)
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
	Shyam Prasad N <sprasad@microsoft.com>,
	Tom Talpey <tom@talpey.com>
Subject: [PATCH v10 25/35] smbdirect: Remove support for ITER_FOLIOQ from smbdirect_map_sges_from_iter()
Date: Mon, 24 Aug 2026 15:41:18 +0100
Message-ID: <20260824144130.759997-26-dhowells@redhat.com>
In-Reply-To: <20260824144130.759997-1-dhowells@redhat.com>
References: <20260824144130.759997-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

netfslib now only presents an bvecq queue and an associated ITER_BVECQ
iterator to the filesystem, so it isn't going to see the ITER_FOLIOQ
iterator.  So remove that code.

Netfslib also won't supply ITER_BVEC/KVEC iterators, though smbdirect
might; further in future, it won't supply iterators at all, but rather a
bvecq slice (that can be used to construct an iterator).

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Stefan Metzmacher <metze@samba.org>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Namjae Jeon <linkinjeon@kernel.org>
cc: Stefan Metzmacher <metze@samba.org>
cc: Shyam Prasad N <sprasad@microsoft.com>
cc: Tom Talpey <tom@talpey.com>
cc: linux-cifs@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/smb/smbdirect/connection.c | 68 -----------------------------------
 1 file changed, 68 deletions(-)

diff --git a/fs/smb/smbdirect/connection.c b/fs/smb/smbdirect/connection.c
index f5e7e75dd809..f217cf127cf9 100644
--- a/fs/smb/smbdirect/connection.c
+++ b/fs/smb/smbdirect/connection.c
@@ -6,7 +6,6 @@
 
 #include "internal.h"
 #include <linux/bvecq.h>
-#include <linux/folio_queue.h>
 
 struct smbdirect_map_sges {
 	struct ib_sge *sge;
@@ -2131,70 +2130,6 @@ static ssize_t smbdirect_map_sges_from_kvec(struct iov_iter *iter,
 	return ret;
 }
 
-/*
- * Extract folio fragments from a FOLIOQ-class iterator and add them to an
- * ib_sge list.  The folios are not pinned.
- */
-static ssize_t smbdirect_map_sges_from_folioq(struct iov_iter *iter,
-					      struct smbdirect_map_sges *state,
-					      ssize_t maxsize)
-{
-	const struct folio_queue *folioq = iter->folioq;
-	unsigned int slot = iter->folioq_slot;
-	ssize_t ret = 0;
-	size_t offset = iter->iov_offset;
-
-	if (WARN_ON_ONCE(!folioq))
-		return -EIO;
-
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = folioq->next;
-		if (WARN_ON_ONCE(!folioq))
-			return -EIO;
-		slot = 0;
-	}
-
-	do {
-		struct folio *folio = folioq_folio(folioq, slot);
-		size_t fsize = folioq_folio_size(folioq, slot);
-
-		if (offset < fsize) {
-			size_t part = umin(maxsize, fsize - offset);
-			bool ok;
-
-			ok = smbdirect_map_sges_single_page(state,
-							    folio_page(folio, 0),
-							    offset,
-							    part);
-			if (!ok)
-				return -EIO;
-
-			offset += part;
-			ret += part;
-			maxsize -= part;
-		}
-
-		if (offset >= fsize) {
-			offset = 0;
-			slot++;
-			if (slot >= folioq_nr_slots(folioq)) {
-				if (!folioq->next) {
-					WARN_ON_ONCE(ret < iter->count);
-					break;
-				}
-				folioq = folioq->next;
-				slot = 0;
-			}
-		}
-	} while (state->num_sge < state->max_sge && maxsize > 0);
-
-	iter->folioq = folioq;
-	iter->folioq_slot = slot;
-	iter->iov_offset = offset;
-	iter->count -= ret;
-	return ret;
-}
-
 /*
  * Extract page fragments from up to the given amount of the source iterator
  * and build up an ib_sge list that refers to all of those bits.  The ib_sge list
@@ -2225,9 +2160,6 @@ static ssize_t smbdirect_map_sges_from_iter(struct iov_iter *iter, size_t len,
 	case ITER_KVEC:
 		ret = smbdirect_map_sges_from_kvec(iter, state, len);
 		break;
-	case ITER_FOLIOQ:
-		ret = smbdirect_map_sges_from_folioq(iter, state, len);
-		break;
 	default:
 		WARN_ONCE(1, "iov_iter_type[%u]\n", iov_iter_type(iter));
 		return -EIO;

