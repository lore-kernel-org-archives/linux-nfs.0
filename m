From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 14:27:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C773E@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181XM3-0001ZS-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 12:27:47 -0700
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




	Something else,

	if you are dd a 10mb file on the local machine that is all going to be =
in cache, so
	the rate will be horribly incorrect.

	Also these are gigabit copper cards correct?  Gigabit copper cards only =
run=20
	a max of 50MB/second, so getting 35MB/second over one of them is pretty =
good.

	I am getting 1500cs/second and 6500ints/second at about 8MB/second to
	the network. =20

	I get 3600cs/second and 15000ints/second at about 20MB/second to the
	network.

	How fast of IO are you getting on the local machine?

							Roger


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
