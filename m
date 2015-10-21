Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731AbbJUO1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2015 10:27:39 -0400
Subject: [PATCH 6/6] KEYS: Merge the type-specific data with the payload data
From: David Howells <dhowells@redhat.com>
To: keyrings@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ecryptfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-ima-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Date: Wed, 21 Oct 2015 15:27:32 +0100
Message-ID: <20151021142732.31251.48751.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151021142646.31251.6867.stgit@warthog.procyon.org.uk>
References: <20151021142646.31251.6867.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merge the type-specific data with the payload data into one four-word chunk
as it seems pointless to keep them separate.

Use user_key_payload() for accessing the payloads of overloaded
user-defined keys.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: linux-cifs@vger.kernel.org
cc: ecryptfs@vger.kernel.org
cc: linux-ext4@vger.kernel.org
cc: linux-f2fs-devel@lists.sourceforge.net
cc: linux-nfs@vger.kernel.org
cc: ceph-devel@vger.kernel.org
cc: linux-ima-devel@lists.sourceforge.net
---

 Documentation/crypto/asymmetric-keys.txt         |   27 +++++++------
 Documentation/security/keys.txt                  |   41 ++++++++++++-------
 crypto/asymmetric_keys/asymmetric_keys.h         |    5 --
 crypto/asymmetric_keys/asymmetric_type.c         |   44 ++++++++++++---------
 crypto/asymmetric_keys/public_key.c              |    4 +-
 crypto/asymmetric_keys/signature.c               |    2 -
 crypto/asymmetric_keys/x509_parser.h             |    1 
 crypto/asymmetric_keys/x509_public_key.c         |    9 ++--
 fs/cifs/cifs_spnego.c                            |    6 +--
 fs/cifs/cifsacl.c                                |   25 ++++++------
 fs/cifs/connect.c                                |    9 ++--
 fs/cifs/sess.c                                   |    2 -
 fs/cifs/smb2pdu.c                                |    2 -
 fs/ecryptfs/ecryptfs_kernel.h                    |    5 +-
 fs/ext4/crypto_key.c                             |    4 +-
 fs/f2fs/crypto_key.c                             |    4 +-
 fs/fscache/object-list.c                         |    4 +-
 fs/nfs/nfs4idmap.c                               |    4 +-
 include/crypto/public_key.h                      |    1 
 include/keys/asymmetric-subtype.h                |    2 -
 include/keys/asymmetric-type.h                   |   15 +++++++
 include/keys/user-type.h                         |    8 ++++
 include/linux/key-type.h                         |    3 -
 include/linux/key.h                              |   33 +++++++--------
 kernel/module_signing.c                          |    1 
 lib/digsig.c                                     |    7 ++-
 net/ceph/ceph_common.c                           |    2 -
 net/ceph/crypto.c                                |    6 +--
 net/dns_resolver/dns_key.c                       |   20 +++++----
 net/dns_resolver/dns_query.c                     |    7 +--
 net/dns_resolver/internal.h                      |    8 ++++
 net/rxrpc/af_rxrpc.c                             |    2 -
 net/rxrpc/ar-key.c                               |   32 +++++++--------
 net/rxrpc/ar-output.c                            |    2 -
 net/rxrpc/ar-security.c                          |    4 +-
 net/rxrpc/rxkad.c                                |   16 ++++---
 security/integrity/evm/evm_crypto.c              |    2 -
 security/keys/big_key.c                          |   47 +++++++++++++++-------
 security/keys/encrypted-keys/encrypted.c         |   18 ++++----
 security/keys/encrypted-keys/encrypted.h         |    4 +-
 security/keys/encrypted-keys/masterkey_trusted.c |    4 +-
 security/keys/key.c                              |   18 ++++----
 security/keys/keyctl.c                           |    4 +-
 security/keys/keyring.c                          |   12 +++---
 security/keys/process_keys.c                     |    4 +-
 security/keys/request_key.c                      |    4 +-
 security/keys/request_key_auth.c                 |   12 +++---
 security/keys/trusted.c                          |    6 +--
 security/keys/user_defined.c                     |   14 +++----
 49 files changed, 286 insertions(+), 230 deletions(-)

diff --git a/Documentation/crypto/asymmetric-keys.txt b/Documentation/crypto/asymmetric-keys.txt
index b7675904a747..8c07e0ea6bc0 100644
--- a/Documentation/crypto/asymmetric-keys.txt
+++ b/Documentation/crypto/asymmetric-keys.txt
@@ -186,7 +186,7 @@ and looks like the following:
 					const struct public_key_signature *sig);
 	};
 
-Asymmetric keys point to this with their type_data[0] member.
+Asymmetric keys point to this with their payload[asym_subtype] member.
 
 The owner and name fields should be set to the owning module and the name of
 the subtype.  Currently, the name is only used for print statements.
@@ -269,8 +269,7 @@ mandatory:
 
 	struct key_preparsed_payload {
 		char		*description;
-		void		*type_data[2];
-		void		*payload;
+		void		*payload[4];
 		const void	*data;
 		size_t		datalen;
 		size_t		quotalen;
@@ -283,16 +282,18 @@ mandatory:
      not theirs.
 
      If the parser is happy with the blob, it should propose a description for
-     the key and attach it to ->description, ->type_data[0] should be set to
-     point to the subtype to be used, ->payload should be set to point to the
-     initialised data for that subtype, ->type_data[1] should point to a hex
-     fingerprint and quotalen should be updated to indicate how much quota this
-     key should account for.
-
-     When clearing up, the data attached to ->type_data[1] and ->description
-     will be kfree()'d and the data attached to ->payload will be passed to the
-     subtype's ->destroy() method to be disposed of.  A module reference for
-     the subtype pointed to by ->type_data[0] will be put.
+     the key and attach it to ->description, ->payload[asym_subtype] should be
+     set to point to the subtype to be used, ->payload[asym_crypto] should be
+     set to point to the initialised data for that subtype,
+     ->payload[asym_key_ids] should point to one or more hex fingerprints and
+     quotalen should be updated to indicate how much quota this key should
+     account for.
+
+     When clearing up, the data attached to ->payload[asym_key_ids] and
+     ->description will be kfree()'d and the data attached to
+     ->payload[asm_crypto] will be passed to the subtype's ->destroy() method
+     to be disposed of.  A module reference for the subtype pointed to by
+     ->payload[asym_subtype] will be put.
 
 
      If the data format is not recognised, -EBADMSG should be returned.  If it
diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index c9e7f4f223a5..8c183873b2b7 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -1049,12 +1049,12 @@ search a specific keyring, so using keyrings in this way is of limited utility.
 NOTES ON ACCESSING PAYLOAD CONTENTS
 ===================================
 
-The simplest payload is just a number in key->payload.value. In this case,
-there's no need to indulge in RCU or locking when accessing the payload.
+The simplest payload is just data stored in key->payload directly.  In this
+case, there's no need to indulge in RCU or locking when accessing the payload.
 
-More complex payload contents must be allocated and a pointer to them set in
-key->payload.data. One of the following ways must be selected to access the
-data:
+More complex payload contents must be allocated and pointers to them set in the
+key->payload.data[] array.  One of the following ways must be selected to
+access the data:
 
  (1) Unmodifiable key type.
 
@@ -1092,6 +1092,13 @@ data:
      the payload. key->datalen cannot be relied upon to be consistent with the
      payload just dereferenced if the key's semaphore is not held.
 
+     Note that key->payload.data[0] has a shadow that is marked for __rcu
+     usage.  This is called key->payload.rcu_data0.  The following accessors
+     wrap the RCU calls to this element:
+
+	rcu_assign_keypointer(struct key *key, void *data);
+	void *rcu_dereference_key(struct key *key);
+
 
 ===================
 DEFINING A KEY TYPE
@@ -1143,8 +1150,7 @@ The structure has a number of fields, some of which are mandatory:
 
 	struct key_preparsed_payload {
 		char		*description;
-		void		*type_data[2];
-		void		*payload;
+		union key_payload payload;
 		const void	*data;
 		size_t		datalen;
 		size_t		quotalen;
@@ -1160,10 +1166,9 @@ The structure has a number of fields, some of which are mandatory:
      attached as a string to the description field.  This will be used for the
      key description if the caller of add_key() passes NULL or "".
 
-     The method can attach anything it likes to type_data[] and payload.  These
-     are merely passed along to the instantiate() or update() operations.  If
-     set, the expiry time will be applied to the key if it is instantiated from
-     this data.
+     The method can attach anything it likes to payload.  This is merely passed
+     along to the instantiate() or update() operations.  If set, the expiry
+     time will be applied to the key if it is instantiated from this data.
 
      The method should return 0 if successful or a negative error code
      otherwise.
@@ -1172,11 +1177,10 @@ The structure has a number of fields, some of which are mandatory:
  (*) void (*free_preparse)(struct key_preparsed_payload *prep);
 
      This method is only required if the preparse() method is provided,
-     otherwise it is unused.  It cleans up anything attached to the
-     description, type_data and payload fields of the key_preparsed_payload
-     struct as filled in by the preparse() method.  It will always be called
-     after preparse() returns successfully, even if instantiate() or update()
-     succeed.
+     otherwise it is unused.  It cleans up anything attached to the description
+     and payload fields of the key_preparsed_payload struct as filled in by the
+     preparse() method.  It will always be called after preparse() returns
+     successfully, even if instantiate() or update() succeed.
 
 
  (*) int (*instantiate)(struct key *key, struct key_preparsed_payload *prep);
@@ -1197,6 +1201,11 @@ The structure has a number of fields, some of which are mandatory:
 
      It is safe to sleep in this method.
 
+     generic_key_instantiate() is provided to simply copy the data from
+     prep->payload.data[] to key->payload.data[], with RCU-safe assignment on
+     the first element.  It will then clear prep->payload.data[] so that the
+     free_preparse method doesn't release the data.
+
 
  (*) int (*update)(struct key *key, const void *data, size_t datalen);
 
diff --git a/crypto/asymmetric_keys/asymmetric_keys.h b/crypto/asymmetric_keys/asymmetric_keys.h
index 3f5b537ab33e..1d450b580245 100644
--- a/crypto/asymmetric_keys/asymmetric_keys.h
+++ b/crypto/asymmetric_keys/asymmetric_keys.h
@@ -14,8 +14,3 @@ extern struct asymmetric_key_id *asymmetric_key_hex_to_key_id(const char *id);
 extern int __asymmetric_key_hex_to_key_id(const char *id,
 					  struct asymmetric_key_id *match_id,
 					  size_t hexlen);
-static inline
-const struct asymmetric_key_ids *asymmetric_key_ids(const struct key *key)
-{
-	return key->type_data.p[1];
-}
diff --git a/crypto/asymmetric_keys/asymmetric_type.c b/crypto/asymmetric_keys/asymmetric_type.c
index 1916680ad81b..9f2165b27d52 100644
--- a/crypto/asymmetric_keys/asymmetric_type.c
+++ b/crypto/asymmetric_keys/asymmetric_type.c
@@ -307,25 +307,34 @@ static int asymmetric_key_preparse(struct key_preparsed_payload *prep)
 }
 
 /*
+ * Clean up the key ID list
+ */
+static void asymmetric_key_free_kids(struct asymmetric_key_ids *kids)
+{
+	int i;
+
+	if (kids) {
+		for (i = 0; i < ARRAY_SIZE(kids->id); i++)
+			kfree(kids->id[i]);
+		kfree(kids);
+	}
+}
+
+/*
  * Clean up the preparse data
  */
 static void asymmetric_key_free_preparse(struct key_preparsed_payload *prep)
 {
-	struct asymmetric_key_subtype *subtype = prep->type_data[0];
-	struct asymmetric_key_ids *kids = prep->type_data[1];
-	int i;
+	struct asymmetric_key_subtype *subtype = prep->payload.data[asym_subtype];
+	struct asymmetric_key_ids *kids = prep->payload.data[asym_key_ids];
 
 	pr_devel("==>%s()\n", __func__);
 
 	if (subtype) {
-		subtype->destroy(prep->payload[0]);
+		subtype->destroy(prep->payload.data[asym_crypto]);
 		module_put(subtype->owner);
 	}
-	if (kids) {
-		for (i = 0; i < ARRAY_SIZE(kids->id); i++)
-			kfree(kids->id[i]);
-		kfree(kids);
-	}
+	asymmetric_key_free_kids(kids);
 	kfree(prep->description);
 }
 
@@ -335,20 +344,19 @@ static void asymmetric_key_free_preparse(struct key_preparsed_payload *prep)
 static void asymmetric_key_destroy(struct key *key)
 {
 	struct asymmetric_key_subtype *subtype = asymmetric_key_subtype(key);
-	struct asymmetric_key_ids *kids = key->type_data.p[1];
+	struct asymmetric_key_ids *kids = key->payload.data[asym_key_ids];
+	void *data = key->payload.data[asym_crypto];
+
+	key->payload.data[asym_crypto] = NULL;
+	key->payload.data[asym_subtype] = NULL;
+	key->payload.data[asym_key_ids] = NULL;
 
 	if (subtype) {
-		subtype->destroy(key->payload.data);
+		subtype->destroy(data);
 		module_put(subtype->owner);
-		key->type_data.p[0] = NULL;
 	}
 
-	if (kids) {
-		kfree(kids->id[0]);
-		kfree(kids->id[1]);
-		kfree(kids);
-		key->type_data.p[1] = NULL;
-	}
+	asymmetric_key_free_kids(kids);
 }
 
 struct key_type key_type_asymmetric = {
diff --git a/crypto/asymmetric_keys/public_key.c b/crypto/asymmetric_keys/public_key.c
index 81efccbe22d5..6db4c01c6503 100644
--- a/crypto/asymmetric_keys/public_key.c
+++ b/crypto/asymmetric_keys/public_key.c
@@ -49,7 +49,7 @@ EXPORT_SYMBOL_GPL(pkey_id_type_name);
 static void public_key_describe(const struct key *asymmetric_key,
 				struct seq_file *m)
 {
-	struct public_key *key = asymmetric_key->payload.data;
+	struct public_key *key = asymmetric_key->payload.data[asym_crypto];
 
 	if (key)
 		seq_printf(m, "%s.%s",
@@ -112,7 +112,7 @@ EXPORT_SYMBOL_GPL(public_key_verify_signature);
 static int public_key_verify_signature_2(const struct key *key,
 					 const struct public_key_signature *sig)
 {
-	const struct public_key *pk = key->payload.data;
+	const struct public_key *pk = key->payload.data[asym_crypto];
 	return public_key_verify_signature(pk, sig);
 }
 
diff --git a/crypto/asymmetric_keys/signature.c b/crypto/asymmetric_keys/signature.c
index 7525fd183574..9441240f7d2a 100644
--- a/crypto/asymmetric_keys/signature.c
+++ b/crypto/asymmetric_keys/signature.c
@@ -37,7 +37,7 @@ int verify_signature(const struct key *key,
 		return -EINVAL;
 	subtype = asymmetric_key_subtype(key);
 	if (!subtype ||
-	    !key->payload.data)
+	    !key->payload.data[0])
 		return -EINVAL;
 	if (!subtype->verify_signature)
 		return -ENOTSUPP;
diff --git a/crypto/asymmetric_keys/x509_parser.h b/crypto/asymmetric_keys/x509_parser.h
index 1de01eaec884..dbeed6018e63 100644
--- a/crypto/asymmetric_keys/x509_parser.h
+++ b/crypto/asymmetric_keys/x509_parser.h
@@ -11,6 +11,7 @@
 
 #include <linux/time.h>
 #include <crypto/public_key.h>
+#include <keys/asymmetric-type.h>
 
 struct x509_certificate {
 	struct x509_certificate *next;
diff --git a/crypto/asymmetric_keys/x509_public_key.c b/crypto/asymmetric_keys/x509_public_key.c
index 197096632412..64d42981a8d7 100644
--- a/crypto/asymmetric_keys/x509_public_key.c
+++ b/crypto/asymmetric_keys/x509_public_key.c
@@ -266,7 +266,8 @@ static int x509_validate_trust(struct x509_certificate *cert,
 	if (!IS_ERR(key))  {
 		if (!use_builtin_keys
 		    || test_bit(KEY_FLAG_BUILTIN, &key->flags))
-			ret = x509_check_signature(key->payload.data, cert);
+			ret = x509_check_signature(key->payload.data[asym_crypto],
+						   cert);
 		key_put(key);
 	}
 	return ret;
@@ -352,9 +353,9 @@ static int x509_key_preparse(struct key_preparsed_payload *prep)
 
 	/* We're pinning the module by being linked against it */
 	__module_get(public_key_subtype.owner);
-	prep->type_data[0] = &public_key_subtype;
-	prep->type_data[1] = kids;
-	prep->payload[0] = cert->pub;
+	prep->payload.data[asym_subtype] = &public_key_subtype;
+	prep->payload.data[asym_key_ids] = kids;
+	prep->payload.data[asym_crypto] = cert->pub;
 	prep->description = desc;
 	prep->quotalen = 100;
 
diff --git a/fs/cifs/cifs_spnego.c b/fs/cifs/cifs_spnego.c
index f4cf200b3c76..6908080e9b6d 100644
--- a/fs/cifs/cifs_spnego.c
+++ b/fs/cifs/cifs_spnego.c
@@ -42,7 +42,7 @@ cifs_spnego_key_instantiate(struct key *key, struct key_preparsed_payload *prep)
 		goto error;
 
 	/* attach the data */
-	key->payload.data = payload;
+	key->payload.data[0] = payload;
 	ret = 0;
 
 error:
@@ -52,7 +52,7 @@ error:
 static void
 cifs_spnego_key_destroy(struct key *key)
 {
-	kfree(key->payload.data);
+	kfree(key->payload.data[0]);
 }
 
 
@@ -167,7 +167,7 @@ cifs_get_spnego_key(struct cifs_ses *sesInfo)
 
 #ifdef CONFIG_CIFS_DEBUG2
 	if (cifsFYI && !IS_ERR(spnego_key)) {
-		struct cifs_spnego_msg *msg = spnego_key->payload.data;
+		struct cifs_spnego_msg *msg = spnego_key->payload.data[0];
 		cifs_dump_mem("SPNEGO reply blob:", msg->data, min(1024U,
 				msg->secblob_len + msg->sesskey_len));
 	}
diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index 1ea780bc6376..3f93125916bf 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -58,16 +58,15 @@ cifs_idmap_key_instantiate(struct key *key, struct key_preparsed_payload *prep)
 	 * dereference payload.data!
 	 */
 	if (prep->datalen <= sizeof(key->payload)) {
-		key->payload.value = 0;
-		memcpy(&key->payload.value, prep->data, prep->datalen);
-		key->datalen = prep->datalen;
-		return 0;
+		key->payload.data[0] = NULL;
+		memcpy(&key->payload, prep->data, prep->datalen);
+	} else {
+		payload = kmemdup(prep->data, prep->datalen, GFP_KERNEL);
+		if (!payload)
+			return -ENOMEM;
+		key->payload.data[0] = payload;
 	}
-	payload = kmemdup(prep->data, prep->datalen, GFP_KERNEL);
-	if (!payload)
-		return -ENOMEM;
 
-	key->payload.data = payload;
 	key->datalen = prep->datalen;
 	return 0;
 }
@@ -76,7 +75,7 @@ static inline void
 cifs_idmap_key_destroy(struct key *key)
 {
 	if (key->datalen > sizeof(key->payload))
-		kfree(key->payload.data);
+		kfree(key->payload.data[0]);
 }
 
 static struct key_type cifs_idmap_key_type = {
@@ -233,8 +232,8 @@ id_to_sid(unsigned int cid, uint sidtype, struct cifs_sid *ssid)
 	 * it could be.
 	 */
 	ksid = sidkey->datalen <= sizeof(sidkey->payload) ?
-		(struct cifs_sid *)&sidkey->payload.value :
-		(struct cifs_sid *)sidkey->payload.data;
+		(struct cifs_sid *)&sidkey->payload :
+		(struct cifs_sid *)sidkey->payload.data[0];
 
 	ksid_size = CIFS_SID_BASE_SIZE + (ksid->num_subauth * sizeof(__le32));
 	if (ksid_size > sidkey->datalen) {
@@ -307,14 +306,14 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct cifs_sid *psid,
 	if (sidtype == SIDOWNER) {
 		kuid_t uid;
 		uid_t id;
-		memcpy(&id, &sidkey->payload.value, sizeof(uid_t));
+		memcpy(&id, &sidkey->payload.data[0], sizeof(uid_t));
 		uid = make_kuid(&init_user_ns, id);
 		if (uid_valid(uid))
 			fuid = uid;
 	} else {
 		kgid_t gid;
 		gid_t id;
-		memcpy(&id, &sidkey->payload.value, sizeof(gid_t));
+		memcpy(&id, &sidkey->payload.data[0], sizeof(gid_t));
 		gid = make_kgid(&init_user_ns, id);
 		if (gid_valid(gid))
 			fgid = gid;
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 773f4dc77630..3f2228570d44 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2325,13 +2325,14 @@ static int
 cifs_set_cifscreds(struct smb_vol *vol, struct cifs_ses *ses)
 {
 	int rc = 0;
-	char *desc, *delim, *payload;
+	const char *delim, *payload;
+	char *desc;
 	ssize_t len;
 	struct key *key;
 	struct TCP_Server_Info *server = ses->server;
 	struct sockaddr_in *sa;
 	struct sockaddr_in6 *sa6;
-	struct user_key_payload *upayload;
+	const struct user_key_payload *upayload;
 
 	desc = kmalloc(CIFSCREDS_DESC_SIZE, GFP_KERNEL);
 	if (!desc)
@@ -2374,14 +2375,14 @@ cifs_set_cifscreds(struct smb_vol *vol, struct cifs_ses *ses)
 	}
 
 	down_read(&key->sem);
-	upayload = key->payload.data;
+	upayload = user_key_payload(key);
 	if (IS_ERR_OR_NULL(upayload)) {
 		rc = upayload ? PTR_ERR(upayload) : -EINVAL;
 		goto out_key_put;
 	}
 
 	/* find first : in payload */
-	payload = (char *)upayload->data;
+	payload = upayload->data;
 	delim = strnchr(payload, upayload->datalen, ':');
 	cifs_dbg(FYI, "payload=%s\n", payload);
 	if (!delim) {
diff --git a/fs/cifs/sess.c b/fs/cifs/sess.c
index bce6fdcd5d48..59727e32ed0f 100644
--- a/fs/cifs/sess.c
+++ b/fs/cifs/sess.c
@@ -988,7 +988,7 @@ sess_auth_kerberos(struct sess_data *sess_data)
 		goto out;
 	}
 
-	msg = spnego_key->payload.data;
+	msg = spnego_key->payload.data[0];
 	/*
 	 * check version field to make sure that cifs.upcall is
 	 * sending us a response in an expected form
diff --git a/fs/cifs/smb2pdu.c b/fs/cifs/smb2pdu.c
index ce83e2edbe0a..52d14c9cf052 100644
--- a/fs/cifs/smb2pdu.c
+++ b/fs/cifs/smb2pdu.c
@@ -660,7 +660,7 @@ ssetup_ntlmssp_authenticate:
 			goto ssetup_exit;
 		}
 
-		msg = spnego_key->payload.data;
+		msg = spnego_key->payload.data[0];
 		/*
 		 * check version field to make sure that cifs.upcall is
 		 * sending us a response in an expected form
diff --git a/fs/ecryptfs/ecryptfs_kernel.h b/fs/ecryptfs/ecryptfs_kernel.h
index 5ba029e627cc..7b39260c7bba 100644
--- a/fs/ecryptfs/ecryptfs_kernel.h
+++ b/fs/ecryptfs/ecryptfs_kernel.h
@@ -86,7 +86,7 @@ ecryptfs_get_encrypted_key_payload_data(struct key *key)
 {
 	if (key->type == &key_type_encrypted)
 		return (struct ecryptfs_auth_tok *)
-			(&((struct encrypted_key_payload *)key->payload.data)->payload_data);
+			(&((struct encrypted_key_payload *)key->payload.data[0])->payload_data);
 	else
 		return NULL;
 }
@@ -117,8 +117,7 @@ ecryptfs_get_key_payload_data(struct key *key)
 
 	auth_tok = ecryptfs_get_encrypted_key_payload_data(key);
 	if (!auth_tok)
-		return (struct ecryptfs_auth_tok *)
-			(((struct user_key_payload *)key->payload.data)->data);
+		return (struct ecryptfs_auth_tok *)user_key_payload(key)->data;
 	else
 		return auth_tok;
 }
diff --git a/fs/ext4/crypto_key.c b/fs/ext4/crypto_key.c
index 1d510c11b100..5c52c79dea46 100644
--- a/fs/ext4/crypto_key.c
+++ b/fs/ext4/crypto_key.c
@@ -121,7 +121,7 @@ int _ext4_get_encryption_info(struct inode *inode)
 	struct key *keyring_key = NULL;
 	struct ext4_encryption_key *master_key;
 	struct ext4_encryption_context ctx;
-	struct user_key_payload *ukp;
+	const struct user_key_payload *ukp;
 	struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
 	struct crypto_ablkcipher *ctfm;
 	const char *cipher_str;
@@ -209,7 +209,7 @@ retry:
 	}
 	crypt_info->ci_keyring_key = keyring_key;
 	BUG_ON(keyring_key->type != &key_type_logon);
-	ukp = ((struct user_key_payload *)keyring_key->payload.data);
+	ukp = user_key_payload(keyring_key);
 	if (ukp->datalen != sizeof(struct ext4_encryption_key)) {
 		res = -EINVAL;
 		goto out;
diff --git a/fs/f2fs/crypto_key.c b/fs/f2fs/crypto_key.c
index 9f77de2ef317..5de2d866a25c 100644
--- a/fs/f2fs/crypto_key.c
+++ b/fs/f2fs/crypto_key.c
@@ -122,7 +122,7 @@ int _f2fs_get_encryption_info(struct inode *inode)
 	struct key *keyring_key = NULL;
 	struct f2fs_encryption_key *master_key;
 	struct f2fs_encryption_context ctx;
-	struct user_key_payload *ukp;
+	const struct user_key_payload *ukp;
 	struct crypto_ablkcipher *ctfm;
 	const char *cipher_str;
 	char raw_key[F2FS_MAX_KEY_SIZE];
@@ -199,7 +199,7 @@ retry:
 	}
 	crypt_info->ci_keyring_key = keyring_key;
 	BUG_ON(keyring_key->type != &key_type_logon);
-	ukp = ((struct user_key_payload *)keyring_key->payload.data);
+	ukp = user_key_payload(keyring_key);
 	if (ukp->datalen != sizeof(struct f2fs_encryption_key)) {
 		res = -EINVAL;
 		goto out;
diff --git a/fs/fscache/object-list.c b/fs/fscache/object-list.c
index 51dde817e1f2..6b028b7c4250 100644
--- a/fs/fscache/object-list.c
+++ b/fs/fscache/object-list.c
@@ -316,7 +316,7 @@ static const struct seq_operations fscache_objlist_ops = {
 static void fscache_objlist_config(struct fscache_objlist_data *data)
 {
 #ifdef CONFIG_KEYS
-	struct user_key_payload *confkey;
+	const struct user_key_payload *confkey;
 	unsigned long config;
 	struct key *key;
 	const char *buf;
@@ -329,7 +329,7 @@ static void fscache_objlist_config(struct fscache_objlist_data *data)
 	config = 0;
 	rcu_read_lock();
 
-	confkey = key->payload.data;
+	confkey = user_key_payload(key);
 	buf = confkey->data;
 
 	for (len = confkey->datalen - 1; len >= 0; len--) {
diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index 2e4902203c35..5ba22c6b0ffa 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -297,7 +297,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 {
 	const struct cred *saved_cred;
 	struct key *rkey;
-	struct user_key_payload *payload;
+	const struct user_key_payload *payload;
 	ssize_t ret;
 
 	saved_cred = override_creds(id_resolver_cache);
@@ -316,7 +316,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 	if (ret < 0)
 		goto out_up;
 
-	payload = rcu_dereference(rkey->payload.rcudata);
+	payload = user_key_payload(rkey);
 	if (IS_ERR_OR_NULL(payload)) {
 		ret = PTR_ERR(payload);
 		goto out_up;
diff --git a/include/crypto/public_key.h b/include/crypto/public_key.h
index 067c242b1e15..cc2516df0efa 100644
--- a/include/crypto/public_key.h
+++ b/include/crypto/public_key.h
@@ -15,7 +15,6 @@
 #define _LINUX_PUBLIC_KEY_H
 
 #include <linux/mpi.h>
-#include <keys/asymmetric-type.h>
 #include <crypto/hash_info.h>
 
 enum pkey_algo {
diff --git a/include/keys/asymmetric-subtype.h b/include/keys/asymmetric-subtype.h
index 4b840e822209..4915d40d3c3c 100644
--- a/include/keys/asymmetric-subtype.h
+++ b/include/keys/asymmetric-subtype.h
@@ -49,7 +49,7 @@ struct asymmetric_key_subtype {
 static inline
 struct asymmetric_key_subtype *asymmetric_key_subtype(const struct key *key)
 {
-	return key->type_data.p[0];
+	return key->payload.data[asym_subtype];
 }
 
 #endif /* _KEYS_ASYMMETRIC_SUBTYPE_H */
diff --git a/include/keys/asymmetric-type.h b/include/keys/asymmetric-type.h
index c0754abb2f56..59c1df9cf922 100644
--- a/include/keys/asymmetric-type.h
+++ b/include/keys/asymmetric-type.h
@@ -19,6 +19,16 @@
 extern struct key_type key_type_asymmetric;
 
 /*
+ * The key payload is four words.  The asymmetric-type key uses them as
+ * follows:
+ */
+enum asymmetric_payload_bits {
+	asym_crypto,
+	asym_subtype,
+	asym_key_ids,
+};
+
+/*
  * Identifiers for an asymmetric key ID.  We have three ways of looking up a
  * key derived from an X.509 certificate:
  *
@@ -58,6 +68,11 @@ extern struct asymmetric_key_id *asymmetric_key_generate_id(const void *val_1,
 							    size_t len_1,
 							    const void *val_2,
 							    size_t len_2);
+static inline
+const struct asymmetric_key_ids *asymmetric_key_ids(const struct key *key)
+{
+	return key->payload.data[asym_key_ids];
+}
 
 /*
  * The payload is at the discretion of the subtype.
diff --git a/include/keys/user-type.h b/include/keys/user-type.h
index cebefb069c44..c56fef40f53e 100644
--- a/include/keys/user-type.h
+++ b/include/keys/user-type.h
@@ -15,6 +15,8 @@
 #include <linux/key.h>
 #include <linux/rcupdate.h>
 
+#ifdef CONFIG_KEYS
+
 /*****************************************************************************/
 /*
  * the payload for a key of type "user" or "logon"
@@ -46,5 +48,11 @@ extern void user_describe(const struct key *user, struct seq_file *m);
 extern long user_read(const struct key *key,
 		      char __user *buffer, size_t buflen);
 
+static inline const struct user_key_payload *user_key_payload(const struct key *key)
+{
+	return (struct user_key_payload *)rcu_dereference_key(key);
+}
+
+#endif /* CONFIG_KEYS */
 
 #endif /* _KEYS_USER_TYPE_H */
diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index ff9f1d394235..7463355a198b 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -40,8 +40,7 @@ struct key_construction {
  */
 struct key_preparsed_payload {
 	char		*description;	/* Proposed key description (or NULL) */
-	void		*type_data[2];	/* Private key-type data */
-	void		*payload[2];	/* Proposed payload */
+	union key_payload payload;	/* Proposed payload */
 	const void	*data;		/* Raw data */
 	size_t		datalen;	/* Raw datalen */
 	size_t		quotalen;	/* Quota length for proposed payload */
diff --git a/include/linux/key.h b/include/linux/key.h
index e1d4715f3222..66f705243985 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -89,6 +89,11 @@ struct keyring_index_key {
 	size_t			desc_len;
 };
 
+union key_payload {
+	void __rcu		*rcu_data0;
+	void			*data[4];
+};
+
 /*****************************************************************************/
 /*
  * key reference with possession attribute handling
@@ -186,28 +191,18 @@ struct key {
 		};
 	};
 
-	/* type specific data
-	 * - this is used by the keyring type to index the name
-	 */
-	union {
-		struct list_head	link;
-		unsigned long		x[2];
-		void			*p[2];
-		int			reject_error;
-	} type_data;
-
 	/* key data
 	 * - this is used to hold the data actually used in cryptography or
 	 *   whatever
 	 */
 	union {
-		union {
-			unsigned long		value;
-			void __rcu		*rcudata;
-			void			*data;
-			void			*data2[2];
-		} payload;
-		struct assoc_array keys;
+		union key_payload payload;
+		struct {
+			/* Keyring bits */
+			struct list_head name_link;
+			struct assoc_array keys;
+		};
+		int reject_error;
 	};
 };
 
@@ -336,12 +331,12 @@ static inline bool key_is_instantiated(const struct key *key)
 }
 
 #define rcu_dereference_key(KEY)					\
-	(rcu_dereference_protected((KEY)->payload.rcudata,		\
+	(rcu_dereference_protected((KEY)->payload.rcu_data0,		\
 				   rwsem_is_locked(&((struct key *)(KEY))->sem)))
 
 #define rcu_assign_keypointer(KEY, PAYLOAD)				\
 do {									\
-	rcu_assign_pointer((KEY)->payload.rcudata, (PAYLOAD));		\
+	rcu_assign_pointer((KEY)->payload.rcu_data0, (PAYLOAD));	\
 } while (0)
 
 #ifdef CONFIG_SYSCTL
diff --git a/kernel/module_signing.c b/kernel/module_signing.c
index bd62f5cda746..6528a79d998d 100644
--- a/kernel/module_signing.c
+++ b/kernel/module_signing.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/errno.h>
 #include <keys/system_keyring.h>
 #include <crypto/public_key.h>
 #include "module-internal.h"
diff --git a/lib/digsig.c b/lib/digsig.c
index ae05ea393fc8..07be6c1ef4e2 100644
--- a/lib/digsig.c
+++ b/lib/digsig.c
@@ -79,12 +79,13 @@ static int digsig_verify_rsa(struct key *key,
 	unsigned char *out1 = NULL;
 	const char *m;
 	MPI in = NULL, res = NULL, pkey[2];
-	uint8_t *p, *datap, *endp;
-	struct user_key_payload *ukp;
+	uint8_t *p, *datap;
+	const uint8_t *endp;
+	const struct user_key_payload *ukp;
 	struct pubkey_hdr *pkh;
 
 	down_read(&key->sem);
-	ukp = key->payload.data;
+	ukp = user_key_payload(key);
 
 	if (ukp->datalen < sizeof(*pkh))
 		goto err1;
diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index 54a00d66509e..78f098a20796 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -318,7 +318,7 @@ static int get_secret(struct ceph_crypto_key *dst, const char *name) {
 		goto out;
 	}
 
-	ckey = ukey->payload.data;
+	ckey = ukey->payload.data[0];
 	err = ceph_crypto_key_clone(dst, ckey);
 	if (err)
 		goto out_key;
diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
index 4440edcce0d6..42e8649c6e79 100644
--- a/net/ceph/crypto.c
+++ b/net/ceph/crypto.c
@@ -537,7 +537,7 @@ static int ceph_key_preparse(struct key_preparsed_payload *prep)
 	if (ret < 0)
 		goto err_ckey;
 
-	prep->payload[0] = ckey;
+	prep->payload.data[0] = ckey;
 	prep->quotalen = datalen;
 	return 0;
 
@@ -549,14 +549,14 @@ err:
 
 static void ceph_key_free_preparse(struct key_preparsed_payload *prep)
 {
-	struct ceph_crypto_key *ckey = prep->payload[0];
+	struct ceph_crypto_key *ckey = prep->payload.data[0];
 	ceph_crypto_key_destroy(ckey);
 	kfree(ckey);
 }
 
 static void ceph_key_destroy(struct key *key)
 {
-	struct ceph_crypto_key *ckey = key->payload.data;
+	struct ceph_crypto_key *ckey = key->payload.data[0];
 
 	ceph_crypto_key_destroy(ckey);
 	kfree(ckey);
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index 31cd4fd75486..c79b85eb4d4c 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -122,7 +122,7 @@ dns_resolver_preparse(struct key_preparsed_payload *prep)
 					goto bad_option_value;
 
 				kdebug("dns error no. = %lu", derrno);
-				prep->type_data[0] = ERR_PTR(-derrno);
+				prep->payload.data[dns_key_error] = ERR_PTR(-derrno);
 				continue;
 			}
 
@@ -137,8 +137,8 @@ dns_resolver_preparse(struct key_preparsed_payload *prep)
 
 	/* don't cache the result if we're caching an error saying there's no
 	 * result */
-	if (prep->type_data[0]) {
-		kleave(" = 0 [h_error %ld]", PTR_ERR(prep->type_data[0]));
+	if (prep->payload.data[dns_key_error]) {
+		kleave(" = 0 [h_error %ld]", PTR_ERR(prep->payload.data[dns_key_error]));
 		return 0;
 	}
 
@@ -155,7 +155,7 @@ dns_resolver_preparse(struct key_preparsed_payload *prep)
 	memcpy(upayload->data, data, result_len);
 	upayload->data[result_len] = '\0';
 
-	prep->payload[0] = upayload;
+	prep->payload.data[dns_key_data] = upayload;
 	kleave(" = 0");
 	return 0;
 }
@@ -167,7 +167,7 @@ static void dns_resolver_free_preparse(struct key_preparsed_payload *prep)
 {
 	pr_devel("==>%s()\n", __func__);
 
-	kfree(prep->payload[0]);
+	kfree(prep->payload.data[dns_key_data]);
 }
 
 /*
@@ -223,10 +223,10 @@ static int dns_resolver_match_preparse(struct key_match_data *match_data)
  */
 static void dns_resolver_describe(const struct key *key, struct seq_file *m)
 {
-	int err = key->type_data.x[0];
-
 	seq_puts(m, key->description);
 	if (key_is_instantiated(key)) {
+		int err = PTR_ERR(key->payload.data[dns_key_error]);
+
 		if (err)
 			seq_printf(m, ": %d", err);
 		else
@@ -241,8 +241,10 @@ static void dns_resolver_describe(const struct key *key, struct seq_file *m)
 static long dns_resolver_read(const struct key *key,
 			      char __user *buffer, size_t buflen)
 {
-	if (key->type_data.x[0])
-		return key->type_data.x[0];
+	int err = PTR_ERR(key->payload.data[dns_key_error]);
+
+	if (err)
+		return err;
 
 	return user_read(key, buffer, buflen);
 }
diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index 39d2c39bdf87..4677b6fa6dda 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -70,7 +70,7 @@ int dns_query(const char *type, const char *name, size_t namelen,
 	      const char *options, char **_result, time_t *_expiry)
 {
 	struct key *rkey;
-	struct user_key_payload *upayload;
+	const struct user_key_payload *upayload;
 	const struct cred *saved_cred;
 	size_t typelen, desclen;
 	char *desc, *cp;
@@ -137,12 +137,11 @@ int dns_query(const char *type, const char *name, size_t namelen,
 		goto put;
 
 	/* If the DNS server gave an error, return that to the caller */
-	ret = rkey->type_data.x[0];
+	ret = PTR_ERR(rkey->payload.data[dns_key_error]);
 	if (ret)
 		goto put;
 
-	upayload = rcu_dereference_protected(rkey->payload.data,
-					     lockdep_is_held(&rkey->sem));
+	upayload = user_key_payload(rkey);
 	len = upayload->datalen;
 
 	ret = -ENOMEM;
diff --git a/net/dns_resolver/internal.h b/net/dns_resolver/internal.h
index 7af1ed39c009..0c570d40e4d6 100644
--- a/net/dns_resolver/internal.h
+++ b/net/dns_resolver/internal.h
@@ -23,6 +23,14 @@
 #include <linux/sched.h>
 
 /*
+ * Layout of key payload words.
+ */
+enum {
+	dns_key_data,
+	dns_key_error,
+};
+
+/*
  * dns_key.c
  */
 extern const struct cred *dns_resolver_cache;
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 25d60ed15284..1f8a144a5dc2 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -305,7 +305,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 
 	if (!key)
 		key = rx->key;
-	if (key && !key->payload.data)
+	if (key && !key->payload.data[0])
 		key = NULL; /* a no-security key */
 
 	bundle = rxrpc_get_bundle(rx, trans, key, service_id, gfp);
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index db0f39f5ef96..da3cc09f683e 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -148,10 +148,10 @@ static int rxrpc_preparse_xdr_rxkad(struct key_preparsed_payload *prep,
 		       token->kad->ticket[6], token->kad->ticket[7]);
 
 	/* count the number of tokens attached */
-	prep->type_data[0] = (void *)((unsigned long)prep->type_data[0] + 1);
+	prep->payload.data[1] = (void *)((unsigned long)prep->payload.data[1] + 1);
 
 	/* attach the data */
-	for (pptoken = (struct rxrpc_key_token **)&prep->payload[0];
+	for (pptoken = (struct rxrpc_key_token **)&prep->payload.data[0];
 	     *pptoken;
 	     pptoken = &(*pptoken)->next)
 		continue;
@@ -522,7 +522,7 @@ static int rxrpc_preparse_xdr_rxk5(struct key_preparsed_payload *prep,
 		goto inval;
 
 	/* attach the payload */
-	for (pptoken = (struct rxrpc_key_token **)&prep->payload[0];
+	for (pptoken = (struct rxrpc_key_token **)&prep->payload.data[0];
 	     *pptoken;
 	     pptoken = &(*pptoken)->next)
 		continue;
@@ -764,10 +764,10 @@ static int rxrpc_preparse(struct key_preparsed_payload *prep)
 	memcpy(&token->kad->ticket, v1->ticket, v1->ticket_length);
 
 	/* count the number of tokens attached */
-	prep->type_data[0] = (void *)((unsigned long)prep->type_data[0] + 1);
+	prep->payload.data[1] = (void *)((unsigned long)prep->payload.data[1] + 1);
 
 	/* attach the data */
-	pp = (struct rxrpc_key_token **)&prep->payload[0];
+	pp = (struct rxrpc_key_token **)&prep->payload.data[0];
 	while (*pp)
 		pp = &(*pp)->next;
 	*pp = token;
@@ -814,7 +814,7 @@ static void rxrpc_free_token_list(struct rxrpc_key_token *token)
  */
 static void rxrpc_free_preparse(struct key_preparsed_payload *prep)
 {
-	rxrpc_free_token_list(prep->payload[0]);
+	rxrpc_free_token_list(prep->payload.data[0]);
 }
 
 /*
@@ -831,7 +831,7 @@ static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 	if (prep->datalen != 8)
 		return -EINVAL;
 
-	memcpy(&prep->type_data, prep->data, 8);
+	memcpy(&prep->payload.data[2], prep->data, 8);
 
 	ci = crypto_alloc_blkcipher("pcbc(des)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(ci)) {
@@ -842,7 +842,7 @@ static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 	if (crypto_blkcipher_setkey(ci, prep->data, 8) < 0)
 		BUG();
 
-	prep->payload[0] = ci;
+	prep->payload.data[0] = ci;
 	_leave(" = 0");
 	return 0;
 }
@@ -852,8 +852,8 @@ static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
  */
 static void rxrpc_free_preparse_s(struct key_preparsed_payload *prep)
 {
-	if (prep->payload[0])
-		crypto_free_blkcipher(prep->payload[0]);
+	if (prep->payload.data[0])
+		crypto_free_blkcipher(prep->payload.data[0]);
 }
 
 /*
@@ -861,7 +861,7 @@ static void rxrpc_free_preparse_s(struct key_preparsed_payload *prep)
  */
 static void rxrpc_destroy(struct key *key)
 {
-	rxrpc_free_token_list(key->payload.data);
+	rxrpc_free_token_list(key->payload.data[0]);
 }
 
 /*
@@ -869,9 +869,9 @@ static void rxrpc_destroy(struct key *key)
  */
 static void rxrpc_destroy_s(struct key *key)
 {
-	if (key->payload.data) {
-		crypto_free_blkcipher(key->payload.data);
-		key->payload.data = NULL;
+	if (key->payload.data[0]) {
+		crypto_free_blkcipher(key->payload.data[0]);
+		key->payload.data[0] = NULL;
 	}
 }
 
@@ -1070,7 +1070,7 @@ static long rxrpc_read(const struct key *key,
 	size += 1 * 4;	/* token count */
 
 	ntoks = 0;
-	for (token = key->payload.data; token; token = token->next) {
+	for (token = key->payload.data[0]; token; token = token->next) {
 		toksize = 4;	/* sec index */
 
 		switch (token->security_index) {
@@ -1163,7 +1163,7 @@ static long rxrpc_read(const struct key *key,
 	ENCODE(ntoks);
 
 	tok = 0;
-	for (token = key->payload.data; token; token = token->next) {
+	for (token = key->payload.data[0]; token; token = token->next) {
 		toksize = toksizes[tok++];
 		ENCODE(toksize);
 		oldxdr = xdr;
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index c0042807bfc6..a40d3afe93b7 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -158,7 +158,7 @@ int rxrpc_client_sendmsg(struct rxrpc_sock *rx, struct rxrpc_transport *trans,
 			service_id = htons(srx->srx_service);
 		}
 		key = rx->key;
-		if (key && !rx->key->payload.data)
+		if (key && !rx->key->payload.data[0])
 			key = NULL;
 		bundle = rxrpc_get_bundle(rx, trans, key, service_id,
 					  GFP_KERNEL);
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
index 49b3cc31ee1f..8334474eb26c 100644
--- a/net/rxrpc/ar-security.c
+++ b/net/rxrpc/ar-security.c
@@ -137,9 +137,9 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 	if (ret < 0)
 		return ret;
 
-	if (!key->payload.data)
+	token = key->payload.data[0];
+	if (!token)
 		return -EKEYREJECTED;
-	token = key->payload.data;
 
 	sec = rxrpc_security_lookup(token->security_index);
 	if (!sec)
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index f226709ebd8f..d7a9ab5a9d9c 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -67,7 +67,7 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 
 	_enter("{%d},{%x}", conn->debug_id, key_serial(conn->key));
 
-	token = conn->key->payload.data;
+	token = conn->key->payload.data[0];
 	conn->security_ix = token->security_index;
 
 	ci = crypto_alloc_blkcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
@@ -125,7 +125,7 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	if (!conn->key)
 		return;
 
-	token = conn->key->payload.data;
+	token = conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
 	desc.tfm = conn->cipher;
@@ -221,7 +221,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	rxkhdr.checksum = 0;
 
 	/* encrypt from the session key */
-	token = call->conn->key->payload.data;
+	token = call->conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 	desc.tfm = call->conn->cipher;
 	desc.info = iv.x;
@@ -433,7 +433,7 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
 	/* decrypt from the session key */
-	token = call->conn->key->payload.data;
+	token = call->conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 	desc.tfm = call->conn->cipher;
 	desc.info = iv.x;
@@ -780,7 +780,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	if (conn->security_level < min_level)
 		goto protocol_error;
 
-	token = conn->key->payload.data;
+	token = conn->key->payload.data[0];
 
 	/* build the response packet */
 	memset(&resp, 0, sizeof(resp));
@@ -848,12 +848,12 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 		}
 	}
 
-	ASSERT(conn->server_key->payload.data != NULL);
+	ASSERT(conn->server_key->payload.data[0] != NULL);
 	ASSERTCMP((unsigned long) ticket & 7UL, ==, 0);
 
-	memcpy(&iv, &conn->server_key->type_data, sizeof(iv));
+	memcpy(&iv, &conn->server_key->payload.data[2], sizeof(iv));
 
-	desc.tfm = conn->server_key->payload.data;
+	desc.tfm = conn->server_key->payload.data[0];
 	desc.info = iv.x;
 	desc.flags = 0;
 
diff --git a/security/integrity/evm/evm_crypto.c b/security/integrity/evm/evm_crypto.c
index 159ef3ea4130..461f8d891579 100644
--- a/security/integrity/evm/evm_crypto.c
+++ b/security/integrity/evm/evm_crypto.c
@@ -247,7 +247,7 @@ int evm_init_key(void)
 		return -ENOENT;
 
 	down_read(&evm_key->sem);
-	ekp = evm_key->payload.data;
+	ekp = evm_key->payload.data[0];
 	if (ekp->decrypted_datalen > MAX_KEY_SIZE) {
 		rc = -EINVAL;
 		goto out;
diff --git a/security/keys/big_key.c b/security/keys/big_key.c
index b6adb94f6d52..907c1522ee46 100644
--- a/security/keys/big_key.c
+++ b/security/keys/big_key.c
@@ -21,6 +21,16 @@
 MODULE_LICENSE("GPL");
 
 /*
+ * Layout of key payload words.
+ */
+enum {
+	big_key_data,
+	big_key_path,
+	big_key_path_2nd_part,
+	big_key_len,
+};
+
+/*
  * If the data is under this limit, there's no point creating a shm file to
  * hold it as the permanently resident metadata for the shmem fs will be at
  * least as large as the data.
@@ -47,7 +57,7 @@ struct key_type key_type_big_key = {
  */
 int big_key_preparse(struct key_preparsed_payload *prep)
 {
-	struct path *path = (struct path *)&prep->payload;
+	struct path *path = (struct path *)&prep->payload.data[big_key_path];
 	struct file *file;
 	ssize_t written;
 	size_t datalen = prep->datalen;
@@ -60,7 +70,7 @@ int big_key_preparse(struct key_preparsed_payload *prep)
 	/* Set an arbitrary quota */
 	prep->quotalen = 16;
 
-	prep->type_data[1] = (void *)(unsigned long)datalen;
+	prep->payload.data[big_key_len] = (void *)(unsigned long)datalen;
 
 	if (datalen > BIG_KEY_FILE_THRESHOLD) {
 		/* Create a shmem file to store the data in.  This will permit the data
@@ -94,7 +104,8 @@ int big_key_preparse(struct key_preparsed_payload *prep)
 		if (!data)
 			return -ENOMEM;
 
-		prep->payload[0] = memcpy(data, prep->data, prep->datalen);
+		prep->payload.data[big_key_data] = data;
+		memcpy(data, prep->data, prep->datalen);
 	}
 	return 0;
 
@@ -110,10 +121,10 @@ error:
 void big_key_free_preparse(struct key_preparsed_payload *prep)
 {
 	if (prep->datalen > BIG_KEY_FILE_THRESHOLD) {
-		struct path *path = (struct path *)&prep->payload;
+		struct path *path = (struct path *)&prep->payload.data[big_key_path];
 		path_put(path);
 	} else {
-		kfree(prep->payload[0]);
+		kfree(prep->payload.data[big_key_data]);
 	}
 }
 
@@ -123,11 +134,12 @@ void big_key_free_preparse(struct key_preparsed_payload *prep)
  */
 void big_key_revoke(struct key *key)
 {
-	struct path *path = (struct path *)&key->payload.data2;
+	struct path *path = (struct path *)&key->payload.data[big_key_path];
 
 	/* clear the quota */
 	key_payload_reserve(key, 0);
-	if (key_is_instantiated(key) && key->type_data.x[1] > BIG_KEY_FILE_THRESHOLD)
+	if (key_is_instantiated(key) &&
+	    (size_t)key->payload.data[big_key_len] > BIG_KEY_FILE_THRESHOLD)
 		vfs_truncate(path, 0);
 }
 
@@ -136,14 +148,16 @@ void big_key_revoke(struct key *key)
  */
 void big_key_destroy(struct key *key)
 {
-	if (key->type_data.x[1] > BIG_KEY_FILE_THRESHOLD) {
-		struct path *path = (struct path *)&key->payload.data2;
+	size_t datalen = (size_t)key->payload.data[big_key_len];
+
+	if (datalen) {
+		struct path *path = (struct path *)&key->payload.data[big_key_path];
 		path_put(path);
 		path->mnt = NULL;
 		path->dentry = NULL;
 	} else {
-		kfree(key->payload.data);
-		key->payload.data = NULL;
+		kfree(key->payload.data[big_key_data]);
+		key->payload.data[big_key_data] = NULL;
 	}
 }
 
@@ -152,12 +166,12 @@ void big_key_destroy(struct key *key)
  */
 void big_key_describe(const struct key *key, struct seq_file *m)
 {
-	unsigned long datalen = key->type_data.x[1];
+	size_t datalen = (size_t)key->payload.data[big_key_len];
 
 	seq_puts(m, key->description);
 
 	if (key_is_instantiated(key))
-		seq_printf(m, ": %lu [%s]",
+		seq_printf(m, ": %zu [%s]",
 			   datalen,
 			   datalen > BIG_KEY_FILE_THRESHOLD ? "file" : "buff");
 }
@@ -168,14 +182,14 @@ void big_key_describe(const struct key *key, struct seq_file *m)
  */
 long big_key_read(const struct key *key, char __user *buffer, size_t buflen)
 {
-	unsigned long datalen = key->type_data.x[1];
+	size_t datalen = (size_t)key->payload.data[big_key_len];
 	long ret;
 
 	if (!buffer || buflen < datalen)
 		return datalen;
 
 	if (datalen > BIG_KEY_FILE_THRESHOLD) {
-		struct path *path = (struct path *)&key->payload.data2;
+		struct path *path = (struct path *)&key->payload.data[big_key_path];
 		struct file *file;
 		loff_t pos;
 
@@ -190,7 +204,8 @@ long big_key_read(const struct key *key, char __user *buffer, size_t buflen)
 			ret = -EIO;
 	} else {
 		ret = datalen;
-		if (copy_to_user(buffer, key->payload.data, datalen) != 0)
+		if (copy_to_user(buffer, key->payload.data[big_key_data],
+				 datalen) != 0)
 			ret = -EFAULT;
 	}
 
diff --git a/security/keys/encrypted-keys/encrypted.c b/security/keys/encrypted-keys/encrypted.c
index 7bed4ad7cd76..927db9f35ad6 100644
--- a/security/keys/encrypted-keys/encrypted.c
+++ b/security/keys/encrypted-keys/encrypted.c
@@ -303,10 +303,10 @@ out:
  *
  * Use a user provided key to encrypt/decrypt an encrypted-key.
  */
-static struct key *request_user_key(const char *master_desc, u8 **master_key,
+static struct key *request_user_key(const char *master_desc, const u8 **master_key,
 				    size_t *master_keylen)
 {
-	struct user_key_payload *upayload;
+	const struct user_key_payload *upayload;
 	struct key *ukey;
 
 	ukey = request_key(&key_type_user, master_desc, NULL);
@@ -314,7 +314,7 @@ static struct key *request_user_key(const char *master_desc, u8 **master_key,
 		goto error;
 
 	down_read(&ukey->sem);
-	upayload = ukey->payload.data;
+	upayload = user_key_payload(ukey);
 	*master_key = upayload->data;
 	*master_keylen = upayload->datalen;
 error:
@@ -426,7 +426,7 @@ static int init_blkcipher_desc(struct blkcipher_desc *desc, const u8 *key,
 }
 
 static struct key *request_master_key(struct encrypted_key_payload *epayload,
-				      u8 **master_key, size_t *master_keylen)
+				      const u8 **master_key, size_t *master_keylen)
 {
 	struct key *mkey = NULL;
 
@@ -653,7 +653,7 @@ static int encrypted_key_decrypt(struct encrypted_key_payload *epayload,
 {
 	struct key *mkey;
 	u8 derived_key[HASH_SIZE];
-	u8 *master_key;
+	const u8 *master_key;
 	u8 *hmac;
 	const char *hex_encoded_data;
 	unsigned int encrypted_datalen;
@@ -837,7 +837,7 @@ static void encrypted_rcu_free(struct rcu_head *rcu)
  */
 static int encrypted_update(struct key *key, struct key_preparsed_payload *prep)
 {
-	struct encrypted_key_payload *epayload = key->payload.data;
+	struct encrypted_key_payload *epayload = key->payload.data[0];
 	struct encrypted_key_payload *new_epayload;
 	char *buf;
 	char *new_master_desc = NULL;
@@ -896,7 +896,7 @@ static long encrypted_read(const struct key *key, char __user *buffer,
 {
 	struct encrypted_key_payload *epayload;
 	struct key *mkey;
-	u8 *master_key;
+	const u8 *master_key;
 	size_t master_keylen;
 	char derived_key[HASH_SIZE];
 	char *ascii_buf;
@@ -957,13 +957,13 @@ out:
  */
 static void encrypted_destroy(struct key *key)
 {
-	struct encrypted_key_payload *epayload = key->payload.data;
+	struct encrypted_key_payload *epayload = key->payload.data[0];
 
 	if (!epayload)
 		return;
 
 	memset(epayload->decrypted_data, 0, epayload->decrypted_datalen);
-	kfree(key->payload.data);
+	kfree(key->payload.data[0]);
 }
 
 struct key_type key_type_encrypted = {
diff --git a/security/keys/encrypted-keys/encrypted.h b/security/keys/encrypted-keys/encrypted.h
index 8136a2d44c63..47802c0de735 100644
--- a/security/keys/encrypted-keys/encrypted.h
+++ b/security/keys/encrypted-keys/encrypted.h
@@ -5,10 +5,10 @@
 #if defined(CONFIG_TRUSTED_KEYS) || \
   (defined(CONFIG_TRUSTED_KEYS_MODULE) && defined(CONFIG_ENCRYPTED_KEYS_MODULE))
 extern struct key *request_trusted_key(const char *trusted_desc,
-				       u8 **master_key, size_t *master_keylen);
+				       const u8 **master_key, size_t *master_keylen);
 #else
 static inline struct key *request_trusted_key(const char *trusted_desc,
-					      u8 **master_key,
+					      const u8 **master_key,
 					      size_t *master_keylen)
 {
 	return ERR_PTR(-EOPNOTSUPP);
diff --git a/security/keys/encrypted-keys/masterkey_trusted.c b/security/keys/encrypted-keys/masterkey_trusted.c
index 013f7e5d3a2f..b5b4812dbc87 100644
--- a/security/keys/encrypted-keys/masterkey_trusted.c
+++ b/security/keys/encrypted-keys/masterkey_trusted.c
@@ -29,7 +29,7 @@
  * data, trusted key type data is not visible decrypted from userspace.
  */
 struct key *request_trusted_key(const char *trusted_desc,
-				u8 **master_key, size_t *master_keylen)
+				const u8 **master_key, size_t *master_keylen)
 {
 	struct trusted_key_payload *tpayload;
 	struct key *tkey;
@@ -39,7 +39,7 @@ struct key *request_trusted_key(const char *trusted_desc,
 		goto error;
 
 	down_read(&tkey->sem);
-	tpayload = tkey->payload.data;
+	tpayload = tkey->payload.data[0];
 	*master_key = tpayload->key;
 	*master_keylen = tpayload->key_len;
 error:
diff --git a/security/keys/key.c b/security/keys/key.c
index c0478465d1ac..ab7997ded725 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -554,7 +554,7 @@ int key_reject_and_link(struct key *key,
 	if (!test_bit(KEY_FLAG_INSTANTIATED, &key->flags)) {
 		/* mark the key as being negatively instantiated */
 		atomic_inc(&key->user->nikeys);
-		key->type_data.reject_error = -error;
+		key->reject_error = -error;
 		smp_wmb();
 		set_bit(KEY_FLAG_NEGATIVE, &key->flags);
 		set_bit(KEY_FLAG_INSTANTIATED, &key->flags);
@@ -1046,14 +1046,14 @@ int generic_key_instantiate(struct key *key, struct key_preparsed_payload *prep)
 
 	ret = key_payload_reserve(key, prep->quotalen);
 	if (ret == 0) {
-		key->type_data.p[0] = prep->type_data[0];
-		key->type_data.p[1] = prep->type_data[1];
-		rcu_assign_keypointer(key, prep->payload[0]);
-		key->payload.data2[1] = prep->payload[1];
-		prep->type_data[0] = NULL;
-		prep->type_data[1] = NULL;
-		prep->payload[0] = NULL;
-		prep->payload[1] = NULL;
+		rcu_assign_keypointer(key, prep->payload.data[0]);
+		key->payload.data[1] = prep->payload.data[1];
+		key->payload.data[2] = prep->payload.data[2];
+		key->payload.data[3] = prep->payload.data[3];
+		prep->payload.data[0] = NULL;
+		prep->payload.data[1] = NULL;
+		prep->payload.data[2] = NULL;
+		prep->payload.data[3] = NULL;
 	}
 	pr_devel("<==%s() = %d\n", __func__, ret);
 	return ret;
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 6110fa498494..fb111eafcb89 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -1027,7 +1027,7 @@ long keyctl_instantiate_key_common(key_serial_t id,
 	if (!instkey)
 		goto error;
 
-	rka = instkey->payload.data;
+	rka = instkey->payload.data[0];
 	if (rka->target_key->serial != id)
 		goto error;
 
@@ -1194,7 +1194,7 @@ long keyctl_reject_key(key_serial_t id, unsigned timeout, unsigned error,
 	if (!instkey)
 		goto error;
 
-	rka = instkey->payload.data;
+	rka = instkey->payload.data[0];
 	if (rka->target_key->serial != id)
 		goto error;
 
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index d33437007ad2..f931ccfeefb0 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -118,7 +118,7 @@ static void keyring_publish_name(struct key *keyring)
 		if (!keyring_name_hash[bucket].next)
 			INIT_LIST_HEAD(&keyring_name_hash[bucket]);
 
-		list_add_tail(&keyring->type_data.link,
+		list_add_tail(&keyring->name_link,
 			      &keyring_name_hash[bucket]);
 
 		write_unlock(&keyring_name_lock);
@@ -387,9 +387,9 @@ static void keyring_destroy(struct key *keyring)
 	if (keyring->description) {
 		write_lock(&keyring_name_lock);
 
-		if (keyring->type_data.link.next != NULL &&
-		    !list_empty(&keyring->type_data.link))
-			list_del(&keyring->type_data.link);
+		if (keyring->name_link.next != NULL &&
+		    !list_empty(&keyring->name_link))
+			list_del(&keyring->name_link);
 
 		write_unlock(&keyring_name_lock);
 	}
@@ -572,7 +572,7 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
 		/* we set a different error code if we pass a negative key */
 		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
 			smp_rmb();
-			ctx->result = ERR_PTR(key->type_data.reject_error);
+			ctx->result = ERR_PTR(key->reject_error);
 			kleave(" = %d [neg]", ctx->skipped_ret);
 			goto skipped;
 		}
@@ -990,7 +990,7 @@ struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
 		 * that's readable and that hasn't been revoked */
 		list_for_each_entry(keyring,
 				    &keyring_name_hash[bucket],
-				    type_data.link
+				    name_link
 				    ) {
 			if (!kuid_has_mapping(current_user_ns(), keyring->user->uid))
 				continue;
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 43b4cddbf2b3..a3f85d2a00bb 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -457,7 +457,7 @@ key_ref_t search_process_keyrings(struct keyring_search_context *ctx)
 		down_read(&cred->request_key_auth->sem);
 
 		if (key_validate(ctx->cred->request_key_auth) == 0) {
-			rka = ctx->cred->request_key_auth->payload.data;
+			rka = ctx->cred->request_key_auth->payload.data[0];
 
 			ctx->cred = rka->cred;
 			key_ref = search_process_keyrings(ctx);
@@ -647,7 +647,7 @@ try_again:
 			key_ref = ERR_PTR(-EKEYREVOKED);
 			key = NULL;
 		} else {
-			rka = ctx.cred->request_key_auth->payload.data;
+			rka = ctx.cred->request_key_auth->payload.data[0];
 			key = rka->dest_keyring;
 			__key_get(key);
 		}
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 486ef6fa393b..95d5cfc172c6 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -271,7 +271,7 @@ static void construct_get_dest_keyring(struct key **_dest_keyring)
 			if (cred->request_key_auth) {
 				authkey = cred->request_key_auth;
 				down_read(&authkey->sem);
-				rka = authkey->payload.data;
+				rka = authkey->payload.data[0];
 				if (!test_bit(KEY_FLAG_REVOKED,
 					      &authkey->flags))
 					dest_keyring =
@@ -593,7 +593,7 @@ int wait_for_key_construction(struct key *key, bool intr)
 		return -ERESTARTSYS;
 	if (test_bit(KEY_FLAG_NEGATIVE, &key->flags)) {
 		smp_rmb();
-		return key->type_data.reject_error;
+		return key->reject_error;
 	}
 	return key_validate(key);
 }
diff --git a/security/keys/request_key_auth.c b/security/keys/request_key_auth.c
index 5d672f7580dd..4f0f112fe276 100644
--- a/security/keys/request_key_auth.c
+++ b/security/keys/request_key_auth.c
@@ -59,7 +59,7 @@ static void request_key_auth_free_preparse(struct key_preparsed_payload *prep)
 static int request_key_auth_instantiate(struct key *key,
 					struct key_preparsed_payload *prep)
 {
-	key->payload.data = (struct request_key_auth *)prep->data;
+	key->payload.data[0] = (struct request_key_auth *)prep->data;
 	return 0;
 }
 
@@ -69,7 +69,7 @@ static int request_key_auth_instantiate(struct key *key,
 static void request_key_auth_describe(const struct key *key,
 				      struct seq_file *m)
 {
-	struct request_key_auth *rka = key->payload.data;
+	struct request_key_auth *rka = key->payload.data[0];
 
 	seq_puts(m, "key:");
 	seq_puts(m, key->description);
@@ -84,7 +84,7 @@ static void request_key_auth_describe(const struct key *key,
 static long request_key_auth_read(const struct key *key,
 				  char __user *buffer, size_t buflen)
 {
-	struct request_key_auth *rka = key->payload.data;
+	struct request_key_auth *rka = key->payload.data[0];
 	size_t datalen;
 	long ret;
 
@@ -110,7 +110,7 @@ static long request_key_auth_read(const struct key *key,
  */
 static void request_key_auth_revoke(struct key *key)
 {
-	struct request_key_auth *rka = key->payload.data;
+	struct request_key_auth *rka = key->payload.data[0];
 
 	kenter("{%d}", key->serial);
 
@@ -125,7 +125,7 @@ static void request_key_auth_revoke(struct key *key)
  */
 static void request_key_auth_destroy(struct key *key)
 {
-	struct request_key_auth *rka = key->payload.data;
+	struct request_key_auth *rka = key->payload.data[0];
 
 	kenter("{%d}", key->serial);
 
@@ -179,7 +179,7 @@ struct key *request_key_auth_new(struct key *target, const void *callout_info,
 		if (test_bit(KEY_FLAG_REVOKED, &cred->request_key_auth->flags))
 			goto auth_key_revoked;
 
-		irka = cred->request_key_auth->payload.data;
+		irka = cred->request_key_auth->payload.data[0];
 		rka->cred = get_cred(irka->cred);
 		rka->pid = irka->pid;
 
diff --git a/security/keys/trusted.c b/security/keys/trusted.c
index d3633cf17c7d..903dace648a1 100644
--- a/security/keys/trusted.c
+++ b/security/keys/trusted.c
@@ -1007,7 +1007,7 @@ static void trusted_rcu_free(struct rcu_head *rcu)
  */
 static int trusted_update(struct key *key, struct key_preparsed_payload *prep)
 {
-	struct trusted_key_payload *p = key->payload.data;
+	struct trusted_key_payload *p = key->payload.data[0];
 	struct trusted_key_payload *new_p;
 	struct trusted_key_options *new_o;
 	size_t datalen = prep->datalen;
@@ -1114,12 +1114,12 @@ static long trusted_read(const struct key *key, char __user *buffer,
  */
 static void trusted_destroy(struct key *key)
 {
-	struct trusted_key_payload *p = key->payload.data;
+	struct trusted_key_payload *p = key->payload.data[0];
 
 	if (!p)
 		return;
 	memset(p->key, 0, p->key_len);
-	kfree(key->payload.data);
+	kfree(key->payload.data[0]);
 }
 
 struct key_type key_type_trusted = {
diff --git a/security/keys/user_defined.c b/security/keys/user_defined.c
index 36b47bbd3d8c..28cb30f80256 100644
--- a/security/keys/user_defined.c
+++ b/security/keys/user_defined.c
@@ -74,7 +74,7 @@ int user_preparse(struct key_preparsed_payload *prep)
 
 	/* attach the data */
 	prep->quotalen = datalen;
-	prep->payload[0] = upayload;
+	prep->payload.data[0] = upayload;
 	upayload->datalen = datalen;
 	memcpy(upayload->data, prep->data, datalen);
 	return 0;
@@ -86,7 +86,7 @@ EXPORT_SYMBOL_GPL(user_preparse);
  */
 void user_free_preparse(struct key_preparsed_payload *prep)
 {
-	kfree(prep->payload[0]);
+	kfree(prep->payload.data[0]);
 }
 EXPORT_SYMBOL_GPL(user_free_preparse);
 
@@ -120,7 +120,7 @@ int user_update(struct key *key, struct key_preparsed_payload *prep)
 
 	if (ret == 0) {
 		/* attach the new data, displacing the old */
-		zap = key->payload.data;
+		zap = key->payload.data[0];
 		rcu_assign_keypointer(key, upayload);
 		key->expiry = 0;
 	}
@@ -140,7 +140,7 @@ EXPORT_SYMBOL_GPL(user_update);
  */
 void user_revoke(struct key *key)
 {
-	struct user_key_payload *upayload = key->payload.data;
+	struct user_key_payload *upayload = key->payload.data[0];
 
 	/* clear the quota */
 	key_payload_reserve(key, 0);
@@ -158,7 +158,7 @@ EXPORT_SYMBOL(user_revoke);
  */
 void user_destroy(struct key *key)
 {
-	struct user_key_payload *upayload = key->payload.data;
+	struct user_key_payload *upayload = key->payload.data[0];
 
 	kfree(upayload);
 }
@@ -183,10 +183,10 @@ EXPORT_SYMBOL_GPL(user_describe);
  */
 long user_read(const struct key *key, char __user *buffer, size_t buflen)
 {
-	struct user_key_payload *upayload;
+	const struct user_key_payload *upayload;
 	long ret;
 
-	upayload = rcu_dereference_key(key);
+	upayload = user_key_payload(key);
 	ret = upayload->datalen;
 
 	/* we can return the data as is */

