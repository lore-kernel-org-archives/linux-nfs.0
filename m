From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel 2.6 vs. Kernel 2.4: higher NFS traffic
Date: Wed, 27 Jul 2005 13:28:11 -0400
Message-ID: <1122485291.8068.14.camel@lade.trondhjem.org>
References: <20050727112639.22B1.BRANDEN@terra.com.br>
	 <1122484635.8068.8.camel@lade.trondhjem.org>
	 <20050727142031.22BF.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dxphl-0002vi-P8
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 10:28:29 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dxphk-0008HM-9G
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 10:28:29 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050727142031.22BF.BRANDEN@terra.com.br>
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

on den 27.07.2005 Klokka 14:25 (-0300) skreiv Filipe Brandenburger:

> Why is there so much difference? Why does 2.6 make 21% getattr while 2.4
> does less then 1%?

We no longer allow post-op attributes to update the attribute cache. It
leads to some nasty races.

> Are there any mount options that I can use to do some tuning on this?

No.



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
