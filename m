From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: remove unused field rq_reffh
Date: Fri, 4 Dec 2009 20:05:49 -0500
Message-ID: <20091205010549.GG22497@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41680 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757492AbZLEBEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 20:04:40 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NGj5p-0006X9-Mv
	for linux-nfs@vger.kernel.org; Fri, 04 Dec 2009 20:05:49 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ran across this while looking at the header files.  Anyone have any idea
what this was for?

--b.

commit a917c42f73799b0670854de2b31d9cc518f4540d
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Dec 4 18:29:33 2009 -0500

    nfsd: remove unused field rq_reffh
    
    This field is never referenced anywhere else.  I don't know what it was
    intended for.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index d1567d6..5a3085b 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -273,10 +273,6 @@ struct svc_rqst {
 	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
-	struct knfsd_fh *	rq_reffh;	/* Referrence filehandle, used to
-						 * determine what device number
-						 * to report (real or virtual)
-						 */
 	int			rq_splice_ok;   /* turned off in gss privacy
 						 * to prevent encrypting page
 						 * cache pages */
