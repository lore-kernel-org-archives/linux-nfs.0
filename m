From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] make NFS lockd port numbers assignable at run time
Date: Thu, 28 Aug 2003 11:46:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F4E23EA.2040300@RedHat.com>
References: <mailman.1061167921.6355.linux-kernel2news@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040002000101010803010107"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sOy3-0005yr-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 08:45:47 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sOy2-0004M8-M5
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 08:45:46 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h7SFjjK26682
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 11:45:45 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <mailman.1061167921.6355.linux-kernel2news@redhat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------040002000101010803010107
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jamie Lokier wrote:
> This patch allows the port numbers and the other lockd parameters to
> be set through files in /proc/sys/fs/nfs/nlm_*.  The port numbers take
> effect when lockd is next started or restarted.

Here is a version of Jamie's patch that has been
backported to 2.4.21 kernels and restores the
modules parameter interface for backwards compatibility.

Both of this patches will make it much easier to
get NFS traffic through a firewall... Whether that's
a good idea or not is a hold different issue... ;-)

SteveD.

--------------040002000101010803010107
Content-Type: text/plain;
 name="linux-2.4.21-lockd-sysctlif.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-lockd-sysctlif.patch"

--- linux-2.4.21/fs/lockd/svc.c.orig	2003-08-21 22:01:41.000000000 -0400
+++ linux-2.4.21/fs/lockd/svc.c	2003-08-22 10:34:57.000000000 -0400
@@ -16,6 +16,7 @@
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/sysctl.h>
 
 #include <linux/sched.h>
 #include <linux/errno.h>
@@ -51,19 +52,30 @@ static DECLARE_MUTEX_LOCKED(lockd_start)
 static DECLARE_WAIT_QUEUE_HEAD(lockd_exit);
 
 /*
- * Currently the following can be set only at insmod time.
- * Ideally, they would be accessible through the sysctl interface.
+ * These can be set at insmod time (useful for NFS as root filesystem),
+ * and also changed through the sysctl interface.  -- Jamie Lokier, Aug 2003
  */
-unsigned long			nlm_grace_period;
-unsigned long			nlm_timeout = LOCKD_DFLT_TIMEO;
-unsigned long			nlm_udpport, nlm_tcpport;
+static unsigned long		nlm_grace_period;
+static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
+static int			nlm_udpport, nlm_tcpport;
+
+/*
+ * Constants needed for the sysctl interface.
+ */
+static const unsigned long	nlm_grace_period_min = 0;
+static const unsigned long	nlm_grace_period_max = 240;
+static const unsigned long	nlm_timeout_min = 3;
+static const unsigned long	nlm_timeout_max = 20;
+static const int		nlm_port_min = 0, nlm_port_max = 65535;
+
+static struct ctl_table_header * nlm_sysctl_table;
 
 static unsigned long set_grace_period(void)
 {
 	unsigned long grace_period;
 
 	/* Note: nlm_timeout should always be nonzero */
-	if (nlm_grace_period)
+	if (nlm_grace_period && nlm_timeout > 0)
 		grace_period = ((nlm_grace_period + nlm_timeout - 1)
 				/ nlm_timeout) * nlm_timeout * HZ;
 	else
@@ -314,8 +326,76 @@ out:
 	up(&nlmsvc_sema);
 }
 
-#ifdef MODULE
-/* New module support in 2.1.18 */
+/*
+ * Sysctl parameters (same as module parameters, different interface).
+ */
+
+/* Something that isn't CTL_ANY, CTL_NONE or a value that may clash. */
+#define CTL_UNNUMBERED		-2
+
+static ctl_table nlm_sysctls[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nlm_grace_period",
+		.data		= &nlm_grace_period,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_doulongvec_minmax,
+		.extra1		= (unsigned long *) &nlm_grace_period_min,
+		.extra2		= (unsigned long *) &nlm_grace_period_max,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nlm_timeout",
+		.data		= &nlm_timeout,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_doulongvec_minmax,
+		.extra1		= (unsigned long *) &nlm_timeout_min,
+		.extra2		= (unsigned long *) &nlm_timeout_max,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nlm_udpport",
+		.data		= &nlm_udpport,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.extra1		= (int *) &nlm_port_min,
+		.extra2		= (int *) &nlm_port_max,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nlm_tcpport",
+		.data		= &nlm_tcpport,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.extra1		= (int *) &nlm_port_min,
+		.extra2		= (int *) &nlm_port_max,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table nlm_sysctl_dir[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nfs",
+		.mode		= 0555,
+		.child		= nlm_sysctls,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table nlm_sysctl_root[] = {
+	{
+		.ctl_name	= CTL_FS,
+		.procname	= "fs",
+		.mode		= 0555,
+		.child		= nlm_sysctl_dir,
+	},
+	{ .ctl_name = 0 }
+};
 
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_DESCRIPTION("NFS file locking service version " LOCKD_VERSION ".");
@@ -325,41 +405,26 @@ MODULE_PARM(nlm_timeout, "3-20l");
 MODULE_PARM(nlm_udpport, "0-65535l");
 MODULE_PARM(nlm_tcpport, "0-65535l");
 
-int
-init_module(void)
-{
-	/* Init the static variables */
-	init_MUTEX(&nlmsvc_sema);
-	nlmsvc_users = 0;
-	nlmsvc_pid = 0;
-	return 0;
-}
 
-void
-cleanup_module(void)
-{
-	/* FIXME: delete all NLM clients */
-	nlm_shutdown_hosts();
-}
-#else
-/* not a module, so process bootargs
- * lockd.udpport and lockd.tcpport
+/*
+ * Initialising and terminating the module.
  */
 
-static int __init udpport_set(char *str)
+static int __init init_nlm(void)
 {
-	nlm_udpport = simple_strtoul(str, NULL, 0);
-	return 1;
+	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root, 0);
+	return nlm_sysctl_table ? 0 : -ENOMEM;
 }
-static int __init tcpport_set(char *str)
+
+static void __exit exit_nlm(void)
 {
-	nlm_tcpport = simple_strtoul(str, NULL, 0);
-	return 1;
+	/* FIXME: delete all NLM clients */
+	nlm_shutdown_hosts();
+	unregister_sysctl_table(nlm_sysctl_table);
 }
-__setup("lockd.udpport=", udpport_set);
-__setup("lockd.tcpport=", tcpport_set);
 
-#endif
+module_init(init_nlm);
+module_exit(exit_nlm);
 
 /*
  * Define NLM program and procedures

--------------040002000101010803010107--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
