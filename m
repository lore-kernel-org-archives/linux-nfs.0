From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS hang
Date: Mon, 27 Nov 2006 14:58:07 -0500
Message-ID: <1164657487.5727.12.camel@lade.trondhjem.org>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-qA5FVn1N7gLGr6Trs3Wd"
Cc: Frank Filz <ffilz@us.ibm.com>, nfs@lists.sourceforge.net,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gomcn-00088R-4I
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 11:58:45 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18qi0F2Jl07VmiqSqc/WmJeqAP/aO5IvFo=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gomcl-0000Ny-QD
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 11:58:46 -0800
To: Chris Caputo <ccaputo@alt.net>
In-Reply-To: <Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
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


--=-qA5FVn1N7gLGr6Trs3Wd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2006-11-27 at 19:33 +0000, Chris Caputo wrote:
> On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > On Mon, 2006-11-27 at 19:09 +0000, Chris Caputo wrote:
> > > -		if (!RPC_IS_QUEUED(task))
> > > -			continue;
> > > -		rpc_clear_running(task);
> > > +		queue = task->u.tk_wait.rpc_waitq;
> > 
> > NACK... There is no guarantee that task->u.tk_wait has any meaning here.
> > Particularly not so in the case of an asynchronous task, where the
> > storage is shared with the work_struct.
> 
> Yikes.  Would you suggest I move the lock outside of the union and try 
> again?

No. There is no way this can work. You would need something that
guarantees that the task stays queued while you are taking the queue
lock.

Have you instead tried Christophe Saout's patch (see attachment)?

Cheers
  Trond


--=-qA5FVn1N7gLGr6Trs3Wd
Content-Disposition: inline; filename=linux-2.6.19-001-fix_rpc_wakeup_race.dif
Content-Type: message/rfc822; name=linux-2.6.19-001-fix_rpc_wakeup_race.dif

From: Christophe Saout <christophe@saout.de>
Date: Sun, 05 Nov 2006 18:42:48 +0100
Subject: Re: [PATCH] Fix SUNRPC wakeup/execute race condition
Message-Id: <1164657487.5727.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

The sunrpc scheduler contains a race condition that can let an RPC
task end up being neither running nor on any wait queue. The race takes
place between rpc_make_runnable (called from rpc_wake_up_task) and
__rpc_execute under the following condition:

First __rpc_execute calls tk_action which puts the task on some wait
queue. The task is dequeued by another process before __rpc_execute
continues its execution. While executing rpc_make_runnable exactly after
setting the task `running' bit and before clearing the `queued' bit
__rpc_execute picks up execution, clears `running' and subsequently
both functions fall through, both under the false assumption somebody
else took the job.

Swapping rpc_test_and_set_running with rpc_clear_queued in
rpc_make_runnable fixes that hole. This introduces another possible
race condition that can be handled by checking for `queued' after
setting the `running' bit.

Bug noticed on a 4-way x86_64 system under XEN with an NFSv4 server
on the same physical machine, apparently one of the few ways to hit
this race condition at all.

Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Christophe Saout <christophe@saout.de>
Signed-off-by: Trond Myklebust <trond.myklebust@fys.uio.no>
---

 net/sunrpc/sched.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index a1ab4ee..b57d406 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -295,13 +295,15 @@ EXPORT_SYMBOL(__rpc_wait_for_completion_
  */
 static void rpc_make_runnable(struct rpc_task *task)
 {
-	int do_ret;
-
 	BUG_ON(task->tk_timeout_fn);
-	do_ret = rpc_test_and_set_running(task);
 	rpc_clear_queued(task);
-	if (do_ret)
+	if (rpc_test_and_set_running(task))
+		return;
+	/* We might have raced */
+	if (RPC_IS_QUEUED(task)) {
+		rpc_clear_running(task);
 		return;
+	}
 	if (RPC_IS_ASYNC(task)) {
 		int status;
 

--=-qA5FVn1N7gLGr6Trs3Wd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-qA5FVn1N7gLGr6Trs3Wd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-qA5FVn1N7gLGr6Trs3Wd--
