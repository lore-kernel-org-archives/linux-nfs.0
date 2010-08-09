Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756202Ab0HILvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Aug 2010 07:51:31 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: Use kernel DNS resolver
To: torvalds@osdl.org, akpm@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, smfrench@gmail.com,
        linux-kernel@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>
Date: Mon, 09 Aug 2010 12:50:46 +0100
Message-ID: <20100809115046.1461.7584.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

Use the kernel DNS resolver to translate hostnames to IP addresses.  Create a
new config option to choose between the legacy DNS resolver and the new
resolver.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/Kconfig       |   16 ++++++++++++++++
 fs/nfs/dns_resolve.c |   24 ++++++++++++++++++++++++
 fs/nfs/dns_resolve.h |   12 ++++++++++++
 3 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index cc1bb33..c5bbdca 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -100,3 +100,19 @@ config NFS_FSCACHE
 	help
 	  Say Y here if you want NFS data to be cached locally on disc through
 	  the general filesystem cache manager
+
+config NFS_USE_LEGACY_DNS
+	bool "Use the legacy NFS DNS resolver"
+	depends on NFS_V4
+	help
+	  The kernel now provides a method for translating a host name into an
+	  IP address.  Select Y here if you would rather use your own DNS
+	  resolver script.
+
+	  If unsure, say N
+
+config NFS_USE_KERNEL_DNS
+	bool
+	depends on NFS_V4 && !NFS_USE_LEGACY_DNS
+	select DNS_RESOLVER
+	default y
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 76fd235..dba50a5 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -6,6 +6,29 @@
  * Resolves DNS hostnames into valid ip addresses
  */
 
+#ifdef CONFIG_NFS_USE_KERNEL_DNS
+
+#include <linux/sunrpc/clnt.h>
+#include <linux/dns_resolver.h>
+
+ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
+		struct sockaddr *sa, size_t salen)
+{
+	ssize_t ret;
+	char *ip_addr = NULL;
+	int ip_len;
+
+	ip_len = dns_query(NULL, name, namelen, NULL, &ip_addr, NULL);
+	if (ip_len > 0)
+		ret = rpc_pton(ip_addr, ip_len, sa, salen);
+	else
+		ret = -ESRCH;
+	kfree(ip_addr);
+	return ret;
+}
+
+#else
+
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <linux/kmod.h>
@@ -346,3 +369,4 @@ void nfs_dns_resolver_destroy(void)
 	nfs_cache_unregister(&nfs_dns_resolve);
 }
 
+#endif
diff --git a/fs/nfs/dns_resolve.h b/fs/nfs/dns_resolve.h
index a3f0938..199bb55 100644
--- a/fs/nfs/dns_resolve.h
+++ b/fs/nfs/dns_resolve.h
@@ -6,8 +6,20 @@
 
 #define NFS_DNS_HOSTNAME_MAXLEN	(128)
 
+
+#ifdef CONFIG_NFS_USE_KERNEL_DNS
+static inline int nfs_dns_resolver_init(void)
+{
+	return 0;
+}
+
+static inline void nfs_dns_resolver_destroy(void)
+{}
+#else
 extern int nfs_dns_resolver_init(void);
 extern void nfs_dns_resolver_destroy(void);
+#endif
+
 extern ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
 		struct sockaddr *sa, size_t salen);
 

