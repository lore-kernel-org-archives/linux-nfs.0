From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: ANNOUNCE - nfs-utils 1.0.6
Date: Mon, 15 Sep 2003 10:48:29 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16229.3165.675990.593856@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chip Salzenberg <chip@pobox.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19yhXe-0007FC-00
	for <nfs@lists.sourceforge.net>; Sun, 14 Sep 2003 17:48:34 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19yhXe-0005dY-4I
	for nfs@lists.sourceforge.net; Sun, 14 Sep 2003 17:48:34 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) (for <chip@pobox.com>) By note With
	Smtp ; Mon, 15 Sep 2003 10:48:30 +1000
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



nfs-utils-1.0.6 is available at
   http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
and
   http://download.sourceforge.net/nfs/

It contains a few minor improvements over 1.0.5 including some that are needed
for correct functioning with 2.6.0 based kernels.

It also corrects a bug which can cause mountd to crash in the event of an
incorrect DNS configuration of a client.  This could be used in a remote 
denial of service attack in the unwise situation that an NFS server was not
firewalled from the open internet.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
