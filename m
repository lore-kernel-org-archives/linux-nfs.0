Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D668C10F06
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:10:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5DB612192B
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:10:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391605AbfBOQKJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:10:09 -0500
Received: from mx1.redhat.com ([209.132.183.28]:36662 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389248AbfBOQKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:10:08 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E77EEAD886;
        Fri, 15 Feb 2019 16:10:07 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C60E81024955;
        Fri, 15 Feb 2019 16:10:05 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 17/27] keys: Add a keyctl to move a key between keyrings
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:10:05 +0000
Message-ID: <155024700503.21651.11352044662949476132.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 15 Feb 2019 16:10:08 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add a keyctl to atomically move a link to a key from one keyring to
another.  The key must exist in "from" keyring and a flag can be given to
cause the operation to fail if there's a matching key already in the "to"
keyring.

This can be done with:

	keyctl(KEYCTL_MOVE,
	       key_serial_t key,
	       key_serial_t from_keyring,
	       key_serial_t to_keyring,
	       unsigned int flags);

The key being moved must grant Link permission and both keyrings must grant
Write permission.

flags should be 0 or KEYCTL_MOVE_EXCL, with the latter preventing
displacement of a matching key from the "to" keyring.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/key.h         |    5 ++
 include/uapi/linux/keyctl.h |    3 +
 security/keys/compat.c      |    3 +
 security/keys/internal.h    |    1 
 security/keys/keyctl.c      |   55 +++++++++++++++++++++++++++
 security/keys/keyring.c     |   88 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 155 insertions(+)

diff --git a/include/linux/key.h b/include/linux/key.h
index 82eb1b8d6336..165f842ec042 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -335,6 +335,11 @@ extern int key_update(key_ref_t key,
 extern int key_link(struct key *keyring,
 		    struct key *key);
 
+extern int key_move(struct key *key,
+		    struct key *from_keyring,
+		    struct key *to_keyring,
+		    unsigned int flags);
+
 extern int key_unlink(struct key *keyring,
 		      struct key *key);
 
diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index bb075ad1827d..425bbd9612c4 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -70,6 +70,7 @@
 #define KEYCTL_WATCH_KEY		30	/* Watch a key or ring of keys for changes */
 #define KEYCTL_CONTAINER_INTERCEPT	31	/* Intercept upcalls inside a container */
 #define KEYCTL_QUERY_REQUEST_KEY_AUTH	32	/* Query a request_key_auth key */
+#define KEYCTL_MOVE			33	/* Move keys between keyrings */
 
 /* keyctl structures */
 struct keyctl_dh_params {
@@ -126,4 +127,6 @@ struct keyctl_query_request_key_auth {
 	__u64		spare[1];
 };
 
+#define KEYCTL_MOVE_EXCL	0x00000001 /* Do not displace from the to-keyring */
+
 #endif /*  _LINUX_KEYCTL_H */
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 30055fc2b629..ed36efa13c48 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -168,6 +168,9 @@ COMPAT_SYSCALL_DEFINE5(keyctl, u32, option,
 		return keyctl_query_request_key_auth(arg2, compat_ptr(arg3));
 #endif
 
+	case KEYCTL_MOVE:
+		return keyctl_keyring_move(arg2, arg3, arg4, arg5);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 40846657aebd..bad4a8038a99 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -242,6 +242,7 @@ extern long keyctl_update_key(key_serial_t, const void __user *, size_t);
 extern long keyctl_revoke_key(key_serial_t);
 extern long keyctl_keyring_clear(key_serial_t);
 extern long keyctl_keyring_link(key_serial_t, key_serial_t);
+extern long keyctl_keyring_move(key_serial_t, key_serial_t, key_serial_t, unsigned int);
 extern long keyctl_keyring_unlink(key_serial_t, key_serial_t);
 extern long keyctl_describe_key(key_serial_t, char __user *, size_t);
 extern long keyctl_keyring_search(key_serial_t, const char __user *,
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index a19efc60944d..6057b810c611 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -572,6 +572,55 @@ long keyctl_keyring_unlink(key_serial_t id, key_serial_t ringid)
 	return ret;
 }
 
+/*
+ * Move a link to a key from one keyring to another, displacing any matching
+ * key from the destination keyring.
+ *
+ * The key must grant the caller Link permission and both keyrings must grant
+ * the caller Write permission.  There must also be a link in the from keyring
+ * to the key.  If both keyrings are the same, nothing is done.
+ *
+ * If successful, 0 will be returned.
+ */
+long keyctl_keyring_move(key_serial_t id, key_serial_t from_ringid,
+			 key_serial_t to_ringid, unsigned int flags)
+{
+	key_ref_t key_ref, from_ref, to_ref;
+	long ret;
+
+	if (flags & ~KEYCTL_MOVE_EXCL)
+		return -EINVAL;
+
+	key_ref = lookup_user_key(id, KEY_LOOKUP_CREATE, KEY_NEED_LINK);
+	if (IS_ERR(key_ref)) {
+		ret = PTR_ERR(key_ref);
+		goto error;
+	}
+
+	from_ref = lookup_user_key(from_ringid, 0, KEY_NEED_WRITE);
+	if (IS_ERR(from_ref)) {
+		ret = PTR_ERR(from_ref);
+		goto error2;
+	}
+
+	to_ref = lookup_user_key(to_ringid, KEY_LOOKUP_CREATE, KEY_NEED_WRITE);
+	if (IS_ERR(to_ref)) {
+		ret = PTR_ERR(to_ref);
+		goto error3;
+	}
+
+	ret = key_move(key_ref_to_ptr(key_ref), key_ref_to_ptr(from_ref),
+		       key_ref_to_ptr(to_ref), flags);
+
+	key_ref_put(to_ref);
+error3:
+	key_ref_put(from_ref);
+error2:
+	key_ref_put(key_ref);
+error:
+	return ret;
+}
+
 /*
  * Return a description of a key to userspace.
  *
@@ -1869,6 +1918,12 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 			(struct keyctl_query_request_key_auth __user *)arg3);
 #endif
 
+	case KEYCTL_MOVE:
+		return keyctl_keyring_move((key_serial_t)arg2,
+					   (key_serial_t)arg3,
+					   (key_serial_t)arg4,
+					   (unsigned int)arg5);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 1334ed97e530..14df79814ea0 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -1504,6 +1504,94 @@ int key_unlink(struct key *keyring, struct key *key)
 }
 EXPORT_SYMBOL(key_unlink);
 
+/**
+ * key_move - Move a key from one keyring to another
+ * @key: The key to move
+ * @from_keyring: The keyring to remove the link from.
+ * @to_keyring: The keyring to make the link in.
+ * @flags: Qualifying flags, such as KEYCTL_MOVE_EXCL.
+ *
+ * Make a link in @to_keyring to a key, such that the keyring holds a reference
+ * on that key and the key can potentially be found by searching that keyring
+ * whilst simultaneously removing a link to the key from @from_keyring.
+ *
+ * This function will write-lock both keyring's semaphores and will consume
+ * some of the user's key data quota to hold the link on @to_keyring.
+ *
+ * Returns 0 if successful, -ENOTDIR if either keyring isn't a keyring,
+ * -EKEYREVOKED if either keyring has been revoked, -ENFILE if the second
+ * keyring is full, -EDQUOT if there is insufficient key data quota remaining
+ * to add another link or -ENOMEM if there's insufficient memory.  If
+ * KEYCTL_MOVE_EXCL is set, then -EEXIST will be returned if there's already a
+ * matching key in @to_keyring.
+ *
+ * It is assumed that the caller has checked that it is permitted for a link to
+ * be made (the keyring should have Write permission and the key Link
+ * permission).
+ */
+int key_move(struct key *key,
+	     struct key *from_keyring,
+	     struct key *to_keyring,
+	     unsigned int flags)
+{
+	struct assoc_array_edit *from_edit, *to_edit;
+	int ret;
+
+	kenter("%d,%d,%d", key->serial, from_keyring->serial, to_keyring->serial);
+
+	if (from_keyring == to_keyring)
+		return 0;
+
+	key_check(key);
+	key_check(from_keyring);
+	key_check(to_keyring);
+
+	/* We have to be very careful here to take the keyring locks in the
+	 * right order, lest we open ourselves to deadlocking against another
+	 * move operation.
+	 */
+	if (from_keyring < to_keyring) {
+		ret = __key_unlink_begin(from_keyring, 0, key, &from_edit);
+		if (ret < 0)
+			goto out;
+		ret = __key_link_begin(to_keyring, 1, &key->index_key, &to_edit);
+		if (ret < 0) {
+			assoc_array_cancel_edit(from_edit);
+			goto out;
+		}
+	} else {
+		ret = __key_link_begin(to_keyring, 0, &key->index_key, &to_edit);
+		if (ret < 0)
+			goto out;
+		ret = __key_unlink_begin(from_keyring, 1, key, &from_edit);
+		if (ret < 0) {
+			__key_link_end(to_keyring, &key->index_key, to_edit);
+			goto out;
+		}
+	}
+
+	ret = -EEXIST;
+	if (to_edit->dead_leaf && (flags & KEYCTL_MOVE_EXCL))
+		goto error;
+
+	ret = __key_link_check_restriction(to_keyring, key);
+	if (ret < 0)
+		goto error;
+	ret = __key_link_check_live_key(to_keyring, key);
+	if (ret < 0)
+		goto error;
+
+	__key_unlink(from_keyring, key, &from_edit);
+	__key_link(to_keyring, key, &to_edit);
+error:
+	__key_unlink_end(from_keyring, key, from_edit);
+	__key_link_end(to_keyring, &key->index_key, to_edit);
+out:
+	kleave(" = %d", ret);
+	return ret;
+}
+EXPORT_SYMBOL(key_move);
+
 /**
  * keyring_clear - Clear a keyring
  * @keyring: The keyring to clear.

