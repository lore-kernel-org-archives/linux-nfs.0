From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS using FScache for 2.6.9-rc4-mm1 kernel
	(Update)
Date: Tue, 19 Oct 2004 04:33:39 -0400
Sender: linux-cachefs-bounces@redhat.com
Message-ID: <4174D163.8090006@RedHat.com>
References: <416FA6B5.7020407@RedHat.com>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010807040604000400060608"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <linux-cachefs-bounces@redhat.com>
To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
In-Reply-To: <416FA6B5.7020407@RedHat.com>
List-Unsubscribe: <http://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=unsubscribe>
List-Archive: </archives/linux-cachefs>
List-Post: <mailto:linux-cachefs@redhat.com>
List-Help: <mailto:linux-cachefs-request@redhat.com?subject=help>
List-Subscribe: <http://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=subscribe>
Errors-To: linux-cachefs-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------010807040604000400060608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:

> Here is the  2.6.9-rc4-mm1 patch that will enable NFS to
> use FScache (formally know as CacheFS). Notable changes:
>
> 1) Moved some code around into different source files
>     per Trond's request.
>
> 2) Found and fixed some problems in the filehandle matching code.
>
> 3) Added NFS4 support, which was really no big deal since
>    all that was needed was to move some code around and
>    fix some compile errors.
>
> 4) Added the NFS_MOUNT_FSCACHE and NFS4_MOUNT_FSCACHE
>    mounting options. This means a fscache enabled mount command
>    will be need to enable NFS to used the fscache. For now, the 
> util-linux
>    patch,  source rpm and binary rpm can be found at:
>    http://people.redhat.com/steved/fscache/util-linux/
>
Here is an updated to the above patch that removes a majority all of the
#ifdef  CONFIG_NFS_FSCACHE which definitely cleans things up
nicely....

Signed-off-by: Steve Dickson <SteveD@RedHat.com>

--------------010807040604000400060608
Content-Type: text/plain;
 name="linux-2.6.9-rc4-mm1-fscache-nfs2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="linux-2.6.9-rc4-mm1-fscache-nfs2.patch"

--- 2.6.9-rc4-mm1/include/linux/nfs_fs.h.orig	2004-10-13 09:54:18.000000000 -0400
+++ 2.6.9-rc4-mm1/include/linux/nfs_fs.h	2004-10-16 09:21:59.000000000 -0400
@@ -30,6 +30,7 @@
 #include <linux/nfs_xdr.h>
 #include <linux/rwsem.h>
 #include <linux/workqueue.h>
+#include <linux/fscache.h>
 
 /*
  * Enable debugging support for nfs client.
@@ -189,6 +190,10 @@ struct nfs_inode {
 	struct rw_semaphore	rwsem;
 #endif /* CONFIG_NFS_V4*/
 
+#ifdef CONFIG_NFS_FSCACHE
+	struct fscache_cookie	*fscache;
+#endif
+
 	struct inode		vfs_inode;
 };
 
--- 2.6.9-rc4-mm1/include/linux/nfs_fs_sb.h.orig	2004-10-13 09:54:18.000000000 -0400
+++ 2.6.9-rc4-mm1/include/linux/nfs_fs_sb.h	2004-10-16 09:21:59.000000000 -0400
@@ -3,6 +3,7 @@
 
 #include <linux/list.h>
 #include <linux/backing-dev.h>
+#include <linux/fscache.h>
 
 /*
  * NFS client parameters stored in the superblock.
@@ -46,6 +47,10 @@ struct nfs_server {
 						   that are supported on this
 						   filesystem */
 #endif
+
+#ifdef CONFIG_NFS_FSCACHE
+	struct fscache_cookie	*fscache;	/* cache cookie */
+#endif
 };
 
 /* Server capabilities */
--- 2.6.9-rc4-mm1/include/linux/nfs_mount.h.orig	2004-08-14 06:54:47.000000000 -0400
+++ 2.6.9-rc4-mm1/include/linux/nfs_mount.h	2004-10-16 09:21:59.000000000 -0400
@@ -60,6 +60,7 @@ struct nfs_mount_data {
 #define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
 #define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
 #define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
+#define NFS_MOUNT_FSCACHE		0x3000
 #define NFS_MOUNT_FLAGMASK	0xFFFF
 
 #endif
--- 2.6.9-rc4-mm1/include/linux/nfs4_mount.h.orig	2004-08-14 06:55:32.000000000 -0400
+++ 2.6.9-rc4-mm1/include/linux/nfs4_mount.h	2004-10-16 09:21:59.000000000 -0400
@@ -65,6 +65,7 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_NOCTO	0x0010	/* 1 */
 #define NFS4_MOUNT_NOAC		0x0020	/* 1 */
 #define NFS4_MOUNT_STRICTLOCK	0x1000	/* 1 */
+#define NFS4_MOUNT_FSCACHE	0x2000	/* 1 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
 #endif
--- 2.6.9-rc4-mm1/fs/nfs/file.c.orig	2004-10-13 09:54:09.000000000 -0400
+++ 2.6.9-rc4-mm1/fs/nfs/file.c	2004-10-16 09:21:59.000000000 -0400
@@ -27,9 +27,11 @@
 #include <linux/slab.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
+#include <linux/buffer_head.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
+#include "nfs-fscache.h"
 
 #include "delegation.h"
 
@@ -240,6 +242,11 @@ static int nfs_commit_write(struct file 
 	return status;
 }
 
+/*
+ * since we use page->private for our own nefarious purposes when using fscache, we have to
+ * override extra address space ops to prevent fs/buffer.c from getting confused, even though we
+ * may not have asked its opinion
+ */
 struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -251,6 +258,12 @@ struct address_space_operations nfs_file
 #ifdef CONFIG_NFS_DIRECTIO
 	.direct_IO = nfs_direct_IO,
 #endif
+#ifdef CONFIG_NFS_FSCACHE
+	.sync_page	= block_sync_page,
+	.releasepage	= nfs_releasepage,
+	.invalidatepage	= nfs_invalidatepage,
+	.page_mkwrite	= nfs_mkwrite,
+#endif
 };
 
 /* 
--- 2.6.9-rc4-mm1/fs/nfs/inode.c.orig	2004-10-13 09:54:09.000000000 -0400
+++ 2.6.9-rc4-mm1/fs/nfs/inode.c	2004-10-16 11:19:37.821518424 -0400
@@ -41,6 +41,8 @@
 
 #include "delegation.h"
 
+#include "nfs-fscache.h"
+
 #define NFSDBG_FACILITY		NFSDBG_VFS
 #define NFS_PARANOIA 1
 
@@ -140,7 +142,7 @@ nfs_delete_inode(struct inode * inode)
 
 /*
  * For the moment, the only task for the NFS clear_inode method is to
- * release the mmap credential
+ * release the mmap credential and release the inode's on-disc cache
  */
 static void
 nfs_clear_inode(struct inode *inode)
@@ -153,6 +155,10 @@ nfs_clear_inode(struct inode *inode)
 	cred = nfsi->cache_access.cred;
 	if (cred)
 		put_rpccred(cred);
+
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_FSCACHE)
+		nfs_clear_fscookie(nfsi);
+
 	BUG_ON(atomic_read(&nfsi->data_updates) != 0);
 }
 
@@ -462,6 +468,9 @@ nfs_fill_super(struct super_block *sb, s
 			server->namelen = NFS2_MAXNAMLEN;
 	}
 
+	if (server->flags & NFS_MOUNT_FSCACHE)
+		nfs_fill_fscookie(sb);
+
 	sb->s_op = &nfs_sops;
 	return nfs_sb_init(sb, authflavor);
 }
@@ -524,6 +533,7 @@ static int nfs_show_options(struct seq_f
 		{ NFS_MOUNT_NOAC, ",noac", "" },
 		{ NFS_MOUNT_NONLM, ",nolock", ",lock" },
 		{ NFS_MOUNT_BROKEN_SUID, ",broken_suid", "" },
+		{ NFS_MOUNT_FSCACHE, ",fscache", "" },
 		{ 0, NULL, NULL }
 	};
 	struct proc_nfs_info *nfs_infop;
@@ -568,6 +578,9 @@ nfs_zap_caches(struct inode *inode)
 		nfsi->flags |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 	else
 		nfsi->flags |= NFS_INO_INVALID_ATTR;
+
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_FSCACHE)
+		nfs_zap_fscookie(nfsi);
 }
 
 /*
@@ -705,6 +718,9 @@ nfs_fhget(struct super_block *sb, struct
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 		nfsi->cache_access.cred = NULL;
 
+		if (NFS_SB(sb)->flags & NFS_MOUNT_FSCACHE)
+			nfs_fhget_fscookie(sb, nfsi);
+
 		unlock_new_inode(inode);
 	} else
 		nfs_refresh_inode(inode, fattr);
@@ -1009,6 +1025,9 @@ __nfs_revalidate_inode(struct nfs_server
 				(long long)NFS_FILEID(inode));
 		/* This ensures we revalidate dentries */
 		nfsi->cache_change_attribute++;
+
+		if (server->flags & NFS_MOUNT_FSCACHE)
+			nfs_renew_fscookie(server, nfsi);
 	}
 	dfprintk(PAGECACHE, "NFS: (%s/%Ld) revalidation complete\n",
 		inode->i_sb->s_id,
@@ -1417,6 +1436,14 @@ static struct super_block *nfs_get_sb(st
 		return ERR_PTR(-EINVAL);
 	}
 
+#ifndef CONFIG_NFS_FSCACHE
+	if (data->flags & NFS_MOUNT_FSCACHE) {
+		printk(KERN_WARNING "NFS: kernel not compiled with CONFIG_NFS_FSCACHE\n");
+		kfree(server);
+		return ERR_PTR(-EINVAL);
+	}
+#endif
+
 	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
 
 	if (IS_ERR(s) || s->s_root) {
@@ -1449,6 +1476,9 @@ static void nfs_kill_super(struct super_
 
 	kill_anon_super(s);
 
+	if (server->flags & NFS_MOUNT_FSCACHE)
+		nfs_kill_fscookie(server);
+
 	nfs4_renewd_prepare_shutdown(server);
 
 	if (server->client != NULL && !IS_ERR(server->client))
@@ -1653,6 +1683,9 @@ static int nfs4_fill_super(struct super_
 		}
 	}
 
+	if (server->flags & NFS4_MOUNT_FSCACHE)
+		nfs4_fill_fscookie(sb);
+
 	sb->s_op = &nfs4_sops;
 	err = nfs_sb_init(sb, authflavour);
 	if (err == 0)
@@ -1888,6 +1921,11 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
+	/* we want to be able to cache */
+	err = nfs_register_netfs(&nfs_cache_netfs, &nfs_cache_server_index_def);
+	if (err < 0)
+		goto out5;
+
 	err = nfs_init_nfspagecache();
 	if (err)
 		goto out4;
@@ -1923,6 +1961,9 @@ out2:
 out3:
 	nfs_destroy_nfspagecache();
 out4:
+	nfs_unregister_netfs(&nfs_cache_netfs);
+out5:
+
 	return err;
 }
 
@@ -1932,6 +1973,7 @@ static void __exit exit_nfs_fs(void)
 	nfs_destroy_readpagecache();
 	nfs_destroy_inodecache();
 	nfs_destroy_nfspagecache();
+	nfs_unregister_netfs(&nfs_cache_netfs);
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
--- 2.6.9-rc4-mm1/fs/nfs/Makefile.orig	2004-10-13 09:54:09.000000000 -0400
+++ 2.6.9-rc4-mm1/fs/nfs/Makefile	2004-10-16 09:21:59.000000000 -0400
@@ -12,4 +12,5 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4x
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o
 nfs-$(CONFIG_NFS_DIRECTIO) += direct.o
+nfs-$(CONFIG_NFS_FSCACHE) += nfs-fscache.o
 nfs-objs		:= $(nfs-y)
--- /dev/null	2004-02-23 16:02:56.000000000 -0500
+++ 2.6.9-rc4-mm1/fs/nfs/nfs-fscache.c	2004-10-16 09:21:59.000000000 -0400
@@ -0,0 +1,191 @@
+/* nfs-fscache.c: NFS filesystem cache interface
+ *
+ * Copyright (C) 2004 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+
+#include <linux/config.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_fs_sb.h>
+
+#include "nfs-fscache.h"
+
+#define NFS_CACHE_FH_INDEX_SIZE sizeof(struct nfs_fh)
+
+/*
+ * the root index is
+ */
+static struct fscache_page *nfs_cache_get_page_token(struct page *page);
+
+static struct fscache_netfs_operations nfs_cache_ops = {
+	.get_page_token	= nfs_cache_get_page_token,
+};
+
+struct fscache_netfs nfs_cache_netfs = {
+	.name			= "nfs",
+	.version		= 0,
+	.ops			= &nfs_cache_ops,
+};
+
+/*
+ * the root index for the filesystem is defined by nfsd IP address and ports
+ */
+static fscache_match_val_t nfs_cache_server_match(void *target,
+						  const void *entry);
+static void nfs_cache_server_update(void *source, void *entry);
+
+struct fscache_index_def nfs_cache_server_index_def = {
+	.name			= "servers",
+	.data_size		= 18,
+	.keys[0]		= { FSCACHE_INDEX_KEYS_IPV6ADDR, 16 },
+	.keys[1]		= { FSCACHE_INDEX_KEYS_BIN, 2 },
+	.match			= nfs_cache_server_match,
+	.update			= nfs_cache_server_update,
+};
+
+/*
+ * the primary index for each server is simply made up of a series of NFS file
+ * handles
+ */
+static fscache_match_val_t nfs_cache_fh_match(void *target, const void *entry);
+static void nfs_cache_fh_update(void *source, void *entry);
+
+struct fscache_index_def nfs_cache_fh_index_def = {
+	.name			= "fh",
+	.data_size		= NFS_CACHE_FH_INDEX_SIZE,
+	.keys[0]		= { FSCACHE_INDEX_KEYS_BIN_SZ2,
+				    sizeof(struct nfs_fh) },
+	.match			= nfs_cache_fh_match,
+	.update			= nfs_cache_fh_update,
+};
+
+/*
+ * get a page token for the specified page
+ * - the token will be attached to page->private and PG_private will be set on
+ *   the page
+ */
+static struct fscache_page *nfs_cache_get_page_token(struct page *page)
+{
+	return fscache_page_get_private(page, GFP_NOIO);
+}
+
+static const uint8_t nfs_cache_ipv6_wrapper_for_ipv4[12] = {
+	[0 ... 9]	= 0x00,
+	[10 ... 11]	= 0xff
+};
+
+/*
+ * match a server record obtained from the cache
+ */
+static fscache_match_val_t nfs_cache_server_match(void *target,
+						  const void *entry)
+{
+	struct nfs_server *server = target;
+	const uint8_t *data = entry;
+
+	switch (server->addr.sin_family) {
+	case AF_INET:
+		if (memcmp(data + 0,
+			   &nfs_cache_ipv6_wrapper_for_ipv4,
+			   12) != 0)
+			break;
+
+		if (memcmp(data + 12, &server->addr.sin_addr, 4) != 0)
+			break;
+
+		if (memcmp(data + 16, &server->addr.sin_port, 2) != 0)
+			break;
+
+		return FSCACHE_MATCH_SUCCESS;
+
+	case AF_INET6:
+		if (memcmp(data + 0, &server->addr.sin_addr, 16) != 0)
+			break;
+
+		if (memcmp(data + 16, &server->addr.sin_port, 2) != 0)
+			break;
+
+		return FSCACHE_MATCH_SUCCESS;
+
+	default:
+		break;
+	}
+
+	return FSCACHE_MATCH_FAILED;
+}
+
+/*
+ * update a server record in the cache
+ */
+static void nfs_cache_server_update(void *source, void *entry)
+{
+	struct nfs_server *server = source;
+	uint8_t *data = entry;
+
+	switch (server->addr.sin_family) {
+	case AF_INET:
+		memcpy(data + 0, &nfs_cache_ipv6_wrapper_for_ipv4, 12);
+		memcpy(data + 12, &server->addr.sin_addr, 4);
+		memcpy(data + 16, &server->addr.sin_port, 2);
+		return;
+
+	case AF_INET6:
+		memcpy(data + 0, &server->addr.sin_addr, 16);
+		memcpy(data + 16, &server->addr.sin_port, 2);
+		return;
+
+	default:
+		return;
+	}
+}
+
+/*
+ * match a file handle record obtained from the cache
+ */
+static fscache_match_val_t nfs_cache_fh_match(void *target, const void *entry)
+{
+	struct nfs_inode *nfsi = target;
+	const uint8_t *data = entry;
+	uint16_t nsize;
+
+	/* check the file handle matches */
+	memcpy(&nsize, data, 2);
+	nsize = ntohs(nsize);
+
+	if (nsize <= NFS_CACHE_FH_INDEX_SIZE && nfsi->fh.size == nsize) {
+		if (memcmp(data + 2, nfsi->fh.data, nsize) == 0) {
+			return FSCACHE_MATCH_SUCCESS;
+		}
+	}
+
+	return FSCACHE_MATCH_FAILED;
+}
+
+/*
+ * update a fh record in the cache
+ */
+static void nfs_cache_fh_update(void *source, void *entry)
+{
+	struct nfs_inode *nfsi = source;
+	uint16_t nsize;
+	uint8_t *data = entry;
+
+	BUG_ON(nfsi->fh.size > NFS_CACHE_FH_INDEX_SIZE - 2);
+
+	/* set the file handle */
+	nsize = htons(nfsi->fh.size);
+	memcpy(data, &nsize, 2);
+	memcpy(data + 2, &nfsi->fh.data, nfsi->fh.size);
+	memset(data + 2 + nfsi->fh.size,
+	       FSCACHE_INDEX_DEADFILL_PATTERN,
+	       NFS_CACHE_FH_INDEX_SIZE - 2 - nfsi->fh.size);
+}
--- /dev/null	2004-02-23 16:02:56.000000000 -0500
+++ 2.6.9-rc4-mm1/fs/nfs/nfs-fscache.h	2004-10-16 11:23:56.585180368 -0400
@@ -0,0 +1,145 @@
+/* nfs-fscache.h: NFS filesystem cache interface definitions
+ *
+ * Copyright (C) 2004 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _NFS_FSCACHE_H
+#define _NFS_FSCACHE_H
+
+#include <linux/nfs_mount.h>
+#include <linux/nfs4_mount.h>
+#include <linux/fscache.h>
+
+#ifdef CONFIG_NFS_FSCACHE
+#ifndef CONFIG_FSCACHE
+#error "CONFIG_NFS_FSCACHE is defined but not CONFIG_FSCACHE"
+#endif
+
+extern struct fscache_netfs nfs_cache_netfs;
+extern struct fscache_index_def nfs_cache_server_index_def;
+extern struct fscache_index_def nfs_cache_fh_index_def;
+
+extern int nfs_invalidatepage(struct page *, unsigned long);
+extern int nfs_releasepage(struct page *, int);
+extern int nfs_mkwrite(struct page *);
+
+static inline void 
+nfs_renew_fscookie(struct nfs_server *server, struct nfs_inode *nfsi)
+{
+	struct fscache_cookie *old =  nfsi->fscache;
+
+	/* retire the current fscache cache and get a new one */
+	fscache_relinquish_cookie(nfsi->fscache, 1);
+	nfsi->fscache = fscache_acquire_cookie(server->fscache, NULL, nfsi);
+
+	dfprintk(PAGECACHE,
+		"NFS: revalidation new cookie (0x%p/0x%p/0x%p/0x%p)\n",
+		server, nfsi, old, nfsi->fscache);
+
+	return;
+}
+static inline void
+nfs4_fill_fscookie(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+
+	/* create a cache index for looking up filehandles */
+	server->fscache = fscache_acquire_cookie(nfs_cache_netfs.primary_index,
+			       &nfs_cache_fh_index_def, server);
+	if (server->fscache == NULL) {
+		printk(KERN_WARNING "NFS4: No Fscache cookie. Turning Fscache off!\n");
+	} else /* reuse the NFS mount option */
+		server->flags |= NFS_MOUNT_FSCACHE;
+
+	dfprintk(PAGECACHE,"NFS: nfs4 cookie (0x%p,0x%p/0x%p)\n", 
+		sb, server, server->fscache);
+
+	return;
+}
+static inline void
+nfs_fill_fscookie(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+
+	/* create a cache index for looking up filehandles */
+	server->fscache = fscache_acquire_cookie(nfs_cache_netfs.primary_index,
+			      &nfs_cache_fh_index_def, server);
+	if (server->fscache == NULL) {
+		server->flags &= ~NFS_MOUNT_FSCACHE;
+		printk(KERN_WARNING "NFS: No Fscache cookie. Turning Fscache off!\n");
+	}
+	dfprintk(PAGECACHE,"NFS: cookie (0x%p/0x%p/0x%p)\n", 
+		sb, server, server->fscache);
+
+	return;
+}
+static inline void
+nfs_fhget_fscookie(struct super_block *sb, struct nfs_inode *nfsi)
+{
+	struct nfs_server *server = NFS_SB(sb);
+
+	nfsi->fscache = fscache_acquire_cookie(server->fscache, NULL, nfsi);
+	if (server->fscache == NULL)
+		printk(KERN_WARNING "NFS: NULL FScache cookie: sb 0x%p nfsi 0x%p\n", sb, nfsi);
+
+	dfprintk(PAGECACHE, "NFS: fhget new cookie (0x%p/0x%p/0x%p)\n",
+		sb, nfsi, nfsi->fscache);
+
+	return;
+}
+static inline void 
+nfs_kill_fscookie(struct nfs_server *server)
+{
+	dfprintk(PAGECACHE,"NFS: killing cookie (0x%p/0x%p)\n",
+		server, server->fscache);
+
+	fscache_relinquish_cookie(server->fscache, 0);
+	server->fscache = NULL;
+
+	return;
+}
+static inline void
+nfs_clear_fscookie(struct nfs_inode *nfsi)
+{
+	dfprintk(PAGECACHE, "NFS: clear cookie (0x%p/0x%p)\n",
+			nfsi, nfsi->fscache);
+
+	fscache_relinquish_cookie(nfsi->fscache, 0);
+	nfsi->fscache = NULL;
+
+	return;
+}
+static inline void
+nfs_zap_fscookie(struct nfs_inode *nfsi)
+{
+	dfprintk(PAGECACHE,"NFS: zapping cookie (0x%p/0x%p)\n",
+		nfsi, nfsi->fscache);
+
+	fscache_relinquish_cookie(nfsi->fscache, 1);
+	nfsi->fscache = NULL;
+
+	return;
+}
+#define nfs_register_netfs(a, b) fscache_register_netfs((a), (b))
+#define nfs_unregister_netfs(a)  fscache_unregister_netfs((a))
+#else
+static inline void nfs_fill_fscookie(struct super_block *sb) {}
+static inline void nfs_fhget_fscookie(struct super_block *sb, struct nfs_inode *nfsi) {}
+static inline void nfs4_fill_fscookie(struct super_block *sb) {}
+static inline void nfs_kill_fscookie(struct nfs_server *server) {}
+static inline void nfs_clear_fscookie(struct nfs_inode *nfsi) {}
+static inline void nfs_zap_fscookie(struct nfs_inode *nfsi) {}
+static inline void 
+	nfs_renew_fscookie(struct nfs_server *server, struct nfs_inode *nfsi) {}
+
+#define nfs_register_netfs(a, b) 0
+#define nfs_unregister_netfs(a) 
+
+#endif
+#endif /* _NFS_FSCACHE_H */
--- 2.6.9-rc4-mm1/fs/nfs/read.c.orig	2004-10-13 09:54:09.000000000 -0400
+++ 2.6.9-rc4-mm1/fs/nfs/read.c	2004-10-16 11:14:43.033333040 -0400
@@ -28,6 +28,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/nfs_mount.h>
 #include <linux/smp_lock.h>
 
 #include <asm/system.h>
@@ -88,6 +89,47 @@ int nfs_return_empty_page(struct page *p
 	return 0;
 }
 
+#ifdef CONFIG_NFS_FSCACHE
+/*
+ * store a newly fetched page in fscache
+ */
+static void
+nfs_readpage_to_fscache_complete(void *cookie_data, struct page *page, void *data, int error)
+{
+	dprintk("NFS:     readpage_to_fscache_complete (%p/%p/%p/%d)\n",
+		cookie_data, page, data, error);
+
+	end_page_fs_misc(page);
+}
+
+static inline void
+nfs_readpage_to_fscache(struct inode *inode, struct page *page, int sync)
+{
+	int ret;
+
+	dprintk("NFS: readpage_to_fscache(0x%p/0x%p/0x%p/%d)\n",
+		NFS_I(inode)->fscache, page, inode, sync);
+
+	SetPageFsMisc(page);
+	ret = fscache_write_page(NFS_I(inode)->fscache, page,
+		nfs_readpage_to_fscache_complete, NULL, GFP_KERNEL);
+	if (ret != 0) {
+		dprintk("NFS:     readpage_to_fscache: error %d\n", ret);
+		fscache_uncache_page(NFS_I(inode)->fscache, page);
+		ClearPageFsMisc(page);
+	}
+
+	unlock_page(page);
+}
+#else
+static inline void
+nfs_readpage_to_fscache(struct inode *inode, struct page *page, int sync)
+{
+	BUG();
+}
+#endif
+
+
 /*
  * Read a page synchronously.
  */
@@ -164,6 +206,13 @@ static int nfs_readpage_sync(struct nfs_
 		ClearPageError(page);
 	result = 0;
 
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_FSCACHE)
+		nfs_readpage_to_fscache(inode, page, 1);
+	else
+		unlock_page(page);
+
+	return result;
+
 io_error:
 	unlock_page(page);
 	nfs_readdata_free(rdata);
@@ -196,7 +245,13 @@ static int nfs_readpage_async(struct nfs
 
 static void nfs_readpage_release(struct nfs_page *req)
 {
-	unlock_page(req->wb_page);
+	struct inode *d_inode = req->wb_context->dentry->d_inode;
+
+	if ((NFS_SERVER(d_inode)->flags & NFS_MOUNT_FSCACHE) && 
+			PageUptodate(req->wb_page))
+		nfs_readpage_to_fscache(d_inode, req->wb_page, 0);
+	else
+		unlock_page(req->wb_page);
 
 	nfs_clear_request(req);
 	nfs_release_request(req);
@@ -494,6 +549,67 @@ void nfs_readpage_result(struct rpc_task
 	data->complete(data, status);
 }
 
+
+/*
+ * Read a page through the on-disc cache if possible
+ */
+#ifdef CONFIG_NFS_FSCACHE
+static void
+nfs_readpage_from_fscache_complete(void *cookie_data, struct page *page, void *data, int error)
+{
+	dprintk("NFS: readpage_from_fscache_complete (0x%p/0x%p/0x%p/%d)\n",
+		cookie_data, page, data, error);
+
+	if (error)
+		SetPageError(page);
+	else
+		SetPageUptodate(page);
+
+	unlock_page(page);
+}
+
+static inline int
+nfs_readpage_from_fscache(struct inode *inode, struct page *page)
+{
+	struct fscache_page *pageio;
+	int ret;
+
+	dprintk("NFS: readpage_from_fscache(0x%p/0x%p/0x%p)\n",
+		NFS_I(inode)->fscache, page, inode);
+
+	pageio = fscache_page_get_private(page, GFP_NOIO);
+	if (IS_ERR(pageio)) {
+		 dprintk("NFS:     fscache_page_get_private error %ld\n", PTR_ERR(pageio));
+		return PTR_ERR(pageio);
+	}
+
+	ret = fscache_read_or_alloc_page(NFS_I(inode)->fscache,
+					 page,
+					 nfs_readpage_from_fscache_complete,
+					 NULL,
+					 GFP_KERNEL);
+
+	switch (ret) {
+	case 1: /* read BIO submitted and wb-journal entry found */
+		BUG();
+		
+	case 0: /* read BIO submitted (page in fscache) */
+		return ret;
+
+	case -ENOBUFS: /* inode not in cache */
+	case -ENODATA: /* page not in cache */
+		dprintk("NFS:     fscache_read_or_alloc_page error %d\n", ret);
+		return 1;
+
+	default:
+		return ret;
+	}
+}
+#else
+static inline int 
+nfs_readpage_from_fscache(struct inode *inode, struct page *page) { return 1; }
+#endif
+
 /*
  * Read a page over NFS.
  * We read the page synchronously in the following case:
@@ -527,6 +643,13 @@ int nfs_readpage(struct file *file, stru
 		ctx = get_nfs_open_context((struct nfs_open_context *)
 				file->private_data);
 	if (!IS_SYNC(inode)) {
+		if (NFS_SERVER(inode)->flags & NFS_MOUNT_FSCACHE) {
+			error = nfs_readpage_from_fscache(inode, page);
+			if (error < 0)
+				goto out_error;
+			if (error == 0)
+				return error;
+		}
 		error = nfs_readpage_async(ctx, inode, page);
 		goto out;
 	}
@@ -557,6 +680,15 @@ readpage_async_filler(void *data, struct
 	unsigned int len;
 
 	nfs_wb_page(inode, page);
+
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_FSCACHE) {
+		int error = nfs_readpage_from_fscache(inode, page);
+		if (error < 0)
+			return error;
+		if (error == 0)
+			return error;
+	}
+
 	len = nfs_page_length(inode, page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
@@ -631,3 +763,61 @@ void nfs_destroy_readpagecache(void)
 	if (kmem_cache_destroy(nfs_rdata_cachep))
 		printk(KERN_INFO "nfs_read_data: not all structures were freed\n");
 }
+
+#ifdef CONFIG_NFS_FSCACHE
+int nfs_invalidatepage(struct page *page, unsigned long offset)
+{
+	int ret = 1;
+	struct nfs_server *server = NFS_SERVER(page->mapping->host);
+
+	BUG_ON(!PageLocked(page));
+
+	if (server->flags & NFS_MOUNT_FSCACHE) {
+		if (PagePrivate(page)) {
+			struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+
+			dfprintk(PAGECACHE,"NFS: fscache invalidatepage (0x%p/0x%p/0x%p)\n",
+				nfsi->fscache, page, nfsi);
+
+			fscache_uncache_page(nfsi->fscache, page);
+
+			if (offset == 0) {
+				BUG_ON(!PageLocked(page));
+				ret = 0;
+				if (!PageWriteback(page))
+					ret = page->mapping->a_ops->releasepage(page, 0);
+			}
+		}
+	} else
+		ret = 0;
+
+	return ret;
+}
+int nfs_releasepage(struct page *page, int gfp_flags)
+{
+	struct fscache_page *pageio;
+	struct nfs_server *server = NFS_SERVER(page->mapping->host);
+
+	if (server->flags & NFS_MOUNT_FSCACHE && PagePrivate(page)) {
+		struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+
+		dfprintk(PAGECACHE,"NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
+			nfsi->fscache, page, nfsi);
+
+		fscache_uncache_page(nfsi->fscache, page);
+		pageio = (struct fscache_page *) page->private;
+		page->private = 0;
+		ClearPagePrivate(page);
+
+		if (pageio)
+			kfree(pageio);
+	}
+
+	return 0;
+}
+int nfs_mkwrite(struct page *page)
+{
+	wait_on_page_fs_misc(page);
+	return 0;
+}
+#endif
--- 2.6.9-rc4-mm1/fs/nfs/write.c.orig	2004-10-13 09:54:09.000000000 -0400
+++ 2.6.9-rc4-mm1/fs/nfs/write.c	2004-10-16 09:21:59.000000000 -0400
@@ -273,6 +273,38 @@ static int wb_priority(struct writeback_
 }
 
 /*
+ * store an updated page in fscache
+ */
+#ifdef CONFIG_NFS_FSCACHE
+static void
+nfs_writepage_to_fscache_complete(void *cookie_data, struct page *page, void *data, int error)
+{
+	/* really need to synchronise the end of writeback, probably using a page flag */
+}
+static inline void
+nfs_writepage_to_fscache(struct inode *inode, struct page *page)
+{
+	int ret; 
+
+	dprintk("NFS: writepage_to_fscache (0x%p/0x%p/0x%p)\n",
+		NFS_I(inode)->fscache, page, inode);
+
+	ret =  fscache_write_page(NFS_I(inode)->fscache, page,
+		nfs_writepage_to_fscache_complete, NULL, GFP_KERNEL);
+	if (ret != 0) {
+		dprintk("NFS:    fscache_write_page error %d\n", ret);
+		fscache_uncache_page(NFS_I(inode)->fscache, page);
+	}
+}
+#else
+static inline void
+nfs_writepage_to_fscache(struct inode *inode, struct page *page)
+{
+	BUG();
+}
+#endif
+
+/*
  * Write an mmapped page to the server.
  */
 int nfs_writepage(struct page *page, struct writeback_control *wbc)
@@ -317,6 +349,10 @@ do_it:
 		err = -EBADF;
 		goto out;
 	}
+
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_FSCACHE)
+		nfs_writepage_to_fscache(inode, page);
+
 	lock_kernel();
 	if (!IS_SYNC(inode) && inode_referenced) {
 		err = nfs_writepage_async(ctx, inode, page, 0, offset);
@@ -1322,6 +1358,7 @@ nfs_commit_done(struct rpc_task *task)
 			(long long)NFS_FILEID(req->wb_context->dentry->d_inode),
 			req->wb_bytes,
 			(long long)req_offset(req));
+
 		if (task->tk_status < 0) {
 			req->wb_context->error = task->tk_status;
 			nfs_inode_remove_request(req);
--- 2.6.9-rc4-mm1/fs/Kconfig.orig	2004-10-13 09:59:40.000000000 -0400
+++ 2.6.9-rc4-mm1/fs/Kconfig	2004-10-16 09:21:59.000000000 -0400
@@ -1493,6 +1493,13 @@ config NFS_V4
 
 	  If unsure, say N.
 
+config NFS_FSCACHE
+	bool "Provide NFS client caching support"
+	depends on NFS_FS && FSCACHE && EXPERIMENTAL
+	help
+	  Say Y here if you want NFS data to be cached locally on disc through
+	  the general filesystem cache manager
+
 config NFS_DIRECTIO
 	bool "Allow direct I/O on NFS files (EXPERIMENTAL)"
 	depends on NFS_FS && EXPERIMENTAL

--------------010807040604000400060608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--
Linux-cachefs mailing list
Linux-cachefs@redhat.com
http://www.redhat.com/mailman/listinfo/linux-cachefs

--------------010807040604000400060608--
