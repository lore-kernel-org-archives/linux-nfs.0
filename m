From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 9 Dec 2004 09:54:58 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0412090954400.23728-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcK4r-00026K-Th
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 00:55:09 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CcK4o-00016O-So
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 00:55:08 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id AB0F025DAB4
	for <nfs@lists.sourceforge.net>; Thu,  9 Dec 2004 09:54:58 +0100 (CET)
To: nfs@lists.sourceforge.net
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

On Wed, 8 Dec 2004, Mike Waychison wrote:

> This has been bugging me for a while.  The fact that we are limitting
> ourselves to a single nfs mount per port.  From what I can tell, Solaris
> shares the transports between nfs mounts from the same server and saves
> themselves a lot of trouble with running out of port numbers in doing so.
> 
> The attached patch does the same for Linux against 2.6.9.  We share
> xprts from existing connections, effectively removing any limit on the
> number of nfs mounts we have in the system.

Good work! 


> The only thing to worry about now is any talking to the portmapper or
> mountd from userspace using tcp, which will put the reserved ports in
> TIME_WAIT state.  This can limit the 'speed' at which we mount many
> mounts.

How about using SO_REUSEADDR?

-- 
Peter Åstrand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Linköping        Phone: +46-13-21 46 00




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
