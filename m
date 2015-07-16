Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35524 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbbGPCdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2015 22:33:50 -0400
Received: by pactm7 with SMTP id tm7so34393879pac.2
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2015 19:33:49 -0700 (PDT)
Message-ID: <55A71806.7020602@gmail.com>
Date: Thu, 16 Jul 2015 10:33:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH v2] nfsd: Add layouts checking in client_has_state()
References: <55A384B1.8030207@gmail.com> <55A384DD.1000800@gmail.com> <20150715150311.GA19616@fieldses.org> <55A7174D.3070007@gmail.com>
In-Reply-To: <55A7174D.3070007@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Layout is a state resource, nfsd should check it too.

v2,
drop unneeded updating in nfsd4_renew()

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61dfb33..00a0f8f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2241,6 +2241,7 @@ static bool client_has_state(struct nfs4_client *clp)
 	 * Also note we should probably be using this in 4.0 case too.
 	 */
 	return !list_empty(&clp->cl_openowners)
+		|| !list_empty(&clp->cl_lo_states)
 		|| !list_empty(&clp->cl_delegations)
 		|| !list_empty(&clp->cl_sessions);
 }
-- 
2.4.3

