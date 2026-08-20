Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3235C37C925
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 15:08:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787238515; cv=none; b=MCl0ocAMdWxI1mY9TPcZiHCmF8H2WelB/snorg7dsEx4e/6tPtD1ZVoJw5uxxWFTL3iwrTTFwlD1TO0/rQb2QBpAduCW+WTSYkoQvui3RSlDxlcKBkT62f6l4YfkxsxJoz0P/AwoAj1ifjOYMDB3hkIJB26d/Evbx5eSwphK81o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787238515; c=relaxed/simple;
	bh=YzmCZpSJfpKYULuv3Q4jVcp0s3YsxqqPfoA62uZI+XA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fG+2v4V3OHsseruWRltD0Lvgw3J7loHjNb+EtpvZzLsqG55jSeQx2wENdyjuOnJlDSL6GVEwIg1OcToGYyqMzIOBXqMEj6qzmIioLLIV0JloyVg/iHXTOUv/6IbjtnIu1sSmnEvXOmBXWXYJ0bNSlWubhIsdVr3n6GF9XKi43S4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DCNP/N+0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DCNP/N+0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5724E1F00A3D;
	Thu, 20 Aug 2026 15:08:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787238514;
	bh=N7M0CpKOd7TmMu40f+vdzY09rDgEP25qZ9aHlE6cfbA=;
	h=From:To:Cc:Subject:Date;
	b=DCNP/N+0lVIWQoOgJOqqmzLADJGWmu5qAnz0bQO+yW5k5e1hSLPCOFo0fh4rFENj1
	 0JYcknWBrEybYk0c927pESJhFMHhojT8oWUp4wSe/tZJXSV09AR+66GLqiQEW7tBtV
	 nNtHMLHYyqG0fOkbV+rQgg6CxRMp6IqqtRcqeX5h/6csmGFa8MHAqqQsatL82g2MwG
	 fqQE17ydXmDH4Rk2zB80nURM6p71q4jie2TbKMQmGWcJcitbSuDfseru5aE/4oQ4K5
	 xnVbHL9gCzgkp0/wahCpzlwqX3fQv3v3Y/nLlVd5q8btTJqVBlJ+6NdbaI2Kwv2DwP
	 YdhCyAy0fIieQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Shuangpeng Bai <shuangpeng.kernel@gmail.com>,
	sashiko-bot <sashiko-bot@kernel.org>
Subject: [PATCH v2] lockd: fix use-after-free in nlmsvc_retry_blocked
Date: Thu, 20 Aug 2026 11:08:31 -0400
Message-ID: <20260820150831.3291262-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nlmsvc_retry_blocked() examines the block at the head of nlm_blocked
under nlm_blocked_lock, then releases the lock before calling
nlmsvc_grant_blocked() or retry_deferred_block(). The nlm_blocked list
reference is all that keeps the block alive across that window.
nlmsvc_grant_blocked() does take one of its own, but not until after
the lock has been dropped. Unmounting the nfsd filesystem while a lock
request is still blocked reaches nlmsvc_traverse_blocks(), which drops
the list reference and frees the block along with the nlm_rqst hanging
off it.

  BUG: KASAN: slab-use-after-free in nlm_async_call+0xd6/0x230
  Read of size 8 at addr ffff88811b04c808 by task lockd/8377
    nlm_async_call+0xd6/0x230
    nlmsvc_retry_blocked+0x61c/0x800
    lockd+0x144/0x1c0
  Freed by task 8392:
    nlmsvc_release_block+0x231/0x290
    nlmsvc_traverse_blocks+0x139/0x1b0
    nlm_traverse_files+0x1aa/0xa00
    nlmsvc_free_host_resources+0x12/0x60
    nlm_shutdown_hosts_net+0x127/0x280
    lockd_down+0xd5/0x1c0

Take a reference before releasing nlm_blocked_lock and drop it once
the retry has run.

Holding that reference exposes a second problem. Both arms of the
retry end in nlmsvc_insert_block(), which queues any block it finds
unlisted, while nlmsvc_traverse_blocks() skips blocks that are already
unlisted. A block unlinked during the window therefore returns to
nlm_blocked after the teardown scan has passed it by. The surviving
block pins its file and its host, so the host is never reaped. lockd
warns that it could not shut down the host module, and the host
outlives the network namespace that host->net points at.

Mark a block with B_DEAD before unlinking it wherever it is retired
for good, and have nlmsvc_insert_block_locked() ignore a block that
carries the flag. nlmsvc_grant_blocked() unlinks and requeues as a
normal part of a grant attempt, so it keeps calling
nlmsvc_unlink_block() directly.

Fixes: 0e4ac9d93515 ("lockd: handle fl_grant callbacks")
Reported-by: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
Closes: https://lore.kernel.org/linux-nfs/20260818235808.3458075-1-shuangpeng.kernel@gmail.com/
Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20260819162247.2970703-1-cel@kernel.org?part=1
Signed-off-by: Chuck Lever <cel@kernel.org>
---

Changes in v2:
- Add B_DEAD so a retry cannot requeue a retired block (sashiko-bot).
- Link to v1: https://lore.kernel.org/r/20260819162247.2970703-1-cel@kernel.org
---
 fs/lockd/lockd.h   |  1 +
 fs/lockd/svclock.c | 31 +++++++++++++++++++++++++------
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/lockd.h b/fs/lockd/lockd.h
index 14cc952fe81a..063947ac1543 100644
--- a/fs/lockd/lockd.h
+++ b/fs/lockd/lockd.h
@@ -230,6 +230,7 @@ struct nlm_block {
 #define B_QUEUED		1	/* lock queued */
 #define B_GOT_CALLBACK		2	/* got lock or conflicting lock */
 #define B_TIMED_OUT		4	/* filesystem too slow to respond */
+#define B_DEAD			8	/* block retired, must not be requeued */
 };
 
 /*
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e628b5d35507..674b20e3426d 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -57,6 +57,9 @@ nlmsvc_insert_block_locked(struct nlm_block *block, unsigned long when)
 	struct list_head *pos;
 
 	dprintk("lockd: nlmsvc_insert_block(%p, %ld)\n", block, when);
+	if (block->b_flags & B_DEAD)
+		return;
+
 	if (list_empty(&block->b_list)) {
 		kref_get(&block->b_count);
 	} else {
@@ -256,6 +259,20 @@ static int nlmsvc_unlink_block(struct nlm_block *block)
 	return status;
 }
 
+/*
+ * nlmsvc_retry_blocked() holds a reference to this block outside
+ * nlm_blocked_lock and re-inserts it once the retry has run. Set
+ * B_DEAD before the unlink, or the block reappears on nlm_blocked.
+ */
+static int nlmsvc_retire_block(struct nlm_block *block)
+{
+	spin_lock(&nlm_blocked_lock);
+	block->b_flags |= B_DEAD;
+	spin_unlock(&nlm_blocked_lock);
+
+	return nlmsvc_unlink_block(block);
+}
+
 static void nlmsvc_free_block(struct kref *kref)
 {
 	struct nlm_block *block = container_of(kref, struct nlm_block, b_count);
@@ -302,7 +319,7 @@ void nlmsvc_traverse_blocks(struct nlm_host *host,
 		kref_get(&block->b_count);
 		spin_unlock(&nlm_blocked_lock);
 		mutex_unlock(&file->f_mutex);
-		nlmsvc_unlink_block(block);
+		nlmsvc_retire_block(block);
 		nlmsvc_release_block(block);
 		goto restart;
 	}
@@ -489,12 +506,12 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 		dprintk("lockd: nlmsvc_lock deferred block %p flags %d\n",
 							block, block->b_flags);
 		if (block->b_granted) {
-			nlmsvc_unlink_block(block);
+			nlmsvc_retire_block(block);
 			ret = nlm_granted;
 			goto out;
 		}
 		if (block->b_flags & B_TIMED_OUT) {
-			nlmsvc_unlink_block(block);
+			nlmsvc_retire_block(block);
 			ret = nlm_lck_denied;
 			goto out;
 		}
@@ -702,7 +719,7 @@ nlmsvc_cancel_blocked(struct net *net, struct nlm_file *file, struct lockd_lock
 
 		mode = lock_to_openmode(fl);
 		vfs_cancel_lock(block->b_file->f_file[mode], fl);
-		status = nlmsvc_unlink_block(block);
+		status = nlmsvc_retire_block(block);
 		nlmsvc_release_block(block);
 	}
 	return status ? nlm_lck_denied : nlm_granted;
@@ -968,7 +985,7 @@ nlmsvc_grant_reply(struct lockd_cookie *cookie, __be32 status)
 		break;
 	case nlm_lck_denied:
 		/* Client doesn't want it, just unlock it */
-		nlmsvc_unlink_block(block);
+		nlmsvc_retire_block(block);
 		fl = &block->b_call->a_args.lock.fl;
 		fl->c.flc_type = F_UNLCK;
 		error = vfs_lock_file(fl->c.flc_file, F_SETLK, fl, NULL);
@@ -980,7 +997,7 @@ nlmsvc_grant_reply(struct lockd_cookie *cookie, __be32 status)
 		 * Either it was accepted or the status makes no sense
 		 * just unlink it either way.
 		 */
-		nlmsvc_unlink_block(block);
+		nlmsvc_retire_block(block);
 	}
 	nlmsvc_release_block(block);
 }
@@ -1023,6 +1040,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			timeout = block->b_when - jiffies;
 			break;
 		}
+		kref_get(&block->b_count);
 		spin_unlock(&nlm_blocked_lock);
 
 		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
@@ -1033,6 +1051,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			retry_deferred_block(block);
 		} else
 			nlmsvc_grant_blocked(block);
+		nlmsvc_release_block(block);
 		spin_lock(&nlm_blocked_lock);
 	}
 	spin_unlock(&nlm_blocked_lock);
-- 
2.54.0

