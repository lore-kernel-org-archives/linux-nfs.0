From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: 2.4.19 hang (was unlink perf pb !)
Date: Wed, 14 Aug 2002 18:21:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E22B@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'Lever, Charles'" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes4.atos-group.com ([160.92.18.11])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f0v8-0004Ct-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 09:22:54 -0700
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


well I try ! but for now :
* all I have is a console message saying "RPC: waiting for request =
slot"
* when I turn debug on : system slow to a crawl ! load average goes to =
more
than 700 ! but it works
         never crash !
* when I turn debug of : crash with lot's of process blocked ! running
process seems to be kswapd !

I'v tried to but debug just when system near crash, but then it slow =
down,
and get back to "life" slowly.

more : I have some difficulties to reproduce what i was having =
yesterday !

valery

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Wednesday, August 14, 2002 2:53 PM
> To: Brasseur Val=E9ry
> Cc: 'Lever, Charles'; nfs@lists.sourceforge.net
> Subject: Re: [NFS] 2.4.19 hang (was unlink perf pb !)
>=20
>=20
> >>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> =
writes:
>=20
>      > try a stock 2.4.19 without nfs patches : no hang !  seems that
>      > nfs patches broke something !
>=20
> Can you get me a trace of the hang using the command
>=20
>    echo "1" > /proc/sys/sunrpc/rpc_debug
>=20
> Cheers,
>   Trond
>=20


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
