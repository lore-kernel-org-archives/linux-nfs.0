Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:4592 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935330AbeEXUFt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 May 2018 16:05:49 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
Date: Thu, 24 May 2018 16:05:42 -0400
Message-ID: <20180524200542.22685-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the user supplies a clientaddr value, it should be either
a special value of either IPV4/IPV6 any address or a local address
on the same network that the server being mounted. Otherwise, we
disallow the client to use an arbitrary value of the clientaddr value.
This value is used to construct a client id of SETCLIENTID and
providing a false value can interfere with the real owner's mount.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 utils/mount/stropts.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d1b0708..44a6ff5 100644
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
@@ -242,11 +243,26 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
 	struct sockaddr *my_addr = &address.sa;
 	socklen_t my_len = sizeof(address);
 
-	if (po_contains(options, "clientaddr") == PO_FOUND)
-		return 1;
-
 	nfs_callback_address(sap, salen, my_addr, &my_len);
 
+	if (po_contains(options, "clientaddr") == PO_FOUND) {
+		char *addr = po_get(options, "clientaddr");
+		char address[NI_MAXHOST];
+
+		if (!strcmp(addr, "0.0.0.0") || !strcmp(addr, "::"))
+			return 1;
+		if (!nfs_present_sockaddr(my_addr, my_len, address,
+						sizeof(address)))
+			goto out;
+
+		if (strcmp(addr, address)) {
+			nfs_error(_("%s: failed to validate clientaddr "
+					"address"), progname);
+			return 0;
+		}
+		return 1;
+	}
+out:
 	return nfs_append_generic_address_option(my_addr, my_len,
 							"clientaddr", options);
 }
-- 
1.8.3.1

