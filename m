From: Roberto Sebastiano <robs@multiplayer.it>
Subject: gigabit, 2.4.22 and timeo
Date: Tue, 14 Oct 2003 14:24:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1066134271.629.19.camel@newdeal>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9OEq-0004yp-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 05:25:20 -0700
Received: from vsmtp2.tin.it ([212.216.176.222] helo=vsmtp2alice.tin.it)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9OEp-0005Ju-TM
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 05:25:20 -0700
Received: from host117-100.pool80182.interbusiness.it (80.182.100.117) by vsmtp2alice.tin.it (7.0.019)
        id 3F4F171B0006815D for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 14:24:48 +0200
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

Hi,
I have this hw setup:
1 Dual PIII 1Ghz, Intel PRO/1000MT nic, linux 2.4.22 (nfs client)
1 Single P4 2.53Ghz, Intel PRO/1000MT nic, linux 2.4.22, fast RAID5 scsi
disk subsystem (nfs server)
These are cross-connected and both have jumbo frames enabled
This setup will (hopefully) be used to share files between two web
servers under load balancing

Now, to the problem.
I specified the mount options as follows (from /proc/mounts):
rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock,addr=192.168.2.1

When I copy a large file over the network, on the client side I see: 
Oct 14 13:39:24 flanders kernel: nfs: server 192.168.2.1 not responding,
still trying
Oct 14 13:39:24 flanders last message repeated 5 times
Oct 14 13:39:24 flanders kernel: nfs: server 192.168.2.1 OK
Oct 14 13:39:24 flanders last message repeated 5 times
Oct 14 13:39:25 flanders kernel: nfs: server 192.168.2.1 not responding,
still trying
Oct 14 13:39:26 flanders last message repeated 11 times
Oct 14 13:39:26 flanders kernel: nfs: server 192.168.2.1 OK

But the cp process goes just fine.
Setting retrans to 5 or higher "solves" the problem (copying is still ok
and no errors are triggered), but setting timeo to a larger value (60 or
so) doesn't seem to have any effect (between the start of the copy and
the printf of the message, there are only two seconds or so)

I think that the client is just assuming a too low timeout value, and it
keeps sending requests
I found that with nfs over TCP this problem doesn't occur


Is there any way to solve this ?

Thanks,
-- 
Roberto Sebastiano <robs@multiplayer.it>



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
