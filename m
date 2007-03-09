From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux clients
	to a solaris server
Date: Fri, 9 Mar 2007 15:46:18 +0100
Message-ID: <200703091546.19536.olaf.kirch@oracle.com>
References: <45F004BD.1070500@biochem.mpg.de> <45F15018.1060804@biochem.mpg.de>
	<EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPgO4-0000pq-Pq
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 06:48:04 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPgO5-0006PX-MC
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 06:48:07 -0800
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l29ElOO4001196
	for <nfs@lists.sourceforge.net>; Fri, 9 Mar 2007 08:47:24 -0600
Received: from rcsmt250.oracle.com (rcsmt250.oracle.com [148.87.90.195])
	by rgmgw2.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l29E5mYO000586
	for <nfs@lists.sourceforge.net>; Fri, 9 Mar 2007 07:47:23 -0700
In-Reply-To: <EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
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

On Friday 09 March 2007 14:09, Talpey, Thomas wrote:
> The mount command creates and binds a socket in userspace, then
> passes it to the kernel for connecting to the server. Newer kernels
> don't use this socket however, and it is closed when the mount
> completes. However, it's a TCP socket and is bound to a privileged
> port, the socket isn't destroyed immediately, it sticks around for
> a short time.

Why do we keep creating those at all?

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
