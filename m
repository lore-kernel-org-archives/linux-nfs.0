From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/21] NLM: fix print format for tk_pid
Date: Thu, 16 Nov 2006 15:04:51 -0500
Message-ID: <20061116200451.32549.22319.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1m-0006xN-MD
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:06 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1n-0000cd-BX
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:08 -0800
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

The tk_pid field is an unsigned short.  The proper print format specifier for
that type is %5u, not %4d.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c |    2 +-
 fs/lockd/svc4proc.c |    2 +-
 fs/lockd/svcproc.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 3d84f60..b8e062f 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -729,7 +729,7 @@ static void nlmclnt_cancel_callback(stru
 		goto retry_cancel;
 	}
 
-	dprintk("lockd: cancel status %d (task %d)\n",
+	dprintk("lockd: cancel status %u (task %5u)\n",
 			req->a_res.status, task->tk_pid);
 
 	switch (req->a_res.status) {
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 0ce5c81..f67146a 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -234,7 +234,7 @@ nlm4svc_proc_granted(struct svc_rqst *rq
  */
 static void nlm4svc_callback_exit(struct rpc_task *task, void *data)
 {
-	dprintk("lockd: %4d callback returned %d\n", task->tk_pid,
+	dprintk("lockd: %5u callback returned %d\n", task->tk_pid,
 			-task->tk_status);
 }
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 32e99a6..3707c3a 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -263,7 +263,7 @@ nlmsvc_proc_granted(struct svc_rqst *rqs
  */
 static void nlmsvc_callback_exit(struct rpc_task *task, void *data)
 {
-	dprintk("lockd: %4d callback returned %d\n", task->tk_pid,
+	dprintk("lockd: %5u callback returned %d\n", task->tk_pid,
 			-task->tk_status);
 }
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
