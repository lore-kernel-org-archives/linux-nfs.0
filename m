From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 8 - Add some tracing when showing the content of an RPC cache.
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001qO-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhx-0007Rg-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:13 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:54:58 +1000
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

The /proc/net/rpc/*/content files now will show
entries that are still in the cache, but are either
expired or negative, as comment.

ip_map_show is enhance to work if called with a negative 
or incomplete entry.

Also if cache debugging is enabled, the expiry time and
refcount of each entry will be included in a comment.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/debug.h |    1 +
 ./net/sunrpc/cache.c           |    9 +++++++--
 ./net/sunrpc/svcauth_unix.c    |    8 +++++++-
 3 files changed, 15 insertions(+), 3 deletions(-)

diff ./include/linux/sunrpc/debug.h~current~ ./include/linux/sunrpc/debug.h
--- ./include/linux/sunrpc/debug.h~current~	2003-06-24 14:05:51.000000000 +1000
+++ ./include/linux/sunrpc/debug.h	2003-06-24 13:46:31.000000000 +1000
@@ -58,6 +58,7 @@ extern unsigned int		nlm_debug;
 # define dfprintk(fac, args...)	do { ifdebug(fac) printk(args); } while(0)
 # define RPC_IFDEBUG(x)		x
 #else
+# define ifdebug(fac)		if (0)
 # define dfprintk(fac, args...)	do ; while (0)
 # define RPC_IFDEBUG(x)
 #endif

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-06-24 14:05:51.000000000 +1000
+++ ./net/sunrpc/cache.c	2003-06-24 13:49:37.000000000 +1000
@@ -1063,10 +1063,15 @@ static int c_show(struct seq_file *m, vo
 	if (p == (void *)1)
 		return cd->cache_show(m, cd, NULL, pbuf);
 
+	ifdebug(CACHE)
+		seq_printf(m, "# expiry=%ld refcnt=%d\n",
+			   cp->expiry_time, atomic_read(&cp->refcnt));
 	cache_get(cp);
 	if (cache_check(cd, cp, NULL))
-		return 0;
-	cache_put(cp, cd);
+		/* cache_check does a cache_put on failure */
+		seq_printf(m, "# ");
+	else
+		cache_put(cp, cd);
 
 	return cd->cache_show(m, cd, cp, pbuf);
 }

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-06-24 14:05:45.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2003-06-24 14:07:15.000000000 +1000
@@ -220,6 +220,7 @@ static int ip_map_show(struct seq_file *
 {
 	struct ip_map *im;
 	struct in_addr addr;
+	char *dom = "-no-domain-";
 
 	if (h == NULL) {
 		seq_puts(m, "#class IP domain\n");
@@ -228,13 +229,18 @@ static int ip_map_show(struct seq_file *
 	im = container_of(h, struct ip_map, h);
 	/* class addr domain */
 	addr = im->m_addr;
+
+	if (test_bit(CACHE_VALID, &h->flags) && 
+	    !test_bit(CACHE_NEGATIVE, &h->flags))
+		dom = im->m_client->h.name;
+
 	seq_printf(m, "%s %d.%d.%d.%d %s\n",
 		   im->m_class,
 		   htonl(addr.s_addr) >> 24 & 0xff,
 		   htonl(addr.s_addr) >> 16 & 0xff,
 		   htonl(addr.s_addr) >>  8 & 0xff,
 		   htonl(addr.s_addr) >>  0 & 0xff,
-		   im->m_client->h.name
+		   dom
 		   );
 	return 0;
 }


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
