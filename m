From: "Ogden, Aaron A." <aogden@unocal.com>
Subject: ~800 mountpoint limitation
Date: Tue, 14 Oct 2003 10:51:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6AB920CC10586340BE1674976E0A991D0C6B81@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9RSa-0007E2-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 08:51:44 -0700
Received: from unogate.unocal.com ([192.94.3.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9RSZ-0003gx-D6
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 08:51:43 -0700
Received: from ElCapitan.ad.unocal.com (localhost [127.0.0.1])
	by unogate.unocal.com (8.12.10/8.12.10) with ESMTP id h9EFp5uX011365
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 08:51:05 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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


Message: 1
Date: Mon, 13 Oct 2003 11:23:51 +0800 (WST)
From: Ian Kent <raven@themaw.net>
To: "Ogden, Aaron A." <aogden@unocal.com>
cc: Mike Waychison <Michael.Waychison@Sun.COM>,
   autofs mailing list <autofs@linux.kernel.org>,
<nfs@lists.sourceforge.net>
Subject: Re: [NFS] RE: [autofs] multiple servers per automount

> On Fri, 10 Oct 2003, Ogden, Aaron A. wrote:
>=20
> >
> >
> > > So this would indicate that even if there is a device system that
can
> > > increase the number of unnamed devices that subsystems like NFS
cannot
> > > handle this many mounts.
> >
> > Maybe.  I'm not 100% certain though.  Currently I am holding steady
at
> > 710 active mounts, I am going to write a little script to mount more
in
> > small increments, ie. read a list of ~1000 mountpoints from /home,
mount
> > a few of them, check the filesystems, and repeat... this way I will
know
> > exactly where things break down.
>
> Interesting.
>=20
> If you can edge it up then it's probably not an available port
> restriction.
>=20
> There may be more than one issue at work here.

Hello all,
This limitation has been confirmed to my satisfaction, I just had a test
machine crack at 799 mountpoints, so it seems that Chuck's RPC theory
may be correct.  Mike Waychison and Eric Werme mentioned that Solaris
and HPUX use a multiplexed scheme to reduce the number of ports required
for NFS clients, perhaps that is the direction linux NFS/RPC should be
heading.

--aaron


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
