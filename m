From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: [autofs] multiple servers per automount
Date: Fri, 10 Oct 2003 08:10:13 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC4E3@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Ogden, Aaron A." <aogden@unocal.com>,
        "autofs mailing list" <autofs@linux.kernel.org>,
        <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7yvc-0003hy-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Oct 2003 08:11:40 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A7yvb-0002hk-Vr
	for nfs@lists.sourceforge.net; Fri, 10 Oct 2003 08:11:39 -0700
To: "Ian Kent" <raven@themaw.net>,
        "Mike Waychison" <Michael.Waychison@Sun.COM>
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

the problem is likely the algorithm used to allocate
ports for the RPC transport sockets.  it starts at
port 800 and goes down to zero.

> -----Original Message-----
> From: Ian Kent [mailto:raven@themaw.net]
> Sent: Thursday, October 09, 2003 6:09 PM
> To: Mike Waychison
> Cc: Ogden, Aaron A.; autofs mailing list; nfs@lists.sourceforge.net
> Subject: [NFS] Re: [autofs] multiple servers per automount
>=20
>=20
> On Thu, 9 Oct 2003, Mike Waychison wrote:
>=20
> > Ogden, Aaron A. wrote:
> >
> > >Ouch.  As you may know, the limit is *much* lower in=20
> linux.  Something
> > >that I've been struggling with recently...
> > >
> > >Under normal circumstances I would not be concerned with=20
> 'limitations'
> > >of a few hundred active NFS mounts, but such limitations=20
> certainly limit
> > >scalability for the extreme cases.
> > >
> > >
> >
> > The maximum number of plain pseudo-block device filesystems=20
> on a given
> > filesystem is limitted to 256. (This includes proc, autofs, nfs..).
> >
> > This is because pseudo-block filesystems all use major 0,=20
> and each have
> > a different minor (thus the 256 limit).
> >
> > There are however patches floating around (look at SuSe's=20
> kernels, I'm
> > not sure about RH) that allow n majors to be used (default 5).  This
> > gives you 1280 mounts, a big step up :)
> >
>=20
> But as Aaron and I know things go pear shaped at just shy of=20
> 800 mounts
> with RedHat kernels. They have the more-unnamed patch.
>=20
> So this would indicate that even if there is a device system that can
> increase the number of unnamed devices that subsystems like NFS cannot
> handle this many mounts.
>=20
> --=20
>=20
>    ,-._|\    Ian Kent
>   /      \   Perth, Western Australia
>   *_.--._/   E-mail: raven@themaw.net
>         v    Web: http://themaw.net/
>=20
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
