From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Wed, 08 Dec 2004 13:17:53 -0500
Message-ID: <41B74551.5040908@sun.com>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_T32KZ2bpMLVCidkS+cyZ5g)"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cc6Og-0001xa-79
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 10:18:42 -0800
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cc6Of-00088T-2B
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 10:18:42 -0800
Received: from phys-mpk-1 ([129.146.11.81])
	by brmea-mail-4.sun.com (8.12.10/8.12.9) with ESMTP id iB8II8dt023804
	for <nfs@lists.sourceforge.net>; Wed, 8 Dec 2004 11:18:08 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0I8F00G011G1O2@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Wed, 08 Dec 2004 10:18:08 -0800 (PST)
In-reply-to: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

--Boundary_(ID_T32KZ2bpMLVCidkS+cyZ5g)
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7BIT

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Lever, Charles wrote:
>>the current xprt_bindresvport implementation will search for 
>>a privileged
>>port by counting down from 800 to 0. I think this is a bug, because it
>>will potentially interfere with services trying to bind to 
>>low ports as
>>well.
> 
> 
> is this idle speculation, or do you actually have a test case that
> fails?  :^)
> 

Well, I haven't seen this 'interfere' with services yet, I can imagine
that it is plausible for a service to want to grab some port at a later
time only to have it in use by nfs.

> 
>>The bindresvport implementation in glibc picks from the 600-1023
>>range.
> 
> 
> we should review what other RPC implementations do (namely the reference
> implementation, Solaris).
> 
> but also notice this cuts the usable port range in half (from ~800 to
> ~420).  we need some form of mitigation to ensure we aren't limiting the
> number of NFS mounts a client can have.


This has been bugging me for a while.  The fact that we are limitting
ourselves to a single nfs mount per port.  From what I can tell, Solaris
shares the transports between nfs mounts from the same server and saves
themselves a lot of trouble with running out of port numbers in doing so.

The attached patch does the same for Linux against 2.6.9.  We share
xprts from existing connections, effectively removing any limit on the
number of nfs mounts we have in the system.

The only thing to worry about now is any talking to the portmapper or
mountd from userspace using tcp, which will put the reserved ports in
TIME_WAIT state.  This can limit the 'speed' at which we mount many mounts.

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

iD8DBQFBt0VQdQs4kOxk3/MRAjo8AKCJjoqPxk1R3ev+o+UyquE0kiw0LQCfebi8
6mfhMSHLidFslVyt6jFeNis=
=0uCI
-----END PGP SIGNATURE-----

--Boundary_(ID_T32KZ2bpMLVCidkS+cyZ5g)
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
Index: linux-2.6.9-nfs_portsharing/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.9-nfs_portsharing.orig/include/linux/sunrpc/xprt.h	2004-10-18 14:54:40.000000000 -0700
+++ linux-2.6.9-nfs_portsharing/include/linux/sunrpc/xprt.h	2004-10-26 13:22:41.000000000 -0700
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
Index: linux-2.6.9-nfs_portsharing/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.9-nfs_portsharing.orig/net/sunrpc/xprt.c	2004-10-18 14:54:39.000000000 -0700
+++ linux-2.6.9-nfs_portsharing/net/sunrpc/xprt.c	2004-10-26 15:27:56.713490488 -0700
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
@@ -1395,6 +1401,30 @@ xprt_release(struct rpc_task *task)
 }
 
 /*
+ * Compare two rpc_timeout to see if they are the same.
+ */
+static int
+xprt_is_same_timeout(struct rpc_timeout *left, struct rpc_timeout *right)
+{
+	return left->to_initval     == right->to_initval
+            && left->to_maxval      == right->to_maxval
+            && left->to_increment   == right->to_increment
+            && left->to_retries     == right->to_retries
+            && left->to_exponential == right->to_exponential;
+}
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
@@ -1472,6 +1502,8 @@ xprt_setup(int proto, struct sockaddr_in
 	xprt->timer.data = (unsigned long) xprt;
 	xprt->last_used = jiffies;
 	xprt->port = XPRT_MAX_RESVPORT;
+	INIT_LIST_HEAD(&xprt->shared);
+	atomic_set(&xprt->count, 1);
 
 	/* Set timeout parameters */
 	if (to) {
@@ -1617,8 +1649,8 @@ failed:
 /*
  * Create an RPC client transport given the protocol and peer address.
  */
-struct rpc_xprt *
-xprt_create_proto(int proto, struct sockaddr_in *sap, struct rpc_timeout *to)
+static struct rpc_xprt *
+__xprt_create_proto(int proto, struct sockaddr_in *sap, struct rpc_timeout *to)
 {
 	struct rpc_xprt	*xprt;
 
@@ -1631,6 +1663,43 @@ xprt_create_proto(int proto, struct sock
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
@@ -1658,8 +1727,8 @@ xprt_clear_backlog(struct rpc_xprt *xprt
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
@@ -1670,3 +1739,20 @@ xprt_destroy(struct rpc_xprt *xprt)
 
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

--Boundary_(ID_T32KZ2bpMLVCidkS+cyZ5g)--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
