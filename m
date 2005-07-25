From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 14:17:27 -0700 (PDT)
Message-ID: <20050725211727.18327.qmail@web33904.mail.mud.yahoo.com>
References: <1122324669.19759.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxAKN-0002vV-Gv
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 14:17:35 -0700
Received: from web33904.mail.mud.yahoo.com ([66.163.178.68])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1DxAKL-0002NJ-5X
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 14:17:35 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1122324669.19759.8.camel@lade.trondhjem.org>
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

Hello, and thanks for the response.

The applicable kernel .config file for the client has
"CONFIG_NFS_V3=3Dy", which is as I had stated in the original message.

It does not have CONFIG_NFSD_V3 set, however.  But I don't think the
client should need that, correct?

Thanks.

--- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> m=E5 den 25.07.2005 Klokka 13:40 (-0700) skreiv Bill Johnstone:
>=20
> > On the client, trying to perform a "mount -o vers=3D3 <server
> > IP>:<exportname> <local mountpoint>" gives the error "NFSv3 not
> > supported!" and the mount fails.  If I remove the options to
> > rpc.mountd,   and do not specify "-o vers=3D3" on the client side,
> then
> > mountd listens for protocol versions 1 and 2, and the mount
> succeeds.
>=20
> Sounds like the client doesn't have NFSv3 support compiled in. What
> does
> your .config file say?
>=20
> Cheers,
>   Trond


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
