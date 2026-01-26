Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DC691A3178
	for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2026 19:16:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769454969; cv=none; b=jcmWdmjI8pSOh3g7GGD/lNBi/y+zWWLNKmTAIKPnvKBrL6cPy9XKWkmz4xM7kRPMSV8RJYbQZA+RIBXx27GqDVrO/NldH7/spVBjzyonnXSettIQvgTWqgJuD6KaL97Gumv77qYn3mAadW9x4Q+W2GDJS7joScEOiUXvXgfckww=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769454969; c=relaxed/simple;
	bh=aZ0Zy2EK1CNFrxC039OrtNcZNxkVD+ScxC3qjWAsMkI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=io5M8p1/ZAcIyzPcXiJm80vebS0xnfJKnRUTfH3Hp+RE2yqq1jSSfkQ7Uq14nr0fAKL/6P48qq5wbrJ63x5R37nwVcwhzGSRd8J05F6xJvqBGSTzLmRPOPI3sObuPVMk3PhnQl6Hl7C/mEptYy2tu/0pQv5oxXu5EkVIXLO+Vzk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=CibmWdwn; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="CibmWdwn"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1769454967;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=bd+PwC0gQCF1NZWm91E84POwKUikM3de5bMDm147GAk=;
	b=CibmWdwnEmMx+x02QMfIRl6HZXxyD5DR+/Hqx2Os1Cmv1AEoHK3RXCiQSNeTIhHw2se71B
	/heU0BiS890LG8T0Fz1HcEfF76eMwFh8a7R2auu2wffrm6+nbqLk2mOSdlLT+oi6OKKa3T
	MxtSlHHsJvfjqo8gCMiIPS9kzNsf6fA=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-311-ZaVmJ3DaPL6j_sMKfcrkgQ-1; Mon,
 26 Jan 2026 14:16:03 -0500
X-MC-Unique: ZaVmJ3DaPL6j_sMKfcrkgQ-1
X-Mimecast-MFC-AGG-ID: ZaVmJ3DaPL6j_sMKfcrkgQ_1769454962
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D2D621944B0C;
	Mon, 26 Jan 2026 19:16:02 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.81.42])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 06E191956095;
	Mon, 26 Jan 2026 19:16:01 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trond.myklebust@hammerspace.com,
	anna.schumaker@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] pNFS: fix a missing wake up while waiting on NFS_LAYOUT_DRAIN
Date: Mon, 26 Jan 2026 14:15:39 -0500
Message-ID: <20260126191539.4280-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

It is possible to have a task get stuck on waiting on the
NFS_LAYOUT_DRAIN in the following scenario

1. cpu a: waiter test NFS_LAYOUT_DRAIN (1) and plh_outstanding (1)
2. cpu b: atomic_dec_and_test() -> clear bit -> wake up
3. cpu c: sets NFS_LAYOUT_DRAIN again
4. cpu a: calls wait_on_bit() sleeps forever.

To expand on this we have say 2 outstanding pnfs write IO that get
ESTALE which causes both to call pnfs_destroy_layout() and set the
NFS_LAYOUT_DRAIN bit but the 1st one doesn't call the
pnfs_put_layout_hdr() yet (as that would prevent the 2nd ESTALE write
from trying to call pnfs_destroy_layout()). If the 1st ESTALE write
is the one that initially sets the NFS_LAYOUT_DRAIN so that new IO
on this file initiates new LAYOUTGET. Another new write would find
NFS_LAYOUT_DRAIN set and phl_outstanding>0 (step 1) and would
wait_on_bit(). LAYOUTGET completes doing step 2. Now, the 2nd of
ESTALE writes is calling pnfs_destory_layout() and set the
NFS_LAYOUT_DRAIN bit (step 3). Finally, the waiting write wakes up
to check the bit and goes back to sleep.

The problem revolves around the fact that if NFS_LAYOUT_INVALID_STID
was already set, it should not do the work of
pnfs_mark_layout_stateid_invalid(), thus NFS_LAYOUT_DRAIN will not
be set more than once for an invalid layout.

Suggested-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Fixes: 880265c77ac4 ("pNFS: Avoid a live lock condition in pnfs_update_layout()")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/pnfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f22943fb91cf..e5c50a24c83a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -463,7 +463,8 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 	};
 	struct pnfs_layout_segment *lseg, *next;
 
-	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+	if (test_and_set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags))
+		return !list_empty(&lo->plh_segs);
 	clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(lo->plh_inode)->flags);
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		pnfs_clear_lseg_state(lseg, lseg_list);
-- 
2.47.3

