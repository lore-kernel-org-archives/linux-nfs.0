From: Hans-Peter Jansen <hpj@urpla.net>
Subject: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Sat, 23 Aug 2003 14:04:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308231404.34087.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from moutng.kundenserver.de ([212.227.126.189])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qX8K-0002Ur-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Aug 2003 05:04:40 -0700
Received: from [212.227.126.160] (helo=mrelayng.kundenserver.de)
	by moutng.kundenserver.de with esmtp (Exim 3.35 #1)
	id 19qX8I-0002bI-00
	for nfs@lists.sourceforge.net; Sat, 23 Aug 2003 14:04:38 +0200
Received: from [217.231.159.217] (helo=mail.lisa.de)
	by mrelayng.kundenserver.de with asmtp (Exim 3.35 #1)
	id 19qX8H-0002Og-00
	for nfs@lists.sourceforge.net; Sat, 23 Aug 2003 14:04:38 +0200
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

after kernel update all my (diskless) systems clutter up the syslog
with:

Aug 23 13:41:42 yogi kernel: nfs: server shrek not responding, still trying
Aug 23 13:41:42 yogi last message repeated 8 times
Aug 23 13:41:44 yogi kernel: nfs: server xxx.yy.zz.102 not responding, still trying
Aug 23 13:41:45 yogi kernel: nfs: server xxx.yy.zz.102 OK
Aug 23 13:41:45 yogi kernel: nfs: server shrek OK
Aug 23 13:41:45 yogi last message repeated 8 times
Aug 23 13:43:17 yogi kernel: nfs: server shrek not responding, still trying
Aug 23 13:43:17 yogi last message repeated 8 times
Aug 23 13:43:19 yogi kernel: nfs: server xxx.yy.zz.102 not responding, still trying
Aug 23 13:43:20 yogi kernel: nfs: server xxx.yy.zz.102 OK
Aug 23 13:43:20 yogi kernel: nfs: server shrek OK
Aug 23 13:43:20 yogi last message repeated 8 times
Aug 23 13:44:53 yogi kernel: nfs: server shrek not responding, still trying
Aug 23 13:44:53 yogi last message repeated 15 times
Aug 23 13:44:54 yogi kernel: nfs: server xxx.yy.zz.102 not responding, still trying
Aug 23 13:44:54 yogi kernel: nfs: server shrek not responding, still trying
Aug 23 13:44:56 yogi kernel: nfs: server shrek OK
Aug 23 13:44:56 yogi kernel: nfs: server xxx.yy.zz.102 OK
Aug 23 13:44:56 yogi kernel: nfs: server shrek OK
Aug 23 13:44:56 yogi last message repeated 15 times

Funny is the continous change of name <-> ip address. I would rule out 
named problems, but who knows... It happens predictable with 
2.4.22-pre10, while it doesn't happen with 2.4.20.

Anybody with an idea, whats going on here?

TIA,
Pete


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
