Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:33448 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab1JTS70 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 14:59:26 -0400
Received: by vcge1 with SMTP id e1so2729014vcg.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Oct 2011 11:59:25 -0700 (PDT)
Message-ID: <4EA06F89.8090207@tonian.com>
Date: Thu, 20 Oct 2011 11:59:21 -0700
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfsd4: share_access_to_flags should consider only
 nfs4.x share_access flags
References: <4E9F82FC.2000904@tonian.com> <1319076817-13550-1-git-send-email-benny@tonian.com> <20111020115629.GJ5444@fieldses.org>
In-Reply-To: <20111020115629.GJ5444@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-20 04:56, J. Bruce Fields wrote:
> On Wed, Oct 19, 2011 at 07:13:37PM -0700, Benny Halevy wrote:
>> From: Benny Halevy <bhalevy@tonian.com>
>>
>> Currently, it will not correctl ignore and nfsv4.1 signal flags if the client
>> sends them.
> 
> Good catch, but since b6d2f1ca3c1162f51098969e9c52fd099720416a "nfsd4:
> more robust ignoring of WANT bits in OPEN" we're actually doing this
> right from the start, and this is redundant.
> 
> (And remembering to mask out the other bits on every use is so
> error-prone, I'm wondering if we should actually put the other bits in a
> separate field entirely.  Either that or maybe provide a little helper
> function to get the access bits and ensure they're never accessed any
> other way.)

Agreed, something along these lines? (untested)

>From 3eb3100dc8c8c3833ae24b09d356001245b7e691 Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@tonian.com>
Date: Thu, 20 Oct 2011 07:12:47 -0700
Subject: [PATCH] nfsd4: split out share_access want and signel flags while decoding

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4proc.c  |    3 ---
 fs/nfsd/nfs4state.c |    8 ++++----
 fs/nfsd/nfs4xdr.c   |   25 +++++++++++++++++++------
 fs/nfsd/xdr4.h      |    6 ++++--
 4 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2f87ea5..65f6c86 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -319,9 +319,6 @@ static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;

-	/* We don't yet support WANT bits: */
-	open->op_share_access &= NFS4_SHARE_ACCESS_MASK;
-
 	/*
 	 * RFC5661 18.51.3
 	 * Before RECLAIM_COMPLETE done, server should deny new lock
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9701d71..d00c246 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2657,8 +2657,6 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4

 static int share_access_to_flags(u32 share_access)
 {
-	share_access &= NFS4_SHARE_ACCESS_MASK;
-
 	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
 }

@@ -3036,7 +3034,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	if (nfsd4_has_session(&resp->cstate)) {
 		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;

-		if (open->op_share_access & NFS4_SHARE_WANT_NO_DELEG) {
+		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
 			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
 			goto nodeleg;
 		}
@@ -3654,7 +3652,9 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 			cstate->current_fh.fh_dentry->d_name.name);

 	/* We don't yet support WANT bits: */
-	od->od_share_access &= NFS4_SHARE_ACCESS_MASK;
+	if (od->od_deleg_want)
+		dprintk("NFSD: %s: od_deleg_want=0x%x ignored\n", __func__,
+			od->od_deleg_want);

 	nfs4_lock_state();
 	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 79cb105..9b838e9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -644,15 +644,19 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
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
-	switch (w & NFS4_SHARE_ACCESS_MASK) {
+	*share_access = w & NFS4_SHARE_ACCESS_MASK;
+	*deleg_want = w & NFS4_SHARE_WANT_MASK;
+	if (deleg_when)
+		*deleg_when = w & NFS4_SHARE_WHEN_MASK;
+
+	switch (w & NFS4_SHARE_WHEN_MASK) {
 	case NFS4_SHARE_ACCESS_READ:
 	case NFS4_SHARE_ACCESS_WRITE:
 	case NFS4_SHARE_ACCESS_BOTH:
@@ -660,11 +664,13 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
 	default:
 		return nfserr_bad_xdr;
 	}
-	w &= !NFS4_SHARE_ACCESS_MASK;
+	w &= ~NFS4_SHARE_ACCESS_MASK;
 	if (!w)
 		return nfs_ok;
+
 	if (!argp->minorversion)
 		return nfserr_bad_xdr;
+
 	switch (w & NFS4_SHARE_WANT_MASK) {
 	case NFS4_SHARE_WANT_NO_PREFERENCE:
 	case NFS4_SHARE_WANT_READ_DELEG:
@@ -679,6 +685,9 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
 	w &= ~NFS4_SHARE_WANT_MASK;
 	if (!w)
 		return nfs_ok;
+
+	if (!deleg_when)	/* open_downgrade */
+		return nfserr_inval;
 	switch (w) {
 	case NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL:
 	case NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED:
@@ -725,6 +734,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 {
 	DECODE_HEAD;
+	u32 dummy;

 	memset(open->op_bmval, 0, sizeof(open->op_bmval));
 	open->op_iattr.ia_valid = 0;
@@ -733,7 +743,9 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
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
@@ -854,7 +866,8 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
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
index bf4c9e7..1e5ca95 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -224,6 +224,7 @@ struct nfsd4_open {
 	u32		op_seqid;           /* request */
 	u32		op_share_access;    /* request */
 	u32		op_share_deny;      /* request */
+	u32		op_deleg_want;      /* request */
 	stateid_t	op_stateid;         /* response */
 	u32		op_recall;          /* recall */
 	struct nfsd4_change_info  op_cinfo; /* response */
@@ -244,8 +245,9 @@ struct nfsd4_open_confirm {
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
1.7.6

