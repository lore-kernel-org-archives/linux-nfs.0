Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab3GQUn0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:43:26 -0400
Subject: [PATCH 01/10] KEYS: Skip key state checks when checking for
 possession
To: keyrings@linux-nfs.org
From: David Howells <dhowells@redhat.com>
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 17 Jul 2013 21:43:23 +0100
Message-ID: <20130717204322.8591.11939.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
References: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Skip key state checks (invalidation, revocation and expiration) when checking
for possession.  Without this, keys that have been marked invalid, revoked
keys and expired keys are not given a possession attribute - which means the
possessor is not granted any possession permits and cannot do anything with
them unless they also have one a user, group or other permit.

This causes failures in the keyutils test suite's revocation and expiration
tests now that commit 96b5c8fea6c0861621051290d705ec2e971963f1 reduced the
initial permissions granted to a key.

The failures are due to accesses to revoked and expired keys being given
EACCES instead of EKEYREVOKED or EKEYEXPIRED.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/internal.h         |    1 +
 security/keys/process_keys.c     |    8 +++++---
 security/keys/request_key.c      |    6 ++++--
 security/keys/request_key_auth.c |    2 +-
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/security/keys/internal.h b/security/keys/internal.h
index d4f1468..df971fe 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -124,6 +124,7 @@ extern key_ref_t search_my_process_keyrings(struct key_type *type,
 extern key_ref_t search_process_keyrings(struct key_type *type,
 					 const void *description,
 					 key_match_func_t match,
+					 bool no_state_check,
 					 const struct cred *cred);
 
 extern struct key *find_keyring_by_name(const char *name, bool skip_perm_check);
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 42defae..a3410d6 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -440,6 +440,7 @@ found:
 key_ref_t search_process_keyrings(struct key_type *type,
 				  const void *description,
 				  key_match_func_t match,
+				  bool no_state_check,
 				  const struct cred *cred)
 {
 	struct request_key_auth *rka;
@@ -448,7 +449,7 @@ key_ref_t search_process_keyrings(struct key_type *type,
 	might_sleep();
 
 	key_ref = search_my_process_keyrings(type, description, match,
-					     false, cred);
+					     no_state_check, cred);
 	if (!IS_ERR(key_ref))
 		goto found;
 	err = key_ref;
@@ -468,7 +469,8 @@ key_ref_t search_process_keyrings(struct key_type *type,
 			rka = cred->request_key_auth->payload.data;
 
 			key_ref = search_process_keyrings(type, description,
-							  match, rka->cred);
+							  match, no_state_check,
+							  rka->cred);
 
 			up_read(&cred->request_key_auth->sem);
 
@@ -675,7 +677,7 @@ try_again:
 		/* check to see if we possess the key */
 		skey_ref = search_process_keyrings(key->type, key,
 						   lookup_user_key_possessed,
-						   cred);
+						   true, cred);
 
 		if (!IS_ERR(skey_ref)) {
 			key_put(key);
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index c411f9b..172115b 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -390,7 +390,8 @@ static int construct_alloc_key(struct key_type *type,
 	 * waited for locks */
 	mutex_lock(&key_construction_mutex);
 
-	key_ref = search_process_keyrings(type, description, type->match, cred);
+	key_ref = search_process_keyrings(type, description, type->match,
+					  false, cred);
 	if (!IS_ERR(key_ref))
 		goto key_already_present;
 
@@ -539,7 +540,8 @@ struct key *request_key_and_link(struct key_type *type,
 	       dest_keyring, flags);
 
 	/* search all the process keyrings for a key */
-	key_ref = search_process_keyrings(type, description, type->match, cred);
+	key_ref = search_process_keyrings(type, description, type->match,
+					  false, cred);
 
 	if (!IS_ERR(key_ref)) {
 		key = key_ref_to_ptr(key_ref);
diff --git a/security/keys/request_key_auth.c b/security/keys/request_key_auth.c
index 85730d5..92077de 100644
--- a/security/keys/request_key_auth.c
+++ b/security/keys/request_key_auth.c
@@ -247,7 +247,7 @@ struct key *key_get_instantiation_authkey(key_serial_t target_id)
 		&key_type_request_key_auth,
 		(void *) (unsigned long) target_id,
 		key_get_instantiation_authkey_match,
-		cred);
+		false, cred);
 
 	if (IS_ERR(authkey_ref)) {
 		authkey = ERR_CAST(authkey_ref);

