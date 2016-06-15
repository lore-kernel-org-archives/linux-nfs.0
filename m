Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:51486 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161091AbcFOD22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2016 23:28:28 -0400
From: Oleg Drokin <green@linuxhacker.ru>
To: Jeff Layton <jlayton@poochiereds.net>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH 2/3] nfsd: Extend the mutex holding region around in nfsd4_process_open2()
Date: Tue, 14 Jun 2016 23:28:05 -0400
Message-Id: <1465961286-925636-3-git-send-email-green@linuxhacker.ru>
In-Reply-To: <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
References: <1465945026.12291.5.camel@poochiereds.net>
 <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To avoid racing entry into nfs4_get_vfs_file().
Make init_open_stateid() return with locked stateid to be unlocked
by the caller.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 fs/nfsd/nfs4state.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c927d36..94854a0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3487,6 +3487,10 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	struct nfs4_openowner *oo = open->op_openowner;
 	struct nfs4_ol_stateid *retstp = NULL;
 
+	/* We are moving these outside of the spinlocks to avoid the warnings */
+	mutex_init(&stp->st_mutex);
+	mutex_lock(&stp->st_mutex);
+
 	spin_lock(&oo->oo_owner.so_client->cl_lock);
 	spin_lock(&fp->fi_lock);
 
@@ -3502,13 +3506,17 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	stp->st_openstp = NULL;
-	mutex_init(&stp->st_mutex);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 
 out_unlock:
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
+	if (retstp) {
+		mutex_lock(&retstp->st_mutex);
+		/* Not that we need to, just for neatness */
+		mutex_unlock(&stp->st_mutex);
+	}
 	return retstp;
 }
 
@@ -4344,11 +4352,14 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	} else {
 		stp = open->op_stp;
 		open->op_stp = NULL;
+		/*
+		 * init_open_stateid() either returns a locked stateid
+		 * it found, or initializes and locks the new one we passed in
+		 */
 		swapstp = init_open_stateid(stp, fp, open);
 		if (swapstp) {
 			nfs4_put_stid(&stp->st_stid);
 			stp = swapstp;
-			mutex_lock(&stp->st_mutex);
 			status = nfs4_upgrade_open(rqstp, fp, current_fh,
 						stp, open);
 			if (status) {
@@ -4357,7 +4368,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			}
 			goto upgrade_out;
 		}
-		mutex_lock(&stp->st_mutex);
 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
 		if (status) {
 			mutex_unlock(&stp->st_mutex);
-- 
2.7.4

