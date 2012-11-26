Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29370 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab2KZWbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 17:31:32 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] gssd: Fix bugs in process_krb5_upcall
Date: Mon, 26 Nov 2012 17:31:20 -0500
Message-Id: <1353969081-17842-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 'tgtname' parameter is the _server_ name, not the service name.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 utils/gssd/gssd_proc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index ec251fa..b79e872 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -963,10 +963,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
 
 	if (tgtname) {
-		if (clp->servicename) {
-			free(clp->servicename);
-			clp->servicename = strdup(tgtname);
-		}
+		free(clp->servername);
+		clp->servername = strdup(tgtname);
 	}
 	token.length = 0;
 	token.value = NULL;
-- 
1.7.11.7

