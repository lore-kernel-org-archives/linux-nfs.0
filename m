From: elijah wright <elw@stderr.org>
Subject: bug report: linux-to-solaris mounts
Date: Sun, 11 Apr 2004 10:50:07 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0404111043450.6681@illuminati.stderr.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BChDs-0000Z1-Na
	for nfs@lists.sourceforge.net; Sun, 11 Apr 2004 08:50:16 -0700
Received: from illuminati.stderr.org ([63.246.8.57] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BChDs-0002qq-9g
	for nfs@lists.sourceforge.net; Sun, 11 Apr 2004 08:50:16 -0700
Received: from localhost (elw@localhost [127.0.0.1])
	by illuminati.stderr.org (8.12.11/8.12.11/Debian-4) with ESMTP id i3BFo7e9008557
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Sun, 11 Apr 2004 10:50:08 -0500
To: nfs@lists.sourceforge.net
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


i'm having a little problem here with NFS, and trying to track down a
solution.

situation:  Solaris 9 NFS server, Linux clients running autofs to mount
	homes via nfs.  under linux kernel 2.4.[24,25], things work OK.
	after an upgrade to 2.6.[3,4,5] kernels, i start getting timeouts
	talking to the nfs server - it reports that lockd could not bind
	to reserved port (13?).  so the clients just lose track of the
	server altogether.

	my client machines are running debian unstable, with the most
	recent versions of all support packages that i can find in the
	archives.

anybody got a clue about what's going on?  i'd really, really like to get
this fixed so that my test machines are usable again and so that i can
upgrade the rest of our project machines to newer kernels.  :)


thanks very much in advance,

elijah
Indiana University
School of Library and Information Science




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
