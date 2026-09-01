Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 582D84A2A53
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:20:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788294003; cv=none; b=obzIkaAW9oM6tWfQ38T0fPf0lZYDyL+2mLu7JjAQh+ZO7IwcwdErSZkHFdxDRwLe144AaZ9zzU2o0O5J4P6lCBNvCbQMWwTwP5BlTOkEK1IeDp5zFbb6wtXpANpGdzSUnGLDYARC3yEQ6Kakq0xxiem6KAGof4XG45hDIcD6ir0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788294003; c=relaxed/simple;
	bh=KfPCQ7SbXG3HuPdDLEh5W6blYBJ/8LBBB59mhE8sKdA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=l6IPalq5AySIZ6qwnYc4DknkqE7+kkLtXBoVncBbYUWvf/kEOGU+7cl64oytZsU7ZM+5HOF/QGj4Puv+imQOJLWoaMWX0AAc7QT6A5Ab/TSAWwk6tmLMK9bVdVw4AfzTjj5mS8ukkLWNckeCMCtOjS8kCySkZeii4t0S/b7RldA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LEPKD7du; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LEPKD7du"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 748191F00ACF;
	Tue,  1 Sep 2026 20:20:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788294002;
	bh=8DMMKzP6xk6ILEFBLi3qEaXPqVfBAPiNnA9LDCLbMiE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LEPKD7duDlSFwrhk1T26W9EX0nucF0xy2tajSFQ1sMen/RJzlLWIN3vrEAqqqgh9Y
	 mpJRE4LcD3UpiaM0JU2eKP+RAhaGhGwR2BmkC+UBFRfT9b/Xttw2RRHlcay3bDmq3L
	 tOpQju+lrYf3Kj/BlFSjFdSNs8XrrBWQ9b066425Xjssrwk9HeYyhJp4bQDm6qe3F4
	 2OyBNNcXGLj6c1Sio8q34QObJMxNRctR/a/6o5/mg/Sn8RINxGLLsdBMjcjY4NMrGG
	 5ZkMTankaMNWWdYIxSB4FovwRjnPi4CD7hd4Krz5RN5WgybzhjDCvKPSBAQudJNe3X
	 Il0Ea+CLTdLHA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:45 -0400
Subject: [PATCH v2 5/8] pnfs/blocklayout: Complete a device upcall only on
 its own reply
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-5-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=6348; i=cel@kernel.org;
 h=from:subject:message-id; bh=KfPCQ7SbXG3HuPdDLEh5W6blYBJ/8LBBB59mhE8sKdA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNrglfaCpcW6eYeRG+w1Jpf8noM2BzFDexsf
 BvOSTufn/yJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczawAKCRAzarMzb2Z/
 lwDKD/wNBrOni4aXJW6yX2absl3q0eDVvWb1/tEQz0C5yv1Lycobk5oiEEzg2KMpCwfCafHPjSQ
 vAHSZbEJN9ep7P4H38StK1SlRIOL+hh1kinBV5uiSQHeddgmerVU4MG5O/uJTF7KUu7a+waJCvR
 GTmvmJ6rjUAz9sV6Awlc/pLXq2eWxeJZVjGcvdR96x4elhXJld5VkDtzFN59Y5yZP3tlhagzyED
 9GAVZqiVG8NtOk5vd9nbRWQwTLTsy8+ATppW9yP0zh7JA2CYphbYtTDuLJEMr3pkqMmrYPccwen
 ualNf0LtX66BkeYm9uCoZ6r3VH7cvdhGW4gAgxzMZ/m2w8qN3epPbyaALEKCvVnurxreGxfXi9w
 6FGdkC469gHSgHtf3wkwmIyGok/7y3lGTcRkO0CDwB/1DPk1SyInaAyHMqX8Hy3CUvU+cCLO3Jd
 wn+05oiNF5FBwVQOdMv8FR0yXoATMtdl/YezmfnyDtxFHsxlnfBPJWOn3AUw3T17Bxud6uO/Jh1
 rMS5pGdGbkICW7pN0zqKq/aYC1I5djTnh9cSdv7yLlxkM4pe7xUsfG/N3czRNSoYMy6dvmx/o5p
 uePI1I0KaBLWIfPS9ZWYpLKjW4WpW2FLpWSsWwWTYU99J+YK6v29Y/jUxeHUs7mBFEJb+SW3KpH
 2nzs5/hNAv1vhVg==
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
 fs/nfs/blocklayout/rpc_pipefs.c  | 58 +++++++++++++++++++++++++---------------
 fs/nfs/netns.h                   |  5 +++-
 3 files changed, 41 insertions(+), 27 deletions(-)

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
index d526f5ba7887..50f276a90527 100644
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
@@ -83,17 +81,15 @@ bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
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
 
+	if (msg->errno < 0)
+		goto out_free_data;
 	if (reply->status != BL_DEVICE_REQUEST_PROC) {
 		printk(KERN_WARNING "%s failed to decode device: %d\n",
 			__func__, reply->status);
@@ -113,26 +109,46 @@ static ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,
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
+	 * Accept a reply only after blkmapd has read the whole upcall.
+	 * Completion retires the message, here and in
+	 * bl_pipe_destroy_msg(), so a later reply finds nothing in
+	 * flight.
+	 */
+	spin_lock(&pipe->lock);
+	accepted = rpc_msg_is_inflight(&nn->bl_pipe_msg);
+	if (accepted) {
+		nn->bl_pipe_msg.copied = 0;
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
+	struct rpc_pipe *pipe = nn->bl_device_pipe;
 
 	if (msg->errno >= 0)
 		return;
-	wake_up(bl_pipe_msg->bl_wq);
+
+	spin_lock(&pipe->lock);
+	msg->copied = 0;
+	spin_unlock(&pipe->lock);
+	complete(&nn->bl_done);
 }
 
 static const struct rpc_pipe_ops bl_upcall_ops = {
@@ -221,7 +237,7 @@ static int nfs4blocklayout_net_init(struct net *net)
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

