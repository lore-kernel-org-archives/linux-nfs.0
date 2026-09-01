Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 625324A2A62
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:20:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788294006; cv=none; b=YOu8G08BNs8piuconZR7pxgHEVNvF1Xg8XbAsuGEJZGZKqGXkg2pOSc1aF7fYJJPiIXI3TYIKI/O6RikaLaJ+4DTZuiq9kQpVu2zcb/HH+hnuCh7yXx4HPha0345BUGxUYgJU99kDsMKFVFRnAN3z8Z9rE/2cHK6jufnE90Qwv0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788294006; c=relaxed/simple;
	bh=oq91QIRq8xLGmBO7Oi3U6o+dWWsFLg8T9hmwRDjbrWw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=skWtw0fE+bmWLW7aTFLr2N7FCg3/3iFpKR0bpYEw/CBCzfynnto9Ltp4H6sgjz2WRJJbKiz7XJ5S6urxUC5518+mS5Er9nznny/mwUBYLkfih8mDJ33HnWlr9OxeBjkSKxdiIWQNQZ6lTZ6bqVnzudb6ZZthF7gp9Cd3FkTjss0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IbWNwy7j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IbWNwy7j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 85FA01F00A3F;
	Tue,  1 Sep 2026 20:20:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788294005;
	bh=Vr0bEJ5gcjKQy7h0kIKDRSBLpYq2dBY7r1PzbrOEDL4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IbWNwy7jTvCEuWmh7fuuIHxa5zSlxd72WSS7n6JMK63F8OHfbx9aGtz0zmvu46VoC
	 FEZvTd2w85qUFgXSylmf7DhQGRhb5zkUiUfL9q1oIKIhYTIHNX+3WeRtSatFMcO/eg
	 a+Y/2jiBXADBUJbpIOf4fMaygaqqVu7zG3X9f36Osehl4k+7d31woskhyZJReXiYdS
	 XAA5eDmnkLKPt2RPwkn7z/15bOj3+NI9pB0bIN3GezLCgXDIDaL+JmxbbHW9uotV1d
	 RSXauJal4jZjZxeW1FE1c8hH9D34fYk/qJBE6Qb30Ln3ZrExM/yy9u8RX2DlOix6zd
	 Uoti3iCHzhFYg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:48 -0400
Subject: [PATCH v2 8/8] pnfs/blocklayout: Complete a device upcall when the
 pipe is closed
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-8-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2280; i=cel@kernel.org;
 h=from:subject:message-id; bh=oq91QIRq8xLGmBO7Oi3U6o+dWWsFLg8T9hmwRDjbrWw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNslmy+XuhmY1v9uFtS6wtcgVKajuMpkMELp
 hmkvvTSTc+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczbAAKCRAzarMzb2Z/
 lyHED/0d/AMlqdvVEn+zG53QgStX934p7f7rtEZEyMRO/MQpoeUE4q9c8zznwPYrreMC9nF01bv
 gnFJeztd2JkUUdQmhQQilkdskl48fNkmFGdYBxQ32SQKdrk+gXAMGimQmhGcM6NxxB2rcEiLnSY
 sBCJl+tJAwr6ZaFWepoKhJWRoo3GdwmapCFcnaScVQd2ApAywKEm8I0aIq+iKG3gmJQqFx/hL6p
 oyosb0wTfezRb+CGVbEpjvOnHD5qNT7e6Jv738OmdNsDJN9jh3H9z0MWYqkq3z5yRc2AF1ZcusM
 aUozC6u9tNNzUoIlnNKPJoouoL+42MHuuiyufzJHcDg7lv/ab3CbbOOKYQAogjOyc101KZEF27J
 CofQ89vFoSWbMgHXBmGC+7QQji3Ekh+1wNUSvFKflGgxbwfyrMXBJDkwezsXeKmpPqAmDCWNoRn
 SlnRA9tvziuZbXBERloCDePqxddRZPJ2WTN8QSrIB0/2Th463HacSeT3o5Yi/E9WeB1loaXn/1d
 dTRPO3oyiNafhplR929d273K6DnhDPTWj7mCCudmsjkp9f00iniiZ/8DG0XgTft7wFdqiizlAC5
 5boUxUo98XWHkDLzgHuzkzHE5rFII8O+G9V08VFQcZIIgZWMa8d2zYu/BA/ApE0rXY+Nvii326p
 yPpoxF/kUL+1mxA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Once blkmapd has read a whole upcall, rpc_pipe_read() unlinks the
message from every pipe list, so the purges in rpc_pipe_release()
and rpc_close_pipes() no longer reach it. bl_upcall_ops supplies no
.release_pipe callback, and bl_pipe_destroy_msg() returns without
completing the upcall because a downcall is expected to follow. A
daemon that exits between the read and the write therefore strands
its waiter: bl_resolve_deviceid() sleeps in wait_for_completion()
and never returns, and it holds nn->bl_mutex across that wait, so
every later device resolution in the net namespace blocks behind
it.

Add a .release_pipe that completes an upcall blkmapd has consumed
and left unanswered. Completing an upcall retires it, so a message
the framework has already purged is no longer in flight and is not
completed a second time here.

Fixes: fe0a9b740881 ("pnfsblock: add device operations")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/blocklayout/rpc_pipefs.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index 50f276a90527..f0004a8249e7 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -151,10 +151,31 @@ static void bl_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	complete(&nn->bl_done);
 }
 
+/*
+ * An upcall blkmapd has consumed is off every pipe list, so the
+ * purges in rpc_pipe_release() and rpc_close_pipes() cannot reach it.
+ * No downcall can arrive once the pipe is closed; release its waiter
+ * here.
+ */
+static void bl_release_pipe(struct inode *inode)
+{
+	struct nfs_net *nn = net_generic(inode->i_sb->s_fs_info, nfs_net_id);
+	struct rpc_pipe *pipe = nn->bl_device_pipe;
+
+	spin_lock(&pipe->lock);
+	if (rpc_msg_is_inflight(&nn->bl_pipe_msg)) {
+		nn->bl_pipe_msg.copied = 0;
+		nn->bl_pipe_msg.errno = -EPIPE;
+		complete(&nn->bl_done);
+	}
+	spin_unlock(&pipe->lock);
+}
+
 static const struct rpc_pipe_ops bl_upcall_ops = {
 	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= bl_pipe_downcall,
 	.destroy_msg	= bl_pipe_destroy_msg,
+	.release_pipe	= bl_release_pipe,
 };
 
 static int nfs4blocklayout_register_sb(struct super_block *sb,

-- 
2.54.0

