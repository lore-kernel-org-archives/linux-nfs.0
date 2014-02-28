Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39666 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808AbaB1W35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Feb 2014 17:29:57 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1SMTv5f024605
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 28 Feb 2014 17:29:57 -0500
Date: Fri, 28 Feb 2014 17:29:56 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@redhat.com
Subject: [PATCH/RFC] Add simple backoff logic when reconnecting to a server
 that recently initiated a connection close
Message-ID: <20140228222956.GA1544@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="aT9PWwzfKXlsBJM1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--aT9PWwzfKXlsBJM1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

We recently had a customer whose filer began closing the client's
connection upon receipt of a PATHCONF operation.  The environment had a
mix of RHEL 6.2 and RHEL 6.4 clients.  The RHEL 6.2 clients would wait 3
seconds before reconnecting while the RHEL 6.4 clients would reconnect
immediately, triggering what could be described as a DOS on the filer.

The difference in behavior was due to the inclusion of commit a519fc7
(SUNRPC: Ensure that the TCP socket is closed when in CLOSE_WAIT) in the
RHEL 6.4 kernel.  With this commit in place, when the server initiates a
close we wind up destroying the transport socket, and a subsequent call
to xs_connect() we attempt to connect right away.  Prior to this commit,
we would arrive in xs_connect() with a non-NULL socket and as a result
we'd delay for the reestablish_timeout before trying to connect.

It's still unknown what originally caused the filer to behave in this
manner, but I'm able to reproduce this behavior with a Linux NFS server
patched to close the connection upon receipt of a PATHCONF operation
(patch attached).

I've also attached two possible fixes using the old xprt->shutdown field
to indicate that the other end has initiated a shutdown of the
connection.  The goal of both patches is to bring back some of the old
backoff logic without undoing the fix brought about by a519fc7.  The
first option will delay any time the xprt->shutdown field is set -- the
drawback being that in the case of a simple restart of the NFS server,
the client may delay for 3 seconds before trying to reconnect.  The
second option will only delay after 3 successive connect/close sequences
where we've not received a proper reply to an RPC request.  

-Scott

--aT9PWwzfKXlsBJM1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="repro.patch"

>From 275ac2c1ba2279b23b191825fa190f5b6f7882c5 Mon Sep 17 00:00:00 2001
From: Scott Mayhew <smayhew@redhat.com>
Date: Fri, 28 Feb 2014 16:34:24 -0500
Subject: [PATCH] svcrpc: close connection when nfs v3 pathconf is received

reproducer for case 1046417
---
 net/sunrpc/svc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 5de6801..52866dc 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1113,6 +1113,12 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	rqstp->rq_vers = vers = svc_getnl(argv);	/* version number */
 	rqstp->rq_proc = proc = svc_getnl(argv);	/* procedure number */
 
+	if (prog == 100003 && vers == 3 && proc == 20) {
+		dprintk("received pathconf, closing connection\n");
+		svc_close_xprt(rqstp->rq_xprt);
+		goto dropit;
+	}
+
 	for (progp = serv->sv_program; progp; progp = progp->pg_next)
 		if (prog == progp->pg_prog)
 			break;
-- 
1.8.5.3


--aT9PWwzfKXlsBJM1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="option1.patch"

>From d7e96d391733af92c209589458f1c46c21577434 Mon Sep 17 00:00:00 2001
From: Scott Mayhew <smayhew@redhat.com>
Date: Fri, 28 Feb 2014 15:23:50 -0500
Subject: [PATCH] sunrpc: reintroduce xprt->shutdown with a new purpose (option
 1)

If a server is behaving pathologically and accepting our connections
only to close the socket on the first RPC operation it receives, then
we should probably delay when trying to reconnect.

This patch reintroduces the xprt->shutdown field.  Previously this
field was used to indicate that the transport was in the process of
being shutdown, but now it will just be used to indicate that a shutdown
was initiated by the server.

If we find that xprt->shutdown is nonzero when we arrive in
xs_connect(), then we'll delay before trying to connect.  The drawback
is that it will introduce a short delay in the case of a simple restart
of the NFS server... but that may be preferable to blasting away at a
server that's in a bad way.
---
 include/linux/sunrpc/xprt.h |  3 ++-
 net/sunrpc/clnt.c           |  2 ++
 net/sunrpc/xprtsock.c       | 13 +++++++++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8097b9d..c5490fa 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -173,7 +173,8 @@ struct rpc_xprt {
 	unsigned int		min_reqs;	/* min number of slots */
 	atomic_t		num_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
-	unsigned char		resvport   : 1; /* use a reserved port */
+	unsigned char		shutdown   : 1, /* server initiated a shutdown */
+				resvport   : 1; /* use a reserved port */
 	unsigned int		swapper;	/* we're swapping over this
 						   transport */
 	unsigned int		bind_index;	/* bind function index */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0edada9..c32de98 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -515,6 +515,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
+	xprt->shutdown = 0;
+
 	clnt = rpc_new_client(args, xprt, NULL);
 	if (IS_ERR(clnt))
 		return clnt;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0addefc..318943a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1557,6 +1557,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
 		}
 		spin_unlock(&xprt->transport_lock);
+		xprt->shutdown = 0;
 		break;
 	case TCP_FIN_WAIT1:
 		/* The client initiated a shutdown of the socket */
@@ -1572,6 +1573,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
 		xprt->connect_cookie++;
+		xprt->shutdown = 1;
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		xs_tcp_force_close(xprt);
 	case TCP_CLOSING:
@@ -2332,6 +2334,17 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
+	} else if (xprt->shutdown == 1) {
+		dprintk("RPC:       server previously initiated shutdown of the "
+				"transport socket\n");
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
+				"seconds\n",
+				xprt, xprt->reestablish_timeout / HZ);
+		queue_delayed_work(rpciod_workqueue,
+				   &transport->connect_worker,
+				   xprt->reestablish_timeout);
 	} else {
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
 		queue_delayed_work(rpciod_workqueue,
-- 
1.8.5.3


--aT9PWwzfKXlsBJM1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="option2.patch"

>From 2e3902fc0c66bda360a8e40e3e64d82e312a20d4 Mon Sep 17 00:00:00 2001
From: Scott Mayhew <smayhew@redhat.com>
Date: Fri, 28 Feb 2014 15:23:50 -0500
Subject: [PATCH] sunrpc: reintroduce xprt->shutdown with a new purpose (option
 2)

If a server is behaving pathologically and accepting our connections
only to close the socket on the first RPC operation it receives, then
we should probably delay when trying to reconnect.

This patch reintroduces the xprt->shutdown field (this time as two
bits).  Previously this field was used to indicate that the transport
was in the process of being shutdown, but now it will just be used to
indicate that a shutdown was initiated by the server.

If the server closes the connection 3 times without us having received
an RPC reply in the interim, then we'll delay before attempting to
connect again.
---
 include/linux/sunrpc/xprt.h |  3 ++-
 net/sunrpc/clnt.c           |  2 ++
 net/sunrpc/xprtsock.c       | 13 +++++++++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8097b9d..621d583 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -173,7 +173,8 @@ struct rpc_xprt {
 	unsigned int		min_reqs;	/* min number of slots */
 	atomic_t		num_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
-	unsigned char		resvport   : 1; /* use a reserved port */
+	unsigned char		shutdown   : 2, /* server initiated a shutdown */
+				resvport   : 1; /* use a reserved port */
 	unsigned int		swapper;	/* we're swapping over this
 						   transport */
 	unsigned int		bind_index;	/* bind function index */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0edada9..c32de98 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -515,6 +515,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
+	xprt->shutdown = 0;
+
 	clnt = rpc_new_client(args, xprt, NULL);
 	if (IS_ERR(clnt))
 		return clnt;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0addefc..35cdb63 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1295,6 +1295,7 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
 
 	spin_unlock(&xprt->transport_lock);
+	xprt->shutdown = 0;
 	return 0;
 }
 
@@ -1572,6 +1573,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
 		xprt->connect_cookie++;
+		xprt->shutdown++;
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		xs_tcp_force_close(xprt);
 	case TCP_CLOSING:
@@ -2332,6 +2334,17 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
+	} else if (xprt->shutdown > 2) {
+		dprintk("RPC:       server previously initiated shutdown of the "
+				"transport socket %d times\n", xprt->shutdown);
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
+				"seconds\n",
+				xprt, xprt->reestablish_timeout / HZ);
+		queue_delayed_work(rpciod_workqueue,
+				   &transport->connect_worker,
+				   xprt->reestablish_timeout);
 	} else {
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
 		queue_delayed_work(rpciod_workqueue,
-- 
1.8.5.3


--aT9PWwzfKXlsBJM1--
