From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/3] NFS: Fix Oops in rpc_call_sync()
Date: Wed, 24 Jan 2007 11:54:53 -0800
Message-ID: <20070124195453.21259.74390.stgit@lade.trondhjem.org>
References: <20070124195307.21259.64156.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sds@tycho.nsa.gov, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9oD0-0004gK-58
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:55:02 -0800
Received: from dsl081-065-125.sfo1.dsl.speakeasy.net ([64.81.65.125]
	helo=lade.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9oD1-0002YU-GG
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:55:03 -0800
In-Reply-To: <20070124195307.21259.64156.stgit@lade.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Fix the Oops in http://bugzilla.linux-nfs.org/show_bug.cgi?id=138
We shouldn't be calling rpc_release_task() for tasks that are not active.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |    1 -
 net/sunrpc/clnt.c            |    8 +++-----
 net/sunrpc/sched.c           |    3 ++-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 97c7616..8b6ce60 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -250,7 +250,6 @@ void		rpc_init_task(struct rpc_task *tas
 				int flags, const struct rpc_call_ops *ops,
 				void *data);
 void		rpc_put_task(struct rpc_task *);
-void		rpc_release_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
 void		rpc_killall_tasks(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index aba528b..16c9fbc 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -490,16 +490,14 @@ int rpc_call_sync(struct rpc_clnt *clnt,
 
 	/* Set up the call info struct and execute the task */
 	status = task->tk_status;
-	if (status != 0) {
-		rpc_release_task(task);
+	if (status != 0)
 		goto out;
-	}
 	atomic_inc(&task->tk_count);
 	status = rpc_execute(task);
 	if (status == 0)
 		status = task->tk_status;
-	rpc_put_task(task);
 out:
+	rpc_put_task(task);
 	rpc_restore_sigmask(&oldset);
 	return status;
 }
@@ -537,7 +535,7 @@ rpc_call_async(struct rpc_clnt *clnt, st
 	if (status == 0)
 		rpc_execute(task);
 	else
-		rpc_release_task(task);
+		rpc_put_task(task);
 
 	rpc_restore_sigmask(&oldset);		
 	return status;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 79bc4cd..fc083f0 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -42,6 +42,7 @@ static mempool_t	*rpc_buffer_mempool __r
 static void			__rpc_default_timer(struct rpc_task *task);
 static void			rpciod_killall(void);
 static void			rpc_async_schedule(struct work_struct *);
+static void			 rpc_release_task(struct rpc_task *task);
 
 /*
  * RPC tasks sit here while waiting for conditions to improve.
@@ -896,7 +897,7 @@ void rpc_put_task(struct rpc_task *task)
 }
 EXPORT_SYMBOL(rpc_put_task);
 
-void rpc_release_task(struct rpc_task *task)
+static void rpc_release_task(struct rpc_task *task)
 {
 #ifdef RPC_DEBUG
 	BUG_ON(task->tk_magic != RPC_TASK_MAGIC_ID);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
