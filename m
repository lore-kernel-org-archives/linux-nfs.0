Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:51488 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161113AbcFOD2d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2016 23:28:33 -0400
From: Oleg Drokin <green@linuxhacker.ru>
To: Jeff Layton <jlayton@poochiereds.net>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH 3/3] nfsd: Make init_open_stateid() a bit more whole
Date: Tue, 14 Jun 2016 23:28:06 -0400
Message-Id: <1465961286-925636-4-git-send-email-green@linuxhacker.ru>
In-Reply-To: <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
References: <1465945026.12291.5.camel@poochiereds.net>
 <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the state selection logic inside from the caller,
always making it return correct stp to use.

Signed-off-by: J . Bruce Fields <bfields@fieldses.org>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 fs/nfsd/nfs4state.c | 27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 94854a0..70d0b9b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3480,13 +3480,14 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 }
 
 static struct nfs4_ol_stateid *
-init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
-		struct nfsd4_open *open)
+init_open_stateid(struct nfs4_file *fp, struct nfsd4_open *open)
 {
 
 	struct nfs4_openowner *oo = open->op_openowner;
 	struct nfs4_ol_stateid *retstp = NULL;
+	struct nfs4_ol_stateid *stp;
 
+	stp = open->op_stp;
 	/* We are moving these outside of the spinlocks to avoid the warnings */
 	mutex_init(&stp->st_mutex);
 	mutex_lock(&stp->st_mutex);
@@ -3497,6 +3498,8 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	retstp = nfsd4_find_existing_open(fp, open);
 	if (retstp)
 		goto out_unlock;
+
+	open->op_stp = NULL;
 	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
@@ -3514,10 +3517,11 @@ out_unlock:
 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
 	if (retstp) {
 		mutex_lock(&retstp->st_mutex);
-		/* Not that we need to, just for neatness */
+		/* To keep mutex tracking happy */
 		mutex_unlock(&stp->st_mutex);
+		stp = retstp;
 	}
-	return retstp;
+	return stp;
 }
 
 /*
@@ -4313,7 +4317,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	struct nfs4_file *fp = NULL;
 	struct nfs4_ol_stateid *stp = NULL;
-	struct nfs4_ol_stateid *swapstp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
 
@@ -4350,16 +4353,10 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			goto out;
 		}
 	} else {
-		stp = open->op_stp;
-		open->op_stp = NULL;
-		/*
-		 * init_open_stateid() either returns a locked stateid
-		 * it found, or initializes and locks the new one we passed in
-		 */
-		swapstp = init_open_stateid(stp, fp, open);
-		if (swapstp) {
-			nfs4_put_stid(&stp->st_stid);
-			stp = swapstp;
+		/* stp is returned locked. */
+		stp = init_open_stateid(fp, open);
+		/* See if we lost the race to some other thread */
+		if (stp->st_access_bmap != 0) {
 			status = nfs4_upgrade_open(rqstp, fp, current_fh,
 						stp, open);
 			if (status) {
-- 
2.7.4

