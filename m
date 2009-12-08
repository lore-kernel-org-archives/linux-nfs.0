From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] mount.nfs: make nfs_lookup() global
Date: Tue, 08 Dec 2009 12:59:45 -0500
Message-ID: <20091208175945.2544.75803.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53665 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965721AbZLHSAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:19 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Expose a DNS query API that allows callers to request DNS results from
a specific address family.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   14 ++++++++++++--
 utils/mount/network.h |    2 ++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ecb5acc..7d9accd 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -193,8 +193,18 @@ static const unsigned int *nfs_default_proto()
 }
 #endif /* MOUNT_CONFIG */
 
-static int nfs_lookup(const char *hostname, const sa_family_t family,
-		      struct sockaddr *sap, socklen_t *salen)
+/**
+ * nfs_lookup - resolve hostname to an IPv4 or IPv6 socket address
+ * @hostname: pointer to C string containing DNS hostname to resolve
+ * @family: address family hint
+ * @sap: pointer to buffer to fill with socket address
+ * @len: IN: size of buffer to fill; OUT: size of socket address
+ *
+ * Returns 1 and places a socket address at @sap if successful;
+ * otherwise zero.
+ */
+int nfs_lookup(const char *hostname, const sa_family_t family,
+		struct sockaddr *sap, socklen_t *salen)
 {
 	struct addrinfo *gai_results;
 	struct addrinfo gai_hint = {
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 7eb89b0..2cdf02e 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -45,6 +45,8 @@ int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
 			const socklen_t, struct pmap *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_name_to_address(const char *, struct sockaddr *, socklen_t *);
+int nfs_lookup(const char *hostname, const sa_family_t family,
+		struct sockaddr *sap, socklen_t *salen);
 int nfs_string_to_sockaddr(const char *, struct sockaddr *, socklen_t *);
 int nfs_present_sockaddr(const struct sockaddr *,
 			 const socklen_t, char *, const size_t);

