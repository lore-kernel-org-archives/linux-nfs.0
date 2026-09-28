Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A4893B0ACC
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 18:57:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790621879; cv=none; b=c4Yq+PqakwMjljyOpkXqli1u327f2CoXVfazC7dUDRjmOamR6Xzr8JEX/rkyn6lBgjVTTzJGEp9RB27GAmplg7JzD73x7jSLk91ZL67EdguyCRNoIOGX8E8uMLufbycQBBm26N+6WbuYNkHdKO1MWMqyx3wcEo68B1a4rgUkVkQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790621879; c=relaxed/simple;
	bh=W084MpmOjHfTdaVJI3LE0zRcz5l+rgrgUkUq9dYgQZw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VwDyW1y17HVewM5sxDji2G0JslgWKOwAqO+LoaHOzjDoXREAb/zJWIg1jGOme8FxDbdNEMQToMCpFVSYBA7VKzb64CfjRCKiWZ2wJcbA4eqMgJyoNT+hygz8WSnYySe9GAwJpX0gY9q8pOgwsdlgQpewUx78yzF1ivQuXB+qM2g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hNIO08P3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hNIO08P3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 63D7D1F00893;
	Mon, 28 Sep 2026 18:57:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790621877;
	bh=LXLFwpEMJf+tAdxcFpoyqP/hn1uPckzAldvTHlbq3IU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hNIO08P3JFtPrRjQayEqn01xbvdvW4kpgQXTPx2hPvag95XnM4CdYMcUBO3VR3ncv
	 VIK9WBOKH6Q5zH4I+thJqkdhNVGMbmqflCdDlZ0BjJ0OdFbTbl7uw/otWA2DrRbCno
	 pmPqgyuqyMML4Huhs4bP25TOkbYFjvZaYEV8AAMwaPzUQjxujJ7Vj9ryIeI3EPpxGg
	 3a5ldhOeJ3QupP/6wWlHDSfXeBQACmJgdzkaehjsChUN2JInmmclBwiHtHe9jQGWBw
	 HakdCvnIzpQIWAxCpTQUiq6x9vdEqZFBhpr9y3OqxMD1hFVAdEFB75QMcBkW7blUdA
	 GL+hdlT6Yjtzw==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFSv4/pnfs: don't run the release of a LAYOUTCOMMIT in the submitter
Date: Mon, 28 Sep 2026 14:57:51 -0400
Message-ID: <20260928185751.98682-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260928185751.98682-1-snitzer@kernel.org>
References: <20260928185751.98682-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Since commit 472e25944981 ("NFSv4.1: Pin the inode and super block in
asynchronous layoutcommit") nfs4_proc_layoutcommit() pins the inode and
the superblock for an asynchronous LAYOUTCOMMIT with
nfs_igrab_and_active(), and nfs4_layoutcommit_release() drops both with
nfs_iput_and_deactive().

The task is put with rpc_put_task(), so if it has already completed,
the release runs in the submitter. nfs4_write_inode() sends an
asynchronous LAYOUTCOMMIT from writeback, where the submitter is the
flusher. It holds sb->s_umount and has set I_SYNC on the inode, so it
can do neither the final iput() nor the final deactivate_super(). If
the task has not completed, the release runs on rpciod, because the
task has no workqueue.

Give the asynchronous task nfsiod as its workqueue and put it with
rpc_put_task_async(), as is done for WRITE and COMMIT. None of the
callers that send an asynchronous LAYOUTCOMMIT waits for its release.

A synchronous LAYOUTCOMMIT is left as it is: it pins nothing, so its
release has nothing of the kind to drop.

Fixes: 472e25944981 ("NFSv4.1: Pin the inode and super block in asynchronous layoutcommit")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/nfs4proc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 518348e87dd8..133d01ce9f08 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10147,6 +10147,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 			return -EAGAIN;
 		}
 		task_setup_data.flags = RPC_TASK_ASYNC;
+		task_setup_data.workqueue = nfsiod_workqueue;
 	}
 	nfs4_init_sequence(NFS_SERVER(data->args.inode)->nfs_client,
 			   &data->args.seq_args, &data->res.seq_res, 1, 0);
@@ -10157,7 +10158,11 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 		status = task->tk_status;
 	trace_nfs4_layoutcommit(data->args.inode, &data->args.stateid, status);
 	dprintk("%s: status %d\n", __func__, status);
-	rpc_put_task(task);
+	/* An asynchronous caller may be writeback: don't run rpc_release() here */
+	if (sync)
+		rpc_put_task(task);
+	else
+		rpc_put_task_async(task);
 	return status;
 }
 
-- 
2.52.0

