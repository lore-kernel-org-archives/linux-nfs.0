From: "Amir Hermelin" <amir@montilio.com>
Subject: Recovering from an nfsd crash in Linux 2.4
Date: Sun, 14 Sep 2003 16:36:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00a301c37acd$942b0ec0$0c01a8c0@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19yX48-0003iZ-00
	for <nfs@lists.sourceforge.net>; Sun, 14 Sep 2003 06:37:24 -0700
Received: from sphere.barak.net.il ([212.150.48.98])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19yX47-0000P1-RK
	for nfs@lists.sourceforge.net; Sun, 14 Sep 2003 06:37:24 -0700
Received: from CARTMAN ([62.90.35.123]) by sphere.barak.net.il
          (InterMail vK.4.04.00.00 201-232-137 license 858186d517cc18a2ca9cf19e4d4c6a54)
          with ESMTP id <20030914133533.SNHJ529.sphere@CARTMAN>
          for <nfs@lists.sourceforge.net>; Sun, 14 Sep 2003 16:35:33 +0300
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
When I have a crash in a modified loadable module of knfsd in Linux 2.4.20,
in the midst of a READ(v3) operation, I can't uninstall the module.  After
all [nfsd] daemons die, I use the rmmod command and get still get 'nfsd:
Device or resource busy' error. 

Anyone got any idea how I can get through this w/o rebooting?


Thanks,
Amir.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
