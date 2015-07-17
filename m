Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33884 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbbGQXdg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jul 2015 19:33:36 -0400
Received: by pacan13 with SMTP id an13so68365827pac.1
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2015 16:33:35 -0700 (PDT)
Message-ID: <55A990CB.6020201@gmail.com>
Date: Sat, 18 Jul 2015 07:33:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] nfsd: New counter for generating client confirm verifier
References: <55A384B1.8030207@gmail.com>	<55A38505.6040405@gmail.com>	<20150715204748.GA21669@fieldses.org>	<20150715204950.GB21669@fieldses.org>	<55A726A0.5090907@gmail.com>	<55A72A1F.7060507@gmail.com>	<20150717155846.GC6263@fieldses.org> <20150717134243.7bf809fa@tlielax.poochiereds.net>
In-Reply-To: <20150717134243.7bf809fa@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If using clientid_counter, gen_confirm will generate same verifier
in one second.

A new counter for client confirm verifier make sure gen_confirm
generating different each calling for the same clientid.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/netns.h     | 1 +
 fs/nfsd/nfs4state.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index ea6749a..d8b16c2 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -110,6 +110,7 @@ struct nfsd_net {
 	unsigned int max_connections;
 
 	u32 clientid_counter;
+	u32 clverifier_counter;
 
 	struct svc_serv *nfsd_serv;
 };
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61dfb33..5a64757e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1894,7 +1894,7 @@ static void gen_confirm(struct nfs4_client *clp, struct nfsd_net *nn)
 	 * __force to keep sparse happy
 	 */
 	verf[0] = (__force __be32)get_seconds();
-	verf[1] = (__force __be32)nn->clientid_counter;
+	verf[1] = (__force __be32)nn->clverifier_counter++;
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
-- 
2.4.3

