From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ~800 mountpoint limitation
Date: 14 Oct 2003 12:06:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsfzhvyfbo.fsf@charged.uio.no>
References: <6AB920CC10586340BE1674976E0A991D0C6B81@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9Rgd-0000E3-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 09:06:15 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9Rgc-0001Gx-8Y
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 09:06:14 -0700
To: "Ogden, Aaron A." <aogden@unocal.com>
In-Reply-To: <6AB920CC10586340BE1674976E0A991D0C6B81@slexch2.sugarland.unocal.com>
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

>>>>> " " == Aaron A Ogden <Ogden> writes:

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
