From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/5] NFS: fix nfs_parse_ip_address() corner case
Date: Wed,  8 Oct 2008 15:38:10 -0400
Message-ID: <1223494694-12778-1-git-send-email-bfields@citi.umich.edu>
References: <20081008193114.GA12386@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36892 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876AbYJHTiQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 15:38:16 -0400
In-Reply-To: <20081008193114.GA12386@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

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
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/super.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9abcd2b..c989e71 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -727,17 +727,21 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
 #define IPV6_SCOPE_DELIMITER	'%'
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
-				    const char *delim,
-				    struct sockaddr_in6 *sin6)
+static int nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
+				   const char *delim,
+				   struct sockaddr_in6 *sin6)
 {
 	char *p;
 	size_t len;
 
-	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
-		return ;
+	if ((string + str_len) == delim)
+		return 1;
+
 	if (*delim != IPV6_SCOPE_DELIMITER)
-		return;
+		return 0;
+
+	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
+		return 0;
 
 	len = (string + str_len) - delim - 1;
 	p = kstrndup(delim + 1, len, GFP_KERNEL);
@@ -750,14 +754,20 @@ static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
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
@@ -773,9 +783,11 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
 
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
 
-- 
1.5.5.rc1

