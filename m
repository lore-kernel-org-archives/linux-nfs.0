From: "Amir Hermelin" <amir@montilio.com>
Subject: remounting with a different blocksize
Date: Wed, 17 Sep 2003 08:45:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <009401c37ce7$44aa31c0$1301a8c0@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zV9R-0001oU-00
	for <nfs@lists.sourceforge.net>; Tue, 16 Sep 2003 22:46:53 -0700
Received: from enigma.barak.net.il ([212.150.48.99])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zV9Q-0000u7-Ka
	for nfs@lists.sourceforge.net; Tue, 16 Sep 2003 22:46:52 -0700
Received: from CARTMAN ([62.90.35.123]) by enigma.barak.net.il
          (InterMail vK.4.04.00.00 201-232-137 license 858186d517cc18a2ca9cf19e4d4c6a54)
          with ESMTP id <20030917054629.QWER28637.enigma@CARTMAN>
          for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 08:46:29 +0300
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

Hi,
I'm using RH Linux 2.4.20 on both machines.  When I first mount one of =
the
machines with a 4k read/write blocksize, the READ requests are 4K bytes.
However, when I umount and then mount again with read/write blocksize of =
8K,
the READ requests are still 4K bytes.

Any ideas on how I can properly change the blocksizes?

Thanks,
Amir.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
