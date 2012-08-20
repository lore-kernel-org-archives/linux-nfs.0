Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32885 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756728Ab2HTWvE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 18:51:04 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd: do_nfsd_create verf argument is a u32
Date: Mon, 20 Aug 2012 18:51:00 -0400
Message-Id: <1345503060-8892-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1345503060-8892-1-git-send-email-bfields@redhat.com>
References: <1345503060-8892-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The types here are actually a bit of a mess.  For now cast as we do in
the v4 case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs3proc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 9095f3c..97d90d1 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -247,7 +247,7 @@ nfsd3_proc_create(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
 	/* Now create the file and set attributes */
 	nfserr = do_nfsd_create(rqstp, dirfhp, argp->name, argp->len,
 				attr, newfhp,
-				argp->createmode, argp->verf, NULL, NULL);
+				argp->createmode, (u32 *)argp->verf, NULL, NULL);
 
 	RETURN_STATUS(nfserr);
 }
-- 
1.7.9.5

