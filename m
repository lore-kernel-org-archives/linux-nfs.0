From: "Dennis, Richard" <Richard.Dennis@lehman.com>
Subject: Linux NFS rsize/wsize
Date: Thu, 19 Jun 2003 15:56:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0073ECCF4F99D611810B0002A58F26560EB31522@exnyc03.lehman.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail-haw.bigfish.com ([12.129.199.61] helo=mail1-haw-R.bigfish.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T5WN-0002GW-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 12:56:35 -0700
Received: from mail1-haw.bigfish.com (localhost.localdomain [127.0.0.1])
	by mail1-haw-R.bigfish.com (Postfix) with ESMTP id 417F77F19E
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 19:56:29 +0000 (UTC)
Received: from extrelay2.lehman.com (extrelay2.Lehman.COM [192.147.58.145])
	by mail1-haw.bigfish.com (Postfix) with ESMTP id 782807EAF3
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 19:56:28 +0000 (UTC)
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

I've observed something in our Linux NFS environment that I don't
understand, and I was hoping someone could help shed some light on this.

>From a Linux client, I have mounted a share from a Solaris 8 server.  It's
mounted with the options: "rw,nosuid,hard,rsize=32768,wsize=32768,intr" on
the Linux client, which defaults to UDP.

I'm seeing that when I set the rsize and wsize to 32k, packets are read
(coming from the Solaris server) in 32k packets, but when I write to this
share, Linux frags the file according to my MTU.  Why would the Solaris
server accept the rsize, but the linux client not accept the wsize?  (The
Solaris server's MTU is also 1500.)  

Below are the beginnings of the tcpdumps as taken from the client.

Thanks in advance.  
--Rick

[root@client root]# tcpdump -s 1500 -vvv -r nfstest_32k_udp_read.out|more

16:01:31.260245 nfsclient.412459744 > nfsserver.nfs: 176 access fh
211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
16:01:31.260699 nfsclient.429236960 > nfsserver.nfs: 180 lookup fh
211,9000/1267050 "foo2" (DF) (ttl 64, id 0, len 208)
16:01:31.261119 nfsclient.446014176 > nfsserver.nfs: 176 access fh
211,9000/1253571 0001 (DF) (ttl 64, id 0, len 204)
16:01:31.261589 nfsclient.462791392 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000000000 (DF) (ttl 64, id 0, len 212)
16:01:31.265868 nfsclient.479568608 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000008000 (DF) (ttl 64, id 0, len 212)
16:01:31.265925 nfsclient.496345824 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000010000 (DF) (ttl 64, id 0, len 212)
16:01:31.274669 nfsclient.513123040 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000018000 (DF) (ttl 64, id 0, len 212)
16:01:31.274737 nfsclient.529900256 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000020000 (DF) (ttl 64, id 0, len 212)
16:01:31.274784 nfsclient.546677472 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000028000 (DF) (ttl 64, id 0, len 212)
16:01:31.283490 nfsclient.563454688 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000030000 (DF) (ttl 64, id 0, len 212)
16:01:31.284079 nfsclient.580231904 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000038000 (DF) (ttl 64, id 0, len 212)
16:01:31.284655 nfsclient.597009120 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000040000 (DF) (ttl 64, id 0, len 212)
16:01:31.291038 nfsclient.613786336 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000048000 (DF) (ttl 64, id 0, len 212)
16:01:31.291545 nfsclient.630563552 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000050000 (DF) (ttl 64, id 0, len 212)
16:01:31.295064 nfsclient.647340768 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000058000 (DF) (ttl 64, id 0, len 212)
16:01:31.297166 nfsclient.664117984 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000060000 (DF) (ttl 64, id 0, len 212)
16:01:31.299847 nfsclient.680895200 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000068000 (DF) (ttl 64, id 0, len 212)
16:01:31.302588 nfsclient.697672416 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000070000 (DF) (ttl 64, id 0, len 212)
16:01:31.305327 nfsclient.714449632 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000078000 (DF) (ttl 64, id 0, len 212)
16:01:31.308053 nfsclient.731226848 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000080000 (DF) (ttl 64, id 0, len 212)
16:01:31.310805 nfsclient.748004064 > nfsserver.nfs: 184 read fh
211,9000/1253571 32768 bytes @ 0x000088000 (DF) (ttl 64, id 0, len 212)



[root@client root]# tcpdump -s 1500 -vvv -r nfstest_32k_udp_write.out|more

16:00:27.177895 nfsclient.3415450336 > nfsserver.nfs: 176 access fh
211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
16:00:27.178405 nfsclient.3432227552 > nfsserver.nfs: 176 access fh
211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
16:00:27.178827 nfsclient.3449004768 > nfsserver.nfs: 180 lookup fh
211,9000/1267050 "foo3" (DF) (ttl 64, id 0, len 208)
16:00:27.179221 nfsclient.3465781984 > nfsserver.nfs: 176 access fh
211,9000/1267050 001e (DF) (ttl 64, id 0, len 204)
16:00:27.179598 nfsclient.3482559200 > nfsserver.nfs: 212 create fh
211,9000/1267050 "foo3" (DF) (ttl 64, id 0, len 240)
16:00:27.182630 nfsclient.3499336416 > nfsserver.nfs: 176 access fh
211,9000/1266907 0000 (DF) (ttl 64, id 0, len 204)
16:00:27.185844 nfsclient.3516113632 > nfsserver.nfs: 1472 write fh
211,9000/1266907 32768 bytes @ 0x000000000 <unstable> (frag 50541:1480@0+)
(ttl 64, len 1500)
16:00:27.185864 nfsclient > nfsserver: (frag 50541:1480@1480+) (ttl 64, len
1500)
16:00:27.185869 nfsclient > nfsserver: (frag 50541:1480@2960+) (ttl 64, len
1500)
16:00:27.185875 nfsclient > nfsserver: (frag 50541:1480@4440+) (ttl 64, len
1500)
16:00:27.185883 nfsclient > nfsserver: (frag 50541:1480@5920+) (ttl 64, len
1500)
16:00:27.185891 nfsclient > nfsserver: (frag 50541:1480@7400+) (ttl 64, len
1500)
16:00:27.185912 nfsclient > nfsserver: (frag 50541:1480@8880+) (ttl 64, len
1500)
16:00:27.185918 nfsclient > nfsserver: (frag 50541:1480@10360+) (ttl 64, len
1500)
16:00:27.185929 nfsclient > nfsserver: (frag 50541:1480@11840+) (ttl 64, len
1500)
16:00:27.185934 nfsclient > nfsserver: (frag 50541:1480@13320+) (ttl 64, len
1500)
16:00:27.185939 nfsclient > nfsserver: (frag 50541:1480@14800+) (ttl 64, len
1500)
16:00:27.185945 nfsclient > nfsserver: (frag 50541:1480@16280+) (ttl 64, len
1500)
16:00:27.185950 nfsclient > nfsserver: (frag 50541:1480@17760+) (ttl 64, len
1500)
16:00:27.185956 nfsclient > nfsserver: (frag 50541:1480@19240+) (ttl 64, len
1500)
16:00:27.185962 nfsclient > nfsserver: (frag 50541:1480@20720+) (ttl 64, len
1500)
16:00:27.185968 nfsclient > nfsserver: (frag 50541:1480@22200+) (ttl 64, len
1500)
16:00:27.185974 nfsclient > nfsserver: (frag 50541:1480@23680+) (ttl 64, len
1500)
16:00:27.185980 nfsclient > nfsserver: (frag 50541:1480@25160+) (ttl 64, len
1500)
16:00:27.185986 nfsclient > nfsserver: (frag 50541:1480@26640+) (ttl 64, len
1500)
16:00:27.185992 nfsclient > nfsserver: (frag 50541:1480@28120+) (ttl 64, len
1500)
16:00:27.185998 nfsclient > nfsserver: (frag 50541:1480@29600+) (ttl 64, len
1500)
16:00:27.186006 nfsclient > nfsserver: (frag 50541:1480@31080+) (ttl 64, len
1500)
16:00:27.186015 nfsclient > nfsserver: (frag 50541:408@32560) (ttl 64, len
428)
16:00:27.187272 nfsclient.3532890848 > nfsserver.nfs: 1472 write fh
211,9000/1266907 32768 bytes @ 0x000008000 <unstable> (frag 50542:1480@0+)
(ttl 64, len 1500)
16:00:27.187291 nfsclient > nfsserver: (frag 50542:1480@1480+) (ttl 64, len
1500)
16:00:27.187296 nfsclient > nfsserver: (frag 50542:1480@2960+) (ttl 64, len
1500)
16:00:27.187302 nfsclient > nfsserver: (frag 50542:1480@4440+) (ttl 64, len
1500)
16:00:27.187307 nfsclient > nfsserver: (frag 50542:1480@5920+) (ttl 64, len
1500)

------------------------------------------------------------------------------
This message is intended only for the personal and confidential use of the
designated recipient(s) named above.  If you are not the intended recipient of
this message you are hereby notified that any review, dissemination,
distribution or copying of this message is strictly prohibited.  This
communication is for information purposes only and should not be regarded as
an offer to sell or as a solicitation of an offer to buy any financial
product, an official confirmation of any transaction, or as an official
statement of Lehman Brothers.  Email transmission cannot be guaranteed to be
secure or error-free.  Therefore, we do not represent that this information is
complete or accurate and it should not be relied upon as such.  All
information is subject to change without notice.



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
