Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60626 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760347Ab2EWVkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 01/10] nfsd4: setclientid remove unnecessary terms from a logical expression
Date: Wed, 23 May 2012 17:40:31 -0400
Message-Id: <1337809240-15770-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 21266c7..3dc0289 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2344,9 +2344,8 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			nfsd4_probe_callback(conf);
 			status = nfs_ok;
 		}
-	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm, &confirm)))
-	    && (!unconf || (unconf && !same_verf(&unconf->cl_confirm,
-				    				&confirm)))) {
+	} else if ((!conf || !same_verf(&conf->cl_confirm, &confirm))
+	    && (!unconf || !same_verf(&unconf->cl_confirm, &confirm))) {
 		/*
 		 * RFC 3530 14.2.34 CASE 4:
 		 * Client probably hasn't noticed that we rebooted yet.
-- 
1.7.9.5

