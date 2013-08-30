Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33763 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753309Ab3H3VoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Aug 2013 17:44:05 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1VFWU9-000095-1a
	for linux-nfs@vger.kernel.org; Fri, 30 Aug 2013 17:44:05 -0400
Date: Fri, 30 Aug 2013 17:44:05 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] svcrpc: remove unused rq_resused
Message-ID: <20130830214405.GC32015@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I forgot to remove this in
afc59400d6c65bad66d4ad0b2daf879cbff8e23e "nfsd4: cleanup: replace
rq_resused count by rq_next_page pointer".

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svc.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 1f0216b..6eecfc2 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -243,7 +243,6 @@ struct svc_rqst {
 	struct xdr_buf		rq_res;
 	struct page *		rq_pages[RPCSVC_MAXPAGES];
 	struct page *		*rq_respages;	/* points into rq_pages */
-	int			rq_resused;	/* number of pages used for result */
 	struct page *		*rq_next_page; /* next reply page to use */
 
 	struct kvec		rq_vec[RPCSVC_MAXPAGES]; /* generally useful.. */
-- 
1.7.9.5

