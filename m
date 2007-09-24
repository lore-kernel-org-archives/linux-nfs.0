From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH][RFC] use after free in NLM subsystem -- how best to
	fix it?
Date: Mon, 24 Sep 2007 16:12:36 -0400
Message-ID: <20070924161236.48779845.jlayton@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZuIM-00052D-57
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 13:12:42 -0700
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZuIQ-0004Mu-GW
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 13:12:47 -0700
Received: from mail.poochiereds.net ([71.70.159.32])
	by cdptpa-omta06.mail.rr.com with ESMTP id
	<20070924201237.HYBB3972.cdptpa-omta06.mail.rr.com@mail.poochiereds.net>
	for <nfs@lists.sourceforge.net>; Mon, 24 Sep 2007 20:12:37 +0000
Received: from tleilax.poochiereds.net (tleilax.poochiereds.net [192.168.1.3])
	by mail.poochiereds.net (Postfix) with SMTP id D1D305808D
	for <nfs@lists.sourceforge.net>; Mon, 24 Sep 2007 16:12:36 -0400 (EDT)
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

I've noticed a problem with the way we're doing grant callbacks. I've
seen at least one oops from it in the field. I can also reproduce it
pretty much at will on older kernels with slab poisoning enabled. On
newer kernels (2.6.23-rc-ish), I've gotten it to reproduce once on a
kernel with SLUB poisoning, but can't quite do it at will.

The problem is that I'm not sure of the best way to fix it. Hopefully
someone can give me an idea...

When a lock that a client is blocking on comes free, lockd does this in
nlmsvc_grant_blocked():

    nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG, &nlmsvc_grant_ops);

the callback from this call is nlmsvc_grant_callback(). That function
does this at the end to wake up lockd:

    svc_wake_up(block->b_daemon);

...the problem is, that there is no guarantee that lockd will be up
when this happens. If someone shuts down or restarts lockd before the
async call completes, then the b_daemon pointer will point to freed
memory.

The best I've been able to come up with is to replace the svc_wake_up
calls with a call to a function that wakes up whatever lockd happens
to be up at the time (if any). My thinking is that we don't really
care too much about waking up the lockd thread that happened to spawn
the block. Rather, we're just interested in making sure that an active
lockd wakes up.

Rough, untested patch follows as an RFC. A similar patch fixes the
easily reproducible panics on older kernels.

Details on that patch and how to reproduce this are in this RHBZ:

https://bugzilla.redhat.com/show_bug.cgi?id=253754

Thoughts?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 82e2192..a3791cc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -50,6 +50,7 @@ static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
 static pid_t			nlmsvc_pid;
 static struct svc_serv		*nlmsvc_serv;
+static DEFINE_RWLOCK(nlmsvc_serv_lock);
 int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
 
@@ -129,7 +130,9 @@ lockd(struct svc_rqst *rqstp)
 	 * Let our maker know we're running.
 	 */
 	nlmsvc_pid = current->pid;
+	write_lock(&nlmsvc_serv_lock);
 	nlmsvc_serv = rqstp->rq_server;
+	write_unlock(&nlmsvc_serv_lock);
 	complete(&lockd_start_done);
 
 	daemonize("lockd");
@@ -205,7 +208,9 @@ lockd(struct svc_rqst *rqstp)
 			nlmsvc_invalidate_all();
 		nlm_shutdown_hosts();
 		nlmsvc_pid = 0;
+		write_lock(&nlmsvc_serv_lock);
 		nlmsvc_serv = NULL;
+		write_unlock(&nlmsvc_serv_lock);
 	} else
 		printk(KERN_DEBUG
 			"lockd: new process, skipping host shutdown\n");
@@ -273,11 +278,14 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (nlmsvc_pid) {
+	read_lock(&nlmsvc_serv_lock);
+	if (nlmsvc_serv) {
 		if (proto)
 			error = make_socks(nlmsvc_serv, proto);
+		read_unlock(&nlmsvc_serv_lock);
 		goto out;
 	}
+	read_unlock(&nlmsvc_serv_lock);
 
 	/*
 	 * Sanity check: if there's no pid,
@@ -355,6 +363,9 @@ lockd_down(void)
 		printk(KERN_WARNING 
 			"lockd_down: lockd failed to exit, clearing pid\n");
 		nlmsvc_pid = 0;
+		write_lock(&nlmsvc_serv_lock);
+		nlmsvc_serv = NULL;
+		write_unlock(&nlmsvc_serv_lock);
 	}
 	spin_lock_irq(&current->sighand->siglock);
 	recalc_sigpending();
@@ -364,6 +375,16 @@ out:
 }
 EXPORT_SYMBOL(lockd_down);
 
+/* wake up current lockd thread */
+void
+lockd_wake_up(void)
+{
+	read_lock(&nlmsvc_serv_lock);
+	if (nlmsvc_serv)
+		svc_wake_up(nlmsvc_serv);
+	read_unlock(&nlmsvc_serv_lock);
+}
+
 /*
  * Sysctl parameters (same as module parameters, different interface).
  */
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index a21e4bc..1dc16b8 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -644,7 +644,7 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
 				block->b_granted = 1;
 
 			nlmsvc_insert_block(block, 0);
-			svc_wake_up(block->b_daemon);
+			lockd_wake_up();
 			rc = 0;
 			break;
 		}
@@ -671,7 +671,7 @@ nlmsvc_notify_blocked(struct file_lock *fl)
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
 			nlmsvc_insert_block(block, 0);
-			svc_wake_up(block->b_daemon);
+			lockd_wake_up();
 			return;
 		}
 	}
@@ -784,7 +784,7 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
 		timeout = 60 * HZ;
 	}
 	nlmsvc_insert_block(block, timeout);
-	svc_wake_up(block->b_daemon);
+	lockd_wake_up();
 }
 
 static void nlmsvc_grant_release(void *data)
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 6f1637c..29642e3 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -38,6 +38,7 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
 extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
+extern void	lockd_wake_up(void);
 
 unsigned long get_nfs_grace_period(void);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
