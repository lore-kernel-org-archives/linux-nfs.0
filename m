Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from n9-44.mail.139.com ([221.176.9.44]:33091 "EHLO
	n9-44.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692AbbK0CNX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 21:13:23 -0500
From: Wei Tang <tangwei@cmss.chinamobile.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] nfs: ERROR: do not initialise statics to 0
Date: Fri, 27 Nov 2015 10:03:47 +0800
Message-Id: <1448589827-1960-1-git-send-email-tangwei@cmss.chinamobile.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch fixes the checkpatch.pl error to nfs4sysctl.c:

ERROR: do not initialise statics to 0

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 fs/nfs/nfs4sysctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4sysctl.c b/fs/nfs/nfs4sysctl.c
index 0fbd3ab..8693d77 100644
--- a/fs/nfs/nfs4sysctl.c
+++ b/fs/nfs/nfs4sysctl.c
@@ -12,7 +12,7 @@
 #include "nfs4idmap.h"
 #include "callback.h"
 
-static const int nfs_set_port_min = 0;
+static const int nfs_set_port_min;
 static const int nfs_set_port_max = 65535;
 static struct ctl_table_header *nfs4_callback_sysctl_table;
 
-- 
1.9.1


