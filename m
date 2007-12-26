From: James Morris <jmorris@namei.org>
Subject: [PATCH] NFS: add newline to kernel warning message in auth_gss code
Date: Wed, 26 Dec 2007 11:20:43 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0712261117290.16520@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:40662 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751183AbXLZAVD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Dec 2007 19:21:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add newline to kernel warning message in gss_create().

Signed-off-by: James Morris <jmorris@namei.org>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index a6e57d1..1f2d85e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -625,7 +625,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	err = -EINVAL;
 	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
 	if (!gss_auth->mech) {
-		printk(KERN_WARNING "%s: Pseudoflavor %d not found!",
+		printk(KERN_WARNING "%s: Pseudoflavor %d not found!\n",
 				__FUNCTION__, flavor);
 		goto err_free;
 	}
-- 
1.5.3.7


