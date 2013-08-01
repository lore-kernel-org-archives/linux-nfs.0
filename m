Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab3HARi6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 13:38:58 -0400
Subject: [PATCH 1/2] KEYS: Implement a big key type that can save to tmpfs
To: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org
From: David Howells <dhowells@redhat.com>
Cc: krbdev@mit.edu, linux-kernel@vger.kernel.org, simo@redhat.com
Date: Thu, 01 Aug 2013 18:38:54 +0100
Message-ID: <20130801173854.28023.82045.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement a big key type that can save its contents to tmpfs and thus
swapspace when memory is tight.  This is useful for Kerberos ticket caches.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/keys/big_key-type.h |   27 ++++++
 include/linux/key.h         |    1 
 security/keys/Kconfig       |   11 +++
 security/keys/Makefile      |    1 
 security/keys/big_key.c     |  181 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 221 insertions(+)
 create mode 100644 include/keys/big_key-type.h
 create mode 100644 security/keys/big_key.c

diff --git a/include/keys/big_key-type.h b/include/keys/big_key-type.h
new file mode 100644
index 0000000..6610d46
--- /dev/null
+++ b/include/keys/big_key-type.h
@@ -0,0 +1,27 @@
+/* Big capacity key type.
+ *
+ * Copyright (C) 2013 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _KEYS_BIG_KEY_TYPE_H
+#define _KEYS_BIG_KEY_TYPE_H
+
+#include <linux/key-type.h>
+
+extern struct key_type key_type_big_key;
+
+struct key_preparsed_payload;
+
+extern int big_key_instantiate(struct key *key, struct key_preparsed_payload *prep);
+extern void big_key_revoke(struct key *key);
+extern void big_key_destroy(struct key *key);
+extern void big_key_describe(const struct key *big_key, struct seq_file *m);
+extern long big_key_read(const struct key *key, char __user *buffer, size_t buflen);
+
+#endif /* _KEYS_BIG_KEY_TYPE_H */
diff --git a/include/linux/key.h b/include/linux/key.h
index 2417f78..010dbb6 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -201,6 +201,7 @@ struct key {
 			unsigned long		value;
 			void __rcu		*rcudata;
 			void			*data;
+			void			*data2[2];
 		} payload;
 		struct assoc_array keys;
 	};
diff --git a/security/keys/Kconfig b/security/keys/Kconfig
index 15e0dfe..eafb335 100644
--- a/security/keys/Kconfig
+++ b/security/keys/Kconfig
@@ -20,6 +20,17 @@ config KEYS
 
 	  If you are unsure as to whether this is required, answer N.
 
+config BIG_KEYS
+	tristate "Large payload keys"
+	depends on KEYS
+	select TMPFS
+	help
+	  This option provides support for holding large keys within the kernel
+	  (for example Kerberos ticket caches).  The data may be stored out to
+	  swapspace by tmpfs.
+
+	  If you are unsure as to whether this is required, answer N.
+
 config TRUSTED_KEYS
 	tristate "TRUSTED KEYS"
 	depends on KEYS && TCG_TPM
diff --git a/security/keys/Makefile b/security/keys/Makefile
index 504aaa0..c487c77 100644
--- a/security/keys/Makefile
+++ b/security/keys/Makefile
@@ -22,5 +22,6 @@ obj-$(CONFIG_SYSCTL) += sysctl.o
 #
 # Key types
 #
+obj-$(CONFIG_BIG_KEYS) += big_key.o
 obj-$(CONFIG_TRUSTED_KEYS) += trusted.o
 obj-$(CONFIG_ENCRYPTED_KEYS) += encrypted-keys/
diff --git a/security/keys/big_key.c b/security/keys/big_key.c
new file mode 100644
index 0000000..bd19afc
--- /dev/null
+++ b/security/keys/big_key.c
@@ -0,0 +1,181 @@
+/* Big capacity key type
+ *
+ * Copyright (C) 2013 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/seq_file.h>
+#include <linux/file.h>
+#include <linux/shmem_fs.h>
+#include <linux/err.h>
+#include <keys/user-type.h>
+#include <keys/big_key-type.h>
+
+MODULE_LICENSE("GPL");
+
+/*
+ * big_key defined keys take an arbitrary string as the description and an
+ * arbitrary blob of data as the payload
+ */
+struct key_type key_type_big_key = {
+	.name			= "big_key",
+	.def_lookup_type	= KEYRING_SEARCH_LOOKUP_DIRECT,
+	.instantiate		= big_key_instantiate,
+	.match			= user_match,
+	.revoke			= big_key_revoke,
+	.destroy		= big_key_destroy,
+	.describe		= big_key_describe,
+	.read			= big_key_read,
+};
+
+/*
+ * Instantiate a big key
+ */
+int big_key_instantiate(struct key *key, struct key_preparsed_payload *prep)
+{
+	struct path *path = (struct path *)&key->payload.data2;
+	struct file *file;
+	ssize_t written;
+	size_t datalen = prep->datalen;
+	int ret;
+
+	ret = -EINVAL;
+	if (datalen <= 0 || datalen > 1024 * 1024 || !prep->data)
+		goto error;
+
+	/* Set an arbitrary quota */
+	ret = key_payload_reserve(key, 16);
+	if (ret < 0)
+		goto error;
+
+	/* Create a shmem file to store the data in.  This will permit the data
+	 * to be swapped out if needed.
+	 *
+	 * TODO: Encrypt the stored data with a temporary key.
+	 */
+	file = shmem_file_setup("", datalen, 0);
+	if (IS_ERR(file))
+		goto err_quota;
+
+	written = kernel_write(file, prep->data, prep->datalen, 0);
+	if (written != datalen) {
+		if (written >= 0)
+			ret = -ENOMEM;
+		goto err_fput;
+	}
+
+	/* Pin the mount and dentry to the key so that we can open it again
+	 * later
+	 */
+	*path = file->f_path;
+	path_get(path);
+	fput(file);
+	return 0;
+
+err_fput:
+	fput(file);
+err_quota:
+	key_payload_reserve(key, 0);
+error:
+	return ret;
+}
+
+/*
+ * match big_keys on their name
+ */
+int big_key_match(const struct key *key, const void *description)
+{
+	return strcmp(key->description, description) == 0;
+}
+
+/*
+ * dispose of the links from a revoked keyring
+ * - called with the key sem write-locked
+ */
+void big_key_revoke(struct key *key)
+{
+	struct path *path = (struct path *)&key->payload.data2;
+
+	/* clear the quota */
+	key_payload_reserve(key, 0);
+	if (key_is_instantiated(key))
+		vfs_truncate(path, 0);
+}
+
+/*
+ * dispose of the data dangling from the corpse of a big_key key
+ */
+void big_key_destroy(struct key *key)
+{
+	struct path *path = (struct path *)&key->payload.data2;
+	path_put(path);
+	path->mnt = NULL;
+	path->dentry = NULL;
+}
+
+/*
+ * describe the big_key key
+ */
+void big_key_describe(const struct key *key, struct seq_file *m)
+{
+	struct path *path = (struct path *)&key->payload.data2;
+	struct dentry *dentry = path->dentry;
+	struct inode *inode = dentry ? dentry->d_inode : NULL;
+
+	seq_puts(m, key->description);
+
+	if (inode &&
+	    key_is_instantiated(key) &&
+	    !test_bit(KEY_FLAG_REVOKED, &key->flags))
+		seq_printf(m, ": %llu", i_size_read(inode));
+}
+
+/*
+ * read the key data
+ * - the key's semaphore is read-locked
+ */
+long big_key_read(const struct key *key, char __user *buffer, size_t buflen)
+{
+	struct path *path = (struct path *)&key->payload.data2;
+	struct file *file;
+	loff_t pos, size = i_size_read(path->dentry->d_inode);
+	long ret;
+
+	ret = size;
+	if (buffer && buflen >= size) {
+		file = dentry_open(path, O_RDONLY, current_cred());
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+
+		pos = 0;
+		ret = vfs_read(file, buffer, size, &pos);
+		fput(file);
+		if (ret >= 0 && ret != size)
+			return -EIO;
+	}
+
+	return ret;
+}
+
+/*
+ * Module stuff
+ */
+static int __init big_key_init(void)
+{
+	return register_key_type(&key_type_big_key);
+}
+
+static void __exit big_key_cleanup(void)
+{
+	unregister_key_type(&key_type_big_key);
+}
+
+module_init(big_key_init);
+module_exit(big_key_cleanup);

