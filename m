From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 34 - IDmap support for the NFSv4 server.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006H9-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqB-0006sr-KD
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:23 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPpp-0005aj-PB
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:01 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:41 +1100
To: Andrew Morton <akpm@osdl.org>
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


Updated version which uses ascii-encoding of messages, from
http://www.citi.umich.edu/u/marius/linux-2.5.70-idmap-server-new.diff
as of October 14, 2003.

 ----------- Diffstat output ------------
 ./fs/nfsd/Makefile                      |    2 
 ./fs/nfsd/nfs4idmap.c                   |  569 ++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfs4proc.c                    |    3 
 ./fs/nfsd/nfs4xdr.c                     |   54 +--
 ./fs/nfsd/nfsctl.c                      |    7 
 ./fs/nfsd/nfsproc.c                     |    1 
 ./include/linux/nfsd/xdr4.h             |    6 
 ./include/linux/nfsd_idmap.h            |   54 +++
 ./net/sunrpc/auth_gss/gss_mech_switch.c |    1 
 9 files changed, 668 insertions(+), 29 deletions(-)

diff ./fs/nfsd/Makefile~current~ ./fs/nfsd/Makefile
--- ./fs/nfsd/Makefile~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/Makefile	2004-02-24 10:42:30.000000000 +1100
@@ -7,5 +7,5 @@ obj-$(CONFIG_NFSD)	+= nfsd.o
 nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
 			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
-nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o
+nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o
 nfsd-objs		:= $(nfsd-y)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfs4idmap.c	2004-02-24 10:42:30.000000000 +1100
@@ -0,0 +1,569 @@
+/*
+ *  fs/nfsd/nfs4idmap.c
+ *
+ *  Mapping of UID/GIDs to name and vice versa.
+ *
+ *  Copyright (c) 2002, 2003 The Regents of the University of
+ *  Michigan.  All rights reserved.
+ *
+ *  Marius Aamodt Eriksen <marius@umich.edu>
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
+	uid_t             id;
+	char              name[IDMAP_NAMESZ];
+	char              authname[IDMAP_NAMESZ];
+};
+
+#define DefineSimpleCacheLookupMap(STRUCT, FUNC)			\
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
+	new->type = itm->type;
+
+	strlcpy(new->name, itm->name, sizeof(new->name));
+	strlcpy(new->authname, itm->authname, sizeof(new->name));
+}
+
+static inline void
+ent_update(struct ent *new, struct ent *itm)
+{
+	ent_init(new, itm);
+}
+
+void
+ent_put(struct cache_head *ch, struct cache_detail *cd)
+{
+	if (cache_put(ch, cd)) {
+		struct ent *map = container_of(ch, struct ent, h);
+		kfree(map);
+	}
+}
+
+/*
+ * ID -> Name cache
+ */
+
+static struct cache_head *idtoname_table[ENT_HASHMAX];
+
+static uint32_t
+idtoname_hash(struct ent *ent)
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
+idtoname_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
+    int *blen)
+{
+ 	struct ent *ent = container_of(ch, struct ent, h);
+	char idstr[11];
+
+	qword_add(bpp, blen, ent->authname);
+	snprintf(idstr, sizeof(idstr), "%d", ent->id);
+	qword_add(bpp, blen, ent->type == IDMAP_TYPE_GROUP ? "group" : "user");
+	qword_add(bpp, blen, idstr);
+
+	(*bpp)[-1] = '\n';
+}
+
+static inline int
+idtoname_match(struct ent *a, struct ent *b)
+{
+	return (a->id == b->id && a->type == b->type &&
+	    strcmp(a->authname, b->authname) == 0);
+}
+
+static int
+idtoname_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
+{
+	struct ent *ent;
+
+	if (h == NULL) {
+		seq_puts(m, "#domain type id [name]\n");
+		return 0;
+	}
+	ent = container_of(h, struct ent, h);
+	seq_printf(m, "%s %s %d", ent->authname,
+			ent->type == IDMAP_TYPE_GROUP ? "group" : "user",
+			ent->id);
+	if (test_bit(CACHE_VALID, &h->flags))
+		seq_printf(m, " %s", ent->name);
+	seq_printf(m, "\n");
+	return 0;
+}
+
+static int         idtoname_parse(struct cache_detail *, char *, int);
+static struct ent *idtoname_lookup(struct ent *, int);
+
+struct cache_detail idtoname_cache = {
+	.hash_size	= ENT_HASHMAX,
+	.hash_table	= idtoname_table,
+	.name		= "nfs4.idtoname",
+	.cache_put	= ent_put,
+	.cache_request	= idtoname_request,
+	.cache_parse	= idtoname_parse,
+	.cache_show	= idtoname_show,
+};
+
+int
+idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
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
+		goto out;
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
+	/* Name */
+	error = qword_get(&buf, buf1, PAGE_SIZE);
+	if (error == -EINVAL)
+		goto out;
+	if (error == -ENOENT)
+		set_bit(CACHE_NEGATIVE, &ent.h.flags);
+	else {
+		if (error >= IDMAP_NAMESZ) {
+			error = -EINVAL;
+			goto out;
+		}
+		memcpy(ent.name, buf1, sizeof(ent.name));
+	}
+	error = -ENOMEM;
+	if ((res = idtoname_lookup(&ent, 1)) == NULL)
+		goto out;
+
+	ent_put(&res->h, &idtoname_cache);
+
+	error = 0;
+out:
+	kfree(buf1);
+
+	return error;
+}
+
+static DefineSimpleCacheLookupMap(ent, idtoname);
+
+/*
+ * Name -> ID cache
+ */
+
+static struct cache_head *nametoid_table[ENT_HASHMAX];
+
+static inline int
+nametoid_hash(struct ent *ent)
+{
+	return hash_str(ent->name, ENT_HASHBITS);
+}
+
+void
+nametoid_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
+    int *blen)
+{
+ 	struct ent *ent = container_of(ch, struct ent, h);
+
+	qword_add(bpp, blen, ent->authname);
+	qword_add(bpp, blen, ent->type == IDMAP_TYPE_GROUP ? "group" : "user");
+	qword_add(bpp, blen, ent->name);
+
+	(*bpp)[-1] = '\n';
+}
+
+static inline int
+nametoid_match(struct ent *a, struct ent *b)
+{
+	return (a->type == b->type && strcmp(a->name, b->name) == 0 &&
+	    strcmp(a->authname, b->authname) == 0);
+}
+
+static int
+nametoid_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
+{
+	struct ent *ent;
+
+	if (h == NULL) {
+		seq_puts(m, "#domain type name [id]\n");
+		return 0;
+	}
+	ent = container_of(h, struct ent, h);
+	seq_printf(m, "%s %s %s", ent->authname,
+			ent->type == IDMAP_TYPE_GROUP ? "group" : "user",
+			ent->name);
+	if (test_bit(CACHE_VALID, &h->flags))
+		seq_printf(m, " %d", ent->id);
+	seq_printf(m, "\n");
+	return 0;
+}
+
+static struct ent *nametoid_lookup(struct ent *, int);
+int                nametoid_parse(struct cache_detail *, char *, int);
+
+struct cache_detail nametoid_cache = {
+	.hash_size	= ENT_HASHMAX,
+	.hash_table	= nametoid_table,
+	.name		= "nfs4.nametoid",
+	.cache_put	= ent_put,
+	.cache_request	= nametoid_request,
+	.cache_parse	= nametoid_parse,
+	.cache_show	= nametoid_show,
+};
+
+int
+nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
+{
+	struct ent ent, *res;
+	char *buf1;
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
+		goto out;
+	memcpy(ent.authname, buf1, sizeof(ent.authname));
+
+	/* Type */
+	if (qword_get(&buf, buf1, PAGE_SIZE) <= 0)
+		goto out;
+	ent.type = strcmp(buf1, "user") == 0 ?
+		IDMAP_TYPE_USER : IDMAP_TYPE_GROUP;
+
+	/* Name */
+	error = qword_get(&buf, buf1, PAGE_SIZE);
+	if (error <= 0 || error >= IDMAP_NAMESZ)
+		goto out;
+	memcpy(ent.name, buf1, sizeof(ent.name));
+
+	/* expiry */
+	ent.h.expiry_time = get_expiry(&buf);
+	if (ent.h.expiry_time == 0)
+		goto out;
+
+	/* ID */
+	error = get_int(&buf, &ent.id);
+	if (error == -EINVAL)
+		goto out;
+	if (error == -ENOENT)
+		set_bit(CACHE_NEGATIVE, &ent.h.flags);
+
+	error = -ENOMEM;
+	if ((res = nametoid_lookup(&ent, 1)) == NULL)
+		goto out;
+
+	ent_put(&res->h, &nametoid_cache);
+	error = 0;
+out:
+	kfree(buf1);
+
+	return (error);
+}
+
+static DefineSimpleCacheLookupMap(ent, nametoid);
+
+/*
+ * Exported API
+ */
+
+void
+nfsd_idmap_init(void)
+{
+	cache_register(&idtoname_cache);
+	cache_register(&nametoid_cache);
+}
+
+void
+nfsd_idmap_shutdown(void)
+{
+	cache_unregister(&idtoname_cache);
+	cache_unregister(&nametoid_cache);
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
+	if (atomic_dec_and_test(&mdr->count))
+		kfree(mdr);
+}
+
+static void
+idmap_revisit(struct cache_deferred_req *dreq, int toomany)
+{
+	struct idmap_defer_req *mdr =
+		container_of(dreq, struct idmap_defer_req, deferred_req);
+
+	wake_up(&mdr->waitq);
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
+static inline int
+idmap_lookup_wait(struct idmap_defer_req *mdr, wait_queue_t waitq, struct
+		svc_rqst *rqstp) {
+	int ret = -ETIMEDOUT;
+
+	set_task_state(current, TASK_INTERRUPTIBLE);
+	lock_kernel();
+	/* XXX: Does it matter that threads_waiting isn't per-server? */
+	/* Note: BKL prevents races with nfsd_svc and other lookups */
+	if (2 * threads_waiting > rqstp->rq_server->sv_nrthreads)
+		goto out;
+	threads_waiting++;
+	schedule_timeout(10 * HZ);
+	threads_waiting--;
+	ret = 0;
+out:
+	unlock_kernel();
+	remove_wait_queue(&mdr->waitq, &waitq);
+	set_task_state(current, TASK_RUNNING);
+	put_mdr(mdr);
+	return ret;
+}
+
+static int
+idmap_lookup(struct svc_rqst *rqstp,
+		struct ent *(*lookup_fn)(struct ent *, int), struct ent *key,
+		struct cache_detail *detail, struct ent **item)
+{
+	struct idmap_defer_req *mdr;
+	DECLARE_WAITQUEUE(waitq, current);
+	int ret;
+
+	*item = lookup_fn(key, 0);
+	if (!*item)
+		return -ENOMEM;
+	mdr = kmalloc(sizeof(*mdr), GFP_KERNEL);
+	memset(mdr, 0, sizeof(*mdr));
+	init_waitqueue_head(&mdr->waitq);
+	add_wait_queue(&mdr->waitq, &waitq);
+	atomic_set(&mdr->count, 2);
+	mdr->req.defer = idmap_defer;
+	ret = cache_check(detail, &(*item)->h, &mdr->req);
+	if (ret == -EAGAIN) {
+		ret = idmap_lookup_wait(mdr, waitq, rqstp);
+		if (ret)
+			goto out;
+		/* Try again, but don't wait. */
+		*item = lookup_fn(key, 0);
+		ret = -ENOMEM;
+		if (!*item)
+			goto out;
+		ret = -ETIMEDOUT;
+		if (!test_bit(CACHE_VALID, &(*item)->h.flags)) {
+			ent_put(&(*item)->h, detail);
+			goto out;
+		}
+		ret = cache_check(detail, &(*item)->h, NULL);
+	}
+out:
+	return ret;
+}
+
+static int
+idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen,
+		uid_t *id)
+{
+	struct ent *item, key = {
+		.type = type,
+	};
+	int ret;
+
+	if (namelen + 1 > sizeof(key.name))
+		return -EINVAL;
+	memcpy(key.name, name, namelen);
+	key.name[namelen] = '\0';
+	strlcpy(key.authname, rqstp->rq_client->name, sizeof(key.authname));
+	ret = idmap_lookup(rqstp, nametoid_lookup, &key, &nametoid_cache, &item);
+	if (ret)
+		return ret;
+	*id = item->id;
+	ent_put(&item->h, &nametoid_cache);
+	return 0;
+}
+
+static int
+idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
+{
+	struct ent *item, key = {
+		.id = id,
+		.type = type,
+	};
+	int ret;
+
+	strlcpy(key.authname, rqstp->rq_client->name, sizeof(key.authname));
+	ret = idmap_lookup(rqstp, idtoname_lookup, &key, &idtoname_cache, &item);
+	if (ret)
+		return ret;
+	ret = strlen(item->name);
+	BUG_ON(ret > IDMAP_NAMESZ);
+	memcpy(name, item->name, ret);
+	ent_put(&item->h, &idtoname_cache);
+	return ret;
+}
+
+int
+nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
+		__u32 *id)
+{
+	return idmap_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, id);
+}
+
+int
+nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
+		__u32 *id)
+{
+	return idmap_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, id);
+}
+
+int
+nfsd_map_uid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
+{
+	return idmap_id_to_name(rqstp, IDMAP_TYPE_USER, id, name);
+}
+
+int
+nfsd_map_gid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
+{
+	return idmap_id_to_name(rqstp, IDMAP_TYPE_GROUP, id, name);
+}

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:30.000000000 +1100
@@ -568,7 +568,8 @@ nfsd4_verify(struct svc_rqst *rqstp, str
 
 	status = nfsd4_encode_fattr(current_fh, current_fh->fh_export,
 				    current_fh->fh_dentry, buf,
-				    &count, verify->ve_bmval);
+				    &count, verify->ve_bmval,
+				    rqstp);
 
 	/* this means that nfsd4_encode_fattr() ran out of space */
 	if (status == nfserr_resource && count == 0)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:30.000000000 +1100
@@ -51,10 +51,10 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/name_lookup.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
+#include <linux/nfsd_idmap.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -373,7 +373,7 @@ nfsd4_decode_fattr(struct nfsd4_compound
 		READMEM(buf, dummy32);
 		if (check_utf8(buf, dummy32))
 			return nfserr_inval;
-		if ((status = name_get_uid(buf, dummy32, &iattr->ia_uid)))
+		if ((status = nfsd_map_name_to_uid(argp->rqstp, buf, dummy32, &iattr->ia_uid)))
 			goto out_nfserr;
 		iattr->ia_valid |= ATTR_UID;
 	}
@@ -386,7 +386,7 @@ nfsd4_decode_fattr(struct nfsd4_compound
 		READMEM(buf, dummy32);
 		if (check_utf8(buf, dummy32))
 			return nfserr_inval;
-		if ((status = name_get_gid(buf, dummy32, &iattr->ia_gid)))
+		if ((status = nfsd_map_name_to_gid(argp->rqstp, buf, dummy32, &iattr->ia_gid)))
 			goto out_nfserr;
 		iattr->ia_valid |= ATTR_GID;
 	}
@@ -1239,13 +1239,16 @@ static u32 nfs4_ftypes[16] = {
  */
 int
 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		   struct dentry *dentry, u32 *buffer, int *countp, u32 *bmval)
+		struct dentry *dentry, u32 *buffer, int *countp, u32 *bmval,
+		struct svc_rqst *rqstp)
 {
 	u32 bmval0 = bmval[0];
 	u32 bmval1 = bmval[1];
 	struct kstat stat;
-	struct name_ent *owner = NULL;
-	struct name_ent *group = NULL;
+	char owner[IDMAP_NAMESZ];
+	u32 ownerlen = 0;
+	char group[IDMAP_NAMESZ];
+	u32 grouplen = 0;
 	struct svc_fh tempfh;
 	struct kstatfs statfs;
 	int buflen = *countp << 2;
@@ -1277,14 +1280,20 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		fhp = &tempfh;
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER) {
-		status = name_get_user(stat.uid, &owner);
-		if (status)
+		int temp = nfsd_map_uid_to_name(rqstp, stat.uid, owner);
+		if (temp < 0) {
+			status = temp;
 			goto out_nfserr;
+		}
+		ownerlen = (unsigned) temp;
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER_GROUP) {
-		status = name_get_group(stat.gid, &group);
-		if (status)
+		int temp = nfsd_map_gid_to_name(rqstp, stat.gid, group);
+		if (temp < 0) {
+			status = temp;
 			goto out_nfserr;
+		}
+		grouplen = (unsigned) temp;
 	}
 
 	if ((buflen -= 16) < 0)
@@ -1485,20 +1494,18 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		WRITE32(stat.nlink);
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER) {
-		int namelen  = strlen(owner->name);
-		buflen -= (XDR_QUADLEN(namelen) << 2) + 4;
+		buflen -= (XDR_QUADLEN(ownerlen) << 2) + 4;
 		if (buflen < 0)
 			goto out_resource;
-		WRITE32(namelen);
-		WRITEMEM(owner->name, namelen);
+		WRITE32(ownerlen);
+		WRITEMEM(owner, ownerlen);
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER_GROUP) {
-		int namelen = strlen(group->name);
-		buflen -= (XDR_QUADLEN(namelen) << 2) + 4;
+		buflen -= (XDR_QUADLEN(grouplen) << 2) + 4;
 		if (buflen < 0)
 			goto out_resource;
-		WRITE32(namelen);
-		WRITEMEM(group->name, namelen);
+		WRITE32(grouplen);
+		WRITEMEM(group, grouplen);
 	}
 	if (bmval1 & FATTR4_WORD1_RAWDEV) {
 		if ((buflen -= 8) < 0)
@@ -1566,10 +1573,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 out:
 	if (fhp == &tempfh)
 		fh_put(&tempfh);
-	if (owner)
-		name_put(owner);
-	if (group)
-		name_put(group);
 	return status;
 out_nfserr:
 	status = nfserrno(status);
@@ -1648,7 +1651,8 @@ nfsd4_encode_dirent(struct readdir_cd *c
 		}
 
 		nfserr = nfsd4_encode_fattr(NULL, exp,
-				dentry, p, &buflen, cd->rd_bmval);
+				dentry, p, &buflen, cd->rd_bmval,
+				cd->rd_rqstp);
 		if (!nfserr) {
 			p += buflen;
 			goto out;
@@ -1771,7 +1775,8 @@ nfsd4_encode_getattr(struct nfsd4_compou
 
 	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
 	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
-				    resp->p, &buflen, getattr->ga_bmval);
+				    resp->p, &buflen, getattr->ga_bmval,
+				    resp->rqstp);
 
 	if (!nfserr)
 		resp->p += buflen;
@@ -2381,6 +2386,7 @@ nfs4svc_decode_compoundargs(struct svc_r
 	args->tmpp = NULL;
 	args->to_free = NULL;
 	args->ops = args->iops;
+	args->rqstp = rqstp;
 
 	status = nfsd4_decode_compound(args);
 	if (status) {

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2004-02-24 10:42:30.000000000 +1100
@@ -24,6 +24,7 @@
 #include <linux/init.h>
 
 #include <linux/nfs.h>
+#include <linux/nfsd_idmap.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
@@ -436,6 +437,9 @@ static int __init init_nfsd(void)
 	nfsd_cache_init();	/* RPC reply cache */
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
+#ifdef CONFIG_NFSD_V4
+	nfsd_idmap_init();      /* Name to ID mapping */
+#endif /* CONFIG_NFSD_V4 */
 	if (proc_mkdir("fs/nfs", 0)) {
 		struct proc_dir_entry *entry;
 		entry = create_proc_entry("fs/nfs/exports", 0, NULL);
@@ -462,6 +466,9 @@ static void __exit exit_nfsd(void)
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
+#ifdef CONFIG_NFSD_V4
+	nfsd_idmap_shutdown();
+#endif /* CONFIG_NFSD_V4 */
 	unregister_filesystem(&nfsd_fs_type);
 }
 

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfsproc.c	2004-02-24 10:42:30.000000000 +1100
@@ -585,6 +585,7 @@ nfserrno (int errno)
 		{ nfserr_dquot, -EDQUOT },
 #endif
 		{ nfserr_stale, -ESTALE },
+		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
 		{ -1, -EIO }

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2004-02-24 10:42:30.000000000 +1100
@@ -375,7 +375,9 @@ struct nfsd4_compoundargs {
 		struct tmpbuf *next;
 		void *buf;
 	}				*to_free;
-	
+
+	struct svc_rqst			*rqstp;
+
 	u32				taglen;
 	char *				tag;
 	u32				minorversion;
@@ -419,7 +421,7 @@ void nfsd4_encode_operation(struct nfsd4
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 int nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		       struct dentry *dentry, u32 *buffer, int *countp, 
-		       u32 *bmval);
+		       u32 *bmval, struct svc_rqst *);
 extern int nfsd4_setclientid(struct svc_rqst *rqstp, 
 		struct nfsd4_setclientid *setclid);
 extern int nfsd4_setclientid_confirm(struct svc_rqst *rqstp, 

diff ./include/linux/nfsd_idmap.h~current~ ./include/linux/nfsd_idmap.h
--- ./include/linux/nfsd_idmap.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/nfsd_idmap.h	2004-02-24 10:42:30.000000000 +1100
@@ -0,0 +1,54 @@
+/*
+ *  include/linux/nfsd_idmap.h
+ *
+ *  Mapping of UID to name and vice versa.
+ *
+ *  Copyright (c) 2002, 2003 The Regents of the University of
+ *  Michigan.  All rights reserved.
+> *
+ *  Marius Aamodt Eriksen <marius@umich.edu>
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
+#ifndef LINUX_NFSD_IDMAP_H
+#define LINUX_NFSD_IDMAP_H
+
+#include <linux/in.h>
+#include <linux/sunrpc/svc.h>
+
+/* XXX from linux/nfs_idmap.h */
+#define IDMAP_NAMESZ 128
+
+void nfsd_idmap_init(void);
+void nfsd_idmap_shutdown(void);
+
+int nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
+int nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);
+int nfsd_map_uid_to_name(struct svc_rqst *, __u32, char *);
+int nfsd_map_gid_to_name(struct svc_rqst *, __u32, char *);
+
+#endif /* LINUX_NFSD_IDMAP_H */

diff ./net/sunrpc/auth_gss/gss_mech_switch.c~current~ ./net/sunrpc/auth_gss/gss_mech_switch.c
--- ./net/sunrpc/auth_gss/gss_mech_switch.c~current~	2004-02-24 10:40:29.000000000 +1100
+++ ./net/sunrpc/auth_gss/gss_mech_switch.c	2004-02-24 10:42:30.000000000 +1100
@@ -43,7 +43,6 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/name_lookup.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY        RPCDBG_AUTH


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
