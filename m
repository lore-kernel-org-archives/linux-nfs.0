From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] kNFSd - 3 of 5 - ip_map_init does a kmalloc which isn't checked
Date: Sun, 8 Feb 2004 15:43:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208204325.GD27482@fieldses.org>
References: <20040206161050.27799.patches@notabene> <E1AoyIo-0007FS-00@notabene> <20040207012423.396efe73.akpm@osdl.org> <20040208043723.GC13391@fieldses.org> <20040207214637.387d3018.akpm@osdl.org> <20040208055921.GA14053@fieldses.org> <20040208203018.GA27482@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ApvmG-00024l-09
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:43:40 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1ApvmF-0001Mb-Aq
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:43:39 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040208203018.GA27482@fieldses.org>
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


There is no way to return an error from a cache init routine, so instead we
make sure to pre-allocate the memory needed, and free it after the lookup if
the lookup failed.


 net/sunrpc/svcauth_unix.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff -puN net/sunrpc/svcauth_unix.c~neil_NfsdIpMapInit net/sunrpc/svcauth_unix.c
--- linux-2.6.1/net/sunrpc/svcauth_unix.c~neil_NfsdIpMapInit	2004-02-08 01:50:33.000000000 -0500
+++ linux-2.6.1-bfields/net/sunrpc/svcauth_unix.c	2004-02-08 01:50:33.000000000 -0500
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

_


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
