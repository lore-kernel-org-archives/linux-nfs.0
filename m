From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs break
Date: Mon, 20 Jun 2005 09:22:48 -0400
Message-ID: <1119273768.11129.57.camel@lade.trondhjem.org>
References: <42B5BB6F.9030104@gmail.com>
	 <1119208054.11291.21.camel@lade.trondhjem.org> <42B5DEE0.5070600@gmail.com>
	 <42B6B191.3050004@rhythm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oded Maimon <oded.maimon@gmail.com>, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Greg Bradner <gregb@rhythm.com>
In-Reply-To: <42B6B191.3050004@rhythm.com>
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

m=C3=A5 den 20.06.2005 Klokka 05:07 (-0700) skreiv Greg Bradner:
> This is for linux:
>=20
> # turn on linux nfs debug
> echo 1 > /proc/sys/sunrpc/nfs_debug

Actually, there is a whole bitmask of values you can use here in order
to selectively turn on or off parts of the debugging code.
See the NFSDBG_* defines in include/linux/nfs_fs.h.

There are similar bitmasks for the RPC, NLM (i.e. lockd) and nfsd
subsystems in include/linux/sunrpc/debug.h, include/linux/lockd/debug.h
and include/linux/nfsd/debug.h. These bitmasks act
on /proc/sys/sunrpc/rpc_debug, /proc/sys/sunrpc/nlm_debug
and /proc/sys/sunrpc/nfsd_debug respectively.

Note as I said earlier, though, this is really designed for debugging
purposes. There are no plans to convert it into an administrative tool.

Cheers,
  Trond

> # turn off linux nfs debug
> echo 0 > /proc/sys/sunrpc/nfs_debug
>=20
>=20
> Oded Maimon wrote:
>=20
> >
> >
> > Trond Myklebust wrote:
> >
> >>su den 19.06.2005 Klokka 20:37 (+0200) skreiv Oded Maimon:
> >> =20
> >>
> >>>Hi,
> >>>
> >>>is there any way to make nfs-client create more informative logs?
> >>>
> >>>somthing like levels of logs?
> >>>   =20
> >>>
> >>
> >>The only logging that the current NFS client supports is the informatio=
n
> >>provided by "nfsstat".
> >>
> >>It is also possible to enable selective debug tracing in the case of
> >>client bugs, but those traces were not designed with system
> >>administration in mind, and so are unlikely to be very useful.
> >>
> >>Cheers,
> >>  Trond
> >>
> >>
> >> =20
> >>
> > thanks, that will be very helpful,
> > can you please tell me how can i enable the debug tracing, just to see=20
> > what i can get from that?
> > ------------------------------------------------------- SF.Net email=20
> > is sponsored by: Discover Easy Linux Migration Strategies from IBM.=20
> > Find simple to follow Roadmaps, straightforward articles, informative=20
> > Webcasts and more! Get everything you need to get up to speed, fast.=20
> > http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclick=20
> > _______________________________________________ NFS maillist -=20
> > NFS@lists.sourceforge.net=20
> > https://lists.sourceforge.net/lists/listinfo/nfs=20
>=20
>=20



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
