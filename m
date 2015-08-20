Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:35952 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbbHTLRj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:39 -0400
Received: by ykfw73 with SMTP id w73so33706710ykf.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:39 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 13/20] nfsd: add new tracepoints for nfsd_file cache
Date: Thu, 20 Aug 2015 07:17:13 -0400
Message-Id: <1440069440-27454-14-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 20 +++++++++---
 fs/nfsd/trace.h     | 91 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 10aa698b6057..e48b536762aa 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -15,6 +15,7 @@
 #include "nfsd.h"
 #include "nfsfh.h"
 #include "filecache.h"
+#include "trace.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_FH
 
@@ -53,6 +54,7 @@ nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval)
 			if (may & NFSD_MAY_READ)
 				__set_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
 		}
+		trace_nfsd_file_alloc(nf);
 	}
 	return nf;
 }
@@ -60,6 +62,7 @@ nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval)
 static void
 nfsd_file_put_final(struct nfsd_file *nf)
 {
+	trace_nfsd_file_put_final(nf);
 	if (nf->nf_file)
 		fput(nf->nf_file);
 	kfree_rcu(nf, nf_rcu);
@@ -70,6 +73,7 @@ nfsd_file_unhash(struct nfsd_file *nf)
 {
 	lockdep_assert_held(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
 
+	trace_nfsd_file_unhash(nf);
 	if (test_bit(NFSD_FILE_HASHED, &nf->nf_flags)) {
 		clear_bit(NFSD_FILE_HASHED, &nf->nf_flags);
 		hlist_del_rcu(&nf->nf_node);
@@ -84,6 +88,7 @@ nfsd_file_unhash_and_release_locked(struct nfsd_file *nf, struct list_head *disp
 {
 	lockdep_assert_held(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
 
+	trace_nfsd_file_unhash_and_release_locked(nf);
 	if (!nfsd_file_unhash(nf))
 		return;
 	if (!atomic_dec_and_test(&nf->nf_ref))
@@ -95,8 +100,8 @@ nfsd_file_unhash_and_release_locked(struct nfsd_file *nf, struct list_head *disp
 void
 nfsd_file_put(struct nfsd_file *nf)
 {
+	trace_nfsd_file_put(nf);
 	list_lru_rotate(&nfsd_file_lru, &nf->nf_lru);
-
 	if (!atomic_dec_and_test(&nf->nf_ref))
 		return;
 
@@ -303,8 +308,11 @@ retry:
 
 	if (!new) {
 		new = nfsd_file_alloc(inode, may_flags, hashval);
-		if (!new)
+		if (!new) {
+			trace_nfsd_file_acquire(hashval, inode, may_flags, NULL,
+						nfserr_jukebox);
 			return nfserr_jukebox;
+		}
 	}
 
 	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
@@ -381,13 +389,17 @@ wait_for_construction:
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
+	trace_nfsd_file_acquire(hashval, inode, may_flags, nf, status);
 	return status;
 open_file:
 	status = nfsd_open(rqstp, fhp, S_IFREG, may_flags, &nf->nf_file);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 0befe762762b..2dac872d31e8 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -10,6 +10,8 @@
 #include <linux/tracepoint.h>
 
 #include "state.h"
+#include "filecache.h"
+#include "vfs.h"
 
 DECLARE_EVENT_CLASS(nfsd_stateid_class,
 	TP_PROTO(stateid_t *stp),
@@ -48,6 +50,95 @@ DEFINE_STATEID_EVENT(layout_recall_done);
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
+DECLARE_EVENT_CLASS(nfsd_file_class,
+	TP_PROTO(struct nfsd_file *nf),
+	TP_ARGS(nf),
+	TP_STRUCT__entry(
+		__field(unsigned int, nf_hashval)
+		__field(void *, nf_inode)
+		__field(int, nf_ref)
+		__field(unsigned long, nf_flags)
+		__field(unsigned char, nf_may)
+		__field(struct file *, nf_file)
+	),
+	TP_fast_assign(
+		__entry->nf_hashval = nf->nf_hashval;
+		__entry->nf_inode = nf->nf_inode;
+		__entry->nf_ref = atomic_read(&nf->nf_ref);
+		__entry->nf_flags = nf->nf_flags;
+		__entry->nf_may = nf->nf_may;
+		__entry->nf_file = nf->nf_file;
+	),
+	TP_printk("hash=0x%x inode=0x%p ref=%d flags=%s may=%s file=%p",
+		__entry->nf_hashval,
+		__entry->nf_inode,
+		__entry->nf_ref,
+		show_nf_flags(__entry->nf_flags),
+		show_nf_may(__entry->nf_may),
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
+DEFINE_NFSD_FILE_EVENT(nfsd_file_unhash_and_release_locked);
+
+TRACE_EVENT(nfsd_file_acquire,
+	TP_PROTO(unsigned int hash, struct inode *inode,
+		 unsigned int may_flags, struct nfsd_file *nf,
+		 __be32 status),
+
+	TP_ARGS(hash, inode, may_flags, nf, status),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, hash)
+		__field(void *, inode)
+		__field(unsigned int, may_flags)
+		__field(int, nf_ref)
+		__field(unsigned long, nf_flags)
+		__field(unsigned char, nf_may)
+		__field(struct file *, nf_file)
+		__field(__be32, status)
+	),
+
+	TP_fast_assign(
+		__entry->hash = hash;
+		__entry->inode = inode;
+		__entry->may_flags = may_flags;
+		__entry->nf_ref = nf ? atomic_read(&nf->nf_ref) : 0;
+		__entry->nf_flags = nf ? nf->nf_flags : 0;
+		__entry->nf_may = nf ? nf->nf_may : 0;
+		__entry->nf_file = nf ? nf->nf_file : NULL;
+		__entry->status = status;
+	),
+
+	TP_printk("hash=0x%x inode=0x%p may_flags=%s ref=%d nf_flags=%s nf_may=%s nf_file=0x%p status=%u",
+			__entry->hash, __entry->inode,
+			show_nf_may(__entry->may_flags), __entry->nf_ref,
+			show_nf_flags(__entry->nf_flags),
+			show_nf_may(__entry->nf_may), __entry->nf_file,
+			be32_to_cpu(__entry->status))
+);
 #endif /* _NFSD_TRACE_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
2.4.3

