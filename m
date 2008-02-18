From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/17] text-based mount.nfs: allow mntopt helpers to construct
	AF_INET6 addresses
Date: Mon, 18 Feb 2008 13:36:38 -0500
Message-ID: <20080218183638.19060.27078.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:56993 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbYBRSgj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:39 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIacJF019591
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:38 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIacPT019384
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:38 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are three helpers that convert sockaddr-style addresses to text
addresses, then construct mount options to pass these addresses to the
kernel.  The tail of each of these helpers does exactly the same thing,
so refactor the common code into a separate function.  Add an IPv6-enabled
variant.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |  102 ++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 74 insertions(+), 28 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 6293766..ef6365d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -33,8 +33,11 @@
 #include <errno.h>
 #include <netdb.h>
 #include <time.h>
+
+#include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/mount.h>
+#include <arpa/inet.h>
 
 #include "xcommon.h"
 #include "mount.h"
@@ -141,6 +144,66 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 }
 
 /*
+ * Convert the passed-in sockaddr-style address to a text version of
+ * the address, then append an option of the form "keyword=address".
+ *
+ * Returns 1 if the option was appended successfully;
+ * otherwise zero.
+ */
+#ifdef IPV6_SUPPORTED
+static int append_generic_address_option(const struct sockaddr *sap,
+					 const char *keyword,
+					 struct mount_options *options)
+{
+	char new_option[128 + INET6_ADDRSTRLEN];
+	size_t len = strlen(keyword) + 1;
+	void *src;
+
+	if (len + INET6_ADDRSTRLEN >= sizeof(new_option))
+		return 0;
+
+	new_option[0] = '\0';
+	strcat(new_option, keyword);
+	strcat(new_option, "=");
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		src = &((struct sockaddr_in *)sap)->sin_addr;
+		break;
+	case AF_INET6:
+		src = &((struct sockaddr_in6 *)sap)->sin6_addr;
+		break;
+	default:
+		return 0;
+	}
+	if (inet_ntop(sap->sa_family, src, new_option + len,
+						INET6_ADDRSTRLEN) == NULL)
+		return 0;
+
+	if (po_append(options, new_option) != PO_SUCCEEDED)
+		return 0;
+	return 1;
+}
+#else
+static int append_generic_address_option(const struct sockaddr *sap,
+					 const char *keyword,
+					 struct mount_options *options)
+{
+	char new_option[128];
+
+	if (strlen(keyword) + 16 > sizeof(new_option))
+		return 0;
+
+	snprintf(new_option, sizeof(new_option) - 1, "%s=%s", keyword,
+			inet_ntoa(((struct sockaddr_in *)sap)->sin_addr));
+
+	if (po_append(options, new_option) != PO_SUCCEEDED)
+		return 0;
+	return 1;
+}
+#endif
+
+/*
  * Append the 'addr=' option to the options string to pass a resolved
  * server address to the kernel.  After a successful mount, this address
  * is also added to /etc/mtab for use when unmounting.
@@ -152,19 +215,12 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
  * Returns 1 if 'addr=' option appended successfully;
  * otherwise zero.
  */
-static int append_addr_option(struct sockaddr_in *saddr,
+static int append_addr_option(struct sockaddr *saddr,
 			   struct mount_options *options)
 {
-	char new_option[24];
-
 	po_remove_all(options, "addr");
 
-	snprintf(new_option, sizeof(new_option) - 1,
-			"addr=%s", inet_ntoa(saddr->sin_addr));
-
-	if (po_append(options, new_option) == PO_SUCCEEDED)
-		return 1;
-	return 0;
+	return append_generic_address_option(saddr, "addr", options);
 }
 
 /*
@@ -174,26 +230,20 @@ static int append_addr_option(struct sockaddr_in *saddr,
  * Returns 1 if 'clientaddr=' option created successfully or if
  * 'clientaddr=' option is already present; otherwise zero.
  */
-static int append_clientaddr_option(struct sockaddr_in *saddr,
+static int append_clientaddr_option(struct sockaddr *saddr,
 				    struct mount_options *options)
 {
 	struct sockaddr_in my_addr;
 	socklen_t len = sizeof(my_addr);
-	char new_option[32];
 
 	if (po_contains(options, "clientaddr") == PO_SUCCEEDED)
 		return 1;
 
-	if (!nfs_client_address((struct sockaddr *)saddr,
-				(struct sockaddr *)&my_addr, &len))
+	if (!nfs_client_address(saddr, (struct sockaddr *)&my_addr, &len))
 		return 0;
 
-	snprintf(new_option, sizeof(new_option) - 1,
-			"clientaddr=%s", inet_ntoa(my_addr.sin_addr));
-
-	if (po_append(options, new_option) == PO_SUCCEEDED)
-		return 1;
-	return 0;
+	return append_generic_address_option((struct sockaddr *)&my_addr,
+						"clientaddr", options);
 }
 
 /*
@@ -203,7 +253,7 @@ static int append_clientaddr_option(struct sockaddr_in *saddr,
 static int fix_mounthost_option(struct mount_options *options)
 {
 	struct sockaddr_in maddr;
-	char *mounthost, new_option[32];
+	char *mounthost;
 
 	mounthost = po_get(options, "mounthost");
 	if (!mounthost)
@@ -212,12 +262,8 @@ static int fix_mounthost_option(struct mount_options *options)
 	if (!fill_ipv4_sockaddr(mounthost, &maddr))
 		return 0;
 
-	snprintf(new_option, sizeof(new_option) - 1,
-			"mountaddr=%s", inet_ntoa(maddr.sin_addr));
-
-	if (po_append(options, new_option) == PO_SUCCEEDED)
-		return 1;
-	return 0;
+	return append_generic_address_option((struct sockaddr *)&maddr,
+						"mountaddr", options);
 }
 
 /*
@@ -226,7 +272,7 @@ static int fix_mounthost_option(struct mount_options *options)
  * Returns 1 if successful; otherwise zero.
  */
 static int set_mandatory_options(const char *type,
-				 struct sockaddr_in *saddr,
+				 struct sockaddr *saddr,
 				 struct mount_options *options)
 {
 	if (!append_addr_option(saddr, options))
@@ -694,7 +740,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		goto fail;
 	}
 
-	if (!set_mandatory_options(type, &saddr, options))
+	if (!set_mandatory_options(type, (struct sockaddr *)&saddr, options))
 		goto out;
 
 	if (po_rightmost(options, "bg", "fg") == PO_KEY1_RIGHTMOST)

