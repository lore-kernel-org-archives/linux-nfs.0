Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CCA434B95D3
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 10:49:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789642167; cv=none; b=IOXxy69kSxB3ynto0bcThvmoOMqB2t/rMtkazxFKCtWqpC9JfH2IX1j40HZ2tkKaAZeGp3rv3QEwTpWsc53rgMJydMBrFsGf3E6YDqzHhJZAo0NcoX8FIaRSLSFLQQRzLI8lLvnJu9uUYVtfqqSQnHbgSULweeJ68+eabjFwaSg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789642167; c=relaxed/simple;
	bh=5CoWkN/u+Mmrp5gIy/gHLcgVKNgqXKA5S0r0nVcHvKc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DBoH6SsiNzJQZBFIWaDQj7rI3F4hln1qbOA6PXz9eZVoNtvnjbfRCXkWCoG19izcg+ZGZsiF6eSgThyt5w/9o79LQ7OOnA9et6uVa9h/khUjoBkyGgGNhkqG64UecFjl5qrE2h2YuFaYgZfpoALVrNjKZfPWTUEiobmC/35zWFo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=G5/7myZJ; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="G5/7myZJ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789642151;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=8vzsKH8kvcTqtVMf3PuReRdVUmTRp9l88ipqg1WvuYc=;
	b=G5/7myZJPrqCiXRnuZoOjBfiUmQky5IXtxEtQsVm8GbUzlnNlJCbTCUCr+Toi6vN5dq8dN
	oBetkuXVMsb4D3uZbkRdiLb3J84uiAzgb7trem9YJT+sDP4PFgXAFLAjDQFLYME5q0mOuF
	H42aGG7kZsHad4pTkjvburVTnVO2cWQ=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-338-e2FHtavAM660SJkRd6d_4A-1; Thu,
 17 Sep 2026 06:49:10 -0400
X-MC-Unique: e2FHtavAM660SJkRd6d_4A-1
X-Mimecast-MFC-AGG-ID: e2FHtavAM660SJkRd6d_4A_1789642149
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5010B18A6973;
	Thu, 17 Sep 2026 10:49:09 +0000 (UTC)
Received: from idlethread.redhat.com (unknown [10.44.48.41])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 183BC180034F;
	Thu, 17 Sep 2026 10:49:06 +0000 (UTC)
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: neil@brown.name,
	prabhakar.pujeri@dell.com,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFS: return DENIED in decode_lock_denied if we cannot decode owner
Date: Thu, 17 Sep 2026 12:49:05 +0200
Message-ID: <20260917104905.669983-1-rbergant@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

After commit 43502f6e8d1e ("NFS: fix open_owner_id_maxsz and related
fields.") we dramatically changed the size of the LOCK/LOCKT reply buffer
from 164 to 52 bytes. This made visible a situation on a buggy NFS
server that sent oversized denied responses which led to us returning
EIO instead of DENIED.

Now, apart from buggy server issue, this poses an interesting question:
what if other implementations have legitimate but bigger than we expect
lock owner response, especially now that we have reduced the size we
allocate for it (20 bytes for the lock owner part).

This change proposes to tackle that issue returning DENIED instead of
EIO regardless of whether we manage to decode the owner or not:

- At this point of decode_lock_denied we know there is an owner.
- Server legitimately denied the lock request, with an owner that fits on
  NFS4_OPAQUE_LIMIT but we returned EIO instead to userspace.
- The owner data is decoded but actually never used, decode_lock path
  simply retries, and decode_lockt turns it into 0 on file_lock and
  returns it to userspace.
- LOCK/LOCKT are the last operations on the compound so it's not relevant
  if we didn't advance the pointer.
- Also removes an inverted likely(!p) hint.

Fixes: 43502f6e8d1e ("NFS: fix open_owner_id_maxsz and related fields.")
Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
Reviewed-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 v2:
  - fixed formatting issues

 fs/nfs/nfs4xdr.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc049ce4ba8a..9d0f7ad7525a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5169,8 +5169,7 @@ static int decode_lock_denied(struct xdr_stream *xdr, struct file_lock *fl)
 	p = xdr_decode_hyper(p, &clientid); /* read 8 bytes */
 	namelen = be32_to_cpup(p); /* read 4 bytes */  /* have read all 32 bytes now */
 	p = xdr_inline_decode(xdr, namelen); /* variable size field */
-	if (likely(!p))
-		return -EIO;
+	/* We have an owner here, return DENIED */
 	return -NFS4ERR_DENIED;
 }
 
-- 
2.45.0

