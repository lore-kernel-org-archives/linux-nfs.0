From: ed@sam-solutions.net (Ed V. Bartosh)
Subject: NFSv3 UID/GID mapping
Date: Thu, 22 Apr 2004 12:36:13 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <m3vfjsxsky.fsf@pc213.belcaf.minsk.by>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGaeL-0007ed-UG
	for nfs@lists.sourceforge.net; Thu, 22 Apr 2004 02:37:41 -0700
Received: from mail.sam-solutions.net ([217.21.35.41])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BGaeJ-0008LZ-5P
	for nfs@lists.sourceforge.net; Thu, 22 Apr 2004 02:37:40 -0700
Received: from pc213.belcaf.minsk.by ([192.168.117.18] helo=pc213.sam-solutions.net)
	by mail.sam-solutions.net with esmtp (Exim 4.31)
	id 1BGae8-0000JK-S8
	for nfs@lists.sourceforge.net; Thu, 22 Apr 2004 12:37:28 +0300
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

--=-=-=

Dear NFS developers,

Here is the NFSv3 uid/gid mapping implementation (both kernel and
nfs-utils parts). Userspace part uses idmap daemon from CITI NFSv4, 
so the NFSv4 patches are required.

Look at this, please. Any kind of feedback will be appreciated.

-- 
Best regards,
Ed V. Bartosh


--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=linux-2.6.4-nfsd3_idmap.patch

diff -ruN kernel-source-2.6.4/fs/nfsd.orig/auth.c kernel-source-2.6.4/fs/nfsd/auth.c
--- kernel-source-2.6.4/fs/nfsd.orig/auth.c	2004-03-23 16:20:09 +0200
+++ kernel-source-2.6.4/fs/nfsd/auth.c	2004-04-21 17:16:49 +0300
@@ -4,11 +4,17 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
  */
 
+#include <linux/config.h>
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/nfsd/nfsd.h>
+#ifdef CONFIG_NFSD3_IDMAP
+#include <linux/nfsd_idmap.h>
+#endif
+
+#define NFSDDBG_FACILITY NFSDDBG_AUTH
 
 #define	CAP_NFSD_MASK (CAP_FS_MASK|CAP_TO_MASK(CAP_SYS_RESOURCE))
 
@@ -17,6 +23,33 @@
 	struct svc_cred	*cred = &rqstp->rq_cred;
 	int i;
 	int ret;
+	
+#ifdef CONFIG_NFSD3_IDMAP
+	__u32 uidm = IDMAP_UID_NONE;
+	__u32 gidm = IDMAP_UID_NONE;
+
+	if (exp->ex_flags & NFSEXP_IDMAPD) {
+		struct group_info *gi;
+		ret = nfsd3_map_uid_to_uid(rqstp, cred->cr_uid, &uidm);
+		if (ret == 0 && uidm != IDMAP_UID_NONE)
+			cred->cr_uid = uidm;
+
+		ret = nfsd3_map_gid_to_gid(rqstp, cred->cr_gid, &gidm);
+		if (ret == 0 && gidm != IDMAP_UID_NONE)
+			cred->cr_gid = gidm;
+
+		gi = groups_alloc(cred->cr_group_info->ngroups);
+		if (gi) {
+			for (i = 0; i < cred->cr_group_info->ngroups; i++) {
+				ret = nfsd3_map_gid_to_gid(rqstp, GROUP_AT(cred->cr_group_info, i), &gidm);
+				if (ret == 0 && gidm != IDMAP_UID_NONE)
+					GROUP_AT(gi, i) = gidm;
+			}
+			put_group_info(cred->cr_group_info);
+			cred->cr_group_info = gi;
+		}
+	}
+#else
 
 	if (exp->ex_flags & NFSEXP_ALLSQUASH) {
 		cred->cr_uid = exp->ex_anon_uid;
@@ -40,7 +73,7 @@
 		put_group_info(cred->cr_group_info);
 		cred->cr_group_info = gi;
 	}
-
+#endif
 	if (cred->cr_uid != (uid_t) -1)
 		current->fsuid = cred->cr_uid;
 	else
diff -ruN kernel-source-2.6.4/fs/nfsd.orig/export.c kernel-source-2.6.4/fs/nfsd/export.c
--- kernel-source-2.6.4/fs/nfsd.orig/export.c	2004-03-23 16:20:09 +0200
+++ kernel-source-2.6.4/fs/nfsd/export.c	2004-04-08 21:26:11 +0300
@@ -1010,6 +1010,7 @@
 	{ NFSEXP_ALLSQUASH, {"all_squash", ""}},
 	{ NFSEXP_ASYNC, {"async", "sync"}},
 	{ NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
+	{ NFSEXP_IDMAPD, {"mapping=idmapd", ""}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
diff -ruN kernel-source-2.6.4/fs/nfsd.orig/Makefile kernel-source-2.6.4/fs/nfsd/Makefile
--- kernel-source-2.6.4/fs/nfsd.orig/Makefile	2004-03-23 16:20:09 +0200
+++ kernel-source-2.6.4/fs/nfsd/Makefile	2004-03-25 12:41:43 +0200
@@ -7,5 +7,6 @@
 nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
 			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
+nfsd-$(CONFIG_NFSD3_IDMAP) += nfs3idmap.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o
 nfsd-objs		:= $(nfsd-y)
diff -ruN kernel-source-2.6.4/fs/nfsd.orig/nfsctl.c kernel-source-2.6.4/fs/nfsd/nfsctl.c
--- kernel-source-2.6.4/fs/nfsd.orig/nfsctl.c	2004-03-23 16:20:09 +0200
+++ kernel-source-2.6.4/fs/nfsd/nfsctl.c	2004-04-08 18:10:36 +0300
@@ -438,6 +436,9 @@
 	nfsd_cache_init();	/* RPC reply cache */
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
+#ifdef CONFIG_NFSD3_IDMAP
+	nfsd3_idmap_init();	/* User/Group ID mapping */
+#endif /* CONFIG_NFSD3_IDMAP */
 #ifdef CONFIG_NFSD_V4
 	nfsd_idmap_init();      /* Name to ID mapping */
 #endif /* CONFIG_NFSD_V4 */
@@ -467,6 +468,9 @@
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
+#ifdef CONFIG_NFSD3_IDMAP
+	nfsd3_idmap_shutdown();
+#endif /* CONFIG_NFSD3_IDMAP */
 #ifdef CONFIG_NFSD_V4
 	nfsd_idmap_shutdown();
 #endif /* CONFIG_NFSD_V4 */
--- kernel-source-2.6.4/include/linux/nfsd_idmap.h.orig	2004-03-23 17:23:13 +0200
+++ kernel-source-2.6.4/include/linux/nfsd_idmap.h	2004-04-12 15:56:33 +0300
@@ -51,4 +51,16 @@
 int nfsd_map_uid_to_name(struct svc_rqst *, __u32, char *);
 int nfsd_map_gid_to_name(struct svc_rqst *, __u32, char *);
 
+#ifdef CONFIG_NFSD3_IDMAP
+
+#define IDMAP_UID_NONE		((uid_t)-1)
+
+void nfsd3_idmap_init(void);
+void nfsd3_idmap_shutdown(void);
+
+int nfsd3_map_uid_to_uid(struct svc_rqst *rqstp, __u32 id, __u32 *idm);
+
+int nfsd3_map_gid_to_gid(struct svc_rqst *rqstp, __u32 id, __u32 *idm);
+#endif
+
 #endif /* LINUX_NFSD_IDMAP_H */
--- kernel-source-2.6.4/include/linux/nfsd/export.h~	2004-02-04 05:43:56 +0200
+++ kernel-source-2.6.4/include/linux/nfsd/export.h	2004-04-08 21:36:29 +0300
@@ -32,7 +32,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40 80 100 currently unused */
+#define NFSEXP_IDMAPD		0x0040
+/* 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
--- kernel-source-2.6.4/fs/Kconfig.orig	2004-03-23 16:58:28 +0200
+++ kernel-source-2.6.4/fs/Kconfig	2004-03-25 12:42:09 +0200
@@ -1373,6 +1373,13 @@
 	  If you would like to include the NFSv3 server as well as the NFSv2
 	  server, say Y here.  If unsure, say Y.
 
+config NFSD3_IDMAP
+	bool "Provide NFS User/Group ID Mapping support (EXPERIMENTAL)"
+	depends on NFSD_V3 && EXPERIMENTAL
+	help
+	  If you want NFSv3 server to map client's UID or/and GID to
+	  the server's one, say Y here.  If unsure, say N.
+
 config NFSD_V4
 	bool "Provide NFSv4 server support (EXPERIMENTAL)"
 	depends on NFSD_V3 && EXPERIMENTAL
--- kernel-source-2.6.4/fs/nfsd.orig/nfs3idmap.c	1970-01-01 02:00:00 +0200
+++ kernel-source-2.6.4/fs/nfsd/nfs3idmap.c	2004-04-15 15:39:31 +0300
@@ -0,0 +1,444 @@
+/*
+ *  fs/nfsd/nfs3idmap.c
+ *
+ *  User/Group ID Mapping.
+ *
+ *  Copyright (c) 2002, 2003 The Regents of the University of
+ *  Michigan.  All rights reserved.
+ *
+ *  Marius Aamodt Eriksen <marius@umich.edu>
+ *
+ *  Ed V. Bartosh <ed@sam-solutions.net>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/init.h>
+
+#include <linux/mm.h>
+#include <linux/utsname.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/nfs.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
+#include <linux/smp_lock.h>
+#include <linux/sunrpc/cache.h>
+#include <linux/nfsd_idmap.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+#include <linux/time.h>
+#include <linux/seq_file.h>
+#include <linux/sunrpc/svcauth.h>
+
+/*
+ * Cache entry
+ */
+
+/*
+ * XXX we know that IDMAP_NAMESZ < PAGE_SIZE, but it's ugly to rely on
+ * that.
+ */
+
+#define IDMAP_TYPE_USER  0
+#define IDMAP_TYPE_GROUP 1
+
+struct ent {
+	struct cache_head h;
+	int               type;		       /* User / Group */
+	uid_t             id;                  /* ID */
+	uid_t             idm;                 /* mapped ID */
+	char              authname[IDMAP_NAMESZ];
+};
+
+#define DefineSimpleCacheLookupMap(STRUCT, FUNC)	\
+        DefineCacheLookup(struct STRUCT, h, FUNC##_lookup,		\
+        (struct STRUCT *item, int set), /*no setup */,			\
+	& FUNC##_cache, FUNC##_hash(item), FUNC##_match(item, tmp),	\
+	STRUCT##_init(new, item), STRUCT##_update(tmp, item), 0)
+
+/* Common entry handling */
+
+#define ENT_HASHBITS          8
+#define ENT_HASHMAX           (1 << ENT_HASHBITS)
+#define ENT_HASHMASK          (ENT_HASHMAX - 1)
+
+static inline void
+ent_init(struct ent *new, struct ent *itm)
+{
+	new->id = itm->id;
+	new->idm = itm->idm;
+	new->type = itm->type;
+	strlcpy(new->authname, itm->authname, sizeof(new->authname));
+}
+
+static inline void
+ent_update(struct ent *new, struct ent *itm)
+{
+	ent_init(new, itm);
+}
+
+static void
+ent_put(struct cache_head *ch, struct cache_detail *cd)
+{
+	if (cache_put(ch, cd)) {
+		struct ent *map = container_of(ch, struct ent, h);
+		kfree(map);
+	}
+}
+
+/*
+ * cache
+ */
+
+static struct cache_head *idtoid_table[ENT_HASHMAX];
+
+static uint32_t
+idtoid_hash(struct ent *ent)
+{
+	uint32_t hash;
+
+	hash = hash_str(ent->authname, ENT_HASHBITS);
+	hash = hash_long(hash ^ ent->id, ENT_HASHBITS);
+
+	/* Flip LSB for user/group */
+	if (ent->type == IDMAP_TYPE_GROUP)
+		hash ^= 1;
+
+	return hash;
+}
+
+static void
+idtoid_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
+    int *blen)
+{
+ 	struct ent *ent = container_of(ch, struct ent, h);
+	char idstr[11];
+
+	qword_add(bpp, blen, ent->authname);
+	snprintf(idstr, sizeof(idstr), "%d", ent->id);
+	qword_add(bpp, blen, ent->type == IDMAP_TYPE_GROUP ? "group" : "user");
+	qword_add(bpp, blen, idstr);
+	qword_add(bpp, blen, idstr); /* mapped id */
+
+	(*bpp)[-1] = '\n';
+}
+
+static inline int
+idtoid_match(struct ent *a, struct ent *b)
+{
+	return (a->id == b->id && a->type == b->type &&
+	    strcmp(a->authname, b->authname) == 0);
+}
+
+static int
+idtoid_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
+{
+	struct ent *ent;
+
+	if (h == NULL) {
+		seq_puts(m, "#domain type id id\n");
+		return 0;
+	}
+	ent = container_of(h, struct ent, h);
+	seq_printf(m, "%s %s %d", ent->authname,
+	  ent->type == IDMAP_TYPE_GROUP ? "group" : "user", ent->id);
+	if (test_bit(CACHE_VALID, &h->flags))
+		seq_printf(m, " %d", ent->idm);
+	seq_printf(m, "\n");
+	return 0;
+}
+
+static int  idtoid_parse(struct cache_detail *, char *, int);
+
+struct cache_detail idtoid_cache = {
+	.hash_size	= ENT_HASHMAX,
+	.hash_table	= idtoid_table,
+	.name		= "nfs3.idtoid",
+	.cache_put	= ent_put,
+	.cache_request	= idtoid_request,
+	.cache_parse	= idtoid_parse,
+	.cache_show	= idtoid_show,
+};
+
+static struct ent *idtoid_lookup(struct ent *, int);
+
+static int
+idtoid_parse(struct cache_detail *cd, char *buf, int buflen)
+{
+	struct ent ent, *res;
+	char *buf1, *bp;
+	int error = -EINVAL;
+
+	if (buf[buflen - 1] != '\n')
+		return (-EINVAL);
+	buf[buflen - 1]= '\0';
+
+	buf1 = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (buf1 == NULL)
+		return (-ENOMEM);
+
+	memset(&ent, 0, sizeof(ent));
+
+	/* Authentication name */
+	if (qword_get(&buf, buf1, PAGE_SIZE) <= 0)
+			goto out;
+	memcpy(ent.authname, buf1, sizeof(ent.authname));
+
+	/* Type */
+	if (qword_get(&buf, buf1, PAGE_SIZE) <= 0)
+		goto out;
+	ent.type = strcmp(buf1, "user") == 0 ?
+		IDMAP_TYPE_USER : IDMAP_TYPE_GROUP;
+
+	/* ID */
+	if (qword_get(&buf, buf1, PAGE_SIZE) <= 0)
+		goto out;
+	ent.id = simple_strtoul(buf1, &bp, 10);
+	if (bp == buf1)
+		goto out;
+
+	/* expiry */
+	ent.h.expiry_time = get_expiry(&buf);
+	if (ent.h.expiry_time == 0)
+		goto out;
+
+	/* Mapped ID */
+	if (qword_get(&buf, buf1, PAGE_SIZE) <= 0)
+		goto out;
+	ent.idm = simple_strtoul(buf1, &bp, 10);
+	if (bp == buf1)
+		goto out;
+
+	error = -ENOMEM;	
+	if ((res = idtoid_lookup(&ent, 1)) == NULL)
+		goto out;
+
+	ent_put(&res->h, &idtoid_cache);
+
+	error = 0;
+out:
+	kfree(buf1);
+
+	return error;
+}
+
+static DefineSimpleCacheLookupMap(ent, idtoid);
+
+/*
+ * Exported API
+ */
+
+void
+nfsd3_idmap_init(void)
+{
+	cache_register(&idtoid_cache);
+}
+
+void
+nfsd3_idmap_shutdown(void)
+{
+	cache_unregister(&idtoid_cache);
+}
+
+/*
+ * Deferred request handling
+ */
+
+struct idmap_defer_req {
+       struct cache_req		req;
+       struct cache_deferred_req deferred_req;
+       wait_queue_head_t	waitq;
+       atomic_t			count;
+};
+
+static void
+put_mdr(struct idmap_defer_req *mdr)
+{
+	wait_queue_head_t	*waitq = &mdr->waitq;
+
+	if (atomic_dec_and_test(&mdr->count))
+		kfree(mdr);
+	else
+		wake_up(waitq);
+}
+
+static void
+idmap_revisit(struct cache_deferred_req *dreq, int toomany)
+{
+	struct idmap_defer_req *mdr =
+		container_of(dreq, struct idmap_defer_req, deferred_req);
+
+	put_mdr(mdr);
+}
+
+static struct cache_deferred_req *
+idmap_defer(struct cache_req *req)
+{
+	struct idmap_defer_req *mdr =
+		container_of(req, struct idmap_defer_req, req);
+
+	mdr->deferred_req.revisit = idmap_revisit;
+	return (&mdr->deferred_req);
+}
+
+static int threads_waiting = 0;
+
+static inline void
+idmap_wait(struct idmap_defer_req *mdr, struct svc_rqst *rqstp) {
+
+	/* Note: BKL prevents races with nfsd_svc and other lookups */
+	lock_kernel();
+	/* XXX: Does it matter that threads_waiting isn't per-server? */
+
+	if (2 * threads_waiting > rqstp->rq_server->sv_nrthreads)
+		goto out;
+	threads_waiting++;
+	schedule_timeout(10 * HZ);
+	threads_waiting--;
+out:
+	unlock_kernel();
+}
+
+static inline int
+do_idmap_lookup(struct ent *(*lookup_fn)(struct ent *, int), struct ent *key,
+		struct cache_detail *detail, struct ent **item,
+		struct idmap_defer_req *mdr)
+{
+	*item = lookup_fn(key, 0);
+	if (!*item)
+		return -ENOMEM;
+	return cache_check(detail, &(*item)->h, &mdr->req);
+}
+
+static inline int
+do_idmap_lookup_nowait(struct ent *(*lookup_fn)(struct ent *, int),
+			struct ent *key, struct cache_detail *detail,
+			struct ent **item)
+{
+	int ret = -ENOMEM;
+
+	*item = lookup_fn(key, 0);
+	if (!*item)
+		goto out_err;
+	ret = -ETIMEDOUT;
+	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
+			|| (*item)->h.expiry_time < get_seconds()
+			|| detail->flush_time > (*item)->h.last_refresh)
+		goto out_put;
+	ret = -ENOENT;
+	if (test_bit(CACHE_NEGATIVE, &(*item)->h.flags))
+		goto out_put;
+	return 0;
+out_put:
+	ent_put(&(*item)->h, detail);
+out_err:
+	*item = NULL;
+	return ret;
+}
+
+static inline void
+init_mdr(struct idmap_defer_req *mdr, wait_queue_t *waitq)
+{
+
+	memset(mdr, 0, sizeof(*mdr));
+	init_waitqueue_head(&mdr->waitq);
+	add_wait_queue(&mdr->waitq, waitq);
+	atomic_set(&mdr->count, 2);
+	mdr->req.defer = idmap_defer;
+}
+
+static inline void
+warn_no_idmapd(void) {
+	static time_t last_warning = 0;
+
+	if (last_warning < get_seconds() - 60) {
+		last_warning = get_seconds();
+		printk(KERN_WARNING "nfsd: idmapd timed out; "
+		  "check if idmapd is running?\n");
+	}
+}
+
+static int
+idmap_lookup(struct svc_rqst *rqstp,
+		struct ent *(*lookup_fn)(struct ent *, int), struct ent *key,
+		struct cache_detail *detail, struct ent **item)
+{
+	DECLARE_WAITQUEUE(waitq, current);
+	struct idmap_defer_req *mdr;
+	int ret;
+
+	mdr = kmalloc(sizeof(*mdr), GFP_KERNEL);
+	if (!mdr)
+		return -ENOMEM;
+
+	init_mdr(mdr, &waitq);
+	set_task_state(current, TASK_INTERRUPTIBLE);
+	ret = do_idmap_lookup(lookup_fn, key, detail, item, mdr);
+	
+	if (ret == -EAGAIN) {
+		idmap_wait(mdr, rqstp);
+		ret = do_idmap_lookup_nowait(lookup_fn, key, detail, item);
+	} else {
+		put_mdr(mdr);
+		put_mdr(mdr);
+ 	}
+ 	return ret;
+ }
+
+static int
+idmap_id_to_id(struct svc_rqst *rqstp, int type, uid_t id, uid_t *idm)
+{
+	struct ent *item, key = {
+		.type = type,
+		.id = id,
+	};
+	int ret;
+
+	strlcpy(key.authname, rqstp->rq_client->name, sizeof(key.authname));
+	ret = idmap_lookup(rqstp, idtoid_lookup, &key, &idtoid_cache, &item);
+	if (ret)
+		return ret;
+	*idm = item->idm;
+	ent_put(&item->h, &idtoid_cache);
+	return 0;
+}
+
+int
+nfsd3_map_uid_to_uid(struct svc_rqst *rqstp, __u32 id, __u32 *idm)
+{
+	return idmap_id_to_id(rqstp, IDMAP_TYPE_USER, id, idm);
+}
+
+int
+nfsd3_map_gid_to_gid(struct svc_rqst *rqstp, __u32 id, __u32 *idm)
+{
+	return idmap_id_to_id(rqstp, IDMAP_TYPE_GROUP, id, idm);
+}

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=nfs-utils-1.0.6-uidmapping.patch

--- nfs-utils-1.0.6/utils/idmapd/idmapd.c.orig	2004-03-23 16:12:15 +0200
+++ nfs-utils-1.0.6/utils/idmapd/idmapd.c	2004-04-08 16:22:44 +0300
@@ -96,6 +96,8 @@
 
 #define IC_IDNAME 1
 #define IC_NAMEID 2
+#define IC_IDID 3
+
 struct idmap_client {
 	int                        ic_fd;
 	int                        ic_dirfd;
@@ -122,9 +124,10 @@
 static void imconv(struct idmap_client *, struct idmap_msg *);
 static void idtonameres(struct idmap_msg *);
 static void nametoidres(struct idmap_msg *);
+static void idtoidres(struct idmap_msg *);
 
 static int nfsdopen(char *);
-static int nfsdopenone(struct idmap_client *, short, char *);
+static int nfsdopenone(struct idmap_client *, short, char *, int);
 
 size_t  strlcat(char *, const char *, size_t);
 size_t  strlcpy(char *, const char *, size_t);
@@ -137,7 +140,7 @@
 static char *nobodyuser, *nobodygroup;
 static uid_t nobodyuid;
 static gid_t nobodygid;
-static struct idmap_client nfsd_ic[2];
+static struct idmap_client nfsd_ic[3];
 
 /* Used by cfg.c */
 char *conf_path;
@@ -418,6 +428,18 @@
 			return;
 
 		break;
+	case IC_IDID:
+		im.im_conv = IDMAP_CONV_IDTOID;
+		if (getfield(&bp, buf1, sizeof(buf1)) == -1)
+			return;
+		if ((im.im_id = strtoul(buf1, (char **)NULL, 10)) == ULONG_MAX &&
+		    errno == ERANGE)
+			return;
+		/* Ugly, but we need client name */
+		strlcpy(im.im_name, authbuf, sizeof(im.im_name));
+
+		break;
+
 	default:
 		warnx("Unknown which type %d", ic->ic_which);
 		return;
@@ -468,6 +490,25 @@
 		bp[-1] = '\n';
 
 		break;
+		
+	case IC_IDID:
+		/* Type */
+		p = im.im_type == IDMAP_TYPE_USER ? "user" : "group";
+		addfield(&bp, &bsiz, p);
+		/* ID */
+		snprintf(buf1, sizeof(buf1), "%u", im.im_id);
+		addfield(&bp, &bsiz, buf1);
+		/* expiry */
+		snprintf(buf1, sizeof(buf1), "%lu", time(NULL) + NFSD_EXPIRY);
+		addfield(&bp, &bsiz, buf1);
+		/* Mapped ID */
+		snprintf(buf1, sizeof(buf1), "%u", im.im_idm);
+		addfield(&bp, &bsiz, buf1);
+
+		bp[-1] = '\n';
+
+		break;
+
 	default:
 		warnx("Unknown which type %d", ic->ic_which);
 		return;
@@ -506,6 +547,14 @@
 			    im->im_type == IDMAP_TYPE_USER ? "user" : "group",
 			    im->im_name, im->im_id);
 		break;
+	case IDMAP_CONV_IDTOID:
+		idtoidres(im);
+		if (verbose > 1)
+			warnx("%s %s: (%s) id \"%s:%d\" -> id \"%d\"",
+			    ic->ic_id, ic->ic_clid,
+			    im->im_type == IDMAP_TYPE_USER ? "user" : "group",
+			    im->im_name, im->im_id, im->im_idm);
+		break;	      
 	default:
 		warnx("Invalid conversion type (%d) in message", im->im_conv);
 		im->im_status |= IDMAP_STATUS_INVALIDMSG;
@@ -541,18 +590,18 @@
 static int
 nfsdopen(char *path)
 {
-	return ((nfsdopenone(&nfsd_ic[0], IC_NAMEID, path) == 0 && 
-		    nfsdopenone(&nfsd_ic[1], IC_IDNAME, path) == 0) ? 0 : -1);
+	return ((nfsdopenone(&nfsd_ic[2], IC_IDID, path, 3) == 0 || (nfsdopenone(&nfsd_ic[0], IC_NAMEID, path, 4) == 0 &&
+	    nfsdopenone(&nfsd_ic[1], IC_IDNAME, path,4)) == 0) ? 0 : -1);
 }
 
 static int
-nfsdopenone(struct idmap_client *ic, short which, char *path)
+nfsdopenone(struct idmap_client *ic, short which, char *path, int version)
 {
 	char *whichstr;
 
 	whichstr = which == IC_IDNAME ? "idtoname" : "nametoid";
 	snprintf(ic->ic_path, sizeof(ic->ic_path),
-	    "%s/nfs4.%s/channel", path, whichstr);
+		"%s/nfs%d.%s/channel", path, version, "idtoid");
 	if ((ic->ic_fd = open(ic->ic_path, O_RDWR, 0)) == -1) {
 		warn("%s", ic->ic_path);
 		return (-1);
@@ -661,6 +710,31 @@
 
 	im->im_id = id;
 }
+static void
+idtoidres(struct idmap_msg *im)
+{
+        struct passwd *pw;
+        struct group *gr;
+        char *name = NULL;
+	char buf[IDMAP_MAXMSGSZ];
+
+        switch (im->im_type) {
+	case IDMAP_TYPE_USER:
+	        snprintf(buf, IDMAP_MAXMSGSZ-1, "%s:%u", im->im_name, im->im_id);
+		name = conf_get_str("Mapping3", buf);
+	        pw = (name != NULL) ? getpwnam(name) : NULL;
+		im->im_idm = (pw != NULL) ? pw->pw_uid : IDMAP_UID_NONE;
+                break;
+	case IDMAP_TYPE_GROUP:
+	        snprintf(buf, IDMAP_MAXMSGSZ-1, "@%s:%u", im->im_name, im->im_id);
+		name = conf_get_str("Mapping3", buf);
+	        gr = (name != NULL) ? getgrnam(name) : NULL;
+		im->im_idm = (gr != NULL) ? gr->gr_gid : IDMAP_UID_NONE;
+                break;
+        }
+
+	im->im_status |= IDMAP_STATUS_SUCCESS;
+}
 
 static int
 validateascii(char *string, u_int32_t len)
--- nfs-utils-1.0.6/utils/idmapd/nfs_idmap.h.orig	2004-04-12 16:02:21 +0300
+++ nfs-utils-1.0.6/utils/idmapd/nfs_idmap.h	2004-04-12 16:04:04 +0300
@@ -45,6 +45,7 @@
 
 #define IDMAP_CONV_IDTONAME 0
 #define IDMAP_CONV_NAMETOID 1
+#define IDMAP_CONV_IDTOID   2
 
 #define IDMAP_STATUS_INVALIDMSG 0x01
 #define IDMAP_STATUS_AGAIN      0x02
@@ -53,11 +54,14 @@
 
 #define IDMAP_MAXMSGSZ   256
 
+#define IDMAP_UID_NONE	((u_int32_t)-1)
+
 struct idmap_msg {
 	u_int8_t  im_type;
 	u_int8_t  im_conv;
 	char      im_name[IDMAP_NAMESZ];
 	u_int32_t im_id;
+	u_int32_t im_idm;
 	u_int8_t  im_status;
 };
 
diff -ruN nfs-utils-0.3.3.orig/support/nfs/xmalloc.c nfs-utils-0.3.3/support/nfs/xmalloc.c
--- nfs-utils-1.0.6/support/export/nfsctl.c~	2004-03-23 16:12:15 +0200
+++ nfs-utils-1.0.6/support/export/nfsctl.c	2004-04-08 16:40:56 +0300
@@ -90,8 +90,12 @@
 	if (stat(exp->m_export.m_path, &stb) < 0)
 		return 0;
 
-	if (exp->m_export.e_maptype != CLE_MAP_IDENT) {
-		xlog(L_ERROR, "%s: unsupported mapping; kernel supports only 'identity' (default)",
+	if (exp->m_export.e_maptype != CLE_MAP_IDENT
+#ifdef  UGIDMAP_SUPPORTED
+	  && exp->m_export.e_maptype != CLE_MAP_IDMAPD
+#endif
+	) {
+		xlog(L_ERROR, "%s: unsupported mapping; kernel supports only 'identity' (default) and 'idmapd'",
 		     exp->m_export.m_path);
 		errno = EINVAL;
 		return 0;
--- nfs-utils-1.0.6/configure.in.orig	2004-04-08 15:47:39 +0300
+++ nfs-utils-1.0.6/configure.in	2004-04-08 15:48:51 +0300
@@ -40,12 +40,12 @@
 	fi
 	AC_SUBST(enable_nfsv3)
 AC_ARG_ENABLE(kprefix,
-	[  --enable-kprefix       install progs as rpc.knfsd etc],
+	[  --enable-kprefix        install progs as rpc.knfsd etc],
 	test "$enableval" = "yes" && kprefix=k,
 	kprefix=)
 	AC_SUBST(kprefix)
 AC_ARG_ENABLE(secure-statd,
-	[  --enable-secure-statd  Only lockd can use statd (security)],
+	[  --enable-secure-statd   Only lockd can use statd (security)],
 	test "$enableval" = "yes" && secure_statd=yes,
 	secure_statd=no)
 	if test "$secure_statd" = yes; then
@@ -53,7 +53,7 @@
 	fi
 	AC_SUBST(secure_statd)
 AC_ARG_ENABLE(rquotad,
-	[  --enable-rquotad          enable rquotad],
+	[  --enable-rquotad        enable rquotad],
 	enable_rquotad=$enableval,
 	enable_rquotad=yes)
 	if test "$enable_rquotad" = yes; then
@@ -62,6 +62,17 @@
 		RQUOTAD=
 	fi
 	AC_SUBST(RQUOTAD)
+AC_ARG_ENABLE(ugidmapping,
+	[  --enable-uidmapping     enable uid/gid mapping],
+	enable_ugidmapping=$enableval,
+	enable_ugidmapping=no)
+	if test "$enable_ugidmapping" = yes; then
+		AC_DEFINE(UGIDMAP_SUPPORTED)
+	else
+		enable_ugidmapping=
+	fi
+	AC_SUBST(enable_ugidmapping)
+
 dnl AC_ARG_ENABLE(frob,	enable frobnicator,,		    enable_frob=test)
 AC_CONFIG_HEADER(support/include/config.h)
 
--- nfs-utils-0.3.3.orig/rules.mk	Sun Dec  5 00:02:01 1999
+++ nfs-utils-0.3.3/rules.mk	Thu Jun 27 17:55:08 2002
@@ -70,7 +70,7 @@
 # Cleaning rules
 ##################################################################
 clean distclean::
-	rm -f *.o *~ \#* a.out core
+	rm -f *.o *~ *.a \#* a.out core
 
 distclean::
 	rm -f LOG X Y Z x y z .depend
--- nfs-utils-1.0.6/support/nfs/exports.c.orig	2003-08-06 08:19:42 +0300
+++ nfs-utils-1.0.6/support/nfs/exports.c	2004-04-12 11:15:12 +0300
@@ -197,6 +197,9 @@
 	case CLE_MAP_IDENT:
 		fprintf(fp, "identity,");
 		break;
+        case CLE_MAP_IDMAPD:
+                fprintf(fp, "idmapd,");
+                break;
 	case CLE_MAP_UGIDD:
 		fprintf(fp, "ugidd,");
 		break;
@@ -374,8 +377,11 @@
 			ep->e_flags &= ~NFSEXP_NOAUTHNLM;
 		else if (strcmp(opt, "insecure_locks") == 0)
 			ep->e_flags |= NFSEXP_NOAUTHNLM;
-		else if (strncmp(opt, "mapping=", 8) == 0)
+		else if (strncmp(opt, "mapping=", 8) == 0) {
 			ep->e_maptype = parsemaptype(opt+8);
+                        if (ep->e_maptype == CLE_MAP_IDMAPD)
+                                ep->e_flags |= NFSEXP_IDMAPD;
+		}
 		else if (strcmp(opt, "map_identity") == 0)	/* old style */
 			ep->e_maptype = CLE_MAP_IDENT;
 		else if (strcmp(opt, "map_daemon") == 0)	/* old style */
@@ -528,11 +534,13 @@
 static int
 parsemaptype(char *type)
 {
-	if (!strcmp(type, "identity"))
+	if (!strncmp(type, "identity", 8))
 		return CLE_MAP_IDENT;
-	if (!strcmp(type, "ugidd"))
+	if (!strncmp(type, "idmapd", 6))
+		return CLE_MAP_IDMAPD;
+	if (!strncmp(type, "ugidd", 5))
 		return CLE_MAP_UGIDD;
-	if (!strcmp(type, "file"))
+	if (!strncmp(type, "file", 4))
 		return CLE_MAP_FILE;
 	syntaxerr("invalid map type");
 	return CLE_MAP_IDENT;	/* default */
--- nfs-utils-1.0.6/support/include/config.h.in~	2004-04-08 16:56:26 +0300
+++ nfs-utils-1.0.6/support/include/config.h.in	2004-04-08 17:00:01 +0300
@@ -29,3 +29,7 @@
 #undef HAVE_KRB5
 /* XXX: you don't want to know: */
 #undef USE_PRIVATE_KRB5_FUNCTIONS
+
+/* Define this if you want uid/gid mapping support compiled in
+ */
+#undef  UGIDMAP_SUPPORTED
--- nfs-utils-1.0.6/utils/exportfs/exportfs.c~	2004-04-08 16:56:28 +0300
+++ nfs-utils-1.0.6/utils/exportfs/exportfs.c	2004-04-08 17:07:30 +0300
@@ -142,6 +142,8 @@
 	if (!new_cache)
 		xtab_mount_write();
 
+	export_freeall();
+	
 	return export_errno;
 }
 
--- nfs-utils-1.0.6/support/include/nfslib.h~	2004-04-08 16:56:26 +0300
+++ nfs-utils-1.0.6/support/include/nfslib.h	2004-04-08 17:18:17 +0300
@@ -53,6 +53,7 @@
 	CLE_MAP_IDENT = 0,
 	CLE_MAP_FILE,
 	CLE_MAP_UGIDD,
+	CLE_MAP_IDMAPD,
 };
 
 /*
--- nfs-utils-1.0.6/support/include/nfs/export.h~	2004-04-08 16:56:26 +0300
+++ nfs-utils-1.0.6/support/include/nfs/export.h	2004-04-08 17:29:07 +0300
@@ -17,7 +17,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40, 80, 100 unused */
+#define NFSEXP_IDMAPD		0x0040
+/* 80, 100 unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
--- nfs-utils-1.0.6/utils/idmapd/idmapd.conf~	2004-04-12 16:08:15 +0300
+++ nfs-utils-1.0.6/utils/idmapd/idmapd.conf	2004-04-12 16:12:06 +0300
@@ -8,3 +8,7 @@
 
 Nobody-User = nobody
 Nobody-Group = nobody
+
+[Mapping3]
+
+

--=-=-=--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
