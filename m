From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "nfs warning: mount version older than kernel"
Date: Mon, 27 Jun 2005 09:44:37 -0400
Message-ID: <1119879878.8462.4.camel@lade.trondhjem.org>
References: <42C000FC.5080000@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DmvNG-00032j-Kk
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 08:18:14 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DmvNE-00013p-3l
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 08:18:14 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DmtxL-0005Hs-1w
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 06:47:24 -0700
To: "R. Adelsberger" <xiphias@web.de>
In-Reply-To: <42C000FC.5080000@web.de>
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

m=C3=A5 den 27.06.2005 Klokka 15:37 (+0200) skreiv R. Adelsberger:
> Hi!
>=20
> I receive this message since I decided to mount some parts of my home
> folder (via autofs) from a server.
> Although I searched during several months for a solution and reviewed my
> configs several times, I was not able to resolve this issue.
> Could anybody tell me, where the problem lies - or, if you need more
> information, tell me what I should further reveal...
>=20
> My kernel (2.6 series - currently 2.6.11) on the client machine has the
> nfs v3 support and the server the apropriate server support.
> Nevertheless, my logfile is full of the messages mentioned in the
> subject. I have the most recent (stable) version of mount installed...

Those messages are harmless and can be ignored. The 2.6.13 kernel will
contain a patch (already merged into Linus' git repository) that
suppresses them.

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
