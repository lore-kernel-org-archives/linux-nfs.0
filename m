Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33520 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab3DKNYT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2013 09:24:19 -0400
Received: by mail-pa0-f41.google.com with SMTP id kx1so909984pab.14
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2013 06:24:18 -0700 (PDT)
Message-ID: <5166B97D.60805@gmail.com>
Date: Thu, 11 Apr 2013 21:24:13 +0800
From: fanchaoting <tingchaofan@gmail.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfsd: remove some useless code
References: <5163AFED.5060902@cn.fujitsu.com>
In-Reply-To: <5163AFED.5060902@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


the "list_empty(&oo->oo_owner.so_stateids)" is aways true ,
so we remove it.

 Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e27430..e9f1d37 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3830,8 +3830,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			 * In the 4.0 case we need to keep the owners around a
 			 * little while to handle CLOSE replay.
 			 */
-			if (list_empty(&oo->oo_owner.so_stateids))
-				move_to_close_lru(oo, SVC_NET(rqstp));
+			move_to_close_lru(oo, SVC_NET(rqstp));
 		}
 	}
 out:
-- 
1.7.1
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



