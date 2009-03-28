From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 38/47] nfsd41: Remember the auth flavor to use for callbacks
Date: Sat, 28 Mar 2009 11:34:29 +0300
Message-ID: <1238229269-11454-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:19282 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756414AbZC1Ieh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:34:37 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
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
index ef1e372..eb3d0dc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1307,6 +1307,7 @@ out_new:
 	copy_verf(new, &verf);
 	copy_cred(&new->cl_cred, &rqstp->rq_cred);
 	new->cl_addr = ip_addr;
+	new->cl_flavor = rqstp->rq_flavor;
 	gen_clid(new);
 	gen_confirm(new);
 	add_to_unconfirmed(new, strhashval);
-- 
1.6.2.1

