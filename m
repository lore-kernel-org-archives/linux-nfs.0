Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA5C4C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:10:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7966121924
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:10:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730122AbfBOQK0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:10:26 -0500
Received: from mx1.redhat.com ([209.132.183.28]:3145 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728146AbfBOQKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:10:25 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D44FC315FCA;
        Fri, 15 Feb 2019 16:10:24 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id EE3BA5D9CD;
        Fri, 15 Feb 2019 16:10:18 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 18/27] keys: Find the least-recently used unseen key in
 a keyring.
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:10:13 +0000
Message-ID: <155024701313.21651.15123621736164077230.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 15 Feb 2019 16:10:25 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Provide a keyctl by which the oldest "unseen" key in a keyring can be
found.  The "unseenness" is controlled by a flag on the key, so is shared
across all keyrings that might link to a key.  The flag is only set by this
keyctl.  The keyctl looks like:

	key = keyctl_find_lru(key_serial_t keyring,
			      const char *type_name)

It searches the nominated keyring subtree for a valid key of the specified
type and returns its serial number or -ENOKEY if no valid, unseen keys are
found.

This is primarily intended for use with ".request_key_auth"-type keys in
container upcall management.  Ordinarily, it should be possible to just
pick the serial numbers out of the notification records from when an auth
key gets added to the upcall keyring, but if the buffer gets overrun, then
some other means must be employed.

[!] I'm not sure I need to do the "unseen" check at all.  This call is only
    really needed if there's a notification buffer overrun.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/key.h         |    1 
 include/uapi/linux/keyctl.h |    1 
 security/keys/compat.c      |    2 +
 security/keys/container.c   |  106 +++++++++++++++++++++++++++++++++++++++++++
 security/keys/internal.h    |    1 
 security/keys/keyctl.c      |    3 +
 6 files changed, 114 insertions(+)

diff --git a/include/linux/key.h b/include/linux/key.h
index 165f842ec042..de190036512b 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -219,6 +219,7 @@ struct key {
 #define KEY_FLAG_KEEP		8	/* set if key should not be removed */
 #define KEY_FLAG_UID_KEYRING	9	/* set if key is a user or user session keyring */
 #define KEY_FLAG_SET_WATCH_PROXY 10	/* Set if watch_proxy should be set on added keys */
+#define KEY_FLAG_SEEN		11	/* Set if returned by keyctl_find_oldest_key() */
 
 	/* the key type and key description string
 	 * - the desc is used to match a key against search criteria
diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index 425bbd9612c4..5b792303a05b 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -71,6 +71,7 @@
 #define KEYCTL_CONTAINER_INTERCEPT	31	/* Intercept upcalls inside a container */
 #define KEYCTL_QUERY_REQUEST_KEY_AUTH	32	/* Query a request_key_auth key */
 #define KEYCTL_MOVE			33	/* Move keys between keyrings */
+#define KEYCTL_FIND_LRU			34	/* Find the least-recently used key in a keyring */
 
 /* keyctl structures */
 struct keyctl_dh_params {
diff --git a/security/keys/compat.c b/security/keys/compat.c
index ed36efa13c48..160fb7b37352 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -166,6 +166,8 @@ COMPAT_SYSCALL_DEFINE5(keyctl, u32, option,
 		return keyctl_container_intercept(arg2, compat_ptr(arg3), arg4, arg5);
 	case KEYCTL_QUERY_REQUEST_KEY_AUTH:
 		return keyctl_query_request_key_auth(arg2, compat_ptr(arg3));
+	case KEYCTL_FIND_LRU:
+		return keyctl_find_lru(arg2, compat_ptr(arg3));
 #endif
 
 	case KEYCTL_MOVE:
diff --git a/security/keys/container.c b/security/keys/container.c
index 115998e867cd..8e6b3c8710e2 100644
--- a/security/keys/container.c
+++ b/security/keys/container.c
@@ -267,3 +267,109 @@ long keyctl_query_request_key_auth(key_serial_t auth_id,
 
 	return 0;
 }
+
+struct key_lru_search_state {
+	struct key	*candidate;
+	time64_t	oldest;
+};
+
+/*
+ * Iterate over all the keys in the keyring looking for the one with the oldest
+ * timestamp.
+ */
+static bool cmp_lru(const struct key *key,
+			   const struct key_match_data *match_data)
+{
+	struct key_lru_search_state *state = (void *)match_data->raw_data;
+	time64_t t;
+
+	t = READ_ONCE(key->last_used_at);
+	if (state->oldest > t && !test_bit(KEY_FLAG_SEEN, &key->flags)) {
+		state->oldest = t;
+		state->candidate = (struct key *)key;
+	}
+
+	return false;
+}
+
+/*
+ * Find the oldest key in a keyring of a particular type.
+ */
+long keyctl_find_lru(key_serial_t _keyring, const char __user *type_name)
+{
+	struct key_lru_search_state state;
+	struct keyring_search_context ctx = {
+		.index_key.description	= NULL,
+		.cred			= current_cred(),
+		.match_data.cmp		= cmp_lru,
+		.match_data.raw_data	= &state,
+		.match_data.lookup_type	= KEYRING_SEARCH_LOOKUP_ITERATE,
+		.flags			= KEYRING_SEARCH_DO_STATE_CHECK,
+	};
+	struct key_type *ktype;
+	struct key *key;
+	key_ref_t keyring_ref, ref;
+	char type[32];
+	int ret, max_iter = 10;
+
+	if (!_keyring || !type_name)
+		return -EINVAL;
+
+	/* We want to allow special types, such as ".request_key_auth" */
+	ret = strncpy_from_user(type, type_name, sizeof(type));
+	if (ret < 0)
+		return ret;
+	if (ret == 0 || ret >= sizeof(type))
+		return -EINVAL;
+	type[ret] = '\0';
+
+	keyring_ref = lookup_user_key(_keyring, 0, KEY_NEED_SEARCH);
+	if (IS_ERR(keyring_ref))
+		return PTR_ERR(keyring_ref);
+
+	if (strcmp(type, key_type_request_key_auth.name) == 0) {
+		ktype = &key_type_request_key_auth;
+	} else {
+		ktype = key_type_lookup(type);
+		if (IS_ERR(ktype)) {
+			ret = PTR_ERR(ktype);
+			goto error_ring;
+		}
+	}
+
+	ctx.index_key.type = ktype;
+
+	do {
+		state.oldest = TIME64_MAX;
+		state.candidate = NULL;
+
+		rcu_read_lock();
+
+		/* Scan the keyring.  We expect this to end in -EAGAIN as we
+		 * can't generate a result until the entire scan is completed.
+		 */
+		ret = -EAGAIN;
+		ref = keyring_search_aux(keyring_ref, &ctx);
+
+		key = state.candidate;
+		if (key &&
+		    !test_and_set_bit(KEY_FLAG_SEEN, &key->flags) &&
+		    key_validate(key) == 0) {
+			ret = key->serial;
+			goto error_unlock;
+		}
+
+
+		rcu_read_unlock();
+	} while (--max_iter > 0);
+	goto error_type;
+
+error_unlock:
+	rcu_read_unlock();
+error_type:
+	if (ktype != &key_type_request_key_auth)
+		key_type_put(ktype);
+error_ring:
+	key_ref_put(keyring_ref);
+	return ret;
+}
diff --git a/security/keys/internal.h b/security/keys/internal.h
index bad4a8038a99..fe4a4da1ff17 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -365,6 +365,7 @@ static inline long keyctl_watch_key(key_serial_t key_id, int watch_fd, int watch
 extern long keyctl_container_intercept(int, const char __user *, unsigned int, key_serial_t);
 extern long keyctl_query_request_key_auth(key_serial_t,
 					  struct keyctl_query_request_key_auth __user *);
+extern long keyctl_find_lru(key_serial_t, const char __user *);
 #endif
 
 /*
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 6057b810c611..1446bc52e369 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -1916,6 +1916,9 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		return keyctl_query_request_key_auth(
 			(key_serial_t)arg2,
 			(struct keyctl_query_request_key_auth __user *)arg3);
+	case KEYCTL_FIND_LRU:
+		return keyctl_find_lru((key_serial_t)arg2,
+				       (const char __user *)arg3);
 #endif
 
 	case KEYCTL_MOVE:

