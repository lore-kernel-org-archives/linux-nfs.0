Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651487;
	b=gX4GlW6YstFBoz9rSkCCxRN2SzpfUZf3J+GsOw8cLnth4+6gVdLCKvKmUCa3CUzPicsx
	 tJXjYq4gcLAucdTkfkQTHziR3XRCz66zsfpFoR0THzKh4+Eqk+hDl20NANpkodTRwn+gK
	 yFGi0kzV13L30RYPnFnKp/DQ9wxssQtyg0ykNcYFJr+wRlsfgz6tW+0Mrb/i812+GQ0+n
	 LopurZfZXXzHIuUteL/tYKvsftr0vOcC1qB9mcpafL80nEpHoX4rnKgvUuA2B8CdIgDJf
	 s88blb8xbW/sIWQIcF3krUBYo033ketZDFYwdLXW2ccoc4KPw0GXo0sZ9BX/0ir3ezQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651487;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=mkpddXyVgivzdc5zNoKicUfW92I/8cNkbw5ABdyZkeM=;
	b=i1GOoWmXgvDJxU3MVVjHweOMRqO3dh3d214u0JnV3GHFCDX5mxzrQKImjrQS/1WoPrpV
	 HoNIz3lEYYmKdleTbblXTyw93vr+IG7zEt6DmP/9SjdZr6sTpsgWJIL8wcJ4TF21lhWJq
	 y/gfGCjVXOuNKPb4fkcvs90DxM0BReS5XWRFcX9YlifBB85YckYu0PnAAF6OwVg6VnhOy
	 jOcTwnCEiMep3HFpDFRC4OHSclR6C48g5kBDTQQ9ZY23ei71XikXqaO1lwje1L5hqwKtI
	 A9y9E3tjueBve0BORakxNJNIHScLtEwnHzw0a8iBxVVKGmBsLB7cK8ICCUPoU38ebtA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mLgmOtqe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54E26606D802
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 20:31:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mLgmOtqe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C32211F00A1B;
	Mon,  2 Nov 2026 20:31:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651487;
	bh=mkpddXyVgivzdc5zNoKicUfW92I/8cNkbw5ABdyZkeM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mLgmOtqeBnCLypZdAlvub1PE3R0jj1T5f17bbIf9IPkQKseJxoDC5gKH6hw2apXke
	 CHiaVi8SlrjHvKpXW7cOmqbFbnniY3EAyc1YPEvtYYiurvGTORAjDeywIMkv6ewQhy
	 DOozc9VC246Z9UcUqbmw6Ru0e0e4jvgnHqhop0YMkRhWMOFF4Vf4vRNcjntt1ayJdE
	 ltAZ2o5aIEpcXre3Ckr5jqquuOAjJYTs2iNVPRWbKNVTIGnnWCF89C0kebNbtBUgn5
	 1AhYeurgeJUF4M7WsmuzIkOHxhTFX7Z0qWJqc1HPCCV3u1g3n/siWpW9KnZ5hcmpn+
	 ZmLI0IOXuG8bg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/4] NFS/localio: don't run the release of a failed COMMIT in the submitter
Date: Mon,  2 Nov 2026 15:31:20 -0500
Message-ID: <20261102203120.14600-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102203120.14600-1-snitzer@kernel.org>
References: <20261102203120.14600-1-snitzer@kernel.org>
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

nfs_local_commit() allocates its fsync context with GFP_NOIO.  If the
allocation fails, it runs rpc_call_done() and rpc_release() for the
COMMIT in the submitter.  The release of a COMMIT releases its write
requests and, with them, what may be the last reference to an open
context.  The submitter can be the flusher, through nfs_write_inode().
The flusher holds sb->s_umount and has set I_SYNC on the inode, so it
can release neither the superblock nor the inode.  This is the deadlock
of the previous patches, through LOCALIO.

Run the release on nfsiod instead, as the release of an RPC COMMIT
runs.  The failure path cannot allocate a work item.  The commit's task
is not an RPC task for LOCALIO, so its work item is free.  The nfsd_file
is still put in the submitter, because it holds no open context.

Fixes: 70ba381e1a43 ("nfs: add LOCALIO support")
Cc: stable@vger.kernel.org
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/localio.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index cdada6cbb13bf..a1482859eed34 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -1094,6 +1094,32 @@ nfs_local_release_commit_data(struct nfsd_file *localio,
 	call_ops->rpc_release(data);
 }
 
+static void nfs_local_commit_release_work(struct work_struct *work)
+{
+	struct nfs_commit_data *data =
+		container_of(work, struct nfs_commit_data, task.u.tk_work);
+
+	data->task.tk_ops->rpc_call_done(&data->task, data);
+	data->task.tk_ops->rpc_release(data);
+}
+
+/*
+ * The release of a COMMIT releases its write requests and, with them, what
+ * may be the last reference to an open context.  The caller may be
+ * writeback, which must not release the context itself, so release from
+ * nfsiod, as the release of an RPC COMMIT is.  The commit's task is not an
+ * RPC task here, so its work item is free.
+ */
+static void nfs_local_commit_release_async(struct nfsd_file *localio,
+					   struct nfs_commit_data *data,
+					   const struct rpc_call_ops *call_ops)
+{
+	nfs_local_file_put(localio);
+	data->task.tk_ops = call_ops;
+	INIT_WORK(&data->task.u.tk_work, nfs_local_commit_release_work);
+	queue_work(nfsiod_workqueue, &data->task.u.tk_work);
+}
+
 static void
 nfs_local_fsync_ctx_free(struct nfs_local_fsync_ctx *ctx)
 {
@@ -1144,7 +1170,7 @@ int nfs_local_commit(struct nfsd_file *localio,
 	ctx = nfs_local_fsync_ctx_alloc(data, localio, GFP_NOIO);
 	if (!ctx) {
 		nfs_local_commit_done(data, -ENOMEM);
-		nfs_local_release_commit_data(localio, data, call_ops);
+		nfs_local_commit_release_async(localio, data, call_ops);
 		return -ENOMEM;
 	}
 
-- 
2.52.0

