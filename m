From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: linus 2.4.20 nfs performance problem
Date: Wed, 17 Mar 2004 17:38:16 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B38401648912@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3e3p-0002NY-NB
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 08:38:29 -0800
Received: from srv-grp-s01.axime.com ([160.92.18.102])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3e3j-0000Yv-1s
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 08:38:23 -0800
To: "David Dougall" <davidd@et.byu.edu>,
	<nfs@lists.sourceforge.net>
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

we have done that : put all client on Gb as the netapp filer was.=20

at first it was worsed ! for now the only thing which get better result =
is when we have put more memory in clients letting the Gb card in place =
too.

valery
> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net
> [mailto:nfs-admin@lists.sourceforge.net]On Behalf Of David Dougall
> Sent: Wednesday, March 17, 2004 4:57 PM
> To: nfs@lists.sourceforge.net
> Subject: RE: [NFS] linus 2.4.20 nfs performance problem
>=20
>=20
> I know in the past we had symptoms like this when we had mismatched
> speeds between server and client.  If you can, change all machines to
> gigabit or 100Mbit.
> --David Dougall
>=20
>=20
> On Tue, 16 Mar 2004, Trond Myklebust wrote:
>=20
> > P=E5 ty , 16/03/2004 klokka 11:26, skreiv Lever, Charles:
> > > i don't think these limits are the problem.  the=20
> congestion control
> > > and slot table limits should put these processes to=20
> sleep, not leave
> > > them in D state, right?  same for the per-mountpoint=20
> pages in flight
> > > limit.
> >
> > man top
> >
> >        w: S  --  Process Status
> >           The status of the task which can be one of:
> >              =FFD=FF =3D uninterruptible sleep
> >              =FFR=FF =3D running
> >              =FFS=FF =3D sleeping
> >              =FFT=FF =3D traced or stopped
> >              =FFZ=FF =3D zombie
> >
> > Cheers,
> >  Trond
> >
> >
> > -------------------------------------------------------
> > This SF.Net email is sponsored by: IBM Linux Tutorials
> > Free Linux tutorial presented by Daniel Robbins, President=20
> and CEO of
> > GenToo technologies. Learn everything from fundamentals to system
> > administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=CCk
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=3Dick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
