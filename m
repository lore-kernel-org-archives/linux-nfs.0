Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4496B1BC08F;
	Thu, 15 Oct 2026 04:15:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792037744; cv=none; b=ifkV6Uu/6tssGDi8oTYi2zNxMJIvGSJoGD3nequnodVvlFkPAWFpvmr0qx59wsmiNCvovf1DtYGdYqPpxpdHGmook9fJm8m45OG5um+Auzg7m7XyVG/+tpmuQ9lglC9+++PTvy+04mGdWUm4AWl0AaZ41q+RgiAAjgE2BYNlP2Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792037744; c=relaxed/simple;
	bh=hA01muG7iEcYzmpLrFnBB3b1bbamy/50nDdn74BMhW0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=cb7dh5kL3xKO4Wtnx5EMe5dWMWODzyDGfXB8pVAT9CPGLdFq5P2cGQgNnM0yGcvhVo7MWuJ/eQ0t+Lpn47mfRKMWnZOYNACfN7NvUxED1Pn+ZVOeXosI2iDsQUZrOUMStHtHEvwmqyRi+sv41zCRphf7oLgLfuKjJ4QFbjwrnY0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=qo4mdSM5; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="qo4mdSM5"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 0A515C2BCFD;
	Thu, 15 Oct 2026 04:15:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1792037744;
	bh=hA01muG7iEcYzmpLrFnBB3b1bbamy/50nDdn74BMhW0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=qo4mdSM51Gzx2qipMjFExUpec/rEQas9cNmc7tIn/DgKuuuoN4ff0kluFJxzrQLuV
	 YXpasZ99e1VaVHNsolJPc8svGEnTPfLzauyTX53cObZK09ZDRCRBGkALQLDG9c0IXx
	 hmJ760XpmsBrAC9TK+NGKtCjuKtsoYSLIFsjkEfl9ziceRjFleiTS3UC9Un6J9VRKh
	 BzRC+9GgreX9IzuKKSMX1FQ062OTIdoE3Q0vT3b05WQZzUQfJx4thWYbH0b/PCf1sg
	 Fb6I/DhQIWnewmbHlLKvwCCAP89jr5mTS1ERKVgfzzHGhIOlhYwOvFDCGKBOrh5GC0
	 kGWSfJ4LBUNAQ==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6D23CC6B1C;
	Thu, 15 Oct 2026 04:15:43 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Thu, 15 Oct 2026 13:15:44 +0900
Subject: [PATCH v3 3/7] nfsd: make the time limit of a layout recall work
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261015-nfsd-layout-recall-v3-3-ba3269f8ca22@samsung.com>
References: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
In-Reply-To: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792037741; l=4558;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=/GH0fdVr7CZZnz9hVRT0dwIdG3M4bfncvOpuTl/S4Jg=;
 b=hQiAnkTWfIMeZ7L1xCBOpbiFLrPKVS6I8INDDmbscKeLIrPg1yBy/JfGBXzlt5R5ULDr+f0eM
 v9aWF0bsaMcD5XfYL/kqgIx+h41veEYDqXAs7/+DB26uwpvqj2At1Ts
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

nfsd4_cb_layout_done() polls a client that has answered CB_LAYOUTRECALL
and still holds layouts, and is meant to give up after two lease
periods: the recall then fails and the client is fenced. The limit is
computed from task->tk_start. The poll restarts the RPC task from
->rpc_call_done(), and rpc_exit_task() resets the statistics of a task
that was restarted there, tk_start included. So tk_start is the time
of the last poll, and the limit is never reached: a client that keeps
answering is polled every 10 ms for as long as it holds the layout.

Count the two lease periods from the first answer of the client, so that
the time in which a callback could not be delivered is not taken from
it, and take the time with ktime_get_boottime(), which goes on while the
server is suspended, as the lease times of nfsd do. A layout stateid is
recalled once in its life (ls_recalled is not cleared), so the time
needs no reset.

When the limit is reached, the existing failure path is taken. It does
not look at the result of ->fence_client(), so a SCSI layout client
whose fencing fails is treated as fenced there, and the layouts it drops
also end the retries of a fence worker that a lease break has started.
Before this patch a client from v6.8 on reached that path 10 ms after
the recall.

A Linux client before v6.8 answers every poll with NFS4_OK until its
LAYOUTRETURN is prepared (read from the code, not run). If such a
client does not return the layout, it was polled without end and is now
fenced after two lease periods, which is what commit 6b9b21073d3b
("nfsd: give up on CB_LAYOUTRECALLs after two lease periods") and
commit 851238a22f3b ("nfsd: fix error handling for clients that fail to
return the layout") set out to do.

Found by reading the code. The limit could only be tested together with
"nfsd: keep polling a layout recall answered with NFS4ERR_OLD_STATEID",
because a current Linux client does not keep answering a recall with
NFS4_OK or NFS4ERR_DELAY: a client writing through a block layout whose
path to the device is cut for 70 seconds while it can still talk to the
server, a lease time of 15 seconds, and a write to the file on the
server. The recall fails 30 seconds after the first answer of the client
and /sbin/nfsd-recall-failed is run. With the default lease time the
limit is 180 seconds; a recall that comes from a lease break is not
waited for that long: after fs.lease-break-time the breaker goes on,
with the SCSI layout once the client is fenced (and, with a later patch,
the block layout too).

Fixes: 6b9b21073d3b ("nfsd: give up on CB_LAYOUTRECALLs after two lease periods")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4layouts.c | 15 +++++++++++----
 fs/nfsd/state.h       |  1 +
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 1f06478056..ab7340343a 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -312,6 +312,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 		return NULL;
 	}
 
+	ls->ls_recall_start = 0;
 	ls->ls_fenced = false;
 	ls->ls_fence_inflight = false;
 	ls->ls_fence_stopped = false;
@@ -834,12 +835,18 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 			return 1;
 
 		/* Poll the client until it's done with the layout */
-		now = ktime_get();
+		now = ktime_get_boottime();
 		nn = net_generic(ls->ls_stid.sc_client->net, nfsd_net_id);
 
-		/* Client gets 2 lease periods to return it */
-		cutoff = ktime_add_ns(task->tk_start,
-					 (u64)nn->nfsd4_lease * NSEC_PER_SEC * 2);
+		/*
+		 * Client gets 2 lease periods to return it, counted from its
+		 * first answer. task->tk_start cannot be used for this, it
+		 * is set anew each time the callback is restarted.
+		 */
+		if (!ls->ls_recall_start)
+			ls->ls_recall_start = now;
+		cutoff = ktime_add_ns(ls->ls_recall_start,
+				      (u64)nn->nfsd4_lease * NSEC_PER_SEC * 2);
 
 		if (ktime_before(now, cutoff)) {
 			rpc_delay(task, HZ/100); /* 10 mili-seconds */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b1f4c167ea..f05e256421 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -853,6 +853,7 @@ struct nfs4_layout_stateid {
 	struct nfsd_file		*ls_file;
 	struct nfsd4_callback		ls_recall;
 	stateid_t			ls_recall_sid;
+	ktime_t				ls_recall_start;
 	bool				ls_recalled;
 	struct mutex			ls_mutex;
 

-- 
2.43.0


