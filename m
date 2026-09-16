Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74CA14EA371
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 12:45:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789562717; cv=none; b=dzfrx+hw+0viIep/d1kWNg6t7paOqfTEU08mRIBEHFsfs6tDiRHX6T1RalDlVYj7JdoEq29EwGeh1irj1AnP4uuxyD+21gkEEae/CZ2KYUXA35CGd4ErooxXsTQ4xZnfZS0Vwn5Gv2ZQgMCtRBhzf47MAntZiQCOoFoF8iI9CCE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789562717; c=relaxed/simple;
	bh=O1d/yGqLM0QLg6r5jtPOLNV/bStIWVTJ8y85WTRia6c=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=s3BRqaBVME5XJQMDe+DSuhVIAYgn25DAf8kgNJZu8jpYn7G/RDOCzN0T7fVS1M7UkbvKyXqTxTV8CSbhjYssXgBrTA+EFgW2eRBIACXjNAS2i/saOgLHYM3yv84BWAHEV1qthW4s5MrNU5snKE4HKMx8PkXCBB7PtrKyIerf59E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=LvYmhOCt; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="LvYmhOCt"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789562715;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=6M1x22AysauHLyVRp+k9MGf9rURggE+80nQpgXR2xRY=;
	b=LvYmhOCtmRibYYTG0ZNwawlCGlNHWBdhN35VKgGHvCVAyXmGO7NWdAX/wEdRwr9ZXphGEG
	n9kOTP4QYh9NaDtAsfh6BE7r9nUPNpeVqZS09Cc4v4jrFcbuR4+h55CJw9H0OZIazmtVS4
	/CdOWjOkG83OtSRANjbLNQ1/cO9zokw=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-29-IhQQ-FNSOJeh7oVupekkNg-1; Wed,
 16 Sep 2026 08:45:13 -0400
X-MC-Unique: IhQQ-FNSOJeh7oVupekkNg-1
X-Mimecast-MFC-AGG-ID: IhQQ-FNSOJeh7oVupekkNg_1789562712
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A8F9219540D7;
	Wed, 16 Sep 2026 12:45:12 +0000 (UTC)
Received: from idlethread.redhat.com (unknown [10.44.48.211])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D73A119560AB;
	Wed, 16 Sep 2026 12:45:10 +0000 (UTC)
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
To: trondmy@kernel.org
Cc: anna@kernel.org,
	neil@brown.name,
	linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: return DENIED in decode_lock_denied if we cannot decode owner
Date: Wed, 16 Sep 2026 14:45:09 +0200
Message-ID: <20260916124509.587700-1-rbergant@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

After commit 43502f6e8d1e ("NFS: fix open_owner_id_maxsz and related
fields.")we dramatically changed the size of the LOCK/LOCKT reply buffer
from 164 to 52 bytes. This made visible a situation on a buggy NFS
server that sent oversized denied responses which led to us returning
EIO instead of DENIED.

Now, apart from buggy server issue, this poses an interesting question:
what if other implementations have legitimate but bigger than we expect
lock owner response, especially now that we have reduced the size we
allocate for it (20bytes for the lock owner part).

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
---
 fs/nfs/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc049ce4ba8a..bae84e228520 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5169,8 +5169,8 @@ static int decode_lock_denied(struct xdr_stream *xdr, struct file_lock *fl)
 	p = xdr_decode_hyper(p, &clientid); /* read 8 bytes */
 	namelen = be32_to_cpup(p); /* read 4 bytes */  /* have read all 32 bytes now */
 	p = xdr_inline_decode(xdr, namelen); /* variable size field */
-	if (likely(!p))
-		return -EIO;
+	/* We have an owner here, return DENIED */
+
 	return -NFS4ERR_DENIED;
 }
 
-- 
2.45.0

