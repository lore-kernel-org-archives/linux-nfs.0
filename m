Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E44D3F1ABF
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 16:05:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783353955; cv=none; b=GoyrIvIWWYuTXSc0Wxuv+YEg1/MCM3Lm5OjXaBLOJ6Gs68qm5ZnD+GOFxOan7cjTX9XWR6z5OeVNue3c7H+syd4FEgEYmB4cS8+WtyoBSrNBctngtxi1Z3CiUF9FbhwWpJDsemVm5QGvzkNF1Pu6i4JLOMLtTFgNeTJh5y427v4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783353955; c=relaxed/simple;
	bh=XPdmJdluNL8xm9ELWi8Md4kauHaGYg6f9QOXAWYJaR4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Jtq8onlOsOs3NcUAcXQ9aF18cqV/JLMFkq+D9X0eZbpnnHcdrm1mRictkRj5/JtW4pEoljvVbhtMAUNuv8SlB2U9GuNtU3bH44xMIA5LjzDtQnNnrmwCjxgk9JONtyejaR9QHDXyCXJkpdSV9oPMjAuFfAF7bm28AfRco50f2l4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=pAvcQymJ; arc=none smtp.client-ip=209.85.161.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="pAvcQymJ"
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-6a19a5691bbso2256272eaf.3
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jul 2026 09:05:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1783353953; x=1783958753; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uEL0aHDi47AllM85UC2VoFZUZtA7pPsLGPoBdPm2mEM=;
        b=pAvcQymJXntCvxKMWgbBrhyk4RSqTM7ZXjrslcJUDnMiJGp059DisQW/ypzF88EXmq
         j4dLO7O/YY4jfKxYdvGjawh5F1rm2LWaLzqvfjMXb3eyz9TMHBr0dkH+H8bj9Eu76t/k
         7mzebewG4jz5mqMOGDVi2FUIUfSUkZzSdX6m1Vqqt5v9uY9Ux5I9TZLwy9JyIb00du/1
         JYUTTh0tCxM8FMC5tRTtNCIaW8BRCxq21yEDIdmpPk6O7SkDb9a4goTIGSdmobnQ9nJY
         suwR+ZOr+BgeAsC7U851ux/D+1s1Uc5VoqzXHGOKosHeOqsvZ4esqjFOs97wgun6BwzQ
         Odnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1783353953; x=1783958753;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=uEL0aHDi47AllM85UC2VoFZUZtA7pPsLGPoBdPm2mEM=;
        b=PrO6JExSLmAHWZGlffhjeafTB5bNsxH9DdYPonKbLPtVlFFViU4/cV+SnENKo5xH7N
         9n7AL6/AC7s6WqOMTg5hL3NgiBxdbl+z/Vdh1h8QtzCWQbH17W2kfIBN5Z9Ewb0Ec9FE
         VloGgJ7HMJPCGtTvw4qq/AenkwLiBc+zbiZ44FumZa5yNs4RyDMeU7EDPtUO9YIJjtAr
         BAXGObI8FFLVgj/71zXgzn4nulKXlQ4W1cVRtbdYwg314BURVZna38jhml3cfRn2Cdsg
         HaoTcPeBBw3wA8C35hfEPZ/8pXvlgyPxuAhNFTvYd5Ss0GCW4H5elMmcCWcTusyETgLS
         s/zQ==
X-Forwarded-Encrypted: i=1; AFNElJ+Bz5Enaz0KkmK4m+PaoUoaKG4ujRzD74YGvglPxnDYmMVwyiF83ICjhReAvmVHsj7JGTZ3avOwA10=@vger.kernel.org
X-Gm-Message-State: AOJu0YyDuaJRunpWJXpds6zG7kW3Twfx4iR+XyyYMLKH2+J7/Ztut0ur
	4fPYBnHQ8YUzgizss5teZfuo1/4fpQ5XK8S3czOw2NgJV/LTTD+y8qI/Js7t6xyp7OOn3N1tt9A
	/aCH4
X-Gm-Gg: AfdE7cnuRcHGODEe6rc3ZMHIvf77AMLMdEMeT8W5L9krIsPRHaxXE8ngiJYqdmPuclj
	tZ5DDu3k2qxqbnsWczrnnUiqzC+PbowNp8cabGuPi/JfCWqg0hYf0Z/0JpMDFqy78OGPDZWI4Lt
	UGRpwLO9N8LX4xs8zM/j8r1KEtS+2ccHuVrjxdpJ0wXb6AXcl1YL3dDNZULZ6u8gfpTiCjNMORv
	1zIqnD7fkmx45YK5xSzl6WZVr4iYgoXajkWKskRORDTDnW7med/aPfYJ8MHF5p8woKV8Ht6B4S2
	y+zrOhKpC/tL4cY6u3VCRG2DCxbhky3542frJYDUgbn6mRRZLSK6CamYlbz3IcZREvjuB4HbuuN
	cK+JEvU8g7uTEG2yHFsX4rHO2Y4fJivIjLw/uSGslzAc+fqQ2MDmej252OCfQYECfWOShU6XK1O
	8Oxkc5qclSm3kF7LC0CTtUgDk2EwIAFjnayTZ47gyMhC8Y0rZn+UI7W+KKSveHnxAX4Tiw8qbt/
	SJwLgItD3mKmoOf
X-Received: by 2002:a05:6820:4cc5:b0:6a1:11a5:32df with SMTP id 006d021491bc7-6a3555af3f4mr709954eaf.50.1783353953294;
        Mon, 06 Jul 2026 09:05:53 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-92e90bb91adsm963038785a.20.2026.07.06.09.05.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 06 Jul 2026 09:05:52 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Tejun Heo <tj@kernel.org>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] NFS/localio: remove dead FLUSH_SYNC handling from nfs_local_commit
Date: Mon,  6 Jul 2026 12:05:48 -0400
Message-ID: <20260706160549.97580-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260706160549.97580-1-snitzer@kernel.org>
References: <20260706160549.97580-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs_local_commit() is reached only through nfs_initiate_commit(), and every
path that supplies its "how" argument has already cleared FLUSH_SYNC:
__nfs_commit_inode() strips it (how &= ~FLUSH_SYNC) before dispatch and does
its own waiting via wait_on_commit(), while the O_DIRECT path passes how=0.
filelayout issues its DS commit with a NULL localio, so it never enters
nfs_local_commit() at all.  The FLUSH_SYNC branch has therefore been dead
since it was introduced with commit 70ba381e1a43 ("nfs: add LOCALIO
support").

Remove the never-taken FLUSH_SYNC branch along with the completion plumbing
it was the sole user of: the struct nfs_local_fsync_ctx::done member, its
initialization, and the complete() call in nfs_local_fsync_work().  With the
branch gone the "how" parameter is unused, so drop it from nfs_local_commit()
and its callers.  No functional change.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/internal.h |  4 ++--
 fs/nfs/localio.c  | 15 ++-------------
 fs/nfs/write.c    |  2 +-
 3 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0338603e9674..66dbc9befdbb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -476,7 +476,7 @@ extern int nfs_local_doio(struct nfs_client *,
 			  const struct rpc_call_ops *);
 extern int nfs_local_commit(struct nfsd_file *,
 			    struct nfs_commit_data *,
-			    const struct rpc_call_ops *, int);
+			    const struct rpc_call_ops *);
 extern bool nfs_server_is_local(const struct nfs_client *clp);
 
 #else /* CONFIG_NFS_LOCALIO */
@@ -498,7 +498,7 @@ static inline int nfs_local_doio(struct nfs_client *clp,
 }
 static inline int nfs_local_commit(struct nfsd_file *localio,
 				struct nfs_commit_data *data,
-				const struct rpc_call_ops *call_ops, int how)
+				const struct rpc_call_ops *call_ops)
 {
 	return -EINVAL;
 }
diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index d3e480888eb1..acbc2bddcf81 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -52,7 +52,6 @@ struct nfs_local_fsync_ctx {
 	struct nfsd_file	*localio;
 	struct nfs_commit_data	*data;
 	struct work_struct	work;
-	struct completion	*done;
 };
 
 static bool localio_enabled __read_mostly = true;
@@ -1100,8 +1099,6 @@ nfs_local_fsync_work(struct work_struct *work)
 	status = nfs_local_run_commit(nfs_to->nfsd_file_file(ctx->localio),
 				      ctx->data);
 	nfs_local_commit_done(ctx->data, status);
-	if (ctx->done != NULL)
-		complete(ctx->done);
 	nfs_local_fsync_ctx_free(ctx);
 
 	current->flags = old_flags;
@@ -1117,14 +1114,13 @@ nfs_local_fsync_ctx_alloc(struct nfs_commit_data *data,
 		ctx->localio = localio;
 		ctx->data = data;
 		INIT_WORK(&ctx->work, nfs_local_fsync_work);
-		ctx->done = NULL;
 	}
 	return ctx;
 }
 
 int nfs_local_commit(struct nfsd_file *localio,
 		     struct nfs_commit_data *data,
-		     const struct rpc_call_ops *call_ops, int how)
+		     const struct rpc_call_ops *call_ops)
 {
 	struct nfs_local_fsync_ctx *ctx;
 
@@ -1136,14 +1132,7 @@ int nfs_local_commit(struct nfsd_file *localio,
 	}
 
 	nfs_local_init_commit(data, call_ops);
-
-	if (how & FLUSH_SYNC) {
-		DECLARE_COMPLETION_ONSTACK(done);
-		ctx->done = &done;
-		queue_work(nfslocaliod_workqueue, &ctx->work);
-		wait_for_completion(&done);
-	} else
-		queue_work(nfslocaliod_workqueue, &ctx->work);
+	queue_work(nfslocaliod_workqueue, &ctx->work);
 
 	return 0;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0d7f2c2e599c..3afe243597fb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1663,7 +1663,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 	dprintk("NFS: initiated commit call\n");
 
 	if (localio)
-		return nfs_local_commit(localio, data, call_ops, how);
+		return nfs_local_commit(localio, data, call_ops);
 
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
-- 
2.44.0

