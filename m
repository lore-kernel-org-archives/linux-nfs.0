From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 2] mark NFS/TCP not EXPERIMENTAL
Date: Tue, 27 Jul 2004 14:09:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BpJHD-0005ci-7W@notabene.cse.unsw.edu.au>
References: <20040727140509.21492.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpJHK-0002rX-SR
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:09:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BpJHJ-00018S-Ud
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:09:26 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



NFS/TCP has been used widely for a long time now, and is now
enabled by many distros and typically recommended for lossy or
congested networks.  This patch removes the EXPERIMENTAL tag,
updates the help text, and changes arch defconfigs to set it
by default (note that several already did so).

From: Greg Banks <gnb@sgi.com>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./Documentation/Configure.help |    7 ++++---
 ./arch/i386/defconfig          |    2 +-
 ./arch/ia64/defconfig          |    2 +-
 ./arch/mips/defconfig          |    2 +-
 ./arch/mips64/defconfig        |    2 +-
 ./arch/ppc/defconfig           |    2 +-
 ./arch/ppc64/defconfig         |    2 +-
 ./arch/s390/defconfig          |    2 +-
 ./arch/s390x/defconfig         |    2 +-
 ./arch/sh64/defconfig          |    2 +-
 ./fs/Config.in                 |    2 +-
 11 files changed, 14 insertions(+), 13 deletions(-)

diff ./Documentation/Configure.help~current~ ./Documentation/Configure.help
--- ./Documentation/Configure.help~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./Documentation/Configure.help	2004-07-27 13:57:14.000000000 +1000
@@ -17209,10 +17209,11 @@ CONFIG_NFSD_V3
   If you would like to include the NFSv3 server as well as the NFSv2
   server, say Y here.  If unsure, say Y.
 
-Provide NFS over TCP server support EXPERIMENTAL
+Provide NFS over TCP server support
 CONFIG_NFSD_TCP
-  Enable NFS service over TCP connections.  This the officially
-  still experimental, but seems to work well.
+  If you want your NFS server to support TCP connections, say Y here.
+  TCP connections usually perform better than the default UDP when
+  the network is lossy or congested.  If unsure, say Y.
 
 OS/2 HPFS file system support
 CONFIG_HPFS_FS

diff ./arch/i386/defconfig~current~ ./arch/i386/defconfig
--- ./arch/i386/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/i386/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -741,7 +741,7 @@ CONFIG_NFS_FS=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 # CONFIG_SMB_FS is not set

diff ./arch/ia64/defconfig~current~ ./arch/ia64/defconfig
--- ./arch/ia64/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/ia64/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -755,7 +755,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y

diff ./arch/mips/defconfig~current~ ./arch/mips/defconfig
--- ./arch/mips/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/mips/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -607,7 +607,7 @@ CONFIG_NFS_FS=y
 CONFIG_ROOT_NFS=y
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 # CONFIG_SMB_FS is not set

diff ./arch/mips64/defconfig~current~ ./arch/mips64/defconfig
--- ./arch/mips64/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/mips64/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -563,7 +563,7 @@ CONFIG_NFS_V3=y
 CONFIG_ROOT_NFS=y
 # CONFIG_NFSD is not set
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y

diff ./arch/ppc/defconfig~current~ ./arch/ppc/defconfig
--- ./arch/ppc/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/ppc/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -812,7 +812,7 @@ CONFIG_NFS_FS=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 # CONFIG_SMB_FS is not set

diff ./arch/ppc64/defconfig~current~ ./arch/ppc64/defconfig
--- ./arch/ppc64/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/ppc64/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -668,7 +668,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y

diff ./arch/s390/defconfig~current~ ./arch/s390/defconfig
--- ./arch/s390/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/s390/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -351,7 +351,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y

diff ./arch/s390x/defconfig~current~ ./arch/s390x/defconfig
--- ./arch/s390x/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/s390x/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -291,7 +291,7 @@ CONFIG_NFS_V3=y
 # CONFIG_ROOT_NFS is not set
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y

diff ./arch/sh64/defconfig~current~ ./arch/sh64/defconfig
--- ./arch/sh64/defconfig~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./arch/sh64/defconfig	2004-07-27 13:57:14.000000000 +1000
@@ -386,7 +386,7 @@ CONFIG_NFS_V3=y
 CONFIG_ROOT_NFS=y
 # CONFIG_NFSD is not set
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_SUNRPC=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y

diff ./fs/Config.in~current~ ./fs/Config.in
--- ./fs/Config.in~current~	2004-07-27 13:57:14.000000000 +1000
+++ ./fs/Config.in	2004-07-27 13:57:14.000000000 +1000
@@ -121,7 +121,7 @@ if [ "$CONFIG_NET" = "y" ]; then
 
    dep_tristate 'NFS server support' CONFIG_NFSD $CONFIG_INET
    dep_mbool '  Provide NFSv3 server support' CONFIG_NFSD_V3 $CONFIG_NFSD
-   dep_mbool '  Provide NFS server over TCP support (EXPERIMENTAL)' CONFIG_NFSD_TCP $CONFIG_NFSD $CONFIG_EXPERIMENTAL
+   dep_mbool '  Provide NFS server over TCP support' CONFIG_NFSD_TCP $CONFIG_NFSD
 
    if [ "$CONFIG_NFS_FS" = "y" -o "$CONFIG_NFSD" = "y" ]; then
       define_tristate CONFIG_SUNRPC y


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
