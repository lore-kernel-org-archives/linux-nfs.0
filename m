Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:37107 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbaGYLeu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:50 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so4392299qac.19
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v6 6/9] nfsd: clean up arguments to nfs4_open_delegation
Date: Fri, 25 Jul 2014 07:34:24 -0400
Message-Id: <1406288067-20663-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to pass in a net pointer since we can derive that.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 049ef2ce72bf..24065e1b2bb2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3607,11 +3607,12 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
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
 
@@ -3630,7 +3631,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 			 * Let's not give out any delegations till everyone's
 			 * had the chance to reclaim theirs....
 			 */
-			if (locks_in_grace(net))
+			if (locks_in_grace(clp->net))
 				goto out_no_deleg;
 			if (!cb_up || !(oo->oo_flags & NFS4_OO_CONFIRMED))
 				goto out_no_deleg;
@@ -3649,7 +3650,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 		default:
 			goto out_no_deleg;
 	}
-	dp = alloc_init_deleg(oo->oo_owner.so_client, fh);
+	dp = alloc_init_deleg(clp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
 	status = nfs4_set_delegation(dp, stp->st_file);
@@ -3762,7 +3763,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	* Attempt to hand out a delegation. No error return, because the
 	* OPEN succeeds even if we fail.
 	*/
-	nfs4_open_delegation(SVC_NET(rqstp), current_fh, open, stp);
+	nfs4_open_delegation(current_fh, open, stp);
 nodeleg:
 	status = nfs_ok;
 
-- 
1.9.3

