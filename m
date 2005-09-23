From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils 2 of 10 - Incorporate some clean up	code
 from Ulrich Drepper
Date: Fri, 23 Sep 2005 12:56:15 -0400
Message-ID: <433433AF.1040702@RedHat.com>
References: <433414D0.8030905@RedHat.com> <1127490778.8328.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIqqV-0003Vo-Oq
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 09:56:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIqqU-0006eL-FQ
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 09:56:24 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1127490778.8328.6.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
>  Why not clean that up further by putting it into a simple library
> function that takes an argument consisting of the pipes you do not want
> it to close?
Good point... its just one things that appeared one day (Uli when
nuts and changed a bunch of system daemons) and since everything
seem to still work I never gave it a second thought...

Where would be the best place for this this new routine?
If we put the routine in libnfs.a, then both the
idmapd and svcgssd daemons would have to start
linking it which may or may not cause a problem..
Or maybe a new local library??

steved.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
