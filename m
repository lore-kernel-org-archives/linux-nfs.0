Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90F103BE642
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 18:57:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790621877; cv=none; b=r4pqP6BusPk+CBq0v9OXlQYH2Z067qst3qJFllpCQQwjbwLJeU/JV0wQ09jfjd0xckvM6j98ApaLvapFtWMSzWJkR7Id515THpwSFNY/L2zJazVr+aJwpYuW5hqlBa4fV8FF7odPvivnsoQCDG2mAIZj28J2g/i5K54z6KP0who=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790621877; c=relaxed/simple;
	bh=zMb1eO24H1bOW7jLh4VrrpsK/Za6DgDtnAeyx6XsbL0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tAUr592BpEI+9C/oBI+x4Okkiso+EwB6IyqabEuDDWQCT/5g2iPtAzwG2uLy6+ke2I4U6AaTt75biqXs8fYkvPIcaxn0sA5uBSut7aB589YMYD5yZEMS3h2ESSWeT1bOe9OUCjUeWqL7Jv2C5zXbUeyOVPNY+R9bcIxFFEYnR7k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l192Db52; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l192Db52"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D4921F000FF;
	Mon, 28 Sep 2026 18:57:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790621876;
	bh=OKpk9fQcqYpl1ydQa5H/0r89S697ec+CPjW1wcEcyCY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=l192Db52nE53RYznPbixYl/hfbEw4shNL2vAdRpC/CbZiaWqzEw83dbMHGQcVleVP
	 2vkZuuqcoO1/qliVgq0Kt5xz3W5qqBoCiMPAhgzOZK28VuuqFKoY+vEz2y28+N9GBo
	 oZ1fsrHyD8qkx6yA5CPys7nx2qwxDCnHCPgEVBWWrjXvtbTH1mgJxuJouGzgLPuBln
	 Pu/oRTk7QJiTFR5Wh5HOIbtgRArbGV2DjxPH/wepB3wgCKNSkPLedvo0Nk2l2mxq/u
	 5YJPoddMxMPddV4w8HqREGKL8K5EWTwnt/8CGPeMa1y1VJTBAvWzriwULTprbxr7nV
	 9IvCqzap9OFfA==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFS: don't run the release of a WRITE or COMMIT in the submitter
Date: Mon, 28 Sep 2026 14:57:50 -0400
Message-ID: <20260928185751.98682-3-snitzer@kernel.org>
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

nfs_initiate_pgio() and nfs_initiate_commit() start an asynchronous RPC
task and then drop their reference to it with rpc_put_task(). If the
task has already completed, that reference is the last one and
rpc_put_task() runs the rpc_release() callback in the submitter rather
than on nfsiod, where task_setup_data.workqueue asks for it to run.

The release of a WRITE or COMMIT releases write requests and, with
them, what may be the last reference to an open context. The submitter
is usually the flusher, which holds sb->s_umount and has set I_SYNC on
the inode, so it can release neither the superblock nor the inode:

  wb_workfn
    wb_writeback
      writeback_sb_inodes
        __writeback_single_inode
          nfs_write_inode
            __nfs_commit_inode
              nfs_generic_commit_list
                nfs_commit_list
                  nfs_initiate_commit
                    rpc_put_task
                      rpc_free_task
                        nfs_commit_release
                          nfs_commitdata_release
                            put_nfs_open_context
                              nfs_sb_deactive
                                deactivate_super   <- blocks on s_umount

This is the deadlock that was reported in 2014, see the link below.

Before commit bf294b41cefc ("SUNRPC: Close a race in
__rpc_wait_for_completion_task()") the final rpc_put_task() always
handed the release to the workqueue of the task. That commit made
rpc_put_task() run the release in the caller, and added
rpc_put_task_async() for callers that must not. Use it.

nfs_initiate_pgio() also starts READs, whose release now always runs
on nfsiod as well.

Nothing depends on the release of a COMMIT having run by the time
nfs_initiate_commit() returns: no caller has passed it FLUSH_SYNC since
commit 64a93dbf25d3 ("NFS: Fix deadlocks in nfs_scan_commit_list()").
Before that commit nfs_write_inode() did, from the flusher, and the
wait then made the reference of the submitter the last one every time.

Link: https://lore.kernel.org/linux-nfs/20140407135001.56ef9f36@notabene.brown/
Fixes: bf294b41cefc ("SUNRPC: Close a race in __rpc_wait_for_completion_task()")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/pagelist.c | 3 ++-
 fs/nfs/write.c    | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 71f0ce2bc4ea..e87ad5651f4d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -816,7 +816,8 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	rpc_put_task(task);
+	/* The caller may be writeback: don't run rpc_release() here */
+	rpc_put_task_async(task);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f38bbebffe4d..766481c5870e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1677,7 +1677,8 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		return PTR_ERR(task);
 	if (how & FLUSH_SYNC)
 		rpc_wait_for_completion_task(task);
-	rpc_put_task(task);
+	/* The caller may be writeback: don't run rpc_release() here */
+	rpc_put_task_async(task);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_commit);
-- 
2.52.0

