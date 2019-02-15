Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 986D6C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:11:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5DC4A21924
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:11:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2404320AbfBOQLz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:11:55 -0500
Received: from mx1.redhat.com ([209.132.183.28]:47363 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2404036AbfBOQLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:11:54 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B7707C0AD406;
        Fri, 15 Feb 2019 16:11:53 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 899475D6A9;
        Fri, 15 Feb 2019 16:11:51 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 24/27] keys: Allow a container to be specified as a
 subject in a key's ACL
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:11:50 +0000
Message-ID: <155024711079.21651.7490587069155188367.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 16:11:54 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Allow the ACL attached to a key to grant permissions to the denizens of a
container object when request_key() is called.  This allows separate
permissions to those granted in the possessor set.

	int cfd = container_create("foo", 0);

	int ret = keyctl_grant_permission(key,
					  KEY_ACE_SUBJ_CONTAINER,
					  cfd,
					  KEY_ACE_SEARCH);

To allow request_key() to find a key, KEY_ACE_SEARCH must be included in
the ACE.  This will allow filesystems and network protocols (eg. AFS and
AF_RXRPC) to use the key.  For the request_key() system call to be able to
find a key for a process inside the container, KEY_ACE_LINK must be granted
also.

Keys on the container keyring (and the container keyring itself) can be
accessed directly by ID from inside the container if other KEY_ACE_*
permits are granted.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/container.h    |    6 ++-
 include/linux/key.h          |    3 +
 include/uapi/linux/keyctl.h  |    1 
 kernel/container.c           |   41 ++++++++++++++++++-
 samples/vfs/test-container.c |   60 ++++++++++++++++++++++++++++
 security/keys/permission.c   |   90 ++++++++++++++++++++++++++++++++++++++----
 security/keys/process_keys.c |    2 -
 7 files changed, 188 insertions(+), 15 deletions(-)

diff --git a/include/linux/container.h b/include/linux/container.h
index 7424f7fb5560..cd82074c26a3 100644
--- a/include/linux/container.h
+++ b/include/linux/container.h
@@ -33,7 +33,11 @@ struct container {
 	refcount_t		usage;
 	int			exit_code;	/* The exit code of 'init' */
 	const struct cred	*cred;		/* Creds for this container, including userns */
+#ifdef CONFIG_KEYS
 	struct key		*keyring;	/* Externally managed container keyring */
+	struct key_tag		*tag;		/* Container ID for key ACL */
+	struct list_head	req_key_traps;	/* Traps for request-key upcalls */
+#endif
 	struct nsproxy		*ns;		/* This container's namespaces */
 	struct path		root;		/* The root of the container's fs namespace */
 	struct task_struct	*init;		/* The 'init' task for this container */
@@ -43,7 +47,6 @@ struct container {
 	struct list_head	members;	/* Member processes, guarded with ->lock */
 	struct list_head	child_link;	/* Link in parent->children */
 	struct list_head	children;	/* Child containers */
-	struct list_head	req_key_traps;	/* Traps for request-key upcalls */
 	wait_queue_head_t	waitq;		/* Someone waiting for init to exit waits here */
 	unsigned long		flags;
 #define CONTAINER_FLAG_INIT_STARTED	0	/* Init is started - certain ops now prohibited */
@@ -63,6 +66,7 @@ extern int copy_container(unsigned long flags, struct task_struct *tsk,
 extern void exit_container(struct task_struct *tsk);
 extern void put_container(struct container *c);
 extern long key_del_intercept(struct container *c, const char *type);
+extern struct container *fd_to_container(int fd);
 
 static inline struct container *get_container(struct container *c)
 {
diff --git a/include/linux/key.h b/include/linux/key.h
index a38b89bd414c..01bccaa40047 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -90,6 +90,9 @@ struct key_ace {
 		kuid_t		uid;
 		kgid_t		gid;
 		unsigned int	subject_id;
+#ifdef CONFIG_CONTAINERS
+		struct key_tag __rcu *container_tag;
+#endif
 	};
 };
 
diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index 045dcbb6bb8d..7136d14dd4d7 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -20,6 +20,7 @@
  */
 enum key_ace_subject_type {
 	KEY_ACE_SUBJ_STANDARD	= 0,	/* subject is one of key_ace_standard_subject */
+	KEY_ACE_SUBJ_CONTAINER	= 1,	/* subject is a container fd */
 	nr__key_ace_subject_type
 };
 
diff --git a/kernel/container.c b/kernel/container.c
index f2706a45f364..81be4ed915c2 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -35,7 +35,9 @@ struct container init_container = {
 	.members.next	= &init_task.container_link,
 	.members.prev	= &init_task.container_link,
 	.children	= LIST_HEAD_INIT(init_container.children),
+#ifdef CONFIG_KEYS
 	.req_key_traps	= LIST_HEAD_INIT(init_container.req_key_traps),
+#endif
 	.flags		= (1 << CONTAINER_FLAG_INIT_STARTED),
 	.lock		= __SPIN_LOCK_UNLOCKED(init_container.lock),
 	.seq		= SEQCNT_ZERO(init_fs.seq),
@@ -54,8 +56,6 @@ void put_container(struct container *c)
 
 	while (c && refcount_dec_and_test(&c->usage)) {
 		BUG_ON(!list_empty(&c->members));
-		if (!list_empty(&c->req_key_traps))
-			key_del_intercept(c, NULL);
 		if (c->pid_ns)
 			put_pid_ns(c->pid_ns);
 		if (c->ns)
@@ -71,7 +71,15 @@ void put_container(struct container *c)
 
 		if (c->cred)
 			put_cred(c->cred);
+#ifdef CONFIG_KEYS
+		if (!list_empty(&c->req_key_traps))
+			key_del_intercept(c, NULL);
+		if (c->tag) {
+			c->tag->removed = true;
+			key_put_tag(c->tag);
+		}
 		key_put(c->keyring);
+#endif
 		security_container_free(c);
 		kfree(c);
 		c = parent;
@@ -209,6 +217,24 @@ const struct file_operations container_fops = {
 	.release	= container_release,
 };
 
+/**
+ * fd_to_container - Get the container attached to an fd.
+ */
+struct container *fd_to_container(int fd)
+{
+	struct container *c = ERR_PTR(-EINVAL);
+	struct fd f = fdget(fd);
+
+	if (!f.file)
+		return ERR_PTR(-EBADF);
+
+	if (is_container_file(f.file))
+		c = get_container(f.file->private_data);
+
+	fdput(f);
+	return c;
+}
+
 /*
  * Handle fork/clone.
  *
@@ -290,7 +316,9 @@ static struct container *alloc_container(const char __user *name)
 
 	INIT_LIST_HEAD(&c->members);
 	INIT_LIST_HEAD(&c->children);
+#ifdef CONFIG_KEYS
 	INIT_LIST_HEAD(&c->req_key_traps);
+#endif
 	init_waitqueue_head(&c->waitq);
 	spin_lock_init(&c->lock);
 	refcount_set(&c->usage, 1);
@@ -305,8 +333,15 @@ static struct container *alloc_container(const char __user *name)
 	ret = -EINVAL;
 	if (strchr(c->name, '/'))
 		goto err;
-
 	c->name[len] = 0;
+
+#ifdef CONFIG_KEYS
+	ret = -ENOMEM;
+	c->tag = kzalloc(sizeof(*c->tag), GFP_KERNEL);
+	if (!c->tag)
+		goto err;
+	refcount_set(&c->tag->usage, 1);
+#endif
 	return c;
 
 err:
diff --git a/samples/vfs/test-container.c b/samples/vfs/test-container.c
index e24048fdbe33..7b2081693fce 100644
--- a/samples/vfs/test-container.c
+++ b/samples/vfs/test-container.c
@@ -22,6 +22,30 @@
 
 #define KEYCTL_CONTAINER_INTERCEPT	31	/* Intercept upcalls inside a container */
 #define KEYCTL_SET_CONTAINER_KEYRING	35	/* Attach a keyring to a container */
+#define KEYCTL_GRANT_PERMISSION		36	/* Grant a permit to a key */
+
+enum key_ace_subject_type {
+	KEY_ACE_SUBJ_STANDARD	= 0,	/* subject is one of key_ace_standard_subject */
+	KEY_ACE_SUBJ_CONTAINER	= 1,	/* subject is a container fd */
+};
+
+enum key_ace_standard_subject {
+	KEY_ACE_EVERYONE	= 0,	/* Everyone, including owner and group */
+	KEY_ACE_GROUP		= 1,	/* The key's group */
+	KEY_ACE_OWNER		= 2,	/* The owner of the key */
+	KEY_ACE_POSSESSOR	= 3,	/* Any process that possesses of the key */
+};
+
+#define KEY_ACE_VIEW		0x00000001 /* Can describe the key */
+#define KEY_ACE_READ		0x00000002 /* Can read the key content */
+#define KEY_ACE_WRITE		0x00000004 /* Can update/modify the key content */
+#define KEY_ACE_SEARCH		0x00000008 /* Can find the key by search */
+#define KEY_ACE_LINK		0x00000010 /* Can make a link to the key */
+#define KEY_ACE_SET_SECURITY	0x00000020 /* Can set owner, group, ACL */
+#define KEY_ACE_INVAL		0x00000040 /* Can invalidate the key */
+#define KEY_ACE_REVOKE		0x00000080 /* Can revoke the key */
+#define KEY_ACE_JOIN		0x00000100 /* Can join keyring */
+#define KEY_ACE_CLEAR		0x00000200 /* Can clear keyring */
 
 /* Hope -1 isn't a syscall */
 #ifndef __NR_fsopen
@@ -190,7 +214,7 @@ void container_init(void)
  */
 int main(int argc, char *argv[])
 {
-	key_serial_t keyring;
+	key_serial_t keyring, key;
 	pid_t pid;
 	int fsfd, mfd, cfd, ws;
 
@@ -271,11 +295,45 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	/* We need to grant the container permission to search for keys in the
+	 * container keyring.
+	 */
+	if (keyctl(KEYCTL_GRANT_PERMISSION, keyring, KEY_ACE_SUBJ_CONTAINER, cfd,
+		   KEY_ACE_SEARCH) < 0) {
+		perror("keyctl_grant/s");
+		exit(1);
+	}
+
+	if (keyctl(KEYCTL_GRANT_PERMISSION, keyring,
+		   KEY_ACE_SUBJ_STANDARD, KEY_ACE_OWNER, 0) < 0) {
+		perror("keyctl_grant/s");
+		exit(1);
+	}
+
 	if (keyctl(KEYCTL_SET_CONTAINER_KEYRING, cfd, keyring) < 0) {
 		perror("keyctl_set_container_keyring");
 		exit(1);
 	}
 
+	/* Create a key that can be accessed from within the container */
+	printf("Sample key...\n");
+	key = add_key("user", "foobar", "wibble", 6, keyring);
+	if (key == -1) {
+		perror("add_key/s");
+		exit(1);
+	}
+
+	if (keyctl(KEYCTL_GRANT_PERMISSION, key, KEY_ACE_SUBJ_CONTAINER, cfd,
+		   KEY_ACE_VIEW | KEY_ACE_SEARCH | KEY_ACE_READ | KEY_ACE_LINK) < 0) {
+		perror("keyctl_grant/s");
+		exit(1);
+	}
+
+	if (keyctl_link(key, keyring) < 0) {
+		perror("keyctl_link");
+		exit(1);
+	}
+
 	/* Create a keyring to catch upcalls. */
 	printf("Intercepting...\n");
 	keyring = add_key("keyring", "upcall", NULL, 0, KEY_SPEC_SESSION_KEYRING);
diff --git a/security/keys/permission.c b/security/keys/permission.c
index cb1359f6c668..f16d1665885f 100644
--- a/security/keys/permission.c
+++ b/security/keys/permission.c
@@ -13,6 +13,7 @@
 #include <linux/security.h>
 #include <linux/user_namespace.h>
 #include <linux/uaccess.h>
+#include <linux/container.h>
 #include "internal.h"
 
 struct key_acl default_key_acl = {
@@ -130,6 +131,15 @@ int key_task_permission(const key_ref_t key_ref, const struct cred *cred,
 				break;
 			}
 			break;
+#ifdef CONFIG_CONTAINERS
+		case KEY_ACE_SUBJ_CONTAINER: {
+			const struct key_tag *tag = rcu_dereference(ace->container_tag);
+
+			if (!tag->removed && current->container->tag == tag)
+				allow |= ace->perm;
+			break;
+		}
+#endif
 		}
 	}
 
@@ -185,8 +195,7 @@ EXPORT_SYMBOL(key_validate);
  */
 unsigned int key_acl_to_perm(const struct key_acl *acl)
 {
-	unsigned int perm = 0, tperm;
-	int i;
+	unsigned int perm = 0, tperm, i;
 
 	BUILD_BUG_ON(KEY_OTH_VIEW	!= KEY_ACE_VIEW		||
 		     KEY_OTH_READ	!= KEY_ACE_READ		||
@@ -237,13 +246,37 @@ unsigned int key_acl_to_perm(const struct key_acl *acl)
 	return perm;
 }
 
+/*
+ * Clean up an ACL.
+ */
+static void key_free_acl(struct rcu_head *rcu)
+{
+	struct key_acl *acl = container_of(rcu, struct key_acl, rcu);
+#ifdef CONFIG_CONTAINERS
+	struct key_tag *tag;
+	unsigned int i;
+
+	for (i = 0; i < acl->nr_ace; i++) {
+		const struct key_ace *ace = &acl->aces[i];
+		switch (ace->type) {
+		case KEY_ACE_SUBJ_CONTAINER:
+			tag = rcu_access_pointer(ace->container_tag);
+			key_put_tag(ace->container_tag);
+			break;
+		}
+	}
+#endif
+
+	kfree(acl);
+}
+
 /*
  * Destroy a key's ACL.
  */
 void key_put_acl(struct key_acl *acl)
 {
 	if (acl && refcount_dec_and_test(&acl->usage))
-		kfree_rcu(acl, rcu);
+		call_rcu(&acl->rcu, key_free_acl);
 }
 
 /*
@@ -297,6 +330,10 @@ static struct key_acl *key_alloc_acl(const struct key_acl *old_acl, int nr, int
 		if (i == skip)
 			continue;
 		acl->aces[j] = old_acl->aces[i];
+#ifdef CONFIG_CONTAINERS
+		if (acl->aces[j].type == KEY_ACE_SUBJ_CONTAINER)
+			refcount_inc(&acl->aces[j].container_tag->usage);
+#endif
 		j++;
 	}
 	return acl;
@@ -312,21 +349,39 @@ static long key_change_acl(struct key *key, struct key_ace *new_ace)
 
 	old = rcu_dereference_protected(key->acl, lockdep_is_held(&key->sem));
 
-	for (i = 0; i < old->nr_ace; i++)
-		if (old->aces[i].type == new_ace->type &&
-		    old->aces[i].subject_id == new_ace->subject_id)
-			goto found_match;
+	for (i = 0; i < old->nr_ace; i++) {
+		if (old->aces[i].type != new_ace->type)
+			continue;
+		switch (old->aces[i].type) {
+		case KEY_ACE_SUBJ_STANDARD:
+			if (old->aces[i].subject_id == new_ace->subject_id)
+				goto replace_ace;
+			break;
+#ifdef CONFIG_CONTAINERS
+		case KEY_ACE_SUBJ_CONTAINER:
+			if (old->aces[i].container_tag == new_ace->container_tag)
+				goto replace_ace;
+			break;
+#endif
+		default:
+			break;
+		}
+	}
 
 	if (new_ace->perm == 0)
-		return 0; /* No permissions to remove.  Add deny record? */
+		return 0; /* No permissions to cancel.  Add deny record? */
 
 	acl = key_alloc_acl(old, 1, -1);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 	acl->aces[i] = *new_ace;
+#ifdef CONFIG_CONTAINERS
+	if (acl->aces[i].type == KEY_ACE_SUBJ_CONTAINER)
+		refcount_inc(&acl->aces[i].container_tag->usage);
+#endif
 	goto change;
 
-found_match:
+replace_ace:
 	if (new_ace->perm == 0)
 		goto delete_ace;
 	if (new_ace->perm == old->aces[i].perm)
@@ -360,6 +415,7 @@ long keyctl_grant_permission(key_serial_t keyid,
 	key_ref_t key_ref;
 	long ret;
 
+	memset(&new_ace, 0, sizeof(new_ace));
 	new_ace.type = type;
 	new_ace.perm = perm;
 
@@ -370,6 +426,18 @@ long keyctl_grant_permission(key_serial_t keyid,
 		new_ace.subject_id = subject;
 		break;
 
+#ifdef CONFIG_CONTAINERS
+	case KEY_ACE_SUBJ_CONTAINER: {
+		struct container *c = fd_to_container(subject);
+		if (IS_ERR(c))
+			return -EINVAL;
+		refcount_inc(&c->tag->usage);
+		new_ace.container_tag = c->tag;
+		put_container(c);
+		break;
+	}
+#endif
+
 	default:
 		return -ENOENT;
 	}
@@ -391,5 +459,9 @@ long keyctl_grant_permission(key_serial_t keyid,
 	up_write(&key->sem);
 	key_put(key);
 error:
+#ifdef CONFIG_CONTAINERS
+	if (new_ace.type == KEY_ACE_SUBJ_CONTAINER && new_ace.container_tag)
+		key_put_tag(new_ace.container_tag);
+#endif
 	return ret;
 }
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 0a231ede4d2b..f296a1cc979a 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -466,7 +466,7 @@ key_ref_t search_my_process_keyrings(struct keyring_search_context *ctx)
 #ifdef CONFIG_CONTAINERS
 	if (current->container->keyring) {
 		key_ref = keyring_search_aux(
-			make_key_ref(current->container->keyring, 1), ctx);
+			make_key_ref(current->container->keyring, false), ctx);
 		if (!IS_ERR(key_ref))
 			goto found;
 

