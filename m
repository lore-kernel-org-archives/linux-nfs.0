From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4
 referrals and migration
Date: Wed, 19 Aug 2009 19:51:56 -0400
Message-ID: <1250725916.12555.1.camel@heimdal.trondhjem.org>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1220 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784AbZHSXwB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:52:01 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNq3ni004839
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:52:03 -0700 (PDT)
In-Reply-To: <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-19 at 19:38 -0400, Trond Myklebust wrote:
> The NFSv4 and NFSv4.1 protocols both allow for the redirection of a client
> from one server to another in order to support filesystem migration and
> replication. For full protocol support, we need to add the ability to
> convert a DNS host name into an IP address that we can feed to the RPC
> client.
> 
> We'll reuse the sunrpc cache, now that it has been converted to work with
> rpc_pipefs.

Should I merge this too?

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS: Testcase for the DNS resolver

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/Kconfig           |   11 ++++++++++
 fs/nfs/Makefile          |    4 +++
 fs/nfs/cache_testcases.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/dns_resolve.c     |    1 +
 4 files changed, 69 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/cache_testcases.c


diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 2a77bc2..13fc471 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -101,3 +101,14 @@ config NFS_FSCACHE
 	help
 	  Say Y here if you want NFS data to be cached locally on disc through
 	  the general filesystem cache manager
+
+config NFS_CACHETEST
+	tristate "Test the NFS client DNS cache upcalls"
+	depends on NFS_FS
+	default N
+	help
+	  Choose M if you want to build a module that can be used to test
+	  the NFS client DNS cache upcall mechanism.
+
+	  Most people will want to say N
+
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index da7fda6..4fe5ac2 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -17,3 +17,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4namespace.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
+
+obj-$(CONFIG_NFS_CACHETEST) += nfs_cachetest.o
+nfs_cachetest-objs := cache_testcases.o
+
diff --git a/fs/nfs/cache_testcases.c b/fs/nfs/cache_testcases.c
new file mode 100644
index 0000000..2d8810a
--- /dev/null
+++ b/fs/nfs/cache_testcases.c
@@ -0,0 +1,53 @@
+/*
+ * linux/fs/nfs/cache_testcases.c
+ *
+ * Testcases for the NFS client cache upcalls
+ *
+ * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/sunrpc/clnt.h>
+
+#include "dns_resolve.h"
+
+static char hostname[NFS_DNS_HOSTNAME_MAXLEN] = "";
+module_param_string(hostname, hostname, sizeof(hostname), 0600);
+MODULE_PARM_DESC(hostname, "DNS hostname to look up");
+
+static int nfs_lookup_hostname(char *name)
+{
+	struct sockaddr_storage sa;
+	ssize_t salen;
+
+	if (!name || *name == '\0')
+		goto out;
+	salen = nfs_dns_resolve_name(name, strlen(name),
+			(struct sockaddr *)&sa, sizeof(sa));
+	if (salen > 0) {
+		char buf[INET6_ADDRSTRLEN+IPV6_SCOPE_ID_LEN+1];
+
+		rpc_ntop((struct sockaddr *)&sa, buf, sizeof(buf));
+		printk(KERN_NOTICE "%15s ", buf);
+	} else
+		printk(KERN_NOTICE "%15zd ", salen);
+	printk("%15s\n", name);
+out:
+	return 0;
+}
+
+static int nfs_dnstest_init(void)
+{
+	return nfs_lookup_hostname(hostname);
+}
+
+static void nfs_dnstest_exit(void)
+{
+}
+
+MODULE_AUTHOR("Trond Myklebust <Trond.Myklebust@netapp.com>");
+MODULE_LICENSE("GPL");
+
+module_init(nfs_dnstest_init)
+module_exit(nfs_dnstest_exit)
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index f4d54ba..572d453 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -322,6 +322,7 @@ ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
 		ret = -ESRCH;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
 
 int nfs_dns_resolver_init(void)
 {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
