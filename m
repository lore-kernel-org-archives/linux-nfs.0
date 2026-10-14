Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 552F748662E;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791962999; cv=none; b=P+MKkyqP6SKz+8+FEmgtmCL1EMRt3BTZm7crIB6a67xxg0fCsSblS/L4Nuwcfa7UyCEyiBm9dSVRDg3CTm2QXImWMpSqQdl3Cy9Kcdd5IKyXkCVvXa19Q+7Q7hVSARS4bDyNJj1TS6jckAh8xfA0OvcIk6RexGXe0yE+TCRO5cE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791962999; c=relaxed/simple;
	bh=rwYDVjVLwW4O9dHo/Z1t0WhlZC+3gJknMz7cajis+18=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=AEjOaS0EH5B3q0JIJiqUVzE+Fb0pyXPehKDikzffAek0C++UkKGTLgHD+P/tr46AD6f5ebHqT3sQGGPlYTQ/Q5zP5Xc2BDJCWllnUWzLFCM36811zJ4mRnvwHerrj3vcfD2ucdoQU5QmNkuD8G3IRqqe2TWn2x18EMhx13NBMnU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NoUqzesM; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NoUqzesM"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 06E51C4AF0C;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791962999;
	bh=rwYDVjVLwW4O9dHo/Z1t0WhlZC+3gJknMz7cajis+18=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=NoUqzesMlhHF1XKSV4pPaOjxF76T37q+qaJ8iB6S5imvU0v5d1V/xPo2Eekjwc95c
	 jicsoyPUqaFP7LXJ/4f46F0837viuceCkVL+4IC6mGTgp6pv5uPKWhXLjc9R/0A3R2
	 ZWTtq7QJS+ZGQzxwHHbMYEJy8+9Vc4YmnKubIB/jOlAGpRFXWAQQs/oRiPs3ex/pmI
	 1DM8tp8Ewe7ybGTo+5PgFXdlNRNYV5sIZlXYvRvnY60BVgecT0UWQFH1mgGUADPdxi
	 E0JBSeTA90O3El4fqHqqg1+JZjqrI1Mtmna/FtMRqkE4UgUQdFDpPxFyTNBVHBSdZ4
	 /XESiCM8zw3SA==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDFB7CC6B29;
	Wed, 14 Oct 2026 07:29:58 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Wed, 14 Oct 2026 16:29:59 +0900
Subject: [PATCH v2 3/7] nfsd: make the time limit of a layout recall work
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261014-nfsd-layout-recall-v2-3-764462bddfd1@samsung.com>
References: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
In-Reply-To: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791962996; l=4428;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=XDHNIkZefhQS+7i2dgjXZ0NmiOI6Rgx6mkxQJuzvlOs=;
 b=jN19z9QDzl+cKn40yhwjlTorliGmyL3zi3JwPoYz5v9DKtdFqlfIg349Bpj5CYuyRBI09tt34
 uEzHcnO2B7/BllR/K18VbPqDLlDaLE+IrdwrvOYnTmvWwWgzgqPGQwY
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

Found by reading the code. The limit could only be tested together
with "nfsd: keep polling a layout recall answered with
NFS4ERR_OLD_STATEID", because a current Linux client does not keep
answering a recall with NFS4_OK or NFS4ERR_DELAY: a client writing
through a block layout whose path to the device is cut for 70 seconds
while it can still talk to the server, a lease time of 15 seconds, and
a write to the file on the server. The recall fails 30 seconds after
the first answer of the client and /sbin/nfsd-recall-failed is run.
With the default lease time the limit is 180 seconds; a recall that
comes from a lease break is not waited for that long: after
fs.lease-break-time the breaker has the client fenced.

Fixes: 6b9b21073d3b ("nfsd: give up on CB_LAYOUTRECALLs after two lease periods")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 15 +++++++++++----
 fs/nfsd/state.h       |  1 +
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 035ab79faa..f05e8f3c0f 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -313,6 +313,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 		return NULL;
 	}
 
+	ls->ls_recall_start = 0;
 	ls->ls_fenced = false;
 	ls->ls_fence_inflight = false;
 	ls->ls_fence_stopped = false;
@@ -808,12 +809,18 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
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
index 3df871d301..0920c83857 100644
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


