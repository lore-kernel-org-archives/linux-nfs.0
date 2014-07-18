Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:52288 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761996AbaGRPNz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:13:55 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so3068119qac.26
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 08:13:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 08/10] nfsd: clean up arguments to nfs4_open_delegation
Date: Fri, 18 Jul 2014 11:13:34 -0400
Message-Id: <1405696416-32585-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to pass in a net pointer since we can derive that.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3e761ea48a70..1834d9bd5935 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3608,11 +3608,12 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
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
 
@@ -3631,7 +3632,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 			 * Let's not give out any delegations till everyone's
 			 * had the chance to reclaim theirs....
 			 */
-			if (locks_in_grace(net))
+			if (locks_in_grace(clp->net))
 				goto out_no_deleg;
 			if (!cb_up || !(oo->oo_flags & NFS4_OO_CONFIRMED))
 				goto out_no_deleg;
@@ -3650,7 +3651,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 		default:
 			goto out_no_deleg;
 	}
-	dp = alloc_init_deleg(oo->oo_owner.so_client, fh);
+	dp = alloc_init_deleg(clp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
 	status = nfs4_set_delegation(dp, stp->st_file);
@@ -3764,7 +3765,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	* Attempt to hand out a delegation. No error return, because the
 	* OPEN succeeds even if we fail.
 	*/
-	nfs4_open_delegation(SVC_NET(rqstp), current_fh, open, stp);
+	nfs4_open_delegation(current_fh, open, stp);
 nodeleg:
 	status = nfs_ok;
 
-- 
1.9.3

