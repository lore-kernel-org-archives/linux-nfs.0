From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/4] lockd: nlm_release_host() checks for NULL, caller needn't
Date: Tue, 15 Jul 2008 14:48:10 -0400
Message-ID: <1216147693-23881-1-git-send-email-bfields@citi.umich.edu>
References: <20080715184554.GD21590@fieldses.org>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39560 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbYGOSs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 14:48:28 -0400
In-Reply-To: <20080715184554.GD21590@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

No need to check for a NULL argument twice.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc4proc.c |    3 +--
 fs/lockd/svcproc.c  |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 385437e..006a832 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -58,8 +58,7 @@ nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return 0;
 
 no_locks:
-	if (host)
-		nlm_release_host(host);
+	nlm_release_host(host);
  	if (error)
 		return error;	
 	return nlm_lck_denied_nolocks;
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 88379cc..fce3d70 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -87,8 +87,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return 0;
 
 no_locks:
-	if (host)
-		nlm_release_host(host);
+	nlm_release_host(host);
 	if (error)
 		return error;
 	return nlm_lck_denied_nolocks;
-- 
1.5.5.rc1

