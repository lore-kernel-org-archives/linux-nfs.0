From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: NFS over TCP performance
Date: Mon, 17 Jun 2002 09:05:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D0E08D8.72BC5FBD@attbi.com>
References: <3D0C8760.8050308@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Jyxu-00018M-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Jun 2002 09:02:50 -0700
To: Felix Radensky <felix@allot.com>,
 	NFS maillist <nfs@lists.sourceforge.net>
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

Hi -

There is a cost for using TCP, but it might not be as much 
system-wide as this test indicates.  To get a really broad
picture, I'd suggest using IOzone, which isn't hard to set
up, and gives you a lot of data over a broad spectrum of 
file access types.  The parameters you might want to use
are disucssed in the performance section of the howto, at
http://nfs.sourceforge.net/nfs-howto/performance.html

I think you are probably right about 8K being the best 
transfer size for your particular tests, but I'd have to 
go back and look at my IOzone runs to see what might be
best in genernal.  You can still get a writeup plus the
benchmark data that I generated late last year, at 
http://www.missioncriticallinux.com/orph/

It also looks like you are not using jumbo frames, which 
Trond has mentioned as a big performance boost for tcp in 
100 baseT full duplex environments.

Also, since you're using 0.3.3 utils, I assume you are 
using sync exports; otherwise there are costs at the server 
which are hidden from the benchmark data.

Tom

Felix Radensky wrote:
> 
> Hi,
> 
> I'm testing NFS server performance in the following environment:
> 
> NFS server :
> 
> Compaq Proliant ML 350,
> dual 1.33 GHz CPU,
> 1G of RAM,
> 132G RAID5 based on Compaq Smart Array 532 (cciss driver),
> linux-2.4.19-pre10 SMP kernel with latest NFS_ALL and NFS TCP patches,
> ext3 filesystem with internal 400M journal,
> NFS version 3,
> nfs-utils 0.3.3,
> e100 NIC driver version 2.0.30,
> 16 nfs server threads,
> rmem_default and rmem_max are set to 1048576
> 
> NFS client:
> 
> Dual 1G CPU board based on ServerWorks chipset,
> 1G of RAM,
> linux-2.4.18,
> NFS version 3,
> mount-2.11b,
> e100 NIC driver version 2.0.30
> 
> Client and server are connected to 10/100 Cisco switch,
> which is not congested, and both are synchronized to
> 100 Base Tx Full Duplex.
> 
> Client mounts /users directory like this:
> 
> mount -o rsize=8192,wsize=8192,hard,intr,tcp server_ip:/users /users
> 
> My test, as explained in Linux NFS howto, consists of copying a 2G
> file, from client to server, like this
> 
> time dd if=/dev/zero of=testfile bs=8k count=262144
> 
> It takes about 4.5 min to complete the write. The same test, but over UDP,
> takes around 3 min. My question is: is NFS over TCP supposed to be much
> slower than over UDP, and if no, how can I improve the performance.
> I've tried other values for rsize/wsize, but 8k seems to give the best
> performance.
> I've also tried mounting ext3 filesystem with data=journal, but then
> test runs
> about 4 times longer.
> 
> TIA,
> 
> Felix.
> 
> _______________________________________________________________
> 
> Sponsored by:
> ThinkGeek at http://www.ThinkGeek.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
