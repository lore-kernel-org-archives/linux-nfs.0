Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:57538 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbcGBGZH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jul 2016 02:25:07 -0400
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: jlayton@poochiereds.net, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 2/2] nfsd: remove extraneous KERN_INFO prefix
Date: Sat,  2 Jul 2016 08:24:48 +0200
Message-Id: <1467440688-8368-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

smatch complains about using KERN_INFO as a prefix when calling dprintk

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bc2173a..ba6b2df 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2226,7 +2226,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
 out_err:
 	conn->cb_addr.ss_family = AF_UNSPEC;
 	conn->cb_addrlen = 0;
-	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
+	dprintk("NFSD: this client (clientid %08x/%08x) "
 		"will not receive delegations\n",
 		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
 
-- 
2.7.4

