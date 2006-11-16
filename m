From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/21] SUNRPC: another pmap wakeup fix
Date: Thu, 16 Nov 2006 15:03:38 -0500
Message-ID: <20061116200338.32549.58508.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko0l-0006mo-R5
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:03 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko0h-0000IQ-Kx
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:02 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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

Don't wake up bind waiters if a task finds that another task is already
trying to bind.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/pmap_clnt.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index e52afab..090a891 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -101,14 +101,14 @@ void rpc_getport(struct rpc_task *task)
 	/* Autobind on cloned rpc clients is discouraged */
 	BUG_ON(clnt->cl_parent != clnt);
 
+	status = -EACCES;		/* tell caller to check again */
+	if (xprt_test_and_set_binding(xprt))
+		goto bailout_nowake;
+
 	/* Put self on queue before sending rpcbind request, in case
 	 * pmap_getport_done completes before we return from rpc_run_task */
 	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
 
-	status = -EACCES;		/* tell caller to check again */
-	if (xprt_test_and_set_binding(xprt))
-		goto bailout_nofree;
-
 	/* Someone else may have bound if we slept */
 	status = 0;
 	if (xprt_bound(xprt))
@@ -143,8 +143,9 @@ bailout:
 	pmap_map_free(map);
 	xprt_put(xprt);
 bailout_nofree:
-	task->tk_status = status;
 	pmap_wake_portmap_waiters(xprt, status);
+bailout_nowake:
+	task->tk_status = status;
 }
 
 #ifdef CONFIG_ROOT_NFS

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
