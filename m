From: "Adam J. Richter" <adam@yggdrasil.com>
Subject: 2.5.44 - constantly need to reexport mount permissions
Date: Sun, 27 Oct 2002 02:15:15 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210271015.CAA02764@adam.yggdrasil.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from h-66-166-207-249.snvacaid.covad.net ([66.166.207.249] helo=freya.yggdrasil.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185kS2-0004BA-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Oct 2002 02:15:22 -0800
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

	I know there is more that I can do to track down this problem,
but I've been preoccupied with some other tasks, so I thought I ought
to post a description in case the information is helpful to other
people in shedding light on other problems in the recent NFS updates
which wide use of 2.5.44 may be helping to uncover.  Here goes.

	I have a file server and two machines that NFS mount its
mail spool and also run autofs to NFS mount its root file system
and all of its subordinate file systems.

	Often when I reboot client A, client B get this when it
tries to access the area that it has aotomounted from the server:

call_verify: server accept status: 1
call_verify: server accept status: 1
call_verify: server accept status: 1
RPC: garbage, exit EIO

	The accesses fail with EIO.

	Logging into the server and doing "kexportfs -avr" fixes
everything.  I believe that the problem also occured in .43, but
that the process doing the "kexportfs -avr" would sometimes hang,
and it would be necessary to reboot the file server.

	Anyhow, I hope this report is helpful.

Adam J. Richter     __     ______________   575 Oroville Road
adam@yggdrasil.com     \ /                  Milpitas, California 95035
+1 408 309-6081         | g g d r a s i l   United States of America
                         "Free Software For The Rest Of Us."


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
