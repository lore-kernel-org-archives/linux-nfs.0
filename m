From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: fix nfs_parse_ip_address() corner case
Date: Fri, 22 Aug 2008 14:24:22 -0400
Message-ID: <20080822182419.19572.34705.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14994 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782AbYHVSaA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 14:30:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce observed that nfs_parse_ip_address() will successfully parse an IPv6
address that looks like this:

  "::1%"

A scope delimiter is present, but there is no scope ID following it.
This is harmless, as it would simply set the scope ID to zero.  However,
in some cases we would like to flag this as an improperly formed
address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5b2aa04..f73e068 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -727,19 +727,21 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
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
 
 	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
-		return ;
+		return 0;
 	if (*delim != IPV6_SCOPE_DELIMITER)
-		return;
-
+		return 0;
 	len = (string + str_len) - delim - 1;
+	if (len == 0)
+		return 0;
+
 	p = kstrndup(delim + 1, len, GFP_KERNEL);
 	if (p) {
 		unsigned long scope_id = 0;
@@ -758,6 +760,8 @@ static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
 		sin6->sin6_scope_id = scope_id;
 		dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
 	}
+
+	return 1;
 }
 
 static void nfs_parse_ipv6_address(char *string, size_t str_len,
@@ -773,9 +777,11 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
 
 		sin6->sin6_family = AF_INET6;
 		*addr_len = sizeof(*sin6);
-		if (in6_pton(string, str_len, addr, IPV6_SCOPE_DELIMITER, &delim)) {
-			nfs_parse_ipv6_scope_id(string, str_len, delim, sin6);
-			return;
+		if (in6_pton(string, str_len, addr,
+					IPV6_SCOPE_DELIMITER, &delim)) {
+			if (nfs_parse_ipv6_scope_id(string,
+							str_len, delim, sin6))
+				return;
 		}
 	}
 

