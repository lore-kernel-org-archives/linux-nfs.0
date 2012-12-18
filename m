Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60449 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747Ab2LREp6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 23:45:58 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd: warn on odd reply state in nfsd_vfs_read
Date: Mon, 17 Dec 2012 23:45:50 -0500
Message-Id: <1355805953-2473-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1355805953-2473-1-git-send-email-bfields@redhat.com>
References: <1355805953-2473-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As far as I can tell this shouldn't currently happen--or if it does,
something is wrong and data is going to be corrupted.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0ef9b6b..b31e46e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -936,6 +936,7 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 			.u.data		= rqstp,
 		};
 
+		WARN_ON_ONCE(rqstp->rq_resused != 1);
 		rqstp->rq_resused = 1;
 		host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
 	} else {
-- 
1.7.9.5

