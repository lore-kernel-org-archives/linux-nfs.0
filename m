Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33810 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932763AbcBZOgy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Feb 2016 09:36:54 -0500
Received: by mail-pa0-f52.google.com with SMTP id fy10so51974609pac.1
        for <linux-nfs@vger.kernel.org>; Fri, 26 Feb 2016 06:36:54 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfsd: Fix a memory leak when meeting unsupported
 state_protect_how4
Message-ID: <56D062FA.7090605@gmail.com>
Date: Fri, 26 Feb 2016 22:36:42 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remember free allocated client when meeting unsupported state protect how.

Fixes: 50c7b948adbd ("nfsd: minor consolidation of mach_cred handling code")
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c484a2b..9d20c6a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2408,7 +2408,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	default:				/* checked by xdr code */
 		WARN_ON_ONCE(1);
 	case SP4_SSV:
-		return nfserr_encr_alg_unsupp;
+		status = nfserr_encr_alg_unsupp;
+		goto out_nolock;
 	}
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
-- 
2.5.0

