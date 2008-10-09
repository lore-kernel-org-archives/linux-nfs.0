From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/4] NFS: fix nfs_parse_ip_address() corner case
Date: Thu, 09 Oct 2008 15:00:32 -0400
Message-ID: <20081009190032.18388.72628.stgit@localhost.localdomain>
References: <20081009190031.18388.95039.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64609 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760495AbYJITEi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:04:38 -0400
In-Reply-To: <20081009190031.18388.95039.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6b447f5..27c7c3d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -719,17 +719,21 @@ static void nfs_parse_ipv4_address(char *string, size_t str_len,
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
@@ -742,14 +746,20 @@ static void nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
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
@@ -765,9 +775,11 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
 
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
 

