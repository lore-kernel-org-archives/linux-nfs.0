From: Felix Radensky <felix@allot.com>
Subject: NFS over TCP performance
Date: Sun, 16 Jun 2002 15:41:04 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D0C8760.8050308@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mxout3.netvision.net.il ([194.90.9.24])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17JZMh-000283-00
	for <nfs@lists.sourceforge.net>; Sun, 16 Jun 2002 05:42:43 -0700
Received: from exg.allot.com ([199.203.223.202]) by mxout3.netvision.net.il
 (iPlanet Messaging Server 5.2 HotFix 0.3 (built May 13 2002))
 with ESMTP id <0GXS00CZKTWVSC@mxout3.netvision.net.il> for
 nfs@lists.sourceforge.net; Sun, 16 Jun 2002 15:41:19 +0300 (IDT)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi,

I'm testing NFS server performance in the following environment:

NFS server :
 
Compaq Proliant ML 350,
dual 1.33 GHz CPU,
1G of RAM,
132G RAID5 based on Compaq Smart Array 532 (cciss driver),
linux-2.4.19-pre10 SMP kernel with latest NFS_ALL and NFS TCP patches,
ext3 filesystem with internal 400M journal,
NFS version 3,
nfs-utils 0.3.3,
e100 NIC driver version 2.0.30,
16 nfs server threads,
rmem_default and rmem_max are set to 1048576
 
NFS client:

Dual 1G CPU board based on ServerWorks chipset,
1G of RAM,
linux-2.4.18,
NFS version 3,
mount-2.11b,
e100 NIC driver version 2.0.30

Client and server are connected to 10/100 Cisco switch,
which is not congested, and both are synchronized to
100 Base Tx Full Duplex.

Client mounts /users directory like this:

mount -o rsize=8192,wsize=8192,hard,intr,tcp server_ip:/users /users

My test, as explained in Linux NFS howto, consists of copying a 2G
file, from client to server, like this

time dd if=/dev/zero of=testfile bs=8k count=262144

It takes about 4.5 min to complete the write. The same test, but over UDP,
takes around 3 min. My question is: is NFS over TCP supposed to be much
slower than over UDP, and if no, how can I improve the performance.
I've tried other values for rsize/wsize, but 8k seems to give the best 
performance.
I've also tried mounting ext3 filesystem with data=journal, but then 
test runs
about 4 times longer.

TIA,

Felix.


_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
