From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 20/19] A basic NFSv4 client for 2.5.x
Date: Tue, 15 Oct 2002 00:36:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15787.18187.306840.862917@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181Dpg-0004Gp-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 15:37:04 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

This patch defines a new switch in fs/Config.in -
  CONFIG_NFS_V4:  enables nfsv4 client

diff -u --recursive --new-file linux-2.5.42-nfsv4-E03/fs/Config.help linux-2.5.42-nfsv4-E10/fs/Config.help
--- linux-2.5.42-nfsv4-E03/fs/Config.help	2002-10-10 19:54:06.000000000 -0400
+++ linux-2.5.42-nfsv4-E10/fs/Config.help	2002-10-12 13:08:49.000000000 -0400
@@ -535,6 +535,13 @@
   causes open() to return EINVAL if a file residing in NFS is
   opened with the O_DIRECT flag.
 
+CONFIG_NFS_V4
+  Say Y here if you want your NFS client to be able to speak the newer
+  version 4 of the NFS protocol.  This feature is experimental, and
+  should only be used if you are interested in helping to test NFSv4.
+
+  If unsure, say N.
+
 CONFIG_ROOT_NFS
   If you want your Linux box to mount its whole root file system (the
   one containing the directory /) from some other computer over the
diff -u --recursive --new-file linux-2.5.42-nfsv4-E03/fs/Config.in linux-2.5.42-nfsv4-E10/fs/Config.in
--- linux-2.5.42-nfsv4-E03/fs/Config.in	2002-10-10 19:54:06.000000000 -0400
+++ linux-2.5.42-nfsv4-E10/fs/Config.in	2002-10-12 13:13:11.000000000 -0400
@@ -117,6 +117,7 @@
    dep_tristate 'InterMezzo file system support (replicating fs) (EXPERIMENTAL)' CONFIG_INTERMEZZO_FS $CONFIG_INET $CONFIG_EXPERIMENTAL
    dep_tristate 'NFS file system support' CONFIG_NFS_FS $CONFIG_INET
    dep_mbool '  Provide NFSv3 client support' CONFIG_NFS_V3 $CONFIG_NFS_FS
+   dep_mbool '  Provide NFSv4 client support (EXPERIMENTAL)' CONFIG_NFS_V4 $CONFIG_NFS_FS $CONFIG_EXPERIMENTAL
    dep_bool '  Root file system on NFS' CONFIG_ROOT_NFS $CONFIG_NFS_FS $CONFIG_IP_PNP
 
    dep_tristate 'NFS server support' CONFIG_NFSD $CONFIG_INET


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
