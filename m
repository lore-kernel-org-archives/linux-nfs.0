Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36734 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbbGUFJ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2015 01:09:27 -0400
Received: by pdjr16 with SMTP id r16so115152527pdj.3
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2015 22:09:27 -0700 (PDT)
Message-ID: <55ADD3FD.405@gmail.com>
Date: Tue, 21 Jul 2015 13:09:17 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH v3] nfsd: Add layouts checking in client_has_state()
References: <20150721095737.7411eb05@canb.auug.org.au>
In-Reply-To: <20150721095737.7411eb05@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Layout is a state resource, nfsd should check it too.

v2, drop unneeded updating in nfsd4_renew()
v3, fix compile error without CONFIG_NFSD_PNFS

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61dfb33..94a2980 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2241,6 +2241,9 @@ static bool client_has_state(struct nfs4_client *clp)
 	 * Also note we should probably be using this in 4.0 case too.
 	 */
 	return !list_empty(&clp->cl_openowners)
+#ifdef CONFIG_NFSD_PNFS
+		|| !list_empty(&clp->cl_lo_states)
+#endif
 		|| !list_empty(&clp->cl_delegations)
 		|| !list_empty(&clp->cl_sessions);
 }
-- 
2.4.3

