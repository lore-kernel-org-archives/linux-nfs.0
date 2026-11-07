Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794057356;
	b=C+QySQI7dgEt8Oq2Ew4mblyjT3NnzfadkTaP6i42XMZ7FiU5BZi4nCQtvzdnopg/W2ZY
	 b1cmdomUtJUTgHzaD2c57j3ZK1j8Ji/3XvT2t746OsPr5dGSz6IwjVIKvzFJNXzwlzqgx
	 TPtD9V/ZN23fuAfycpKica8B8NKqnThCnfvNA4wb0WIxm7t2OxvaxsyWOJqUnQ8jicGzi
	 dxqMPuihkcZfIt3AdNPIJUmueJnxdW/6158q0xnSD/lH2NV8yCW2B4ZHN6rYAWzJM7mUM
	 gGlRCcPWX4Jji2pD5aT16ss2z9ICAq7dQhhX9T1J+2utrdn2lm4vTXY5rv2jlsrIWaA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794057356;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=pPJtaNXXVN6W3aSE9iN/Uh6en78jkh+qXfwU+6KoP0E=;
	b=KeRGQU3POtFv7lwpb0XTFe5krKldkUTbd+MIqDl6R4br8TLEdDFzVjkU18XSLedbsv6s
	 pVXEZ55gHV62Rbo66WFirjLGROz/SpzJ6n7efz9HxPkyEub22YYTZMJe07GDS1OSbSoMn
	 joiD0zH/WBXzPTYoZXv5P9n4efN1x6JBXHS2vBjoynDReoNsi69W9acXblBnfuAKbf3yP
	 6PGHHGQ7BJeGyTiPYdvZPmnWdnyttp8KgP3Q9czTtY62x97xCQogQWM/ZWERY0mNSGfbj
	 CelAuGqXfpApjNLBAposPDUQGm2ywnK4Jewov0gDnXVAGEv4Lqj59KS8n76I9NohBtA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kc0mb3vo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id DC653606D813;
	Sat,  7 Nov 2026 13:15:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kc0mb3vo
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 0CADE1F008A6;
	Sat,  7 Nov 2026 13:15:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794057355;
	bh=pPJtaNXXVN6W3aSE9iN/Uh6en78jkh+qXfwU+6KoP0E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kc0mb3voKBSKiadfBRWgdG1TFYzNTeWWy/mtCL1NlQ3gxJsZ+vp+u3BxOUAuuN++w
	 5247t9a8ET+aHQBmPl8+bPEfssBpQviEPyE4A7AdHJrSG4cLSMBX912mmLDpB+8OHG
	 vmdt3KY3IRPDOj6h2hDSDub3OtTZzCJ+2RrnNJ6KP90KeakslY35KnD8oD/4A7Ea2o
	 1cUNJskiVU3Ol/8ObBycVQYRqlzGemTOG+xBrAsWcOQETsCLxqqEk0zjxF/s7XIkWK
	 3WW0ORkZlkHwoYe5/MChXCHSiTAFlT2U6ok/3Ip2+X9bRec5fW0UxescgdNp9thNGx
	 P1K/NSqXizUCQ==
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
Subject: [PATCH v4 09/11] KEYS: Pin the backing kernel module for a key type
Date: Sat,  7 Nov 2026 15:15:10 +0200
Message-ID: <20261107131512.3603168-10-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261107131512.3603168-1-jarkko@kernel.org>
References: <20261107131512.3603168-1-jarkko@kernel.org>
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

Add the owner field (populated with THIS_MODULE) to struct key_type.

Pin the module in key_alloc() and keyring_restrict(), and release it in
key_gc_unused_keys() and keyring_destroy(), which are wires to the keys
and restrictions.

Reject module owners still in MODULE_STATE_COMING so that the failed
module_init() paths cannot leave behind referenced keys.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 include/linux/key-type.h |  6 ++++-
 security/keys/gc.c       | 14 ++++++++++--
 security/keys/key.c      | 48 ++++++++++++++++++++++++++++++----------
 security/keys/keyring.c  | 36 +++++++++++++++++++++++++-----
 4 files changed, 83 insertions(+), 21 deletions(-)

diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index c4f329b6ae3f..9ecec31ad571 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -10,9 +10,11 @@
 
 #include <linux/key.h>
 #include <linux/errno.h>
+#include <linux/init.h>
 
 #ifdef CONFIG_KEYS
 
+struct module;
 struct kernel_pkey_query;
 struct kernel_pkey_params;
 
@@ -161,6 +163,7 @@ struct key_type {
 				     const void *in, const void *in2);
 
 	/* internal fields */
+	struct module		*owner;
 	atomic64_t		index_id;	/* Opaque keyring index ID */
 	struct list_head	link;		/* link in types list */
 	struct lock_class_key	lock_class;	/* key->sem lock class */
@@ -168,7 +171,8 @@ struct key_type {
 
 extern struct key_type key_type_keyring;
 
-extern int register_key_type(struct key_type *ktype);
+int __register_key_type(struct key_type *ktype, struct module *owner);
+#define register_key_type(ktype) __register_key_type(ktype, THIS_MODULE)
 extern void unregister_key_type(struct key_type *ktype);
 
 extern int key_payload_reserve(struct key *key, size_t datalen);
diff --git a/security/keys/gc.c b/security/keys/gc.c
index 9b625436d3b5..7b2f32998f58 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/slab.h>
+#include <linux/module.h>
 #include <linux/security.h>
 #include <keys/keyring-type.h>
 #include "internal.h"
@@ -150,6 +151,7 @@ static noinline void key_gc_unused_keys(struct list_head *keys)
 	while (!list_empty(keys)) {
 		struct key *key =
 			list_entry(keys->next, struct key, graveyard_link);
+		struct module *owner = key->type->owner;
 		short state = key->state;
 
 		list_del(&key->graveyard_link);
@@ -163,8 +165,15 @@ static noinline void key_gc_unused_keys(struct list_head *keys)
 #endif
 
 		/* Throw away the key data if the key is instantiated */
-		if (state == KEY_IS_POSITIVE && key->type->destroy)
-			key->type->destroy(key);
+		if (state == KEY_IS_POSITIVE) {
+			if (key->type->destroy)
+				key->type->destroy(key);
+		} else if (key->restrict_link) {
+			if (key->restrict_link->keytype)
+				module_put(key->restrict_link->keytype->owner);
+			key_put(key->restrict_link->key);
+			kfree(key->restrict_link);
+		}
 
 		security_key_free(key);
 
@@ -178,6 +187,7 @@ static noinline void key_gc_unused_keys(struct list_head *keys)
 
 		memzero_explicit(key, sizeof(*key));
 		kmem_cache_free(key_jar, key);
+		module_put(owner);
 	}
 }
 
diff --git a/security/keys/key.c b/security/keys/key.c
index 3e604d25d35e..be68d19f91d3 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -7,6 +7,7 @@
 
 #include <linux/export.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/poison.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -234,19 +235,34 @@ struct key *key_alloc(struct key_type *type, const char *desc,
 
 	key = ERR_PTR(-EINVAL);
 	if (!desc || !*desc)
-		goto error;
+		goto out;
+
+	/* Failed module initialization ignores outstanding module references. */
+	if ((type->owner && module_is_coming(type->owner)) ||
+	    !try_module_get(type->owner)) {
+		key = ERR_PTR(-ENOENT);
+		goto out;
+	}
+
+	if (restrict_link && restrict_link->keytype &&
+	    ((restrict_link->keytype->owner &&
+	      module_is_coming(restrict_link->keytype->owner)) ||
+	     !try_module_get(restrict_link->keytype->owner))) {
+		key = ERR_PTR(-ENOENT);
+		goto out_put_module;
+	}
 
 	if (type->vet_description) {
 		ret = type->vet_description(desc);
 		if (ret < 0) {
 			key = ERR_PTR(ret);
-			goto error;
+			goto out_put_restrict_module;
 		}
 	}
 
 	desclen = strlen(desc);
 	if (desclen >= KEY_MAX_DESC_SIZE)
-		goto error;
+		goto out_put_restrict_module;
 	quotalen = desclen + 1 + type->def_datalen;
 
 	/* get hold of the key tracking for this user */
@@ -323,8 +339,6 @@ struct key *key_alloc(struct key_type *type, const char *desc,
 	refcount_inc(&key->domain_tag->usage);
 	atomic_inc(&user->nkeys);
 	key_alloc_serial(key);
-
-error:
 	return key;
 
 security_error:
@@ -338,7 +352,7 @@ struct key *key_alloc(struct key_type *type, const char *desc,
 	}
 	key_user_put(user);
 	key = ERR_PTR(ret);
-	goto error;
+	goto out_put_restrict_module;
 
 no_memory_3:
 	kmem_cache_free(key_jar, key);
@@ -352,13 +366,22 @@ struct key *key_alloc(struct key_type *type, const char *desc,
 	key_user_put(user);
 no_memory_1:
 	key = ERR_PTR(-ENOMEM);
-	goto error;
+	goto out_put_restrict_module;
 
 no_quota:
 	spin_unlock_irqrestore(&user->lock, irqflags);
 	key_user_put(user);
 	key = ERR_PTR(-EDQUOT);
-	goto error;
+
+out_put_restrict_module:
+	if (restrict_link && restrict_link->keytype)
+		module_put(restrict_link->keytype->owner);
+
+out_put_module:
+	module_put(type->owner);
+
+out:
+	return key;
 }
 EXPORT_SYMBOL(key_alloc);
 
@@ -1231,19 +1254,20 @@ int generic_key_instantiate(struct key *key, struct key_preparsed_payload *prep)
 EXPORT_SYMBOL(generic_key_instantiate);
 
 /**
- * register_key_type - Register a type of key.
+ * __register_key_type - Register a type of key.
  * @ktype: The new key type.
+ * @owner: Module owning the key type.
  *
  * Register a new key type.
  *
  * Returns 0 on success or -EEXIST if a type of this name already exists.
  */
-int register_key_type(struct key_type *ktype)
+int __register_key_type(struct key_type *ktype, struct module *owner)
 {
 	struct key_type *p;
 	int ret;
 
-	memset(&ktype->lock_class, 0, sizeof(ktype->lock_class));
+	ktype->owner = owner;
 
 	ret = -EEXIST;
 	down_write(&key_types_sem);
@@ -1264,7 +1288,7 @@ int register_key_type(struct key_type *ktype)
 	up_write(&key_types_sem);
 	return ret;
 }
-EXPORT_SYMBOL(register_key_type);
+EXPORT_SYMBOL(__register_key_type);
 
 /**
  * unregister_key_type - Unregister a type of key.
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 5281da9d5bf7..f90ab46ecfab 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -7,6 +7,7 @@
 
 #include <linux/export.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/security.h>
@@ -436,6 +437,9 @@ static void keyring_destroy(struct key *keyring)
 	if (keyring->restrict_link) {
 		struct key_restriction *keyres = keyring->restrict_link;
 
+		if (keyres->keytype)
+			module_put(keyres->keytype->owner);
+
 		key_put(keyres->key);
 		kfree(keyres);
 	}
@@ -540,6 +544,9 @@ struct key *keyring_alloc(const char *description, kuid_t uid, kgid_t gid,
 	if (!IS_ERR(keyring)) {
 		ret = key_instantiate_and_link(keyring, NULL, 0, dest, NULL);
 		if (ret < 0) {
+			if (restrict_link && restrict_link->keytype)
+				module_put(restrict_link->keytype->owner);
+			keyring->restrict_link = NULL;
 			key_put(keyring);
 			keyring = ERR_PTR(ret);
 		}
@@ -1062,7 +1069,7 @@ int keyring_restrict(key_ref_t keyring_ref, const char *type,
 
 		if (!restrict_type->lookup_restriction) {
 			ret = -ENOENT;
-			goto error;
+			goto out;
 		}
 
 		restrict_link = restrict_type->lookup_restriction(restriction);
@@ -1070,7 +1077,15 @@ int keyring_restrict(key_ref_t keyring_ref, const char *type,
 
 	if (IS_ERR(restrict_link)) {
 		ret = PTR_ERR(restrict_link);
-		goto error;
+		goto out;
+	}
+
+	if (restrict_link && restrict_link->keytype &&
+	    ((restrict_link->keytype->owner &&
+	      module_is_coming(restrict_link->keytype->owner)) ||
+	     !try_module_get(restrict_link->keytype->owner))) {
+		ret = -ENOENT;
+		goto out_free_restriction;
 	}
 
 	down_write(&keyring->sem);
@@ -1088,12 +1103,21 @@ int keyring_restrict(key_ref_t keyring_ref, const char *type,
 	up_write(&keyring_serialise_restrict_sem);
 	up_write(&keyring->sem);
 
-	if (ret < 0) {
+	if (ret < 0)
+		goto out_put_module;
+
+	goto out;
+
+out_put_module:
+	if (restrict_link && restrict_link->keytype)
+		module_put(restrict_link->keytype->owner);
+
+out_free_restriction:
+	if (restrict_link)
 		key_put(restrict_link->key);
-		kfree(restrict_link);
-	}
+	kfree(restrict_link);
 
-error:
+out:
 	if (restrict_type)
 		key_type_put(restrict_type);
 
-- 
2.47.3

