From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: df hangs on down nfs server mounted with hard,intr,can't kill
Date: Mon, 15 Mar 2004 14:57:10 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07BC3@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B311O-0005Df-Qk
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 14:57:22 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B311N-0000qB-5A
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 14:57:21 -0800
To: "Steve Dickson" <SteveD@redhat.com>
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

hi steve-

downloaded your patches from 30 dec '03.

zeroing the RPC counters is a little outside the scope of my
patch, as i'm providing a whole new interface that is outside
the /proc/net/rpc/* hierarchy.  this is work that might/should
go in separately from mine?  (my patch will allow zeroing the
stats that i'm providing, which are different than the ones
already provided in /proc/net/rpc/nfs).

but one question:  why do you use a hex value for this interface?
i thought /proc was supposed to be human-readable.  why not use
"z" "zc" "zs" just like your nfsstat arguments so that one can
just as easily do:

  echo "zs" > /proc/net/rpc/nfs

as well as

  nfsstat -zs

> -----Original Message-----
> From: Steve Dickson [mailto:SteveD@redhat.com]=20
> Sent: Monday, March 15, 2004 1:16 PM
> To: Trond Myklebust
> Cc: Yusuf Goolamabbas; nfs@lists.sourceforge.net
> Subject: Re: [NFS] df hangs on down nfs server mounted with=20
> hard,intr, can't kill
>=20
>=20
> Trond Myklebust wrote:
>=20
> >P=E5 m=E5 , 15/03/2004 klokka 00:21, skreiv Yusuf Goolamabbas:
> > =20
> >
> >>Also, what's the status with the nfszerostats patch from=20
> Steve Dickson=20
> >>of Redhat
> >>
> >>http://people.redhat.com/steved/NFS/nfszerostats/
> >>   =20
> >>
> >
> >Chuck is currently working on some enhanced NFS statistics=20
> patches. I=20
> >imagine he will take steps to include Steve's patches in his=20
> work, and=20
> >then push them to me.
> > =20
> >
> FYI... The nfs-utils code to support nfszerostats is already
> in the FC2 rawhides... I'm hopeful Neil will include this
> patch in the next nfs-utils release....
>=20
> SteveD.
>=20
>=20
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
