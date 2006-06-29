From: wangmin@hed.com.cn
Subject: nfs: server 10.1.1.144 not responding, still trying
Date: Thu, 29 Jun 2006 16:00:52 +0800
Message-ID: <20060629080052.11857.qmail@hed.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FvrpO-0002vg-VV
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 01:24:47 -0700
Received: from [218.244.233.140] (helo=Thunder.hed.com.cn ident=root)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1FvrpN-0007Nx-7D
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 01:24:47 -0700
Received: from hed.com.cn (dns2.hed.com.cn [218.244.233.132])
	by Thunder.hed.com.cn (8.11.3/8.11.3) with SMTP id k5T8R4o01147
	for <nfs@lists.sourceforge.net>; Thu, 29 Jun 2006 16:27:06 +0800 (CST)
	(envelope-from wangmin@hed.com.cn)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

hi man: 

   I am porting linux-2.4.18 to ARM920t and I want to use NFS booting.But I
got an error:

    nfs: server 10.1.1.144 not responding, still trying 

The command line is like this :
"root=/dev/nfs rw nfsroot=10.1.1.144:/home/root 
ip=10.1.1.142:10.1.1.144::255.0.0.0::eth0:off init=/sbin/init console=ttyS0 
mem=64M "; 

The TCPDUMP got like this:
15:59:29.488818 arp who-has 10.1.1.144 tell 10.1.1.142
15:59:29.490449 arp reply 10.1.1.144 is-at 00:e0:4c:d4:e1:6e
15:59:29.489716 IP 10.1.1.142.800 > 10.1.1.144.sunrpc: UDP, length 56
15:59:29.490004 IP 10.1.1.144.sunrpc > 10.1.1.142.800: UDP, length 28
15:59:29.498555 IP 10.1.1.142.800 > 10.1.1.144.sunrpc: UDP, length 56
15:59:29.499114 IP 10.1.1.144.sunrpc > 10.1.1.142.800: UDP, length 28
15:59:29.503878 IP 10.1.1.142.800 > 10.1.1.144.929: UDP, length 64
15:59:29.507898 IP 10.1.1.144.929 > 10.1.1.142.800: UDP, length 60
15:59:29.513782 IP 10.1.1.142.53491924 > 10.1.1.144.nfs: 104 getattr [|nfs]
15:59:29.514334 IP 10.1.1.144.nfs > 10.1.1.142.53491924: reply ok 96 getattr 
DIR 40333 ids 0/0 sz 4096
15:59:29.516656 IP 10.1.1.142.70269140 > 10.1.1.144.nfs: 104 fsstat [|nfs]
15:59:29.517030 IP 10.1.1.144.nfs > 10.1.1.142.70269140: reply ok 48 fsstat 
tsize 32768 bsize 4096 blocks 28286638 bfree 24450403 bavail 23013527
15:59:29.524987 IP 10.1.1.142.87046356 > 10.1.1.144.nfs: 112 lookup [|nfs]
15:59:29.525028 IP 10.1.1.144.nfs > 10.1.1.142.87046356: reply ok 128 lookup 
[|nfs]
15:59:29.527148 IP 10.1.1.142.103823572 > 10.1.1.144.nfs: 116 lookup [|nfs]
15:59:29.527188 IP 10.1.1.144.nfs > 10.1.1.142.103823572: reply ok 128 
lookup [|nfs]
15:59:29.529211 IP 10.1.1.142.120600788 > 10.1.1.144.nfs: 104 readlink 
[|nfs]
15:59:29.529343 IP 10.1.1.144.nfs > 10.1.1.142.120600788: reply ok 40 
readlink "ttyS0"
15:59:29.531269 IP 10.1.1.142.137378004 > 10.1.1.144.nfs: 116 lookup [|nfs]
15:59:29.531309 IP 10.1.1.144.nfs > 10.1.1.142.137378004: reply ok 128 
lookup [|nfs]
15:59:29.542845 IP 10.1.1.142.154155220 > 10.1.1.144.nfs: 112 lookup [|nfs]
15:59:29.542884 IP 10.1.1.144.nfs > 10.1.1.142.154155220: reply ok 128 
lookup [|nfs]
15:59:29.545056 IP 10.1.1.142.170932436 > 10.1.1.144.nfs: 112 lookup [|nfs]
15:59:29.545157 IP 10.1.1.144.nfs > 10.1.1.142.170932436: reply ok 128 
lookup [|nfs]
15:59:29.548865 IP 10.1.1.142.187709652 > 10.1.1.144.nfs: 104 getattr [|nfs]
15:59:29.548901 IP 10.1.1.144.nfs > 10.1.1.142.187709652: reply ok 96 
getattr REG 100755 ids 0/0 sz 424317
15:59:29.551341 IP 10.1.1.142.204486868 > 10.1.1.144.nfs: 116 read [|nfs]
15:59:29.551497 IP 10.1.1.144.nfs > 10.1.1.142.204486868: reply ok 1472 read
15:59:29.551511 IP 10.1.1.144 > 10.1.1.142: udp
15:59:29.551542 IP 10.1.1.144 > 10.1.1.142: udp
15:59:30.094837 IP 10.1.1.142.204486868 > 10.1.1.144.nfs: 116 read [|nfs]
15:59:30.094995 IP 10.1.1.144.nfs > 10.1.1.142.204486868: reply ok 1472 read
15:59:30.095004 IP 10.1.1.144 > 10.1.1.142: udp
15:59:30.095009 IP 10.1.1.144 > 10.1.1.142: udp
15:59:31.188712 IP 10.1.1.142.204486868 > 10.1.1.144.nfs: 116 read [|nfs]
15:59:31.188811 IP 10.1.1.144.nfs > 10.1.1.142.204486868: reply ok 1472 read
15:59:31.188818 IP 10.1.1.144 > 10.1.1.142: udp
15:59:31.188823 IP 10.1.1.144 > 10.1.1.142: udp
15:59:33.376012 IP 10.1.1.142.204486868 > 10.1.1.144.nfs: 116 read [|nfs]
15:59:33.376114 IP 10.1.1.144.nfs > 10.1.1.142.204486868: reply ok 1472 read
15:59:33.376121 IP 10.1.1.144 > 10.1.1.142: udp
15:59:33.376126 IP 10.1.1.144 > 10.1.1.142: udp
15:59:33.391254 arp who-has 10.1.1.144 tell 10.1.1.142
15:59:33.391263 arp reply 10.1.1.144 is-at 00:e0:4c:d4:e1:6e
........ 

then they stopped,
can somebody give me some advice ?
thanks for reading ! 


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
