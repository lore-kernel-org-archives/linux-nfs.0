From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 20:55:44 -0700 (PDT)
Message-ID: <20050726035544.72927.qmail@web33915.mail.mud.yahoo.com>
References: <1122334694.19759.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxGXn-0003ox-BC
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 20:55:51 -0700
Received: from web33915.mail.mud.yahoo.com ([66.163.178.79])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1DxGXm-0005qT-5G
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 20:55:51 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1122334694.19759.24.camel@lade.trondhjem.org>
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

Well, I tried a variety of things, including upgrading from "mount"
version 2.12i to 2.12q, and nfs-utils 1.0.6 to 1.0.7 .  I believe
upgrading nfs-utils (on the client side) allowed the mount to take
place  successfully.

However, now, when I run "umount", I get the message:

Bad UMNT RPC: RPC: Program/version mismatch; low version =3D 3, high
version =3D 3

What could be causing this?  This happened before and after I upgraded
the server to 1.0.7 as well.  When I mount the NFS volume, I also get a
warning that the mount version is older than the kernel -- I presume
this can be safely ignored?

Lastly,

--- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> Those numbers are unrelated to the NFS protocol version. statd
> version 1
> and portmapper version 2 should work fine.

Might I kindly suggest that this be added to the FAQ on the nfs.sf.net
homepage?  It could potentially alleviate confusion for NFS newcomers
like me.

Thanks for the help.


	=09
____________________________________________________
Start your day with Yahoo! - make it your home page=20
http://www.yahoo.com/r/hs=20
=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
