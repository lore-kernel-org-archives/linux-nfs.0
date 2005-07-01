From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange problem with ACL over NFS
Date: Sat, 02 Jul 2005 00:51:56 +0200
Message-ID: <1120258316.8246.0.camel@lade.trondhjem.org>
References: <42C3DBDC.5050803@bio.ifi.lmu.de>
	 <1120157929.8922.14.camel@lade.trondhjem.org>
	 <42C4DA08.8070202@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DoUMp-0002Sg-5y
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 15:52:15 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DoUMn-0005Ev-KL
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 15:52:15 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <42C4DA08.8070202@bio.ifi.lmu.de>
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

fr den 01.07.2005 Klokka 07:52 (+0200) skreiv Frank Steiner:

> So this looks more like a client bug to me, because it is not always
> the first mount from the same server that does not have ACL, but the
> first overall NFS mount. Like the client was not able to initialize
> ACLs for NFS before the first mount is done...

I won't buy that argument until I see a tcpdump to prove it ;-)

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
