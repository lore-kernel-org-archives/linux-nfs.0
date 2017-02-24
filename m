Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:35122 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdBXARN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 19:17:13 -0500
Received: by mail-wr0-f175.google.com with SMTP id g10so1848296wrg.2
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2017 16:16:23 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] fs: nfsd: remove superfluous KERN_INFO
Date: Fri, 24 Feb 2017 01:15:55 +0100
Message-Id: <1487895356-24307-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

dprintk already provides a KERN_* prefix; this KERN_INFO just shows up
as some odd characters in the output.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a0dee8ae9f97..df86e888f833 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2281,7 +2281,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
 out_err:
 	conn->cb_addr.ss_family = AF_UNSPEC;
 	conn->cb_addrlen = 0;
-	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
+	dprintk("NFSD: this client (clientid %08x/%08x) "
 		"will not receive delegations\n",
 		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
 
-- 
2.1.4

