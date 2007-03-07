From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils, e_maptype
Date: Wed, 7 Mar 2007 16:28:44 -0500
Message-ID: <20070307212844.GQ26553@fieldses.org>
References: <20070307022107.GC27862@fieldses.org>
	<200703072123.47224.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP3g9-0007TW-87
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:28:10 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP3g9-0005GC-94
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:28:09 -0800
In-Reply-To: <200703072123.47224.okir@lst.de>
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

On Wed, Mar 07, 2007 at 09:23:45PM +0100, Olaf Kirch wrote:
> On Wednesday 07 March 2007 03:21, J. Bruce Fields wrote:
> > Anybody know what the e_maptype export field is for?  It seems to be
> > unused.
> 
> IINM it goes back to the unfsd days. You could do different types of uid
> mapping there - 1:1 mapping, using NIS, or using some funky contraption called
> rpc.ugidd. Yes, we had uid mapping before NFSv4, and no, it wasnt pretty :-)

Some things are just timeless.

So does that someone somewhere could theoretically be using this code
right now?  On a quick glance I'd convinced myself it was totally dead,
but I wasn't thinking about unfsd.  I have no clue how it interacts with
anything else in nfs-utils.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
