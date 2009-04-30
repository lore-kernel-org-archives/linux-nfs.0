From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 04/10] nfsd41: Remember the auth flavor to use for callbacks
Date: Fri,  1 May 2009 02:06:01 +0300
Message-ID: <1241132761-32494-1-git-send-email-bhalevy@panasas.com>
References: <49FA2D86.8060402@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16825 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756850AbZD3XGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:06:08 -0400
In-Reply-To: <49FA2D86.8060402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

The callbacks will be sent using the same authentication flavor that
was used during session creation.  We'll add code to remember the
principal in the case RPCSEC_GSS in a separate patch.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cc9705b..ad30039 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1284,6 +1284,7 @@ out_new:
 	copy_verf(new, &verf);
 	copy_cred(&new->cl_cred, &rqstp->rq_cred);
 	new->cl_addr = ip_addr;
+	new->cl_flavor = rqstp->rq_flavor;
 	gen_clid(new);
 	gen_confirm(new);
 	add_to_unconfirmed(new, strhashval);
-- 
1.6.2.1

