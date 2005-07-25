From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 17:27:10 -0400
Message-ID: <1122326830.19759.11.camel@lade.trondhjem.org>
References: <20050725211727.18327.qmail@web33904.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxATz-0003Px-FM
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 14:27:31 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DxATy-0004cA-3Q
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 14:27:31 -0700
To: Bill Johnstone <beejstone3@yahoo.com>
In-Reply-To: <20050725211727.18327.qmail@web33904.mail.mud.yahoo.com>
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

m=C3=A5 den 25.07.2005 Klokka 14:17 (-0700) skreiv Bill Johnstone:
> Hello, and thanks for the response.
>=20
> The applicable kernel .config file for the client has
> "CONFIG_NFS_V3=3Dy", which is as I had stated in the original message.
>=20
> It does not have CONFIG_NFSD_V3 set, however.  But I don't think the
> client should need that, correct?

It shouldn't, no.

Try combining a debugging dump ('echo "1" >/proc/sys/sunrpc/nfs_debug')
with a tcpdump on the client and see what that gives you.

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
