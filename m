From: "Robert L. Millner" <rmillner@transmeta.com>
Subject: NFS/UDP slow read, lost fragments
Date: Thu, 25 Sep 2003 10:59:43 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2aPR-0002mb-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 11:00:09 -0700
Received: from neon-gw-l3.transmeta.com ([63.209.4.196] helo=neon-gw.transmeta.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2aPQ-0008Jx-RK
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 11:00:08 -0700
Received: (from root@localhost)
	by neon-gw.transmeta.com (8.9.3/8.9.3) id LAA15200
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 11:00:05 -0700
Received: from draal.transmeta.com (draal.transmeta.com [10.10.26.54])
	by deepthought.transmeta.com (8.11.6/8.11.6) with ESMTP id h8PHxig01411
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 10:59:44 -0700 (PDT)
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

Hello,

The problem I am seeing is similar to what was posted by Larry Sendlosky
on Jun 27, "2.4.20-pre3 -> 2.4.21 : nfs client read performance broken"
though I have not done as through a drill-down into the nature of the
problem.

Somewhere between 2.4.19 and 2.4.20, NFS/UDP read performance began to
suck because of a large number of request retransmits.  From tcpdump, the
retransmits are for read transactions which return data in a reasonable
time frame but are missing one or more fragments of the return packet.

The client is a PIII 550, dual CPU, 1GB RAM, eepro100 (tested with both
the e100 and eepro drivers) running a variety of kernels from the stock
Red Hat 7.3 (2.4.20-20.7 which exhibits the problem), and from stock
2.4.18 through 2.4.22.  2.4.20 and above exhibit this problem.

The server is a Network Appliance F820 running ONTAP 6.2.2.  Tests are
conducted when the F820 is not under a noticeable load.

>From the difference in behavior between kernel revisions and by tcpdump, 
it is believed that the fragments are transmitted by the server.

The timings for different IO sizes for NFSv3 reads of a 70MB file:

Configuration             Seconds Real Time
-------------------------------------------
UDP, 32k                       1080
UDP,  8k                        420
UDP,  4k                        210
UDP,  1k                         40

TCP, 32k                          6.4


The NFSv2/UDP timings for 8k, 4k and 1k are almost identical to the
NFSv3/UDP timings.

The same test with 2.4.18 yields read times for around 6.3 seconds for 32k
and 8k NFSv2 and NFSv3 over UDP.

Setting rmem_max, rmem_default, wmem_max and wmem_default to either 524284 
or 262142 make no difference.

Setting netdev_max_backlog to 1200 (from 300) makes no difference.

Setting ipfrag_high_thresh to up to 4194304 makes no difference.


We have a mix of clients and servers, not all of which support NFS/TCP yet
so we can't globally set tcp in the automounter maps for our netapp mounts
or as "localoptions" in the autofs init script.  The mount patch submitted
by Steve Dickson on Aug 6, "NFS Mount Patch:  Making NFS over TCP the
default" is probably the immediate workaround that will at least make the
mounts that really matter to us work well again.  I'll test that next.


Is this a known problem?  Is there a patch already out there or in the
works that fixes this?  What other data would help drill into this
problem?


	Rob



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
