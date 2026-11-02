Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651485;
	b=gZZg7xnNEHbRydDX/XUT033O72QwidjYKe6Xse5Ah58+HuVxpSiolzrW0GS3JPYeanlA
	 Q60O/cKnUtppg3D8DUrk+8VrGwOvDivG/fzbO8c3vQKO66AxDU5BEhQqqoPA4qe9Oiqm/
	 FPuOIOR53uieqUqTA3wvsMMEz9wjsZYEyPXM1EQKE20IDl2Nj5RuojGAq75ECtfJWtQMs
	 0uABnBKtF5yyZvKCmKxvU1K90LM84BspPrqk3oTR+ghQGQI97tiJC9H1S1TsM+p08LaTU
	 YTquWpknNFNukZBqNpT5WSu5ovZ80qxyXLX4ghAyJpnYq+9qRcjWRGBdkpDsHyK9fIQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651485;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=AeAdQzSxxNekj5lo3PLPbqB21IFCQTUgkMuCTY+l6ZU=;
	b=qom3RCBYuLW1vBaFY6fuKTkMmalsZxC1ix2acurwUYtUrnm7Nxzk9cQEmfvi/jKtIjcl
	 1d5Ac9GOloKl0Ft/OSOjkgym+HtNNsQt2BQE8sbCasn1KhRoxZcVAPlQqDP0K7yO9ZfK6
	 niaNxJJ+NGgfJ5A6i14cHTx+ruy6R7R4cRSMeXAjNR8jM+popCAgjQi37sRY/Z2R+K3iF
	 1swhOrAH9UdgGOSI6Dw/RPayhLoa96UUenGDhTthIl7DIaxgBeKj9By0ArrHMt8yahS+0
	 Rr8vB3h8UOPd70qwYGrEKQIOPq9SkcY5ZfNvalcPLmxEvr71hA2rSr9jYs3dzKiAG7A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lFGE21pN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8054606D82B
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 20:31:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lFGE21pN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 488BC1F00A1E;
	Mon,  2 Nov 2026 20:31:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651484;
	bh=AeAdQzSxxNekj5lo3PLPbqB21IFCQTUgkMuCTY+l6ZU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lFGE21pNdyPgHlQ87eP07e08bqpNVk105cM4r3HlAUs1QASsYc0uRkixq458lfUss
	 /Ao69ANiLULBWQU5KHvwUzCwvj5zSa03stphOaeAfcHbXRmvNfdis6AqYkI1FQFDJT
	 o6uH53UM/ZeRaX/+iwXFKB2NFfi6bnTNJ4NcCSUOhCun9skRWoSLHuTY3QN3/j5egC
	 q/BPxRNMO81bMtv3FJCnaRcU+QxcCB5RfNHiQ2PvcX90xXiiT7FGMoYoP5pqrW96JA
	 BpAnoGOJ8E5GRwPHrFO+VRhxZ6Q/od/zi4wxP41LX31RP3THC8zZRDZzmzcnzMMglU
	 TUyi77gHmzoZg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/4] NFS: don't run the release of a WRITE or COMMIT in the submitter
Date: Mon,  2 Nov 2026 15:31:18 -0500
Message-ID: <20261102203120.14600-3-snitzer@kernel.org>
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
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/pagelist.c | 3 ++-
 fs/nfs/write.c    | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 71f0ce2bc4eab..e87ad5651f4df 100644
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
index f38bbebffe4d7..766481c5870e6 100644
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

