From: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
Subject: questions for exportfs
Date: Mon, 23 Jun 2003 15:46:46 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030623152823.6981.KAKMY@mvh.biglobe.ne.jp>
Reply-To: kakuma@tko.ncs.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rcpt-expgw.biglobe.ne.jp ([202.225.89.163])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UL6T-0006rZ-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Jun 2003 23:47:01 -0700
Received: from smtp-gw.biglobe.ne.jp
	by rcpt-expgw.biglobe.ne.jp (nkrw/5808200503) with ESMTP id h5N6kmp11931
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 15:46:48 +0900 (JST)
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

hello,

I'm having 2 question for doing of exportfs command on linux.
Please, reply question.

System: GNU-Debian/Linux 
Architecture: i386
Package: nfs-kernel-server 1.0-2 


1. Some entries with same shared directory and same machine name type
are added by exportfs. Next, when one entry is unexported by exportfs,
in type except MCL_FQDN type, all entries with same shared directory
and same type is unexported.

show the example

# exportfs -o rw *.aaa.co.jp:/share
# exportfs -o rw *.bbb.co.jp:/share
# exportfs -v
/share          *.aaa.co.jp(rw,async,wdelay,root_squash)
/share          *.bbb.co.jp(rw,async,wdelay,root_squash)
/share          <world>(ro,async,wdelay,root_squash)
# exportfs -u *.aaa.co.jp:/share
# exportfs -v
/share          <world>(ro,async,wdelay,root_squash)

Is this result correct?
What reason would exportfs have to unexport all entries with
same shaed directory and same type?

In following code, I think that only appointed entry is
unexported.
Have following code any problem ?


$ diff -uN utils/exportfs/exportfs.c.orig utils/exportfs/exportfs.c
--- utils/exportfs/exportfs.c.orig        Tue Oct  9 05:50:20 2001
+++ utils/exportfs/exportfs.c     Thu Jun 19 13:53:37 2003
@@ -260,9 +260,8 @@
                if (path && strcmp(path, exp->m_export.e_path))
                        continue;
                if (htype != exp->m_client->m_type
-                   || (htype == MCL_FQDN
-                       && !matchhostname(exp->m_export.e_hostname,
-                                         hname)))
+                   || !matchhostname(exp->m_export.e_hostname,
+                                         hname))
                        continue;
                if (verbose) {
                        if (exp->m_exported) {
$


2. While a nfs client is mounting shared directory with wild card
type (or other type except MCL_FQDN), modified options
don't reflect to a client even if options of mounted entry is 
modified by exportfs.
But in MCL_FQDN type this go well.

show the example

(1) nfs server

~# exportfs -o rw *.aaa.co.jp:/share
~# exportfs -v
/share          *.aaa.co.jp(rw,async,wdelay,root_squash)
/share2         <world>(rw,async,wdelay,root_squash)
~#

(2) nfs client

~# mount nfs-server:/share /pub1
~# touch /pub1/tmp1
~# ls -l /pub1
total 0
-rw-r--r--    1 nobody   nogroup         0 Jun 23  2003 tmp1
~#

(3) nfs server

~# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/share  nfs-client.aaa.co.jp(rw,root_squash,async,wdelay) # xxx.xxx.xxx.xxx
~# exportfs -o rw,no_root_squash *.aaa.co.jp:/share
~# exportfs -v
/share          *.aaa.co.jp(rw,async,wdelay,no_root_squash)
/share2         <world>(rw,async,wdelay,root_squash)
~# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/share  nfs-client.aaa.co.jp(rw,root_squash,async,wdelay) # xxx.xxx.xxx.xxx
~#

(4) nfs client

~# touch /pub1/tmp2
~# ls -l /pub1
total 0
-rw-r--r--    1 nobody   nogroup         0 Jun 23  2003 tmp1
-rw-r--r--    1 nobody   nogroup         0 Jun 23  2003 tmp2
~# umount /pub1
~# mount nfs-server:/share /pub1
~# touch /pub1/tmp3
~# ls -l /pub1
total 0
-rw-r--r--    1 nobody   nogroup         0 Jun 23  2003 tmp1
-rw-r--r--    1 nobody   nogroup         0 Jun 23  2003 tmp2
-rw-r--r--    1 root     root            0 Jun 23  2003 tmp3
~#

(5) nfs server

~# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/share  nfs-client.aaa.co.jp(rw,no_root_squash,async,wdelay) # xxx.xxx.xxx.xxx
~#

What reason would exportfs not immediately reflect modified options
with wild card type (or other type except MCL_FQDN) to client ?


Can I deal with the following ?

In function exports_update of utils/exportfs/exportfs.c:
(1)Find entry that belong entry with modified options
in exportlist of type except FQDN from exportlist of
FQDN type,
(2)Set modified options to that entry.
(3)After that reflect it client by original update code.


-- 
fumihiko kakuma <kakuma@tko.ncs.co.jp>



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
