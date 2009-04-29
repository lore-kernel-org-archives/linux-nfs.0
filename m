From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 6/7] gssd: process target= attribute in new upcall
Date: Wed, 29 Apr 2009 17:56:41 -0400
Message-ID: <20090429215641.25811.65865.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47728 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756351AbZD2V4l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:41 -0400
In-Reply-To: <20090429214300.25811.81332.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

Add processing of the "target=" attribute in the new gssd upcall.
Information in this field is used to construct the gss service name
of the server for which gssd will create a context .

This, along with the next patch handling "service=", is needed
for callback security.

For Kerberos, the NFS client will use a service principal present
in its keytab during authentication of the SETCLIENT_ID operation.
When establishing the context for the callback, the gssd on the
NFS server will attempt to authenticate the callback against the
principal name used by the client.

Note: An NFS client machine must have a keytab for the callback
authentication to succeed.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd_proc.c |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 2fc26b4..12eb5b3 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -885,7 +885,7 @@ int create_auth_rpc_client(struct clnt_info *clp,
  * context on behalf of the kernel
  */
 static void
-process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd)
+process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname)
 {
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
@@ -898,6 +898,12 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd)
 
 	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
 
+	if (tgtname) {
+		if (clp->servicename) {
+			free(clp->servicename);
+			clp->servicename = strdup(tgtname);
+		}
+	}
 	token.length = 0;
 	token.value = NULL;
 	memset(&pd, 0, sizeof(struct authgss_private_data));
@@ -1056,7 +1062,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 		return;
 	}
 
-	return process_krb5_upcall(clp, uid, clp->krb5_fd);
+	return process_krb5_upcall(clp, uid, clp->krb5_fd, NULL);
 }
 
 void
@@ -1081,6 +1087,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 	int			lbuflen = 0;
 	char			*p;
 	char			*mech = NULL;
+	char			*target = NULL;
 
 	printerr(1, "handling gssd upcall (%s)\n", clp->dirname);
 
@@ -1124,9 +1131,21 @@ handle_gssd_upcall(struct clnt_info *clp)
 		goto out;
 	}
 
+	/* read target name */
+	if ((p = strstr(lbuf, "target=")) != NULL) {
+		target = malloc(lbuflen);
+		if (!target)
+			goto out;
+		if (sscanf(p, "target=%s", target) != 1) {
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				    "failed to parse target name "
+				    "in upcall string '%s'\n", lbuf);
+			goto out;
+		}
+	}
 
 	if (strcmp(mech, "krb5") == 0)
-		process_krb5_upcall(clp, uid, clp->gssd_fd);
+		process_krb5_upcall(clp, uid, clp->gssd_fd, target);
 	else if (strcmp(mech, "spkm3") == 0)
 		process_spkm3_upcall(clp, uid, clp->gssd_fd);
 	else
@@ -1136,6 +1155,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 out:
 	free(lbuf);
 	free(mech);
+	free(target);
 	return;	
 }
 

