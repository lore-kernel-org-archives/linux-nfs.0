Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:22210 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198Ab0KGVWx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Nov 2010 16:22:53 -0500
Date: Sun, 7 Nov 2010 22:11:34 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-kernel@vger.kernel.org
cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: [PATCH] SUNRPC: Simplify rpc_alloc_iostats by removing pointless
 local variable
Message-ID: <alpine.LNX.2.00.1011072205370.26247@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

We can simplify net/sunrpc/stats.c::rpc_alloc_iostats() a bit by getting 
rid of the unneeded local variable 'new'.


Please CC me on replies.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 stats.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git 
a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index f71a731..80df89d 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -115,9 +115,7 @@ EXPORT_SYMBOL_GPL(svc_seq_show);
  */
 struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt)
 {
-	struct rpc_iostats *new;
-	new = kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
-	return new;
+	return kcalloc(clnt->cl_maxproc, sizeof(struct rpc_iostats), GFP_KERNEL);
 }
 EXPORT_SYMBOL_GPL(rpc_alloc_iostats);
 


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

