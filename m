From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs-utils 2 of 10 - Incorporate some clean
	up	code from Ulrich Drepper
Date: Fri, 23 Sep 2005 14:23:36 -0400
Message-ID: <1127499816.8328.17.camel@lade.trondhjem.org>
References: <433414D0.8030905@RedHat.com>
	 <1127490778.8328.6.camel@lade.trondhjem.org>  <433433AF.1040702@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIsDB-0007IG-4x
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 11:23:53 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIsD6-0007Sj-37
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 11:23:48 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <433433AF.1040702@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
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

fr den 23.09.2005 Klokka 12:56 (-0400) skreiv Steve Dickson:

> Where would be the best place for this this new routine?
> If we put the routine in libnfs.a, then both the
> idmapd and svcgssd daemons would have to start
> linking it which may or may not cause a problem..
> Or maybe a new local library??

How about in libmisc?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
