From: "Patrice Seyed" <apseyed@bu.edu>
Subject: ReasmFails increases / NFS performance on Linux Cluster
Date: Sat, 14 Aug 2004 03:46:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001501c481d2$d8900950$6701a8c0@psyche1>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "'Patrice Seyed'" <apseyed@bu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvtFp-0001aT-B7
	for nfs@lists.sourceforge.net; Sat, 14 Aug 2004 00:47:05 -0700
Received: from acsn03.bu.edu ([128.197.159.63])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BvtFo-00025O-Rv
	for nfs@lists.sourceforge.net; Sat, 14 Aug 2004 00:47:05 -0700
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

We have 1 ibm x345 as a management node, and 1 ibm x35 as a storage =
node,
(both dual cpu 2.8 xeon and 2.5gb memory) which is fiber channeled to a =
Raid
5 array with ~900 GB usable. Then we have 10 IBM BladeCenters which =
contain
14 blades per chassis except the last one (has 8). So 134 nodes with =
dual
xeon at 2.8Ghz, mostly with 1GB ram and 20 with 2GB.

All nodes including x345s are set to 1000/full and cabled into a 3750
Cataylst. Bear in mind each BladeCenter chassis include a switch module,
which is also set to 1000/full.

In testing dd writes from /dev/zero to an nfs mount and back in a large
number of batch jobs, I'm seeing high load on the storage node and heavy
slowdowns for example for ssh login, df, or ls on the head node.=20
In my attempt to tune the storage node, I have tried 32k and now 8k
(rsize,wsize in autofs) with no improvement in the slowness. Other
parameters I am using are hard,intr,noatime,retrans=3D20,timeo=3D25. I =
am
currently running 64 nfsd daemons. Also I now have ipfrag_low_thresh and
ipfrag_high_thread both set to 1045876. When I had doubled the default
values for these settings a few weeks ago, it appeared to solve I/O =
errors
that were appearing in the logs for many of the nodes. Still now the
ReasmFails value in /proc/net/snmp steadily increases (for 8k or 32k) =
when I
submit a moderate number of jobs (20-40) that are heavy on I/O.

More info (on the storage node):
$ netstat -s | less
Ip:
    226750504 total packets received
    0 forwarded
    501200 incoming packets discarded
    164658619 incoming packets delivered
    161895650 requests sent out
    5006 fragments dropped after timeout
    80794698 reassemblies required
    13723023 packets reassembled ok
    126665 packet reassembles failed
    2858536 fragments received ok
    14006786 fragments created

Udp:
    159845714 packets received
    142 packets to unknown port received.
    501200 packet receive errors
    152909713 packets sent


I welcome any suggestions or recommendations.

Regards,
=20
Patrice Seyed
Linux System Administrator - SIG
RHCE, SCSA
Boston University School of Medicine




-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
