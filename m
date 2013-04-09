Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:49824 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752220Ab3DJGFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 02:05:34 -0400
Message-ID: <5163AFED.5060902@cn.fujitsu.com>
Date: Tue, 09 Apr 2013 14:06:37 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd: remove some useless code
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
