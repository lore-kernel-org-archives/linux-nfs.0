From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 15 - Provide content file for auth.unix.ip cache
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002Xf-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xl-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:26 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:14 +1100
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

 ----------- Diffstat output ------------
 ./net/sunrpc/svcauth_unix.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-01-06 10:11:58.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2003-01-06 10:14:36.000000000 +1100
@@ -5,6 +5,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/err.h>
+#include <linux/seq_file.h>
 
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
@@ -210,6 +211,33 @@ static int ip_map_parse(struct cache_det
 	return 0;
 }
 
+static int ip_map_show(struct seq_file *m,
+		       struct cache_detail *cd,
+		       struct cache_head *h,
+		       char *pbuf)
+{
+	struct ip_map *im;
+	struct in_addr addr;
+
+	if (h == NULL) {
+		seq_puts(m, "#class IP domain\n");
+		return 0;
+	}
+	im = container_of(h, struct ip_map, h);
+	/* class addr domain */
+	addr = im->m_addr;
+	seq_printf(m, "%s %d.%d.%d.%d %s\n",
+		   im->m_class,
+		   htonl(addr.s_addr) >> 24 & 0xff,
+		   htonl(addr.s_addr) >> 16 & 0xff,
+		   htonl(addr.s_addr) >>  8 & 0xff,
+		   htonl(addr.s_addr) >>  0 & 0xff,
+		   im->m_client->h.name
+		   );
+	return 0;
+}
+	
+
 struct cache_detail ip_map_cache = {
 	.hash_size	= IP_HASHMAX,
 	.hash_table	= ip_table,
@@ -217,6 +245,7 @@ struct cache_detail ip_map_cache = {
 	.cache_put	= ip_map_put,
 	.cache_request	= ip_map_request,
 	.cache_parse	= ip_map_parse,
+	.cache_show	= ip_map_show,
 };
 
 static DefineSimpleCacheLookup(ip_map)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
