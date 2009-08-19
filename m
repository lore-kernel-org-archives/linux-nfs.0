From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4 referrals
 and migration
Date: Wed, 19 Aug 2009 19:38:53 -0400
Message-ID: <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075AbZHSXkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:55 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePRX001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:43 -0700 (PDT)
In-Reply-To: <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 and NFSv4.1 protocols both allow for the redirection of a client
from one server to another in order to support filesystem migration and
replication. For full protocol support, we need to add the ability to
convert a DNS host name into an IP address that we can feed to the RPC
client.

We'll reuse the sunrpc cache, now that it has been converted to work with
rpc_pipefs.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 Documentation/filesystems/nfs.txt   |   98 ++++++++++
 Documentation/kernel-parameters.txt |    8 +
 fs/nfs/Makefile                     |    3 +-
 fs/nfs/cache_lib.c                  |  140 +++++++++++++++
 fs/nfs/cache_lib.h                  |   27 +++
 fs/nfs/dns_resolve.c                |  335 +++++++++++++++++++++++++++++++++++
 fs/nfs/dns_resolve.h                |   14 ++
 fs/nfs/inode.c                      |    8 +
 net/sunrpc/rpc_pipe.c               |    7 +
 9 files changed, 639 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/filesystems/nfs.txt
 create mode 100644 fs/nfs/cache_lib.c
 create mode 100644 fs/nfs/cache_lib.h
 create mode 100644 fs/nfs/dns_resolve.c
 create mode 100644 fs/nfs/dns_resolve.h

diff --git a/Documentation/filesystems/nfs.txt b/Documentation/filesystems/nfs.txt
new file mode 100644
index 0000000..f50f26c
--- /dev/null
+++ b/Documentation/filesystems/nfs.txt
@@ -0,0 +1,98 @@
+
+The NFS client
+==============
+
+The NFS version 2 protocol was first documented in RFC1094 (March 1989).
+Since then two more major releases of NFS have been published, with NFSv3
+being documented in RFC1813 (June 1995), and NFSv4 in RFC3530 (April
+2003).
+
+The Linux NFS client currently supports all the above published versions,
+and work is in progress on adding support for minor version 1 of the NFSv4
+protocol.
+
+The purpose of this document is to provide information on some of the
+upcall interfaces that are used in order to provide the NFS client with
+some of the information that it requires in order to fully comply with
+the NFS spec.
+
+The DNS resolver
+================
+
+NFSv4 allows for one server to refer the NFS client to data that has been
+migrated onto another server by means of the special "fs_locations"
+attribute. See
+	http://tools.ietf.org/html/rfc3530#section-6
+and
+	http://tools.ietf.org/html/draft-ietf-nfsv4-referrals-00
+
+The fs_locations information can take the form of either an ip address and
+a path, or a DNS hostname and a path. The latter requires the NFS client to
+do a DNS lookup in order to mount the new volume, and hence the need for an
+upcall to allow userland to provide this service.
+
+Assuming that the user has the 'rpc_pipefs' filesystem mounted in the usual
+/var/lib/nfs/rpc_pipefs, the upcall consists of the following steps:
+
+   (1) The process checks the dns_resolve cache to see if it contains a
+       valid entry. If so, it returns that entry and exits.
+
+   (2) If no valid entry exists, the helper script '/sbin/nfs_cache_getent'
+       (may be changed using the 'nfs.cache_getent' kernel boot parameter)
+       is run, with two arguments:
+		- the cache name, "dns_resolve"
+		- the hostname to resolve
+
+   (3) After looking up the corresponding ip address, the helper script
+       writes the result into the rpc_pipefs pseudo-file
+       '/var/lib/nfs/rpc_pipefs/cache/dns_resolve/channel'
+       in the following (text) format:
+
+		"<ip address> <hostname> <ttl>\n"
+
+       Where <ip address> is in the usual IPv4 (123.456.78.90) or IPv6
+       (ffee:ddcc:bbaa:9988:7766:5544:3322:1100, ffee::1100, ...) format.
+       <hostname> is identical to the second argument of the helper
+       script, and <ttl> is the 'time to live' of this cache entry (in
+       units of seconds).
+
+       Note: If <ip address> is invalid, say the string "0", then a negative
+       entry is created, which will cause the kernel to treat the hostname
+       as having no valid DNS translation.
+
+
+
+
+A basic sample /sbin/nfs_cache_getent
+=====================================
+
+#!/bin/bash
+#
+ttl=600
+#
+cut=/usr/bin/cut
+getent=/usr/bin/getent
+rpc_pipefs=/var/lib/nfs/rpc_pipefs
+#
+die()
+{
+	echo "Usage: $0 cache_name entry_name"
+	exit 1
+}
+
+[ $# -lt 2 ] && die
+cachename="$1"
+cache_path=${rpc_pipefs}/cache/${cachename}/channel
+
+case "${cachename}" in
+	dns_resolve)
+		name="$2"
+		result="$(${getent} hosts ${name} | ${cut} -f1 -d\ )"
+		[ -z "${result}" ] && result="0"
+		;;
+	*)
+		die
+		;;
+esac
+echo "${result} ${name} ${ttl}" >${cache_path}
+
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 2f18206..4d0ed96 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1499,6 +1499,14 @@ and is between 256 and 4096 characters. It is defined in the file
 			[NFS] set the TCP port on which the NFSv4 callback
 			channel should listen.
 
+	nfs.cache_getent=
+			[NFS] sets the pathname to the program which is used
+			to update the NFS client cache entries.
+
+	nfs.cache_getent_timeout=
+			[NFS] sets the timeout after which an attempt to
+			update a cache entry is deemed to have failed.
+
 	nfs.idmap_cache_timeout=
 			[NFS] set the maximum lifetime for idmapper cache
 			entries.
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8451598..da7fda6 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -6,7 +6,8 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
 			   direct.o pagelist.o proc.o read.o symlink.o unlink.o \
-			   write.o namespace.o mount_clnt.o
+			   write.o namespace.o mount_clnt.o \
+			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
new file mode 100644
index 0000000..b4ffd01
--- /dev/null
+++ b/fs/nfs/cache_lib.c
@@ -0,0 +1,140 @@
+/*
+ * linux/fs/nfs/cache_lib.c
+ *
+ * Helper routines for the NFS client caches
+ *
+ * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
+ */
+#include <linux/kmod.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/sunrpc/cache.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
+
+#include "cache_lib.h"
+
+#define NFS_CACHE_UPCALL_PATHLEN 256
+#define NFS_CACHE_UPCALL_TIMEOUT 15
+
+static char nfs_cache_getent_prog[NFS_CACHE_UPCALL_PATHLEN] =
+				"/sbin/nfs_cache_getent";
+static unsigned long nfs_cache_getent_timeout = NFS_CACHE_UPCALL_TIMEOUT;
+
+module_param_string(cache_getent, nfs_cache_getent_prog,
+		sizeof(nfs_cache_getent_prog), 0600);
+MODULE_PARM_DESC(cache_getent, "Path to the client cache upcall program");
+module_param_named(cache_getent_timeout, nfs_cache_getent_timeout, ulong, 0600);
+MODULE_PARM_DESC(cache_getent_timeout, "Timeout (in seconds) after which "
+		"the cache upcall is assumed to have failed");
+
+int nfs_cache_upcall(struct cache_detail *cd, char *entry_name)
+{
+	static char *envp[] = { "HOME=/",
+		"TERM=linux",
+		"PATH=/sbin:/usr/sbin:/bin:/usr/bin",
+		NULL
+	};
+	char *argv[] = {
+		nfs_cache_getent_prog,
+		cd->name,
+		entry_name,
+		NULL
+	};
+	int ret = -EACCES;
+
+	if (nfs_cache_getent_prog[0] == '\0')
+		goto out;
+	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
+	/*
+	 * Disable the upcall mechanism if we're getting an ENOENT or
+	 * EACCES error. The admin can re-enable it on the fly by using
+	 * sysfs to set the 'cache_getent' parameter once the problem
+	 * has been fixed.
+	 */
+	if (ret == -ENOENT || ret == -EACCES)
+		nfs_cache_getent_prog[0] = '\0';
+out:
+	return ret > 0 ? 0 : ret;
+}
+
+/*
+ * Deferred request handling
+ */
+void nfs_cache_defer_req_put(struct nfs_cache_defer_req *dreq)
+{
+	if (atomic_dec_and_test(&dreq->count))
+		kfree(dreq);
+}
+
+static void nfs_dns_cache_revisit(struct cache_deferred_req *d, int toomany)
+{
+	struct nfs_cache_defer_req *dreq;
+
+	dreq = container_of(d, struct nfs_cache_defer_req, deferred_req);
+
+	complete_all(&dreq->completion);
+	nfs_cache_defer_req_put(dreq);
+}
+
+static struct cache_deferred_req *nfs_dns_cache_defer(struct cache_req *req)
+{
+	struct nfs_cache_defer_req *dreq;
+
+	dreq = container_of(req, struct nfs_cache_defer_req, req);
+	dreq->deferred_req.revisit = nfs_dns_cache_revisit;
+	atomic_inc(&dreq->count);
+
+	return &dreq->deferred_req;
+}
+
+struct nfs_cache_defer_req *nfs_cache_defer_req_alloc(void)
+{
+	struct nfs_cache_defer_req *dreq;
+
+	dreq = kzalloc(sizeof(*dreq), GFP_KERNEL);
+	if (dreq) {
+		init_completion(&dreq->completion);
+		atomic_set(&dreq->count, 1);
+		dreq->req.defer = nfs_dns_cache_defer;
+	}
+	return dreq;
+}
+
+int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq)
+{
+	if (wait_for_completion_timeout(&dreq->completion,
+			nfs_cache_getent_timeout * HZ) == 0)
+		return -ETIMEDOUT;
+	return 0;
+}
+
+int nfs_cache_register(struct cache_detail *cd)
+{
+	struct nameidata nd;
+	struct vfsmount *mnt;
+	int ret;
+
+	mnt = rpc_get_mount();
+	if (IS_ERR(mnt))
+		return PTR_ERR(mnt);
+	ret = vfs_path_lookup(mnt->mnt_root, mnt, "/cache", 0, &nd);
+	if (ret)
+		goto err;
+	ret = sunrpc_cache_register_pipefs(nd.path.dentry,
+			cd->name, 0600, cd);
+	path_put(&nd.path);
+	if (!ret)
+		return ret;
+err:
+	rpc_put_mount();
+	return ret;
+}
+
+void nfs_cache_unregister(struct cache_detail *cd)
+{
+	sunrpc_cache_unregister_pipefs(cd);
+	rpc_put_mount();
+}
+
diff --git a/fs/nfs/cache_lib.h b/fs/nfs/cache_lib.h
new file mode 100644
index 0000000..76f856e
--- /dev/null
+++ b/fs/nfs/cache_lib.h
@@ -0,0 +1,27 @@
+/*
+ * Helper routines for the NFS client caches
+ *
+ * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
+ */
+
+#include <linux/completion.h>
+#include <linux/sunrpc/cache.h>
+#include <asm/atomic.h>
+
+/*
+ * Deferred request handling
+ */
+struct nfs_cache_defer_req {
+	struct cache_req req;
+	struct cache_deferred_req deferred_req;
+	struct completion completion;
+	atomic_t count;
+};
+
+extern int nfs_cache_upcall(struct cache_detail *cd, char *entry_name);
+extern struct nfs_cache_defer_req *nfs_cache_defer_req_alloc(void);
+extern void nfs_cache_defer_req_put(struct nfs_cache_defer_req *dreq);
+extern int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq);
+
+extern int nfs_cache_register(struct cache_detail *cd);
+extern void nfs_cache_unregister(struct cache_detail *cd);
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
new file mode 100644
index 0000000..f4d54ba
--- /dev/null
+++ b/fs/nfs/dns_resolve.c
@@ -0,0 +1,335 @@
+/*
+ * linux/fs/nfs/dns_resolve.c
+ *
+ * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ * Resolves DNS hostnames into valid ip addresses
+ */
+
+#include <linux/hash.h>
+#include <linux/string.h>
+#include <linux/kmod.h>
+#include <linux/module.h>
+#include <linux/socket.h>
+#include <linux/seq_file.h>
+#include <linux/inet.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/cache.h>
+#include <linux/sunrpc/svcauth.h>
+
+#include "dns_resolve.h"
+#include "cache_lib.h"
+
+#define NFS_DNS_HASHBITS 4
+#define NFS_DNS_HASHTBL_SIZE (1 << NFS_DNS_HASHBITS)
+
+static struct cache_head *nfs_dns_table[NFS_DNS_HASHTBL_SIZE];
+
+struct nfs_dns_ent {
+	struct cache_head h;
+
+	char *hostname;
+	size_t namelen;
+
+	struct sockaddr_storage addr;
+	size_t addrlen;
+};
+
+
+static void nfs_dns_ent_init(struct cache_head *cnew,
+		struct cache_head *ckey)
+{
+	struct nfs_dns_ent *new;
+	struct nfs_dns_ent *key;
+
+	new = container_of(cnew, struct nfs_dns_ent, h);
+	key = container_of(ckey, struct nfs_dns_ent, h);
+
+	kfree(new->hostname);
+	new->hostname = kstrndup(key->hostname, key->namelen, GFP_KERNEL);
+	if (new->hostname) {
+		new->namelen = key->namelen;
+		memcpy(&new->addr, &key->addr, key->addrlen);
+		new->addrlen = key->addrlen;
+	} else {
+		new->namelen = 0;
+		new->addrlen = 0;
+	}
+}
+
+static void nfs_dns_ent_put(struct kref *ref)
+{
+	struct nfs_dns_ent *item;
+
+	item = container_of(ref, struct nfs_dns_ent, h.ref);
+	kfree(item->hostname);
+	kfree(item);
+}
+
+static struct cache_head *nfs_dns_ent_alloc(void)
+{
+	struct nfs_dns_ent *item = kmalloc(sizeof(*item), GFP_KERNEL);
+
+	if (item != NULL) {
+		item->hostname = NULL;
+		item->namelen = 0;
+		item->addrlen = 0;
+		return &item->h;
+	}
+	return NULL;
+};
+
+static unsigned int nfs_dns_hash(const struct nfs_dns_ent *key)
+{
+	return hash_str(key->hostname, NFS_DNS_HASHBITS);
+}
+
+static void nfs_dns_request(struct cache_detail *cd,
+		struct cache_head *ch,
+		char **bpp, int *blen)
+{
+	struct nfs_dns_ent *key = container_of(ch, struct nfs_dns_ent, h);
+
+	qword_add(bpp, blen, key->hostname);
+	(*bpp)[-1] = '\n';
+}
+
+static int nfs_dns_upcall(struct cache_detail *cd,
+		struct cache_head *ch)
+{
+	struct nfs_dns_ent *key = container_of(ch, struct nfs_dns_ent, h);
+	int ret;
+
+	ret = nfs_cache_upcall(cd, key->hostname);
+	if (ret)
+		ret = sunrpc_cache_pipe_upcall(cd, ch, nfs_dns_request);
+	return ret;
+}
+
+static int nfs_dns_match(struct cache_head *ca,
+		struct cache_head *cb)
+{
+	struct nfs_dns_ent *a;
+	struct nfs_dns_ent *b;
+
+	a = container_of(ca, struct nfs_dns_ent, h);
+	b = container_of(cb, struct nfs_dns_ent, h);
+
+	if (a->namelen == 0 || a->namelen != b->namelen)
+		return 0;
+	return memcmp(a->hostname, b->hostname, a->namelen) == 0;
+}
+
+static int nfs_dns_show(struct seq_file *m, struct cache_detail *cd,
+		struct cache_head *h)
+{
+	struct nfs_dns_ent *item;
+	long ttl;
+
+	if (h == NULL) {
+		seq_puts(m, "# ip address      hostname        ttl\n");
+		return 0;
+	}
+	item = container_of(h, struct nfs_dns_ent, h);
+	ttl = (long)item->h.expiry_time - (long)get_seconds();
+	if (ttl < 0)
+		ttl = 0;
+
+	if (!test_bit(CACHE_NEGATIVE, &h->flags)) {
+		char buf[INET6_ADDRSTRLEN+IPV6_SCOPE_ID_LEN+1];
+
+		rpc_ntop((struct sockaddr *)&item->addr, buf, sizeof(buf));
+		seq_printf(m, "%15s ", buf);
+	} else
+		seq_puts(m, "<none>          ");
+	seq_printf(m, "%15s %ld\n", item->hostname, ttl);
+	return 0;
+}
+
+struct nfs_dns_ent *nfs_dns_lookup(struct cache_detail *cd,
+		struct nfs_dns_ent *key)
+{
+	struct cache_head *ch;
+
+	ch = sunrpc_cache_lookup(cd,
+			&key->h,
+			nfs_dns_hash(key));
+	if (!ch)
+		return NULL;
+	return container_of(ch, struct nfs_dns_ent, h);
+}
+
+struct nfs_dns_ent *nfs_dns_update(struct cache_detail *cd,
+		struct nfs_dns_ent *new,
+		struct nfs_dns_ent *key)
+{
+	struct cache_head *ch;
+
+	ch = sunrpc_cache_update(cd,
+			&new->h, &key->h,
+			nfs_dns_hash(key));
+	if (!ch)
+		return NULL;
+	return container_of(ch, struct nfs_dns_ent, h);
+}
+
+static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
+{
+	char buf1[NFS_DNS_HOSTNAME_MAXLEN+1];
+	struct nfs_dns_ent key, *item;
+	unsigned long ttl;
+	ssize_t len;
+	int ret = -EINVAL;
+
+	if (buf[buflen-1] != '\n')
+		goto out;
+	buf[buflen-1] = '\0';
+
+	len = qword_get(&buf, buf1, sizeof(buf1));
+	if (len <= 0)
+		goto out;
+	key.addrlen = rpc_pton(buf1, len,
+			(struct sockaddr *)&key.addr,
+			sizeof(key.addr));
+
+	len = qword_get(&buf, buf1, sizeof(buf1));
+	if (len <= 0)
+		goto out;
+
+	key.hostname = buf1;
+	key.namelen = len;
+	memset(&key.h, 0, sizeof(key.h));
+
+	ttl = get_expiry(&buf);
+	if (ttl == 0)
+		goto out;
+	key.h.expiry_time = ttl + get_seconds();
+
+	ret = -ENOMEM;
+	item = nfs_dns_lookup(cd, &key);
+	if (item == NULL)
+		goto out;
+
+	if (key.addrlen == 0)
+		set_bit(CACHE_NEGATIVE, &key.h.flags);
+
+	item = nfs_dns_update(cd, &key, item);
+	if (item == NULL)
+		goto out;
+
+	ret = 0;
+	cache_put(&item->h, cd);
+out:
+	return ret;
+}
+
+static struct cache_detail nfs_dns_resolve = {
+	.owner = THIS_MODULE,
+	.hash_size = NFS_DNS_HASHTBL_SIZE,
+	.hash_table = nfs_dns_table,
+	.name = "dns_resolve",
+	.cache_put = nfs_dns_ent_put,
+	.cache_upcall = nfs_dns_upcall,
+	.cache_parse = nfs_dns_parse,
+	.cache_show = nfs_dns_show,
+	.match = nfs_dns_match,
+	.init = nfs_dns_ent_init,
+	.update = nfs_dns_ent_init,
+	.alloc = nfs_dns_ent_alloc,
+};
+
+static int do_cache_lookup(struct cache_detail *cd,
+		struct nfs_dns_ent *key,
+		struct nfs_dns_ent **item,
+		struct nfs_cache_defer_req *dreq)
+{
+	int ret = -ENOMEM;
+
+	*item = nfs_dns_lookup(cd, key);
+	if (*item) {
+		ret = cache_check(cd, &(*item)->h, &dreq->req);
+		if (ret)
+			*item = NULL;
+	}
+	return ret;
+}
+
+static int do_cache_lookup_nowait(struct cache_detail *cd,
+		struct nfs_dns_ent *key,
+		struct nfs_dns_ent **item)
+{
+	int ret = -ENOMEM;
+
+	*item = nfs_dns_lookup(cd, key);
+	if (!*item)
+		goto out_err;
+	ret = -ETIMEDOUT;
+	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
+			|| (*item)->h.expiry_time < get_seconds()
+			|| cd->flush_time > (*item)->h.last_refresh)
+		goto out_put;
+	ret = -ENOENT;
+	if (test_bit(CACHE_NEGATIVE, &(*item)->h.flags))
+		goto out_put;
+	return 0;
+out_put:
+	cache_put(&(*item)->h, cd);
+out_err:
+	*item = NULL;
+	return ret;
+}
+
+static int do_cache_lookup_wait(struct cache_detail *cd,
+		struct nfs_dns_ent *key,
+		struct nfs_dns_ent **item)
+{
+	struct nfs_cache_defer_req *dreq;
+	int ret = -ENOMEM;
+
+	dreq = nfs_cache_defer_req_alloc();
+	if (!dreq)
+		goto out;
+	ret = do_cache_lookup(cd, key, item, dreq);
+	if (ret == -EAGAIN) {
+		ret = nfs_cache_wait_for_upcall(dreq);
+		if (!ret)
+			ret = do_cache_lookup_nowait(cd, key, item);
+	}
+	nfs_cache_defer_req_put(dreq);
+out:
+	return ret;
+}
+
+ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
+		struct sockaddr *sa, size_t salen)
+{
+	struct nfs_dns_ent key = {
+		.hostname = name,
+		.namelen = namelen,
+	};
+	struct nfs_dns_ent *item = NULL;
+	ssize_t ret;
+
+	ret = do_cache_lookup_wait(&nfs_dns_resolve, &key, &item);
+	if (ret == 0) {
+		if (salen >= item->addrlen) {
+			memcpy(sa, &item->addr, item->addrlen);
+			ret = item->addrlen;
+		} else
+			ret = -EOVERFLOW;
+		cache_put(&item->h, &nfs_dns_resolve);
+	} else if (ret == -ENOENT)
+		ret = -ESRCH;
+	return ret;
+}
+
+int nfs_dns_resolver_init(void)
+{
+	return nfs_cache_register(&nfs_dns_resolve);
+}
+
+void nfs_dns_resolver_destroy(void)
+{
+	nfs_cache_unregister(&nfs_dns_resolve);
+}
+
diff --git a/fs/nfs/dns_resolve.h b/fs/nfs/dns_resolve.h
new file mode 100644
index 0000000..a3f0938
--- /dev/null
+++ b/fs/nfs/dns_resolve.h
@@ -0,0 +1,14 @@
+/*
+ * Resolve DNS hostnames into valid ip addresses
+ */
+#ifndef __LINUX_FS_NFS_DNS_RESOLVE_H
+#define __LINUX_FS_NFS_DNS_RESOLVE_H
+
+#define NFS_DNS_HOSTNAME_MAXLEN	(128)
+
+extern int nfs_dns_resolver_init(void);
+extern void nfs_dns_resolver_destroy(void);
+extern ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
+		struct sockaddr *sa, size_t salen);
+
+#endif
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe5a8b4..060022b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -46,6 +46,7 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "dns_resolve.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -1506,6 +1507,10 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
+	err = nfs_dns_resolver_init();
+	if (err < 0)
+		goto out8;
+
 	err = nfs_fscache_register();
 	if (err < 0)
 		goto out7;
@@ -1564,6 +1569,8 @@ out5:
 out6:
 	nfs_fscache_unregister();
 out7:
+	nfs_dns_resolver_destroy();
+out8:
 	return err;
 }
 
@@ -1575,6 +1582,7 @@ static void __exit exit_nfs_fs(void)
 	nfs_destroy_inodecache();
 	nfs_destroy_nfspagecache();
 	nfs_fscache_unregister();
+	nfs_dns_resolver_destroy();
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 3fdacaf..7f676bd 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -416,11 +416,13 @@ struct vfsmount *rpc_get_mount(void)
 		return ERR_PTR(err);
 	return rpc_mount;
 }
+EXPORT_SYMBOL_GPL(rpc_get_mount);
 
 void rpc_put_mount(void)
 {
 	simple_release_fs(&rpc_mount, &rpc_mount_count);
 }
+EXPORT_SYMBOL_GPL(rpc_put_mount);
 
 static int rpc_delete_dentry(struct dentry *dentry)
 {
@@ -946,6 +948,7 @@ enum {
 	RPCAUTH_portmap,
 	RPCAUTH_statd,
 	RPCAUTH_nfsd4_cb,
+	RPCAUTH_cache,
 	RPCAUTH_RootEOF
 };
 
@@ -974,6 +977,10 @@ static const struct rpc_filelist files[] = {
 		.name = "nfsd4_cb",
 		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
 	},
+	[RPCAUTH_cache] = {
+		.name = "cache",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
 };
 
 static int
-- 
1.6.0.4
