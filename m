From: Andrew Schretter <schrett@math.duke.edu>
Subject: Problems with TCP and 2.4.20-pre4
Date: Wed, 28 Aug 2002 12:38:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208281638.g7SGc7V19149@roma.math.duke.edu>
Mime-Version: 1.0
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from augustus.math.duke.edu ([152.3.25.8] helo=math.duke.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17k5pb-0004k2-00
	for <nfs@lists.sourceforge.net>; Wed, 28 Aug 2002 09:38:11 -0700
Received: from roma.math.duke.edu (roma [152.3.25.13])
	by math.duke.edu (8.11.6/8.11.6) with ESMTP id g7SGc7I18767
	for <nfs@lists.sourceforge.net>; Wed, 28 Aug 2002 12:38:07 -0400
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Perhaps I'm just a bit confused with what patches are still applicable and
what are applied now that there has been a big merge into the 2.4.20 pre
series, but I'm having a big problem with TCP mounting when the server
is running 2.4.20-pre4.

UDP mounting works fine, but when I use a command like :

mount -o tcp,rsize=8192,wsize=8192 galen:/ytmp /mnt/backup

The mounting system (which is running 2.4.19 with Trond's and Neil's patches
for 2.4.19) hangs hard.  Note that this same system mounts a Solaris 8 nfs
filesystem via TCP fine.

The only patches I have applied to the 2.4.20-pre4 kernel tree are a small
patch to fix /proc/partitions, some Orinoco wireless patches.

I tried adding in Neil's 2.4.20-pre4 A and B patches but they did not fix
the problem.

This works fine with 2.4.19 (same as the client listed above).

I know these are development kernels and all, but is there a particular patch
set I should be using to get TCP serverside to work?

Andrew Schretter
Systems Programmer, Duke University
Dept. of Mathematics (919) 660-2866







-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
