From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Wed, 04 Feb 2009 23:22:35 +1030
Message-ID: <1233751955.13862.68.camel@sibyl.beware.dropbear.id.au>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
	 <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
	 <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
	 <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au>
	 <2A59F69E-7E14-4E20-9F9E-EF9B02326342@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 60-242-66-41.static.tpgi.com.au ([60.242.66.41]:55255 "EHLO
	sibyl.beware.dropbear.id.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757284AbZBDMwq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 07:52:46 -0500
In-Reply-To: <2A59F69E-7E14-4E20-9F9E-EF9B02326342@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2009-02-03 at 17:16 -0500, Chuck Lever wrote: 
> On Feb 3, 2009, at Feb 3, 2009, 4:56 PM, Ian Dall wrote:
> > OK here is version 2 of the patch. It is half the size of version 1,
> > although the resultant client.c is slightly bigger and IMO slightly
> > inferior than for version 1, but certainly it is around the margin.
> 
> Why do you think this is inferior?  This way we are checking exactly  
> the fields in each sockaddr that need to be checked, and using the  
> same equality test that most other parts of the NFS client use.

There is duplicated code, namely the function headers for 
nfs_sockaddr_match_ipaddr() and nfs_sockaddr_match_port().

Granted this doesn't add to the executable size in any way because of
the conditional compilation, but it is still a potential source of
trouble down the track when one function definition gets changed and
another doesn't and further more, it won't show up unless you test both
IPV6 and non IPV6 configurations. Having function headers in two places
makes following the code with etags more confusing. And even without
etags you have to scroll up and down to see the two versions of the same
function.

Also nfs_sockaddr_match_ipaddr4() is trivial, taking 7 lines of code
(counting the call and the function definition) to do what can be
expressed in 2 and has additional overhead, albeit small.

None of these are a big deal, which is way I said *slightly* inferior.

I'm not exactly sure what you didn't like about my first patch. Maybe it
was just too big (fair enough, more to go wrong), or maybe you didn't
like the  test return; test return; ... style, or maybe you didn't like
the use of a port_match flag.

See if you like this one :-) It is small, but not quite minimal. It
doesn't change the style of logic, it doesn't use a flag. It does
address my concerns about duplicated code, it includes Trond's
suggestions and the resulting code is smallest so far (in SLOC). Granted
that less SLOC isn't always better, but in this case it is done by
removing duplication and not by making more complicated lines, so IMHO
it is a good thing!

Log:
======================
Don't compare sock_addr structures using memcmp(). Reduce conditionally
compiled address comparison code.

Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
======================
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9b728f3..1c2a319 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -238,10 +238,12 @@ static const struct in6_addr *nfs_map_ipv4_addr(const struct sockaddr *sa, struc
 			return addr_mapped;
 	}
 }
+#endif
 
 static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 		const struct sockaddr *sa2)
 {
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	const struct in6_addr *addr1;
 	const struct in6_addr *addr2;
 	struct in6_addr addr1_mapped;
@@ -254,23 +256,32 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 			return ipv6_addr_equal(addr1, addr2);
 	}
 	return 0;
-}
 #else
-static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
-				 const struct sockaddr_in *sa2)
-{
-	return sa1->sin_addr.s_addr == sa2->sin_addr.s_addr;
-}
-
-static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
-				 const struct sockaddr *sa2)
-{
 	if (unlikely(sa1->sa_family != AF_INET || sa2->sa_family != AF_INET))
 		return 0;
-	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
-			(const struct sockaddr_in *)sa2);
+	return (((const struct sockaddr_in *)sa1)->sin_addr.s_addr ==
+		((const struct sockaddr_in *)sa2)->sin_addr.s_addr))
+#endif
 }
+
+static int nfs_sockaddr_match_port(const struct sockaddr *sa1,
+				   const struct sockaddr *sa2)
+{
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	switch (sa1->sa_family) {
+	case AF_INET:
+		return (((const struct sockaddr_in *)sa1)->sin_port ==
+			((const struct sockaddr_in *)sa2)->sin_port);
+	case AF_INET6:
+		return (((const struct sockaddr_in6 *)sa1)->sin6_port ==
+			((const struct sockaddr_in6 *)sa2)->sin6_port);
+	}
+	return 0;
+#else
+	return (((const struct sockaddr_in *)sa1)->sin_port ==
+		((const struct sockaddr_in *)sa2)->sin_port);
 #endif
+}
 
 /*
  * Find a client by IP address and protocol version
@@ -344,8 +355,10 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *data)
 {
 	struct nfs_client *clp;
+	const struct sockaddr *sap = data->addr;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -358,8 +371,12 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		/* Match the full socket address */
-		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
+		if (!nfs_sockaddr_match_ipaddr(sap, clap))
 			continue;
+		/* including the port number */
+		if (!nfs_sockaddr_match_port(sap, clap))
+			continue;
+
 
 		atomic_inc(&clp->cl_count);
 		return clp;

-- 
Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

