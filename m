From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 5 - ip_map_init does a kmalloc which isn't checked...
Date: Fri, 06 Feb 2004 16:13:18 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AoyIo-0007FS-00@notabene>
References: <20040206161050.27799.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoyJ4-0008Ia-Iw
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:34 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AoyJ3-0003LN-MV
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:33 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 6 Feb 2004 16:13:22 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


There is no way to return an error from a cache init routine,
so instead we make sure to pre-allocate the memory needed,
and free it after the lookup if the lookup failed.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcauth_unix.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-02-06 11:21:29.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2004-02-06 14:11:40.000000000 +1100
@@ -119,7 +119,8 @@ static inline int ip_map_match(struct ip
 }
 static inline void ip_map_init(struct ip_map *new, struct ip_map *item)
 {
-	new->m_class = strdup(item->m_class);
+	new->m_class = item->m_class;
+	item->m_class = NULL;
 	new->m_addr.s_addr = item->m_addr.s_addr;
 }
 static inline void ip_map_update(struct ip_map *new, struct ip_map *item)
@@ -191,7 +192,9 @@ static int ip_map_parse(struct cache_det
 	} else
 		dom = NULL;
 
-	ipm.m_class = class;
+	ipm.m_class = strdup(class);
+	if (ipm.m_class == NULL)
+		return -ENOMEM;
 	ipm.m_addr.s_addr =
 		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
 	ipm.h.flags = 0;
@@ -207,6 +210,7 @@ static int ip_map_parse(struct cache_det
 		ip_map_put(&ipmp->h, &ip_map_cache);
 	if (dom)
 		auth_domain_put(dom);
+	if (ipm.m_class) kfree(ipm.m_class);
 	if (!ipmp)
 		return -ENOMEM;
 	cache_flush();
@@ -266,7 +270,9 @@ int auth_unix_add_addr(struct in_addr ad
 	if (dom->flavour != RPC_AUTH_UNIX)
 		return -EINVAL;
 	udom = container_of(dom, struct unix_domain, h);
-	ip.m_class = "nfsd";
+	ip.m_class = strdup("nfsd");
+	if (!ip.m_class)
+		return -ENOMEM;
 	ip.m_addr = addr;
 	ip.m_client = udom;
 	ip.m_add_change = udom->addr_changes+1;
@@ -274,6 +280,7 @@ int auth_unix_add_addr(struct in_addr ad
 	ip.h.expiry_time = NEVER;
 	
 	ipmp = ip_map_lookup(&ip, 1);
+	if (ip.m_class) kfree(ip.m_class);
 	if (ipmp) {
 		ip_map_put(&ipmp->h, &ip_map_cache);
 		return 0;


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
