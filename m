From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: 2.4.19 NFSALL performance oddity
Date: Fri, 4 Oct 2002 16:45:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xaG5-0004S7-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Oct 2002 14:45:17 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


I am running some tests using 2.4.19 with all posted nfs patchs, =
everything is
being run sync.   All runs are with NFS3 over UDP.

I have noticed that the IO rates (writes) start slowly (about =
1.5MB/second) and
slowly build up to a peak of 2.5MB/second over several minutes, with the
test averaging 2.32 MB/second over a 2GB file write.  This is=20
with a server with Gigabit copper and the client with 100BT ethernet.  =20
No packets are being lost from what I can tell, on either the server or=20
the client, both machines are dual cpu with 2GB of ram and otherwise=20
unloaded.

The 2.2.19 client (with almost no NFS patches) runs about 3.98MB/second =
over
a 2GB file write, against the same 2.4.19 NFS server, and hits that rate =

almost immediately.

Using an older 2.4.19 NFS server (that I don't believe has any extra NFS
patches) gets a rate of 6.50 average over a 2GB file from
a 2.2.19 client and gets 2.00  MB/second average from one of the
original 2.4 test clients.

Both rsize and wsize are 8192, I have tried it with 32768 on at least
the 2.4 client side, but it does not appear to affect the above results.
I am tried with 32 and 64 nfsd and this did not appear to change
any of the results.   The rmem/wmem parameters have been upped
to 256K and did not appear to make any difference on the server.

The disk is locally capable of 20MB/second writes over a 4GB file, using
the same test as was used above.

Is there a way to make the IO start fast and stay fast?   What code =
could
I look at to see if I can affect the way this works?   Any parameters =
that
I could try changing that might improve things?

It appears to partially be client issue since the 2.2.19 NFS client is =
noticeably
faster, but since the older 2.4.19 server and the 2.2.19 client is even =
faster it
appears to also be a server issue.

So in summary:

2.2.19 -> 2.4.19 no patches -> 6.5MB/second
2.4.19nfsall -> 2.4.19 no patches ->  2.00 MB/second
2.2.19 -> 2.4.19 nfsall patch -> 3.98MB/second
2.4.19nfsall -> 2.4.19 nfsall patch -> 2.32 MB/second


				Roger


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
