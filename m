Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0242E3C3BFA
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 08:00:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790668842; cv=none; b=h8NzTxgUFdE5WrtudXmQXyquGWcMewbbkyKcvse0VMPsaXzb7s5j5nNC3MpJRB5beL7d6RRkh9bTQOeVKiQsiy3g0ARpu8SI2YWqwXxWDkjrk2gX9AcKbl7a76ZoESAI6ATKFTIIAth3EXNNbRp2ShXGMM6pjp6KiA44XZmxT68=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790668842; c=relaxed/simple;
	bh=qU0LIiVfAbiqvJsVXB8Re6g1+FLqUy6lovReP1kYQbg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Iqrzpj9dmAvQadBUITnto/sKCxXfc+G08n3DRoecLuiTGfy2iiVOXXQR3ZcNiFAcAjYqmwXwnBZhJ1rEYJuDdL46R0PoEsOqk2UT5qwBQx4FjsqecsMObKQ430q0fKd1qJQHEmcJRk97+S0J/u2hFfEpYhxPIk/7eG/PKv2QY44=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=eI7yvE3j; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="eI7yvE3j"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790668840;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=wTR+Y7XrGbqO6yFXTqJ8jDfjyeqyr330PNRIkxRcZlo=;
	b=eI7yvE3j1a9aI4akqYE8ftM6FZMaL+EFJF1i4KAPkx2UQZluOFfCoIUkhvJAv+QRJ6t5in
	vUWKsGcNZslvEeNiV2CjyESmHyuNUBpfHVaew/xYO7+ZF+EQtst4EvJw4i15spNYAM+buo
	SVhiz6X+RnhkItRugkn6QaaTCuWEWlc=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-633-Syz1GpI1MVSJenCNr7hi4A-1; Tue,
 29 Sep 2026 04:00:33 -0400
X-MC-Unique: Syz1GpI1MVSJenCNr7hi4A-1
X-Mimecast-MFC-AGG-ID: Syz1GpI1MVSJenCNr7hi4A_1790668831
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3B55019775A2;
	Tue, 29 Sep 2026 08:00:31 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8028A40E;
	Tue, 29 Sep 2026 08:00:25 +0000 (UTC)
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
	Shyam Prasad N <sprasad@microsoft.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v12 08/10] smbdirect: Remove support for ITER_FOLIOQ from smbdirect_map_sges_from_iter()
Date: Tue, 29 Sep 2026 08:59:09 +0100
Message-ID: <20260929075913.2740968-9-dhowells@redhat.com>
In-Reply-To: <20260929075913.2740968-1-dhowells@redhat.com>
References: <20260929075913.2740968-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

netfslib now only presents an bvecq queue and an associated ITER_BVECQ
iterator to the filesystem, so it isn't going to see the ITER_FOLIOQ
iterator.  So remove that code.

Netfslib also won't supply ITER_BVEC/KVEC iterators, though smbdirect
might; further in future, it won't supply iterators at all, but rather a
bvecq slice (that can be used to construct an iterator).

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Stefan Metzmacher <metze@samba.org>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Namjae Jeon <linkinjeon@kernel.org>
cc: Stefan Metzmacher <metze@samba.org>
cc: Shyam Prasad N <sprasad@microsoft.com>
cc: Tom Talpey <tom@talpey.com>
cc: Christoph Hellwig <hch@infradead.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: linux-cifs@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/smb/smbdirect/connection.c | 68 -----------------------------------
 1 file changed, 68 deletions(-)

diff --git a/fs/smb/smbdirect/connection.c b/fs/smb/smbdirect/connection.c
index 7cf8e1f8556f..aa52ecdbef2b 100644
--- a/fs/smb/smbdirect/connection.c
+++ b/fs/smb/smbdirect/connection.c
@@ -6,7 +6,6 @@
 
 #include "internal.h"
 #include <linux/bvecq.h>
-#include <linux/folio_queue.h>
 
 struct smbdirect_map_sges {
 	struct ib_sge *sge;
@@ -2140,70 +2139,6 @@ static ssize_t smbdirect_map_sges_from_kvec(struct iov_iter *iter,
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
@@ -2234,9 +2169,6 @@ static ssize_t smbdirect_map_sges_from_iter(struct iov_iter *iter, size_t len,
 	case ITER_KVEC:
 		ret = smbdirect_map_sges_from_kvec(iter, state, len);
 		break;
-	case ITER_FOLIOQ:
-		ret = smbdirect_map_sges_from_folioq(iter, state, len);
-		break;
 	default:
 		WARN_ONCE(1, "iov_iter_type[%u]\n", iov_iter_type(iter));
 		return -EIO;

