From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] showmount command: move logic to acquire RPC client
	handle out of main()
Date: Tue, 18 Nov 2008 14:29:46 -0500
Message-ID: <20081118192945.22516.36750.stgit@ingres.1015granger.net>
References: <20081118192711.22516.2801.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:16266 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbYKRTa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Nov 2008 14:30:57 -0500
In-Reply-To: <20081118192711.22516.2801.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 5951033..7f5ad3a 100644
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

