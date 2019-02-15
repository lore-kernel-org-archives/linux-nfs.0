Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C649C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:09:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CCA602192B
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:09:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391991AbfBOQJU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:09:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729649AbfBOQJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:09:19 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DD88CBF9FC;
        Fri, 15 Feb 2019 16:09:18 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B6D721024951;
        Fri, 15 Feb 2019 16:09:16 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 12/27] containers: Allow a daemon to intercept
 request_key upcalls in a container
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:09:16 +0000
Message-ID: <155024695603.21651.8408384800355761335.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 15 Feb 2019 16:09:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Provide a mechanism by which a running daemon can intercept request_key
upcalls, filtered by namespace and key type, and service them.  The list of
active services is per-container.

Intercepts for a specific {key_type, namespace} can be installed on a
container with:

	keyctl(KEYCTL_ADD_UPCALL_INTERCEPT,
	       int containerfd,
	       const char *type_name,
	       unsigned int ns_id,
	       key_serial_t dest_keyring);

The authentication token keys for intercepted keys are linked into the
destination keyring.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/container.h        |    2 
 include/linux/key-type.h         |    2 
 include/uapi/linux/keyctl.h      |    1 
 kernel/container.c               |    4 +
 security/keys/Makefile           |    2 
 security/keys/compat.c           |    5 +
 security/keys/container.c        |  227 ++++++++++++++++++++++++++++++++++++++
 security/keys/internal.h         |   10 ++
 security/keys/keyctl.c           |   14 ++
 security/keys/request_key.c      |   18 ++-
 security/keys/request_key_auth.c |    6 +
 11 files changed, 278 insertions(+), 13 deletions(-)
 create mode 100644 security/keys/container.c

diff --git a/include/linux/container.h b/include/linux/container.h
index 087aa1885ef7..a8cac800ce75 100644
--- a/include/linux/container.h
+++ b/include/linux/container.h
@@ -42,6 +42,7 @@ struct container {
 	struct list_head	members;	/* Member processes, guarded with ->lock */
 	struct list_head	child_link;	/* Link in parent->children */
 	struct list_head	children;	/* Child containers */
+	struct list_head	req_key_traps;	/* Traps for request-key upcalls */
 	wait_queue_head_t	waitq;		/* Someone waiting for init to exit waits here */
 	unsigned long		flags;
 #define CONTAINER_FLAG_INIT_STARTED	0	/* Init is started - certain ops now prohibited */
@@ -60,6 +61,7 @@ extern int copy_container(unsigned long flags, struct task_struct *tsk,
 			  struct container *container);
 extern void exit_container(struct task_struct *tsk);
 extern void put_container(struct container *c);
+extern long key_del_intercept(struct container *c, const char *type);
 
 static inline struct container *get_container(struct container *c)
 {
diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index 2148a6bf58f1..0e09dac53245 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -66,7 +66,7 @@ struct key_match_data {
  */
 struct key_type {
 	/* name of the type */
-	const char *name;
+	const char name[24];
 
 	/* default payload length for quota precalculation (optional)
 	 * - this can be used instead of calling key_payload_reserve(), that
diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index e9e7da849619..85e8fef89bba 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -68,6 +68,7 @@
 #define KEYCTL_PKEY_VERIFY		28	/* Verify a public key signature */
 #define KEYCTL_RESTRICT_KEYRING		29	/* Restrict keys allowed to link to a keyring */
 #define KEYCTL_WATCH_KEY		30	/* Watch a key or ring of keys for changes */
+#define KEYCTL_CONTAINER_INTERCEPT	31	/* Intercept upcalls inside a container */
 
 /* keyctl structures */
 struct keyctl_dh_params {
diff --git a/kernel/container.c b/kernel/container.c
index 360284db959b..33e41fe5050b 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -35,6 +35,7 @@ struct container init_container = {
 	.members.next	= &init_task.container_link,
 	.members.prev	= &init_task.container_link,
 	.children	= LIST_HEAD_INIT(init_container.children),
+	.req_key_traps	= LIST_HEAD_INIT(init_container.req_key_traps),
 	.flags		= (1 << CONTAINER_FLAG_INIT_STARTED),
 	.lock		= __SPIN_LOCK_UNLOCKED(init_container.lock),
 	.seq		= SEQCNT_ZERO(init_fs.seq),
@@ -53,6 +54,8 @@ void put_container(struct container *c)
 
 	while (c && refcount_dec_and_test(&c->usage)) {
 		BUG_ON(!list_empty(&c->members));
+		if (!list_empty(&c->req_key_traps))
+			key_del_intercept(c, NULL);
 		if (c->pid_ns)
 			put_pid_ns(c->pid_ns);
 		if (c->ns)
@@ -286,6 +289,7 @@ static struct container *alloc_container(const char __user *name)
 
 	INIT_LIST_HEAD(&c->members);
 	INIT_LIST_HEAD(&c->children);
+	INIT_LIST_HEAD(&c->req_key_traps);
 	init_waitqueue_head(&c->waitq);
 	spin_lock_init(&c->lock);
 	refcount_set(&c->usage, 1);
diff --git a/security/keys/Makefile b/security/keys/Makefile
index 9cef54064f60..24f5df27b1c2 100644
--- a/security/keys/Makefile
+++ b/security/keys/Makefile
@@ -16,6 +16,7 @@ obj-y := \
 	request_key.o \
 	request_key_auth.o \
 	user_defined.o
+
 compat-obj-$(CONFIG_KEY_DH_OPERATIONS) += compat_dh.o
 obj-$(CONFIG_KEYS_COMPAT) += compat.o $(compat-obj-y)
 obj-$(CONFIG_PROC_FS) += proc.o
@@ -23,6 +24,7 @@ obj-$(CONFIG_SYSCTL) += sysctl.o
 obj-$(CONFIG_PERSISTENT_KEYRINGS) += persistent.o
 obj-$(CONFIG_KEY_DH_OPERATIONS) += dh.o
 obj-$(CONFIG_ASYMMETRIC_KEY_TYPE) += keyctl_pkey.o
+obj-$(CONFIG_CONTAINERS) += container.o
 
 #
 # Key types
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 021d8e1c9233..6420881e5ce7 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -161,6 +161,11 @@ COMPAT_SYSCALL_DEFINE5(keyctl, u32, option,
 	case KEYCTL_WATCH_KEY:
 		return keyctl_watch_key(arg2, arg3, arg4);
 
+#ifdef CONFIG_CONTAINERS
+	case KEYCTL_CONTAINER_INTERCEPT:
+		return keyctl_container_intercept(arg2, compat_ptr(arg3), arg4, arg5);
+#endif
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/container.c b/security/keys/container.c
new file mode 100644
index 000000000000..c61c43658f3b
--- /dev/null
+++ b/security/keys/container.c
@@ -0,0 +1,227 @@
+/* Container intercept interface
+ *
+ * Copyright (C) 2019 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/key.h>
+#include <linux/key-type.h>
+#include <linux/container.h>
+#include <keys/request_key_auth-type.h>
+#include "internal.h"
+
+struct request_key_intercept {
+	char			type[32];	/* The type of key to be trapped */
+	struct list_head	link;		/* Link in containers->req_key_traps */
+	struct key		*dest_keyring;	/* Where to place the trapped auth keys */
+	struct ns_common	*ns;		/* Namespace the key must match */
+};
+
+/*
+ * Add an intercept filter to a container.
+ */
+static long key_add_intercept(struct container *c, struct request_key_intercept *rki)
+{
+	struct request_key_intercept *p;
+
+	kenter("%p,{%s,%d}", c, rki->type, key_serial(rki->dest_keyring));
+
+	spin_lock(&c->lock);
+	list_for_each_entry(p, &c->req_key_traps, link) {
+		if (strcmp(rki->type, p->type) == 0) {
+			spin_unlock(&c->lock);
+			return -EEXIST;
+		}
+	}
+
+	/* We put all-matching rules at the back so they're checked after the
+	 * more specific rules.
+	 */
+	if (rki->type[0] == '*' && !rki->type[1])
+		list_add_tail(&rki->link, &c->req_key_traps);
+	else
+		list_add(&rki->link, &c->req_key_traps);
+
+	spin_unlock(&c->lock);
+	kleave(" = 0");
+	return 0;
+}
+
+/*
+ * Remove one or more intercept filters from a container.  Returns the number
+ * of entries removed.
+ */
+long key_del_intercept(struct container *c, const char *type)
+{
+	struct request_key_intercept *p, *q;
+	long count;
+	LIST_HEAD(graveyard);
+
+	kenter("%p,%s", c, type);
+
+	spin_lock(&c->lock);
+	list_for_each_entry_safe(p, q, &c->req_key_traps, link) {
+		if (!type || strcmp(p->type, type) == 0) {
+			kdebug("- match %d", key_serial(p->dest_keyring));
+			list_move(&p->link, &graveyard);
+		}
+	}
+	spin_unlock(&c->lock);
+
+	count = 0;
+	while (!list_empty(&graveyard)) {
+		p = list_entry(graveyard.next, struct request_key_intercept, link);
+		list_del(&p->link);
+		count++;
+
+		key_put(p->dest_keyring);
+		kfree(p);
+	}
+
+	kleave(" = %ld", count);
+	return count;
+}
+
+/*
+ * Create an intercept filter and add it to a container.
+ */
+static long key_create_intercept(struct container *c, const char *type,
+				 key_serial_t dest_ring_id)
+{
+	struct request_key_intercept *rki;
+	key_ref_t dest_ref;
+	long ret = -ENOMEM;
+
+	dest_ref = lookup_user_key(dest_ring_id, KEY_LOOKUP_CREATE,
+				   KEY_NEED_WRITE);
+	if (IS_ERR(dest_ref))
+		return PTR_ERR(dest_ref);
+
+	rki = kzalloc(sizeof(*rki), GFP_KERNEL);
+	if (!rki)
+		goto out_dest;
+
+	memcpy(rki->type, type, sizeof(rki->type));
+	rki->dest_keyring = key_ref_to_ptr(dest_ref);
+	/* TODO: set rki->ns */
+
+	ret = key_add_intercept(c, rki);
+	if (ret < 0)
+		goto out_rki;
+	return ret;
+
+out_rki:
+ 	kfree(rki);
+out_dest:
+	key_ref_put(dest_ref);
+	return ret;
+}
+
+/*
+ * Add or remove (if dest_keyring==0) a request_key upcall intercept trap upon
+ * a container.  If _type points to a string of "*" that matches all types.
+ */
+long keyctl_container_intercept(int containerfd,
+				const char *_type,
+				unsigned int ns_id,
+				key_serial_t dest_ring_id)
+{
+	struct container *c;
+	struct fd f;
+	char type[32] = "";
+	long ret;
+
+	if (containerfd < 0 || ns_id < 0)
+		return -EINVAL;
+	if (dest_ring_id && !_type)
+		return -EINVAL;
+
+	f = fdget(containerfd);
+	if (!f.file)
+		return -EBADF;
+	ret = -EINVAL;
+	if (!is_container_file(f.file))
+		goto out_fd;
+
+	c = f.file->private_data;
+
+	/* Find out what type we're dealing with (can be NULL to make removal
+	 * remove everything).
+	 */
+	if (_type) {
+		ret = key_get_type_from_user(type, _type, sizeof(type));
+		if (ret < 0)
+			goto out_fd;
+	}
+
+	/* TODO: Get the namespace to filter on */
+
+	/* We add a filter if a destination keyring has been specified. */
+	if (dest_ring_id) {
+		ret = key_create_intercept(c, type, dest_ring_id);
+	} else {
+		ret = key_del_intercept(c, _type ? type : NULL);
+	}
+
+out_fd:
+	fdput(f);
+	return ret;
+}
+
+/*
+ * Queue a construction record if we can find a handler.
+ *
+ * Returns true if we found a handler - in which case ownership of the
+ * construction record has been passed on to the service queue and the caller
+ * can no longer touch it.
+ */
+int queue_request_key(struct key *authkey)
+{
+	struct container *c = current->container;
+	struct request_key_intercept *rki;
+	struct request_key_auth *rka = get_request_key_auth(authkey);
+	struct key *service_keyring;
+	struct key *key = rka->target_key;
+	int ret;
+
+	kenter("%p,%d,%d", c, key_serial(authkey), key_serial(key));
+
+	if (list_empty(&c->req_key_traps)) {
+		kleave(" = -EAGAIN [e]");
+		return -EAGAIN;
+	}
+
+	spin_lock(&c->lock);
+
+	list_for_each_entry(rki, &c->req_key_traps, link) {
+		if (strcmp(rki->type, "*") == 0 ||
+		    strcmp(rki->type, key->type->name) == 0)
+			goto found_match;
+	}
+
+	spin_unlock(&c->lock);
+	kleave(" = -EAGAIN [n]");
+	return -EAGAIN;
+
+found_match:
+	service_keyring = key_get(rki->dest_keyring);
+	kdebug("- match %d", key_serial(service_keyring));
+	spin_unlock(&c->lock);
+
+	/* We add the authentication key to the keyring for the service daemon
+	 * to collect.  This can be detected by means of a watch on the service
+	 * keyring.
+	 */
+	ret = key_link(service_keyring, authkey);
+	key_put(service_keyring);
+	kleave(" = %d", ret);
+	return ret;
+}
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 14c5b8ad5bd6..e98fca465146 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -93,6 +93,7 @@ extern wait_queue_head_t request_key_conswq;
 extern void key_set_index_key(struct keyring_index_key *index_key);
 extern struct key_type *key_type_lookup(const char *type);
 extern void key_type_put(struct key_type *ktype);
+extern int key_get_type_from_user(char *, const char __user *, unsigned);
 
 extern int __key_link_begin(struct key *keyring,
 			    const struct keyring_index_key *index_key,
@@ -180,6 +181,11 @@ extern void key_gc_keytype(struct key_type *ktype);
 extern int key_task_permission(const key_ref_t key_ref,
 			       const struct cred *cred,
 			       key_perm_t perm);
+#ifdef CONFIG_CONTAINERS
+extern int queue_request_key(struct key *);
+#else
+static inline int queue_request_key(struct key *authkey) { return -EAGAIN; }
+#endif
 
 static inline void notify_key(struct key *key,
 			      enum key_notification_subtype subtype, u32 aux)
@@ -354,6 +360,10 @@ static inline long keyctl_watch_key(key_serial_t key_id, int watch_fd, int watch
 }
 #endif
 
+#ifdef CONFIG_CONTAINERS
+extern long keyctl_container_intercept(int, const char __user *, unsigned int, key_serial_t);
+#endif
+
 /*
  * Debugging key validation
  */
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 94b99a52b4e5..38ff33431f33 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -30,9 +30,9 @@
 
 #define KEY_MAX_DESC_SIZE 4096
 
-static int key_get_type_from_user(char *type,
-				  const char __user *_type,
-				  unsigned len)
+int key_get_type_from_user(char *type,
+			   const char __user *_type,
+			   unsigned len)
 {
 	int ret;
 
@@ -1857,6 +1857,14 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case KEYCTL_WATCH_KEY:
 		return keyctl_watch_key((key_serial_t)arg2, (int)arg3, (int)arg4);
 
+#ifdef CONFIG_CONTAINERS
+	case KEYCTL_CONTAINER_INTERCEPT:
+		return keyctl_container_intercept((int)arg2,
+						  (const char __user *)arg3,
+						  (unsigned int)arg4,
+						  (key_serial_t)arg5);
+#endif
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index edfabf20bdbb..078767564283 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -17,6 +17,7 @@
 #include <linux/err.h>
 #include <linux/keyctl.h>
 #include <linux/slab.h>
+#include <linux/init_task.h>
 #include <net/net_namespace.h>
 #include "internal.h"
 #include <keys/request_key_auth-type.h>
@@ -91,11 +92,11 @@ static int call_usermodehelper_keys(const char *path, char **argv, char **envp,
  * Request userspace finish the construction of a key
  * - execute "/sbin/request-key <op> <key> <uid> <gid> <keyring> <keyring> <keyring>"
  */
-static int call_sbin_request_key(struct key *authkey, void *aux)
+static int call_sbin_request_key(struct key *authkey)
 {
 	static char const request_key[] = "/sbin/request-key";
 	struct request_key_auth *rka = get_request_key_auth(authkey);
-	const struct cred *cred = current_cred();
+	const struct cred *cred = rka->cred;
 	key_serial_t prkey, sskey;
 	struct key *key = rka->target_key, *keyring, *session;
 	char *argv[9], *envp[3], uid_str[12], gid_str[12];
@@ -203,7 +204,6 @@ static int construct_key(struct key *key, const void *callout_info,
 			 size_t callout_len, void *aux,
 			 struct key *dest_keyring)
 {
-	request_key_actor_t actor;
 	struct key *authkey;
 	int ret;
 
@@ -216,11 +216,13 @@ static int construct_key(struct key *key, const void *callout_info,
 		return PTR_ERR(authkey);
 
 	/* Make the call */
-	actor = call_sbin_request_key;
-	if (key->type->request_key)
-		actor = key->type->request_key;
-
-	ret = actor(authkey, aux);
+	if (key->type->request_key) {
+		ret = key->type->request_key(authkey, aux);
+	} else {
+		ret = queue_request_key(authkey);
+		if (ret == -EAGAIN)
+			ret = call_sbin_request_key(authkey);
+	}
 
 	/* check that the actor called complete_request_key() prior to
 	 * returning an error */
diff --git a/security/keys/request_key_auth.c b/security/keys/request_key_auth.c
index afc304e8b61e..cd75173cadad 100644
--- a/security/keys/request_key_auth.c
+++ b/security/keys/request_key_auth.c
@@ -123,6 +123,10 @@ static void free_request_key_auth(struct request_key_auth *rka)
 {
 	if (!rka)
 		return;
+
+	if (rka->target_key->state == KEY_IS_UNINSTANTIATED)
+		key_reject_and_link(rka->target_key, 0, -ENOKEY, NULL, NULL);
+
 	key_put(rka->target_key);
 	key_put(rka->dest_keyring);
 	if (rka->cred)
@@ -184,7 +188,7 @@ struct key *request_key_auth_new(struct key *target, const char *op,
 			goto error_free_rka;
 		}
 
-		irka = cred->request_key_auth->payload.data[0];
+		irka = get_request_key_auth(cred->request_key_auth);
 		rka->cred = get_cred(irka->cred);
 		rka->pid = irka->pid;
 

