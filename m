From: Erik Walthinsen <omega@pdxcolo.net>
Subject: Converting open filehandles to pathnames
Date: Sat, 08 May 2004 16:33:28 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084059203.714.13.camel@omikron>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMiBy-00059J-GA
	for nfs@lists.sourceforge.net; Sat, 08 May 2004 23:53:42 -0700
Received: from [216.99.212.251] (helo=mail.omegacs.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BMiBy-0001Xv-7a
	for nfs@lists.sourceforge.net; Sat, 08 May 2004 23:53:42 -0700
Received: from [10.1.1.175] ([10.1.1.175])
	by mail.omegacs.net (8.11.6/8.11.0) with ESMTP id i497AWW12038
	for <nfs@lists.sourceforge.net>; Sun, 9 May 2004 00:10:33 -0700
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

I've got an NFS server with client machines running User-mode Linux. 
These UML instances open several large files on the NFS server at boot
time (root, /home, etc), and perform varying amounts of IO over the next
several months, or however long the UML instances are running.

The problem is, I really have no concrete way of determining IO load on
these files.  Nothing distinguishes the packets for one file from
packets for another file coming from the same physical host machine. 
Except the filehandle that is.

A while ago I wrote a script that caught every NFS packet and used
periodic getattr RPC calls to complete a mapping between the filehandles
and inodes (and thus pathnames), and it mostly worked.  However,
something has changed and these getattr calls have ceased.  Thus, the
script happily gathers read and write calls but has no means of
translating them.

My question: is there some means of divining the device/inode of a
filehandle?  I looked around the NFS and VFS code and found nothing that
looked promising, but I don't really understand the VFS subsystem.

(aside: some net sources indicate that Solaris has a /var/nfs/fhtable
that it keeps up to date, but that's related to nfslogd and various
other Sun-isms)

Would it be possible to write a program to walk through kmem from some
known global kernel symbol to find the relevant structures necessary to
perform this translation?  (Ideally, on an existing production system,
passively)  If so, what symbol would be the base of such a trip?  If
someone can explain roughly what the relevant structure tree looks like,
I can figure out how to write the necessary code, but until I have a
clue about the relevant VFS/NFS code, I'm lost.

TIA,
   Omega
   aka Erik Walthinsen
   omega@pdxcolo.net



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
