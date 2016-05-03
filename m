Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12158 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933002AbcECOqd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2016 10:46:33 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] gssd: no longer needed pid logic
Date: Tue, 3 May 2016 10:46:31 -0400
Message-ID: <1462286792-8889-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

with threads, we don't need to distinguish zero uid.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 utils/gssd/gssd_proc.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b19c595..afaaf9e 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -604,7 +604,6 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	gss_buffer_desc		token;
 	int			err, downcall_err = -EACCES;
 	OM_uint32		maj_stat, min_stat, lifetime_rec;
-	pid_t			pid, childpid = -1;
 	gss_name_t		gacceptor = GSS_C_NO_NAME;
 	gss_OID			mech;
 	gss_buffer_desc		acceptor  = {0};
@@ -702,11 +701,7 @@ out:
 	if (rpc_clnt)
 		clnt_destroy(rpc_clnt);
 
-	pid = getpid();
-	if (pid == childpid)
-		exit(0);
-	else
-		return;
+	return;
 
 out_return_error:
 	do_error_downcall(fd, uid, downcall_err);
-- 
1.8.3.1

