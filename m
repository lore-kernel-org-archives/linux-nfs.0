From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 10/25] SUNRPC: remove extraneous header inclusions
Date: Wed, 09 Aug 2006 10:59:14 -0400
Message-ID: <20060809145914.3914.1626.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcS-0000oi-Gs
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcS-0005lP-7U
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:17 -0700
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

include/linux/sunrpc/clnt.h already includes include/linux/sunrpc/xprt.h.
We can remove xprt.h from source files that already include clnt.h.
Likewise include/linux/sunrpc/timer.h.

Test plan:
Compile kernel with CONFIG_NFS enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c     |    1 -
 include/linux/nfs_xdr.h |    1 -
 net/sunrpc/pmap_clnt.c  |    1 -
 net/sunrpc/sched.c      |    1 -
 net/sunrpc/timer.c      |    2 --
 5 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 445abb4..4127487 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -14,7 +14,6 @@ #include <linux/uio.h>
 #include <linux/net.h>
 #include <linux/in.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs_fs.h>
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2d3fb64..0c1093c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1,7 +1,6 @@
 #ifndef _LINUX_NFS_XDR_H
 #define _LINUX_NFS_XDR_H
 
-#include <linux/sunrpc/xprt.h>
 #include <linux/nfsacl.h>
 
 /*
diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index ff0b92c..689333f 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -15,7 +15,6 @@ #include <linux/errno.h>
 #include <linux/uio.h>
 #include <linux/in.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/sched.h>
 
 #ifdef RPC_DEBUG
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 015ffe4..ecf3663 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -21,7 +21,6 @@ #include <linux/spinlock.h>
 #include <linux/mutex.h>
 
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/xprt.h>
 
 #ifdef RPC_DEBUG
 #define RPCDBG_FACILITY		RPCDBG_SCHED
diff --git a/net/sunrpc/timer.c b/net/sunrpc/timer.c
index bcbdf64..8142fdb 100644
--- a/net/sunrpc/timer.c
+++ b/net/sunrpc/timer.c
@@ -19,8 +19,6 @@ #include <linux/types.h>
 #include <linux/unistd.h>
 
 #include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/xprt.h>
-#include <linux/sunrpc/timer.h>
 
 #define RPC_RTO_MAX (60*HZ)
 #define RPC_RTO_INIT (HZ/5)

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
