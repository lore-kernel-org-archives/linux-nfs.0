From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: linus 2.4.20 nfs performance problem
Date: Tue, 16 Mar 2004 08:26:46 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DD6F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HP7-0001Dr-Gj
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:26:57 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HP6-0005QK-Eo
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:26:56 -0800
To: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
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

i don't think these limits are the problem.  the congestion control
and slot table limits should put these processes to sleep, not leave
them in D state, right?  same for the per-mountpoint pages in flight
limit.

valery, your message was a little garbled.  did you say that there
was very little idle left on the clients?  is keystroke responsiveness
affected by this "overload" condition?

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]=20
> Sent: Tuesday, March 16, 2004 11:08 AM
> To: Fabiano Reis
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] linus 2.4.20 nfs performance problem
>=20
>=20
> P=E5 ty , 16/03/2004 klokka 08:37, skreiv Fabiano Reis:
> > looks like you are getting the maximum number of nfs operations by=20
> > mountpoint. See nfs.sourceforge.net
> >=20
> > The maximum nfs operations by mountpoint for kernel < 2.5.47 is 256
> >=20
> > I=B4m getting the same problem with kernel 2.4.20. I ipgraded a nfs=20
> > client to kernel 2.6 and I still getting the same problem. Maybe a=20
> > solution is to upgrade the server and client to kernel 2.6 (I didnt=20
> > tested it yet)
>=20
> There is a second limit: the RPC client limits the number of=20
> RPC requests it can have outstanding on the wire.
>=20
> On TCP, that limit is always 16 requests. On UDP, there is a=20
> congestion control algorithm that will reduce that limit=20
> dynamically if the network is losing packets (or if the=20
> server is dropping them).
>=20
> Note: 2.6.5-rc1 contains a patch by Chuck Lever that allows=20
> you to change that upper limit of 16 requests by means of a=20
> /proc interface.
>=20
> Cheers,
>  Trond
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President=20
> and CEO of GenToo technologies. Learn everything from=20
> fundamentals to system=20
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=3Dick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
