From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Fix xprt_bindresvport
Date: Mon, 11 Jul 2005 11:25:56 +0200
Message-ID: <20050711092556.GD27163@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Cc: akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DruY6-0008MV-3Q
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:26:02 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DruY5-0004EX-OO
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 02:26:02 -0700
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


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

# Subject: Fix xprt_bindresvport
# 
# xprt_bindresvport would grab ports in the range 1-800, which can
# conflict with all sorts of network services. What we really want
# to do is select from a range N - 1023.
# 
# The patch below changes xprt_bindresvport to select ports from
# 650-1023 by default (631 is cups, which we better avoid).
# It also adds syscontrols to allow the admin to use a different
# port range.
# 
# Signed-off-by: Olaf Kirch <okir@suse.de>
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-bindresvport

From: Olaf Kirch <okir@suse.de>
Subject: Fix sunrpc xprt_bindresvport

xprt_bindresvport would grab ports in the range 1-800, which can
conflict with all sorts of network services. What we really want
to do is select from a range N - 1023.

The patch below changes xprt_bindresvport to select ports from
650-1023 by default (631 is cups, which we better avoid).
It also adds syscontrols to allow the admin to use different
port range.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.10/include/linux/sunrpc/debug.h
===================================================================
--- linux-2.6.10.orig/include/linux/sunrpc/debug.h	2004-10-18 23:55:36.000000000 +0200
+++ linux-2.6.10/include/linux/sunrpc/debug.h	2005-02-23 17:18:55.000000000 +0100
@@ -94,6 +94,8 @@ enum {
 	CTL_NLMDEBUG,
 	CTL_SLOTTABLE_UDP,
 	CTL_SLOTTABLE_TCP,
+	CTL_MIN_RESVPORT,
+	CTL_MAX_RESVPORT,
 };
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
Index: linux-2.6.10/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.10.orig/include/linux/sunrpc/xprt.h	2005-02-23 17:17:55.000000000 +0100
+++ linux-2.6.10/include/linux/sunrpc/xprt.h	2005-02-23 17:19:21.000000000 +0100
@@ -224,6 +224,9 @@ void			xprt_sock_setbufsize(struct rpc_x
 					(test_and_clear_bit(XPRT_CONNECT, &(xp)->sockstate))
 #define xprt_clear_connected(xp)	(clear_bit(XPRT_CONNECT, &(xp)->sockstate))
 
+extern unsigned int	xprt_min_resvport;
+extern unsigned int	xprt_max_resvport;
+
 #endif /* __KERNEL__*/
 
 #endif /* _LINUX_SUNRPC_XPRT_H */
Index: linux-2.6.10/net/sunrpc/sysctl.c
===================================================================
--- linux-2.6.10.orig/net/sunrpc/sysctl.c	2005-02-23 17:17:55.000000000 +0100
+++ linux-2.6.10/net/sunrpc/sysctl.c	2005-02-23 17:19:35.000000000 +0100
@@ -29,6 +29,10 @@ unsigned int	nfs_debug;
 unsigned int	nfsd_debug;
 unsigned int	nlm_debug;
 
+unsigned int	xprt_min_resvport = 650;
+unsigned int	xprt_max_resvport = 1023;
+
+
 #ifdef RPC_DEBUG
 
 static struct ctl_table_header *sunrpc_table_header;
@@ -121,6 +125,8 @@ done:
 
 static unsigned int min_slot_table_size = RPC_MIN_SLOT_TABLE;
 static unsigned int max_slot_table_size = RPC_MAX_SLOT_TABLE;
+static unsigned int xprt_min_resvport_limit = 1;
+static unsigned int xprt_max_resvport_limit = 65535;
 
 static ctl_table debug_table[] = {
 	{
@@ -156,6 +162,28 @@ static ctl_table debug_table[] = {
 		.proc_handler	= &proc_dodebug
 	}, 
 	{
+		.ctl_name	= CTL_MIN_RESVPORT,
+		.procname	= "min_resvport",
+		.data		= &xprt_min_resvport,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &xprt_min_resvport_limit,
+		.extra2		= &xprt_max_resvport_limit
+	},
+	{
+		.ctl_name	= CTL_MAX_RESVPORT,
+		.procname	= "max_resvport",
+		.data		= &xprt_max_resvport,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &xprt_min_resvport_limit,
+		.extra2		= &xprt_max_resvport_limit
+	},
+	{
 		.ctl_name	= CTL_SLOTTABLE_UDP,
 		.procname	= "udp_slot_table_entries",
 		.data		= &xprt_udp_slot_table_entries,
Index: linux-2.6.10/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.10.orig/net/sunrpc/xprt.c	2005-02-23 17:17:55.000000000 +0100
+++ linux-2.6.10/net/sunrpc/xprt.c	2005-02-23 17:18:08.000000000 +0100
@@ -75,7 +75,6 @@
 
 #define XPRT_MAX_BACKOFF	(8)
 #define XPRT_IDLE_TIMEOUT	(5*60*HZ)
-#define XPRT_MAX_RESVPORT	(800)
 
 /*
  * Local functions
@@ -1492,7 +1491,7 @@ xprt_setup(int proto, struct sockaddr_in
 	xprt->timer.function = xprt_init_autodisconnect;
 	xprt->timer.data = (unsigned long) xprt;
 	xprt->last_used = jiffies;
-	xprt->port = XPRT_MAX_RESVPORT;
+	xprt->port = xprt_max_resvport;
 
 	/* Set timeout parameters */
 	if (to) {
@@ -1540,8 +1539,10 @@ static inline int xprt_bindresvport(stru
 			xprt->port = port;
 			return 0;
 		}
-		if (--port == 0)
-			port = XPRT_MAX_RESVPORT;
+		if (port < xprt_min_resvport)
+			port = xprt_max_resvport;
+		else
+			port--;
 	} while (err == -EADDRINUSE && port != xprt->port);
 
 	printk("RPC: Can't bind to reserved port (%d).\n", -err);

--BXVAT5kNtrzKuDFl--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
