From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] showmount command: move logic to acquire RPC client
	handle out of main()
Date: Tue, 05 Aug 2008 14:13:03 -0400
Message-ID: <20080805181303.23104.85846.stgit@manray.1015granger.net>
References: <20080805180004.23104.29661.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17756 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760614AbYHESNq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:13:46 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m75IDiYu025802
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:44 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m75EQ1VJ021524
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:43 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75ID364023259
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 14:13:04 -0400
In-Reply-To: <20080805180004.23104.29661.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation to support IPv6 in the showmount command, extract the logic
that parses/acquires the target hostname and converts it into an RPC
client handle to contact the remote mountd service, and move it into its
own function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |  116 ++++++++++++++++++++++++-------------------
 1 files changed, 64 insertions(+), 52 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 6812277..4853c19 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -150,16 +150,75 @@ done:
 	return ret;
 }
 
+/*
+ * Generate an RPC client handle connected to the mountd service
+ * at @hostname, or die trying.
+ *
+ * Supports only AF_INET server addresses.
+ */
+static CLIENT *nfs_get_mount_client(const char *hostname)
+{
+	struct hostent *hp;
+	struct sockaddr_in server_addr;
+	struct timeval pertry_timeout;
+	CLIENT *mclient = NULL;
+	int ret, msock;
+
+	if (inet_aton(hostname, &server_addr.sin_addr)) {
+		server_addr.sin_family = AF_INET;
+	}
+	else {
+		if ((hp = gethostbyname(hostname)) == NULL) {
+			fprintf(stderr, "%s: can't get address for %s\n",
+				program_name, hostname);
+			exit(1);
+		}
+		server_addr.sin_family = AF_INET;
+		memcpy(&server_addr.sin_addr, hp->h_addr, hp->h_length);
+	}
+
+	msock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
+	if (msock != -1) {
+		if (nfs_getport_ping((struct sockaddr *)&server_addr,
+					sizeof(server_addr), MOUNTPROG,
+					MOUNTVERS, IPPROTO_TCP)) {
+			ret = connect_nb(msock, &server_addr, 0);
+			if (ret == 0)
+				mclient = clnttcp_create(&server_addr,
+						MOUNTPROG, MOUNTVERS, &msock,
+						0, 0);
+			else
+				close(msock);
+		} else
+			close(msock);
+	}
+
+	if (!mclient) {
+		if (nfs_getport_ping((struct sockaddr *)&server_addr,
+					sizeof(server_addr), MOUNTPROG,
+					MOUNTVERS, IPPROTO_UDP)) {
+			clnt_pcreateerror("showmount");
+			exit(1);
+		}
+		msock = RPC_ANYSOCK;
+		pertry_timeout.tv_sec = TIMEOUT_UDP;
+		pertry_timeout.tv_usec = 0;
+		if ((mclient = clntudp_create(&server_addr,
+		    MOUNTPROG, MOUNTVERS, pertry_timeout, &msock)) == NULL) {
+			clnt_pcreateerror("mount clntudp_create");
+			exit(1);
+		}
+	}
+
+	return mclient;
+}
+
 int main(int argc, char **argv)
 {
 	char hostname_buf[MAXHOSTLEN];
 	char *hostname;
 	enum clnt_stat clnt_stat;
-	struct hostent *hp;
-	struct sockaddr_in server_addr;
-	int ret, msock;
 	struct timeval total_timeout;
-	struct timeval pertry_timeout;
 	int c;
 	CLIENT *mclient;
 	groups grouplist;
@@ -231,54 +290,7 @@ int main(int argc, char **argv)
 		break;
 	}
 
-	if (inet_aton(hostname, &server_addr.sin_addr)) {
-		server_addr.sin_family = AF_INET;
-	}
-	else {
-		if ((hp = gethostbyname(hostname)) == NULL) {
-			fprintf(stderr, "%s: can't get address for %s\n",
-				program_name, hostname);
-			exit(1);
-		}
-		server_addr.sin_family = AF_INET;
-		memcpy(&server_addr.sin_addr, hp->h_addr, hp->h_length);
-	}
-
-	/* create mount deamon client */
-
-	mclient = NULL;
-	msock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
-	if (msock != -1) {
-		if (nfs_getport_ping((struct sockaddr *)&server_addr,
-					sizeof(server_addr), MOUNTPROG,
-					MOUNTVERS, IPPROTO_TCP)) {
-			ret = connect_nb(msock, &server_addr, 0);
-			if (ret == 0) /* success */
-				mclient = clnttcp_create(&server_addr,
-						MOUNTPROG, MOUNTVERS, &msock,
-						0, 0);
-			else
-				close(msock);
-		} else
-			close(msock);
-	}
-
-	if (!mclient) {
-		if (nfs_getport_ping((struct sockaddr *)&server_addr,
-					sizeof(server_addr), MOUNTPROG,
-					MOUNTVERS, IPPROTO_UDP)) {
-			clnt_pcreateerror("showmount");
-			exit(1);
-		}
-		msock = RPC_ANYSOCK;
-		pertry_timeout.tv_sec = TIMEOUT_UDP;
-		pertry_timeout.tv_usec = 0;
-		if ((mclient = clntudp_create(&server_addr,
-		    MOUNTPROG, MOUNTVERS, pertry_timeout, &msock)) == NULL) {
-			clnt_pcreateerror("mount clntudp_create");
-			exit(1);
-		}
-	}
+	mclient = nfs_get_mount_client(hostname);
 	mclient->cl_auth = authunix_create_default();
 	total_timeout.tv_sec = TOTAL_TIMEOUT;
 	total_timeout.tv_usec = 0;

