Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492Ab2KZOkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:02 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 1/8] nfsd: fix v4 reply caching
Date: Mon, 26 Nov 2012 09:39:52 -0500
Message-Id: <1353940799-11763-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Very embarassing: 1091006c5eb15cba56785bd5b498a8d0b9546903 "nfsd: turn
on reply cache for NFSv4" missed a line, effectively leaving the reply
cache off in the v4 case.  I thought I'd tested that, but I guess not.

This time, wrote a pynfs test to confirm it works.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2013aa00..30d3784 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -640,7 +640,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	}
 
 	/* Store reply in cache. */
-	nfsd_cache_update(rqstp, proc->pc_cachetype, statp + 1);
+	nfsd_cache_update(rqstp, rqstp->rq_cachetype, statp + 1);
 	return 1;
 }
 
-- 
1.7.9.5

