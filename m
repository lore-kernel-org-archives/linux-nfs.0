From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 10/10] rdma: Kconfig
Date: Fri, 19 Oct 2007 16:56:30 -0500
Message-ID: <20071019215630.31937.8096.stgit@dell3.ogc.int>
References: <20071019215304.31937.28876.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IizpZ-0006vO-KJ
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:56:33 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iizpd-00038w-UO
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:56:39 -0700
In-Reply-To: <20071019215304.31937.28876.stgit@dell3.ogc.int>
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

 fs/Kconfig |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index f9eed6d..b5d67f4 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1649,6 +1649,13 @@ config NFSD
 	  To compile the NFS server support as a module, choose M here: the
 	  module will be called nfsd.  If unsure, say N.
 
+config NFSD_RDMA
+	tristate "Provide NFS server over RDMA support (EXPERIMENTAL)"
+	depends on SUNRPC && NFSD && INFINIBAND && EXPERIMENTAL
+	help
+	  If you want your NFS server to support RDMA connections, 
+	  say M or Y here. If unsure, say N.
+
 config NFSD_V2_ACL
 	bool
 	depends on NFSD

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
