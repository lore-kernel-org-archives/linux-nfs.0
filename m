From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] Include FS_POSIX_ACL if nfs server needs it.
Date: Fri, 11 Feb 2005 14:10:46 +1100
Message-ID: <E1CzRCg-0005F2-Ly@notabene.cse.unsw.edu.au>
References: <20050211140917.20133.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CzRCo-0000oR-5q
	for nfs@lists.sourceforge.net; Thu, 10 Feb 2005 19:10:54 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CzRCm-0008Sb-M4
	for nfs@lists.sourceforge.net; Thu, 10 Feb 2005 19:10:54 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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

The ACL extension to NFS recently added to -mm needs the following to
compile correctly (if e.g. you have selected the V4 server, but no ACL support
in filesystems)

NeilBrown


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/Kconfig~current~ ./fs/Kconfig
--- ./fs/Kconfig~current~	2005-02-11 14:01:18.000000000 +1100
+++ ./fs/Kconfig	2005-02-11 14:03:04.000000000 +1100
@@ -1499,6 +1499,7 @@ config NFSD_V3
 config NFSD_ACL
 	bool "NFS_ACL protocol extension"
 	depends on NFSD_V3
+	select FS_POSIX_ACL
 	help
 	  Implement the NFS_ACL protocol extension for manipulating POSIX
 	  Access Control Lists on exported file systems.  The clients must
@@ -1512,6 +1513,7 @@ config NFSD_V4
 	bool "Provide NFSv4 server support (EXPERIMENTAL)"
 	depends on NFSD_V3 && EXPERIMENTAL
 	select NFSD_TCP
+	select FS_POSIX_ACL
 	help
 	  If you would like to include the NFSv4 server as well as the NFSv2
 	  and NFSv3 servers, say Y here.  This feature is experimental, and


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
