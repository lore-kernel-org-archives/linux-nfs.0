Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933999AbdBVWym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 17:54:42 -0500
From: Jan Stancek <jstancek@redhat.com>
To: dhowells@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        jstancek@redhat.com, bcodding@redhat.com, asavkov@redhat.com
Subject: [PATCH 1/2] KEYS: add user_key_payload_rcu()
Date: Wed, 22 Feb 2017 23:54:26 +0100
Message-Id: <9b3fac1a82d8aa6b756a73ecded9655cc80f72b0.1487802542.git.jstancek@redhat.com>
In-Reply-To: <cover.1487802542.git.jstancek@redhat.com>
References: <cover.1487802542.git.jstancek@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

user_key_payload() is wrapper for rcu_dereference_protected(),
and can't be used with just rcu_read_lock() held.

This patch adds user_key_payload_rcu() for accessing key
payload in RCU read-side section, without the need
to hold key semaphore.

Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 Documentation/security/keys.txt | 5 +++++
 include/keys/user-type.h        | 5 +++++
 include/linux/key.h             | 3 +++
 3 files changed, 13 insertions(+)

diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index 3849814bfe6d..da89a854edd2 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -1152,8 +1152,13 @@ access the data:
      wrap the RCU calls to this element:
 
 	rcu_assign_keypointer(struct key *key, void *data);
+
+	/* access payload with semaphore held */
 	void *rcu_dereference_key(struct key *key);
 
+	/* access payload in RCU read-side section*/
+	void *rcu_read_dereference_key(struct key *key);
+
 
 ===================
 DEFINING A KEY TYPE
diff --git a/include/keys/user-type.h b/include/keys/user-type.h
index c56fef40f53e..521bf3369904 100644
--- a/include/keys/user-type.h
+++ b/include/keys/user-type.h
@@ -53,6 +53,11 @@ static inline const struct user_key_payload *user_key_payload(const struct key *
 	return (struct user_key_payload *)rcu_dereference_key(key);
 }
 
+static inline const struct user_key_payload *user_key_payload_rcu(const struct key *key)
+{
+	return (struct user_key_payload *)rcu_read_dereference_key(key);
+}
+
 #endif /* CONFIG_KEYS */
 
 #endif /* _KEYS_USER_TYPE_H */
diff --git a/include/linux/key.h b/include/linux/key.h
index 722914798f37..b6a8c5896761 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -358,6 +358,9 @@ static inline bool key_is_instantiated(const struct key *key)
 	(rcu_dereference_protected((KEY)->payload.rcu_data0,		\
 				   rwsem_is_locked(&((struct key *)(KEY))->sem)))
 
+#define rcu_read_dereference_key(KEY)                                   \
+	(rcu_dereference((KEY)->payload.rcu_data0))
+
 #define rcu_assign_keypointer(KEY, PAYLOAD)				\
 do {									\
 	rcu_assign_pointer((KEY)->payload.rcu_data0, (PAYLOAD));	\
-- 
1.8.3.1

