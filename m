From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Wed, 18 Feb 2009 23:11:11 +1030
Message-ID: <1234960871.3455.27.camel@sibyl.beware.dropbear.id.au>
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
	 <1234711952.25265.34.camel@sibyl.beware.dropbear.id.au>
	 <5E2B57AC-1977-449B-B595-354717A6ECD3@oracle.com>
	 <1234872202.14585.33.camel@sibyl.bewa! re.dropbear.id.au>
	 <30C44273-7011-46AD-B79B-FCD06E9F25FE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 60-242-66-41.static.tpgi.com.au ([60.242.66.41]:55451 "EHLO
	sibyl.beware.dropbear.id.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750802AbZBRMle (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Feb 2009 07:41:34 -0500
In-Reply-To: <30C44273-7011-46AD-B79B-FCD06E9F25FE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2009-02-17 at 12:29 -0500, Chuck Lever wrote:
> Hi Ian-
> 
> On Feb 17, 2009, at Feb 17, 2009, 7:03 AM, Ian Dall wrote:
> > On Mon, 2009-02-16 at 11:24 -0500, Chuck Lever wrote:
> >>
> >> I've thought more about this.  I think we don't want the scope ID
> >> comparison here at all.  The scope ID is not really part of an IPv6
> >> address.  A unique host address is contained only in the sin6_addr
> >> field; the scope ID is simply local routing information.  I can't
> >> think of a case where two unique remotes would have identical link-
> >> local addresses.
> >
> > Isn't that exactly what makes link local addresses, well, link local?
> 
> No, an IPv6 address is link-local by virtue of having the  
> IPV6_ADDR_LINKLOCAL bit set.  Scope IDs came along later.

That is just an API and nothing to do with the semantics of "link
local". Previously it was unspecified how to denote a link, now there is
a sockaddr field (which is largely undocumented, so not much of a
change). There is nothing in the IPv6 standard which says that the
kernel has to use sockaddr internally, but clearly it has to keep track
of what link a link local address is on somehow!

> Generally the way a link-local address is formed on Linux is by using  
> the link's MAC address to form a unique 64-bit EUID, and concatenating  
> that to a standard link-local prefix, usually fe80:: .  Each NIC on a  
> host therefore has it's own link-local address, generally speaking.

Yes. But not all hosts on the "link" need be linux. Also, not all lans
have to be ethernet.

> > http://books.google.com/books?id=6nNjcItz6H4C&pg=PA53&lpg=PA53&dq=sin6_scope_id+%22link+local%22&source=bl&ots=MFyiwYwO5I&sig=hZDvlVcJ8hLOwt7EXoL4lEzT4V4&hl=en&ei=eqCaSdiGD8PDkAWskMmZCw&sa=X&oi=book_result&resnum=7&ct=result
> >
> > Note especially, section 1.8.1 "Since link local addresses may not be
> > unique on different links ..."
> 
> Does that imply that unique hosts can have the same link-local  
> address, or simply that the same link-local address is permitted to  
> appear on different links?

Both I reckon. It is the address which is link local, not (necessarilly)
the host. But if they are link local addresses on the same host but
different links, which are other wise the same, everything else on the
network should treat them just as if they were separate hosts. This is
no different to a host having two ordinary IP (v4 or v6) addresses.

Potentially a host might run two nfs servers listening on two interfaces
on two separate lans with the same link local address, serving up
different files. The servers are on the same host, but that should be
completely opaque to clients.

> I think the correct way to proceed here is to address the original  
> problem without adding the scope ID check, then explore the scope ID  
> issue separately.  The presenting problem in 11061 affects IPv4  
> addresses too if I'm not mistaken, and IPv4 is fairly widely deployed,  
> so it needs to be fixed now.
> 
> If scope ID matching is a problem in nfs_match_client, then it is also  
> an issue for other places in the NFS client, and should be fixed in  
> all those places at once, in a single patch that documents the scope  
> ID matching requirement.

From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Addresses: http://bugzilla.kernel.org/show_bug.cgi?id=11061

sockaddr structures can't be reliably compared using memcmp() because
there are padding bytes in the structure which can't be guaranteed to
be the same even when the sockaddr structures refer to the same
socket. Instead compare all the relevant fields. In the case of IPv6
sin6_flowinfo is not compared because it only affects QoS and
sin6_scope_id is currently not supported.

Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9b728f3..9ac4c6b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -273,6 +273,59 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 #endif
 
 /*
+ * Test if two ip4 socket addresses refer to the same socket, by
+ * comparing relevant fields. The padding bytes specifically, are
+ * not compared.
+ *
+ * The caller should ensure both socket addresses are AF_INET.
+ */
+static int nfs_sockaddr_cmp_ip4(const struct sockaddr_in *saddr1,
+				const struct sockaddr_in *saddr2)
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
+ * and sin6_scope_id is currently not supported.
+ *
+ * The caller should ensure both socket addresses are AF_INET6.
+ */
+static int nfs_sockaddr_cmp_ip6(const struct sockaddr_in6 *saddr1,
+				const struct sockaddr_in6 *saddr2)
+{
+	if (!ipv6_addr_equal(&saddr1->sin6_addr,
+			     &saddr1->sin6_addr))
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
@@ -344,8 +397,10 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *data)
 {
 	struct nfs_client *clp;
+	const struct sockaddr *sap = data->addr;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+		const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -358,7 +413,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		/* Match the full socket address */
-		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
+		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
 
 		atomic_inc(&clp->cl_count);



-- 
Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

