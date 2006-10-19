From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/11] SUNRPC: fix race in in-kernel RPC portmapper
	client
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.96764.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GabLa-0001Rl-A5
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 10:06:22 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GabLa-0003uw-53
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 10:06:23 -0700
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
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

From: Chuck Lever <chuck.lever@oracle.com>

When submitting a request to a fast portmapper (such as the local rpcbind
daemon), the request can complete before the parent task is even queued up
on xprt->binding.  Fix this by queuing before submitting the rpcbind
request.

Test plan:
Connectathon locking test with UDP.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/pmap_clnt.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index 919d5ba..e52afab 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -101,11 +101,13 @@ void rpc_getport(struct rpc_task *task)
 	/* Autobind on cloned rpc clients is discouraged */
 	BUG_ON(clnt->cl_parent != clnt);
 
-	if (xprt_test_and_set_binding(xprt)) {
-		task->tk_status = -EACCES;	/* tell caller to check again */
-		rpc_sleep_on(&xprt->binding, task, NULL, NULL);
-		return;
-	}
+	/* Put self on queue before sending rpcbind request, in case
+	 * pmap_getport_done completes before we return from rpc_run_task */
+	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
+
+	status = -EACCES;		/* tell caller to check again */
+	if (xprt_test_and_set_binding(xprt))
+		goto bailout_nofree;
 
 	/* Someone else may have bound if we slept */
 	status = 0;
@@ -134,8 +136,6 @@ void rpc_getport(struct rpc_task *task)
 		goto bailout;
 	rpc_release_task(child);
 
-	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
-
 	task->tk_xprt->stat.bind_count++;
 	return;
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
