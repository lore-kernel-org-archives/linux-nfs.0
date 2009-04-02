From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 13/21] SQUASHME: nfsd41: fix comment style in init_forechannel_attrs
Date: Fri,  3 Apr 2009 01:38:31 +0300
Message-ID: <1238711911-22427-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28314 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764231AbZDBWig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:36 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

squash into "nfsd41: create_session operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c3d555d..610d918 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -455,7 +455,7 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 	int status = 0;
 	__u32   maxcount = svc_max_payload(rqstp);
 
-	/* headerpadsz set to zero in encode routine*/
+	/* headerpadsz set to zero in encode routine */
 
 	/* Use the client's max request and max response size if possible */
 	if (fchan->maxreq_sz > maxcount)
-- 
1.6.2.1

