From: Matthew Wilcox <willy@debian.org>
Subject: nfsd not working in 2.6.0-test4 on ia64
Date: Wed, 3 Sep 2003 23:07:09 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030903220709.GJ18654@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ufmV-0006At-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 15:07:15 -0700
Received: from parcelfarce.linux.theplanet.co.uk
	([195.92.249.252] helo=www.linux.org.uk ident=93)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.22)
	id 19ufmU-0007yr-Se
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 15:07:15 -0700
To: neilb@cse.unsw.edu.au
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


My mount attempts aren't working.

I turned on nfsd debugging and got...

Sep  3 17:34:00 rowlf rpc.mountd: authenticated mount request from gonzo.int.wil
.cx:787 for /pub (/pub)
Sep  3 17:34:00 rowlf kernel: found domain gonzo.int.wil.cx
Sep  3 17:34:00 rowlf kernel: found fsidtype 0
Sep  3 17:34:00 rowlf kernel: found fsid length 8
Sep  3 17:34:00 rowlf kernel: Path seems to be </pub>
Sep  3 17:34:00 rowlf kernel: Found the path /pub
Sep  3 17:34:00 rowlf kernel: And found export
Sep  3 17:34:00 rowlf kernel: nfsd: exp_rootfh(/pub [e0000040f69e1a80] gonzo.int
.wil.cx:sdb3/195064)
Sep  3 17:34:00 rowlf kernel: nfsd: fh_compose(exp 08:13/195064 //pub, ino=19506
4)
Sep  3 17:34:01 rowlf kernel: nfsd_dispatch: vers 2 proc 1
Sep  3 17:34:01 rowlf kernel: nfsd: GETATTR  32: 00000001 13000800 0002f9f8 0000
0000 00000000 00000000
Sep  3 17:34:01 rowlf kernel: nfsd: fh_verify(32: 00000001 13000800 0002f9f8 000
00000 00000000 00000000)

Then I added full rpc debugging, and got this:

Sep  3 17:56:26 rowlf kernel: svc: socket e0000040fe7b6f80(inet e0000040fe0f6480), count=112, busy=0
Sep  3 17:56:26 rowlf kernel: svc: socket e0000040fe0f6480 served by daemon e0000040425e6900
Sep  3 17:56:26 rowlf kernel: svc: server e0000040425e6900, socket e0000040fe7b6f80, inuse=1
Sep  3 17:56:26 rowlf kernel: svc: socket e0000040fe0f6480 served by daemon e0000040425e7500
Sep  3 17:56:26 rowlf kernel: svc: got len=104
Sep  3 17:56:26 rowlf kernel: svc: svc_authenticate (1)
Sep  3 17:56:26 rowlf kernel: svc: socket e0000040fe0f6480 busy, not enqueued
Sep  3 17:56:26 rowlf kernel: svc: calling dispatcher
Sep  3 17:56:26 rowlf kernel: nfsd_dispatch: vers 2 proc 1
Sep  3 17:56:26 rowlf kernel: nfsd: GETATTR  32: 00000001 13000800 0002f9f8 00000000 00000000 00000000
Sep  3 17:56:26 rowlf kernel: nfsd: fh_verify(32: 00000001 13000800 0002f9f8 00000000 00000000 00000000)
Sep  3 17:56:26 rowlf kernel: svc: service e0000040425e6900, releasing skb e0000040fe5ddf80
Sep  3 17:56:26 rowlf kernel: svc: socket e0000040fe7b6f80 sendto([e00000404258c000 96... ], 96) = 0 (addr 2501a8c0)
Sep  3 17:56:26 rowlf kernel: svc: socket e0000040fe0f6480 busy, not enqueued
Sep  3 17:56:26 rowlf kernel: svc: server e0000040425e6900 waiting for data (to = 3686400)
Sep  3 17:56:26 rowlf kernel: svc: server e0000040425e7500, socket e0000040fe7b6f80, inuse=1
Sep  3 17:56:26 rowlf kernel: svc: got len=-11

tcpdump confirms the same thing -- packets go in, but they don't come out.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
