From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 07/35] nfsd41: sessionid hashing
Date: Fri,  3 Apr 2009 08:27:52 +0300
Message-ID: <1238736472-17295-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:22891 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754165AbZDCF15 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:27:57 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
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
 fs/nfsd/nfs4state.c        |   55 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfsd/state.h |    7 +++++
 2 files changed, 61 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f23385b..fc20e1f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -382,11 +382,62 @@ static void release_openowner(struct nfs4_stateowner *sop)
 	nfs4_put_stateowner(sop);
 }
 
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
 
@@ -3205,6 +3256,8 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
 	}
+	for (i = 0; i < SESSION_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 7faefc7..5b3a666 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -132,6 +132,13 @@ nfsd4_get_session(struct nfsd4_session *ses)
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

