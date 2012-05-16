Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44917 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933337Ab2EPMsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/11] nfsd4: exchange_id error cleanup
Date: Wed, 16 May 2012 08:48:30 -0400
Message-Id: <1337172519-17335-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There's no point to the dprintk here as the main proc_compound loop
already does this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b699c27f..6b7b884 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1508,13 +1508,11 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	status = nfs4_make_rec_clidname(dname, &exid->clname);
 
 	if (status)
-		goto error;
+		return status;
 
 	strhashval = clientstr_hashval(dname);
 
 	nfs4_lock_state();
-	status = nfs_ok;
-
 	conf = find_confirmed_client_by_str(dname, strhashval);
 	if (conf) {
 		if (!clp_used_exchangeid(conf)) {
@@ -1593,8 +1591,6 @@ out_copy:
 
 out:
 	nfs4_unlock_state();
-error:
-	dprintk("nfsd4_exchange_id returns %d\n", ntohl(status));
 	return status;
 }
 
-- 
1.7.9.5

