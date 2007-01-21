From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] SUNRPC: Invalid BUG_ON() popping in
	rpc_release_task()
Date: Sun, 21 Jan 2007 12:25:33 -0500
Message-ID: <1169400333.5764.2.camel@lade.trondhjem.org>
References: <45B35421.1010908@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-o/ws5PS95QO0doYiTtDa"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H8gRo-0003bH-7i
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 09:25:40 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H8gRo-0005AX-MC
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 09:25:41 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <45B35421.1010908@RedHat.com>
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


--=-o/ws5PS95QO0doYiTtDa
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2007-01-21 at 06:53 -0500, Steve Dickson wrote:
> Over the weekend, while doing some Secure NFS testing, I found
> that the BUG_ON() in  rpc_release_task() would pop when
> the Kerberos server was not set up correctly (which I know is a
> very common problem when people start using this feature).
> 
> The code path looks like:
> rpc_call_sync() calls rpc_call_setup() which calls rpcauth_bindcred()
> which fails (due to a krb5 problem) and sets tk_status to -EACCES.
> 
> Back in rpc_call_sync(), since (tk_status != 0) rpc_release_task()
> is called. Unfortunately, since this task was never active,
> (meaning rpc_execute() and rpc_set_active() were never called)
> the tk_magic id was never set and the global task list was
> never set up. So when rpc_release_task() is call, the world
> come tumbling down...
> 
> So the attached patch ensures the RPC_TASK_ACTIVE run state bit
> is set before calling the BUG_ON() and cleaning up the task
> list.
> 
> 
> steved.

I've already posted the attach patch to fix this issue.

Cheers,
  Trond


--=-o/ws5PS95QO0doYiTtDa
Content-Disposition: inline; filename=linux-2.6.20-001-fix_rpc_call_sync.dif
Content-Type: message/rfc822; name=linux-2.6.20-001-fix_rpc_call_sync.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 16 Jan 2007 07:23:06 -0500
NFS: Fix Oops in rpc_call_sync()
Subject: No Subject
Message-Id: <1169400333.5764.3.camel@lade.trondhjem.org>
Mime-Version: 1.0

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

--=-o/ws5PS95QO0doYiTtDa
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-o/ws5PS95QO0doYiTtDa
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-o/ws5PS95QO0doYiTtDa--
