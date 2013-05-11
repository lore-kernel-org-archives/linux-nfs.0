Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f178.google.com ([74.125.82.178]:42685 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab3EKCnQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:16 -0400
Received: by mail-we0-f178.google.com with SMTP id q57so4791228wes.9
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:15 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id ff10sm1320924wib.10.2013.05.10.19.43.14
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:14 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/38] Revert "pnfsd: ds state"
Date: Sat, 11 May 2013 05:43:10 +0300
Message-Id: <1368240190-32149-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 5aba2b7eeb8d96f2647ed54a98bf5ac2e71e916f.

Conflicts:
	fs/nfsd/Makefile
	fs/nfsd/nfs4pnfsd.c
	fs/nfsd/pnfsd.h
	fs/nfsd/state.h
	include/linux/nfsd/nfsd4_pnfs.h
---
 fs/nfsd/Makefile                |  2 +-
 fs/nfsd/export.c                |  3 --
 fs/nfsd/nfs4pnfsd.c             | 69 -----------------------------------------
 fs/nfsd/nfs4state.c             | 10 ------
 fs/nfsd/pnfsd.h                 | 45 ---------------------------
 fs/nfsd/state.h                 | 15 ---------
 include/linux/nfs4.h            |  1 -
 include/linux/nfsd/nfsd4_pnfs.h | 17 ----------
 include/uapi/linux/nfs4.h       |  1 -
 9 files changed, 1 insertion(+), 162 deletions(-)

diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 06f8732..5488e7e 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -12,5 +12,5 @@ nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
-nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o nfs4pnfsdlm.o nfs4pnfsds.o
+nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o nfs4pnfsdlm.o
 nfsd-$(CONFIG_PNFSD_LOCAL_EXPORT) += pnfsd_lexp.o
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 698ca5c..5abe7d3 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -346,9 +346,6 @@ static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
 #if defined(CONFIG_PNFSD)
 static struct pnfsd_cb_operations pnfsd_cb_op = {
 	.cb_layout_recall = nfsd_layout_recall_cb,
-
-	.cb_get_state = nfs4_pnfs_cb_get_state,
-	.cb_change_state = nfs4_pnfs_cb_change_state,
 };
 #endif /* CONFIG_PNFSD */
 
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 85d0733..2be124a 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -505,37 +505,6 @@ struct super_block *
 }
 
 /*
- * get_state() and cb_get_state() are
- */
-void
-release_pnfs_ds_dev_list(struct nfs4_ol_stateid *stp)
-{
-	struct pnfs_ds_dev_entry *ddp;
-
-	while (!list_empty(&stp->st_pnfs_ds_id)) {
-		ddp = list_entry(stp->st_pnfs_ds_id.next,
-				 struct pnfs_ds_dev_entry, dd_dev_entry);
-		list_del(&ddp->dd_dev_entry);
-		kfree(ddp);
-	}
-}
-
-static int
-nfs4_add_pnfs_ds_dev(struct nfs4_ol_stateid *stp, u32 dsid)
-{
-	struct pnfs_ds_dev_entry *ddp;
-
-	ddp = kmalloc(sizeof(*ddp), GFP_KERNEL);
-	if (!ddp)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&ddp->dd_dev_entry);
-	list_add(&ddp->dd_dev_entry, &stp->st_pnfs_ds_id);
-	ddp->dd_dsid = dsid;
-	return 0;
-}
-
-/*
  * are two octet ranges overlapping?
  * start1            last1
  *   |-----------------|
@@ -1124,44 +1093,6 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	return status;
 }
 
-/*
- * PNFS Metadata server export operations callback for get_state
- *
- * called by the cluster fs when it receives a get_state() from a data
- * server.
- * returns status, or pnfs_get_state* with pnfs_get_state->status set.
- *
- */
-int
-nfs4_pnfs_cb_get_state(struct super_block *sb, struct pnfs_get_state *arg)
-{
-	struct nfs4_stid *stid;
-	struct nfs4_ol_stateid *stp;
-	int status = -EINVAL;
-	stateid_t *stateid = (stateid_t *)&arg->stid;
-
-	dprintk("NFSD: %s sid=" STATEID_FMT " ino %llu\n", __func__,
-		STATEID_VAL(stateid), arg->ino);
-
-	nfs4_lock_state();
-	status = nfsd4_lookup_stateid(stateid, NFS4_OPEN_STID|NFS4_LOCK_STID,
-	                              &stid, true);
-	if (!status) {
-		stp = container_of(stid, struct nfs4_ol_stateid, st_stid);
-		/* arg->dsid is the Data server id, set by the cluster fs */
-		status = nfs4_add_pnfs_ds_dev(stp, arg->dsid);
-		if (status)
-			goto out;
-
-		arg->access = stp->st_access_bmap;
-		*(clientid_t *)&arg->clid =
-			stp->st_stateowner->so_client->cl_clientid;
-	}
-out:
-	nfs4_unlock_state();
-	return status;
-}
-
 static bool
 cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp,
 		   stateid_t *lsid, struct nfsd4_pnfs_cb_layout *cbl)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 664c7cb..0871146 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -531,7 +531,6 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perstateowner);
-	release_pnfs_ds_dev_list(stp);
 }
 
 static void close_generic_stateid(struct nfs4_ol_stateid *stp)
@@ -2519,9 +2518,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 
 	nfsd4_init_stid(&stp->st_stid, clp, NFS4_OPEN_STID);
 	INIT_LIST_HEAD(&stp->st_lockowners);
-#if defined(CONFIG_PNFSD)
-	INIT_LIST_HEAD(&stp->st_pnfs_ds_id);
-#endif /* CONFIG_PNFSD */
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = &oo->oo_owner;
@@ -4108,9 +4104,6 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 	if (stp == NULL)
 		return NULL;
 	nfsd4_init_stid(&stp->st_stid, clp, NFS4_LOCK_STID);
-#if defined(CONFIG_PNFSD)
-	INIT_LIST_HEAD(&stp->st_pnfs_ds_id);
-#endif /* CONFIG_PNFSD */
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
@@ -4872,9 +4865,6 @@ struct nfs4_client *nfsd_find_client(struct sockaddr_storage *addr, size_t addr_
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
 	INIT_LIST_HEAD(&del_recall_lru);
-#if defined(CONFIG_PNFSD)
-	nfs4_pnfs_state_init();
-#endif /* CONFIG_PNFSD */
 }
 
 /*
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 6178c17..2405d47 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -58,51 +58,6 @@ struct nfs4_layout {
 	struct nfsd4_layout_seg		lo_seg;
 };
 
-struct pnfs_inval_state {
-	struct knfsd_fh		mdsfh; /* needed only by invalidate all */
-	stateid_t		stid;
-	clientid_t		clid;
-	u32			status;
-};
-
-/* pNFS Data Server state */
-#define DS_STATEID_VALID   0
-#define DS_STATEID_ERROR   1
-#define DS_STATEID_NEW     2
-
-struct pnfs_ds_stateid {
-	struct list_head	ds_hash;        /* ds_stateid hash entry */
-	struct list_head	ds_perclid;     /* per client hash entry */
-	stateid_t		ds_stid;
-	struct knfsd_fh		ds_fh;
-	unsigned long		ds_access;
-	u32			ds_status;      /* from MDS */
-	u32			ds_verifier[2]; /* from MDS */
-	wait_queue_head_t	ds_waitq;
-	unsigned long		ds_flags;
-	struct kref		ds_ref;
-	clientid_t		ds_mdsclid;
-};
-
-struct pnfs_ds_clientid {
-	struct list_head	dc_hash;        /* mds_clid_hashtbl entry */
-	struct list_head	dc_stateid;     /* ds_stateid head */
-	struct list_head	dc_permdsid;    /* per mdsid hash entry */
-	clientid_t		dc_mdsclid;
-	struct kref		dc_ref;
-	uint32_t		dc_mdsid;
-};
-
-struct pnfs_mds_id {
-	struct list_head	di_hash;        /* mds_nodeid list entry */
-	struct list_head	di_mdsclid;     /* mds_clientid head */
-	uint32_t		di_mdsid;
-	time_t			di_mdsboot;	/* mds boot time */
-	struct kref		di_ref;
-};
-
-int nfs4_pnfs_cb_get_state(struct super_block *, struct pnfs_get_state *);
-int nfs4_pnfs_cb_change_state(struct pnfs_get_state *);
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
 __be32 nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 774927c..fac8550 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -446,24 +446,12 @@ static inline struct file *find_any_file(struct nfs4_file *f)
 		return f->fi_fds[O_RDONLY];
 }
 
-#if defined(CONFIG_PNFSD)
-/* pNFS Metadata server state */
-
-struct pnfs_ds_dev_entry {
-	struct list_head	dd_dev_entry; /* st_pnfs_ds_id entry */
-	u32			dd_dsid;
-};
-#endif /* CONFIG_PNFSD */
-
 /* "ol" stands for "Open or Lock".  Better suggestions welcome. */
 struct nfs4_ol_stateid {
 	struct nfs4_stid    st_stid; /* must be first field */
 	struct list_head              st_perfile;
 	struct list_head              st_perstateowner;
 	struct list_head              st_lockowners;
-#if defined(CONFIG_PNFSD)
-	struct list_head              st_pnfs_ds_id;
-#endif /* CONFIG_PNFSD */
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
 	unsigned long                 st_access_bmap;
@@ -528,14 +516,11 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern int nfsd4_init_pnfs_slabs(void);
 extern void nfsd4_free_pnfs_slabs(void);
 extern void pnfs_expire_client(struct nfs4_client *);
-extern void release_pnfs_ds_dev_list(struct nfs4_ol_stateid *);
-extern void nfs4_pnfs_state_init(void);
 extern void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
 #else /* CONFIG_PNFSD */
 static inline void nfsd4_free_pnfs_slabs(void) {}
 static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
 static inline void pnfs_expire_client(struct nfs4_client *clp) {}
-static inline void release_pnfs_ds_dev_list(struct nfs4_ol_stateid *stp) {}
 static inline void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp) {}
 #endif /* CONFIG_PNFSD */
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 59cc833..f6315ce 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -34,7 +34,6 @@ struct nfs4_fsid {
 };
 
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
-typedef struct { char data[NFS4_CLIENTID_SIZE]; } nfs4_clientid;
 
 struct nfs_stateid4 {
 	__be32 seqid;
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 0aab899..d86e1b7 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -127,17 +127,6 @@ struct nfsd4_pnfs_layoutreturn_arg {
 	enum layoutreturn_flags	lr_flags;	/* internal flags */
 };
 
-/* pNFS Metadata to Data server state communication */
-struct pnfs_get_state {
-	u32			dsid;		/* request */
-	u64			ino;		/* request */
-	nfs4_stateid		stid;		/* request;response */
-	nfs4_clientid		clid;		/* response */
-	u32			access;		/* response */
-	u32			stid_gen;	/* response */
-	u32			verifier[2];	/* response */
-};
-
 /*
  * pNFS export operations vector.
  *
@@ -219,12 +208,6 @@ struct pnfs_export_operations {
 
 	/* Can layout segments be merged for this layout type? */
 	int (*can_merge_layouts) (u32 layout_type);
-
-	/* pNFS Files layout specific operations */
-
-	/* Call fs on DS only */
-	int (*get_state) (struct inode *, struct knfsd_fh *,
-			  struct pnfs_get_state *);
 };
 
 struct nfsd4_pnfs_cb_layout {
diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index d81912a..028f5fc 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -17,7 +17,6 @@
 
 #define NFS4_BITMAP_SIZE	2
 #define NFS4_VERIFIER_SIZE	8
-#define NFS4_CLIENTID_SIZE	8
 #define NFS4_STATEID_SEQID_SIZE 4
 #define NFS4_STATEID_OTHER_SIZE 12
 #define NFS4_STATEID_SIZE	(NFS4_STATEID_SEQID_SIZE + NFS4_STATEID_OTHER_SIZE)
-- 
1.7.11.7

