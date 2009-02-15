From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Mon, 16 Feb 2009 02:02:32 +1030
Message-ID: <1234711952.25265.34.camel@sibyl.beware.dropbear.id.au>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
	 <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
	 <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
	 <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au>
	 <1233699391.7161.11.camel@heimdal.trondhjem.org>
	 <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com>
	 <1233771633.7161.35.camel@heimdal.trondhjem.org>
	 <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com>
	 <1233773231.7161.51.camel@heimdal.trondhjem.org>
	 <1234094116.13862.162.camel@sibyl.beware.dropbear.id.au>
	 <7ED0098B-1D71-4E43-A8E4-D5859F13DD38@oracle.com>
	 <1234355861.13862.239.camel@sibyl.beware.dropbear.id.au>
	 <985DCB56-4365-40FC-B48D-43C28742908F@oracle.com>
	 <1234402083.13862.273.camel@sibyl.beware.dropbear.id.au>
	 <C7FF32B1-AF6D-470B-96DB-4BD77E90C50C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 60-242-66-41.static.tpgi.com.au ([60.242.66.41]:51224 "EHLO
	sibyl.beware.dropbear.id.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbZBOPcz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Feb 2009 10:32:55 -0500
In-Reply-To: <C7FF32B1-AF6D-470B-96DB-4BD77E90C50C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I believe this includes all comments so far. I have also swatted up on
Documentation/CodingStyle, and modified the comments somewhat to
conform.

I really hope this is acceptable now. One proviso. I don't actually have
an IPv6 network so that code path is untested (except that it compiles).

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

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9b728f3..fa4060d 100644
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



-- 
Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

