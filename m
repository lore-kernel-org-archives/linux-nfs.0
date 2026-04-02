Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 264863F8814
	for <linux-nfs@vger.kernel.org>; Thu,  2 Apr 2026 23:12:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775171564; cv=none; b=Ymh/9pLbZp41amQe3f6hL9p/PgtjeL4bmepOQe5KTNv9iqognCihxm39eDIWir4QZ8oQ2UEhMCnWuVQtjmjAnG+7hUPeyVcbgc4gKG/Q28lMxR52QIQ3kRu9/xSKFTZG4gsBBJ/xLmGMd/q48fMHu+nYkKial3uurV52li3p1iU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775171564; c=relaxed/simple;
	bh=/CR+kZsH7SsqmKv+KZG+JyDwRejW2OBRZB9RFCQCieI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=KCuHiiiInQskiLTneGrK/Xih7FNnqf+paQyJWZ/ZXBYe/n+TEjsi8MtV7kmF6sP58AtPmcQQrxUhOIwKtp89n8dRplV1QH9yDwWmQ346ZrE95YoJGUCq7B3GsBb4H5OFfI9Q14SLDprg8vRsY3eXT+rzfR23a9TWaoPQTm8CpfI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=YnhylVOE; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="YnhylVOE"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1775171562;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=aVU5/robEuhXH087do4D+WQLdiDM8c2d/i5mi/9qma4=;
	b=YnhylVOES7zIhBxfVeZUp99+ac+3xrFWD6ZKwrvx7j5BPEfdusjF38dDlAh0v3h8XqQnEG
	MkZ9gdvIJM/VbIos5KM+CdjUV1g00QvP3zqC2r9DnvvU+McaHuUqGaRMTRZZ17Hug23GUn
	3MQhpufHbwzCnCq3rXVi8oExULIOOIo=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-150-o-QrCyCaMTClaIjCXUW5Rg-1; Thu,
 02 Apr 2026 19:12:39 -0400
X-MC-Unique: o-QrCyCaMTClaIjCXUW5Rg-1
X-Mimecast-MFC-AGG-ID: o-QrCyCaMTClaIjCXUW5Rg_1775171558
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 07A05180049D;
	Thu,  2 Apr 2026 23:12:38 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.81.6])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 452AD19560A6;
	Thu,  2 Apr 2026 23:12:37 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trond.myklebust@hammerspace.com,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFS: fix RENAME attr in presence of directory delegations
Date: Thu,  2 Apr 2026 19:12:36 -0400
Message-ID: <20260402231236.46595-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Since commit 6f9bda2337f8 ("NFS: Fix directory delegation
verifier checks") xfstest generic/309 is failing because after
the rename (mv) operation, client's mtime/ctime is the same.
Update the delegated mtime when directory delegations are
present in rename.

Fixes: 6f9bda2337f8 ("NFS: Fix directory delegation verifier checks")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/inode.c    | 3 ++-
 fs/nfs/nfs4proc.c | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3a5bba7e3c92..43a0543364b8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -692,7 +692,8 @@ void nfs_update_delegated_atime(struct inode *inode)
 
 void nfs_update_delegated_mtime_locked(struct inode *inode)
 {
-	if (nfs_have_delegated_mtime(inode))
+	if (nfs_have_delegated_mtime(inode) ||
+	    nfs_have_directory_delegation(inode))
 		nfs_update_mtime(inode);
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 768de9935ff1..dd800403a7ce 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5052,6 +5052,7 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 					res->new_fattr->time_start,
 					NFS_INO_INVALID_NLINK |
 					    NFS_INO_INVALID_DATA);
+			nfs_update_delegated_mtime(new_dir);
 		} else
 			nfs4_update_changeattr(old_dir, &res->old_cinfo,
 					res->old_fattr->time_start,
-- 
2.52.0

