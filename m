From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs-utils, e_maptype
Date: Thu, 08 Mar 2007 07:31:32 -0500
Message-ID: <EXNANE01Ogl4rhYQYx30000007d@exnane01.hq.netapp.com>
References: <20070307022107.GC27862@fieldses.org>
	<200703072123.47224.okir@lst.de>
	<20070307212844.GQ26553@fieldses.org>
	<200703080949.54293.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPHnA-00046D-QG
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 04:32:22 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPHnB-000122-Qw
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 04:32:23 -0800
In-Reply-To: <200703080949.54293.okir@lst.de>
References: <20070307022107.GC27862@fieldses.org>
	<200703072123.47224.okir@lst.de>
	<20070307212844.GQ26553@fieldses.org>
	<200703080949.54293.okir@lst.de>
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

At 03:49 AM 3/8/2007, Olaf Kirch wrote:
>I think it's safe to ignore unfsd.

I agree, but I've been surprised to see some of the embedded (ARM) ports
using it, they have .deb-style package installs and everything. Many of the
users of these packages don't have a lot of NFS depth. The tiny NAS boxes
in general don't even enable NFS by default, the users are on their own and
unfsd means they don't have to muck with the embedded kernel.

That said, I don't think these users even know about userid mapping types.
Also most of the boxes are now doing what they call knfsd. Just a data point
that unfsd isn't totally dead.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
