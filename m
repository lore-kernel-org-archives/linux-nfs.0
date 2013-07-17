Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756541Ab3GQUnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:43:43 -0400
Subject: [PATCH 03/10] KEYS: Use bool in make_key_ref() and
 is_key_possessed()
To: keyrings@linux-nfs.org
From: David Howells <dhowells@redhat.com>
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 17 Jul 2013 21:43:39 +0100
Message-ID: <20130717204339.8591.90548.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
References: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make make_key_ref() take a bool possession parameter and make
is_key_possessed() return a bool.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/security/keys.txt |    7 +++----
 include/linux/key.h             |    4 ++--
 security/keys/keyring.c         |    5 +++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index 7b4145d..9ede670 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -865,15 +865,14 @@ encountered:
      calling processes has a searchable link to the key from one of its
      keyrings. There are three functions for dealing with these:
 
-	key_ref_t make_key_ref(const struct key *key,
-			       unsigned long possession);
+	key_ref_t make_key_ref(const struct key *key, bool possession);
 
 	struct key *key_ref_to_ptr(const key_ref_t key_ref);
 
-	unsigned long is_key_possessed(const key_ref_t key_ref);
+	bool is_key_possessed(const key_ref_t key_ref);
 
      The first function constructs a key reference from a key pointer and
-     possession information (which must be 0 or 1 and not any other value).
+     possession information (which must be true or false).
 
      The second function retrieves the key pointer from a reference and the
      third retrieves the possession flag.
diff --git a/include/linux/key.h b/include/linux/key.h
index 4dfde11..51bce29 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -99,7 +99,7 @@ struct keyring_name;
 typedef struct __key_reference_with_attributes *key_ref_t;
 
 static inline key_ref_t make_key_ref(const struct key *key,
-				     unsigned long possession)
+				     bool possession)
 {
 	return (key_ref_t) ((unsigned long) key | possession);
 }
@@ -109,7 +109,7 @@ static inline struct key *key_ref_to_ptr(const key_ref_t key_ref)
 	return (struct key *) ((unsigned long) key_ref & ~1UL);
 }
 
-static inline unsigned long is_key_possessed(const key_ref_t key_ref)
+static inline bool is_key_possessed(const key_ref_t key_ref)
 {
 	return (unsigned long) key_ref & 1UL;
 }
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 6ece7f2..f784063 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -329,9 +329,10 @@ key_ref_t keyring_search_aux(key_ref_t keyring_ref,
 
 	struct keyring_list *keylist;
 	struct timespec now;
-	unsigned long possessed, kflags;
+	unsigned long kflags;
 	struct key *keyring, *key;
 	key_ref_t key_ref;
+	bool possessed;
 	long err;
 	int sp, nkeys, kix;
 
@@ -542,8 +543,8 @@ key_ref_t __keyring_search_one(key_ref_t keyring_ref,
 			       key_perm_t perm)
 {
 	struct keyring_list *klist;
-	unsigned long possessed;
 	struct key *keyring, *key;
+	bool possessed;
 	int nkeys, loop;
 
 	keyring = key_ref_to_ptr(keyring_ref);

