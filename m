From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 9] Mark NFS/TCP server not EXPERIMENTAL
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Lb-LX@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8i-00023b-2Y
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:08 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8h-0007DC-Do
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:07 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Greg Banks <gnb@sgi.com>

NFS/TCP has been used widely for a long time now, and is now  
enabled by many distros and typically recommended for lossy or
congested networks.  This patch removes the EXPERIMENTAL tag,
updates the help text, and changes arch defconfigs to set it
by default (note that several already did so).


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./arch/alpha/defconfig |    2 +-
 ./arch/i386/defconfig  |    2 +-
 ./arch/ia64/defconfig  |    2 +-
 ./arch/ppc/defconfig   |    2 +-
 ./arch/s390/defconfig  |    2 +-
 ./fs/Kconfig           |   10 ++++++----
 6 files changed, 11 insertions(+), 9 deletions(-)

diff ./arch/alpha/defconfig~current~ ./arch/alpha/defconfig
--- ./arch/alpha/defconfig~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./arch/alpha/defconfig	2004-06-23 14:37:17.000000000 +1000
@@ -791,7 +791,7 @@ CONFIG_NFS_V3=y
 CONFIG_NFSD=m
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=m
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=m

diff ./arch/i386/defconfig~current~ ./arch/i386/defconfig
--- ./arch/i386/defconfig~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./arch/i386/defconfig	2004-06-23 14:37:17.000000000 +1000
@@ -1148,7 +1148,7 @@ CONFIG_NFS_FS=y
 # CONFIG_NFS_DIRECTIO is not set
 CONFIG_NFSD=y
 # CONFIG_NFSD_V3 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_EXPORTFS=y
 CONFIG_SUNRPC=y

diff ./arch/ia64/defconfig~current~ ./arch/ia64/defconfig
--- ./arch/ia64/defconfig~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./arch/ia64/defconfig	2004-06-23 14:37:17.000000000 +1000
@@ -999,7 +999,7 @@ CONFIG_NFS_DIRECTIO=y
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y

diff ./arch/ppc/defconfig~current~ ./arch/ppc/defconfig
--- ./arch/ppc/defconfig~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./arch/ppc/defconfig	2004-06-23 14:37:17.000000000 +1000
@@ -1230,7 +1230,7 @@ CONFIG_NFS_V3=y
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y

diff ./arch/s390/defconfig~current~ ./arch/s390/defconfig
--- ./arch/s390/defconfig~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./arch/s390/defconfig	2004-06-23 14:37:17.000000000 +1000
@@ -422,7 +422,7 @@ CONFIG_NFS_V3=y
 CONFIG_NFSD=y
 CONFIG_NFSD_V3=y
 # CONFIG_NFSD_V4 is not set
-# CONFIG_NFSD_TCP is not set
+CONFIG_NFSD_TCP=y
 CONFIG_LOCKD=y
 CONFIG_LOCKD_V4=y
 CONFIG_EXPORTFS=y

diff ./fs/Kconfig~current~ ./fs/Kconfig
--- ./fs/Kconfig~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./fs/Kconfig	2004-06-23 14:37:17.000000000 +1000
@@ -1469,11 +1469,13 @@ config NFSD_V4
 	  If unsure, say N.
 
 config NFSD_TCP
-	bool "Provide NFS server over TCP support (EXPERIMENTAL)"
-	depends on NFSD && EXPERIMENTAL
+	bool "Provide NFS server over TCP support"
+	depends on NFSD
+	default y
 	help
-	  Enable NFS service over TCP connections.  This the officially
-	  still experimental, but seems to work well.
+	  If you want your NFS server to support TCP connections, say Y here.
+	  TCP connections usually perform better than the default UDP when
+	  the network is lossy or congested.  If unsure, say Y.
 
 config ROOT_NFS
 	bool "Root file system on NFS"


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
