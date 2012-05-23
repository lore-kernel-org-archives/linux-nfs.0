Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60640 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760858Ab2EWVkn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/10] nfsd4: setclientid: remove pointless assignment
Date: Wed, 23 May 2012 17:40:38 -0400
Message-Id: <1337809240-15770-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8e77782..e8e3ce0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2263,8 +2263,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			expire_client(conf);
 		}
 		move_to_confirmed(unconf);
-		conf = unconf;
-		nfsd4_probe_callback(conf);
+		nfsd4_probe_callback(unconf);
 		status = nfs_ok;
 	} else if ((!conf || !same_verf(&conf->cl_confirm, &confirm))
 	    && (!unconf || !same_verf(&unconf->cl_confirm, &confirm))) {
-- 
1.7.9.5

