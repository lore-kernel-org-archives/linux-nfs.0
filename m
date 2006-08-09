From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 01/25] SUNRPC: avoid choosing an IPMI port for RPC
	traffic
Date: Wed, 09 Aug 2006 10:58:51 -0400
Message-ID: <20060809145849.3914.57196.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApWQ-0008Gk-D4
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:02 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApWP-0003Qc-Nw
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:03 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Some hardware uses port 664 for its hardware-based IPMI listener.  Teach
the RPC client to avoid using that port by raising the default minimum port
number to 665.

Test plan:
Find a mainboard known to use port 664 for IPMI; enable IPMI; mount NFS
servers in a tight loop.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 840e47a..3a0cca2 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -37,7 +37,7 @@ extern unsigned int xprt_max_resvport;
 
 #define RPC_MIN_RESVPORT	(1U)
 #define RPC_MAX_RESVPORT	(65535U)
-#define RPC_DEF_MIN_RESVPORT	(650U)
+#define RPC_DEF_MIN_RESVPORT	(665U)
 #define RPC_DEF_MAX_RESVPORT	(1023U)
 
 /*

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
