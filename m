From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: fix nfs_parse_ip_address() corner case
Date: Wed, 03 Sep 2008 16:35:57 -0400
Message-ID: <20080903203414.3322.97607.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55262 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbYICUgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 16:36:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce observed that nfs_parse_ip_address() will successfully parse an
IPv6 address that looks like this:

  "::1%"

A scope delimiter is present, but there is no scope ID following it.
This is harmless, as it would simply set the scope ID to zero.  However,
in some cases we would like to flag this as an improperly formed
address.

We are now also careful to reject addresses where garbage follows the
address (up to the length of the string), instead of ignoring the
non-address characters; and where the scope ID is nonsense (not a valid
device name, but also not numeric).  Before, both of these cases would
result in a harmless zero scope ID.
    
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

This has seen some local testing.  I'm not sure it gets every corner case
right, as the mount.nfs4 command passes the server name/address through DNS,
so it already doesn't allow patently bogus addresses like the above example.

But I thought I would post this for comments.

 fs/nfs/super.c |   37 ++++++++++++++++++++++++-------------
 1 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5b2aa04..92de5e2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -727,19 +727,22 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
 #define IPV6_SCOPE_DELIMITER	'%'
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
-				    const char *delim,
-				    struct sockaddr_in6 *sin6)
+static int nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
+				   const char *delim,
+				   struct sockaddr_in6 *sin6)
 {
+	size_t len = (string + str_len) - delim - 1;
 	char *p;
-	size_t len;
 
-	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
-		return ;
+	if (len == 0)
+		return 1;
+
 	if (*delim != IPV6_SCOPE_DELIMITER)
-		return;
+		return 0;
+
+	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
+		return 0;
 
-	len = (string + str_len) - delim - 1;
 	p = kstrndup(delim + 1, len, GFP_KERNEL);
 	if (p) {
 		unsigned long scope_id = 0;
@@ -750,14 +753,20 @@ static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
 			scope_id = dev->ifindex;
 			dev_put(dev);
 		} else {
-			/* scope_id is set to zero on error */
-			strict_strtoul(p, 10, &scope_id);
+			if (strict_strtoul(p, 10, &scope_id) == 0) {
+				kfree(p);
+				return 0;
+			}
 		}
 
 		kfree(p);
+
 		sin6->sin6_scope_id = scope_id;
 		dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
+		return 1;
 	}
+
+	return 0;
 }
 
 static void nfs_parse_ipv6_address(char *string, size_t str_len,
@@ -773,9 +782,11 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
 
 		sin6->sin6_family = AF_INET6;
 		*addr_len = sizeof(*sin6);
-		if (in6_pton(string, str_len, addr, IPV6_SCOPE_DELIMITER, &delim)) {
-			nfs_parse_ipv6_scope_id(string, str_len, delim, sin6);
-			return;
+		if (in6_pton(string, str_len, addr,
+					IPV6_SCOPE_DELIMITER, &delim) != 0) {
+			if (nfs_parse_ipv6_scope_id(string, str_len,
+							delim, sin6) != 0)
+				return;
 		}
 	}
 

