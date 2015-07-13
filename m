Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35569 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbGMJ3p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:29:45 -0400
Received: by pactm7 with SMTP id tm7so204546853pac.2
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:29:45 -0700 (PDT)
Message-ID: <55A38505.6040405@gmail.com>
Date: Mon, 13 Jul 2015 17:29:41 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 02/14] nfsd: Add missing gen_confirm in nfsd4_setclientid()
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 294ac32e99 "nfsd: protect clid and verifier generation with client_lock"
have moved gen_confirm() to gen_clid().

After it, setclientid will return a bad reply with all zero confirms
after copy_clid().

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e0a4556..b1f84fc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3042,10 +3042,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	unconf = find_unconfirmed_client_by_name(&clname, nn);
 	if (unconf)
 		unhash_client_locked(unconf);
-	if (conf && same_verf(&conf->cl_verifier, &clverifier))
+	if (conf && same_verf(&conf->cl_verifier, &clverifier)) {
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
-	else /* case 4 (new client) or cases 2, 3 (client reboot): */
+		gen_confirm(new, nn);
+	} else /* case 4 (new client) or cases 2, 3 (client reboot): */
 		gen_clid(new, nn);
 	new->cl_minorversion = 0;
 	gen_callback(new, setclid, rqstp);
-- 
2.4.3

