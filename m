Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840044;
	b=BnosjPs4Q5Rnbvr5DEGxLB5Mw8dFGQX5YGpGmkbl9kfyrnnOZiSEfLszD3qbtTYaFre9
	 z1yZA+89K7yPdZzzzKq6aNGgfC/s7Ix4MqgCb7+oIUUVa9xe2GDJ0Y399k+/q8cc/PExc
	 cB+wbtxrqx/chruma0c7zWPwo/ETiAfKPvYpOvVBxjdZ+PL2fEXjFNlAj3Kjxc6OsXYQP
	 siMa/DT7ZRZDVZOlnO1dihr+/oFix4Xbeh/65kp2FzFP0PfYS21p1lapqnsm1zfz9+eRX
	 qF9ygUBbUlqFrMnugRTCgvpQJjzajd362j3OxlYuh3jCQUX3NBM8DsnUG8830Ry2qPA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840044;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=toK7NWImcz9ojW68j0qwJJbxrImEty7o3Od098VSgnU=;
	b=DSVeZpYAHKdgJQDmjMQFoYOsvMnUWno527HxaH2xFr/vMYeaEZ6o/bnU2xMGPSaCxoZU
	 THJ4EOw0uGP+twf4UlQg00SFcr8LlJVsnncMW8S8VPjYaceHI/FX+qzmXxM5J1hXETtGY
	 1pCIHakQZhST00rBux3uwaUK70sZMd2X/BfsrmC+mCNTfxlwdsQPqQdsT29HzsQtYAKOj
	 c7/O7/B4MuJy0h9fyHIf8vmxSWZy/Jim/0Nd/Qr3VYNukDVnnSoLlE5zs5ehnip7ywHKy
	 TvL72ZlHV0Z1KJ2yUJHH5Abfu7mvo62NfDame4Q7vXVN3iPaNVny1n8RCioDvD6lSkg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oUaRFa3c;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id C67CE60A2620;
	Thu,  5 Nov 2026 00:54:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oUaRFa3c
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id BDCF41F00A1A;
	Thu,  5 Nov 2026 00:54:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840043;
	bh=toK7NWImcz9ojW68j0qwJJbxrImEty7o3Od098VSgnU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oUaRFa3cDlMLwruMj7hLZJE+4joUWU7f9HDP3mWrg+PHLGKGbs39YkHmeiSGUsQCw
	 QybFMnedvXZlpDcigU8J53/P42Wmiaql7WuafyYchGr/2vIFpYKUXrwIk5Pf1ETNxZ
	 SQ7nPknG3xLLoAi+PPjpESCqzVOMkPT++xsqm7MsaEDT5BRTiWO3S49EGqE8eeZUpS
	 aXrR02Xmoxj7b+CU1r6jEy/T5ujTtIn4TIoXNg8PyM+LvyeB34IvRTOBckmjqZwNl3
	 WckMuWaBOa7gaeUrz9wJZ4lSPDhHIeDqBUMkCbU3+o9dGsgf5n2KHD1MAsg94NYHLx
	 TGIMlH9Br42EA==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Jarkko Sakkinen <jarkko@kernel.org>,
	keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: [RFC PATCH v3 11/11] KEYS: key_garbage_collector(): process in chunks
Date: Thu,  5 Nov 2026 02:53:10 +0200
Message-ID: <20261105005311.804098-12-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261105005311.804098-1-jarkko@kernel.org>
References: <20261105005311.804098-1-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

key_garbage_collector() has a design that is not resistant enough for
workqueue lockups. The duration scales up relative to the number of items
in the serial tree, which causes a reoccuring theme of being guilty of
causing workqueue lockups.

Resolve the problem by processing in chunks:

1. Declare a static variable key_gc_work, which owns the garbage collection
   in-flight state, and key_schedule_gc_work() for re-scheduling the work.
2. Define KEY_GC_CHUNK_SIZE, set to 64 keys, as the bound for the number
   of items scanned and destroyed.
3. Define KEY_GC_DESTROYING to mark resume to destruction without repeating
   the RCU grace period.
4. Define KEY_GC_REAP_REQUESTED for preserving full-pass requests across
   the continuations.

keygcbench results without the patch:

unused:   min=413.359 avg=1817.240 max=3221.120 var=1970880.024
expired:  min=0.002 avg=1360.124 max=2481.990 var=1055093.994
combined: min=0.002 avg=1542.970 max=3221.120 var=1471557.422

keygcbench results with the patch:

unused:   min=0.005 avg=0.126 max=54.173 var=0.946
expired:  min=0.002 avg=0.210 max=216.470 var=7.894
combined: min=0.002 avg=0.158 max=216.470 var=3.627

These results translate to:

- >99.9% drop in the combined variance.
- 3.0% increase in the total task time.

The value 64 for KEY_GC_CHUNK_SIZE was cherry-picked from the set {1, 2,
..., 1024} by running the benchmark for each chunk size three times.

At the far left variance is 97% lower but at the same time total time
grows by 133%, when compared to the selected chunk size. The size was
picked based on getting a reasonable variance with a minimal throughput
decline.

Fixes: 0c061b5707ab ("KEYS: Correctly destroy key payloads when their keytype is removed")
Link: https://git.kernel.org/pub/scm/linux/kernel/git/jarkko/linux-tpmdd-test.git/tree/package/keygcbench
Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 security/keys/gc.c       | 166 ++++++++++++++++++++++++++-------------
 security/keys/internal.h |   3 +-
 security/keys/key.c      |   4 +-
 security/keys/keyring.c  |   2 +-
 4 files changed, 117 insertions(+), 58 deletions(-)

diff --git a/security/keys/gc.c b/security/keys/gc.c
index 8e2c83ef29bc..9fbd1d94274e 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -11,27 +11,28 @@
 #include <keys/keyring-type.h>
 #include "internal.h"
 
-/*
- * Delay between key revocation/expiry in seconds
- */
-unsigned key_gc_delay = 5 * 60;
+#define KEY_GC_CHUNK_SIZE 64
 
 /*
  * Reaper for unused keys.
  */
 static void key_garbage_collector(struct work_struct *work);
-DECLARE_WORK(key_gc_work, key_garbage_collector);
 
-/**
- * key_gc_flush - Drain the garbage collector RCU callbacks
+static struct {
+	time64_t start;			/* expiry range start */
+	time64_t end;			/* expiry range end */
+	struct rb_node *cursor;		/* serial tree position */
+	u8 state;			/* state flags */
+	atomic_t seq;
+	struct work_struct work;	/* work item */
+} key_gc_work = {
+	.work = __WORK_INITIALIZER(key_gc_work.work, key_garbage_collector),
+};
+
+/*
+ * Delay between key revocation/expiry in seconds
  */
-void key_gc_flush(void)
-{
-	do {
-		rcu_barrier();
-	} while (flush_work(&key_gc_work));
-}
-EXPORT_SYMBOL_GPL(key_gc_flush);
+unsigned int key_gc_delay = 5 * 60;
 
 /*
  * Reaper for links from keyrings to dead keys.
@@ -42,6 +43,42 @@ static DEFINE_TIMER(key_gc_timer, key_gc_timer_func);
 static time64_t key_gc_next_run = TIME64_MAX;
 static unsigned long key_gc_flags;
 #define KEY_GC_KEY_EXPIRED	0	/* A key expired and needs unlinking */
+#define KEY_GC_REAP_REQUESTED	1	/* Another complete pass was requested */
+
+/*
+ * Schedule a new GC pass or re-schedule an ongoing GC pass.
+ */
+void key_schedule_gc_work(bool expired)
+{
+	unsigned long flags = BIT(KEY_GC_REAP_REQUESTED);
+
+	if (expired)
+		flags |= BIT(KEY_GC_KEY_EXPIRED);
+
+	/* Publish all request flags together, after the caller's updates. */
+	set_mask_bits(&key_gc_flags, 0, flags);
+	schedule_work(&key_gc_work.work);
+}
+
+/**
+ * key_gc_flush - Drain the garbage collector RCU callbacks
+ */
+void key_gc_flush(void)
+{
+	int seq;
+
+	do {
+		while (flush_work(&key_gc_work.work) ||
+		       work_pending(&key_gc_work.work))
+			cpu_relax();
+		seq = atomic_read_acquire(&key_gc_work.seq);
+		rcu_barrier();
+	} while (flush_work(&key_gc_work.work) ||
+		 work_pending(&key_gc_work.work) ||
+		 atomic_read_acquire(&key_gc_work.seq) != seq);
+}
+EXPORT_SYMBOL_GPL(key_gc_flush);
+
 /*
  * Schedule a garbage collection run.
  * - time precision isn't particularly important
@@ -55,7 +92,8 @@ void key_schedule_gc(time64_t gc_at)
 
 	if (gc_at <= now) {
 		kdebug("IMMEDIATE");
-		schedule_work(&key_gc_work);
+		/* Catch expirations that became due during the scan. */
+		key_schedule_gc_work(true);
 	} else if (gc_at < key_gc_next_run) {
 		kdebug("DEFERRED");
 		key_gc_next_run = gc_at;
@@ -77,15 +115,6 @@ void key_set_expiry(struct key *key, time64_t expiry)
 	}
 }
 
-/*
- * Schedule a dead links collection run.
- */
-void key_schedule_gc_links(void)
-{
-	set_bit(KEY_GC_KEY_EXPIRED, &key_gc_flags);
-	schedule_work(&key_gc_work);
-}
-
 /*
  * Some key's cleanup time was met after it expired, so we need to get the
  * reaper to go through a cycle finding expired keys.
@@ -94,7 +123,7 @@ static void key_gc_timer_func(struct timer_list *unused)
 {
 	kenter("");
 	key_gc_next_run = TIME64_MAX;
-	key_schedule_gc_links();
+	key_schedule_gc_work(true);
 }
 
 /*
@@ -102,7 +131,9 @@ static void key_gc_timer_func(struct timer_list *unused)
  */
 static noinline void key_gc_unused_keys(struct list_head *keys)
 {
-	while (!list_empty(keys)) {
+	unsigned int chunk = KEY_GC_CHUNK_SIZE;
+
+	while (!list_empty(keys) && chunk--) {
 		struct key *key =
 			list_entry(keys->next, struct key, graveyard_link);
 		struct module *owner = key->type->owner;
@@ -155,35 +186,46 @@ static noinline void key_gc_unused_keys(struct list_head *keys)
 static void key_garbage_collector(struct work_struct *work)
 {
 	static LIST_HEAD(graveyard);
-	u8 gc_state = 0;
+	typeof(key_gc_work) *gc = &key_gc_work;
 #define KEY_GC_REAP_AGAIN	0x01	/* - Need another cycle */
 #define KEY_GC_REAPING_LINKS	0x02	/* - We need to reap links */
+#define KEY_GC_DESTROYING	0x04	/* - We need to destroy keys */
 
-	struct rb_node *cursor;
+	unsigned int chunk = KEY_GC_CHUNK_SIZE;
+	unsigned long flags;
 	struct key *key;
-	time64_t new_timer, limit, expiry;
+	time64_t expiry;
 
-	kenter("[%lx]", key_gc_flags);
+	kenter("[%lx,%x]", key_gc_flags, gc->state);
 
-	limit = ktime_get_real_seconds();
+	if (gc->state & KEY_GC_DESTROYING)
+		goto destroy_keys;
+	if (gc->cursor) {
+		spin_lock(&key_serial_lock);
+		goto continue_scanning;
+	}
 
-	if (test_and_clear_bit(KEY_GC_KEY_EXPIRED, &key_gc_flags))
-		gc_state |= KEY_GC_REAPING_LINKS;
-	kdebug("new pass %x", gc_state);
+	flags = xchg(&key_gc_flags, 0);
+	gc->start = ktime_get_real_seconds();
+	gc->state = 0;
+	if (flags & BIT(KEY_GC_KEY_EXPIRED))
+		gc->state |= KEY_GC_REAPING_LINKS;
+	kdebug("new pass %x", gc->state);
 
-	new_timer = TIME64_MAX;
+	gc->end = TIME64_MAX;
 
 	/* As only this function is permitted to remove things from the key
 	 * serial tree, if cursor is non-NULL then it will always point to a
 	 * valid node in the tree - even if lock got dropped.
 	 */
 	spin_lock(&key_serial_lock);
-	cursor = rb_first(&key_serial_tree);
+	gc->cursor = rb_first(&key_serial_tree);
 
 continue_scanning:
-	while (cursor) {
-		key = rb_entry(cursor, struct key, serial_node);
-		cursor = rb_next(cursor);
+	while (gc->cursor && chunk) {
+		key = rb_entry(gc->cursor, struct key, serial_node);
+		gc->cursor = rb_next(gc->cursor);
+		chunk--;
 
 		if (!test_bit_acquire(KEY_FLAG_USER_ALIVE, &key->flags)) {
 			/* Clobber key->user after final put seen. */
@@ -194,14 +236,14 @@ static void key_garbage_collector(struct work_struct *work)
 		if (expiry != TIME64_MAX) {
 			if (!(key->type->flags & KEY_TYPE_INSTANT_REAP))
 				expiry += key_gc_delay;
-			if (expiry > limit && expiry < new_timer) {
+			if (expiry > gc->start && expiry < gc->end) {
 				kdebug("will expire %x in %lld",
-				       key_serial(key), key->expiry - limit);
-				new_timer = key->expiry;
+				       key_serial(key), key->expiry - gc->start);
+				gc->end = key->expiry;
 			}
 		}
 
-		if ((gc_state & KEY_GC_REAPING_LINKS) &&
+		if ((gc->state & KEY_GC_REAPING_LINKS) &&
 		    key->type == &key_type_keyring)
 			goto found_keyring;
 
@@ -213,7 +255,11 @@ static void key_garbage_collector(struct work_struct *work)
 	spin_unlock(&key_serial_lock);
 
 maybe_resched:
-	if (cursor) {
+	if (gc->cursor) {
+		if (!chunk) {
+			schedule_work(&key_gc_work.work);
+			goto out;
+		}
 		cond_resched();
 		spin_lock(&key_serial_lock);
 		goto continue_scanning;
@@ -225,9 +271,9 @@ static void key_garbage_collector(struct work_struct *work)
 	 */
 	kdebug("pass complete");
 
-	if (new_timer != TIME64_MAX) {
-		new_timer += key_gc_delay;
-		key_schedule_gc(new_timer);
+	if (gc->end != TIME64_MAX) {
+		gc->end += key_gc_delay;
+		key_schedule_gc(gc->end);
 	}
 
 	if (!list_empty(&graveyard)) {
@@ -238,13 +284,27 @@ static void key_garbage_collector(struct work_struct *work)
 		 */
 		kdebug("gc sync");
 		synchronize_rcu();
+	}
+
+	gc->state |= KEY_GC_DESTROYING;
+
+destroy_keys:
+	if (!list_empty(&graveyard)) {
 		kdebug("gc keys");
 		key_gc_unused_keys(&graveyard);
+		if (!list_empty(&graveyard)) {
+			schedule_work(&key_gc_work.work);
+			goto out;
+		}
 	}
-
-	if (gc_state & KEY_GC_REAP_AGAIN)
-		schedule_work(&key_gc_work);
-	kleave(" [end %x]", gc_state);
+	gc->state &= ~KEY_GC_DESTROYING;
+
+	if ((gc->state & KEY_GC_REAP_AGAIN) ||
+	    test_bit(KEY_GC_REAP_REQUESTED, &key_gc_flags))
+		schedule_work(&key_gc_work.work);
+out:
+	atomic_inc_return(&gc->seq);
+	kleave(" [end %x]", gc->state);
 	return;
 
 	/* We found an unreferenced key - once we've removed it from the tree,
@@ -256,7 +316,7 @@ static void key_garbage_collector(struct work_struct *work)
 	spin_unlock(&key_serial_lock);
 
 	list_add_tail(&key->graveyard_link, &graveyard);
-	gc_state |= KEY_GC_REAP_AGAIN;
+	gc->state |= KEY_GC_REAP_AGAIN;
 	goto maybe_resched;
 
 	/* We found a keyring and we need to check the payload for links to
@@ -266,6 +326,6 @@ static void key_garbage_collector(struct work_struct *work)
 	 */
 found_keyring:
 	spin_unlock(&key_serial_lock);
-	keyring_gc(key, limit);
+	keyring_gc(key, gc->start);
 	goto maybe_resched;
 }
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 005d609ae2df..976f16baf632 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -161,12 +161,11 @@ extern bool lookup_user_key_possessed(const struct key *key,
 extern long join_session_keyring(const char *name);
 extern void key_change_session_keyring(struct callback_head *twork);
 
-extern struct work_struct key_gc_work;
 extern unsigned key_gc_delay;
 extern void keyring_gc(struct key *keyring, time64_t limit);
 void key_set_expiry(struct key *key, time64_t expiry);
 extern void key_schedule_gc(time64_t gc_at);
-extern void key_schedule_gc_links(void);
+void key_schedule_gc_work(bool expired);
 
 extern int key_task_permission(const key_ref_t key_ref,
 			       const struct cred *cred,
diff --git a/security/keys/key.c b/security/keys/key.c
index df6af8066212..374f65c12ac8 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -693,7 +693,7 @@ void key_put(struct key *key)
 			}
 			/* Mark key as safe for GC after key->user done. */
 			clear_bit_unlock(KEY_FLAG_USER_ALIVE, &key->flags);
-			schedule_work(&key_gc_work);
+			key_schedule_gc_work(false);
 		}
 	}
 }
@@ -1214,7 +1214,7 @@ void key_invalidate(struct key *key)
 		down_write_nested(&key->sem, 1);
 		if (!test_and_set_bit(KEY_FLAG_INVALIDATED, &key->flags)) {
 			notify_key(key, NOTIFY_KEY_INVALIDATED, 0);
-			key_schedule_gc_links();
+			key_schedule_gc_work(true);
 		}
 		up_write(&key->sem);
 	}
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index b51abf698aa9..393e6d3fb4bd 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -266,7 +266,7 @@ void key_remove_domain(struct key_tag *domain_tag)
 {
 	domain_tag->removed = true;
 	if (!key_put_tag(domain_tag))
-		key_schedule_gc_links();
+		key_schedule_gc_work(true);
 }
 
 /*
-- 
2.47.3

