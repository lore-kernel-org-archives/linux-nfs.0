From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 39/69] NFSv4: Convert delegation->type field to fmode_t
Date: Tue, 23 Dec 2008 18:02:17 -0500
Message-ID: <20081223230216.13743.78476.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276AbYLWXXr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:47 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsk006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c     |    2 +-
 fs/nfs/delegation.h     |    6 +++---
 fs/nfs/nfs4xdr.c        |    4 ++--
 include/linux/nfs_fs.h  |    2 +-
 include/linux/nfs_xdr.h |    4 ++--
 5 files changed, 9 insertions(+), 9 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index e75f2f8..968225a 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -48,7 +48,7 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
 	set_bit(NFS_DELEGATION_REFERENCED, &delegation->flags);
 }
 
-int nfs_have_delegation(struct inode *inode, int flags)
+int nfs_have_delegation(struct inode *inode, fmode_t flags)
 {
 	struct nfs_delegation *delegation;
 	int ret = 0;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 2a74882..09f3837 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -17,7 +17,7 @@ struct nfs_delegation {
 	struct rpc_cred *cred;
 	struct inode *inode;
 	nfs4_stateid stateid;
-	int type;
+	fmode_t type;
 	loff_t maxsize;
 	__u64 change_attr;
 	unsigned long flags;
@@ -54,10 +54,10 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
 int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
-int nfs_have_delegation(struct inode *inode, int flags);
+int nfs_have_delegation(struct inode *inode, fmode_t flags);
 
 #else
-static inline int nfs_have_delegation(struct inode *inode, int flags)
+static inline int nfs_have_delegation(struct inode *inode, fmode_t flags)
 {
 	return 0;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b916297..879911c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1024,7 +1024,7 @@ static void encode_opentype(struct xdr_stream *xdr, const struct nfs_openargs *a
 	}
 }
 
-static inline void encode_delegation_type(struct xdr_stream *xdr, int delegation_type)
+static inline void encode_delegation_type(struct xdr_stream *xdr, fmode_t delegation_type)
 {
 	__be32 *p;
 
@@ -1053,7 +1053,7 @@ static inline void encode_claim_null(struct xdr_stream *xdr, const struct qstr *
 	encode_string(xdr, name->len, name->name);
 }
 
-static inline void encode_claim_previous(struct xdr_stream *xdr, int type)
+static inline void encode_claim_previous(struct xdr_stream *xdr, fmode_t type)
 {
 	__be32 *p;
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f110772..8d71d7b 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -180,7 +180,7 @@ struct nfs_inode {
         /* NFSv4 state */
 	struct list_head	open_states;
 	struct nfs_delegation	*delegation;
-	int			 delegation_state;
+	fmode_t			 delegation_state;
 	struct rw_semaphore	rwsem;
 #endif /* CONFIG_NFS_V4*/
 	struct inode		vfs_inode;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c1c31ac..32c1a0e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -126,7 +126,7 @@ struct nfs_openargs {
 		struct iattr *  attrs;    /* UNCHECKED, GUARDED */
 		nfs4_verifier   verifier; /* EXCLUSIVE */
 		nfs4_stateid	delegation;		/* CLAIM_DELEGATE_CUR */
-		int		delegation_type;	/* CLAIM_PREVIOUS */
+		fmode_t		delegation_type;	/* CLAIM_PREVIOUS */
 	} u;
 	const struct qstr *	name;
 	const struct nfs_server *server;	 /* Needed for ID mapping */
@@ -143,7 +143,7 @@ struct nfs_openres {
 	struct nfs_fattr *      dir_attr;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
-	int			delegation_type;
+	fmode_t			delegation_type;
 	nfs4_stateid		delegation;
 	__u32			do_recall;
 	__u64			maxsize;

