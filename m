Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39372 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455Ab1KGEHM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Nov 2011 23:07:12 -0500
Date: Mon, 7 Nov 2011 15:06:54 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: wake up SOFTCONN tasks when a connection error
 happens.
Message-ID: <20111107150654.1c045aad@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Eys2hmBm2NrLNqDu7gHbPgq"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Eys2hmBm2NrLNqDu7gHbPgq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


hi all,
 It being over a year since I last raised this I thought it might be time to
 try again.

 The problem is that an NFSv4 mount request (the default) to an unrouteable
 server results in a 3 minute timeout instead of an instant failure.

 This is easy to test by simply removing your default route then trying to
 mount something outside your local network.

 This patch causes any SOFTCONN task to be woken up as soon as a connection
 error occurs so that it can fail promptly.  The failure reasons gets passed
 back and as it is not ETIMEDOUT it causes immediate failure.

 Is this a reasonable approach?

Thanks,
NeilBrown




=46rom a1aea8fc3977ffa9951c3d7f27dbb1905e5f560f Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Mon, 7 Nov 2011 15:00:17 +1100
Subject: [PATCH] sunrpc: wake up SOFTCONN tasks when a connection error
 happens.

A 'SOFTCONN' task should fail if there is an error or a major timeout
during connection.

However errors are currently converted into a timeout (60seconds for
TCP) which is treated as a minor timeout and 3 of these are required
before failure.

The result of this is that if you try to mount an NFSv4 filesystem
(which doesn't require rpcbind and the failure modes that provides)
from a server which you do not have a route to (an so get
NETUNREACHABLE), you have an unnecessary 3 minutes timeout.

So when ENETUNREACH is reported for a connection - or other errors
which are fatal, wake up any SOFTCONN tasks with that error - rather
than letting them wait 60 seconds and then generate ETIMEDOUT.

This causes the above mentioned mount attempt to fail instantly.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |   29 +++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c        |    6 +++++-
 3 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index e775689..b85451b 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -236,6 +236,7 @@ void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 void		rpc_wake_up(struct rpc_wait_queue *);
 struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
+void		rpc_wake_up_softconn_status(struct rpc_wait_queue *, int);
 int		rpc_queue_empty(struct rpc_wait_queue *);
 void		rpc_delay(struct rpc_task *, unsigned long);
 void *		rpc_malloc(struct rpc_task *, size_t);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d12ffa5..d92000a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -543,6 +543,35 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, =
int status)
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_status);
=20
+/**
+ * rpc_wake_up_softconn_status - wake up all SOFTCONN rpc_tasks and set th=
eir
+ * status value.
+ * @queue: rpc_wait_queue on which the tasks are sleeping
+ * @status: status value to set
+ *
+ * Grabs queue->lock
+ */
+void rpc_wake_up_softconn_status(struct rpc_wait_queue *queue, int status)
+{
+	struct rpc_task *task, *next;
+	struct list_head *head;
+
+	spin_lock_bh(&queue->lock);
+	head =3D &queue->tasks[queue->maxpriority];
+	for (;;) {
+		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
+			if (RPC_IS_SOFTCONN(task)) {
+				task->tk_status =3D status;
+				rpc_wake_up_task_queue_locked(queue, task);
+			}
+		if (head =3D=3D &queue->tasks[0])
+			break;
+		head--;
+	}
+	spin_unlock_bh(&queue->lock);
+}
+EXPORT_SYMBOL_GPL(rpc_wake_up_softconn_status);
+
 static void __rpc_queue_timer_fn(unsigned long ptr)
 {
 	struct rpc_wait_queue *queue =3D (struct rpc_wait_queue *)ptr;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d7f97ef..02c683b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2158,7 +2158,11 @@ static void xs_tcp_setup_socket(struct work_struct *=
work)
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ENETUNREACH:
-		/* retry with existing socket, after a delay */
+		/* Retry with existing socket after a delay, except
+		 * for SOFTCONN tasks which fail. */
+		xprt_clear_connecting(xprt);
+		rpc_wake_up_softconn_status(&xprt->pending, status);
+		return;
 	case 0:
 	case -EINPROGRESS:
 	case -EALREADY:
--=20
1.7.7


--Sig_/Eys2hmBm2NrLNqDu7gHbPgq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTrdZZDnsnt1WYoG5AQJLIBAAiWJbTpohcFOJSrNOfoQODyG9XB6i5lmM
PXs02/RxFGDyzWVKK/gGFiC5a1SgUEAgWC7pteZaruYNPfnHg6lT3aemEOVMXvls
681QyCHVV8KDKbksFJKz0X4vmkyYNn56owuOE831x4XVHAVki19Mv+LYOz3d5WOg
lLpvR+GND+RL/j6mXSRKY04+HjakyHAF7rn1dg53QItBg+1mfMJSXCHVdsZctbrD
xf1s8ge0fSrg/3Sd2kXtju0hDgp2fYaGKpP13V88yKHVLDTHUyups9A9vmuWODby
ZAmye+PKDIzoOfJTdWzr7sbMyvdaYgjcyOKeZlM/naxwfJ4MKdktN2o+9c5It2r/
3vM+mAi3/0yKM0nmiRyydKy3vDH3/qsM4n/jDmVsjpRYiqjXJP2/v4eW3AK2ATX3
Pkbk9rWGmiC2AsMdWb78E+xLnscwDszjkV2BMH5Yv7Mj98sXqg1bxjGuxmoBJ98A
T6+J7QA6Do0gY0cJmOVThbk9lcQZD0SR1QEixvepy6RkuHEvcRWLVBvZtGC7NMiQ
1se7Vp6zAkxBxcWyWulI5mV0f05OoIvlcUhqTASSYP5jYYf/GsdPKXKgjsTHUXWv
6hRZVi98KT7eIuHoBB4iXs7tdpLYPtkJ6eNsh8YBbnuQjXtq/JUlBDzs6ewb47ok
OiKG/VFw5DQ=
=rpxx
-----END PGP SIGNATURE-----

--Sig_/Eys2hmBm2NrLNqDu7gHbPgq--
