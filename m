From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 4] Introduction
Date: Fri, 20 Aug 2004 16:51:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040820164909.27056.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By3Fb-0004fo-NL
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 23:51:47 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1By3Fa-0006oA-7G
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


Following are 4 patches for knfsd in 2.6.latest

1/ remove open_private_file.  It is an ugly hack that isn't really necessary,
   and causes problems.
2/ fix a minor memory leak
3/ fix a(nother) possible memory corruption with xdr encoding of
   readdirplus responses.
4/ Fix minor timing issue with authentication cache flushing.

Thanks,
NeilBrown



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
