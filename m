From: Peter Gostelow <gostelow@global.co.za>
Subject: nfs newbie, where to find portmapper?
Date: Thu, 21 Aug 2003 04:52:06 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308210452.06388.gostelow@global.co.za>
Reply-To: gostelow@global.co.za
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ctb-mesg1.saix.net ([196.25.240.73])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qKSt-00029v-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Aug 2003 15:33:03 -0700
Received: from kdp53-01-p98.gt.saix.net (kdp53-01-p98.gt.saix.net [155.239.86.98])
	by ctb-mesg1.saix.net (Postfix) with ESMTP id B4F7F5099
	for <nfs@lists.sourceforge.net>; Sat, 23 Aug 2003 00:32:51 +0200 (SAST)
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

Slightly off-topic, but I'm a bit stuck.

After building a custom GNU/Linux system, I am attemping to install a LAN 
using three computers where one is a bridge/router between two ethernet 
links. Hopefully, nfs will export the main (/usr/share, /home) directories on 
one host to all the others.

My problem is I cannot find a recent portmap source tarball, the debian one 
(file dates range from 1992 - 1996!) is incompatible with glibc headers. The 
Slackware has a binary only or a similarly old source. Perhaps I'm missing 
something, but the Sun Microsystem website doesn't list any rpc stuff, 
either. The alternative rpcbind (as found by web searches) apparently doesn't 
support the Intel platform.

So, what portmapper are the nfs developers using and is there a source tarball 
available for it?

System specs:-
libc: 2.3.2
kernel: Linux 2.4.20
gcc: 3.2.2
binutils: 2.14
platform: i686
portmap: 5beta

(
for what its worth, the compile errors/warnings are:

portmap.c: In function `xperror':
portmap.c:299: argument `what' doesn't match prototype
/usr/lib/gcc-lib/i686-pc-linux-gnu/3.2.2/include/stdio.h:601: prototype 
declaration [I can pacify gcc here, so this isn't a problem]
portmap.c: In function `reg_service':
portmap.c:353: warning: passing arg 2 of `svc_sendreply' from incompatible 
pointer type [this is a real pain because I can't find where xdrproc_t is 
defined and the argument passed is a bool_t type]
..
similar warnings follow, all related to svc_sendreply() args
)

I am not (yet) on the mailing list, so please reply to the reply-to address.

tia

Peter



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
