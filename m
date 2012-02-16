Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45905 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691Ab2BPS5W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:57:22 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so1017523eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:57:21 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfsd41: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg
Date: Thu, 16 Feb 2012 20:57:17 +0200
Message-Id: <1329418637-23925-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3D4F1F.6080502@tonian.com>
References: <4F3D4F1F.6080502@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Respect client request for not getting a delegation in NFSv4.1
Appropriately return delegation "type" NFS4_OPEN_DELEGATE_NONE_EXT
and WND4_NOT_WANTED reason.

[nfsd41: add missing break when encoding op_why_no_deleg]
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4state.c  |   60 ++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4xdr.c    |   14 +++++++++++
 fs/nfsd/xdr4.h       |    1 +
 include/linux/nfs4.h |   15 +++++++++++-
 4 files changed, 82 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c165df7..ad21b06 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2862,7 +2862,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	struct nfs4_delegation *dp;
 	struct nfs4_openowner *oo = container_of(stp->st_stateowner, struct nfs4_openowner, oo_owner);
 	int cb_up;
-	int status, flag = 0;
+	int status = 0, flag = 0;
 
 	cb_up = nfsd4_cb_channel_good(oo->oo_owner.so_client);
 	flag = NFS4_OPEN_DELEGATE_NONE;
@@ -2903,11 +2903,32 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
 		STATEID_VAL(&dp->dl_stid.sc_stateid));
 out:
-	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS
-			&& flag == NFS4_OPEN_DELEGATE_NONE
-			&& open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
-		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
 	open->op_delegate_type = flag;
+	if (flag == NFS4_OPEN_DELEGATE_NONE) {
+		if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
+		    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
+			dprintk("NFSD: WARNING: refusing delegation reclaim\n");
+
+		if (open->op_deleg_want) {
+			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			if (status == -EAGAIN)
+				open->op_why_no_deleg = WND4_CONTENTION;
+			else {
+				open->op_why_no_deleg = WND4_RESOURCE;
+				switch (open->op_deleg_want) {
+				case NFS4_SHARE_WANT_READ_DELEG:
+				case NFS4_SHARE_WANT_WRITE_DELEG:
+				case NFS4_SHARE_WANT_ANY_DELEG:
+					break;
+				case NFS4_SHARE_WANT_CANCEL:
+					open->op_why_no_deleg = WND4_CANCELLED;
+					break;
+				case NFS4_SHARE_WANT_NO_DELEG:
+					BUG();	/* not supposed to get here */
+				}
+			}
+		}
+	}
 	return;
 out_free:
 	nfs4_put_delegation(dp);
@@ -2977,20 +2998,45 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
-	if (nfsd4_has_session(&resp->cstate))
+	if (nfsd4_has_session(&resp->cstate)) {
 		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 
+		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
+			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			open->op_why_no_deleg = WND4_NOT_WANTED;
+			goto nodeleg;
+		}
+	}
+
 	/*
 	* Attempt to hand out a delegation. No error return, because the
 	* OPEN succeeds even if we fail.
 	*/
 	nfs4_open_delegation(current_fh, open, stp);
-
+nodeleg:
 	status = nfs_ok;
 
 	dprintk("%s: stateid=" STATEID_FMT "\n", __func__,
 		STATEID_VAL(&stp->st_stid.sc_stateid));
 out:
+	/* 4.1 client trying to upgrade/downgrade delegation? */
+	if (open->op_delegate_type == NFS4_OPEN_DELEGATE_NONE && dp &&
+	    open->op_deleg_want) {
+		if (open->op_deleg_want == NFS4_SHARE_WANT_READ_DELEG &&
+		    dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
+			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
+		} else if (open->op_deleg_want == NFS4_SHARE_WANT_WRITE_DELEG &&
+			   dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
+			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			open->op_why_no_deleg = WND4_NOT_SUPP_UPGRADE;
+		}
+		/* Otherwise the client must be confused wanting a delegation
+		 * it already has, therefore we don't return
+		 * NFS4_OPEN_DELEGATE_NONE_EXT and reason.
+		 */
+	}
+
 	if (fp)
 		put_nfs4_file(fp);
 	if (status == 0 && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 78d2bb8..c2cf857 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2862,6 +2862,20 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		WRITE32(0);   /* XXX: is NULL principal ok? */
 		ADJUST_ARGS();
 		break;
+	case NFS4_OPEN_DELEGATE_NONE_EXT: /* 4.1 */
+		switch (open->op_why_no_deleg) {
+		case WND4_CONTENTION:
+		case WND4_RESOURCE:
+			RESERVE_SPACE(8);
+			WRITE32(open->op_why_no_deleg);
+			WRITE32(0);	/* deleg signaling not supported yet */
+			break;
+		default:
+			RESERVE_SPACE(4);
+			WRITE32(open->op_why_no_deleg);
+		}
+		ADJUST_ARGS();
+		break;
 	default:
 		BUG();
 	}
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 1771a91..fea600f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -212,6 +212,7 @@ struct nfsd4_open {
 	struct xdr_netobj op_fname;	    /* request - everything but CLAIM_PREV */
 	u32		op_delegate_type;   /* request - CLAIM_PREV only */
 	stateid_t       op_delegate_stateid; /* request - response */
+	u32		op_why_no_deleg;    /* response - DELEG_NONE_EXT only */
 	u32		op_create;     	    /* request */
 	u32		op_createmode;      /* request */
 	u32		op_bmval[3];        /* request */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 32345c2..8cdde4d 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -441,7 +441,20 @@ enum limit_by4 {
 enum open_delegation_type4 {
 	NFS4_OPEN_DELEGATE_NONE = 0,
 	NFS4_OPEN_DELEGATE_READ = 1,
-	NFS4_OPEN_DELEGATE_WRITE = 2
+	NFS4_OPEN_DELEGATE_WRITE = 2,
+	NFS4_OPEN_DELEGATE_NONE_EXT = 3, /* 4.1 */
+};
+
+enum why_no_delegation4 { /* new to v4.1 */
+	WND4_NOT_WANTED = 0,
+	WND4_CONTENTION = 1,
+	WND4_RESOURCE = 2,
+	WND4_NOT_SUPP_FTYPE = 3,
+	WND4_WRITE_DELEG_NOT_SUPP_FTYPE = 4,
+	WND4_NOT_SUPP_UPGRADE = 5,
+	WND4_NOT_SUPP_DOWNGRADE = 6,
+	WND4_CANCELLED = 7,
+	WND4_IS_DIR = 8,
 };
 
 enum lock_type4 {
-- 
1.7.6.5

