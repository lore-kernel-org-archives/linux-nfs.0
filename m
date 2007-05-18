From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 01/15] knfsd: add NFSD_RDMA as an option to kconfig
Date: Fri, 18 May 2007 12:44:39 -0500
Message-ID: <1179510279.23385.114.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp6VR-0000lG-M5
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:44:46 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp6VU-0006VJ-Bz
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:44:48 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Add NFS_RDMA as an option to the Kconfig file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/Kconfig |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index eab0932..21b1a1c 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1664,6 +1664,14 @@ config NFSD
 	  To compile the NFS server support as a module, choose M here: the
 	  module will be called nfsd.  If unsure, say N.
 
+config NFSD_RDMA
+	bool "Provide NFS server over RDMA support (EXPERIMENTAL)"
+	depends on NFSD && INFINIBAND && EXPERIMENTAL
+	default n
+	help
+	  If you want your NFS server to support RDMA connections, say Y here
+	  If unsure, say N.
+
 config NFSD_V2_ACL
 	bool
 	depends on NFSD


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
