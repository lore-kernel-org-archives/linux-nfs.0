From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: A strange ls on nfsv4
Date: Mon, 9 Feb 2004 18:20:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402091820.30897.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqNFm-000839-Ls
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 18:03:58 -0800
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqF4E-0004Kb-9g
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 09:19:30 -0800
Received: from [129.183.4.3] (helo=ecbull20.frec.bull.fr)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqF4A-0008OE-NB
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 09:19:27 -0800
Received: from roquetav.frec.bull.fr (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id SAA18964
	for <nfs@lists.sourceforge.net>; Mon, 9 Feb 2004 18:19:27 +0100
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

I still not have understood the previous bug (mounting; rebooting without
umounting ; remounting) I found others bugs.

I was creating big BIG files with bonnie++.

I used vim to write "program.c" on a shared NFSv4 remote directory.


=2Drw-r--r--    1 4294967294 4294967294        0 oct 31  1970 4913
=2Drw-r--r--    1 4294967294 4294967294        0 nov  1  1970 5036
=2Drw-r--r--    1 4294967294 4294967294        0 nov  1  1970 5159
=2Drw-r--r--    1 4294967294 4294967294        0 nov  2  1970 5282
=2Drwxr-xr-x    1 4294967294 4294967294    11326 f=E9v  9  2004 program
=2Drw-r--r--    1 4294967294 4294967294      136 f=E9v  9  2004 program.c
=2Drw-r--r--    1 4294967294 4294967294        0 oct 31  1970 program.c~
=2Drw-r--r--    1 4294967294 4294967294        0 nov  2  1970 program.x~
=2Drw-r--r--    1 4294967294 4294967294        0 nov  1  1970 program.y~
=2Drw-r--r--    1 4294967294 4294967294        0 nov  1  1970 program.z~



Creating program.c, vim tell me that it found an old swaped file!
(So I suppose when vim is trying to detect a swaped file, it CREATE this
file?)

Well... and for sure this file was not created in october/november 1970 !!!



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
