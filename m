From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Use AF_INET6 NFSv4 callback listener only if IPv6 is
	built in
Date: Wed, 04 Feb 2009 11:51:34 -0500
Message-ID: <20090204164857.26771.31809.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:31563 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbZBDQwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 11:52:30 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apparently a lot of people need to disable IPv6 completely on their
distributor-built systems, and they do this by blacklisting the ipv6.ko
module.  If CONFIG_IPV6_MODULE is set but the module can't be loaded,
this causes the creation of the NFSv4 callback listener to fail.

As a workaround, change the callback service to use an AF_INET6 listener
only if IPv6 is built into the kernel.

This allows IPv6 NFS testing to continue, while supporting legacy IPv4
NFS as before.  In the meantime, we will pursue a long-term fix so that
the callback server will be able to handle this case correctly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Trond, here's what I'm thinking about for fixing the callback server
piece of the "unloadable ipv6.ko" problem.  Comments?

 fs/nfs/callback.c |   10 ++++++----
 fs/nfs/client.c   |    6 +++---
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 3e634f2..5d99335 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -43,13 +43,15 @@ static const int nfs_set_port_max = 65535;
 
 /*
  * If the kernel has IPv6 support available, always listen for
- * both AF_INET and AF_INET6 requests.
+ * both AF_INET and AF_INET6 requests.  To avoid breaking lockd
+ * if the ipv6 module was built but has been blacklisted, enable
+ * this only if IPv6 support is built into the kernel.
  */
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(CONFIG_IPV6)
 static const sa_family_t	nfs_callback_family = AF_INET6;
-#else
+#else	/* CONFIG_IPV6 */
 static const sa_family_t	nfs_callback_family = AF_INET;
-#endif
+#endif	/* CONFIG_IPV6 */
 
 static int param_set_port(const char *val, struct kernel_param *kp)
 {
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9b728f3..a230c35 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -223,7 +223,7 @@ void nfs_put_client(struct nfs_client *clp)
 	}
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#ifdef CONFIG_IPV6
 static const struct in6_addr *nfs_map_ipv4_addr(const struct sockaddr *sa, struct in6_addr *addr_mapped)
 {
 	switch (sa->sa_family) {
@@ -255,7 +255,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 	}
 	return 0;
 }
-#else
+#else	/* CONFIG_IPV6 */
 static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
 				 const struct sockaddr_in *sa2)
 {
@@ -270,7 +270,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
 			(const struct sockaddr_in *)sa2);
 }
-#endif
+#endif	/* CONFIG_IPV6 */
 
 /*
  * Find a client by IP address and protocol version

