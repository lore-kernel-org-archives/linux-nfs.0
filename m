From: Chris Jensen <chrisjensen@chrisjensen.info>
Subject: NFS Server lockup
Date: Sat, 29 Jun 2002 00:18:39 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200206290018.39994.chrisjensen@chrisjensen.info>
Reply-To: chrisjensen@chrisjensen.info
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="Boundary_(ID_idEN+4yHtmgo1Bnhkgkuzw)"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from seagoon.newcastle.edu.au ([134.148.24.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NwUh-0003jy-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Jun 2002 07:13:04 -0700
Received: from banerjee ([134.148.4.49])
 by mail.newcastle.edu.au (PMDF V5.2-32 #35875)
 with ESMTP id <0GYF00FWN65LY1@mail.newcastle.edu.au> for
 nfs@lists.sourceforge.net; Sat, 29 Jun 2002 00:12:57 +1000 (EST)
Received: from chris (c53h3-asy73.newcastle.edu.au [134.148.10.193])
 by banerjee.newcastle.edu.au
 (iPlanet Messaging Server 5.1 (built May  7 2001)) with ESMTP id
 <0GYF00G4F65J19@banerjee.newcastle.edu.au> for nfs@lists.sourceforge.net; Sat,
 29 Jun 2002 00:12:57 +1000 (EST)
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


--Boundary_(ID_idEN+4yHtmgo1Bnhkgkuzw)
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT

Hi,
I recently experienced a lock up from the nfs software on my linux box.
I had a partition (type vfat), shared read only from one computer and another 
computer I was untaring an archive stored on that partition to a local disk - 
the untarring process stopped in the middle of extracting.
Here's what ps -x had to say about the nfs processes:
  118 ?        DW     0:00 [nfsd]
  119 ?        DW     0:00 [nfsd]
  120 ?        SW     0:00 [lockd]
  121 ?        SW     0:02 [rpciod]
  122 ?        DW     0:00 [nfsd]
  124 ?        DW     0:00 [nfsd]
  125 ?        DW     0:00 [nfsd]
  126 ?        DW     0:00 [nfsd]
  127 ?        DW     0:00 [nfsd]

Attatched is a portion of the servers sys.log when it occured.

I tried restarting all NFS processes - but stopping nfsd failed.

The only solution I could find was to reboot the server
After I rebooted, I remounted the share on the client computer and tried 
extracting the tar archive again - it went fine that time.

Does anyone know what may have caused this?
I'm running kernel 2.4.17 with preempt and lock breaking patches, and 
nfs-utils-0.3.1

-- 
Chris Jensen
chrisjensen@chrisjensen.info

Public Key: http://chrisjensen.info/public_key/

Wait: Did you know that there's a direct correlation between the decline of
Spirograph and the rise in gang activity?  Think about it.
- Dr Spirograph (The Simpsons)

--Boundary_(ID_idEN+4yHtmgo1Bnhkgkuzw)
Content-type: text/x-log; name=sys.log; charset=us-ascii
Content-disposition: attachment; filename=sys.log
Content-transfer-encoding: 7BIT

Jun 27 14:17:45 chris modprobe: modprobe: Can't locate module net-pf-10
Jun 27 15:09:24 chris kernel: sending pkt_too_big to self
Jun 27 15:09:54 chris modprobe: modprobe: Can't locate module net-pf-10
Jun 27 15:10:51 chris kernel: sending pkt_too_big to self
Jun 27 15:11:03 chris modprobe: modprobe: Can't locate module net-pf-10
Jun 27 19:46:53 chris kernel: Unable to handle kernel NULL pointer dereference at virtual address 00000008
Jun 27 19:46:53 chris kernel:  printing eip:
Jun 27 19:46:53 chris kernel: ceaa0312
Jun 27 19:46:53 chris kernel: *pde = 00000000
Jun 27 19:46:53 chris kernel: Oops: 0000
Jun 27 19:46:53 chris kernel: CPU:    0
Jun 27 19:46:53 chris kernel: EIP:    0010:[rtc:__insmod_rtc_S.bss_L24+183130/25025336]    Not tainted
Jun 27 19:46:53 chris kernel: EFLAGS: 00010217
Jun 27 19:46:53 chris kernel: eax: 00000000   ebx: 00000000   ecx: 00000005   edx: cea69b00
Jun 27 19:46:53 chris kernel: esi: 00000005   edi: 00000000   ebp: cb7fe8e0   esp: cd33de10
Jun 27 19:46:53 chris kernel: ds: 0018   es: 0018   ss: 0018
Jun 27 19:46:53 chris kernel: Process nfsd (pid: 123, stackpage=cd33d000)
Jun 27 19:46:53 chris kernel: Stack: cd31c604 00000005 c966f000 11270000 cd8cf9ec cd33dec0 cd31c604 ceaa06f8 
Jun 27 19:46:53 chris kernel:        cd8cf800 cd31c614 00000005 00000003 00000001 cd33dec0 00000004 cd31c694 
Jun 27 19:46:53 chris kernel:        cd31c604 cd33dea8 cd31c614 cd33dec0 cd42fe40 00000040 ceaa1904 cd31c200 
Jun 27 19:46:53 chris kernel: Call Trace: [rtc:__insmod_rtc_S.bss_L24+184128/25024338] [rtc:__insmod_rtc_S.bss_L24+188748/25019718] [rtc:__insmod_rtc_S.bss_L24+189389/25019077] [inet_sendmsg+58/64] [sock_sendmsg+108/140] 
Jun 27 19:46:53 chris kernel:    [rtc:__insmod_rtc_S.bss_L24+209676/24998790] [rtc:__insmod_rtc_S.bss_L24+236744/24971722] [rtc:__insmod_rtc_S.bss_L24+236744/24971722] [rtc:__insmod_rtc_S.bss_L24+175595/25032871] [rtc:__insmod_rtc_S.bss_L24+236744/24971722] [rtc:__insmod_rtc_S.bss_L24+78791/25129675] 
Jun 27 19:46:53 chris kernel:    [rtc:__insmod_rtc_S.bss_L24+235136/24973330] [rtc:__insmod_rtc_S.bss_L24+175067/25033399] [kernel_thread+40/56] 
Jun 27 19:46:53 chris kernel: 
Jun 27 19:46:53 chris kernel: Code: 8b 47 08 bb 8c ff ff ff 85 c0 0f 84 9b 01 00 00 0f b7 40 32 
Jun 27 19:47:45 chris modprobe: modprobe: Can't locate module net-pf-10
Jun 27 19:55:13 chris rpc.mountd: authenticated mount request from 192.168.0.1:841 for /mnt/data (/mnt/data) 
Jun 27 19:57:35 chris rpc.mountd: Caught signal 15, un-registering and exiting. 
Jun 27 19:58:02 chris rpc.mountd: authenticated mount request from 192.168.0.1:932 for /tmp (/tmp) 

--Boundary_(ID_idEN+4yHtmgo1Bnhkgkuzw)--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
