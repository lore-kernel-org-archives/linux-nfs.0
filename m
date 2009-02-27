From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] showmount command: remove legacy RPC logic
Date: Fri, 27 Feb 2009 15:05:29 -0500
Message-ID: <20090227200529.11301.88197.stgit@ingres.1015granger.net>
References: <20090227200511.11301.33720.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:21243 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbZB0UGx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 15:06:53 -0500
In-Reply-To: <20090227200511.11301.33720.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Turns out both legacy RPC and TI-RPC have a clnt_create(3) API.  So there's
really no need to keep the old open-coded transport logic around.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |  141 -------------------------------------------
 1 files changed, 0 insertions(+), 141 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 2695c51..418e8b9 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -78,8 +78,6 @@ static void usage(FILE *fp, int n)
 	exit(n);
 }
 
-#ifdef HAVE_CLNT_CREATE
-
 static const char *nfs_sm_pgmtbl[] = {
 	"showmount",
 	"mount",
@@ -110,145 +108,6 @@ static CLIENT *nfs_get_mount_client(const char *hostname)
 	exit(1);
 }
 
-#else	/* HAVE_CLNT_CREATE */
-
-/*
- *  Perform a non-blocking connect on the socket fd.
- *
- *  tout contains the timeout.  It will be modified to contain the time
- *  remaining (i.e. time provided - time elasped).
- *
- *  Returns zero on success; otherwise, -1 is returned and errno is set
- *  to reflect the nature of the error.
- */
-static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval *tout)
-{
-	int flags, ret;
-	socklen_t len;
-	fd_set rset;
-
-	flags = fcntl(fd, F_GETFL, 0);
-	if (flags < 0)
-		return -1;
-
-	ret = fcntl(fd, F_SETFL, flags | O_NONBLOCK);
-	if (ret < 0)
-		return -1;
-
-	/*
-	 * From here on subsequent sys calls could change errno so
-	 * we set ret = -errno to capture it in case we decide to
-	 * use it later.
-	 */
-	len = sizeof(struct sockaddr);
-	ret = connect(fd, (struct sockaddr *)addr, len);
-	if (ret < 0 && errno != EINPROGRESS) {
-		ret = -1;
-		goto done;
-	}
-
-	if (ret == 0)
-		goto done;
-
-	/* now wait */
-	FD_ZERO(&rset);
-	FD_SET(fd, &rset);
-
-	ret = select(fd + 1, NULL, &rset, NULL, tout);
-	if (ret <= 0) {
-		if (ret == 0)
-			errno = ETIMEDOUT;
-		ret = -1;
-		goto done;
-	}
-
-	if (FD_ISSET(fd, &rset)) {
-		int status;
-
-		len = sizeof(ret);
-		status = getsockopt(fd, SOL_SOCKET, SO_ERROR, &ret, &len);
-		if (status < 0) {
-			ret = -1;
-			goto done;
-		}
-
-		/* Oops - something wrong with connect */
-		if (ret != 0) {
-			errno = ret;
-			ret = -1;
-		}
-	}
-
-done:
-	fcntl(fd, F_SETFL, flags);
-	return ret;
-}
-
-/*
- * Generate an RPC client handle connected to the mountd service
- * at @hostname, or die trying.
- *
- * Supports only AF_INET server addresses.
- */
-static CLIENT *nfs_get_mount_client(const char *hostname)
-{
-	struct hostent *hp;
-	struct sockaddr_in server_addr;
-	struct timeval pertry_timeout;
-	CLIENT *mclient = NULL;
-	int ret, msock;
-
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
-	msock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
-	if (msock != -1) {
-		if (nfs_getport_ping((struct sockaddr *)&server_addr,
-					sizeof(server_addr), MOUNTPROG,
-					MOUNTVERS, IPPROTO_TCP)) {
-			ret = connect_nb(msock, &server_addr, 0);
-			if (ret == 0)
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
-
-	return mclient;
-}
-
-#endif	/* HAVE_CLNT_CREATE */
-
 int main(int argc, char **argv)
 {
 	char hostname_buf[MAXHOSTLEN];

