From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 19:38:14 -0400
Message-ID: <1122334694.19759.24.camel@lade.trondhjem.org>
References: <20050725223031.2952.qmail@web33905.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxCWr-0000J7-TD
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 16:38:37 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DxCWr-00066q-Hh
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 16:38:38 -0700
To: Bill Johnstone <beejstone3@yahoo.com>
In-Reply-To: <20050725223031.2952.qmail@web33905.mail.mud.yahoo.com>
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

m=C3=A5 den 25.07.2005 Klokka 15:30 (-0700) skreiv Bill Johnstone:

> NFS: NFSv3 not supported

Is this being issued by the mount program?

> nfs warning: mount version older than kernel
> NFS: mount program didn't pass remote address!

The bug appears to be in the mount program. Which version are you using?

> Also, would you mind answering the questions I had asked earlier,
> namely what to make of the versions listed for portmapper and status --
> should these be "3" in order for NFSv3 to work, or is NFSv3 expecting
> their versions to be just "2" and "1" respectively?  By "version" I am
> referring to the output in the "version" column of the rpcinfo output.

Those numbers are unrelated to the NFS protocol version. statd version 1
and portmapper version 2 should work fine.

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
