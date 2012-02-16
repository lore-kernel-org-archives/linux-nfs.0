Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52337 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab2BPS5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:57:13 -0500
Received: by eaah12 with SMTP id h12so993483eaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:57:12 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfsd41: split out share_access want and signel flags while decoding
Date: Thu, 16 Feb 2012 20:57:09 +0200
Message-Id: <1329418629-23888-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3D4F1F.6080502@tonian.com>
References: <4F3D4F1F.6080502@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4proc.c  |    3 ---
 fs/nfsd/nfs4state.c |    6 +++---
 fs/nfsd/nfs4xdr.c   |   19 +++++++++++++++----
 fs/nfsd/xdr4.h      |    6 ++++--
 4 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 896da74..a9040be 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -310,9 +310,6 @@ static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
-	/* We don't yet support WANT bits: */
-	open->op_share_access &= NFS4_SHARE_ACCESS_MASK;
-
 	open->op_created = 0;
 	/*
 	 * RFC5661 18.51.3
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a6cdbd5..c165df7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2633,8 +2633,6 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
 
 static int share_access_to_flags(u32 share_access)
 {
-	share_access &= NFS4_SHARE_ACCESS_MASK;
-
 	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
 }
 
@@ -3596,7 +3594,9 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 			cstate->current_fh.fh_dentry->d_name.name);
 
 	/* We don't yet support WANT bits: */
-	od->od_share_access &= NFS4_SHARE_ACCESS_MASK;
+	if (od->od_deleg_want)
+		dprintk("NFSD: %s: od_deleg_want=0x%x ignored\n", __func__,
+			od->od_deleg_want);
 
 	nfs4_lock_state();
 	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0ec5a1b..78d2bb8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -638,14 +638,18 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
 	DECODE_TAIL;
 }
 
-static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
+static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *share_access, u32 *deleg_want, u32 *deleg_when)
 {
 	__be32 *p;
 	u32 w;
 
 	READ_BUF(4);
 	READ32(w);
-	*x = w;
+	*share_access = w & NFS4_SHARE_ACCESS_MASK;
+	*deleg_want = w & NFS4_SHARE_WANT_MASK;
+	if (deleg_when)
+		*deleg_when = w & NFS4_SHARE_WHEN_MASK;
+
 	switch (w & NFS4_SHARE_ACCESS_MASK) {
 	case NFS4_SHARE_ACCESS_READ:
 	case NFS4_SHARE_ACCESS_WRITE:
@@ -673,6 +677,9 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
 	w &= ~NFS4_SHARE_WANT_MASK;
 	if (!w)
 		return nfs_ok;
+
+	if (!deleg_when)	/* open_downgrade */
+		return nfserr_inval;
 	switch (w) {
 	case NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL:
 	case NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED:
@@ -719,6 +726,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 {
 	DECODE_HEAD;
+	u32 dummy;
 
 	memset(open->op_bmval, 0, sizeof(open->op_bmval));
 	open->op_iattr.ia_valid = 0;
@@ -727,7 +735,9 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 	/* seqid, share_access, share_deny, clientid, ownerlen */
 	READ_BUF(4);
 	READ32(open->op_seqid);
-	status = nfsd4_decode_share_access(argp, &open->op_share_access);
+	/* decode, yet ignore deleg_when until supported */
+	status = nfsd4_decode_share_access(argp, &open->op_share_access,
+					   &open->op_deleg_want, &dummy);
 	if (status)
 		goto xdr_error;
 	status = nfsd4_decode_share_deny(argp, &open->op_share_deny);
@@ -848,7 +858,8 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 		return status;
 	READ_BUF(4);
 	READ32(open_down->od_seqid);
-	status = nfsd4_decode_share_access(argp, &open_down->od_share_access);
+	status = nfsd4_decode_share_access(argp, &open_down->od_share_access,
+					   &open_down->od_deleg_want, NULL);
 	if (status)
 		return status;
 	status = nfsd4_decode_share_deny(argp, &open_down->od_share_deny);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2364747..1771a91 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -222,6 +222,7 @@ struct nfsd4_open {
 	u32		op_seqid;           /* request */
 	u32		op_share_access;    /* request */
 	u32		op_share_deny;      /* request */
+	u32		op_deleg_want;      /* request */
 	stateid_t	op_stateid;         /* response */
 	u32		op_recall;          /* recall */
 	struct nfsd4_change_info  op_cinfo; /* response */
@@ -245,8 +246,9 @@ struct nfsd4_open_confirm {
 struct nfsd4_open_downgrade {
 	stateid_t       od_stateid;
 	u32             od_seqid;
-	u32             od_share_access;
-	u32             od_share_deny;
+	u32             od_share_access;	/* request */
+	u32		od_deleg_want;		/* request */
+	u32             od_share_deny;		/* request */
 };
 
 
-- 
1.7.6.5

