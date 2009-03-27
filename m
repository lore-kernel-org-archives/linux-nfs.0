From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 12/47] nfsd41: sessionid hashing
Date: Fri, 27 Mar 2009 06:08:24 +0300
Message-ID: <1238123304-7276-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Marc Eshel <eshel@almaden.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23435 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755173AbZC0DI3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:08:29 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Simple sessionid hashing using its monotonically increasing sequence number.

Locking considerations:
sessionid_hashtbl access is controlled by the sessionid_lock spin lock.
It must be taken for insert, delete, and lookup.
nfsd4_sequence looks up the session id and if the session is found,
it calls nfsd4_get_session (still under the sessionid_lock).
nfsd4_destroy_session calls nfsd4_put_session after unhashing
it, so when the session's kref reaches zero it's going to get freed.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[we don't use a prime for sessionid hash table size]
[use sessionid_lock spin lock]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   57 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfsd/state.h |    7 +++++
 2 files changed, 63 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index df9d42e..ac4e8f2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -383,11 +383,62 @@ static void release_openowner(struct nfs4_stateowner *sop)
 }
 
 #if defined(CONFIG_NFSD_V4_1)
+static DEFINE_SPINLOCK(sessionid_lock);
+#define SESSION_HASH_SIZE	512
+static struct list_head sessionid_hashtbl[SESSION_HASH_SIZE];
+
+static inline int
+hash_sessionid(struct nfs4_sessionid *sessionid)
+{
+	struct nfsd4_sessionid *sid = (struct nfsd4_sessionid *)sessionid;
+
+	return sid->sequence % SESSION_HASH_SIZE;
+}
+
+static inline void
+dump_sessionid(const char *fn, struct nfs4_sessionid *sessionid)
+{
+	u32 *ptr = (u32 *)(&sessionid->data[0]);
+	dprintk("%s: %u:%u:%u:%u\n", fn, ptr[0], ptr[1], ptr[2], ptr[3]);
+}
+
+/* caller must hold sessionid_lock */
+static struct nfsd4_session *
+find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid)
+{
+	struct nfsd4_session *elem;
+	int idx;
+
+	dump_sessionid(__func__, sessionid);
+	idx = hash_sessionid(sessionid);
+	dprintk("%s: idx is %d\n", __func__, idx);
+	/* Search in the appropriate list */
+	list_for_each_entry(elem, &sessionid_hashtbl[idx], se_hash) {
+		dump_sessionid("list traversal", &elem->se_sessionid);
+		if (!memcmp(elem->se_sessionid.data, sessionid->data,
+			    NFS4_MAX_SESSIONID_LEN)) {
+			return elem;
+		}
+	}
+
+	dprintk("%s: session not found\n", __func__);
+	return NULL;
+}
+
+/* caller must hold sessionid_lock */
 static void
-release_session(struct nfsd4_session *ses)
+unhash_session(struct nfsd4_session *ses)
 {
 	list_del(&ses->se_hash);
 	list_del(&ses->se_perclnt);
+}
+
+static void
+release_session(struct nfsd4_session *ses)
+{
+	spin_lock(&sessionid_lock);
+	unhash_session(ses);
+	spin_unlock(&sessionid_lock);
 	nfsd4_put_session(ses);
 }
 
@@ -3213,6 +3264,10 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
 	}
+#if defined(CONFIG_NFSD_V4_1)
+	for (i = 0; i < SESSION_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
+#endif /* CONFIG_NFSD_V4_1 */
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 29624b4..7592d7b 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -133,6 +133,13 @@ nfsd4_get_session(struct nfsd4_session *ses)
 	kref_get(&ses->se_ref);
 }
 
+/* formatted contents of nfs4_sessionid */
+struct nfsd4_sessionid {
+	clientid_t	clientid;
+	u32		sequence;
+	u32		reserved;
+};
+
 #define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
 
 /*
-- 
1.6.2.1

