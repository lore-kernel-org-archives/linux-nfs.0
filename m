Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@kernel.org
Subject: [PATCH 03/15] nfsd4: stop using nfserr_resource for transitory errors
Date: Fri, 26 Aug 2011 18:28:24 -0400
Message-Id: <1314397716-18602-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The server is returning nfserr_resource for both permanent errors and
for errors (like allocation failures) that might be resolved by retrying
later.  Save nfserr_resource for the former and use delay/jukebox for
the latter.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c    |    2 +-
 fs/nfsd/nfs4recover.c |    2 +-
 fs/nfsd/nfs4state.c   |   14 +++++++-------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 479ffb1..ffb4a54 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -938,7 +938,7 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	count = 4 + (verify->ve_attrlen >> 2);
 	buf = kmalloc(count << 2, GFP_KERNEL);
 	if (!buf)
-		return nfserr_resource;
+		return nfserr_jukebox;
 
 	status = nfsd4_encode_fattr(&cstate->current_fh,
 				    cstate->current_fh.fh_export,
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 29d77f6..02eb38e 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -88,7 +88,7 @@ nfs4_make_rec_clidname(char *dname, struct xdr_netobj *clname)
 	struct xdr_netobj cksum;
 	struct hash_desc desc;
 	struct scatterlist sg;
-	__be32 status = nfserr_resource;
+	__be32 status = nfserr_jukebox;
 
 	dprintk("NFSD: nfs4_make_rec_clidname for %.*s\n",
 			clname->len, clname->data);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aa0a36e..08b8413 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1946,7 +1946,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * of 5 bullet points, labeled as CASE0 - CASE4 below.
 	 */
 	unconf = find_unconfirmed_client_by_str(dname, strhashval);
-	status = nfserr_resource;
+	status = nfserr_jukebox;
 	if (!conf) {
 		/*
 		 * RFC 3530 14.2.33 CASE 4:
@@ -2483,7 +2483,7 @@ renew:
 	if (open->op_stateowner == NULL) {
 		sop = alloc_init_open_stateowner(strhashval, clp, open);
 		if (sop == NULL)
-			return nfserr_resource;
+			return nfserr_jukebox;
 		open->op_stateowner = sop;
 	}
 	list_del_init(&sop->so_close_lru);
@@ -2619,7 +2619,7 @@ nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_stateid **stpp,
 
 	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
-		return nfserr_resource;
+		return nfserr_jukebox;
 
 	status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
 	if (status) {
@@ -2850,7 +2850,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfserr_bad_stateid;
 		if (open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR)
 			goto out;
-		status = nfserr_resource;
+		status = nfserr_jukebox;
 		fp = alloc_init_file(ino);
 		if (fp == NULL)
 			goto out;
@@ -4035,7 +4035,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* XXX: Do we need to check for duplicate stateowners on
 		 * the same file, or should they just be allowed (and
 		 * create new stateids)? */
-		status = nfserr_resource;
+		status = nfserr_jukebox;
 		lock_sop = alloc_init_lock_stateowner(strhashval,
 				open_sop->so_client, open_stp, lock);
 		if (lock_sop == NULL)
@@ -4119,9 +4119,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	case (EDEADLK):
 		status = nfserr_deadlock;
 		break;
-	default:        
+	default:
 		dprintk("NFSD: nfsd4_lock: vfs_lock_file() failed! status %d\n",err);
-		status = nfserr_resource;
+		status = nfserrno(err);
 		break;
 	}
 out:
-- 
1.7.4.1

