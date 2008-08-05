From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] showmount command: clean up error returns from
	connect_nb()
Date: Tue, 05 Aug 2008 14:12:47 -0400
Message-ID: <20080805181247.23104.23852.stgit@manray.1015granger.net>
References: <20080805180004.23104.29661.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17737 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761295AbYHESNp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:13:45 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m75IDhpt025758
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:43 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m75EQ1VH021524
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:42 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75IClsJ023217
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 14:12:47 -0400
In-Reply-To: <20080805180004.23104.29661.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up connect_nb() in the showmount command.

Sometimes it returns -1 on error, and sometimes a negative errno.  On error,
it should always return one of these or the other, not both.

Similar functions in other parts of nfs-utils return -1 on error, and set
errno; so let's do that here too.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index b6cea92..6acd7e6 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -83,7 +83,8 @@ static void usage(FILE *fp, int n)
  *  tout contains the timeout.  It will be modified to contain the time
  *  remaining (i.e. time provided - time elasped).
  *
- *  Returns 0 for success 
+ *  Returns zero on success; otherwise, -1 is returned and errno is set
+ *  to reflect the nature of the error.
  */
 static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval *tout)
 {
@@ -107,7 +108,7 @@ static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval *tout)
 	len = sizeof(struct sockaddr);
 	ret = connect(fd, (struct sockaddr *)addr, len);
 	if (ret < 0 && errno != EINPROGRESS) {
-		ret = -errno;
+		ret = -1;
 		goto done;
 	}
 
@@ -121,9 +122,8 @@ static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval *tout)
 	ret = select(fd + 1, NULL, &rset, NULL, tout);
 	if (ret <= 0) {
 		if (ret == 0)
-			ret = -ETIMEDOUT;
-		else
-			ret = -errno;
+			errno = ETIMEDOUT;
+		ret = -1;
 		goto done;
 	}
 
@@ -133,13 +133,15 @@ static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval *tout)
 		len = sizeof(ret);
 		status = getsockopt(fd, SOL_SOCKET, SO_ERROR, &ret, &len);
 		if (status < 0) {
-			ret = -errno;
+			ret = -1;
 			goto done;
 		}
 
 		/* Oops - something wrong with connect */
-		if (ret)
-			ret = -ret;
+		if (ret) {
+			errno = ret;
+			ret = -1;
+		}
 	}
 
 done:
@@ -179,10 +181,10 @@ static unsigned short getport(struct sockaddr_in *addr,
 		tout.tv_sec = TIMEOUT_TCP;
 
 		ret = connect_nb(sock, &saddr, &tout);
-		if (ret < 0) {
-			close(sock);
+		if (ret != 0) {
 			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 			rpc_createerr.cf_error.re_errno = errno;
+			close(sock);
 			return 0;
 		}
 		client = clnttcp_create(&saddr,

