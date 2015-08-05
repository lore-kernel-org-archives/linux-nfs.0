Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:36607 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbbHEVNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:53 -0400
Received: by ykeo23 with SMTP id o23so46445941yke.3
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:52 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 13/18] nfsd: add new tracepoints for nfsd_file cache
Date: Wed,  5 Aug 2015 17:13:31 -0400
Message-Id: <1438809216-4846-14-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 19 ++++++++--
 fs/nfsd/trace.h     | 99 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 115 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 0adcc674441d..44dee985864b 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -14,6 +14,7 @@
 #include "nfsd.h"
 #include "nfsfh.h"
 #include "filecache.h"
+#include "trace.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_FH
 
@@ -74,6 +75,7 @@ nfsd_file_alloc(struct knfsd_fh *fh, unsigned int may, unsigned int hashval)
 			if (may & NFSD_MAY_READ)
 				__set_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
 		}
+		trace_nfsd_file_alloc(nf);
 	}
 	return nf;
 }
@@ -81,6 +83,7 @@ nfsd_file_alloc(struct knfsd_fh *fh, unsigned int may, unsigned int hashval)
 static void
 nfsd_file_put_final(struct nfsd_file *nf)
 {
+	trace_nfsd_file_put_final(nf);
 	if (nf->nf_file)
 		fput(nf->nf_file);
 	kfree_rcu(nf, nf_rcu);
@@ -89,6 +92,7 @@ nfsd_file_put_final(struct nfsd_file *nf)
 static void
 nfsd_file_unhash(struct nfsd_file *nf)
 {
+	trace_nfsd_file_unhash(nf);
 	if (test_and_clear_bit(NFSD_FILE_HASHED, &nf->nf_flags)) {
 		hlist_del_rcu(&nf->nf_node);
 		nfsd_file_count_dec();
@@ -98,6 +102,7 @@ nfsd_file_unhash(struct nfsd_file *nf)
 static void
 nfsd_file_put_locked(struct nfsd_file *nf, struct list_head *dispose)
 {
+	trace_nfsd_file_put_locked(nf);
 	if (!atomic_dec_and_test(&nf->nf_ref)) {
 		nf->nf_time = jiffies;
 		return;
@@ -110,6 +115,7 @@ nfsd_file_put_locked(struct nfsd_file *nf, struct list_head *dispose)
 void
 nfsd_file_put(struct nfsd_file *nf)
 {
+	trace_nfsd_file_put(nf);
 	if (!atomic_dec_and_lock(&nf->nf_ref,
 				&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock)) {
 		nf->nf_time = jiffies;
@@ -284,8 +290,11 @@ retry:
 
 	if (!new) {
 		new = nfsd_file_alloc(&fhp->fh_handle, may_flags, hashval);
-		if (!new)
+		if (!new) {
+			trace_nfsd_file_acquire(hashval, fh, may_flags, NULL,
+						nfserr_jukebox);
 			return nfserr_jukebox;
+		}
 	}
 
 	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
@@ -364,13 +373,17 @@ wait_for_construction:
 		}
 	}
 out:
-	if (status == nfs_ok)
+	if (status == nfs_ok) {
 		*pnf = nf;
-	else
+	} else {
 		nfsd_file_put(nf);
+		nf = NULL;
+	}
 
 	if (new)
 		nfsd_file_put(new);
+
+	trace_nfsd_file_acquire(hashval, fh, may_flags, nf, status);
 	return status;
 open_file:
 	status = nfsd_open(rqstp, fhp, S_IFREG, may_flags, &nf->nf_file);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 0befe762762b..ff26d91f8106 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -10,6 +10,8 @@
 #include <linux/tracepoint.h>
 
 #include "state.h"
+#include "filecache.h"
+#include "vfs.h"
 
 DECLARE_EVENT_CLASS(nfsd_stateid_class,
 	TP_PROTO(stateid_t *stp),
@@ -48,6 +50,103 @@ DEFINE_STATEID_EVENT(layout_recall_done);
 DEFINE_STATEID_EVENT(layout_recall_fail);
 DEFINE_STATEID_EVENT(layout_recall_release);
 
+#define show_nf_flags(val)						\
+	__print_flags(val, "|",						\
+		{ 1 << NFSD_FILE_HASHED,	"HASHED" },		\
+		{ 1 << NFSD_FILE_PENDING,	"PENDING" },		\
+		{ 1 << NFSD_FILE_BREAK_READ,	"BREAK_READ" },		\
+		{ 1 << NFSD_FILE_BREAK_WRITE,	"BREAK_WRITE" })
+
+/* FIXME: This should probably be fleshed out in the future. */
+#define show_nf_may(val)						\
+	__print_flags(val, "|",						\
+		{ NFSD_MAY_READ,		"READ" },		\
+		{ NFSD_MAY_WRITE,		"WRITE" },		\
+		{ NFSD_MAY_NOT_BREAK_LEASE,	"NOT_BREAK_LEASE" })
+
+#define show_nf_fh(fh)					\
+	__print_hex((char *)&fh.fh_base, fh.fh_size)
+
+DECLARE_EVENT_CLASS(nfsd_file_class,
+	TP_PROTO(struct nfsd_file *nf),
+	TP_ARGS(nf),
+	TP_STRUCT__entry(
+		__field(unsigned int, nf_hashval)
+		__field_struct(struct knfsd_fh, nf_handle)
+		__field(int, nf_ref)
+		__field(unsigned long, nf_flags)
+		__field(unsigned char, nf_may)
+		__field(unsigned long, nf_time)
+		__field(struct file *, nf_file)
+	),
+	TP_fast_assign(
+		__entry->nf_hashval = nf->nf_hashval;
+		__entry->nf_handle = nf->nf_handle;
+		__entry->nf_ref = atomic_read(&nf->nf_ref);
+		__entry->nf_flags = nf->nf_flags;
+		__entry->nf_may = nf->nf_may;
+		__entry->nf_time = nf->nf_time;
+		__entry->nf_file = nf->nf_file;
+	),
+	TP_printk("hash=0x%x handle=%s ref=%d flags=%s may=%s time=%lu file=%p",
+		__entry->nf_hashval,
+		show_nf_fh(__entry->nf_handle),
+		__entry->nf_ref,
+		show_nf_flags(__entry->nf_flags),
+		show_nf_may(__entry->nf_may),
+		__entry->nf_time,
+		__entry->nf_file)
+)
+
+#define DEFINE_NFSD_FILE_EVENT(name) \
+DEFINE_EVENT(nfsd_file_class, name, \
+	TP_PROTO(struct nfsd_file *nf), \
+	TP_ARGS(nf))
+
+DEFINE_NFSD_FILE_EVENT(nfsd_file_alloc);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_put_final);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_unhash);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_put);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_put_locked);
+
+TRACE_EVENT(nfsd_file_acquire,
+	TP_PROTO(unsigned int hash, struct knfsd_fh *handle,
+		 unsigned int may_flags, struct nfsd_file *nf,
+		 __be32 status),
+
+	TP_ARGS(hash, handle, may_flags, nf, status),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, hash)
+		__field_struct(struct knfsd_fh, handle)
+		__field(unsigned int, may_flags)
+		__field(int, nf_ref)
+		__field(unsigned long, nf_flags)
+		__field(unsigned char, nf_may)
+		__field(unsigned long, nf_time)
+		__field(struct file *, nf_file)
+		__field(__be32, status)
+	),
+
+	TP_fast_assign(
+		__entry->hash = hash;
+		__entry->handle = *handle;
+		__entry->may_flags = may_flags;
+		__entry->nf_ref = nf ? atomic_read(&nf->nf_ref) : 0;
+		__entry->nf_flags = nf ? nf->nf_flags : 0;
+		__entry->nf_may = nf ? nf->nf_may : 0;
+		__entry->nf_time = nf ? nf->nf_time : 0;
+		__entry->nf_file = nf ? nf->nf_file : NULL;
+		__entry->status = status;
+	),
+
+	TP_printk("hash=0x%x handle=%s may_flags=%s ref=%d nf_flags=%s nf_may=%s nf_time=%lu nf_file=0x%p status=%u",
+			__entry->hash, show_nf_fh(__entry->handle),
+			show_nf_may(__entry->may_flags), __entry->nf_ref,
+			show_nf_flags(__entry->nf_flags),
+			show_nf_may(__entry->nf_may), __entry->nf_time,
+			__entry->nf_file, be32_to_cpu(__entry->status))
+);
 #endif /* _NFSD_TRACE_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
2.4.3

