From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: 2.4.19 hang (was unlink perf pb !)
Date: Mon, 19 Aug 2002 14:09:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E233@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'Lever, Charles'" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes8.atos-group.com ([160.92.18.57] helo=hermes8.segin.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17glLr-0007U8-00
	for <nfs@lists.sourceforge.net>; Mon, 19 Aug 2002 05:09:43 -0700
To: 'Trond Myklebust' <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

more on my problem ...

* it seems that when using tcp mount the hang appears more often and =
more
quickly !
* on stock 2.4.19 which I have is a limited perf but it works
* on 2.4.19 + nfs patches I have limited perf + hang !

I said I have limited perf because the NetApp filer I use as server is =
a 880
which is given for more than 15000 nfs/ops  and with my Linux box I =
can't do
more than 2/3000 ops when I am the only client !

how can I track this down ?

valery

> -----Original Message-----
> From: Brasseur Val=E9ry [mailto:Valery.Brasseur@atosorigin.com]
> Sent: Wednesday, August 14, 2002 6:22 PM
> To: 'Trond Myklebust'
> Cc: 'Lever, Charles'; nfs@lists.sourceforge.net
> Subject: RE: [NFS] 2.4.19 hang (was unlink perf pb !)
>=20
>=20
>=20
> well I try ! but for now :
> * all I have is a console message saying "RPC: waiting for=20
> request slot"
> * when I turn debug on : system slow to a crawl ! load=20
> average goes to more
> than 700 ! but it works
>          never crash !
> * when I turn debug of : crash with lot's of process blocked ! =
running
> process seems to be kswapd !
>=20
> I'v tried to but debug just when system near crash, but then=20
> it slow down,
> and get back to "life" slowly.
>=20
> more : I have some difficulties to reproduce what i was=20
> having yesterday !
>=20
> valery
>=20
> > -----Original Message-----
> > From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> > Sent: Wednesday, August 14, 2002 2:53 PM
> > To: Brasseur Val=E9ry
> > Cc: 'Lever, Charles'; nfs@lists.sourceforge.net
> > Subject: Re: [NFS] 2.4.19 hang (was unlink perf pb !)
> >=20
> >=20
> > >>>>> " " =3D=3D Brasseur Val=E9ry=20
> <Valery.Brasseur@atosorigin.com> writes:
> >=20
> >      > try a stock 2.4.19 without nfs patches : no hang ! =20
> seems that
> >      > nfs patches broke something !
> >=20
> > Can you get me a trace of the hang using the command
> >=20
> >    echo "1" > /proc/sys/sunrpc/rpc_debug
> >=20
> > Cheers,
> >   Trond
> >=20
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by: Dice - The leading online job =
board
> for high-tech professionals. Search and apply for tech jobs today!
> http://seeker.dice.com/seeker.epl?rel_code1
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
