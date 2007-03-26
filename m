From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] provide non-standard getgrouplist()
	in	libnfsidmap when need be
Date: Mon, 26 Mar 2007 09:22:45 -0400
Message-ID: <1174915365.6838.6.camel@heimdal.trondhjem.org>
References: <200703250329.03353.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVpA1-0004Wj-Tk
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 06:22:58 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18YuNMzA1HoOu3QYrE3Ce7kydtBaQ2NZjg=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HVpA2-0007Oe-Je
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 06:23:00 -0700
In-Reply-To: <200703250329.03353.vapier@gentoo.org>
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

On Sun, 2007-03-25 at 03:29 -0400, Mike Frysinger wrote:
> libnfsidmap uses the non-standard function getgrouplist() ... the attached 
> patch takes code from FreeBSD to implement the function based on POSIX 
> functions when the system libc is not sufficient
> -mike

Why not just modify libnfsidmap to directly use the posix functions?

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
