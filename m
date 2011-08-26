Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53256 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752857Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/15] nfsd4: cleanup and consolidate seqid_mutating_err
Date: Fri, 26 Aug 2011 18:28:29 -0400
Message-Id: <1314397716-18602-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4_fs.h     |   24 ------------------------
 fs/nfsd/nfs4xdr.c    |   14 +-------------
 include/linux/nfs4.h |   16 ++++++++++++++++
 3 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1ec1a85..1a652a0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -13,30 +13,6 @@
 
 struct idmap;
 
-/*
- * In a seqid-mutating op, this macro controls which error return
- * values trigger incrementation of the seqid.
- *
- * from rfc 3010:
- * The client MUST monotonically increment the sequence number for the
- * CLOSE, LOCK, LOCKU, OPEN, OPEN_CONFIRM, and OPEN_DOWNGRADE
- * operations.  This is true even in the event that the previous
- * operation that used the sequence number received an error.  The only
- * exception to this rule is if the previous operation received one of
- * the following errors: NFSERR_STALE_CLIENTID, NFSERR_STALE_STATEID,
- * NFSERR_BAD_STATEID, NFSERR_BAD_SEQID, NFSERR_BADXDR,
- * NFSERR_RESOURCE, NFSERR_NOFILEHANDLE.
- *
- */
-#define seqid_mutating_err(err)       \
-(((err) != NFSERR_STALE_CLIENTID) &&  \
- ((err) != NFSERR_STALE_STATEID)  &&  \
- ((err) != NFSERR_BAD_STATEID)    &&  \
- ((err) != NFSERR_BAD_SEQID)      &&  \
- ((err) != NFSERR_BAD_XDR)        &&  \
- ((err) != NFSERR_RESOURCE)       &&  \
- ((err) != NFSERR_NOFILEHANDLE))
-
 enum nfs4_client_state {
 	NFS4CLNT_MANAGER_RUNNING  = 0,
 	NFS4CLNT_CHECK_LEASE,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 78c792f..04ad9a2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1623,18 +1623,6 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 								\
 	save = resp->p;
 
-static bool seqid_mutating_err(__be32 err)
-{
-	/* rfc 3530 section 8.1.5: */
-	return	err != nfserr_stale_clientid &&
-		err != nfserr_stale_stateid &&
-		err != nfserr_bad_stateid &&
-		err != nfserr_bad_seqid &&
-		err != nfserr_bad_xdr &&
-		err != nfserr_resource &&
-		err != nfserr_nofilehandle;
-}
-
 /*
  * Routine for encoding the result of a "seqid-mutating" NFSv4 operation.  This
  * is where sequence id's are incremented, and the replay cache is filled.
@@ -1643,7 +1631,7 @@ static bool seqid_mutating_err(__be32 err)
  */
 
 #define ENCODE_SEQID_OP_TAIL(stateowner) do {			\
-	if (seqid_mutating_err(nfserr) && stateowner) { 	\
+	if (seqid_mutating_err(ntohl(nfserr)) && stateowner) { 	\
 		stateowner->so_seqid++;				\
 		stateowner->so_replay.rp_status = nfserr;   	\
 		stateowner->so_replay.rp_buflen = 		\
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 76f99e8..b875b03 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -373,6 +373,22 @@ enum nfsstat4 {
 	NFS4ERR_DELEG_REVOKED	= 10087,	/* deleg./layout revoked */
 };
 
+static inline bool seqid_mutating_err(u32 err)
+{
+	/* rfc 3530 section 8.1.5: */
+	switch (err) {
+	case NFS4ERR_STALE_CLIENTID:
+	case NFS4ERR_STALE_STATEID:
+	case NFS4ERR_BAD_STATEID:
+	case NFS4ERR_BAD_SEQID:
+	case NFS4ERR_BADXDR:
+	case NFS4ERR_RESOURCE:
+	case NFS4ERR_NOFILEHANDLE:
+		return false;
+	};
+	return true;
+}
+
 /*
  * Note: NF4BAD is not actually part of the protocol; it is just used
  * internally by nfsd.
-- 
1.7.4.1

