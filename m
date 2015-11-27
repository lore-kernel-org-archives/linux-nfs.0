Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from n9-59.mail.139.com ([221.176.9.59]:51104 "EHLO
	n9-59.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757AbbK0Dpn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 22:45:43 -0500
From: Wei Tang <tangwei@cmss.chinamobile.com>
To: bfields@fieldses.org, jlayton@poochiereds.net
Cc: linux-nfs@vger.kernel.org, Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] nfsd: ERROR: do not initialise statics to 0
Date: Fri, 27 Nov 2015 11:35:39 +0800
Message-Id: <1448595339-6234-1-git-send-email-tangwei@cmss.chinamobile.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch fixes the checkpatch.pl error to nfssvc.c:

ERROR: do not initialise statics to 0

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 fs/nfsd/nfssvc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ad4e237..0809dee 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -206,7 +206,7 @@ static int nfsd_init_socks(struct net *net)
 	return 0;
 }
 
-static int nfsd_users = 0;
+static int nfsd_users;
 
 static int nfsd_startup_generic(int nrservs)
 {
-- 
1.9.1


