From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] showmount command: support querying IPv6 servers
Date: Tue, 18 Nov 2008 14:29:51 -0500
Message-ID: <20081118192951.22516.16635.stgit@ingres.1015granger.net>
References: <20081118192711.22516.2801.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:43146 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbYKRTbB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Nov 2008 14:31:01 -0500
In-Reply-To: <20081118192711.22516.2801.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 7f5ad3a..17f7d87 100644
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

