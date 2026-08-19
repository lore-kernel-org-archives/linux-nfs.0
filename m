Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FEF83AEF55
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 16:22:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787156571; cv=none; b=tBN8Fwlu7Ms1LGiXDaGyj8Quis23I3MwenqCXEs+Su2UNvuLCjWMC8eVlegWAnDftseN18XbI/JqU6tub9Xq9haHL2a8gwYIbxuIOsIl77Qfwn07X7j2TOIx1Zq0Xd65hZEkVxNnuv1Sg7Zi1so8hPN/YedancGCHnPMWPUkN5c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787156571; c=relaxed/simple;
	bh=CujLUEFMtewyH3JU6aIAjTy1BHfPfV1ngYQmo3ayzqI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Js2AIa439qj5HcZRg7HMard4YroJeUXHRgDq0Inxx/nOQuTCHmYkYxmluDZsag1Wl35n5tMhGmbo+SzkYHeHjJUHSJyW75+dtChxUW9zDjWwWp/UH/DE4cKgw5rArheP81/ryDBkpwxgmp9JvV4pf7IoUGxbpCsnQoFxtta5nvw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W6uKO7RD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W6uKO7RD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9CFB21F000E9;
	Wed, 19 Aug 2026 16:22:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787156570;
	bh=4UmROjqQkD3ajmNfgyvEPQnF/WlVVe4GImycsDJtip8=;
	h=From:To:Cc:Subject:Date;
	b=W6uKO7RDhOwC983YwvgPGvDsSPvFKMb+EjGiKJNdUDMCRamF6+ksvQnsKYx90zFaf
	 b0CqR7ZN1/qyp4CulBrPpqYbrAsF2w/b0jyJXtU9OrcP2bMa87YfcNDOgitCuax8U5
	 vKABs6wOonGzB2sycIixIFcoyVN51KbLDr0zqsGupfvPJ+PywxDjIsmzCwroJBNFNL
	 zoXIHNS/qPFSzx+RXex45VhTRcDgF/k6KnMrx0/TL8c6hwqoU1GVcRw3pRJd1V6MUU
	 VvtKfN7lEcdEZWBAmBZzHamJrHoHX1fUbXbTNim0R9otI20aYo6Bu0s/tkTTWVZsrl
	 I7J9NvWh1rkTA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Shuangpeng Bai <shuangpeng.kernel@gmail.com>
Subject: [PATCH] lockd: fix use-after-free in nlmsvc_retry_blocked
Date: Wed, 19 Aug 2026 12:22:47 -0400
Message-ID: <20260819162247.2970703-1-cel@kernel.org>
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
nlmsvc_grant_blocked() or retry_deferred_block(). It holds no
reference of its own across that window, so the nlm_blocked list
reference is all that keeps the block alive. Unmounting the nfsd
filesystem while a lock request is still blocked reaches
nlmsvc_traverse_blocks(), which drops that reference.
nlmsvc_grant_blocked() does take a reference, but only after
nlm_blocked_lock has been dropped, so the block and the nlm_rqst
hanging off it can be freed before it runs.

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

Take a reference before releasing nlm_blocked_lock and drop it
once the retry has run. retry_deferred_block() borrows its
caller's reference as well, so this covers both arms of the loop.

Fixes: 0e4ac9d93515 ("lockd: handle fl_grant callbacks")
Reported-by: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
Closes: https://lore.kernel.org/linux-nfs/20260818235808.3458075-1-shuangpeng.kernel@gmail.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/lockd/svclock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e628b5d35507..8d83283d3e21 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -1023,6 +1023,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			timeout = block->b_when - jiffies;
 			break;
 		}
+		kref_get(&block->b_count);
 		spin_unlock(&nlm_blocked_lock);
 
 		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
@@ -1033,6 +1034,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			retry_deferred_block(block);
 		} else
 			nlmsvc_grant_blocked(block);
+		nlmsvc_release_block(block);
 		spin_lock(&nlm_blocked_lock);
 	}
 	spin_unlock(&nlm_blocked_lock);
-- 
2.54.0

