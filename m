From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 10/10] rdma: Kconfig
Date: Mon, 20 Aug 2007 11:58:22 -0500
Message-ID: <20070820165822.15938.22161.stgit@dell3.ogc.int>
References: <20070820165635.15938.57184.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INAa8-000214-4B
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:24 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INAaC-0003OK-7w
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:28 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 634A37C79B
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:58:22 -0500 (CDT)
In-Reply-To: <20070820165635.15938.57184.stgit@dell3.ogc.int>
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
index 0fa0c11..c556eb3 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1652,6 +1652,13 @@ config NFSD
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
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
