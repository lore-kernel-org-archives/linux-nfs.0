From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 8 - Enable selection of NFSv4 server in configurator and Makefile
Date: Fri, 11 Oct 2002 10:05:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znIx-0007eC-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znZD-000847-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:22:11 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:22:03 +1000
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


### Comments for ChangeSet



 ----------- Diffstat output ------------
 ./fs/Config.help   |    6 ++++++
 ./fs/Config.in     |    1 +
 ./fs/nfsd/Makefile |    1 +
 3 files changed, 8 insertions(+)

--- ./fs/nfsd/Makefile	2002/10/10 23:22:38	1.1
+++ ./fs/nfsd/Makefile	2002/10/10 23:24:44	1.2
@@ -7,6 +7,7 @@ obj-$(CONFIG_NFSD)	+= nfsd.o
 nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
 			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
+nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o
 nfsd-objs		:= $(nfsd-y)
 
 include $(TOPDIR)/Rules.make
--- ./fs/Config.in	2002/10/10 23:20:10	1.1
+++ ./fs/Config.in	2002/10/10 23:54:06	1.2
@@ -121,6 +121,7 @@ if [ "$CONFIG_NET" = "y" ]; then
 
    dep_tristate 'NFS server support' CONFIG_NFSD $CONFIG_INET
    dep_mbool '  Provide NFSv3 server support' CONFIG_NFSD_V3 $CONFIG_NFSD
+   dep_mbool '  Provide NFSv4 server support (EXPERIMENTAL)' CONFIG_NFSD_V4 $CONFIG_NFSD_V3 $CONFIG_EXPERIMENTAL
    dep_mbool '  Provide NFS server over TCP support (EXPERIMENTAL)' CONFIG_NFSD_TCP $CONFIG_NFSD $CONFIG_EXPERIMENTAL
 
    if [ "$CONFIG_NFS_FS" = "y" -o "$CONFIG_NFSD" = "y" ]; then
--- ./fs/Config.help	2002/10/10 23:26:43	1.1
+++ ./fs/Config.help	2002/10/10 23:54:06	1.2
@@ -576,6 +576,12 @@ CONFIG_NFSD_V3
   If you would like to include the NFSv3 server as well as the NFSv2
   server, say Y here.  If unsure, say Y.
 
+CONFIG_NFSD_V4
+  If you would like to include the NFSv4 server as well as the NFSv2
+  and NFSv3 servers, say Y here.  This feature is experimental, and
+  should only be used if you are interested in helping to test NFSv4.
+  If unsure, say N.
+
 CONFIG_NFSD_TCP
   Enable NFS service over TCP connections.  This the officially
   still experimental, but seems to work well.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
