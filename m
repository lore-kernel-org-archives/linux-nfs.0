From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: [PATCH] xprt sharing (2nd try)
Date: Thu, 09 Dec 2004 13:23:11 -0500
Message-ID: <41B8980F.9090507@sun.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_X+XJtoXOUo7XeGsKRqw46Q)"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcSxl-0002Zu-Mu
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 10:24:25 -0800
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CcSxa-0003FM-Vz
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 10:24:20 -0800
Received: from phys-mpk-1 ([129.146.11.81])
	by brmea-mail-4.sun.com (8.12.10/8.12.9) with ESMTP id iB9INmdt012033
	for <nfs@lists.sourceforge.net>; Thu, 9 Dec 2004 11:23:48 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0I8G00F01W52OY@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Thu, 09 Dec 2004 10:23:48 -0800 (PST)
Received: from [129.150.26.203]
 (vpn-129-150-26-203.SFBay.Sun.COM [129.150.26.203]) by mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 with ESMTP id <0I8G00635WES5K@mpk-mail1.sfbay.sun.com> for
 nfs@lists.sourceforge.net; Thu, 09 Dec 2004 10:23:17 -0800 (PST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

--Boundary_(ID_X+XJtoXOUo7XeGsKRqw46Q)
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7BIT

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

So, I managed to figure out why the patch I posted yesterday wasn't
working for me.  It would appear that in comparing transport timeouts,
to_increment is only used when to_exponential is false.  nfs uses
to_exponential = 1, and doens't set to_increment at all.  I didn't catch
this earlier because I likely had slab debugging on and instead of
to_increment being garbage values, it was the test pattern (a5a5a5a5).

Anyhow, here is an updated version of the patch which does the timeout
comparison the right way.   Works for me in a not-so-tested environment.

- --
Mike Waychison
Sun Microsystems, Inc.
1 (650) 352-5299 voice
1 (416) 202-8336 voice

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NOTICE:  The opinions expressed in this email are held by me,
and may not represent the views of Sun Microsystems, Inc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBuJgOdQs4kOxk3/MRAr/jAJ9ogzmFQ2iCZGbvvdc/EYewbWjmdACdHI7A
5Uay1xrNaYhGzDY1rft2EVY=
=ndVJ
-----END PGP SIGNATURE-----

--Boundary_(ID_X+XJtoXOUo7XeGsKRqw46Q)
Content-type: text/x-patch; name=xprt_sharing.diff
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=xprt_sharing.diff

This patch allows for sharing of xprts.  This is done by keeping a list of
current xprts and passing them back to the caller of xprt_create_proto if they
match the specifications required (IP X port X protocol X timeout).

We do this multiplexing at the xprt layer as it handles transport creation and
destruction.

This patch has been tested in a test-only environment but has been able to
handle a couple hundreds distinct nfs mounts from the same server over a single
tcp stream.

This effectively gets rid of the 800 nfs mounts max problem, as long as you
aren't mounting from many (800) nfs servers.

Signed-off-by: Mike Waychison <michael.waychison@sun.com>

Index: linux-2.6.9-quilt/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.9-quilt.orig/include/linux/sunrpc/xprt.h	2004-10-18 14:54:40.000000000 -0700
+++ linux-2.6.9-quilt/include/linux/sunrpc/xprt.h	2004-12-09 10:45:15.750404992 -0800
@@ -15,6 +15,8 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xdr.h>
 
+#include <asm/atomic.h>
+
 /*
  * The transport code maintains an estimate on the maximum number of out-
  * standing RPC requests, using a smoothed version of the congestion
@@ -194,6 +196,9 @@ struct rpc_xprt {
 	void			(*old_write_space)(struct sock *);
 
 	wait_queue_head_t	cong_wait;
+
+	atomic_t		count;		/* shared xprt refcount */
+	struct list_head	shared;		/* link to shared list */
 };
 
 #ifdef __KERNEL__
Index: linux-2.6.9-quilt/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.9-quilt.orig/net/sunrpc/xprt.c	2004-10-18 14:54:39.000000000 -0700
+++ linux-2.6.9-quilt/net/sunrpc/xprt.c	2004-12-09 10:45:27.574607440 -0800
@@ -78,6 +78,12 @@
 #define XPRT_MAX_RESVPORT	(800)
 
 /*
+ * List of shared xprt
+ */
+static DECLARE_MUTEX(shared_xprt_sem);
+static LIST_HEAD(shared_xprt_list);
+
+/*
  * Local functions
  */
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
@@ -1395,6 +1401,33 @@ xprt_release(struct rpc_task *task)
 }
 
 /*
+ * Compare two rpc_timeout to see if they are the same.
+ */
+static int
+xprt_is_same_timeout(struct rpc_timeout *left, struct rpc_timeout *right)
+{
+	/* to_increment isn't used if to_exponential is true */
+	return left->to_initval     == right->to_initval
+            && left->to_maxval      == right->to_maxval
+            && left->to_retries     == right->to_retries
+            && left->to_exponential == right->to_exponential
+            && (left->to_exponential
+                || (left->to_increment  == right->to_increment));
+}
+
+/*
+ * Check to see if the timeout is the default timeout.
+ */
+static int
+xprt_is_default_timeout(struct rpc_timeout *to, int proto)
+{
+	struct rpc_timeout defaultto;
+
+	xprt_default_timeout(&defaultto, proto);
+	return xprt_is_same_timeout(&defaultto, to);
+}
+
+/*
  * Set default timeout parameters
  */
 void
@@ -1472,6 +1505,8 @@ xprt_setup(int proto, struct sockaddr_in
 	xprt->timer.data = (unsigned long) xprt;
 	xprt->last_used = jiffies;
 	xprt->port = XPRT_MAX_RESVPORT;
+	INIT_LIST_HEAD(&xprt->shared);
+	atomic_set(&xprt->count, 1);
 
 	/* Set timeout parameters */
 	if (to) {
@@ -1617,8 +1652,8 @@ failed:
 /*
  * Create an RPC client transport given the protocol and peer address.
  */
-struct rpc_xprt *
-xprt_create_proto(int proto, struct sockaddr_in *sap, struct rpc_timeout *to)
+static struct rpc_xprt *
+__xprt_create_proto(int proto, struct sockaddr_in *sap, struct rpc_timeout *to)
 {
 	struct rpc_xprt	*xprt;
 
@@ -1631,6 +1666,43 @@ xprt_create_proto(int proto, struct sock
 }
 
 /*
+ * Create an RPC client transport that is shared given the protocol and peer
+ * address.
+ */
+struct rpc_xprt *
+xprt_create_proto(int proto, struct sockaddr_in *sap, struct rpc_timeout *to)
+{
+	struct rpc_xprt *xprt;
+
+	down(&shared_xprt_sem);
+	/* walk the list and find an existing mathing xprt */
+	list_for_each_entry(xprt, &shared_xprt_list, shared) {
+		/* Filter out mismatches */
+		if (sap->sin_addr.s_addr != xprt->addr.sin_addr.s_addr)
+			continue;
+		if (sap->sin_port != xprt->addr.sin_port)
+			continue;
+		if (xprt->prot != proto)
+			continue;
+		if (to == NULL && !xprt_is_default_timeout(&xprt->timeout, proto))
+			continue;
+		if (to && !xprt_is_same_timeout(&xprt->timeout, to))
+			continue;
+
+		atomic_inc(&xprt->count);
+		goto out;
+	}
+
+	/* make a new one */
+	xprt = __xprt_create_proto(proto, sap, to);
+	if (!IS_ERR(xprt))
+		list_add(&xprt->shared, &shared_xprt_list);
+out:
+	up(&shared_xprt_sem);
+	return xprt;
+}
+
+/*
  * Prepare for transport shutdown.
  */
 void
@@ -1658,8 +1730,8 @@ xprt_clear_backlog(struct rpc_xprt *xprt
 /*
  * Destroy an RPC transport, killing off all requests.
  */
-int
-xprt_destroy(struct rpc_xprt *xprt)
+static int
+__xprt_destroy(struct rpc_xprt *xprt)
 {
 	dprintk("RPC:      destroying transport %p\n", xprt);
 	xprt_shutdown(xprt);
@@ -1670,3 +1742,20 @@ xprt_destroy(struct rpc_xprt *xprt)
 
 	return 0;
 }
+
+/*
+ * Destroy a shared RPC transport.
+ * (XXX: what about the remaining live requests?)
+ */
+int
+xprt_destroy(struct rpc_xprt *xprt)
+{
+	int ret = 0;
+	down(&shared_xprt_sem);
+	if (atomic_dec_and_test(&xprt->count)) {
+		list_del_init(&xprt->shared);
+		ret = __xprt_destroy(xprt);
+	}
+	up(&shared_xprt_sem);
+	return ret;
+}

--Boundary_(ID_X+XJtoXOUo7XeGsKRqw46Q)--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
