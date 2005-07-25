From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 16:51:09 -0400
Message-ID: <1122324669.19759.8.camel@lade.trondhjem.org>
References: <20050725204047.82740.qmail@web33907.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dx9vC-0001mn-IX
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 13:51:34 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dx9vA-0004lw-9f
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 13:51:34 -0700
To: Bill Johnstone <beejstone3@yahoo.com>
In-Reply-To: <20050725204047.82740.qmail@web33907.mail.mud.yahoo.com>
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

m=C3=A5 den 25.07.2005 Klokka 13:40 (-0700) skreiv Bill Johnstone:

> On the client, trying to perform a "mount -o vers=3D3 <server
> IP>:<exportname> <local mountpoint>" gives the error "NFSv3 not
> supported!" and the mount fails.  If I remove the options to
> rpc.mountd,   and do not specify "-o vers=3D3" on the client side, then
> mountd listens for protocol versions 1 and 2, and the mount succeeds.

Sounds like the client doesn't have NFSv3 support compiled in. What does
your .config file say?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
