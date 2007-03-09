From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux clients
	to a solaris server
Date: Fri, 9 Mar 2007 15:25:14 +0100
Message-ID: <200703091525.15438.olaf.kirch@oracle.com>
References: <45F004BD.1070500@biochem.mpg.de>
	<EXNANE01FRaqbC8wSA10000007f@exnane01.hq.netapp.com>
	<45F15018.1060804@biochem.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Bernhard Busch <bbusch@biochem.mpg.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPg5I-000795-1T
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 06:28:40 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPg5G-0004NF-Ix
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 06:28:41 -0800
In-Reply-To: <45F15018.1060804@biochem.mpg.de>
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

On Friday 09 March 2007 13:16, Bernhard Busch wrote:
> But , if i remove the sleep command the
>
> nfs bindresvport: Address already in use

This is a message from the mount command, and it's really
a problem in the RPC library. At some point, mount would
use 2 ports per mount (one when doing pmap_getport, the
other when talking to the server's mountd). I think the getport
call was fixed a while ago, as it doesn't really need a privport
at all. But for many NFS servers, a privileged port is a must
when talking to mountd.

I think one reasonable fix for this would be to make mount
(or the rpc library) issue a setsockopt(SOL_SOCKET, SO_REUSEADDR)
*after* it's done with the request, and before closing the socket. That way,
we can immediately rebind to this port, without risking confusion by having to
mount commands bind to the same port at the same time.

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
