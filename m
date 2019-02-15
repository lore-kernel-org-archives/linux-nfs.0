Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43E1EC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:11:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 120B621924
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:11:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387687AbfBOQLS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:11:18 -0500
Received: from mx1.redhat.com ([209.132.183.28]:48710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727273AbfBOQLS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:11:18 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 63187C610D;
        Fri, 15 Feb 2019 16:11:17 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 92C014115;
        Fri, 15 Feb 2019 16:10:51 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 20/27] container, keys: Add a container keyring
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:10:45 +0000
Message-ID: <155024704568.21651.12664692449080180818.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 15 Feb 2019 16:11:17 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Allow a container manager to attach keyrings to a container such that the
keys contained therein are searched by request_key() in addition to a
process's normal keyrings.  This allows the manager to install keys to
support filesystem decryption and authentication for superblocks inside the
container without requiring any active role being played by processes
inside of the container.

So, for example, a container could be created, a keyring added and then an
rxrpc-type key added to the keyring such that a container's root filesystem
and data filesystems can be brought in from secure AFS volumes.  It would
also be possible to put filesystem crypto keys in there such that Ext4
encrypted files could be decrypted - without the need to share the key
between other containers or let the key leak into the container.

Because the container manager retains control of the keyring, it can update
the contained keys as necessary to prevent expiration.  Note that the
keyring and keys in the keyring must grant Search permission directly to
the container object.

[!] Note that NFS, CIFS and other filesystems wishing to make use of this
    would have to get the token to use by calling request_key() on entry to
    its VFS methods and retain it in its file struct.

[!] Note that request_key() called from userspace does not look in the
    container keyring.

[!] Note that keys are now tagged with a tag that identifies the network
    namespace (or other domain of operation).  This allows keys to be
    provided in one keyring that allow the same thing but in different
    network namespaces.

The keyring should be created by the container manager and then set using:

	keyctl(KEYCTL_SET_CONTAINER_KEYRING, int containerfd,
	       key_serial_t keyring);

With this, request_key() inside the kernel searches:

	thread-keyring, process-keyring, session-keyring, container-keyring

[!] It may be worth setting a flag on a mountpoint to indicate whether to
    search the container keyring first or last.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/container.h    |    1 +
 include/uapi/linux/keyctl.h  |    1 +
 kernel/container.c           |    1 +
 samples/vfs/test-container.c |   14 +++++++++++++
 security/keys/compat.c       |    2 ++
 security/keys/container.c    |   44 ++++++++++++++++++++++++++++++++++++++++++
 security/keys/internal.h     |    1 +
 security/keys/keyctl.c       |    2 ++
 security/keys/process_keys.c |   23 ++++++++++++++++++++++
 9 files changed, 89 insertions(+)

diff --git a/include/linux/container.h b/include/linux/container.h
index a8cac800ce75..7424f7fb5560 100644
--- a/include/linux/container.h
+++ b/include/linux/container.h
@@ -33,6 +33,7 @@ struct container {
 	refcount_t		usage;
 	int			exit_code;	/* The exit code of 'init' */
 	const struct cred	*cred;		/* Creds for this container, including userns */
+	struct key		*keyring;	/* Externally managed container keyring */
 	struct nsproxy		*ns;		/* This container's namespaces */
 	struct path		root;		/* The root of the container's fs namespace */
 	struct task_struct	*init;		/* The 'init' task for this container */
diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index 5b792303a05b..a2afb4512f34 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -72,6 +72,7 @@
 #define KEYCTL_QUERY_REQUEST_KEY_AUTH	32	/* Query a request_key_auth key */
 #define KEYCTL_MOVE			33	/* Move keys between keyrings */
 #define KEYCTL_FIND_LRU			34	/* Find the least-recently used key in a keyring */
+#define KEYCTL_SET_CONTAINER_KEYRING	35	/* Attach a keyring to a container */
 
 /* keyctl structures */
 struct keyctl_dh_params {
diff --git a/kernel/container.c b/kernel/container.c
index 33e41fe5050b..f2706a45f364 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -71,6 +71,7 @@ void put_container(struct container *c)
 
 		if (c->cred)
 			put_cred(c->cred);
+		key_put(c->keyring);
 		security_container_free(c);
 		kfree(c);
 		c = parent;
diff --git a/samples/vfs/test-container.c b/samples/vfs/test-container.c
index 7dc9071399b2..e24048fdbe33 100644
--- a/samples/vfs/test-container.c
+++ b/samples/vfs/test-container.c
@@ -21,6 +21,7 @@
 #include <keyutils.h>
 
 #define KEYCTL_CONTAINER_INTERCEPT	31	/* Intercept upcalls inside a container */
+#define KEYCTL_SET_CONTAINER_KEYRING	35	/* Attach a keyring to a container */
 
 /* Hope -1 isn't a syscall */
 #ifndef __NR_fsopen
@@ -262,6 +263,19 @@ int main(int argc, char *argv[])
 	E(close(fsfd));
 	E(close(mfd));
 
+	/* Create a container keyring. */
+	printf("Container keyring...\n");
+	keyring = add_key("keyring", "_container", NULL, 0, KEY_SPEC_SESSION_KEYRING);
+	if (keyring == -1) {
+		perror("add_key/c");
+		exit(1);
+	}
+
+	if (keyctl(KEYCTL_SET_CONTAINER_KEYRING, cfd, keyring) < 0) {
+		perror("keyctl_set_container_keyring");
+		exit(1);
+	}
+
 	/* Create a keyring to catch upcalls. */
 	printf("Intercepting...\n");
 	keyring = add_key("keyring", "upcall", NULL, 0, KEY_SPEC_SESSION_KEYRING);
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 160fb7b37352..7990ec026237 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -168,6 +168,8 @@ COMPAT_SYSCALL_DEFINE5(keyctl, u32, option,
 		return keyctl_query_request_key_auth(arg2, compat_ptr(arg3));
 	case KEYCTL_FIND_LRU:
 		return keyctl_find_lru(arg2, compat_ptr(arg3));
+	case KEYCTL_SET_CONTAINER_KEYRING:
+		return keyctl_set_container_keyring(arg2, arg3);
 #endif
 
 	case KEYCTL_MOVE:
diff --git a/security/keys/container.c b/security/keys/container.c
index 8e6b3c8710e2..720600f6a318 100644
--- a/security/keys/container.c
+++ b/security/keys/container.c
@@ -373,3 +373,47 @@ long keyctl_find_lru(key_serial_t _keyring, const char __user *type_name)
 	key_ref_put(keyring_ref);
 	return ret;
 }
+
+/*
+ * Attach a keyring to a container as the container key, to be searched by
+ * request_key() after thread, process and session keyrings.  This is only
+ * permitted once per container.
+ */
+long keyctl_set_container_keyring(int containerfd, key_serial_t _keyring)
+{
+	struct container *c;
+	struct fd f;
+	key_ref_t keyring_ref = NULL;
+	long ret;
+
+	if (containerfd < 0 || _keyring <= 0)
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
+	keyring_ref = lookup_user_key(_keyring, 0, KEY_NEED_SEARCH);
+	if (IS_ERR(keyring_ref)) {
+		ret = PTR_ERR(keyring_ref);
+		goto out_fd;
+	}
+
+	ret = -EBUSY;
+	spin_lock(&c->lock);
+	if (!c->keyring) {
+		c->keyring = key_get(key_ref_to_ptr(keyring_ref));
+		ret = 0;
+	}
+	spin_unlock(&c->lock);
+
+	key_ref_put(keyring_ref);
+out_fd:
+	fdput(f);
+	return ret;
+}
diff --git a/security/keys/internal.h b/security/keys/internal.h
index fe4a4da1ff17..6be76caee874 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -366,6 +366,7 @@ extern long keyctl_container_intercept(int, const char __user *, unsigned int, k
 extern long keyctl_query_request_key_auth(key_serial_t,
 					  struct keyctl_query_request_key_auth __user *);
 extern long keyctl_find_lru(key_serial_t, const char __user *);
+extern long keyctl_set_container_keyring(int, key_serial_t);
 #endif
 
 /*
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 1446bc52e369..a25799249b8a 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -1919,6 +1919,8 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case KEYCTL_FIND_LRU:
 		return keyctl_find_lru((key_serial_t)arg2,
 				       (const char __user *)arg3);
+	case KEYCTL_SET_CONTAINER_KEYRING:
+		return keyctl_set_container_keyring((int)arg2, (key_serial_t)arg3);
 #endif
 
 	case KEYCTL_MOVE:
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 0e0b9ccad2f8..39d3cbac920c 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -17,6 +17,7 @@
 #include <linux/err.h>
 #include <linux/mutex.h>
 #include <linux/security.h>
+#include <linux/container.h>
 #include <linux/user_namespace.h>
 #include <linux/uaccess.h>
 #include <keys/request_key_auth-type.h>
@@ -433,6 +434,28 @@ key_ref_t search_my_process_keyrings(struct keyring_search_context *ctx)
 		}
 	}
 
+	/* Search any container keyring on the end. */
+#ifdef CONFIG_CONTAINERS
+	if (current->container->keyring) {
+		key_ref = keyring_search_aux(
+			make_key_ref(current->container->keyring, 1), ctx);
+		if (!IS_ERR(key_ref))
+			goto found;
+
+		switch (PTR_ERR(key_ref)) {
+		case -EAGAIN: /* no key */
+			if (ret)
+				break;
+		case -ENOKEY: /* negative key */
+			ret = key_ref;
+			break;
+		default:
+			err = key_ref;
+			break;
+		}
+	}
+#endif
+
 	/* no key - decide on the error we're going to go for */
 	key_ref = ret ? ret : err;
 

