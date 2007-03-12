From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: nfs-utils patch for mount-reserved-port
Date: Mon, 12 Mar 2007 18:14:35 +0100
Message-ID: <200703121814.36739.olaf.kirch@oracle.com>
References: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQo8s-0000L6-IL
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:17:02 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HQo8t-0008GJ-6c
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:17:04 -0700
In-Reply-To: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
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

On Monday 12 March 2007 16:55, Talpey, Thomas wrote:
> Only create a mount-time reserved port socket for kernels
> which require it (pre-2.1.32/nfs_mount_version 1).

I like this approach. Whether or not to remove compatibility
for ancient versions is another debate - but anything that
reduces the number of privports mount consumes is certainly
a big advantage.

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
