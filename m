Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44230 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754376Ab3DXPnF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 11:43:05 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UV1qa-0005YJ-Gc
	for linux-nfs@vger.kernel.org; Wed, 24 Apr 2013 11:43:04 -0400
Date: Wed, 24 Apr 2013 11:43:04 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: better error return to indicate SSV non-support
Message-ID: <20130424154304.GF20275@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As 4.1 becomes less experimental and SSV still isn't implemented, we
have to admit it's not going to be, and return some sensible error
rather than just saying "our server's broken".  Discussion in the ietf
group hasn't turned up any objections to using NFS4ERR_ENC_ALG_UNSUPP
for that purpose.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

Committing for 3.10.--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e39bf53..a964a17 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1651,6 +1651,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	default:				/* checked by xdr code */
 		WARN_ON_ONCE(1);
 	case SP4_SSV:
+		return nfserr_encr_alg_unsupp;
 	case SP4_MACH_CRED:
 		return nfserr_serverfault;	/* no excuse :-/ */
 	}
-- 
1.7.9.5

