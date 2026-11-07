Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794021166;
	b=cjb2FzCckmdZVo/ur0ZK4wLsDc6WGXhbAyPm05Augo0wbKI+uhTdBU44qq6fv34/pMJc
	 TPcl5cgnZd/66DeZ53D19PVCiIMo50tPbsHhzFfvrBmyGWEce7cUBUs05iy1fd/t9vEdw
	 F9QfpD84thbchQYVDXuF2xSKq/slfYvZbPowyqhC4GyAIRilMeB7cF9oUBPuaMvrznaJH
	 dZ0LyjmoPBwCipPqoF6W4Btf4yj2HuNL9Zy/u4QFguMqgknL3zr5tbU1JEIxALI0h1uZd
	 XOFbSj2xbojzoBtC29x0emHsvLZ2u8RQKbwCsnqgcxghFj3tJZCsIUaYW4sDo4nOrzQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794021166;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=QUykT6/oCQ1/IQBpd0ZSb7vyvYtfwXdcWhR02rdmMI4=;
	b=ziQ6n3pVGkkao5BDyH6ogMcnnnsEqQC+F8SMgFEHfb1wkb9zhrSoQ/5ZvdxKJWjbEz/F
	 PF5OdbVt/uNMSl3PA9oCyugYaX1YjF44kn5xxnyERocXnDSXhsvTGs/8U116p2emo2wG5
	 ZOIeeXoGTCUrIUfc/Zu1XzJvF8Ib5uwqjZ/L2Sz9InDnHuXi+C2mYOyGNIwIvEoE5JhES
	 fVaWk1j5Qga5E1lrwjm7bVtjISHzjzRI3Pke9AUCrcDKhbEg6oULLF6k34M6D46lKBcwx
	 MNblkRjbWb0wVlUV5/6o8wxmUcSshG/qzRnlCqplEU6B12NnpYympM+Pye1MKg7q6nQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A238606A32C
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 03:12:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5A238606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794021159;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=QUykT6/oCQ1/IQBpd0ZSb7vyvYtfwXdcWhR02rdmMI4=;
	b=cYpWTr6gjH3ULB53h6ctl/Nc+BLs+PtUWx4pxySVlMlEz3gyUqPf/GFEul9KNb0DcxbfU8
	U09v2FAgcn2fKDNkgVZEtiPbdebL3L5W710Tjvjx2eQNHTm6SQRkwaKGC6pzi3jjajATKC
	bexaGyw85IQE1aOgDTai6QJnE/WZwkM=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-210-cnqgfvkpP6Oqfb7ZTDpg8Q-1; Fri,
 06 Nov 2026 22:12:36 -0500
X-MC-Unique: cnqgfvkpP6Oqfb7ZTDpg8Q-1
X-Mimecast-MFC-AGG-ID: cnqgfvkpP6Oqfb7ZTDpg8Q_1794021155
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 42C9E19560B6;
	Sat,  7 Nov 2026 03:12:35 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.6])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8E36E187C364;
	Sat,  7 Nov 2026 03:12:34 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: wake blocking lock waiters when a delegated lock  is released
Date: Fri,  6 Nov 2026 22:12:31 -0500
Message-ID: <20261107031232.97464-2-okorniev@redhat.com>
In-Reply-To: <20261107031232.97464-1-okorniev@redhat.com>
References: <20261107031232.97464-1-okorniev@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

When the client holds a delegation, _nfs4_proc_setlk() caches POSIX
locks locally and never sends a LOCK to the server. It has to strip
FL_SLEEP to do so, since that branch runs holding
sp->so_delegreturn_mutex and nfsi->rwsem and F_SETLKW can block
indefinitely. A contending waiter is therefore never placed on the VFS
blocked-lock list, and locks_wake_up_blocks() does not reach it when the
holder releases.

The waiter blocks in nfs4_retry_setlk() on clp->cl_lock_waitq instead,
whose only waker is nfs4_callback_notify_lock(). The server never saw a
LOCK for a cached lock, so it does not know anyone is waiting and will
never send a CB_NOTIFY_LOCK; nfs4_proc_unlck() returns early without
sending LOCKU for the same reason. The waiter sleeps out the full
NFS4_LOCK_MAXTIMEOUT of 30s before retrying a lock that is long free.

Wake cl_lock_waitq when releasing a cached lock. The releasing thread
cannot tell which waiter wants the lock, so the wakeup names only the
inode; make the owner comparison in nfs4_wake_lock_waiter() conditional
on cbnl_valid so that a CB_NOTIFY_LOCK still wakes exactly the owner it
names. The inode restriction matters: without it every blocked locker
for the server is woken, and those on non-delegated state each retry
with a LOCK RPC.

Fixes: a1d617d8f134 ("nfs: allow blocking locks to be awoken by lock callbacks")
Assisted-by: Claude Opus 5
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/nfs4proc.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1018b03c1cb..50d36dc58fc6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7287,8 +7287,15 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	if (status != 0)
 		goto out;
 	/* Is this a delegated lock? */
-	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) == 0)
+	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) == 0) {
+		struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+		struct cb_notify_lock_args cbnl = { .cbnl_valid = false };
+
+		/* The server never saw it, so it will not notify waiters */
+		nfs_copy_fh(&cbnl.cbnl_fh, NFS_FH(inode));
+		__wake_up(&clp->cl_lock_waitq, TASK_NORMAL, 0, &cbnl);
 		goto out;
+	}
 	alloc_seqid = NFS_SERVER(inode)->nfs_client->cl_mvops->alloc_seqid;
 	seqid = alloc_seqid(&lsp->ls_seqid, GFP_KERNEL);
 	status = -ENOMEM;
@@ -7708,8 +7715,14 @@ nfs4_wake_lock_waiter(wait_queue_entry_t *wait, unsigned int mode, int flags, vo
 		struct nfs_lowner		*lowner = &cbnl->cbnl_owner,
 						*wowner = &waiter->owner;
 
-		/* Only wake if the callback was for the same owner. */
-		if (lowner->id != wowner->id || lowner->s_dev != wowner->s_dev)
+		/*
+		 * Only wake the owner a CB_NOTIFY_LOCK names. A lock cached
+		 * under a delegation is released locally, and the releasing
+		 * thread cannot tell which waiter wants it, so those wakeups
+		 * (cbnl_valid false) name only the inode and wake them all.
+		 */
+		if (cbnl->cbnl_valid &&
+		    (lowner->id != wowner->id || lowner->s_dev != wowner->s_dev))
 			return 0;
 
 		/* Make sure it's for the right inode */
-- 
2.52.0

