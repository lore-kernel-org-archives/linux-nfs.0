Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26934 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab3GQUog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:44:36 -0400
Subject: [PATCH 09/10] KEYS: Drop the permissions argument from
 __keyring_search_one()
To: keyrings@linux-nfs.org
From: David Howells <dhowells@redhat.com>
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 17 Jul 2013 21:44:33 +0100
Message-ID: <20130717204433.8591.42799.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
References: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drop the permissions argument from __keyring_search_one() as the only caller
passes 0 here - which causes all checks to be skipped.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/internal.h |    3 +--
 security/keys/key.c      |    2 +-
 security/keys/keyring.c  |    9 +++------
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/security/keys/internal.h b/security/keys/internal.h
index f4bf938..73950bf 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -99,8 +99,7 @@ extern void __key_link_end(struct key *keyring,
 			   unsigned long prealloc);
 
 extern key_ref_t __keyring_search_one(key_ref_t keyring_ref,
-				      const struct keyring_index_key *index_key,
-				      key_perm_t perm);
+				      const struct keyring_index_key *index_key);
 
 extern struct key *keyring_search_instkey(struct key *keyring,
 					  key_serial_t target_id);
diff --git a/security/keys/key.c b/security/keys/key.c
index 1e23cc2..7d716b8 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -847,7 +847,7 @@ key_ref_t key_create_or_update(key_ref_t keyring_ref,
 	 * update that instead if possible
 	 */
 	if (index_key.type->update) {
-		key_ref = __keyring_search_one(keyring_ref, &index_key, 0);
+		key_ref = __keyring_search_one(keyring_ref, &index_key);
 		if (!IS_ERR(key_ref))
 			goto found_matching_key;
 	}
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 35e21d9..37e0d65 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -531,15 +531,14 @@ EXPORT_SYMBOL(keyring_search);
  * RCU is used to make it unnecessary to lock the keyring key list here.
  *
  * Returns a pointer to the found key with usage count incremented if
- * successful and returns -ENOKEY if not found.  Revoked keys and keys not
- * providing the requested permission are skipped over.
+ * successful and returns -ENOKEY if not found.  Revoked and invalidated keys
+ * are skipped over.
  *
  * If successful, the possession indicator is propagated from the keyring ref
  * to the returned key reference.
  */
 key_ref_t __keyring_search_one(key_ref_t keyring_ref,
-			       const struct keyring_index_key *index_key,
-			       key_perm_t perm)
+			       const struct keyring_index_key *index_key)
 {
 	struct keyring_list *klist;
 	struct key *keyring, *key;
@@ -560,8 +559,6 @@ key_ref_t __keyring_search_one(key_ref_t keyring_ref,
 			if (key->type == index_key->type &&
 			    (!key->type->match ||
 			     key->type->match(key, index_key->description)) &&
-			    key_permission(make_key_ref(key, possessed),
-					   perm) == 0 &&
 			    !(key->flags & ((1 << KEY_FLAG_INVALIDATED) |
 					    (1 << KEY_FLAG_REVOKED)))
 			    )

