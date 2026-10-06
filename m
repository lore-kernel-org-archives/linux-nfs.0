Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1154A372686;
	Tue,  6 Oct 2026 04:29:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791260984; cv=none; b=TiQBCNLevEyXIT+WUP3xAhgP7Sn8PgAV/s6ntT2R1z0T1jRS2sNkd/X3RZk5Dj6+jgGh8DvtJ0uwkhymY2l56wSf2xPFn5TGHQnBth9pZVRAusXAR6YlzxmgKtWLHzxc/OnRxw/RGj0iiAWM1d+i8hbP9ryjPCaTa54js++5SGQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791260984; c=relaxed/simple;
	bh=SkyBU2/qXy0y0lIrGat2BUf3ObGnfmio+41Y8eP9tWo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iLj248k2ohnxzIfFsMEX+wXMEeMF+3uyBnESbS0SB+MhcfP2rauXOU7jxOqy5W0/OGdGROO5mRJ5eQS3NwyiWiJThUSG6NAf1yA2FyrzdVgyuCmliDEbxL9rD5CFGSXltqM2n9JF7Xr75MasF2YzxPu01x/ZZnzdJVpKdN2pM/Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RWMf0zRz; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RWMf0zRz"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 85074C4AF60;
	Tue,  6 Oct 2026 04:29:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791260983;
	bh=SkyBU2/qXy0y0lIrGat2BUf3ObGnfmio+41Y8eP9tWo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=RWMf0zRzflfWAuI/El53yGwHufu4DF54w1r5kLQVb1gOnF9MvprNISGHJyFeu+4w2
	 NvJhmUigmxSScC+9RYjrMz4vLsb9LyKHEEYQ+H/SCBTT8yyK8W1qqnbpTLkG4Ync90
	 XCgJCVcEBbhxLuQTKFKLfM8Egzc4dq0lIBn/kkNeYQlq5R2kd2J5imd/UXNpGh9d3p
	 0sda/3LRIeB2lx9WRSF/YMs2GcePf2RUcC+ZnB2vyHELx3asgO+k2dcLQDIfGAnQ+m
	 TnPxAcmT7CCgr/WsC64SJPCZdHCMLRk2EjNBwCLcoQNsP/nDDAdwYCMD0NJe+sW932
	 WCzx2m2dHCP0g==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65F53CA5FED;
	Tue,  6 Oct 2026 04:29:43 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Tue, 06 Oct 2026 13:29:44 +0900
Subject: [PATCH 2/6] nfsd: run the fence script when a block layout lease
 break times out
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfsd-layout-recall-v1-2-b59b31caf342@samsung.com>
References: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
In-Reply-To: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791260982; l=5470;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=bJF/VT1E2WcPMBC2ufO+OAtip9pwsN49gNVrOpeNbVA=;
 b=T96wV+VuDgWGM5CvzMhFBiaoS3wgY//tniueF5+KLnXARLok09sZkdGaAFIT9g7vE0hqMM5Ci
 8mUd7U9uC4lCAYeE5fx+E8m4xHG9IIUnlLds/zj+vj4fDu/cku8/ERF
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

When a lease break has waited for fs.lease-break-time,
nfsd4_layout_lm_breaker_timedout() has the client that holds the layout
fenced before the breaker goes on.  For a layout type without
->fence_client, which is the block layout, it returns true at once: the
lease is removed and the operation on the server goes on while the
client still holds the layout.  /sbin/nfsd-recall-failed, which
Documentation/admin-guide/nfs/pnfs-block-server.rst names as the way to
fence such a client, is only run when the CB_LAYOUTRECALL fails.

This hits a client that keeps answering the recall with NFS4_OK or
NFS4ERR_DELAY for longer than fs.lease-break-time, 45 seconds by
default, for example because its path to the device is cut.  With the
previous patch the recall is polled for two lease periods, 180 seconds
by default, so the lease break times out first.  A Linux client before
v6.8 answers that way (read from the code, not run), and with the next
patch every Linux client is polled that way; until now a client from
v6.8 on has the recall fail after 10 ms.

Let the fence worker run the script for a layout type without
->fence_client, and give up the lease after that.  As on the recall
failure path, the exit status of the script is not looked at.  The
same document says that the server retries a failed fence and keeps
the file from other clients meanwhile; that is what the fence worker
does with ->fence_client().  Doing it for the script would block the
file for good on a server that has no /sbin/nfsd-recall-failed, so
this patch leaves it as the recall failure path has it.

As for the SCSI layout since the commit this fixes, the client is then
fenced after fs.lease-break-time.  That is shorter than one lease
period by default, while RFC 8881 section 12.5.5 has the server wait
one lease period after a recall before it takes further action.
Setting fs.lease-break-time to at least the lease time gives that wait
for both layout types.

The fence worker now runs the script with UMH_WAIT_PROC, and since
"nfsd: drain pNFS fence work during state teardown" tearing down the
client waits for the fence worker.  A script that expires the client it
fences, through /proc/fs/nfsd/clients/*/ctl, would therefore wait for
itself.  That is already so on the recall failure path, where the script
runs while the callback is in flight and the teardown waits for the
callbacks (read from the code, not run).

Tested together with the next patch: a client writing through a block
layout whose path to the device is cut for 70 seconds while it can
still talk to the server, default lease and lease break times, and a
4 KiB write to the file on the server.  Without this patch the write
on the server goes on after 47 seconds and /sbin/nfsd-recall-failed is
not run.  With it the script is run after 47 seconds and the write goes
on then.  In both runs the client returns the layout when its path is
back, and the recall completes.

Fixes: f52792f484ba ("NFSD: Enforce timeout on layout recall and integrate lease manager fencing")

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 3731b4db7..088e26e8e 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -861,6 +861,7 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct nfs4_layout_stateid *ls = container_of(dwork,
 			struct nfs4_layout_stateid, ls_fence_work);
+	const struct nfsd4_layout_ops *ops;
 	struct nfsd_file *nf;
 	struct block_device *bdev;
 	struct nfs4_client *clp;
@@ -884,7 +885,17 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
 	clp = ls->ls_stid.sc_client;
 	nn = net_generic(clp->net, nfsd_net_id);
 	bdev = nf->nf_file->f_path.mnt->mnt_sb->s_bdev;
-	if (nfsd4_layout_ops[ls->ls_layout_type]->fence_client(ls, nf)) {
+	ops = nfsd4_layout_ops[ls->ls_layout_type];
+	if (!ops->fence_client) {
+		/*
+		 * The layout type cannot fence.  Run the fence script, as a
+		 * failed recall does, before the lease is given up.
+		 */
+		nfsd4_cb_layout_fail(ls, nf);
+		nfsd_file_put(nf);
+		goto dispose;
+	}
+	if (ops->fence_client(ls, nf)) {
 		/* fenced ok */
 		nfsd_file_put(nf);
 		pr_warn("%s: FENCED client[%pISpc] clid[%d] to device[%s]\n",
@@ -936,8 +947,9 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
  * nfsd4_layout_lm_breaker_timedout - The layout recall has timed out.
  * @fl: file to check
  *
- * If the layout type supports a fence operation, schedule a worker to
- * fence the client from accessing the block device.
+ * Schedule a worker to fence the client from accessing the block device.
+ * If the layout type has no fence operation, the worker runs the fence
+ * script instead.
  *
  * This function runs under the protection of the spin_lock flc_lock.
  * At this time, the file_lease associated with the layout stateid is
@@ -959,8 +971,6 @@ nfsd4_layout_lm_breaker_timedout(struct file_lease *fl)
 {
 	struct nfs4_layout_stateid *ls = fl->c.flc_owner;
 
-	if (!nfsd4_layout_ops[ls->ls_layout_type]->fence_client)
-		return true;
 	/*
 	 * Make sure layout has not been returned yet before
 	 * taking a reference count on the layout stateid. The

-- 
2.43.0


