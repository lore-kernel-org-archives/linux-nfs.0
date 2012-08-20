Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32887 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756727Ab2HTWvE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 18:51:04 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd4: nfsaclsvc_encode_voidres static
Date: Mon, 20 Aug 2012 18:50:58 -0400
Message-Id: <1345503060-8892-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1345503060-8892-1-git-send-email-bfields@redhat.com>
References: <1345503060-8892-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs2acl.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 6aa5590..b314888 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -218,8 +218,7 @@ static int nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p,
  * There must be an encoding function for void results so svc_process
  * will work properly.
  */
-int
-nfsaclsvc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
+static int nfsaclsvc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
 {
 	return xdr_ressize_check(rqstp, p);
 }
-- 
1.7.9.5

