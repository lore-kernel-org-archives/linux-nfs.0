Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from n9-41.mail.139.com ([221.176.9.41]:53526 "EHLO
	n9-41.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbLDIRG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Dec 2015 03:17:06 -0500
From: Wei Tang <tangwei@cmss.chinamobile.com>
To: bfields@fieldses.org, jlayton@poochiereds.net
Cc: linux-nfs@vger.kernel.org, Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH 2/2] nfsd: do not initialise statics to 0
Date: Fri,  4 Dec 2015 16:08:02 +0800
Message-Id: <1449216482-4246-1-git-send-email-tangwei@cmss.chinamobile.com>
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


