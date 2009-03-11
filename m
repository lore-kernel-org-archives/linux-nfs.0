From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 7/9] Bug 11061, NFS mounts dropped
Date: Wed, 11 Mar 2009 14:25:26 -0400
Message-ID: <20090311182526.403.46830.stgit@heimdal.trondhjem.org>
References: <20090311182525.403.42026.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32654 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877AbZCKS34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:29:56 -0400
In-Reply-To: <20090311182525.403.42026.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Addresses: http://bugzilla.kernel.org/show_bug.cgi?id=11061

sockaddr structures can't be reliably compared using memcmp() because
there are padding bytes in the structure which can't be guaranteed to
be the same even when the sockaddr structures refer to the same
socket. Instead compare all the relevant fields. In the case of IPv6
sin6_flowinfo is not compared because it only affects QoS and
sin6_scope_id is only compared if the address is "link local" because
"link local" addresses need only be unique to a specific link.

Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 62 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9b728f3..06654b8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -273,6 +273,65 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 #endif
 
 /*
+ * Test if two ip4 socket addresses refer to the same socket, by
+ * comparing relevant fields. The padding bytes specifically, are
+ * not compared.
+ *
+ * The caller should ensure both socket addresses are AF_INET.
+ */
+static int nfs_sockaddr_cmp_ip4(const struct sockaddr_in * saddr1,
+				const struct sockaddr_in * saddr2)
+{
+	if (saddr1->sin_addr.s_addr != saddr2->sin_addr.s_addr)
+		return 0;
+	return saddr1->sin_port == saddr2->sin_port;
+}
+
+/*
+ * Test if two ip6 socket addresses refer to the same socket by
+ * comparing relevant fields. The padding bytes specifically, are not
+ * compared. sin6_flowinfo is not compared because it only affects QoS
+ * and sin6_scope_id is only compared if the address is "link local"
+ * because "link local" addresses need only be unique to a specific
+ * link. Conversely, ordinary unicast addresses might have different
+ * sin6_scope_id.
+ *
+ * The caller should ensure both socket addresses are AF_INET6.
+ */
+static int nfs_sockaddr_cmp_ip6 (const struct sockaddr_in6 * saddr1,
+				 const struct sockaddr_in6 * saddr2)
+{
+	if (!ipv6_addr_equal(&saddr1->sin6_addr,
+			     &saddr1->sin6_addr))
+		return 0;
+	if (ipv6_addr_scope(&saddr1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
+	    saddr1->sin6_scope_id != saddr2->sin6_scope_id)
+		return 0;
+	return saddr1->sin6_port == saddr2->sin6_port;
+}
+
+/*
+ * Test if two socket addresses represent the same actual socket,
+ * by comparing (only) relevant fields.
+ */
+static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
+			    const struct sockaddr *sa2)
+{
+	if (sa1->sa_family != sa2->sa_family)
+		return 0;
+
+	switch (sa1->sa_family) {
+	case AF_INET:
+		return nfs_sockaddr_cmp_ip4((const struct sockaddr_in *) sa1,
+					    (const struct sockaddr_in *) sa2);
+	case AF_INET6:
+		return nfs_sockaddr_cmp_ip6((const struct sockaddr_in6 *) sa1,
+					    (const struct sockaddr_in6 *) sa2);
+	}
+	return 0;
+}
+
+/*
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
@@ -344,8 +403,10 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *data)
 {
 	struct nfs_client *clp;
+	const struct sockaddr *sap = data->addr;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -358,7 +419,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		/* Match the full socket address */
-		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
+		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
 
 		atomic_inc(&clp->cl_count);

