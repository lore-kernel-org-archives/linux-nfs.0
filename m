From: Sting YC Tao <stingtao@tw.ibm.com>
Subject: Linux NFS server vs Solaris NFS client performance problem
Date: Thu, 8 May 2003 01:19:30 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF10F6D17F.EB18DF1E-ON48256D1F.005DC811@tw.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ausmtp02.au.ibm.com ([202.135.136.105])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DSXt-0007Zh-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 10:17:34 -0700
Received: from d23rh902.au.ibm.com (d23rh902.au.ibm.com [9.185.167.101])
	by ausmtp02.au.ibm.com (8.12.9/8.12.9) with ESMTP id h47HHNil179330
	for <nfs@lists.sourceforge.net>; Thu, 8 May 2003 03:17:23 +1000
Received: from d23ml050.tw.ibm.com (d23av02.au.ibm.com [9.185.167.107])
	by d23rh902.au.ibm.com (8.12.8/NCO/VER6.5) with ESMTP id h47HHSGj116494
	for <nfs@lists.sourceforge.net>; Thu, 8 May 2003 03:17:29 +1000
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

Recently, I've got trouble in an nfs performance problem.

I've setup Redhat 7.3(2.4.18-10) as nfs server on Gigabit network. When
Solaris 5.8 mount it and copy a large file from linux nfs server, the r/w
performance is aweful(at most 25% compared to solaris-to-solaris).
I've tried to modify  ./include/linux/nfsd/const.h NFSSVC_MAXBLKSIZE from
8192 to 32768 and rebuild kernel image. That didn't help the performance a
lot.

I have the following questions:
1. Is there a known issue between Solaris NFS client and Linux NFS Server
in terms of performance?
2. I'd like to try NFS over TCP at this exact kernle level(2.4.18-10), I
don't know where to start...(The information I found mentioned the patches
are for 2.4.18-17 and later??)

Please help shed some light for me. Thanks!




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
