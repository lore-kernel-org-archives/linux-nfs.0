From: David Dougall <davidd@et.byu.edu>
Subject: rquotad solution
Date: Thu, 4 Sep 2003 10:16:56 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.51.0309041001260.27878@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19uwnJ-0008Qb-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Sep 2003 09:17:13 -0700
Received: from postal3.et.byu.edu ([128.187.122.133])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19uwnB-0000vB-PC
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 09:17:05 -0700
Received: from mail by postal3.et.byu.edu with local (Exim 4.20)
	id 19uwn2-0003I6-Ul
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 10:16:56 -0600
Received: from lewis.et.byu.edu ([128.187.112.50])
	by postal3.et.byu.edu with esmtp (Exim 4.20)
	id 19uwn2-0003H6-M3
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 10:16:56 -0600
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

I feel quite silly responding to my own query.
I was mistaken in saying my older servers ran nfs-utils-1.0.1.  They did
have this, but were not using rpc.rquotad.  I was using rpc.rquotad from
the quota package.
nfs-utils rquotad only supports ext2 and ext3 so my xfs filesystems were
not working.

Also, whoever is in charge of the rpc.rquotad portion of
nfs-utils package, the following patch seems to make more sense detecting
currently mounted filesystems rather than only what is in /etc/fstab.
--David Dougall


diff -ur nfs-utils-1.0.5/utils/rquotad/mntent.h
nfs-utils-1.0.5-new/utils/rquotad/mntent.h
--- nfs-utils-1.0.5/utils/rquotad/mntent.h      Tue May  9 18:36:19 2000
+++ nfs-utils-1.0.5-new/utils/rquotad/mntent.h  Thu Sep  4 10:12:34 2003
@@ -4,7 +4,7 @@
 #include <features.h>

 #define MNTTAB "/etc/fstab"
-#define MOUNTED "/etc/mtab"
+#define MOUNTED "/proc/mounts"

 #define MNTMAXSTR      512

diff -ur nfs-utils-1.0.5/utils/rquotad/rquota_server.c
nfs-utils-1.0.5-new/utils/rquotad/rquota_server.c
--- nfs-utils-1.0.5/utils/rquotad/rquota_server.c       Wed Jun 27
10:45:56 2001
+++ nfs-utils-1.0.5-new/utils/rquotad/rquota_server.c   Thu Sep  4
10:12:49 2003
@@ -108,7 +108,7 @@
       }
    }

-   fp = setmntent(MNTTAB, "r");
+   fp = setmntent(MOUNTED, "r");
    while ((mnt = getmntent(fp)) != (struct mntent *)0) {
       if (stat(mnt->mnt_dir, &stm) == -1)
          continue;



______________________________________
Inflex Virus Scanner - installed on mailserver for domain @et.byu.edu
Queries to: postmaster@et.byu.edu


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
