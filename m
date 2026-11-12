Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794456172;
	b=yWgL36nYfFxBSNnp8V0J1nOS4ZXwe5N8PK0ALPbCZad5T6C3EoLSvRWVMYrROXf1Q0O7
	 vYbY85Q+ny7c4fMmox023HsLmqDmLbB7sp5zVCwSOE6oz/VqLCmtKvE54eGpc8ukEWwMT
	 l4qBFDxkwLKIt/o3vLzqty5qC7BVqsPADwW1TuyYBaJel4TCzET08Nw6t/z5SCgrx4f58
	 6eq57gwrxTWn3Cb25ZFdXCmo5mNwQj3A0byh9JN9MFWKMN9BFNFFD4mxbXDDTexLPf3Ww
	 fzXG0mzCdU4EMMqJ2Paz07ExDQB1NuOHa903cUzNuXe4MdJv9tevOqveEOJvae0YWMQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794456172;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=kva36s1/FXbG0PGpansUJI6uoi654aIusMQ5DfEE8Bs=;
	b=Amm5CuXTeJjXwXRhK7wnDaEdBtOgMwOhZ8pk7mty2fQZw7loFefZt6XeWUzQtx0xQBgD
	 H75+L6XeLVc1HdMgUNG8PvGEp9MIh8PHik0aDP4oRqLzR5Qqo6WjoB8kCsJwsaDBiGAGy
	 zV+RuPh06VQXtzobj2+55oRqGSPUwHFjWgnaYo6XZOFF1gI+/35hyHCOwNYE2vVkMz6Wu
	 VKqa17rcvYuA9ZftarBceuZi5SsYlrELxComf5rTc029PKDkOP2hEzuM2/Bg54sBdWB8y
	 iUcCvGS9mgerdiNDYtnOFSOi0Wi6R8DqKU/23ez+4fmQuwT1crzgP86dHaWWxkoondQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TfVc5ShF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 5B9FD606A31C;
	Thu, 12 Nov 2026 04:02:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TfVc5ShF
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 42C571F00A0A;
	Thu, 12 Nov 2026 04:02:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794456172;
	bh=kva36s1/FXbG0PGpansUJI6uoi654aIusMQ5DfEE8Bs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TfVc5ShFttE0ywd1Y0iRkuux/jO6eEd0Car3Te6c99mFhXlXtKQ7KOQAQsQTBuAWP
	 K2TnMbaVa86AtBBgmTJvgP+HxYtLfdKzgZntAnw3Cb9x7AJ7AN8nrIdkMbYK2IpZ1N
	 DH7Qai9D3vG/8rYawdH0CstjGOm/wINeUGWIewOq4F8ZQ43hFsFihzrFSnaJZDCdEH
	 12ElZVSjBfDqtnGg3ByrFBopEUr2OY3UEDOJOly4TkoQRyAONiQppk/kT9Z1+brDV+
	 FD+TpRGBvtfi5ER6Uo1BUvZrGBnYydqJzGly3iFNlAce2hUA+Z9i0G8bRDqbYo0cYn
	 N0qM1ZMLS8CQQ==
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
Subject: [PATCH v6 01/13] KEYS: Add key_gc_flush() for draining RCU callbacks
Date: Thu, 12 Nov 2026 06:02:30 +0200
Message-ID: <20261112040242.247168-2-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261112040242.247168-1-jarkko@kernel.org>
References: <20261112040242.247168-1-jarkko@kernel.org>
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

keyring_clear() and key_invalidate() release keyring links via call_rcu(),
and key_put() defers final key destruction to key_gc_work.

Once keys pin their type, callers that clear an internal cache before
module unload need a synchronous barrier so module references can be
dropped before delete_module() checks the refcount.

Add key_gc_flush() for flushing the remaining key_gc_work passes.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 include/linux/key.h      |  2 ++
 security/keys/gc.c       | 21 +++++++++++++++++----
 security/keys/internal.h |  1 +
 security/keys/key.c      |  6 +++++-
 4 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index 420412aab926..0f408255f740 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -439,6 +439,7 @@ extern int restrict_link_reject(struct key *keyring,
 				struct key *restriction_key);
 
 extern int keyring_clear(struct key *keyring);
+void key_gc_flush(void);
 
 extern key_ref_t keyring_search(key_ref_t keyring,
 				struct key_type *type,
@@ -526,6 +527,7 @@ extern void key_init(void);
 #define key_free_user_ns(ns)		do { } while(0)
 #define key_remove_domain(d)		do { } while(0)
 #define key_lookup(k)			NULL
+#define key_gc_flush()			do { } while (0)
 
 #endif /* CONFIG_KEYS */
 #endif /* __KERNEL__ */
diff --git a/security/keys/gc.c b/security/keys/gc.c
index eda445f815d4..9b625436d3b5 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -19,8 +19,21 @@ unsigned key_gc_delay = 5 * 60;
  * Reaper for unused keys.
  */
 static void key_garbage_collector(struct work_struct *work);
+
+struct workqueue_struct *key_gc_wq __ro_after_init;
 DECLARE_WORK(key_gc_work, key_garbage_collector);
 
+/**
+ * key_gc_flush - Drain the garbage collector RCU callbacks
+ */
+void key_gc_flush(void)
+{
+	do {
+		rcu_barrier();
+	} while (flush_work(&key_gc_work));
+}
+EXPORT_SYMBOL_GPL(key_gc_flush);
+
 /*
  * Reaper for links from keyrings to dead keys.
  */
@@ -57,7 +70,7 @@ void key_schedule_gc(time64_t gc_at)
 
 	if (gc_at <= now || test_bit(KEY_GC_REAP_KEYTYPE, &key_gc_flags)) {
 		kdebug("IMMEDIATE");
-		schedule_work(&key_gc_work);
+		queue_work(key_gc_wq, &key_gc_work);
 	} else if (gc_at < key_gc_next_run) {
 		kdebug("DEFERRED");
 		key_gc_next_run = gc_at;
@@ -85,7 +98,7 @@ void key_set_expiry(struct key *key, time64_t expiry)
 void key_schedule_gc_links(void)
 {
 	set_bit(KEY_GC_KEY_EXPIRED, &key_gc_flags);
-	schedule_work(&key_gc_work);
+	queue_work(key_gc_wq, &key_gc_work);
 }
 
 /*
@@ -119,7 +132,7 @@ void key_gc_keytype(struct key_type *ktype)
 	set_bit(KEY_GC_REAP_KEYTYPE, &key_gc_flags);
 
 	kdebug("schedule");
-	schedule_work(&key_gc_work);
+	queue_work(key_gc_wq, &key_gc_work);
 
 	kdebug("sleep");
 	wait_on_bit(&key_gc_flags, KEY_GC_REAPING_KEYTYPE,
@@ -322,7 +335,7 @@ static void key_garbage_collector(struct work_struct *work)
 	}
 
 	if (gc_state & KEY_GC_REAP_AGAIN)
-		schedule_work(&key_gc_work);
+		queue_work(key_gc_wq, &key_gc_work);
 	kleave(" [end %x]", gc_state);
 	return;
 
diff --git a/security/keys/internal.h b/security/keys/internal.h
index b7b622bc36a1..84f14307552b 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -164,6 +164,7 @@ extern void key_change_session_keyring(struct callback_head *twork);
 
 extern struct work_struct key_gc_work;
 extern unsigned key_gc_delay;
+extern struct workqueue_struct *key_gc_wq;
 extern void keyring_gc(struct key *keyring, time64_t limit);
 extern void keyring_restriction_gc(struct key *keyring,
 				   struct key_type *dead_type);
diff --git a/security/keys/key.c b/security/keys/key.c
index 3f1f0fc13710..3e604d25d35e 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -670,7 +670,7 @@ void key_put(struct key *key)
 			}
 			/* Mark key as safe for GC after key->user done. */
 			clear_bit_unlock(KEY_FLAG_USER_ALIVE, &key->flags);
-			schedule_work(&key_gc_work);
+			queue_work(key_gc_wq, &key_gc_work);
 		}
 	}
 }
@@ -1294,6 +1294,10 @@ void __init key_init(void)
 	key_jar = kmem_cache_create("key_jar", sizeof(struct key),
 			0, SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_NO_MERGE, NULL);
 
+	key_gc_wq = alloc_workqueue("key_gc", WQ_MEM_RECLAIM | WQ_PERCPU, 0);
+	if (!key_gc_wq)
+		panic("Cannot create key_gc workqueue\n");
+
 	/* add the special key types */
 	list_add_tail(&key_type_keyring.link, &key_types_list);
 	list_add_tail(&key_type_dead.link, &key_types_list);
-- 
2.47.3

