From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 13 of 17 - Implement ip_map_request for upcalls
Date: Fri, 11 Oct 2002 15:27:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsL4-0003bt-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLW-0003iK-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:22 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Fri, 11 Oct 2002 15:28:03 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: linux-kernel@vger.kernel.org
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

This is the first upcall to actually be coded.
A request will look like:
   nfsd 127.0.0.1


 ----------- Diffstat output ------------
 ./net/sunrpc/svcauth_unix.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+)

--- ./net/sunrpc/svcauth_unix.c	2002/10/11 02:00:12	1.4
+++ ./net/sunrpc/svcauth_unix.c	2002/10/11 03:06:58	1.5
@@ -116,11 +116,31 @@ static inline void ip_map_update(struct 
 	new->m_add_change = item->m_add_change;
 }
 
+static void ip_map_request(struct cache_detail *cd,
+				  struct cache_head *h,
+				  char **bpp, int *blen)
+{
+	char text_addr[20];
+	struct ip_map *im = container_of(h, struct ip_map, h);
+	__u32 addr = im->m_addr.s_addr;
+	
+	snprintf(text_addr, 20, "%u.%u.%u.%u",
+		 ntohl(addr) >> 24 & 0xff,
+		 ntohl(addr) >> 16 & 0xff,
+		 ntohl(addr) >>  8 & 0xff,
+		 ntohl(addr) >>  0 & 0xff);
+
+	add_word(bpp, blen, im->m_class);
+	add_word(bpp, blen, text_addr);
+	(*bpp)[-1] = '\n';
+}
+
 struct cache_detail ip_map_cache = {
 	.hash_size	= IP_HASHMAX,
 	.hash_table	= ip_table,
 	.name		= "auth.unix.ip",
 	.cache_put	= ip_map_put,
+	.cache_request	= ip_map_request,
 };
 
 static DefineSimpleCacheLookup(ip_map)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
