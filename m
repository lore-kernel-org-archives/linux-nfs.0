From: Dan Kegel <dkegel@ixiacom.com>
Subject: Meaning of 'udp' mount option
Date: Mon, 30 Jun 2003 12:35:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F00911E.5020001@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 64-60-75-69.cust.telepacific.net ([64.60.75.69] helo=racerx.ixiacom.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19X4UA-0006FS-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Jun 2003 12:38:46 -0700
To: nfs@lists.sourceforge.net
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

Question 1: what does the 'udp' mount option really mean?
It appears to mean 'Use udp mostly, but use TCP when calling pmap_getmaps()'.
Question 2: is this a bug or a feature?
Question 3: if it's a feature, should we add a new mount option to
mean 'really, dude, use udp for everything'?

The long story:

Imagine, if you will, an NFS server running on an operating system
that will shut down all further TCP connects on a given port if that
port ever encounters more than five simultaneous connects.
(That's a rather perverse limitation, but unfortunately, it seems to
be widespread.)

Imagine further that you have 500 NFS clients that want to connect
simultaneously to that server.  "Ah, simple, I'll just use UDP, and
avoid the issue!", you say.

Unfortunately, it appears that even when you specify UDP as a
mount option, util-linux-2.11[nz]'s mount appears
to always connect to the server's portmapper using TCP.  The
culprit is glibc's pmap_getmaps, which always uses tcp.

I threw together a version of rpcinfo.c that uses udp to do
the same thing as pmap_getmaps, and it works.

The next step is for me to patch nfsmount.c's get_mountport()
to only use the standard pmap_getmaps() if mounting via TCP,
and to use my pmap_getmaps_via_udp() if mounting via UDP.

If that works, then presumably it'd be nice to fold something
like this in to the main tree.  But making the 'udp' mount
option really mean 'udp, goddammit' might be too much of a
change in semantics; perhaps there should be a new mount option
always_udp?

- Dan



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
