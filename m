From: "Amir Hermelin" <amir@montilio.com>
Subject: nfsd and kswapd
Date: Mon, 7 Jun 2004 00:46:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002201c44c18$23f45e00$0200000a@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BX5Zv-0001wR-Od
	for nfs@lists.sourceforge.net; Sun, 06 Jun 2004 14:53:19 -0700
Received: from sphere.barak.net.il ([212.150.48.98])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BX5Zu-0005yc-RS
	for nfs@lists.sourceforge.net; Sun, 06 Jun 2004 14:53:19 -0700
Received: from CARTMAN ([212.179.89.182]) by sphere.barak.net.il
          (InterMail vK.4.04.00.00 201-232-137 license e5bc39f1001e7dfa47fa92d56cd12779)
          with ESMTP id <20040606214544.NSBR12447.sphere@CARTMAN>
          for <nfs@lists.sourceforge.net>; Mon, 7 Jun 2004 00:45:44 +0300
To: <nfs@lists.sourceforge.net>
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

Hi,
I'm observing a strange phenomenon running nfsd on 2.4.20 (RH).  I'm =
using a
dual-Xeon server with 6GB of memory, and 40 nfsd threads running.  Under
very heavy load, after a while kswapd starts constantly occupying =
between
60-90% cpu, and every once in a while keventd also wakes up with some =
10-
30% of its own.  This obviously slows the system and greatly reduces the =
nfs
performance.  The strangest thing is, that when I reduce the memory to =
512MB
(with the mem boot option), kswapd seems to be getting a lot less CPU.

Any explanations on the matter would be greatly appreciated.

Thanks,
Amir.

Here's a dump of top and /proc/meminfo:

 08:22:17  up  3:23,  3 users,  load average: 41.85, 41.38, 38.05 102
processes: 98 sleeping, 4 running, 0 zombie, 0 stopped
CPU0 states:   0.0% user  98.5% system    0.0% nice   0.0% iowait   1.1%
idle
CPU1 states:   0.3% user  98.4% system    0.0% nice   0.0% iowait   0.6%
idle
CPU2 states:   0.0% user 100.0% system    0.0% nice   0.0% iowait   0.0%
idle
CPU3 states:   0.0% user  99.0% system    0.0% nice   0.0% iowait   0.6%
idle
Mem:  6178484k av, 6161280k used,   17204k free,       0k shrd,  106908k
buff
                   1896336k actv, 1881924k in_d,   17864k in_c
Swap: 1028120k av,    9756k used, 1018364k free                 5544656k
cached

  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU =
COMMAND
   11 root      25   0     0    0     0 DW   76.0  0.0  77:20   3 kswapd
24902 root      16   0  1184 1160   856 R    15.4  0.0   2:17   1 top
    6 root      15   0     0    0     0 SW   14.8  0.0  12:29   0 =
keventd
22616 root      15   0     0    0     0 DW   11.3  0.0   1:31   1 nfsd
22603 root      16   0     0    0     0 DW   10.7  0.0   1:32   1 nfsd
22626 root      15   0     0    0     0 DW   10.3  0.0   1:29   3 nfsd
22598 root      16   0     0    0     0 DW   10.2  0.0   1:30   1 nfsd
22620 root      15   0     0    0     0 DW   10.0  0.0   1:29   3 nfsd
22590 root      16   0     0    0     0 DW    9.6  0.0   1:30   0 nfsd
22608 root      15   0     0    0     0 DW    9.6  0.0   1:31   3 nfsd
22596 root      15   0     0    0     0 DW    9.5  0.0   1:32   3 nfsd
22621 root      16   0     0    0     0 DW    9.5  0.0   1:32   0 nfsd
22617 root      15   0     0    0     0 DW    9.0  0.0   1:33   0 nfsd
22591 root      15   0     0    0     0 DW    8.9  0.0   1:34   3 nfsd
22605 root      15   0     0    0     0 DW    8.9  0.0   1:31   2 nfsd
22611 root      15   0     0    0     0 DW    8.6  0.0   1:31   1 nfsd
22614 root      15   0     0    0     0 DW    8.3  0.0   1:35   3 nfsd
22612 root      15   0     0    0     0 DW    8.0  0.0   1:33   2 nfsd
22625 root      16   0     0    0     0 RW    8.0  0.0   1:32   1 nfsd
22601 root      16   0     0    0     0 DW    7.9  0.0   1:34   1 nfsd
22610 root      15   0     0    0     0 DW    7.9  0.0   1:32   3 nfsd
22613 root      15   0     0    0     0 DW    7.8  0.0   1:33   1 nfsd
22600 root      15   0     0    0     0 DW    7.5  0.0   1:31   2 nfsd
22604 root      15   0     0    0     0 DW    7.3  0.0   1:32   1 nfsd
22624 root      15   0     0    0     0 DW    7.3  0.0   1:35   1 nfsd
22594 root      15   0     0    0     0 RW    7.0  0.0   1:32   3 nfsd
22595 root      15   0     0    0     0 DW    7.0  0.0   1:32   1 nfsd
22587 root      16   0     0    0     0 DW    6.9  0.0   1:36   0 nfsd
22599 root      15   0     0    0     0 DW    6.8  0.0   1:33   2 nfsd
22588 root      16   0     0    0     0 DW    6.3  0.0   1:34   3 nfsd
22622 root      16   0     0    0     0 DW    6.2  0.0   1:36   0 nfsd
22592 root      15   0     0    0     0 DW    5.8  0.0   1:32   2 nfsd
22609 root      15   0     0    0     0 DW    5.8  0.0   1:35   3 nfsd
22597 root      15   0     0    0     0 DW    5.5  0.0   1:31   3 nfsd
22619 root      15   0     0    0     0 DW    5.3  0.0   1:33   0 nfsd
22593 root      15   0     0    0     0 RW    5.2  0.0   1:33   2 nfsd
22615 root      15   0     0    0     0 DW    5.2  0.0   1:29   3 nfsd
22606 root      15   0     0    0     0 DW    4.5  0.0   1:32   1 nfsd
22623 root      15   0     0    0     0 DW    4.5  0.0   1:32   0 nfsd
22589 root      15   0     0    0     0 DW    4.3  0.0   1:33   3 nfsd
22618 root      15   0     0    0     0 DW    4.2  0.0   1:32   0 nfsd
22607 root      15   0     0    0     0 DW    4.1  0.0   1:35   0 nfsd
22602 root      16   0     0    0     0 DW    3.9  0.0   1:31   1 nfsd
24936 nir       15   0  7612 7072  5088 S     2.6  0.1   0:07   1
gnome-terminal
   13 root      15   0     0    0     0 SW    0.1  0.0   0:08   0
kscand/Normal
  789 root      15   0   940  484   364 S     0.1  0.0   0:43   0 nmbd
    1 root      15   0   108   80    56 S     0.0  0.0   0:04   0 init


[root@BigMama root]# cat /proc/meminfo
        total:    used:    free:  shared: buffers:  cached:
Mem:  6326767616 6309052416 17715200        0 107671552 5681623040
Swap: 1052794880  9883648 1042911232
MemTotal:      6178484 kB
MemFree:         17300 kB
MemShared:           0 kB
Buffers:        105148 kB
Cached:        5545584 kB
SwapCached:       2876 kB
Active:        1904520 kB
ActiveAnon:       6456 kB
ActiveCache:   1898064 kB
Inact_dirty:   1876544 kB
Inact_laundry: 1862944 kB
Inact_clean:     13176 kB
Inact_target:  1131436 kB
HighTotal:     5373824 kB
HighFree:         1024 kB
LowTotal:       804660 kB
LowFree:         16276 kB
SwapTotal:     1028120 kB
SwapFree:      1018468 kB



-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
