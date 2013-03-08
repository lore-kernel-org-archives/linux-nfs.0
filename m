Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f171.google.com ([209.85.210.171]:51680 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab3CHTrZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:47:25 -0500
Received: by mail-ia0-f171.google.com with SMTP id z13so1841706iaz.16
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:47:25 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/11] gssd: Fix whitespace nits
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:47:23 -0500
Message-ID: <20130308194723.5656.72933.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd_proc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index c17ab3b..6b5e90e 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -169,7 +169,7 @@ sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
 {
 	socklen_t		addrlen;
 	int			err;
-	char 			*hostname;
+	char			*hostname;
 	char			hbuf[NI_MAXHOST];
 
 	switch (sa->sa_family) {
@@ -708,7 +708,7 @@ out_err:
 
 /*
  * If the port isn't already set, do an rpcbind query to the remote server
- * using the program and version and get the port. 
+ * using the program and version and get the port.
  *
  * Newer kernels send the value of the port= mount option in the "info"
  * file for the upcall or '0' for NFSv2/3. For NFSv4 it sends the value
@@ -1013,7 +1013,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 					printerr(0, "ERROR: No credentials found "
 						 "for connection to server %s\n",
 						 clp->servername);
-						goto out_return_error;
+					goto out_return_error;
 				}
 				for (ccname = credlist; ccname && *ccname; ccname++) {
 					gssd_setup_krb5_machine_gss_ccache(*ccname);
@@ -1023,12 +1023,12 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 						/* Success! */
 						success++;
 						break;
-					} 
+					}
 					printerr(2, "WARNING: Failed to create machine krb5 context "
 						 "with credentials cache %s for server %s\n",
 						 *ccname, clp->servername);
 				}
-				gssd_free_krb5_machine_cred_list(credlist);			
+				gssd_free_krb5_machine_cred_list(credlist);
 				if (!success) {
 					if(nocache == 0) {
 						nocache++;
@@ -1225,6 +1225,6 @@ out:
 	free(enctypes);
 	free(target);
 	free(service);
-	return;	
+	return;
 }
 

