From: "Ogden, Aaron A." <aogden@unocal.com>
Subject: RE: ~800 mountpoint limitation
Date: Tue, 14 Oct 2003 11:27:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6AB920CC10586340BE1674976E0A991D59560D@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9S23-0002VE-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 09:28:23 -0700
Received: from unogate.unocal.com ([192.94.3.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9S21-0000Nh-W9
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 09:28:22 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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


Excellent!  I was hoping that you were following the discussion.  It is
something you can fix though?  It seems that RPC may be involved as
well...

Is there any hope of a patch for 2.4.20+ or is this strictly 2.6 code?

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]=20
Sent: Tuesday, October 14, 2003 11:06 AM
To: Ogden, Aaron A.
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] ~800 mountpoint limitation


>>>>> " " =3D=3D Aaron A Ogden <Ogden> writes:

     > Hello all, This limitation has been confirmed to my
     > satisfaction, I just had a test machine crack at 799
     > mountpoints, so it seems that Chuck's RPC theory may be
     > correct.  Mike Waychison and Eric Werme mentioned that Solaris
     > and HPUX use a multiplexed scheme to reduce the number of ports
     > required for NFS clients, perhaps that is the direction linux
     > NFS/RPC should be heading.

Yes, I already started work on that. In fact a patch already exists on

  http://www.fys.uio.no/~trondmy/src/2.5.73/linux-2.5.73-09-xprt.dif

to multiplex all RPC traffic to a given server/port combination
through a single socket.

It's been put on hold though due to a combination of higher priority
interrupts, and now the 2.6.0 code-freeze...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
