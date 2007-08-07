From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.23-rc1-mm2
Date: Tue, 07 Aug 2007 17:08:48 -0400
Message-ID: <1186520929.6625.12.camel@heimdal.trondhjem.org>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
	<1186160608.7255.10.camel@localhost> <20070803172137.GA3783@tv-sign.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-DhVLaiptBvrBCxg63kbS"
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Oleg Nesterov <oleg@tv-sign.ru>, Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIWJS-00066v-E7
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:09:58 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18wKYfsl9GXwm7iyp1/xI/hrGtfN0TMgfo=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIWJU-0007YM-Ls
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:10:02 -0700
In-Reply-To: <20070803172137.GA3783@tv-sign.ru>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-DhVLaiptBvrBCxg63kbS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2007-08-03 at 21:21 +0400, Oleg Nesterov wrote:
> On 08/03, Trond Myklebust wrote:
> > I'll have a look at this. I suspect that most if not all of our calls to
> > run_workqueue()/flush_scheduled_work() can now be replaced by more
> > targeted calls to cancel_work_sync() and cancel_delayed_work_sync().
> 
> Yes, please, if possible.

All the NFS and SUNRPC cases appear to be trivial. IOW: the only reason
for the flush_workqueue()/flush_scheduled_work() calls was to ensure
that the cancel_work()/cancel_delayed_work() calls preceding them have
completed. Nevertheless I've split the conversion into two patches,
since one touches only the NFS code, whereas the other touches the
SUNRPC client and server code.

The two patches have been tested, and appear to work...

Trond



--=-DhVLaiptBvrBCxg63kbS
Content-Disposition: inline;
	filename=linux-2.6.23-007-nfs_dont_call_flush_workqueue.dif
Content-Type: message/rfc822;
	name=linux-2.6.23-007-nfs_dont_call_flush_workqueue.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 7 Aug 2007 15:28:33 -0400
NFS: Replace flush_scheduled_work with cancel_work_sync() and friends
Subject: No Subject
Message-Id: <1186520901.6625.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

This will avoid deadlocks of the form:

stack backtrace:
 [<c0104fda>] show_trace_log_lvl+0x1a/0x30
 [<c0105c02>] show_trace+0x12/0x20
 [<c0105d15>] dump_stack+0x15/0x20
 [<c013ee42>] __lock_acquire+0xc22/0x1030
 [<c013f2b1>] lock_acquire+0x61/0x80
 [<c012edd9>] flush_workqueue+0x49/0x70
 [<c012ee0d>] flush_scheduled_work+0xd/0x10
 [<dcf55c0c>] nfs_release_automount_timer+0x2c/0x30 [nfs]
 [<dcf45d8e>] nfs_free_server+0x9e/0xd0 [nfs]
 [<dcf4e626>] nfs_kill_super+0x16/0x20 [nfs]
 [<c017b38d>] deactivate_super+0x7d/0xa0
 [<c018f94b>] mntput_no_expire+0x4b/0x80
 [<c018fd94>] expire_mount_list+0xe4/0x140
 [<c0191219>] mark_mounts_for_expiry+0x99/0xb0
 [<dcf55d1d>] nfs_expire_automounts+0xd/0x40 [nfs]
 [<c012e61b>] run_workqueue+0x12b/0x1e0
 [<c012f05b>] worker_thread+0x9b/0x100
 [<c0131c72>] kthread+0x42/0x70
 [<c0104c0f>] kernel_thread_helper+0x7/0x18
 =======================

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/namespace.c  |    6 ++----
 fs/nfs/nfs4renewd.c |    5 ++---
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 7f86e65..aea76d0 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -175,10 +175,8 @@ static void nfs_expire_automounts(struct work_struct *work)
 
 void nfs_release_automount_timer(void)
 {
-	if (list_empty(&nfs_automount_list)) {
-		cancel_delayed_work(&nfs_automount_task);
-		flush_scheduled_work();
-	}
+	if (list_empty(&nfs_automount_list))
+		cancel_delayed_work_sync(&nfs_automount_task);
 }
 
 /*
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 0505ca1..3ea352d 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -127,16 +127,15 @@ nfs4_schedule_state_renewal(struct nfs_client *clp)
 void
 nfs4_renewd_prepare_shutdown(struct nfs_server *server)
 {
-	flush_scheduled_work();
+	cancel_delayed_work(&server->nfs_client->cl_renewd);
 }
 
 void
 nfs4_kill_renewd(struct nfs_client *clp)
 {
 	down_read(&clp->cl_sem);
-	cancel_delayed_work(&clp->cl_renewd);
+	cancel_delayed_work_sync(&clp->cl_renewd);
 	up_read(&clp->cl_sem);
-	flush_scheduled_work();
 }
 
 /*

--=-DhVLaiptBvrBCxg63kbS
Content-Disposition: inline;
	filename=linux-2.6.23-008-sunrpc_dont_call_flush_workqueue.dif
Content-Type: message/rfc822;
	name=linux-2.6.23-008-sunrpc_dont_call_flush_workqueue.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 7 Aug 2007 15:33:01 -0400
SUNRPC: Replace flush_workqueue() with cancel_work_sync() and friends
Subject: No Subject
Message-Id: <1186520901.6625.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/cache.c    |    3 +--
 net/sunrpc/rpc_pipe.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 01c3c41..ebe344f 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -371,8 +371,7 @@ int cache_unregister(struct cache_detail *cd)
 	}
 	if (list_empty(&cache_list)) {
 		/* module must be being unloaded so its safe to kill the worker */
-		cancel_delayed_work(&cache_cleaner);
-		flush_scheduled_work();
+		cancel_delayed_work_sync(&cache_cleaner);
 	}
 	return 0;
 }
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 650af06..669e12a 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -132,8 +132,7 @@ rpc_close_pipes(struct inode *inode)
 		rpci->nwriters = 0;
 		if (ops->release_pipe)
 			ops->release_pipe(inode);
-		cancel_delayed_work(&rpci->queue_timeout);
-		flush_workqueue(rpciod_workqueue);
+		cancel_delayed_work_sync(&rpci->queue_timeout);
 	}
 	rpc_inode_setowner(inode, NULL);
 	mutex_unlock(&inode->i_mutex);

--=-DhVLaiptBvrBCxg63kbS
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--=-DhVLaiptBvrBCxg63kbS
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-DhVLaiptBvrBCxg63kbS--
