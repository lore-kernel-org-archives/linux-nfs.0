From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: handle interface identifiers in incoming IPv6
	addresses
Date: Mon, 23 Jun 2008 12:37:01 -0400
Message-ID: <20080623163700.10539.19275.stgit@ellison.1015granger.net>
References: <20080623163129.10539.15565.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:47525 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755061AbYFWQh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2008 12:37:27 -0400
In-Reply-To: <20080623163129.10539.15565.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support in the kernel NFS client's address parser for interface
identifiers.

IPv6 link-local addresses require an additional "interface identifier",
which is a network device name or an integer that indexes the array of
local network interfaces.  They are suffixed to the address with a '%'.
For example:

	fe80::215:c5ff:fe3b:e1b2%2

indicates an interface index of 2.  Or

	fe80::215:c5ff:fe3b:e1b2%eth0

indicates that requests should be routed through the eth0 device.
Without the interface ID, link-local addresses are not usable for NFS.

Both the kernel NFS client mount option parser and the mount.nfs command
can take either form.  The mount.nfs command always passes the address
through getnameinfo(3), which usually re-writes interface indices as
device names.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   41 ++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 40 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 225b14c..1736268 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -47,6 +47,7 @@
 #include <linux/inet.h>
 #include <linux/in6.h>
 #include <net/ipv6.h>
+#include <linux/netdevice.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
@@ -722,12 +723,48 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
 	*addr_len = 0;
 }
 
+#define IPV6_SCOPE_DELIMITER	'%'
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
+				    const char *delim,
+				    struct sockaddr_in6 *sin6)
+{
+	char *p;
+	size_t len;
+
+	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
+		return ;
+	if (*delim != IPV6_SCOPE_DELIMITER)
+		return;
+
+	len = (string + str_len) - delim - 1;
+	p = kstrndup(delim + 1, len, GFP_KERNEL);
+	if (p) {
+		unsigned long scope_id = 0;
+		struct net_device *dev;
+
+		dev = dev_get_by_name(&init_net, p);
+		if (dev != NULL) {
+			scope_id = dev->ifindex;
+			dev_put(dev);
+		} else {
+			/* scope_id is set to zero on error */
+			strict_strtoul(p, 10, &scope_id);
+		}
+
+		kfree(p);
+		sin6->sin6_scope_id = scope_id;
+		dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
+	}
+}
+
 static void nfs_parse_ipv6_address(char *string, size_t str_len,
 				   struct sockaddr *sap, size_t *addr_len)
 {
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
+	const char *delim;
 
 	if (str_len <= INET6_ADDRSTRLEN) {
 		dfprintk(MOUNT, "NFS: parsing IPv6 address %*s\n",
@@ -735,8 +772,10 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
 
 		sin6->sin6_family = AF_INET6;
 		*addr_len = sizeof(*sin6);
-		if (in6_pton(string, str_len, addr, '\0', NULL))
+		if (in6_pton(string, str_len, addr, IPV6_SCOPE_DELIMITER, &delim)) {
+			nfs_parse_ipv6_scope_id(string, str_len, delim, sin6);
 			return;
+		}
 	}
 
 	sap->sa_family = AF_UNSPEC;

