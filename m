Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840020;
	b=jjI+5Tgu9xw+r9mPnhtIT9b7BWB7793oBv5aFqTr/mharrvA5/+CutJtc+kiPdaFgNLh
	 nRKAFRu6RvLv3zcXoQlPk9LySjGK1Z2ipdL0CZu5dAe7hUQApJur1bweuysMRRnd1qfJ7
	 pi5/OKV+S8BHFy36sBKyZ7yFWdH4KoFP6pAFx78RkaUFHreJ/rZTy9UF/AB0ZsIL3S8Mh
	 AAtsuelwNyX8p6fwr25cCz58ZtRVDM3Vnun2DvtotmJVwuXcJhR9MQvS+f2Dl27/qaFIp
	 dRRYLtqo1Yys3ydQjHt/K2QHgyxsfAAogNDsMIXNfXr0iHtMYV3OLnCD5Gcm1RVgClg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840020;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=lkqe98CyLBgQ52rBxXU0ciHtvnWKRuThjgKaQZqo1VU=;
	b=Z3yYFB5u9dZjQvfNyCh/b6zL0sFWWF6eUywShEQBZvGF21zqiaxO1LzapvEC7OsDkL4R
	 kh32qc3M8njTfQ3C0SM/3GZqiXtuxqZE9jv4h35ibvBoq3RXlwRssxt0PHstTZWW9uJoN
	 5tuhf1fZz0TH4xb6FNjc1oJzNaaJUkijXNLDzZojw7ctvRYdcchN4c3JSDcHCXbUDBix3
	 lsyJuPwg4SpgDnXvULgvrLhgR+bVkFbliMI2QvyuJedPX1J/vSfgxTdgcqhU38vJtAI6O
	 SOrXGt9TAlDfxqVvDYV0AVT9t79SKWQgrO3m+XcdI2k5uHGUHDQFOWS7Cmu+FuMbtFA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nlA2Yq6X;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id BE1BD606EE9E;
	Thu,  5 Nov 2026 00:53:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nlA2Yq6X
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id E71531F00A16;
	Thu,  5 Nov 2026 00:53:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840019;
	bh=lkqe98CyLBgQ52rBxXU0ciHtvnWKRuThjgKaQZqo1VU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nlA2Yq6XEpov2xGMrjdcMIsZiCwjZIs39yI6qAqw7rUEg6UqdUaui6n6yWBUU/oRF
	 HBrzB8zFN4Gyz54LQK0jDusMFmiCja2dFdsmdEUWp1Idd+DoL2h+DDR340cOk4SzkM
	 9cod+lVUMm8MLtt9RCE2zLXOg0i/d4XpuyzjlM+UuxkJK/0rLuYaTV4u/0Jq962C0l
	 HW3J7Znftph+RS8pLgXokMPSINbcLolU88ykNSGazpYMFg3Z0lqMDP80CcgZu0R+TH
	 3trrUawXqwmilXk1YAFfLFg5WzpbmlkfRIYYVAeWZSzLOxkSQYT7YDX6+9YxooELYp
	 IH0Oaue8SJzeQ==
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
Subject: [RFC PATCH v3 05/11] s390/cert_store: Start tracking subsystem keys
Date: Thu,  5 Nov 2026 02:53:04 +0200
Message-ID: <20261105005311.804098-6-jarkko@kernel.org>
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

cert_store refreshes its keyring by unregistering and then registering
again key_type_cert_store_key. Once keys pin to the kernel module of their
key type, this is no longer necessary.

Register key_type_cert_store_key once during init before creating sysfs
attributes, and track subsystem-created keys explicitly so that the refresh
operationunlinks and invalidates previous entries directly.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 arch/s390/kernel/cert_store.c | 161 ++++++++++++++--------------------
 1 file changed, 67 insertions(+), 94 deletions(-)

diff --git a/arch/s390/kernel/cert_store.c b/arch/s390/kernel/cert_store.c
index 998f2da56175..ab1a78cdfd4c 100644
--- a/arch/s390/kernel/cert_store.c
+++ b/arch/s390/kernel/cert_store.c
@@ -17,6 +17,7 @@
 #include <linux/key.h>
 #include <linux/keyctl.h>
 #include <linux/kobject.h>
+#include <linux/list.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
@@ -296,6 +297,18 @@ static int check_certificate_valid(const struct vce *vce)
 	return check_certificate_hash(vce);
 }
 
+struct cert_store_key {
+	struct list_head list;
+	struct key *key;
+};
+
+static DEFINE_MUTEX(cs_refresh_lock);
+/* Owned references, protected by cs_refresh_lock. */
+static LIST_HEAD(cs_keys);
+static struct key *active_cs_keyring;
+static struct key *cs_keyring_parent;
+
+/* Return an owned reference to the user session keyring. */
 static struct key *get_user_session_keyring(void)
 {
 	key_ref_t us_keyring_ref;
@@ -305,118 +318,66 @@ static struct key *get_user_session_keyring(void)
 	if (IS_ERR(us_keyring_ref)) {
 		pr_dbf_msg("Couldn't get user session keyring: %ld",
 			   PTR_ERR(us_keyring_ref));
-		return ERR_PTR(-ENOKEY);
+		return ERR_CAST(us_keyring_ref);
 	}
-	key_ref_put(us_keyring_ref);
 	return key_ref_to_ptr(us_keyring_ref);
 }
 
-/* Invalidate all keys from cert_store keyring. */
-static int invalidate_keyring_keys(struct key *keyring)
-{
-	unsigned long num_keys, key_index;
-	size_t keyring_payload_len;
-	key_serial_t *key_array;
-	struct key *current_key;
-	int rc;
-
-	keyring_payload_len = key_type_keyring.read(keyring, NULL, 0);
-	num_keys = keyring_payload_len / sizeof(key_serial_t);
-	key_array = kzalloc_objs(key_serial_t, num_keys);
-	if (!key_array)
-		return -ENOMEM;
-
-	rc = key_type_keyring.read(keyring, (char *)key_array, keyring_payload_len);
-	if (rc != keyring_payload_len) {
-		pr_dbf_msg("Couldn't read keyring payload");
-		goto out;
-	}
-
-	for (key_index = 0; key_index < num_keys; key_index++) {
-		current_key = key_lookup(key_array[key_index]);
-		pr_dbf_msg("Invalidating key %08x", current_key->serial);
-
-		key_invalidate(current_key);
-		key_put(current_key);
-		rc = key_unlink(keyring, current_key);
-		if (rc) {
-			pr_dbf_msg("Couldn't unlink key %08x: %d", current_key->serial, rc);
-			break;
-		}
-	}
-out:
-	kfree(key_array);
-	return rc;
-}
-
-static struct key *find_cs_keyring(void)
-{
-	key_ref_t cs_keyring_ref;
-	struct key *cs_keyring;
-
-	cs_keyring_ref = keyring_search(make_key_ref(get_user_session_keyring(), true),
-					&key_type_keyring, CERT_STORE_KEYRING_NAME,
-					false);
-	if (!IS_ERR(cs_keyring_ref)) {
-		cs_keyring = key_ref_to_ptr(cs_keyring_ref);
-		key_ref_put(cs_keyring_ref);
-		goto found;
-	}
-	/* Search default locations: thread, process, session keyrings */
-	cs_keyring = request_key(&key_type_keyring, CERT_STORE_KEYRING_NAME, NULL);
-	if (IS_ERR(cs_keyring))
-		return NULL;
-	key_put(cs_keyring);
-found:
-	return cs_keyring;
-}
-
 static void cleanup_cs_keys(void)
 {
-	struct key *cs_keyring;
+	struct cert_store_key *entry, *tmp;
+	int rc;
 
-	cs_keyring = find_cs_keyring();
-	if (!cs_keyring)
+	if (!active_cs_keyring)
 		return;
 
-	pr_dbf_msg("Found cert_store keyring. Purging...");
-	/*
-	 * Remove cert_store_key_type in case invalidation
-	 * of old cert_store keys failed (= severe error).
-	 */
-	if (invalidate_keyring_keys(cs_keyring))
-		unregister_key_type(&key_type_cert_store_key);
+	/* Invalidate even certificates unlinked or linked into other keyrings. */
+	list_for_each_entry_safe(entry, tmp, &cs_keys, list) {
+		key_invalidate(entry->key);
+		key_put(entry->key);
+		list_del(&entry->list);
+		kfree(entry);
+	}
 
-	keyring_clear(cs_keyring);
-	key_invalidate(cs_keyring);
-	key_put(cs_keyring);
-	key_unlink(get_user_session_keyring(), cs_keyring);
+	rc = keyring_clear(active_cs_keyring);
+	if (rc)
+		pr_dbf_msg("Couldn't clear cert_store keyring: %d", rc);
+	key_invalidate(active_cs_keyring);
+	rc = key_unlink(cs_keyring_parent, active_cs_keyring);
+	if (rc)
+		pr_dbf_msg("Couldn't unlink cert_store keyring: %d", rc);
+	key_put(active_cs_keyring);
+	key_put(cs_keyring_parent);
+	active_cs_keyring = NULL;
+	cs_keyring_parent = NULL;
 }
 
+/* Return a borrowed reference; cleanup_cs_keys() owns the keyring. */
 static struct key *create_cs_keyring(void)
 {
-	static struct key *cs_keyring;
+	struct key *cs_keyring, *parent;
 
 	/* Cleanup previous cs_keyring and all associated keys if any. */
 	cleanup_cs_keys();
+	parent = get_user_session_keyring();
+	if (IS_ERR(parent))
+		return parent;
+
 	cs_keyring = keyring_alloc(CERT_STORE_KEYRING_NAME, GLOBAL_ROOT_UID,
 				   GLOBAL_ROOT_GID, current_cred(),
 				   (KEY_POS_ALL & ~KEY_POS_SETATTR) | KEY_USR_VIEW | KEY_USR_READ,
 				   KEY_ALLOC_NOT_IN_QUOTA | KEY_ALLOC_SET_KEEP,
-				   NULL, get_user_session_keyring());
+				   NULL, parent);
 	if (IS_ERR(cs_keyring)) {
 		pr_dbf_msg("Can't allocate cert_store keyring");
-		return NULL;
+		key_put(parent);
+		return cs_keyring;
 	}
 
+	active_cs_keyring = cs_keyring;
+	cs_keyring_parent = parent;
 	pr_dbf_msg("Successfully allocated cert_store keyring: %08x", cs_keyring->serial);
 
-	/*
-	 * In case a previous clean-up ran into an
-	 * error and unregistered key type.
-	 */
-	register_key_type(&key_type_cert_store_key);
-
 	return cs_keyring;
 }
 
@@ -454,6 +415,7 @@ static char *get_key_description(struct vcssb *vcssb, const struct vce *vce)
 static int create_key_from_vce(struct vcssb *vcssb, struct vce *vce,
 			       struct key *keyring)
 {
+	struct cert_store_key *entry;
 	key_ref_t newkey;
 	char *desc;
 	int rc;
@@ -462,6 +424,13 @@ static int create_key_from_vce(struct vcssb *vcssb, struct vce *vce,
 	if (!desc)
 		return -ENOMEM;
 
+	/* Reserve cleanup tracking before the key can be linked elsewhere. */
+	entry = kmalloc_obj(*entry);
+	if (!entry) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
 	newkey = key_create_or_update(
 		make_key_ref(keyring, true), CERT_STORE_KEY_TYPE_NAME,
 		desc, (u8 *)vce + vce->vce_hdr.vc_offset,
@@ -473,10 +442,12 @@ static int create_key_from_vce(struct vcssb *vcssb, struct vce *vce,
 	if (rc) {
 		pr_dbf_msg("Couldn't create a key from Certificate Entry (%d)", rc);
 		rc = -ENOKEY;
+		kfree(entry);
 		goto out;
 	}
 
-	key_ref_put(newkey);
+	entry->key = key_ref_to_ptr(newkey);
+	list_add_tail(&entry->list, &cs_keys);
 out:
 	kfree(desc);
 	return rc;
@@ -704,19 +675,18 @@ static int fill_cs_keyring(void)
 	if (rc)
 		goto cleanup_keys;
 
-	rc = -ENOMEM;
 	cs_keyring = create_cs_keyring();
-	if (!cs_keyring)
+	if (IS_ERR(cs_keyring)) {
+		rc = PTR_ERR(cs_keyring);
 		goto cleanup_keys;
+	}
 
 	rc = add_certificates_to_keyring(vcssb, cs_keyring);
 	if (rc)
-		goto cleanup_cs_keyring;
+		goto cleanup_keys;
 
 	goto out;
 
-cleanup_cs_keyring:
-	key_put(cs_keyring);
 cleanup_keys:
 	cleanup_cs_keys();
 out:
@@ -724,7 +694,6 @@ static int fill_cs_keyring(void)
 	return rc;
 }
 
-static DEFINE_MUTEX(cs_refresh_lock);
 static int cs_status_val = -1;
 
 static ssize_t cs_status_show(struct kobject *kobj,
@@ -794,14 +763,18 @@ static int __init cert_store_init(void)
 	if (!cert_store_kobj)
 		goto cleanup_dbf;
 
-	rc = sysfs_create_files(cert_store_kobj, cert_store_attrs);
+	rc = register_key_type(&key_type_cert_store_key);
 	if (rc)
 		goto cleanup_kobj;
 
-	register_key_type(&key_type_cert_store_key);
+	rc = sysfs_create_files(cert_store_kobj, cert_store_attrs);
+	if (rc)
+		goto cleanup_key_type;
 
 	return rc;
 
+cleanup_key_type:
+	unregister_key_type(&key_type_cert_store_key);
 cleanup_kobj:
 	kobject_put(cert_store_kobj);
 cleanup_dbf:
-- 
2.47.3

