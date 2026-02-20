Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DC5330F924
	for <linux-nfs@vger.kernel.org>; Fri, 20 Feb 2026 21:42:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771623747; cv=none; b=RHmqUIb4ya1y9HQ70GIhu8lu6exEXx4Tw88lq1X0+l1BzQHfdq8fIfvCiVhC5uNZSz7153QhmpHyf7+nVW/vmZqtXHRZQKPS8Fp+aGF3vrykrdc22FxC7tzkzuRXTJwk1iZ0U7/pX7W6OSdbAXaRBB3XFse5AfkYFUs+AginaQY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771623747; c=relaxed/simple;
	bh=lq/EldmgTuPW+yf4qZazKNCoILMBJ5fR/yMxxfKF9nc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=s7kQ8W48tXPsOSubbH6Gt9k+pcrvDD12uCIKXVYUeNEYIQiLz+dGXO2mlLO3w4qsOeXFfnSwcemvFcUei0WR6uVavSDiTTt0xJdfyoKVN5EYclHiLZflYu0zWHuj3eFKrbDvghAJz1lV7uYE9dAeaflF+JCIAwXjnPGrDqH6Xs0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Qv7wi8J4; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Qv7wi8J4"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1771623744;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=G3ZR6RfuU4OWvrHUm+pX5q7ViLCSlmylbviSHdz6gOY=;
	b=Qv7wi8J4LdLs2XTnRSTOFWcY8qoMUwX4ktlR+XDn26sULRoG+77BANAa/ynVtnYEmu2+4Y
	qBNJ2ypJFZvh8zfc1L9wdZexA2k0t2vuNEmrCIl9Bt7B5vVcgK7H1bu+TmDzPNpFJZFdda
	YXnWvnVwd9N47v6nVfpLwiXC4VjFjqI=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-556-wOV0sPv7MdSMjZLruTQ-aQ-1; Fri,
 20 Feb 2026 16:42:21 -0500
X-MC-Unique: wOV0sPv7MdSMjZLruTQ-aQ-1
X-Mimecast-MFC-AGG-ID: wOV0sPv7MdSMjZLruTQ-aQ_1771623740
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0F8261956088;
	Fri, 20 Feb 2026 21:42:20 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.80.103])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 4E8C8195419E;
	Fri, 20 Feb 2026 21:42:19 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trond.myklebust@hammerspace.com,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFS: improve "Server wrote zero bytes" error
Date: Fri, 20 Feb 2026 16:42:18 -0500
Message-ID: <20260220214218.78581-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

When a pnfs error occurs, the IO is retried against the MDS. However,
the initial IO leads to the kernel logging "Serer wrote zero bytes"
when in fact the MDS IO will not fail and thus the error misleads
administrators that the system is experiencing issues.

When pnfs IO fails which triggers pnfs_write_done_resent_to_mds() which
would end up clearing nfs_pgio_header's pages structure (copying the
content into a new one to do new RPC calls to the MDS). Thus,
in nfs_writeback_result() when we have no pages to work with no need
to try and also therefore skip logging the message about 0bytes.

Suggested-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2d0e4a765aeb..fe9930f8405b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1551,7 +1551,7 @@ static void nfs_writeback_result(struct rpc_task *task,
 	struct nfs_pgio_args	*argp = &hdr->args;
 	struct nfs_pgio_res	*resp = &hdr->res;
 
-	if (resp->count < argp->count) {
+	if (resp->count < argp->count && !list_empty(&hdr->pages)) {
 		static unsigned long    complain;
 
 		/* This a short write! */
-- 
2.52.0

