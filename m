From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 4/4] Make sunrpc and lockd use
	register_sysctl_table_path
Date: Thu, 3 Aug 2006 13:05:38 +0200
Message-ID: <20060803110538.GA17178@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8b1J-0007dp-Mq
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:41 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8b1J-0003Cf-Nv
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:42 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 56C5F1FD10
	for <nfs@lists.sourceforge.net>; Thu,  3 Aug 2006 13:05:38 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

From: Olaf Kirch <okir@suse.de>
Subject: Make sunrpc and lockd use register_sysctl_table_path

  This changes lockd and sunrpc to use the new register_sysctl_table_path
  call.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/svc.c      |   29 ++++++-----------------------
 net/sunrpc/sysctl.c |   16 ++++------------
 2 files changed, 10 insertions(+), 35 deletions(-)

Index: linux-2.6.18/net/sunrpc/sysctl.c
===================================================================
--- linux-2.6.18.orig/net/sunrpc/sysctl.c
+++ linux-2.6.18/net/sunrpc/sysctl.c
@@ -38,7 +38,9 @@ void
 rpc_register_sysctl(void)
 {
 	if (!sunrpc_table_header) {
-		sunrpc_table_header = register_sysctl_table(sunrpc_table, 1);
+		struct ctl_path ctl_path[] = { { CTL_SUNRPC, "sunrpc", 0555 }, { 0 } };
+
+		sunrpc_table_header = register_sysctl_table_path(sunrpc_table, ctl_path);
 #ifdef CONFIG_PROC_FS
 		if (sunrpc_table[0].de)
 			sunrpc_table[0].de->owner = THIS_MODULE;
@@ -125,7 +127,7 @@ static unsigned int max_slot_table_size 
 static unsigned int xprt_min_resvport_limit = RPC_MIN_RESVPORT;
 static unsigned int xprt_max_resvport_limit = RPC_MAX_RESVPORT;
 
-static ctl_table debug_table[] = {
+static ctl_table sunrpc_table[] = {
 	{
 		.ctl_name	= CTL_RPCDEBUG,
 		.procname	= "rpc_debug",
@@ -205,14 +207,4 @@ static ctl_table debug_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static ctl_table sunrpc_table[] = {
-	{
-		.ctl_name	= CTL_SUNRPC,
-		.procname	= "sunrpc",
-		.mode		= 0555,
-		.child		= debug_table
-	},
-	{ .ctl_name = 0 }
-};
-
 #endif
Index: linux-2.6.18/fs/lockd/svc.c
===================================================================
--- linux-2.6.18.orig/fs/lockd/svc.c
+++ linux-2.6.18/fs/lockd/svc.c
@@ -371,26 +371,6 @@ static ctl_table nlm_sysctls[] = {
 	{ .ctl_name = 0 }
 };
 
-static ctl_table nlm_sysctl_dir[] = {
-	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "nfs",
-		.mode		= 0555,
-		.child		= nlm_sysctls,
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table nlm_sysctl_root[] = {
-	{
-		.ctl_name	= CTL_FS,
-		.procname	= "fs",
-		.mode		= 0555,
-		.child		= nlm_sysctl_dir,
-	},
-	{ .ctl_name = 0 }
-};
-
 /*
  * Module (and driverfs) parameters.
  */
@@ -463,15 +443,18 @@ module_param_call(nlm_tcpport, param_set
 
 static int __init init_nlm(void)
 {
-	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root, 0);
-	return nlm_sysctl_table ? 0 : -ENOMEM;
+	struct ctl_path ctl_path[] = { { CTL_FS, "fs", 0555 }, { -2, "nfs", 0555 }, { 0 } };
+
+	nlm_sysctl_table = register_sysctl_table_path(nlm_sysctls, ctl_path);
+	return 0;
 }
 
 static void __exit exit_nlm(void)
 {
 	/* FIXME: delete all NLM clients */
 	nlm_shutdown_hosts();
-	unregister_sysctl_table(nlm_sysctl_table);
+	if (nlm_sysctl_table)
+		unregister_sysctl_table(nlm_sysctl_table);
 }
 
 module_init(init_nlm);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
