From: Eric Whiting <ewhiting@amis.com>
Subject: 2.4.20rc1 NFS V3 UDP client problems
Date: Thu, 14 Nov 2002 10:37:35 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DD3DF5F.854AD688@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CNny-0004LN-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 09:29:26 -0800
Received: from amis.com (gannett.design.amis.com [172.16.17.181])
	by mailtest.design.amis.com (Postfix) with ESMTP id A3E4FF524
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 11:18:30 -0700 (MST)
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
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

I'm seeing some 2.4.20rc1 client problems.

25 seconds to write a 1G file
13 minutes to read that file back

CLIENT 2.4.20rc1 NFSV3 UDP HIGHMEM SUPPORT ON
gigE card with jumbo frames enabled 
Tested with both netgear and intel -- same result

SERVER
Netapps 825 ontap 6.3
gigE card with jumbo frames enabled

private point-to-point connection.

Is this a HIGHMEM problem? Or is it related to jumbo frames? I'll test
with both disabled.

I'm seeing network errors on the client -- dropped and overruns are both
the same.

Anything I should try?
 
eric


# time dd if=/dev/zero of=file1 bs=1G count=1
1+0 records in
1+0 records out

real    0m25.881s
user    0m0.000s
sys     0m4.220s


(run a program to calloc 1G of RAM and clear some buffer cache)


# time dd if=file1  of=/dev/null

2097152+0 records in
2097152+0 records out

real    13m7.445s
user    0m0.370s
sys     0m2.160s

 # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:02:B3:AC:52:F5
          inet addr:10.0.0.2  Bcast:10.255.255.255  Mask:255.0.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:1534585 errors:10240 dropped:10240 overruns:10240
frame:0
          TX packets:5332748 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:2069590604 (1973.7 Mb)  TX bytes:587855320 (560.6 Mb)
          Interrupt:12 Base address:0xc000 Memory:ea020000-ea040000


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
