From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: WebNFS support
Date: Fri, 16 Feb 2007 15:14:49 +0100
Message-ID: <200702161514.50493.olaf.kirch@oracle.com>
References: <45D5FC14.8E99.00F4.0@novell.com>
	<Pine.LNX.4.64.0702161427080.32604@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Cc: Peter =?iso-8859-15?q?=C5strand?= <astrand@cendio.se>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HI3rU-0002Np-Ec
	for nfs@lists.sourceforge.net; Fri, 16 Feb 2007 06:14:57 -0800
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HI3rV-0005PJ-Uw
	for nfs@lists.sourceforge.net; Fri, 16 Feb 2007 06:14:58 -0800
In-Reply-To: <Pine.LNX.4.64.0702161427080.32604@maggie.lkpg.cendio.se>
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

On Friday 16 February 2007 14:31, Peter =C5strand wrote:
> I have some plans to implement WebNFS support in userspace server unfs3,
> though. Since it can already run the NFS and MOUNT protocol on the same
> TCP port, I haven't considered WebNFS support critical.

At some point in the very distant past I added WebNFS support to
unfsd. There was zero interest in it. I think webnfs was an Internet
bubble idea, ie very trendy but devoid of any technical use.
May it rest in peace.

Olaf
-- =

Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
