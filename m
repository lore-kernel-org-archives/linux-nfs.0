Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759331Ab0HFS3a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 14:29:30 -0400
Message-ID: <4C5C54A3.1010206@netapp.com>
Date: Fri, 06 Aug 2010 14:29:55 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: David Howells <dhowells@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS use kernel DNS resolver
References: <1280970596.2865.28.camel@heimdal.trondhjem.org> <4C59D1A3.5030406@netapp.com> <13523.1281060342@redhat.com>
In-Reply-To: <13523.1281060342@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The patch is below.  Thanks!

Bryan




Use the kernel DNS resolver to translate hostnames to IP addresses.
Create a new config option to choose between the legacy DNS resolver and the
new resolver.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index a43d07e..10eebc5 100644
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
index 76fd235..7e5d3a9 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -6,6 +6,37 @@
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
+inline int nfs_dns_resolver_init(void)
+{
+	return 0;
+}
+
+inline void nfs_dns_resolver_destroy(void)
+{}
+
+#else
+
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <linux/kmod.h>
@@ -346,3 +377,4 @@ void nfs_dns_resolver_destroy(void)
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



On 08/05/2010 10:05 PM, David Howells wrote:
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
>> David, can you carry this as part of your 'generic DNS resolver'
>> patchset?
> 
> Probably.  Can you send me a copy of the patch?
> 
> David

