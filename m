From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: query
Date: Thu, 23 Oct 2003 06:56:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127F5F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>,
        "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ADJft-0008Vt-00
	for <nfs@lists.sourceforge.net>; Sat, 25 Oct 2003 01:21:30 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ACfzp-0007Lc-7w
	for nfs@lists.sourceforge.net; Thu, 23 Oct 2003 06:59:25 -0700
To: "Sundareswar Jayakumar" <sundar@cdacb.ernet.in>
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

hi-

what trond says is true, and i'd like to supplement that
idea by saying that the types of workloads where the BKL
would be a bottleneck are rare these days, compared to
the problems more common workloads experience, so it has
been a lower priority.

i think as database on NFS becomes more popular, for example,
this issue will become more important.

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Wednesday, October 22, 2003 9:46 AM
> To: Sundareswar Jayakumar
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] query
>=20
>=20
> >>>>> " " =3D=3D Sundareswar Jayakumar <sundar@cdacb.ernet.in> writes:
>=20
>      > Hi,
>      > 	I am working on adistributed filesytem on=20
> linux.I am using
>      > nfs source code as a learning resource.I require a
>      > clarification.
>=20
>=20
>      > In many entry points the Big Kernel Lock lock/unlock_kernel is
>      > used instead of locking just the private data structures of the
>      > filesystem.why is it so?.kindly clarify w.r.t to a smp m/c.
>=20
> When working on performance, you pursue the largest sources of latency
> first...
> BKL contention has not yet turned up on the radar screen. There has
> therefore not yet been enough incentive to replace it as a mechanism
> for serialization.
>=20
> Cheers,
>   Trond
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by OSDN developer relations
> Here's your chance to show off your extensive product knowledge
> We want to know what you know. Tell us and you have a chance=20
> to win $100
> http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
