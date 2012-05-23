Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759512Ab2EWVkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/10] nfsd4: fix setclientid_confirm same_cred check
Date: Wed, 23 May 2012 17:40:36 -0400
Message-Id: <1337809240-15770-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

New clients are created only by nfsd4_setclientid(), which always gives
any new client a unique clientid.  The only exception is in the
"callback update" case, in which case it may create an unconfirmed
client with the same clientid as a confirmed client.  In that case it
also checks that the confirmed client has the same credential.

Therefore, it is pointless for setclientid_confirm to check whether a
confirmed and unconfirmed client with the same clientid have matching
credentials--they're guaranteed to.

Instead, it should be checking whether the credential on the
setclientid_confirm matches either of those.  Otherwise, it could be
anyone sending the setclientid_confirm.  Granted, I can't see why anyone
would, but still it's probalby safer to check.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2d28abf..286710d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2243,7 +2243,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	status = nfserr_clid_inuse;
 	if (conf && unconf && same_verf(&confirm, &unconf->cl_confirm)) {
 		/* case 1: callback update */
-		if (!same_creds(&conf->cl_cred, &unconf->cl_cred))
+		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred))
 			status = nfserr_clid_inuse;
 		else {
 			nfsd4_change_callback(conf, &unconf->cl_cb_conn);
-- 
1.7.9.5

