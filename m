From: Christian Reis <kiko@async.com.br>
Subject: General network slowness on SIS 530 with eepro100
Date: Tue, 13 Aug 2002 21:29:23 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020813212923.L2219@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sr1.terra.com.br ([200.176.3.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17em2W-0007KA-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 17:29:33 -0700
To: eepro100@scyld.com, nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Helle there,

I've been, for the past days, setting up a fairly big diskless network
based on Linux. I've chosen to use 2.4.19 as the kernel because there
were some hardware requirements, and for most of the newer boxes, it
runs fine. However, for three of the older boxes, we have had some
pretty odd performance and stability issues. This message is about the
latest one, which is an ASUS P5S-B (has the infamous SIS 530 chipset)
on an intel eepro100 card. Details:

Host bridge: Silicon Integrated Systems [SiS] 530 Host (rev 2).
Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 8).
VGA compatible controller: Silicon Integrated Systems [SiS] 6306
3D-AGP (rev a2)

We've been using NFS for the diskless boxes, of course, and for this
particular box, the CPU usage for everything is just so much higher its
amazing. It's so slow you can feel the repaints happening when running
X, even when listing directories using ls -lR. I'll show a summary of
bonnie runs on the root (NFS) partition:

1.02b           ------Sequential Output------ --Sequential Input- --Random-
                -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine    Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP /sec %CP
can (v2)   300M  4054  57  5121   2  3549   3  5942  91 10195   3 442.2   4
can (v3)   300M  5965  82  7861   3  2739   2  5437  82  9316   3 675.5   6
can (v3+)  300M  4721  66  2654   1   641   0  5454  74  5017   0 690.2   7
min (v3+)  300M  3170  95  1526   2  1118   3  2913  89  4061   2 474.9  21
tri (v3+)  300M  2708  96  5997  65  2806  76  2673  90  6064  73 351.9  64

                ------Sequential Create------ --------Random Create--------
                -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
          files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP /sec %CP
can (v2)    16    44   0  4316  19    80   0    46   0  4684   8 68   0
can (v3)    16  2104   9  5060  16  2102   8  2149   6  5789  10 1833   6
can (v3+)   16  1666   7  4390  38  2103   8  1735   9  8859  17 2143   8
min (v3+)   16  1037  19  2467  45  1133  17   959  17  4645  26 1120  12
tri (v3+)   16  1066  35  1879  66  1125  28   978  30  4187  43 1334  32

Legend: hosts to the left, can is a K7-900 min and tri are K6-500s.
        v2 indicates mount options=v2
        v3 indicates mount options=v3
        v3+ indicates mount options=v3 and Trond's nfs-all patch applied

On tri, which is the referred SIS530 box, as you can see, for most runs
the CPU usage is just so much higher than minas, which has practically
the same setup: K6-500, old PCI (no AGP) board, eepro100 card. I'm
wondering if anybody has seen something like this before?

The server is a K7 with 2 3c905-TXM cards that is serving all other
boxes with no problems reported (beyond some lockd quirks I'm trying to
get my head around).

I've tried applying Trond's patches, using pci=biosirq and other tweaks,
but nothing has really made it better. Any idea what's going on?

Crossposting to reach the appropriate parties as I feel its quite a
cross-subject issue.

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
