From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] mount.nfs: Remove nfs_name_to_address()
Date: Tue, 08 Dec 2009 13:00:43 -0500
Message-ID: <20091208180043.2544.97150.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:62440 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965750AbZLHSBA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:01:00 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  nfs_name_to_address() has no more callers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   23 ++---------------------
 utils/mount/network.h |    1 -
 2 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index d598fcf..e3ad5c2 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -253,25 +253,6 @@ int nfs_lookup(const char *hostname, const sa_family_t family,
 }
 
 /**
- * nfs_name_to_address - resolve hostname to an IPv4 or IPv6 socket address
- * @hostname: pointer to C string containing DNS hostname to resolve
- * @sap: pointer to buffer to fill with socket address
- * @len: IN: size of buffer to fill; OUT: size of socket address
- *
- * Returns 1 and places a socket address at @sap if successful;
- * otherwise zero.
- */
-int nfs_name_to_address(const char *hostname,
-			struct sockaddr *sap, socklen_t *salen)
-{
-#ifdef IPV6_SUPPORTED
-	return nfs_lookup(hostname, AF_UNSPEC, sap, salen);
-#else	/* !IPV6_SUPPORTED */
-	return nfs_lookup(hostname, AF_INET, sap, salen);
-#endif	/* !IPV6_SUPPORTED */
-}
-
-/**
  * nfs_gethostbyname - resolve a hostname to an IPv4 address
  * @hostname: pointer to a C string containing a DNS hostname
  * @sin: returns an IPv4 address 
@@ -293,8 +274,8 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *sin)
  *		OUT: length of converted socket address
  *
  * Convert a presentation format address string to a socket address.
- * Similar to nfs_name_to_address(), but the DNS query is squelched,
- * and won't make any noise if the getaddrinfo() call fails.
+ * Similar to nfs_lookup(), but the DNS query is squelched, and it
+ * won't make any noise if the getaddrinfo() call fails.
  *
  * Returns 1 and fills in @sap and @salen if successful; otherwise zero.
  *
diff --git a/utils/mount/network.h b/utils/mount/network.h
index da095e3..2a3a110 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -44,7 +44,6 @@ int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
 			struct pmap *, const struct sockaddr *,
 			const socklen_t, struct pmap *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
-int nfs_name_to_address(const char *, struct sockaddr *, socklen_t *);
 int nfs_lookup(const char *hostname, const sa_family_t family,
 		struct sockaddr *sap, socklen_t *salen);
 int nfs_string_to_sockaddr(const char *, struct sockaddr *, socklen_t *);

