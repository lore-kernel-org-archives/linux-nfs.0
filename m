From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS Client Performance Question
Date: Wed, 13 Jul 2005 12:04:16 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539DAB@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsmWt-0000uN-CD
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 12:04:23 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DsmWs-0006BH-Tn
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 12:04:23 -0700
To: <penney@msu.edu>
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

reads and writes should be asynchronous if your page size is indeed 16KB
and your r/wsize is 32KB.

"/usr/bin/time -v date" will report your client's page size, and "cat
/proc/mounts" will show your actual rsize and wsize.  you may find that
the server has negotiated these down to 8KB even if you requested larger
on your mount command line.

> -----Original Message-----
> From: Chris Penney [mailto:cpenney@gmail.com]=20
> Sent: Wednesday, July 13, 2005 2:56 PM
> To: Lever, Charles
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS Client Performance Question
>=20
>=20
> The Itanium page size is 16k (unless I'm mistaken) and the r/wsize is
> 32k so can that still be it?  Or are you saying that it is because the
> size of the write is only 4k?
>=20
>    Chris
>=20
> On 7/13/05, Lever, Charles <Charles.Lever@netapp.com> wrote:
> > hi chris-
> >=20
> > take a look at the NFS faq (http://nfs.sourceforge.net) i=20
> believe this
> > issue is addressed there.
> >=20
> > the problem is your itanium uses pages larger than your=20
> r/wsize setting,
> > which forces the client into synchronous I/O mode for NFS.  some
> > possible workarounds:
> >=20
> > 1.  upgrade to a late model 2.6 kernel where this is fixed
> >=20
> > 2.  reduce the page size on your client system
> >=20
> > 3.  increase the r/wsize to something larger than your page size
> >=20
> > 4.  compile your client with a larger maximum transfer size=20
> so you can
> > do 3.
> >=20
> > the goal is to have r/wsize be equal to or greater than=20
> your client's
> > page size.
> >=20
> > > -----Original Message-----
> > > From: Chris Penney [mailto:cpenney@gmail.com]
> > > Sent: Wednesday, July 13, 2005 2:30 PM
> > > To: nfs@lists.sourceforge.net
> > > Subject: [NFS] NFS Client Performance Question
> > >
> > >
> > > I have a large smp SGI Itanium box box running a 2.4.21=20
> kernel and I'm
> > > getting fairly bad NFS performance, esp. when doing=20
> random writes to
> > > an unloaded NFS server.  The box is rather busy doing=20
> computation and
> > > a lot of i/o to /tmp; however, there is little network i/o (<100
> > > KB/s).  I use iozone with the following options to test=20
> "-c -e -i 2 -w
> > > -s 16m" and use an unloaded Sun NFS server (same=20
> performance results
> > > with Linux NFS servers, but they are all under load so I=20
> test with the
> > > Sun).  I only get ~2.5MB/s using the above test.  I found=20
> an Intel box
> > > still running a 2.4.20 kernel and it gets 15MB/s.  On a=20
> 2.6 kernel box
> > > the rate jumps to 46MB/s (nice work).
> > >
> > > I did some sniffing on the Sun and noticed that the=20
> problem Itanium
> > > system was not doing async writes (snips are from the start of the
> > > write test):
> > >
> > > [snip]
> > > redhat -> server NFS C WRITE3 FH=3D40E5 at 1478656 for 4096 =
(ASYNC)
> > > server -> redhat NFS R WRITE3 OK 4096 (ASYNC)
> > > redhat -> server NFS C WRITE3 FH=3D40E5 at 1179648 for 4096 =
(ASYNC)
> > > [snip]
> > > itanium -> server NFS C WRITE3 FH=3D40E5 at 4239360 for 4096 =
(FSYNC)
> > > server -> server NFS R WRITE3 OK 4096 (FSYNC)
> > > server -> server NFS C WRITE3 FH=3D40E5 at 15101952 for 4096 =
(FSYNC)
> > > [snip]
> > >
> > > The client mount options are:
> > >    =
rw,nosuid,bg,hard,intr,nfsvers=3D3,tcp,rsize=3D32768,wsize=3D32768
> > >
> > > So my question: Is the Itanium system not doing async nfs=20
> i/o because
> > > nfract_sync has been exceeded due to local i/o to /tmp or is it
> > > something else?  Is there anything I can do to improve=20
> NFS performance
> > > on this box?
> > >
> > >    Chris
> > >
> > >
> > > -------------------------------------------------------
> > > This SF.Net email is sponsored by the 'Do More With Dual!'
> > > webinar happening
> > > July 14 at 8am PDT/11am EDT. We invite you to explore the
> > > latest in dual
> > > core and dual graphics technology at this free one hour event
> > > hosted by HP,
> > > AMD, and NVIDIA.  To register visit=20
> http://www.hp.com/go/dualwebinar
> > >=20
> _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > >
> >
>=20


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
