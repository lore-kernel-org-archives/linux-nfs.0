Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 713572DA768
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 00:38:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788136737; cv=none; b=TveaM+dzmfeoXJMX4FIX+dYWnfD5s4+V+MdexFItVUATdxATjQyF10SFstVAH2zyfAd1WNwY+k+ACwPZdKk10lI8vOesJsynqQQtAtCnWkcIta7G2BKYBYcfgqY63s9tBqQ8TArWl+SJczDnW9EQr1LrkTtfjAsqISZ5vAvVCPA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788136737; c=relaxed/simple;
	bh=MhAnLvX+3XTdFuy1LFG/erkHHBTr2pFLM/YyeuXdJFU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=VbChIySgvD8Erh/QSGYJZuwEo91S4MbWoSKGv12cs2bwlTIx/qgOvsj511XndK658bSjOdwXZ+jeqkAjFRiZxvnGo6NvfHFwBGAd6dGJGLJoPXUOJHcJBqW92JaQtQsVwBz1o5+x4sljGUx/drj2iPAbHAY8zkC412nhuDrPenQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Y36X8r4i; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Y36X8r4i"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 824CB1F00A3D;
	Mon, 31 Aug 2026 00:38:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788136736;
	bh=gekn1IZc+14vwYZJfIc5R53YTOVDyVJOxUd07TYHzBs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Y36X8r4irGrYlP62IpDQPaBzVMXZOXI0qcmIgaR9deAA/it5EXPWu8QJj3P6fQjeD
	 sLOYjn+cXgDpeL2bvFLr0Jy+VPSIBeNJp6v4h/gjuIJuun+fJ3+8IEOLjF4YyOknP9
	 143K5E6sT0EViuFFpUqH/J/AGWTNmLWXQDynSt8Rnpwa3gk/DU2maAwJg0qLFoSh00
	 N9XYPR2z7oBpzEUUn74QnadoVNTS9/B6B1rMtFhykhYjaG6g0mZqCdQqby9TJq030P
	 RneikJjwbnJho1wltgpa5iZN5uFKMZ5D2e5uR3AHTWOSF41HW9j8Hhl/uj1jPn2sjc
	 ZidpwDkzxuJUQ==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 30 Aug 2026 20:38:42 -0400
Subject: [PATCH 5/5] pnfs/blocklayout: Complete a device upcall only on its
 own reply
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260830-alemi-v1-5-463f80b9e9a8@kernel.org>
References: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
In-Reply-To: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>, 
 Scott Mayhew <smayhew@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=6323; i=cel@kernel.org;
 h=from:subject:message-id; bh=MhAnLvX+3XTdFuy1LFG/erkHHBTr2pFLM/YyeuXdJFU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlM0ZeT3A1LWpOk6aCJhbcCzVBiHeSDJA0Dxs0
 6WmSh/fIh2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapTNGQAKCRAzarMzb2Z/
 l9BKD/4lY3XG1vE/qsZl5lSQulFroCOuBZpkML1gD8mI6zxVAI8qVhVrUxf+GwPTGzOoQz+Ype+
 ppU/+pipAT0Ay+LW66ufrnJYfdbVuBx31dYHupzb+z5SgVidhTjH+Mx9OMBDTY6DMtjrpZM6AWQ
 QI4CZAJxkVTWESeOt+vfu8RBZrZDi7C2Ej+pigVFMdN9qQmO55R47VJJbhE9gu3Qr5B+wGRVisX
 tL5Nt4PHqYEYKn7e9Ov6xmq14zn7tVh73LdwEUf91Fa8lRRqGxGL0OSV9LDDfqVVJf4QOdew+/o
 4sEobvHShiOfMCtswBD6IOeXYwwNvrR0Z5595sCqxuAWL64O0Hjwy/Z1Vw51gpNqzqSp8SY9WMu
 tBPZ/KTf9Z4hQvYWbZpWh1KccOFj3okg3zioQpMGfjgmiG2GVXDCTuTfU5MSa1OYutq2Xmp2YLK
 7FSYhWBc/IKSg/xshxB1u0ekOAbY0P+r5zshuEucgfSRYGYP9EDH+i90F8og7wrD2CklZzdJvm7
 vCkVJwc87xRWrgB/0vf95+GV0hAqJ8p4dFuH22rhKnFEjzJ9WbjFib/FlnRmuj719G3iQysvI8q
 aCKbKtZPNYbc56YbkTQHhbt9oZJWs9sccyZrm1VcocAx3wGcA3GamU/6cgxRgCQt4YpksrogKTL
 dkcFpHRCCa/mHsg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

bl_pipe_downcall() wakes bl_resolve_deviceid() on any write of the
right size, without checking that blkmapd has read the upcall being
replied to. A write that arrives first returns the waiter while its
struct rpc_pipe_msg is still queued on the pipe, which then holds a
list_head into a dead stack frame. Reaching the pipe takes root, so
the trigger is a broken or hostile blkmapd.

The wait has two further defects. bl_resolve_deviceid() sets
TASK_UNINTERRUPTIBLE only after rpc_queue_upcall() has made the
message visible, so a reply that lands in between wakes a running
task and the schedule() that follows sleeps forever holding
bl_mutex. And nn->bl_mount_reply is never reset, so when the pipe
purges an unread upcall the waiter takes the previous reply as its
own.

Move the message into struct nfs_net, where bl_mutex already limits
the pipe to one upcall per net namespace. Accept a reply only while
blkmapd has read the whole message and no earlier reply has been
taken, and reject any other write with -EINVAL. Wait for that reply
on a completion so it cannot slip past the sleep, and check
msg->errno before trusting it.

Fixes: fe0a9b740881 ("pnfsblock: add device operations")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/blocklayout/blocklayout.h |  5 ----
 fs/nfs/blocklayout/rpc_pipefs.c  | 56 +++++++++++++++++++++++++---------------
 fs/nfs/netns.h                   |  5 +++-
 3 files changed, 39 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 6da40ca19570..e242b1d5b4bd 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -161,11 +161,6 @@ BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
 	return BLK_LO2EXT(lseg->pls_layout);
 }
 
-struct bl_pipe_msg {
-	struct rpc_pipe_msg msg;
-	wait_queue_head_t *bl_wq;
-};
-
 struct bl_msg_hdr {
 	u8  type;
 	u16 totallen; /* length of entire message, including hdr itself */
diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index d526f5ba7887..63db51759658 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -55,17 +55,15 @@ bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
 	struct net *net = server->nfs_client->cl_net;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct bl_dev_msg *reply = &nn->bl_mount_reply;
-	struct bl_pipe_msg bl_pipe_msg;
-	struct rpc_pipe_msg *msg = &bl_pipe_msg.msg;
+	struct rpc_pipe_msg *msg = &nn->bl_pipe_msg;
+	struct rpc_pipe *pipe = nn->bl_device_pipe;
 	struct bl_msg_hdr *bl_msg;
-	DECLARE_WAITQUEUE(wq, current);
 	dev_t dev = 0;
 	int rc;
 
 	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
 
 	mutex_lock(&nn->bl_mutex);
-	bl_pipe_msg.bl_wq = &nn->bl_wq;
 
 	b->simple.len += 4;	/* single volume */
 	if (b->simple.len > PAGE_SIZE)
@@ -83,17 +81,20 @@ bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
 	nfs4_encode_simple(msg->data + sizeof(*bl_msg), b);
 
 	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
-	add_wait_queue(&nn->bl_wq, &wq);
-	rc = rpc_queue_upcall(nn->bl_device_pipe, msg);
-	if (rc < 0) {
-		remove_wait_queue(&nn->bl_wq, &wq);
+	reinit_completion(&nn->bl_done);
+	rc = rpc_queue_upcall(pipe, msg);
+	if (rc < 0)
 		goto out_free_data;
-	}
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule();
-	remove_wait_queue(&nn->bl_wq, &wq);
+	wait_for_completion(&nn->bl_done);
 
+	/* Retire the upcall so bl_pipe_downcall() rejects a later write. */
+	spin_lock(&pipe->lock);
+	msg->copied = 0;
+	spin_unlock(&pipe->lock);
+
+	if (msg->errno < 0)
+		goto out_free_data;
 	if (reply->status != BL_DEVICE_REQUEST_PROC) {
 		printk(KERN_WARNING "%s failed to decode device: %d\n",
 			__func__, reply->status);
@@ -113,26 +114,39 @@ static ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,
 {
 	struct nfs_net *nn = net_generic(file_inode(filp)->i_sb->s_fs_info,
 					 nfs_net_id);
+	struct rpc_pipe *pipe = nn->bl_device_pipe;
+	struct bl_dev_msg reply;
+	bool accepted;
 
-	if (mlen != sizeof (struct bl_dev_msg))
+	if (mlen != sizeof(reply))
 		return -EINVAL;
-
-	if (copy_from_user(&nn->bl_mount_reply, src, mlen) != 0)
+	if (copy_from_user(&reply, src, mlen) != 0)
 		return -EFAULT;
 
-	wake_up(&nn->bl_wq);
-
+	/*
+	 * Only the first reply counts, and only after blkmapd has read
+	 * the whole upcall and before bl_resolve_deviceid() retires it.
+	 */
+	spin_lock(&pipe->lock);
+	accepted = rpc_msg_is_inflight(&nn->bl_pipe_msg) &&
+		   !completion_done(&nn->bl_done);
+	if (accepted) {
+		nn->bl_mount_reply = reply;
+		complete(&nn->bl_done);
+	}
+	spin_unlock(&pipe->lock);
+	if (!accepted)
+		return -EINVAL;
 	return mlen;
 }
 
 static void bl_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
-	struct bl_pipe_msg *bl_pipe_msg =
-		container_of(msg, struct bl_pipe_msg, msg);
+	struct nfs_net *nn = container_of(msg, struct nfs_net, bl_pipe_msg);
 
 	if (msg->errno >= 0)
 		return;
-	wake_up(bl_pipe_msg->bl_wq);
+	complete(&nn->bl_done);
 }
 
 static const struct rpc_pipe_ops bl_upcall_ops = {
@@ -221,7 +235,7 @@ static int nfs4blocklayout_net_init(struct net *net)
 	int err;
 
 	mutex_init(&nn->bl_mutex);
-	init_waitqueue_head(&nn->bl_wq);
+	init_completion(&nn->bl_done);
 	nn->bl_device_pipe = rpc_mkpipe_data(&bl_upcall_ops, 0);
 	if (IS_ERR(nn->bl_device_pipe))
 		return PTR_ERR(nn->bl_device_pipe);
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index 36658579100d..e1decff366d4 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -10,6 +10,8 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
+#include <linux/completion.h>
 
 struct bl_dev_msg {
 	int32_t status;
@@ -21,8 +23,9 @@ struct nfs_netns_client;
 struct nfs_net {
 	struct cache_detail *nfs_dns_resolve;
 	struct rpc_pipe *bl_device_pipe;
+	struct rpc_pipe_msg bl_pipe_msg;
 	struct bl_dev_msg bl_mount_reply;
-	wait_queue_head_t bl_wq;
+	struct completion bl_done;
 	struct mutex bl_mutex;
 	struct list_head nfs_client_list;
 	struct list_head nfs_volume_list;

-- 
2.54.0

