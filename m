From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/13] NFSD: Add helper functions for __write_ports()
Date: Wed, 05 Nov 2008 12:28:44 -0500
Message-ID: <20081105172844.7330.9873.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36951 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbYKERaU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:20 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  I'd like to refactor __write_ports() to make it easier to
understand and maintain.  Introduce a set of helper functions to
handle the details of the __write_ports() function.

New helpers are not used yet.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |  110 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 110 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5c75f8a..0e64d92 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -879,6 +879,116 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 	return rv;
 }
 
+/*
+ * Zero-length write.  Return a list of NFSD's current listener
+ * transports.
+ */
+static ssize_t __write_ports_names(char *buf, size_t size)
+{
+	if (!nfsd_serv)
+		return 0;
+	return svc_xprt_names(nfsd_serv, buf, 0);
+}
+
+/*
+ * A single 'fd' number was written, in which case it must be for
+ * a socket of a supported family/protocol, and we use it as an
+ * nfsd listener.
+ */
+static ssize_t __write_ports_addfd(char *buf, size_t size)
+{
+	char *mesg = buf;
+	int fd, err;
+
+	err = get_int(&mesg, &fd);
+	if (err || fd < 0)
+		return -EINVAL;
+
+	err = nfsd_create_serv();
+	if (err)
+		return err;
+
+	err = svc_addsock(nfsd_serv, fd, buf);
+	if (err < 0)
+		return err;
+
+	err = lockd_up();
+	if (err < 0)
+		svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
+
+	/* Decrease the count, but don't shut down the the service */
+	nfsd_serv->sv_nrthreads--;
+
+	return err < 0 ? err : 0;
+}
+
+/*
+ * A '-' followed by the 'name' of a socket means we close the socket.
+ */
+static ssize_t __write_ports_delfd(char *buf, size_t size)
+{
+	char *toclose;
+	int len = 0;
+
+	toclose = kstrdup(buf + 1, GFP_KERNEL);
+	if (!toclose)
+		return -ENOMEM;
+
+	if (nfsd_serv)
+		len = svc_sock_names(buf, nfsd_serv, toclose);
+	if (len >= 0)
+		lockd_down();
+
+	kfree(toclose);
+	return len;
+}
+
+/*
+ * A transport listener is added by writing it's transport name and
+ * a port number
+ */
+static ssize_t __write_ports_addxprt(char *buf, size_t size,
+				     char *transport, unsigned short port)
+{
+	int err;
+
+	err = nfsd_create_serv();
+	if (err)
+		return err;
+
+	err = svc_create_xprt(nfsd_serv, transport, port, SVC_SOCK_ANONYMOUS);
+	if (err == -ENOENT)
+		/* Give a reasonable perror msg for
+		 * bad transport string */
+		err = -EPROTONOSUPPORT;
+
+	return err < 0 ? err : 0;
+}
+
+/*
+ * A transport listener is removed by writing a "-", it's transport
+ * name, and it's port number
+ */
+static ssize_t __write_ports_delxprt(char *buf, size_t size,
+				     char *transport, int port)
+{
+	struct svc_xprt *xprt;
+	int err = -EINVAL;
+
+	if (port == 0 || nfsd_serv == NULL)
+		return err;
+
+	xprt = svc_find_xprt(nfsd_serv, transport, AF_UNSPEC, port);
+	if (xprt) {
+		svc_close_xprt(xprt);
+		svc_xprt_put(xprt);
+		err = 0;
+	} else
+		err = -ENOTCONN;
+
+	return err < 0 ? err : 0;
+}
+
 static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 {
 	if (size == 0) {

