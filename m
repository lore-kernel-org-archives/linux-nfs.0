Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58D9F410D3C;
	Thu,  4 Jun 2026 13:57:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780581480; cv=none; b=CQsXhuYXcEkxWRWCcw3GWGBw5L8RnK6zY0g8t7zrRVP1fLgpaPTGfgr+fuwKb4K8k5KbyL0TxMkw0XE3Doq6dapmtEAkVyPdqUT5iudRbzXJQPnynicqwneOkhaPSS/n9dmuQt88qf0A6ZtSjSwQkS8w3Rpsb9W0T/8Mo0UQhig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780581480; c=relaxed/simple;
	bh=7ZVpp48F0B2xB8Sg0Ry28tt/II4SvovHy6T6EAS/W1o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=d0FNmbnR3hWao6LgXENB2qXGsw3wsgYJzrQBg2I6M7EWW1b/T+j7FuKSnqPykd/jeDHSQJjXNGDjkP2DLAT93IpBuj+B3XIDZr1FHbUR//UL104xQR6SD64j2jv7uFH0WMjFxI9Bn0c7ap1oU5f0mPbm3gBeTnGrUMk66iUg5oU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FJnY+eSr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FJnY+eSr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE2A91F00893;
	Thu,  4 Jun 2026 13:57:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780581479;
	bh=9oPjHRDiW5hMqrs2PW6G7UEg3sGOhIbde0O2vBhEv0I=;
	h=From:Date:Subject:To:Cc;
	b=FJnY+eSrja/zziAu03mb/FFNpPFKmh74D/1NnCDqdZ3L5VwNJksigs9yAIuCznmrF
	 qYbPSs7mliqCfP0tv6QggKIVhyA08e9adIjZqqoE2E+k/sY81nRxeeRC1ps9DmrKmZ
	 8lDyFfzIwc1ZAfZTuKKT8LZSpzHrVlvWkErY3KxilQ5UW5SkjhRRRLN5wbR8VLs2AN
	 6Dh16mpDjTuVGBMra/N891zBEpeGLiI2FYwtHryki09vBx4dKBd4SUr4TpNqXmMeJo
	 d2yry+YBgAg4Wd86oE9QWPNw5jRH2qPSOuOCzjBvvtYS9JHUASeCV9yeSVP+Jq2N3j
	 vDiWd94HZhlrw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 04 Jun 2026 09:57:43 -0400
Subject: [PATCH v3] nfsd: close shrinker/GC/fsnotify vs per-net shutdown
 race in filecache
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260604-nfsd-testing-v3-1-c9c58cc45c71@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XMQQrCMBSE4atI1kZeEhPUlfcQF6WZtA8llaQEp
 fTupl2p4HIGvn8SGYmRxWkziYTCmYdYh9luRNs3sYNkX7fQpB05UjKG7OWIPHLsJIylo7cgYyE
 qeSQEfq65y7XunvM4pNdaL2p5/4SKkiQ9BadgjfPhcL4hRdx3Q+rEUir6U+sfravGHo3TMK237
 Zee5/kNJda3G+cAAAA=
X-Change-ID: 20260601-nfsd-testing-e3509d5e035e
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
 Anna Schumaker <anna.schumaker@oracle.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@meta.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6209; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=7ZVpp48F0B2xB8Sg0Ry28tt/II4SvovHy6T6EAS/W1o=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqIYRl5kPJJNsJRdhPXV8fZ5x4sBvHul8OXnGlb
 ITfZcGFidyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaiGEZQAKCRAADmhBGVaC
 FZ6PD/9sTXScKHHcN5UQb4weka/L/+R99+rD/2ETi7YDU6pmK/7cbhoFxxBrSfjBlDiRdnc0uFr
 zVaCRP4ynF2E+VGbqJw4ETnkC7N/kKIqL6WtdPv2ifN0TzI7eSGTI08WGujfZCW4uSGfbtBvt2y
 npoe5wrxe4owBene/vmxLFakfLNHVfk7DyoS5WtisrbQRm+oCkWT6woZAEoAPnEX/ZO/+awtd0G
 u3OBxQetYaM1s+bSyW7HjKN9upRGBgmfNaGb40hmaxmWmN/6QM22lm23Fj/SxBHS7+KKdA45CRh
 L9lYCHUmaw/RBrZT9CDGpLXp3UkUC6aS9sSZSidCJo41RLdlxnd7qWnM8IrDxBsCOpU5pNhWJmZ
 lBPBtwIDb/Tlm3VzPehgrrY8Kf2YnJvmzQOZeAUtV4opewaZ3cAGuBWvmpPuU1jqreZOY/uGdeg
 g4A+kx/Q2bYUMQ+hDu1bwS7MW4EFl/emFLafXd60XfTdWKSp8pIcczMLEglrX0d1lFkjT3WPwRa
 nRsGDi+R99q/XinbKNlTvzalljtKZL0zePZB/5y0moyUba/0kfZ+pgJnhl24+bSUC49+NTbEPD9
 TrORPkNeMwIApQsQhJrNYLU0sN0rH7ZyZE581/zG9sDefE9OTfTeNYY2En2vC06p+ha4h/MGQRL
 CQ4cAC2RudyWINQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The shrinker, GC worker, and fsnotify/lease callbacks can unhash an
nfsd_file from the rhashtable and then call
nfsd_file_dispose_list_delayed() to move it to the per-net dispose list.
If nfsd_file_cache_shutdown_net() runs concurrently, its rhashtable walk
misses the already-unhashed file, and its drain of the per-net dispose
list can run before the file has been queued.  The file then sits on
the per-net list with no thread to drain it, leaking both the file and
its associated state.

The GC worker and shrinker already hold nfsd_gc_lock while walking the
LRU, but in the original code they release it before calling
nfsd_file_dispose_list_delayed().  The fsnotify/lease path
(nfsd_file_close_inode) has no synchronisation at all.

Fix this by:

  1. Widening nfsd_gc_lock in both nfsd_file_gc() and nfsd_file_lru_scan()
     to cover the nfsd_file_dispose_list_delayed() call.

  2. Wrapping nfsd_file_close_inode() in nfsd_gc_lock so that all three
     callers of nfsd_file_dispose_list_delayed() hold the lock.

  3. Adding a spin_lock/unlock(nfsd_gc_lock) barrier in
     nfsd_file_cache_shutdown_net() after the purge, so that any
     in-progress disposal has fully completed before the per-net list
     is drained.

All operations inside the lock are non-sleeping (rhashtable lookups,
atomic bit/refcount ops, list moves, svc_wake_up), so the spinlock is
appropriate.

Fixes: 43fd953fa7e2 ("nfsd: simplify the delayed disposal list code")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: Claude:claude-opus-4-8
---
This is the remaining patch from the 9 patch series I posted earlier
this week. This version doesn't touch the net refcount and instead
relies on increasing the scope of the nfsd_gc_lock.
---
Changes in v3:
- Drop already-merged patches from series
- Protect against race vs. pernet teardown by using nfsd_gc_lock instead
  of taking net references
- Link to v2: https://lore.kernel.org/r/20260602-nfsd-testing-v2-0-e4ea62e3cd5c@kernel.org

Changes in v2:
- rework filecache patch to only take net ref at disposal time
- fix ordering of operations in nfsd4_release_compoundargs()
- add Al's patch to simplify nfsd_cross_mnt() cleanup
- Link to v1: https://lore.kernel.org/r/20260601-nfsd-testing-v1-0-d0f61e536df8@kernel.org
---
 fs/nfsd/filecache.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 03f01a0beced..63fda677bbd2 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -55,6 +55,14 @@
 /* We only care about NFSD_MAY_READ/WRITE for this cache */
 #define NFSD_FILE_MAY_MASK	(NFSD_MAY_READ|NFSD_MAY_WRITE|NFSD_MAY_LOCALIO)
 
+/* If the shrinker runs between calls to list_lru_walk_node() in
+ * nfsd_file_gc(), the "remaining" count will be wrong.  This could
+ * result in premature freeing of some files.  This may not matter much
+ * but is easy to fix with this spinlock which temporarily disables
+ * the shrinker.
+ */
+static DEFINE_SPINLOCK(nfsd_gc_lock);
+
 static DEFINE_PER_CPU(unsigned long, nfsd_file_cache_hits);
 static DEFINE_PER_CPU(unsigned long, nfsd_file_acquisitions);
 static DEFINE_PER_CPU(unsigned long, nfsd_file_allocations);
@@ -426,10 +434,16 @@ nfsd_file_dispose_list(struct list_head *dispose)
  * Transfers each file to the per-net freeme list in its nfsd_net and wakes
  * an nfsd thread to do the actual close.  This keeps the cost of fput()
  * in the nfsd threads rather than in the shrinker or GC worker.
+ *
+ * All callers must hold nfsd_gc_lock, so that nfsd_file_cache_shutdown_net()
+ * can synchronise against them before draining the per-net dispose list.
+ * This guarantees nf_net is still live when we call net_generic().
  */
 static void
 nfsd_file_dispose_list_delayed(struct list_head *dispose)
 {
+	lockdep_assert_held(&nfsd_gc_lock);
+
 	while (!list_empty(dispose)) {
 		struct nfsd_file *nf = list_first_entry(dispose,
 						struct nfsd_file, nf_gc);
@@ -547,13 +561,6 @@ nfsd_file_gc_cb(struct list_head *item, struct list_lru_one *lru,
 	return nfsd_file_lru_cb(item, lru, arg);
 }
 
-/* If the shrinker runs between calls to list_lru_walk_node() in
- * nfsd_file_gc(), the "remaining" count will be wrong.  This could
- * result in premature freeing of some files.  This may not matter much
- * but is easy to fix with this spinlock which temporarily disables
- * the shrinker.
- */
-static DEFINE_SPINLOCK(nfsd_gc_lock);
 static void
 nfsd_file_gc(void)
 {
@@ -576,9 +583,9 @@ nfsd_file_gc(void)
 				remaining = 0;
 		}
 	}
+	nfsd_file_dispose_list_delayed(&dispose);
 	spin_unlock(&nfsd_gc_lock);
 	trace_nfsd_file_gc_removed(ret, list_lru_count(&nfsd_file_lru));
-	nfsd_file_dispose_list_delayed(&dispose);
 }
 
 static void
@@ -606,9 +613,9 @@ nfsd_file_lru_scan(struct shrinker *s, struct shrink_control *sc)
 
 	ret = list_lru_shrink_walk(&nfsd_file_lru, sc,
 				   nfsd_file_lru_cb, &dispose);
+	nfsd_file_dispose_list_delayed(&dispose);
 	spin_unlock(&nfsd_gc_lock);
 	trace_nfsd_file_shrinker_removed(ret, list_lru_count(&nfsd_file_lru));
-	nfsd_file_dispose_list_delayed(&dispose);
 	return ret;
 }
 
@@ -694,8 +701,10 @@ nfsd_file_close_inode(struct inode *inode)
 {
 	LIST_HEAD(dispose);
 
+	spin_lock(&nfsd_gc_lock);
 	nfsd_file_queue_for_close(inode, &dispose);
 	nfsd_file_dispose_list_delayed(&dispose);
+	spin_unlock(&nfsd_gc_lock);
 }
 
 /**
@@ -999,6 +1008,14 @@ nfsd_file_cache_shutdown_net(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	nfsd_file_cache_purge(net);
+	/*
+	 * Ensure any in-progress shrinker, GC, or fsnotify/lease callback
+	 * (all of which hold nfsd_gc_lock while calling
+	 * nfsd_file_dispose_list_delayed()) has fully completed before
+	 * draining the per-net dispose list.
+	 */
+	spin_lock(&nfsd_gc_lock);
+	spin_unlock(&nfsd_gc_lock);
 	nfsd_file_dispose_list(&nn->fcache_dispose_list);
 }
 

---
base-commit: ee0133a25c54a3000757e128a8b6b1f16fb42ff4
change-id: 20260601-nfsd-testing-e3509d5e035e

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

