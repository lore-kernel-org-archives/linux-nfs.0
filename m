Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37693 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab3EKCnN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:13 -0400
Received: by mail-wi0-f169.google.com with SMTP id h11so1325714wiv.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:12 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id h8sm1330007wiz.9.2013.05.10.19.43.10
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:11 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/38] Revert "pnfsd: Use ds_state_lock to protect retrieving verifier."
Date: Sat, 11 May 2013 05:43:06 +0300
Message-Id: <1368240186-32111-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 8ee9cf66f92878c5add818cdeb6b8a9937056f85.

Conflicts:
	fs/nfsd/pnfsd.h
---
 fs/nfsd/nfs4proc.c              | 16 +++-------------
 fs/nfsd/nfs4xdr.c               |  6 ------
 fs/nfsd/pnfsd.h                 |  5 ++---
 include/linux/nfsd/nfsd4_pnfs.h |  2 --
 4 files changed, 5 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2f1786a..c9befff 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -499,19 +499,11 @@ static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
 			   &access->ac_supported);
 }
 
-static void nfsd4_get_verifier(struct super_block *sb, nfs4_verifier *verifier, struct net *nn)
+static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
 {
 	__be32 verf[2];
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-#if defined(CONFIG_PNFSD)
-	if (sb->s_pnfs_op && sb->s_pnfs_op->get_verifier) {
-		nfs4_ds_get_verifier(NULL, sb,
-				     (u32 *)verifier->data);
-		return;
-	}
-#endif /* CONFIG_PNFSD */
-
 	verf[0] = (__be32)nn->nfssvc_boot.tv_sec;
 	verf[1] = (__be32)nn->nfssvc_boot.tv_usec;
 	memcpy(verifier->data, verf, sizeof(verifier->data));
@@ -521,8 +513,7 @@ static void nfsd4_get_verifier(struct super_block *sb, nfs4_verifier *verifier,
 nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_commit *commit)
 {
-	nfsd4_get_verifier(cstate->current_fh.fh_dentry->d_inode->i_sb,
-			   &commit->co_verf, SVC_NET(rqstp));
+	gen_boot_verifier(&commit->co_verf, SVC_NET(rqstp));
 	return nfsd_commit(rqstp, &cstate->current_fh, commit->co_offset,
 			     commit->co_count);
 }
@@ -953,8 +944,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 
 	cnt = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
-	nfsd4_get_verifier(cstate->current_fh.fh_dentry->d_inode->i_sb,
-			   &write->wr_verifier, SVC_NET(rqstp));
+	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
 
 	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
 	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 33f4c3e..a552202 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2843,9 +2843,6 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	if (!nfserr) {
 		RESERVE_SPACE(NFS4_VERIFIER_SIZE);
 		WRITEMEM(commit->co_verf.data, NFS4_VERIFIER_SIZE);
-		dprintk("NFSD: nfsd4_encode_commit: verifier %x:%x\n",
-			((u32 *)(&commit->co_verf.data))[0],
-			((u32 *)(&commit->co_verf.data))[1]);
 		ADJUST_ARGS();
 	}
 	return nfserr;
@@ -3439,9 +3436,6 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		WRITE32(write->wr_bytes_written);
 		WRITE32(write->wr_how_written);
 		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
-		dprintk("NFSD: nfsd4_encode_write: verifier %x:%x\n",
-			((u32 *)(&write->wr_verifier.data))[0],
-			((u32 *)(&write->wr_verifier.data))[1]);
 		ADJUST_ARGS();
 	}
 	return nfserr;
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 458e095..6178c17 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -101,14 +101,13 @@ struct pnfs_mds_id {
 	struct kref		di_ref;
 };
 
+int nfs4_pnfs_cb_get_state(struct super_block *, struct pnfs_get_state *);
+int nfs4_pnfs_cb_change_state(struct pnfs_get_state *);
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
 __be32 nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
 int nfs4_pnfs_return_layout(struct super_block *, struct svc_fh *,
 					struct nfsd4_pnfs_layoutreturn *);
-int nfs4_pnfs_cb_get_state(struct super_block *, struct pnfs_get_state *);
-int nfs4_pnfs_cb_change_state(struct pnfs_get_state *);
-void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
 int put_layoutrecall(struct nfs4_layoutrecall *);
 void nomatching_layout(struct nfs4_layoutrecall *);
 void *layoutrecall_done(struct nfs4_layoutrecall *);
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 1e6ef66..0aab899 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -222,8 +222,6 @@ struct pnfs_export_operations {
 
 	/* pNFS Files layout specific operations */
 
-	/* Get the write verifier for DS (called on MDS only) */
-	void (*get_verifier) (struct super_block *, u32 *p);
 	/* Call fs on DS only */
 	int (*get_state) (struct inode *, struct knfsd_fh *,
 			  struct pnfs_get_state *);
-- 
1.7.11.7

