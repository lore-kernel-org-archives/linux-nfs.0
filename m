From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 4] Introduction
Date: Mon, 16 Aug 2004 13:58:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040816135256.9819.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwYgt-0008PC-5d
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 21:01:47 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BwYgs-0002aF-Q3
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 21:01:47 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
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

4 patches for knfsd.  in 2.4.28-pre1

 1/ improve checking of out-of-range lengths, particularly in write requests.
 2/ make CONFIG_NFSD_TCP non-EXPERIMENTAL and select it by default.
 3/ Allow a larger blocksize on arch's with large page size.
 4/ use llseek instead of explicitly setting f_pos in NFS i/o requests.

Thank,
NeilBrown


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
