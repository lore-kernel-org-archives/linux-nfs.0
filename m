Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD2D930EF9A;
	Fri, 21 Aug 2026 16:36:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787330209; cv=none; b=Q2LDzpYml1rm+yaA6MGqZqq3OXV3Gr6zXjt51HREJFEywcpFCJs2pSilp8ZTGL7dLEWqUqec90KLl/i54MbT6nmq4LFnOo2jja+l8b50yh3XRUHEDn7FX3xaYld0A/dc8rP2ZiiLQzMnwPblDnXx8nw70v13n+g3QVgI+dxTbfA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787330209; c=relaxed/simple;
	bh=ME+efIPKzEwPgTYlOLL6Tbzt7rIdyV14zjhwbjSsY4c=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=GJunpTwGH2kUIvIgL+VkpEQTdENvZ/3iXEl3O08XYu7hL9gZhA+EZejeWgGO+8ysH2FYk1V9bd+6OTfWvwjnO0BiqP4Foou1B9ZznPppL+0ZCAElws+L5m5CyOesAeOlCBf5GKUL7BSbggmGBuQqChNjCzltAAXRD/EUJVAvcls=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F3rJIftX; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F3rJIftX"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 3E47AC19425;
	Fri, 21 Aug 2026 16:36:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1787330209;
	bh=ME+efIPKzEwPgTYlOLL6Tbzt7rIdyV14zjhwbjSsY4c=;
	h=From:Date:Subject:To:Cc:Reply-To:From;
	b=F3rJIftXux7eUD0tVPFfKK04iNQpw65fIQ6pow2Y7KeJiBkWMnWl13jxU9teR+TIN
	 cGmnRPG8TnSk97RBhEl/ZU31rxtRcSO5zjOmTAIH+U5ywpTtjrBOY/0gn9Hjz3zdoE
	 4cXfgS2weasdKxeuxLcfvTcIEYoSaDkJWf72uLh7pQhj0l+UMaH4t1ltCcTYxFFYaJ
	 ofN1WBDLvnOu6HviTEgYyRkNxKJm+lnCDffaIM4iLIEQC1CgBleZSgx7d1FlmpdsMb
	 7WIz1h51TGcey9PXeJM/mX/cHkp0sLIiT5D2mkha5w19ZylP15Ae+znfU0B7nZv7Tw
	 BiuW8TPs6f7aQ==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 128F8C5DF94;
	Fri, 21 Aug 2026 16:36:49 +0000 (UTC)
From: FAN YE via B4 Relay <devnull+fy15309206903.gmail.com@kernel.org>
Date: Fri, 21 Aug 2026 16:36:49 +0000
Subject: [PATCH RFC] pnfs/blocklayout: fix lost wakeup in
 bl_resolve_deviceid()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260821-rpc-pipefs-blwake-v1-1-3e70ec9b0537@gmail.com>
X-B4-Tracking: v=1; b=H4sIAKB+iGoC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDCyND3aKCZN2CzILUtGLdpJzyxOxU3SRTczMzy6S0FCOzZCWgvoKi1LT
 MCrCZ0UpBbs5KsRDB4tKkrNTkEpBpSrW1ACUp1mF6AAAA
X-Change-ID: 20260821-rpc-pipefs-blwake-b57669bfd26c
To: Anna Schumaker <anna@kernel.org>, Trond Myklebust <trondmy@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1787330208; l=2479;
 i=fy15309206903@gmail.com; s=tbnet3; h=from:subject:message-id;
 bh=c+z4jifpi2nDQnBqxSM28wkVpN1tmwF5BQ5Cy9b5Al8=;
 b=Lnpzauy2mhybRxGXcwUrYR2F3F+2zhlFwLPs56EQ8jQ/SN42YJaiFZ/pUBnl+ePmuPgN4a1aR
 yMzDp46Vbc8Bi5gGNIKjcu7BDeXusiaqH73MefiU22XNzhxFbNSyj8k
X-Developer-Key: i=fy15309206903@gmail.com; a=ed25519;
 pk=6QsQIrI/kruYWIJyCH9ntPMXsHCqF5JtK/DCMtOCzdc=
X-Endpoint-Received: by B4 Relay for fy15309206903@gmail.com/tbnet3 with
 auth_id=929
X-Original-From: FAN YE <fy15309206903@gmail.com>
Reply-To: fy15309206903@gmail.com

From: FAN YE <fy15309206903@gmail.com>

bl_resolve_deviceid() queues itself on nn->bl_wq and calls
rpc_queue_upcall(), but sets TASK_UNINTERRUPTIBLE only after that call
returns.  If blkmapd answers on another CPU in between, the wake_up()
from bl_pipe_downcall() finds the task runnable and the assignment that
follows overwrites it, so schedule() never returns.  The caller holds
nn->bl_mutex, so every later blocklayout device resolution blocks behind
it.

Set the state before queueing the upcall and restore TASK_RUNNING on the
error path.  Of the four rpc_queue_upcall() callers this is the only
open-coded waiter; __cld_pipe_upcall() uses wait_for_completion(), which
cannot lose a wakeup this way.

Fixes: fe0a9b740881 ("pnfsblock: add device operations")
Assisted-by: Claude:claude-opus-5
Signed-off-by: FAN YE <fy15309206903@gmail.com>
---
Not seen on a real pNFS mount.  In a VM I reached bl_resolve_deviceid()
through a debugfs hook with a fake blkmapd and an mdelay() widening the
window: the caller sticks in D state at schedule(), and the next caller
then blocks on nn->bl_mutex.  Both go away with this patch.

Two questions:
- Would you rather have bl_wq converted to a completion, like
  __cld_pipe_upcall() in fs/nfsd/nfs4recover.c?
- rpc_queue_upcall() calls dput().  If the pipe were unlinked meanwhile,
  that could sleep with the task already in TASK_UNINTERRUPTIBLE.  Is that
  acceptable here?
---
 fs/nfs/blocklayout/rpc_pipefs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index d526f5ba7887..15972ca0daf1 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -84,14 +84,16 @@ bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
 
 	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
 	add_wait_queue(&nn->bl_wq, &wq);
+	set_current_state(TASK_UNINTERRUPTIBLE);
 	rc = rpc_queue_upcall(nn->bl_device_pipe, msg);
 	if (rc < 0) {
+		__set_current_state(TASK_RUNNING);
 		remove_wait_queue(&nn->bl_wq, &wq);
 		goto out_free_data;
 	}
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
 	schedule();
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(&nn->bl_wq, &wq);
 
 	if (reply->status != BL_DEVICE_REQUEST_PROC) {

---
base-commit: 818bebeb63dd6bf5f4e07e145f6cdbace520a34c
change-id: 20260821-rpc-pipefs-blwake-b57669bfd26c

Best regards,
--  
FAN YE <fy15309206903@gmail.com>


