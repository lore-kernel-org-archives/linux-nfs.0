Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43322 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628Ab2JARnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:43:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd4: set cl_minorversion at create time
Date: Mon,  1 Oct 2012 13:43:47 -0400
Message-Id: <1349113428-30173-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113428-30173-1-git-send-email-bfields@redhat.com>
References: <1349113428-30173-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

And remove some mostly obsolete comments.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0f8d7e7..73029cd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1667,6 +1667,7 @@ out_new:
 		status = nfserr_jukebox;
 		goto out;
 	}
+	new->cl_minorversion = 1;
 
 	gen_clid(new);
 	add_to_unconfirmed(new, strhashval);
@@ -1799,12 +1800,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		status = nfserr_stale_clientid;
 		goto out;
 	}
-
-	/*
-	 * XXX: we should probably set this at creation time, and check
-	 * for consistent minorversion use throughout:
-	 */
-	conf->cl_minorversion = 1;
 	/*
 	 * We do not support RDMA or persistent sessions
 	 */
@@ -2216,10 +2211,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		copy_clid(new, conf);
 	else /* case 4 (new client) or cases 2, 3 (client reboot): */
 		gen_clid(new);
-	/*
-	 * XXX: we should probably set this at creation time, and check
-	 * for consistent minorversion use throughout:
-	 */
 	new->cl_minorversion = 0;
 	gen_callback(new, setclid, rqstp);
 	add_to_unconfirmed(new, strhashval);
-- 
1.7.9.5

