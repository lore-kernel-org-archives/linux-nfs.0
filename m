From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: ~800 mountpoint limitation
Date: Tue, 14 Oct 2003 09:45:04 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC50F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9SIn-0003s6-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 09:45:41 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9SIm-0006NU-Cp
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 09:45:40 -0700
To: "Ogden, Aaron A." <aogden@unocal.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

trond has heard my complaints about this before....

sharing an RPC transport socket across mounts is an
interesting solution in some ways, but i'm concerned
about the performance scalability of this solution,
especially since the RPC slot table size is fixed at
a relatively small 16 entries.  imagine sharing 16
RPC slots across all the mounts on a very busy
multi-user system.  if one mount backs up (say
because one of the server's disks gets busy), that
makes all the mounts sharing that slot table unusable.

this solution also won't allow you to mount more than
800 different servers, for similar reasons to today's
800 mounts per client limitation.  you can still only
have about 800 transport sockets.

so there are some issues to be worked out.

> -----Original Message-----
> From: Ogden, Aaron A. [mailto:aogden@unocal.com]
> Sent: Tuesday, October 14, 2003 12:28 PM
> To: Trond Myklebust
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] ~800 mountpoint limitation
>=20
>=20
>=20
> Excellent!  I was hoping that you were following the=20
> discussion.  It is
> something you can fix though?  It seems that RPC may be involved as
> well...
>=20
> Is there any hope of a patch for 2.4.20+ or is this strictly 2.6 code?
>=20
> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]=20
> Sent: Tuesday, October 14, 2003 11:06 AM
> To: Ogden, Aaron A.
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] ~800 mountpoint limitation
>=20
>=20
> >>>>> " " =3D=3D Aaron A Ogden <Ogden> writes:
>=20
>      > Hello all, This limitation has been confirmed to my
>      > satisfaction, I just had a test machine crack at 799
>      > mountpoints, so it seems that Chuck's RPC theory may be
>      > correct.  Mike Waychison and Eric Werme mentioned that Solaris
>      > and HPUX use a multiplexed scheme to reduce the number of ports
>      > required for NFS clients, perhaps that is the direction linux
>      > NFS/RPC should be heading.
>=20
> Yes, I already started work on that. In fact a patch already exists on
>=20
>   http://www.fys.uio.no/~trondmy/src/2.5.73/linux-2.5.73-09-xprt.dif
>=20
> to multiplex all RPC traffic to a given server/port combination
> through a single socket.
>=20
> It's been put on hold though due to a combination of higher priority
> interrupts, and now the 2.6.0 code-freeze...
>=20
> Cheers,
>   Trond
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: SF.net Giveback Program.
> SourceForge.net hosts over 70,000 Open Source Projects.
> See the people who have HELPED US provide better services:
> Click here: http://sourceforge.net/supporters.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
