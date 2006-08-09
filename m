From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 15/25] SUNRPC: Clean-up after previous patches.
Date: Wed, 09 Aug 2006 10:59:26 -0400
Message-ID: <20060809145926.3914.94390.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcU-0000p1-RA
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcT-0003GL-Gv
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:19 -0700
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

Remove some unused macros related to accessing an RPC peer address

Test plan:
Compile kernel with CONFIG_NFS option enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    1 -
 include/linux/nfs_fs.h      |    1 -
 include/linux/sunrpc/clnt.h |    3 ---
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 38b0e8a..a516a01 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -26,7 +26,6 @@ #define NLM_ADDRHASH(addr)	(ntohl(addr) 
 #define NLM_HOST_REBIND		(60 * HZ)
 #define NLM_HOST_EXPIRE		((nrhosts > NLM_HOST_MAX)? 300 * HZ : 120 * HZ)
 #define NLM_HOST_COLLECT	((nrhosts > NLM_HOST_MAX)? 120 * HZ :  60 * HZ)
-#define NLM_HOST_ADDR(sv)	(&(sv)->s_nlmclnt->cl_xprt->addr)
 
 static struct nlm_host *	nlm_hosts[NLM_HOST_NRHASH];
 static unsigned long		next_gc;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2474345..dd61af2 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -210,7 +210,6 @@ #define NFS_FH(inode)			(&NFS_I(inode)->
 #define NFS_SERVER(inode)		(NFS_SB(inode->i_sb))
 #define NFS_CLIENT(inode)		(NFS_SERVER(inode)->client)
 #define NFS_PROTO(inode)		(NFS_SERVER(inode)->rpc_ops)
-#define NFS_ADDR(inode)			(RPC_PEERADDR(NFS_CLIENT(inode)))
 #define NFS_COOKIEVERF(inode)		(NFS_I(inode)->cookieverf)
 #define NFS_READTIME(inode)		(NFS_I(inode)->read_cache_jiffies)
 #define NFS_CHANGE_ATTR(inode)		(NFS_I(inode)->change_attr)
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b7d47f0..a26d695 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -89,9 +89,6 @@ struct rpc_procinfo {
 	char *			p_name;		/* name of procedure */
 };
 
-#define RPC_CONGESTED(clnt)	(RPCXPRT_CONGESTED((clnt)->cl_xprt))
-#define RPC_PEERADDR(clnt)	(&(clnt)->cl_xprt->addr)
-
 #ifdef __KERNEL__
 
 struct rpc_clnt *rpc_create_client(struct rpc_xprt *xprt, char *servname,

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
