Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651486;
	b=2bkImtL8TpKP2G8hjmlOmlgo96NmE9AdDSSGFeZcCigaJj25arMCRs1VELeuRnWIZcAU
	 94g+PBWBsM+GGky+OdlnHU2pLOhbBnMBuIdBdjVRzuA+I6T5jEbMfdD5hGMNC0XMKApL8
	 +KsaHnzzVzkBw9uBajRkILnvBilO3zp4rFSXq+U6bCaW+sV9FigERWo+SJw7xWnyp33f7
	 ocPlel9aHh10C7qyxNGUs2ZiQbSU+R0u+MzPEEtEg2qgyvxaiOPAUbdMyKBQ1Y2z5yvdU
	 SawkPo3aXygjihxJ0aRD2fPyWp2KAnhdi2bDlnbdresLBdKMAcANKsnuG1xUZsXw+Xw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651486;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=eYkhgtT4CvsCJbzRVXneWueZyGa0/5bz9gPe31oNPdw=;
	b=ZIohB/SSTmStyTjOVcUHDU08g+eEEaYHU5UqIKL7BWzpOhyujcJ42wqLE2BcisXeHsNq
	 AKhunSIlp2DnCVsMBv10Evo+iB14PoMUETtIVnb2llSt8kLQGpqlLmJ4bOWAF7SVAO8aI
	 XoL/HAzBaLhJjwPIgfgTAuoQsxHKwu3e8KYHIOOOSNFG36miaDkA+PurdfyuAtJ/Cy6l0
	 z0tkRwCb2uITZ6cpWIqd49L2iqyzaOgnfY7gAL5jDEL1NY/I1d7n5XaXRkhvwIDRqSo80
	 1NWRkggomNqwopZ22BaYV7qM6xWzcRY//QX+fUL2paF3AibMJj3w2m9VU6KevDNaYmA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="MG/j8laY";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CBE3606D802
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 20:31:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MG/j8laY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 83EF51F00A2E;
	Mon,  2 Nov 2026 20:31:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651485;
	bh=eYkhgtT4CvsCJbzRVXneWueZyGa0/5bz9gPe31oNPdw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MG/j8laYj14eLBk+S8x5CX4dKuhFC6SnShITUywYaGbitbffK3o2BkkRt9U0Sy3iZ
	 aMwI/XiOJ1P+9TlDlFJgGkbsGWU9H7jp1/WeQvx9GSpVxaBaagPKR087WA0LwY0us4
	 RnrvLwLtZk/mK6TmbifXzK6qLTWQI+Z0X/9rSz3fpeEl7BinvlSCh8xRQMoU447r7A
	 lpKnxFzqt61hgeMSgDAABTPX//joUw7Vw5z9MUxBFIgYq/CvBxAPvKP3ihlcsvBLcW
	 fxIocV921FOQj4d+TMObue6w5RKISVAEk7fdhlPrTrmScMzR2nhLG9EgvPGaQ6I9fx
	 8uNhiSLi+jGxg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/4] NFSv4/pnfs: don't run the release of a LAYOUTCOMMIT in the submitter
Date: Mon,  2 Nov 2026 15:31:19 -0500
Message-ID: <20261102203120.14600-4-snitzer@kernel.org>
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
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/nfs4proc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0adc209dc5df1..47cc70ef30802 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10152,6 +10152,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 			return -EAGAIN;
 		}
 		task_setup_data.flags = RPC_TASK_ASYNC;
+		task_setup_data.workqueue = nfsiod_workqueue;
 	}
 	nfs4_init_sequence(NFS_SERVER(data->args.inode)->nfs_client,
 			   &data->args.seq_args, &data->res.seq_res, 1, 0);
@@ -10162,7 +10163,11 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
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

