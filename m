From: "Martynas Buozis" <martynas@ti.com>
Subject: Root-NFS problem
Date: Tue, 13 May 2003 21:36:16 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <005001c31986$ec556f80$6464a8c0@foxie>
Reply-To: "Martynas Buozis" <martynas@ti.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="windows-1257"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from news.ti.com ([192.94.94.33] helo=dragon.ti.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19FfZa-0006PV-00
	for <nfs@lists.sourceforge.net>; Tue, 13 May 2003 12:36:26 -0700
Received: from dlep52.itg.ti.com ([157.170.134.103])
	by dragon.ti.com (8.12.9/8.12.9) with ESMTP id h4DJaLKX017909
	for <nfs@lists.sourceforge.net>; Tue, 13 May 2003 14:36:21 -0500 (CDT)
Received: from ffab.tide.ti.com (localhost [127.0.0.1])
	by dlep52.itg.ti.com (8.12.9/8.12.9) with ESMTP id h4DJaJ2s028248
	for <nfs@lists.sourceforge.net>; Tue, 13 May 2003 14:36:20 -0500 (CDT)
Received: from foxie ([172.24.68.9])
	by ffab.tide.ti.com (8.12.6/8.12.6) with SMTP id h4DJaHZu009728
	for <nfs@lists.sourceforge.net>; Tue, 13 May 2003 21:36:18 +0200 (MEST)
To: <nfs@lists.sourceforge.net>
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

Hello

I am using diskless clients that boots over BOOTP and mount root file system
over nfs. But I got stuck with mounting root file system shared on
EMC/Celerra. While evrything works fine when root file system is shared on
SUN/Solaris box.

This is how boot process ends when I use Celerra as NFS server :

Looking up port of RPC 100003/2 on aaa.bbb.ccc.xxx
Looking up port of RPC 100005/1 on aaa.bbb.ccc.xxx
call_verify: server accept status: 5
call_verify: server accept status: 5
call_verify: server accept status: 5
RPC: garbage, exit EIO
Root-NFS: Server returned error -5 while mounting /BOOTP/redhat/8.0/
VFS: Unable to mount root fs via NFS, trying floppy.

This is how it looks (all options are same, except for NFS server IP and
share path, all files are identical on shared file system) when root
file system is shared on SUN/Solaris :

Looking up port of RPC 100003/2 on aaa.bbb.ccc.yyy
Looking up port of RPC 100005/1 on aaa.bbb.ccc.yyy
VFS: Mounted root (nfs filesystem).

I can mount file system using command line "mount
aaa.bbb.ccc.xxx:/BOOTP/redhat/8.0 /mnt" shared on EMC/Celerra when RedHat
is up and running. I can access all files there - no problems at all. The
problem is only to mount root file system during OS boot.

Can you give any tip what is wrong and what are possible ways to fix it ? I
think that status 5 mean "A result was too large to fit in buffer.", but 1)
I am not sure and 2) this gives me no clue how to fix it !

Any help would be highly appreciated.

With best regards
Martynas




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
