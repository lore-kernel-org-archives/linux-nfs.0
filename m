From: Hua Qin <qinhua@poisson.ecse.rpi.edu>
Subject: kernel 2.2.16 fully support nfs TCP mount on client
Date: Fri, 20 Sep 2002 10:48:02 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.10.10209201039360.27867-100000@poisson.ecse.rpi.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.rpi.edu ([128.113.22.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sP4p-0002Ak-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 07:48:15 -0700
Received: from poisson.ecse.rpi.edu (poisson.ecse.rpi.edu [128.113.50.30])
	by mail.rpi.edu (8.12.1/8.12.1) with ESMTP id g8KEmBJO199384
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 10:48:11 -0400
Received: from localhost (qinhua@localhost)
	by poisson.ecse.rpi.edu (8.9.1/8.9.1) with ESMTP id KAA28193
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 10:48:02 -0400 (EDT)
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hi,

I think I can mount from a (kernel-2.2.16) machine by using NFSv3 
over TCP, but if I do write test, this machine will hang.

Does someone know if  2.2.16 kernel cam fully support nfs TCP on client
side?  Which version in 2.2.? start to support NFSv3 TCP client. I know
2.4 do  support, but I have to use 2.2 for some reason.

Thanks!!
Hua



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
