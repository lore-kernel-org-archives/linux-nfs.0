Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:25116 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752472AbdI1RaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:19 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 7/8] NFSD: allow inter server COPY to have a STALE source server fh
Date: Thu, 28 Sep 2017 13:30:01 -0400
Message-ID: <20170928173002.50818-8-kolga@netapp.com>
In-Reply-To: <20170928173002.50818-1-kolga@netapp.com>
References: <20170928173002.50818-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The inter server to server COPY source server filehandle
is a foreign filehandle as the COPY is sent to the destination
server.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/Kconfig    | 10 ++++++++++
 fs/nfsd/nfs4proc.c | 45 ++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsfh.h    |  5 ++++-
 fs/nfsd/xdr4.h     |  1 +
 4 files changed, 57 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 20b1c17..37ff3d5 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -131,6 +131,16 @@ config NFSD_FLEXFILELAYOUT
 
 	  If unsure, say N.
 
+config NFSD_V4_2_INTER_SSC
+	bool "NFSv4.2 inter server to server COPY"
+	depends on NFSD_V4 && NFS_V4_1 && NFS_V4_2
+	help
+	  This option enables support for NFSv4.2 inter server to
+	  server copy where the destination server calls the NFSv4.2
+	  client to read the data to copy from the source server.
+
+	  If unsure, say N.
+
 config NFSD_V4_SECURITY_LABEL
 	bool "Provide Security Label support for NFSv4 server"
 	depends on NFSD_V4 && SECURITY
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a0536a6..18d1de4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -516,12 +516,21 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
 	    union nfsd4_op_u *u)
 {
 	struct nfsd4_putfh *putfh = &u->putfh;
+	__be32 ret;
 
 	fh_put(&cstate->current_fh);
 	cstate->current_fh.fh_handle.fh_size = putfh->pf_fhlen;
 	memcpy(&cstate->current_fh.fh_handle.fh_base, putfh->pf_fhval,
 	       putfh->pf_fhlen);
-	return fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
+	ret = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
+#ifdef CONFIG_NFSD_V4_2_INTER_SSC
+	if (ret == nfserr_stale && HAS_CSTATE_FLAG(cstate, NO_VERIFY_FH)) {
+		CLEAR_CSTATE_FLAG(cstate, NO_VERIFY_FH);
+		SET_FH_FLAG(&cstate->current_fh, NFSD4_FH_FOREIGN);
+		ret = 0;
+	}
+#endif
+	return ret;
 }
 
 static __be32
@@ -1903,6 +1912,26 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 		- rqstp->rq_auth_slack;
 }
 
+#ifdef CONFIG_NFSD_V4_2_INTER_SSC
+static bool _compound_contains_inter_copy(struct nfsd4_op *ops, int start,
+					  int end)
+{
+	bool found = false;
+	struct nfsd4_copy *copy;
+	int i;
+
+	for (i = start; i < end; i++) {
+		if (ops[i].opnum == OP_COPY) {
+			copy = (struct nfsd4_copy *)&ops[i].u;
+			if (copy->cp_src)
+				found = true;
+			break;
+		}
+	}
+	return found;
+}
+#endif
+
 /*
  * COMPOUND call.
  */
@@ -1950,6 +1979,14 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
 
+#ifdef CONFIG_NFSD_V4_2_INTER_SSC
+		if (op->opnum == OP_PUTFH &&
+			args->ops[resp->opcnt].opnum == OP_SAVEFH &&
+			args->ops[resp->opcnt+1].opnum == OP_PUTFH &&
+			_compound_contains_inter_copy(args->ops, resp->opcnt+2,
+						      args->opcnt))
+			SET_CSTATE_FLAG(cstate, NO_VERIFY_FH);
+#endif
 		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
 			resp->opcnt, args->opcnt, op->opnum,
 			nfsd4_op_name(op->opnum));
@@ -1964,12 +2001,14 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 			goto encode_op;
 		}
 
-		if (!current_fh->fh_dentry) {
+		if (!current_fh->fh_dentry &&
+				!HAS_FH_FLAG(current_fh, NFSD4_FH_FOREIGN)) {
 			if (!(op->opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
 				op->status = nfserr_nofilehandle;
 				goto encode_op;
 			}
-		} else if (current_fh->fh_export->ex_fslocs.migrated &&
+		} else if (current_fh->fh_export &&
+			   current_fh->fh_export->ex_fslocs.migrated &&
 			  !(op->opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
 			op->status = nfserr_moved;
 			goto encode_op;
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index e47cf6c..eeff20b 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -33,7 +33,7 @@ static inline ino_t u32_to_ino_t(__u32 uino)
 
 	bool			fh_locked;	/* inode locked by us */
 	bool			fh_want_write;	/* remount protection taken */
-
+	int			fh_flags;	/* FH flags */
 #ifdef CONFIG_NFSD_V3
 	bool			fh_post_saved;	/* post-op attrs saved */
 	bool			fh_pre_saved;	/* pre-op attrs saved */
@@ -54,6 +54,9 @@ static inline ino_t u32_to_ino_t(__u32 uino)
 #endif /* CONFIG_NFSD_V3 */
 
 } svc_fh;
+#define NFSD4_FH_FOREIGN (1<<0)
+#define SET_FH_FLAG(c, f) ((c)->fh_flags |= (f))
+#define HAS_FH_FLAG(c, f) ((c)->fh_flags & (f))
 
 enum nfsd_fsid {
 	FSID_DEV = 0,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index c979235..82d714b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -45,6 +45,7 @@
 
 #define CURRENT_STATE_ID_FLAG (1<<0)
 #define SAVED_STATE_ID_FLAG (1<<1)
+#define NO_VERIFY_FH (1<<2)
 
 #define SET_CSTATE_FLAG(c, f) ((c)->sid_flags |= (f))
 #define HAS_CSTATE_FLAG(c, f) ((c)->sid_flags & (f))
-- 
1.8.3.1

