From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 4] Minor memory leak fix.
Date: Fri, 20 Aug 2004 16:51:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1By3FQ-000738-5m@notabene.cse.unsw.edu.au>
References: <20040820164909.27056.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By3Fb-0004fc-At
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:47 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1By3Fa-0006oC-A4
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:47 -0700
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



Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |    1 +
 1 files changed, 1 insertion(+)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-08-20 16:38:12.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2004-08-20 16:38:19.000000000 +1000
@@ -104,6 +104,7 @@ void ip_map_put(struct cache_head *item,
 		if (test_bit(CACHE_VALID, &item->flags) &&
 		    !test_bit(CACHE_NEGATIVE, &item->flags))
 			auth_domain_put(&im->m_client->h);
+		kfree(im->m_class);
 		kfree(im);
 	}
 }


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
