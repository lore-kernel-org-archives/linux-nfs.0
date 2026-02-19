Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1686A223DD6
	for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2026 19:23:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771529014; cv=none; b=dVSmf8hQCSnDXE56paElA4DfKTzDY5FHQ8Ku3zNKce/baNHTMYRF9IOkrPoLKzR1V5DIhoyfonzYU7fGAm5UHL+byrN1QwbrXZezREYuwx94KPtDjoUByqwboVfQE4apR/FpOnldJt2W1iF8p1EX58QjNNbOB1KjZgK6QexTo74=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771529014; c=relaxed/simple;
	bh=tgDxLp/1LZ2U4OaFykvhM3ZojZT1yiPZcOJRs0oIMRc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=F8rWtQJKTkmZNVgkJgATzZh8ZnubanKUA91dQtk4vcc9VLgYpx4JMxxHLwHYPJEoMcBhKcSVHfyBvmUUXXYN8pj0ePVxF6/WDnIujDExmukw8U3jAhJQtMYBXHfP+DeMj5F8tU4EAtv4+g30Qo1ldYCxCkPLAh3mk85GDrZlIuw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=RclObw6m; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="RclObw6m"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1771529012;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=vqLYjN9jYdLFaMTB9azFTeNO6kbYsB6RKGWlgr1vJGE=;
	b=RclObw6mp+vDR8qkxXwIkDzXrkwdCGzYJhquBGY80rYpcZYCpsgYmC0e5ekwFwd0y+Vzyz
	OsxmLVNr/AGPorvUZAmF8bhZo2TbXBOAUlbXry9s3PCcG/4fKqcy4WB3kfDV11y/Io4opN
	qw9Dh/hGekmTDGAIaorVZ6aMPUU5kKA=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-471-A-nNEcAzNtqtCy_DDDUVAQ-1; Thu,
 19 Feb 2026 14:23:30 -0500
X-MC-Unique: A-nNEcAzNtqtCy_DDDUVAQ-1
X-Mimecast-MFC-AGG-ID: A-nNEcAzNtqtCy_DDDUVAQ_1771529009
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5560C180049D;
	Thu, 19 Feb 2026 19:23:29 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.82.39])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9C3751800668;
	Thu, 19 Feb 2026 19:23:28 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trond.myklebust@hammerspace.com,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] pnfs: improve "Server wrote zero bytes" error
Date: Thu, 19 Feb 2026 14:23:27 -0500
Message-ID: <20260219192327.34732-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

When a pnfs error occurs, the IO is retried against the MDS. However,
the initial IO leads to the kernel logging "Serer wrote zero bytes"
when in fact the MDS IO will not fail and thus the error misleads
administrators that the system is experiencing issues.

Instead, recognize that a re-try-against-MDS type of error has
occuried before printing the "Server wrote zero bytes" warning.

Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/nfs/filelayout/filelayout.c | 1 +
 fs/nfs/write.c                 | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 5c4551117c58..2cf405c370b4 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -323,6 +323,7 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 
 	switch (err) {
 	case -NFS4ERR_RESET_TO_MDS:
+		hdr->pnfs_error = task->tk_status;
 		filelayout_reset_write(hdr);
 		return task->tk_status;
 	case -EAGAIN:
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2d0e4a765aeb..8e8e3f8ef362 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1558,7 +1558,7 @@ static void nfs_writeback_result(struct rpc_task *task,
 		nfs_inc_stats(hdr->inode, NFSIOS_SHORTWRITE);
 
 		/* Has the server at least made some progress? */
-		if (resp->count == 0) {
+		if (resp->count == 0 && !hdr->pnfs_error) {
 			if (time_before(complain, jiffies)) {
 				printk(KERN_WARNING
 				       "NFS: Server wrote zero bytes, expected %u.\n",
-- 
2.52.0

