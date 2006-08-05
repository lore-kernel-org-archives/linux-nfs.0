From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 20/22] [sunrpc] Register all RPC programs with
	portmapper by default
Date: Sat, 5 Aug 2006 15:06:49 +0200
Message-ID: <20060805130649.GA8118@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrh-000796-TG
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:54 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrh-0003MN-Hx
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:54 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 4109C101B4
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:49 +0200 (CEST)
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
Subject: [sunrpc] Register all RPC programs with portmapper by default

  The NFSACL patches introduced support for multiple RPC services
  listening on the same transport. However, only the first of these
  services was registered with portmapper. This was perfectly fine
  for nfsacl, as you traditionally do not want these to show up in a
  portmapper listing.

  The patch below changes the default behavior to always register
  all services listening on a given transport, but retains the
  old behavior for nfsacl services.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/nfsd/nfs2acl.c          |    1 +
 fs/nfsd/nfs3acl.c          |    1 +
 include/linux/sunrpc/svc.h |    3 +++
 net/sunrpc/svc.c           |   37 +++++++++++++++++++++++--------------
 4 files changed, 28 insertions(+), 14 deletions(-)

Index: build/fs/nfsd/nfs2acl.c
===================================================================
--- build.orig/fs/nfsd/nfs2acl.c
+++ build/fs/nfsd/nfs2acl.c
@@ -333,4 +333,5 @@ struct svc_version	nfsd_acl_version2 = {
 		.vs_proc	= nfsd_acl_procedures2,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+		.vs_hidden	= 1,
 };
Index: build/fs/nfsd/nfs3acl.c
===================================================================
--- build.orig/fs/nfsd/nfs3acl.c
+++ build/fs/nfsd/nfs3acl.c
@@ -263,5 +263,6 @@ struct svc_version	nfsd_acl_version3 = {
 		.vs_proc	= nfsd_acl_procedures3,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+		.vs_hidden	= 1,
 };
 
Index: build/include/linux/sunrpc/svc.h
===================================================================
--- build.orig/include/linux/sunrpc/svc.h
+++ build/include/linux/sunrpc/svc.h
@@ -280,6 +280,9 @@ struct svc_version {
 	struct svc_procedure *	vs_proc;	/* per-procedure info */
 	u32			vs_xdrsize;	/* xdrsize needed for this version */
 
+	unsigned int		vs_hidden : 1;	/* Don't register with portmapper.
+						 * Only used for nfsacl so far. */
+
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
 	 * vs_dispatch == NULL means use default dispatcher.
Index: build/net/sunrpc/svc.c
===================================================================
--- build.orig/net/sunrpc/svc.c
+++ build/net/sunrpc/svc.c
@@ -215,23 +215,32 @@ svc_register(struct svc_serv *serv, int 
 	unsigned long		flags;
 	int			i, error = 0, dummy;
 
-	progp = serv->sv_program;
-
-	dprintk("RPC: svc_register(%s, %s, %d)\n",
-		progp->pg_name, proto == IPPROTO_UDP? "udp" : "tcp", port);
-
 	if (!port)
 		clear_thread_flag(TIF_SIGPENDING);
 
-	for (i = 0; i < progp->pg_nvers; i++) {
-		if (progp->pg_vers[i] == NULL)
-			continue;
-		error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
-		if (error < 0)
-			break;
-		if (port && !dummy) {
-			error = -EACCES;
-			break;
+	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
+		for (i = 0; i < progp->pg_nvers; i++) {
+			if (progp->pg_vers[i] == NULL)
+				continue;
+
+			dprintk("RPC: svc_register(%s, %s, %d, %d)%s\n",
+					progp->pg_name,
+					proto == IPPROTO_UDP?  "udp" : "tcp",
+					port,
+					i,
+					progp->pg_vers[i]->vs_hidden?
+						" (but not telling portmap)" : "");
+
+			if (progp->pg_vers[i]->vs_hidden)
+				continue;
+
+			error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
+			if (error < 0)
+				break;
+			if (port && !dummy) {
+				error = -EACCES;
+				break;
+			}
 		}
 	}
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
