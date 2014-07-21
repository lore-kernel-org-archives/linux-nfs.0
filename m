Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:50651 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932436AbaGUNf1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 09:35:27 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so5240369qge.25
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 06:35:26 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v5 08/10] nfsd: clean up arguments to nfs4_open_delegation
Date: Mon, 21 Jul 2014 09:35:04 -0400
Message-Id: <1405949706-27757-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
References: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to pass in a net pointer since we can derive that.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index acddedb7250e..171ab5a2c60c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3601,11 +3601,12 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
  * proper support for them.
  */
 static void
-nfs4_open_delegation(struct net *net, struct svc_fh *fh,
-		     struct nfsd4_open *open, struct nfs4_ol_stateid *stp)
+nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
+			struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_delegation *dp;
-	struct nfs4_openowner *oo = container_of(stp->st_stateowner, struct nfs4_openowner, oo_owner);
+	struct nfs4_openowner *oo = openowner(stp->st_stateowner);
+	struct nfs4_client *clp = stp->st_stid.sc_client;
 	int cb_up;
 	int status = 0;
 
@@ -3624,7 +3625,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 			 * Let's not give out any delegations till everyone's
 			 * had the chance to reclaim theirs....
 			 */
-			if (locks_in_grace(net))
+			if (locks_in_grace(clp->net))
 				goto out_no_deleg;
 			if (!cb_up || !(oo->oo_flags & NFS4_OO_CONFIRMED))
 				goto out_no_deleg;
@@ -3643,7 +3644,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 		default:
 			goto out_no_deleg;
 	}
-	dp = alloc_init_deleg(oo->oo_owner.so_client, fh);
+	dp = alloc_init_deleg(clp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
 	status = nfs4_set_delegation(dp, stp->st_file);
@@ -3757,7 +3758,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	* Attempt to hand out a delegation. No error return, because the
 	* OPEN succeeds even if we fail.
 	*/
-	nfs4_open_delegation(SVC_NET(rqstp), current_fh, open, stp);
+	nfs4_open_delegation(current_fh, open, stp);
 nodeleg:
 	status = nfs_ok;
 
-- 
1.9.3

