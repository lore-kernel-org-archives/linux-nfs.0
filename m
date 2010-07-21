From: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/7] nfsd: clean up nfsd_create_serv error handling
Date: Wed, 21 Jul 2010 19:26:48 -0400
Message-ID: <1279754811-8328-4-git-send-email-bfields@redhat.com>
References: <20100721232432.GA6689@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916Ab0GUX1v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 19:27:51 -0400
In-Reply-To: <20100721232432.GA6689@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

There doesn't seem to be any need to reset the nfssvc_boot time if the
nfsd startup failed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d7a4d7b..a631ea6 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -292,10 +292,9 @@ int nfsd_create_serv(void)
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
-		err = -ENOMEM;
-	else
-		set_max_drc();
+		return -ENOMEM;
 
+	set_max_drc();
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;
 }
-- 
1.7.0.4

