From: Jeff Layton <jeffrey.b.layton@lmco.com>
Subject: Changing block size in 2.4.20 kernel
Date: Tue, 22 Jul 2003 12:04:57 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F1D60A9.1010203@lmco.com>
Reply-To: jeffrey.b.layton@lmco.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailgw1a.lmco.com ([192.31.106.7])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19f0Lc-0003MI-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 09:50:44 -0700
Received: from emss02g01.ems.lmco.com (relay2.ems.lmco.com [166.29.2.54])
	by mailgw1a.lmco.com (8.11.6p2/8.11.6) with ESMTP id h6MGoHS08835
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 10:50:17 -0600 (MDT)
Received: from CONVERSION-DAEMON.lmco.com by lmco.com (PMDF V6.1-1 #40644)
 id <0HIF00E01QRR8P@lmco.com> for nfs@lists.sourceforge.net; Tue, 22 Jul 2003 10:50:16 -0600 (MDT)
Received: from emss02g02.ems.lmco.com ([166.29.2.60]) by lmco.com (PMDF V6.1-1 #40644)
 with ESMTP id <0HIF00KJWQRMNH@lmco.com> for nfs@lists.sourceforge.net; Tue, 22 Jul 2003 10:50:10 -0600 (MDT)
Received: from CONVERSION-DAEMON.lmco.com by lmco.com (PMDF V6.1-1 #40645)
 id <0HIF00D01QRMLL@lmco.com> for nfs@lists.sourceforge.net; Tue, 22 Jul 2003 10:50:10 -0600 (MDT)
Received: from lmco.com ([134.5.193.209]) by lmco.com (PMDF V6.1-1 #40645) with ESMTP id <0HIF00MH9QRGE9@lmco.com> for
 nfs@lists.sourceforge.net; Tue, 22 Jul 2003 10:50:05 -0600 (MDT)
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

Hello,

   I'd like to increase the block size in the 2.4.20 kernel (can't upgrade
for various reasons) and I can't apply the TCP patches that change it.
This particular machine is a server for a beowulf, so it's a Linux
server for Linux clients (all the same kernel).
   If I change ./include/linux/nfsd/const.h, NFSSVC_MAXBLKSIZE
to 32k (32768), rebuild, reinstall, reboot, etc. Will this then change
the blocksize for the NFS server? (I just want to be sure :) Then the
clients can handle a 32k blocksize even running UDP? (Again, I
just want to be sure :)

TIA!

Jeff



-- 
Dr. Jeff Layton
Chart Monkey - Aerodynamics and CFD
Lockheed-Martin Aeronautical Company - Marietta




-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
