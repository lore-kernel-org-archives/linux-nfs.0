Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab3GQUoT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:44:19 -0400
Subject: [PATCH 07/10] KEYS: Search for auth-key by name rather than targt
 key ID
To: keyrings@linux-nfs.org
From: David Howells <dhowells@redhat.com>
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 17 Jul 2013 21:44:15 +0100
Message-ID: <20130717204415.8591.41028.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
References: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Search for auth-key by name rather than by target key ID as, in a future
patch, we'll by searching directly by index key in preference to iteration
over all keys.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/request_key_auth.c |   21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/security/keys/request_key_auth.c b/security/keys/request_key_auth.c
index 8d09852..7495a93 100644
--- a/security/keys/request_key_auth.c
+++ b/security/keys/request_key_auth.c
@@ -18,6 +18,7 @@
 #include <linux/slab.h>
 #include <asm/uaccess.h>
 #include "internal.h"
+#include <keys/user-type.h>
 
 static int request_key_auth_instantiate(struct key *,
 					struct key_preparsed_payload *);
@@ -222,33 +223,25 @@ error_alloc:
 }
 
 /*
- * See if an authorisation key is associated with a particular key.
- */
-static int key_get_instantiation_authkey_match(const struct key *key,
-					       const void *_id)
-{
-	struct request_key_auth *rka = key->payload.data;
-	key_serial_t id = (key_serial_t)(unsigned long) _id;
-
-	return rka->target_key->serial == id;
-}
-
-/*
  * Search the current process's keyrings for the authorisation key for
  * instantiation of a key.
  */
 struct key *key_get_instantiation_authkey(key_serial_t target_id)
 {
+	char description[16];
 	struct keyring_search_context ctx = {
 		.index_key.type		= &key_type_request_key_auth,
+		.index_key.description	= description,
 		.cred			= current_cred(),
-		.match			= key_get_instantiation_authkey_match,
-		.match_data		= (void *)(unsigned long)target_id,
+		.match			= user_match,
+		.match_data		= description,
 		.flags			= KEYRING_SEARCH_LOOKUP_DIRECT,
 	};
 	struct key *authkey;
 	key_ref_t authkey_ref;
 
+	sprintf(description, "%x", target_id);
+
 	authkey_ref = search_process_keyrings(&ctx);
 
 	if (IS_ERR(authkey_ref)) {

