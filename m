From: Olaf Kirch <okir@lst.de>
Subject: Re: nfs-utils, e_maptype
Date: Wed, 7 Mar 2007 21:23:45 +0100
Message-ID: <200703072123.47224.okir@lst.de>
References: <20070307022107.GC27862@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP2g9-0000Xf-He
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:24:06 -0800
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1HP2g6-0001S2-Jd
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:24:04 -0800
In-Reply-To: <20070307022107.GC27862@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday 07 March 2007 03:21, J. Bruce Fields wrote:
> Anybody know what the e_maptype export field is for?  It seems to be
> unused.

IINM it goes back to the unfsd days. You could do different types of uid
mapping there - 1:1 mapping, using NIS, or using some funky contraption called
rpc.ugidd. Yes, we had uid mapping before NFSv4, and no, it wasnt pretty :-)

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
