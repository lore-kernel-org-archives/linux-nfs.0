From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] showmount: support querying IPv6 servers
Date: Tue, 05 Aug 2008 14:13:09 -0400
Message-ID: <20080805181309.23104.61543.stgit@manray.1015granger.net>
References: <20080805180004.23104.29661.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17721 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761234AbYHESNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:13:44 -0400
Received: from rgmgw1.us.oracle.com (rgmgw1.us.oracle.com [138.1.186.110])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m75IDgOO025708
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:43 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rgmgw1.us.oracle.com (Switch-3.2.4/Switch-3.2.4) with ESMTP id m75IDfIv005563
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:42 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75ID9CW023273
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 14:13:09 -0400
In-Reply-To: <20080805180004.23104.29661.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a version of nfs_get_mount_client() that supports AF_INET6 and
AF_INET server addresses.  If the TI-RPC library is not available when
the showmount command is built, fall back to the legacy RPC user-space
API.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 4853c19..046b59e 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -50,6 +50,13 @@ static int	aflag = 0;
 static int	dflag = 0;
 static int	eflag = 0;
 
+static const char *nfs_sm_pgmtbl[] = {
+	"showmount",
+	"mount",
+	"mountd",
+	NULL,
+};
+
 static struct option longopts[] =
 {
 	{ "all", 0, 0, 'a' },
@@ -78,6 +85,33 @@ static void usage(FILE *fp, int n)
 	exit(n);
 }
 
+#ifdef HAVE_CLNT_CREATE
+
+/*
+ * Generate an RPC client handle connected to the mountd service
+ * at @hostname, or die trying.
+ *
+ * Supports both AF_INET and AF_INET6 server addresses.
+ */
+static CLIENT *nfs_get_mount_client(const char *hostname)
+{
+	rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, nfs_sm_pgmtbl);
+	CLIENT *client;
+
+	client = clnt_create(hostname, program, MOUNTVERS, "tcp");
+	if (client)
+		return client;
+
+	client = clnt_create(hostname, program, MOUNTVERS, "udp");
+	if (client)
+		return client;
+
+	clnt_pcreateerror("clnt_create");
+	exit(1);
+}
+
+#else	/* HAVE_CLNT_CREATE */
+
 /*
  *  Perform a non-blocking connect on the socket fd.
  *
@@ -213,6 +247,8 @@ static CLIENT *nfs_get_mount_client(const char *hostname)
 	return mclient;
 }
 
+#endif	/* HAVE_CLNT_CREATE */
+
 int main(int argc, char **argv)
 {
 	char hostname_buf[MAXHOSTLEN];

