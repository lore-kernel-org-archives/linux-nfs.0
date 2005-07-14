From: Haakon Riiser <hakonrk@student.matnat.uio.no>
Subject: "Server not responding" after periods of client inactivity
Date: Thu, 14 Jul 2005 14:34:30 +0200
Message-ID: <20050714123430.GA18416@fox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt2vS-0005Vr-Pf
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 05:34:50 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt2vR-0005p2-EL
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 05:34:50 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1Dt2vH-0007mP-6o
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 14:34:39 +0200
Received: from 231.80-203-47.nextgentel.com ([80.203.47.231] helo=fox.venod.com)
	by mail-mx3.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1Dt2vE-0006f5-41
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 14:34:36 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

(Trying to post this for the third time -- nothing appeared on the
list the first two times.)

I have noticed that after periods of inactivity on the client
machine, the first NFS operation will always hang for around
15 seconds.  My first guess was that the server had powered down
its disk drives, and that it was the spin-up time that caused the
delay, but when I had an ssh session open on the server at the
same time as the client started complaining about not getting a
reply, I saw that this was /not/ the case -- there is nothing
on the server that would explain why the client is stalling.
No load, and no delay when working directly on the server.

I did tcpdump (on the server side) while the client was hanging,
and this is what I found:

Source  Time  Packets
------  ----  -------
client  0.00  V3 ACCESS Call, FH:0x02120000
client  0.10  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client  0.31  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client  0.71  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client  1.53  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client  3.16  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client  6.42  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client  7.12  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client  8.52  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
client 11.32  [Retransmission of #1] V3 ACCESS Call, FH:0x02120000
server 15.30  V3 ACCESS Reply

After this, there are no more delays for this shared file system;
any file operation on the same file system will succeed instantly.
However, the first operation on any /other/ NFS file system also
mounted on the client will still hang just like the above example.
I.e., the hang always happens exactly once for each mount point.

I have tried setting rsize=1024,wsize=1024, and I have tried both
tcp and udp, but nothing has helped so far.  Any ideas?  tcpdump
clearly shows that all the requests arrive at the server, so why
does the server wait 15 seconds before it replies?

NFS server:
  Pentium III 650 MHz, 256 MB RAM
  Fedora Core 3 (fully updated)
  nfs-utils 1.0.6-52
  kernel 2.6.11-1.35_FC3

NFS client:
  Athlon XP2500+, 1 GB RAM
  Slackware 10.1
  nfs-utils 1.0.7
  kernel 2.6.11.11

-- 
 Haakon


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
