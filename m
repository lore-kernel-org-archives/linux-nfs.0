From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: linus 2.4.20 nfs performance problem
Date: Tue, 16 Mar 2004 17:29:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B3840164890A@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HRw-0001yw-5M
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:29:52 -0800
Received: from srv-grp-s01.axime.com ([160.92.18.102])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HRv-0006B8-0B
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:29:51 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

no, there is plenty of idle on the client !
only the load average is high !

note : on our latest experiment we have seen that adding more memory =
(ie: now we are at 4Gb), and perhaps going over Gb network is a way =
better....


Valery BRASSEUR                      | Phone # +33 320 60 7982=20
Atosorigin Branche Multimedia        | Fax   # +33 320 60 7649
  Tout krab-la m=F2 an bari-la=20
  (Tous les crabes sont morts dans le baril).


> -----Original Message-----
> From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> Sent: Tuesday, March 16, 2004 5:27 PM
> To: Brasseur Val=E9ry
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] linus 2.4.20 nfs performance problem
>=20
>=20
> i don't think these limits are the problem.  the congestion control
> and slot table limits should put these processes to sleep, not leave
> them in D state, right?  same for the per-mountpoint pages in flight
> limit.
>=20
> valery, your message was a little garbled.  did you say that there
> was very little idle left on the clients?  is keystroke responsiveness
> affected by this "overload" condition?
>=20
> > -----Original Message-----
> > From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]=20
> > Sent: Tuesday, March 16, 2004 11:08 AM
> > To: Fabiano Reis
> > Cc: nfs@lists.sourceforge.net
> > Subject: Re: [NFS] linus 2.4.20 nfs performance problem
> >=20
> >=20
> > P=E5 ty , 16/03/2004 klokka 08:37, skreiv Fabiano Reis:
> > > looks like you are getting the maximum number of nfs=20
> operations by=20
> > > mountpoint. See nfs.sourceforge.net
> > >=20
> > > The maximum nfs operations by mountpoint for kernel <=20
> 2.5.47 is 256
> > >=20
> > > I=B4m getting the same problem with kernel 2.4.20. I ipgraded a =
nfs=20
> > > client to kernel 2.6 and I still getting the same=20
> problem. Maybe a=20
> > > solution is to upgrade the server and client to kernel=20
> 2.6 (I didnt=20
> > > tested it yet)
> >=20
> > There is a second limit: the RPC client limits the number of=20
> > RPC requests it can have outstanding on the wire.
> >=20
> > On TCP, that limit is always 16 requests. On UDP, there is a=20
> > congestion control algorithm that will reduce that limit=20
> > dynamically if the network is losing packets (or if the=20
> > server is dropping them).
> >=20
> > Note: 2.6.5-rc1 contains a patch by Chuck Lever that allows=20
> > you to change that upper limit of 16 requests by means of a=20
> > /proc interface.
> >=20
> > Cheers,
> >  Trond
> >=20
> >=20
> > -------------------------------------------------------
> > This SF.Net email is sponsored by: IBM Linux Tutorials
> > Free Linux tutorial presented by Daniel Robbins, President=20
> > and CEO of GenToo technologies. Learn everything from=20
> > fundamentals to system=20
> > administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=3Dick
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net=20
> > https://lists.sourceforge.net/lists/listinfo/n> fs
> >=20
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
