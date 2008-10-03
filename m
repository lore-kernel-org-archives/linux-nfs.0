From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] lockd: Add helper to sanity check incoming NOTIFY requests
Date: Fri, 03 Oct 2008 12:50:44 -0400
Message-ID: <20081003165043.10198.17650.stgit@ingres.1015granger.net>
References: <20081003162856.10198.20451.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55101 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbYJCQwG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 12:52:06 -0400
In-Reply-To: <20081003162856.10198.20451.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd accepts SM_NOTIFY calls only from a privileged process on the
local system.  If lockd uses an AF_INET6 listener, the sender's address
(ie the local rpc.statd) will be the IPv6 loopback address, not the
IPv4 loopback address.

Make sure the privilege test in nlmsvc_proc_sm_notify() and
nlm4svc_proc_sm_notify() works for both AF_INET and AF_INET6 family
addresses by refactoring the test into a helper and adding support for
IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc4proc.c         |    6 ++----
 fs/lockd/svcproc.c          |    6 ++----
 include/linux/lockd/lockd.h |   41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 45 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 89eb6f9..1ca972d 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -432,11 +432,9 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 {
 	struct sockaddr_in	saddr;
 
-	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
-
 	dprintk("lockd: SM_NOTIFY     called\n");
-	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
-	 || ntohs(saddr.sin_port) >= 1024) {
+
+	if (!nlm_privileged_requester(rqstp)) {
 		char buf[RPC_MAX_ADDRBUFLEN];
 		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
 				svc_print_addr(rqstp, buf, sizeof(buf)));
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 361aac2..212e4a3 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -464,11 +464,9 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 {
 	struct sockaddr_in	saddr;
 
-	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
-
 	dprintk("lockd: SM_NOTIFY     called\n");
-	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
-	 || ntohs(saddr.sin_port) >= 1024) {
+
+	if (!nlm_privileged_requester(rqstp)) {
 		char buf[RPC_MAX_ADDRBUFLEN];
 		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
 				svc_print_addr(rqstp, buf, sizeof(buf)));
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 165ef7a..888b92c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -277,6 +277,47 @@ static inline struct inode *nlmsvc_file_inode(struct nlm_file *file)
 	return file->f_file->f_path.dentry->d_inode;
 }
 
+static inline int __nlm_privileged_request4(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	return (sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK)) &&
+			(ntohs(sin->sin_port) < 1024);
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline int __nlm_privileged_request6(const struct sockaddr *sap)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	return (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LOOPBACK) &&
+			(ntohs(sin6->sin6_port) < 1024);
+}
+#else	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+static inline int __nlm_privileged_request6(const struct sockaddr *sap)
+{
+	return 0;
+}
+#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+
+/*
+ * Ensure incoming requests are from local privileged callers.
+ *
+ * Return TRUE if sender is local and is connecting via a privileged port;
+ * otherwise return FALSE.
+ */
+static inline int nlm_privileged_requester(const struct svc_rqst *rqstp)
+{
+	const struct sockaddr *sap = svc_addr(rqstp);
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		return __nlm_privileged_request4(sap);
+	case AF_INET6:
+		return __nlm_privileged_request6(sap);
+	default:
+		return 0;
+	}
+}
+
 static inline int __nlm_cmp_addr4(const struct sockaddr *sap1,
 				  const struct sockaddr *sap2)
 {

