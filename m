From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH supplemental 15/19] Add RDMA dependency to
 SUNRPC_XPRT_RDMA
Date: Thu, 20 Sep 2007 17:37:58 -0400
Message-ID: <EXNANE01OSQeSOzNCWb00000575@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYTjZ-0004FH-Mh
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:38:54 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IYTje-0003Wq-EF
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:38:58 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8KLcqDC008262
	for <nfs@lists.sourceforge.net>; Thu, 20 Sep 2007 14:38:52 -0700 (PDT)
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

RPCRDMA: Kconfig RDMA dependency

Add a dependency on RDMA before enabling SUNRPC_XPRT_RDMA
Yes, "INFINIBAND" also turns on iWARP and other RDMA support.

Signed-off-by: Tom Talpey <talpey@netapp.com>

---

 fs/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: kernel/fs/Kconfig
===================================================================
--- kernel.orig/fs/Kconfig
+++ kernel/fs/Kconfig
@@ -1733,7 +1733,7 @@ config SUNRPC_GSS
 
 config SUNRPC_XPRT_RDMA
 	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
+	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
 	default m
 	help
 	  Adds a client RPC transport for supporting kernel NFS over RDMA

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
