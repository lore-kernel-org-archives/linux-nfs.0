Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:32804 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751816AbeFETif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 15:38:35 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 1/2] Add check of clientaddr argument
Date: Tue, 5 Jun 2018 15:29:08 -0400
Message-ID: <20180605192909.27578-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the NFS client administrator supplies the clientaddr mount
option, it should be either a special value of either IPv4/IPv6
any address or one of the machine's network addresses. Otherwise,
warn the administrator about the use of an arbitrary value for
the clientaddr value.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
`
---
 utils/mount/network.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |  2 ++
 utils/mount/stropts.c | 24 ++++++++++++++++++++++--
 3 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index e490399..2a54f82 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -50,6 +50,8 @@
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
 #include <rpc/pmap_clnt.h>
+#include <net/if.h>
+#include <ifaddrs.h>
 
 #include "sockaddr.h"
 #include "xcommon.h"
@@ -1759,3 +1761,46 @@ int nfs_umount_do_umnt(struct mount_options *options,
 
 	return EX_SUCCESS;
 }
+
+int nfs_is_inaddr_any(struct sockaddr *nfs_saddr)
+{
+	switch (nfs_saddr->sa_family) {
+	case AF_INET: {
+		if (((struct sockaddr_in *)nfs_saddr)->sin_addr.s_addr ==
+				INADDR_ANY)
+			return 1;
+	}
+	case AF_INET6:
+		if (!memcmp(&((struct sockaddr_in6 *)nfs_saddr)->sin6_addr,
+				&in6addr_any, sizeof(in6addr_any)))
+			return 1;
+	}
+	return 0;
+}
+
+int nfs_addr_matches_localips(struct sockaddr *nfs_saddr)
+{
+	struct ifaddrs *myaddrs, *ifa;
+	int found = 0;
+
+	/* acquire exiting network interfaces */
+	if (getifaddrs(&myaddrs) != 0)
+		return 0;
+
+	/* interate over the available interfaces and check if we
+	 * we find a match to the supplied clientaddr value
+	 */
+	for (ifa = myaddrs; ifa != NULL; ifa = ifa->ifa_next) {
+		if (ifa->ifa_addr == NULL)
+			continue;
+		if (!(ifa->ifa_flags & IFF_UP))
+			continue;
+		if (!memcmp(ifa->ifa_addr, nfs_saddr,
+				sizeof(struct sockaddr))) {
+			found = 1;
+			break;
+		}
+	}
+	freeifaddrs(myaddrs);
+	return found;
+}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index ecaac33..0fc98ac 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -54,6 +54,8 @@ int nfs_callback_address(const struct sockaddr *, const socklen_t,
 int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,
 		struct sockaddr_in *);
+int nfs_is_inaddr_any(struct sockaddr *);
+int nfs_addr_matches_localips(struct sockaddr *);
 
 struct mount_options;
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d1b0708..4d2e37e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -229,7 +229,8 @@ static int nfs_append_addr_option(const struct sockaddr *sap,
 
 /*
  * Called to discover our address and append an appropriate 'clientaddr='
- * option to the options string.
+ * option to the options string. If the supplied 'clientaddr=' value does
+ * not match either IPV4/IPv6 any or a local address, then fail the mount.
  *
  * Returns 1 if 'clientaddr=' option created successfully or if
  * 'clientaddr=' option is already present; otherwise zero.
@@ -242,8 +243,27 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
 	struct sockaddr *my_addr = &address.sa;
 	socklen_t my_len = sizeof(address);
 
-	if (po_contains(options, "clientaddr") == PO_FOUND)
+	if (po_contains(options, "clientaddr") == PO_FOUND) {
+		char *addr = po_get(options, "clientaddr");
+		union nfs_sockaddr nfs_address;
+		struct sockaddr *nfs_saddr = &nfs_address.sa;
+		socklen_t nfs_salen = sizeof(nfs_address);
+
+		/* translate the input for clientaddr to nfs_sockaddr */
+		if (!nfs_string_to_sockaddr(addr, nfs_saddr, &nfs_salen))
+			return 0;
+
+		/* check for IPV4_ANY and IPV6_ANY */
+		if (nfs_is_inaddr_any(nfs_saddr))
+			return 1;
+
+		/* check if ip matches local network addresses */
+		if (!nfs_addr_matches_localips(nfs_saddr))
+			nfs_error(_("%s: [warning] supplied clientaddr=%s "
+				"does not match any existing network "
+				"addresses"), progname, addr);
 		return 1;
+	}
 
 	nfs_callback_address(sap, salen, my_addr, &my_len);
 
-- 
1.8.3.1

