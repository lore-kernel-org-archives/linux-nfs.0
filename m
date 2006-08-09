From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 08/25] LOCKD: Teach lockd to use the new
	rpc_peeraddr() API
Date: Wed, 09 Aug 2006 10:59:09 -0400
Message-ID: <20060809145909.3914.85397.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApWe-0008Ll-Ml
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:16 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApWd-000127-S9
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:17 -0700
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

Hide the details of how the RPC client stores remote peer addresses from
the Network Lock Manager.

Test plan:
Destructive testing (unplugging the network temporarily).  Connectathon
with UDP and TCP.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 89ba0df..50dbb67 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -151,11 +151,13 @@ static void nlmclnt_release_lockargs(str
 int
 nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
 {
+	struct rpc_clnt		*client = NFS_CLIENT(inode);
+	struct sockaddr_in	addr;
 	struct nlm_host		*host;
 	struct nlm_rqst		*call;
 	sigset_t		oldset;
 	unsigned long		flags;
-	int			status, proto, vers;
+	int			status, vers;
 
 	vers = (NFS_PROTO(inode)->version == 3) ? 4 : 1;
 	if (NFS_PROTO(inode)->version > 3) {
@@ -163,10 +165,8 @@ nlmclnt_proc(struct inode *inode, int cm
 		return -ENOLCK;
 	}
 
-	/* Retrieve transport protocol from NFS client */
-	proto = NFS_CLIENT(inode)->cl_xprt->prot;
-
-	host = nlmclnt_lookup_host(NFS_ADDR(inode), proto, vers);
+	rpc_peeraddr(client, (struct sockaddr *) &addr, sizeof(addr));
+	host = nlmclnt_lookup_host(&addr, client->cl_xprt->prot, vers);
 	if (host == NULL)
 		return -ENOLCK;
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
