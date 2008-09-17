From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] lockd: Add helper to sanity check incoming NOTIFY
	requests
Date: Wed, 17 Sep 2008 11:17:57 -0500
Message-ID: <20080917161757.4963.82230.stgit@ellison.1015granger.net>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:21530 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002AbYIQQYQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:24:16 -0400
In-Reply-To: <20080917161337.4963.74674.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NLM performs a silly test to see that incoming NOTIFY requests are
relatively secure.  Make sure the test works for both AF_INET and AF_INET6
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc4proc.c         |    6 ++----
 fs/lockd/svcproc.c          |    6 ++----
 include/linux/lockd/lockd.h |   41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 45 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 9e1c751..6a5ef9f 100644
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
index fcb7998..62fcfdb 100644
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
index 075095f..409eab4 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -280,6 +280,47 @@ static inline struct inode *nlmsvc_file_inode(struct nlm_file *file)
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
+ * Ensure incoming requests are suitably "secure"
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

