Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f52.google.com ([209.85.160.52]:53237 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab3L3LYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Dec 2013 06:24:32 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so11537959pbc.11
        for <linux-nfs@vger.kernel.org>; Mon, 30 Dec 2013 03:24:31 -0800 (PST)
Message-ID: <52C157EA.7010205@gmail.com>
Date: Mon, 30 Dec 2013 19:24:26 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J.,Bruce Fields" <bfields@fieldses.org>,
        Gareth Williams <gareth@garethwilliams.me.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com
Subject: [PATCH 1/2] SUNRPC: supports ignoring error from svc_register
References: <52B47A12.2070202@garethwilliams.me.uk>	<20131223173956.GA9221@fieldses.org>	<52BD53CA.5050205@gmail.com>	<7FD776EA-EAA8-41E0-9567-BF3924D365AC@oracle.com>	<20131227184309.GA9161@fieldses.org>	<01763B6D-C8CB-46B7-87AC-CE189496019A@oracle.com>	<6E281EC9-49CB-4BDA-BDF3-7A6F4B703156@gmail.com>	<CAB6yy34woYZaJ=k=Ga9iT_mmBWBiCUj1SprT=Se2SVrOu6YO_Q@mail.gmail.com>	<5D65FDE6-D1AB-442C-BFD8-141AB87FF321@gmail.com> <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com> <52C1577B.9080100@gmail.com>
In-Reply-To: <52C1577B.9080100@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 needs ignoring the return errno from svc_register, 
so adds a flags for svc_version.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/svc.h |  1 +
 net/sunrpc/svc.c           | 25 +++++++++++++++++--------
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6eecfc2..9ca8280 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -388,6 +388,7 @@ struct svc_version {
 
 	unsigned int		vs_hidden : 1;	/* Don't register with portmapper.
 						 * Only used for nfsacl so far. */
+	unsigned int		vs_ignore_err : 1;
 
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e7fbe36..7dba3c3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -916,9 +916,6 @@ static int __svc_register(struct net *net, const char *progname,
 #endif
 	}
 
-	if (error < 0)
-		printk(KERN_WARNING "svc: failed to register %sv%u RPC "
-			"service (errno %d).\n", progname, version, -error);
 	return error;
 }
 
@@ -937,6 +934,7 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		 const unsigned short port)
 {
 	struct svc_program	*progp;
+	struct svc_version	*vers;
 	unsigned int		i;
 	int			error = 0;
 
@@ -946,7 +944,8 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
-			if (progp->pg_vers[i] == NULL)
+			vers = progp->pg_vers[i];
+			if (vers == NULL)
 				continue;
 
 			dprintk("svc: svc_register(%sv%d, %s, %u, %u)%s\n",
@@ -955,16 +954,26 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 					proto == IPPROTO_UDP?  "udp" : "tcp",
 					port,
 					family,
-					progp->pg_vers[i]->vs_hidden?
-						" (but not telling portmap)" : "");
+					vers->vs_hidden ?
+					" (but not telling portmap)" : "");
 
-			if (progp->pg_vers[i]->vs_hidden)
+			if (vers->vs_hidden)
 				continue;
 
 			error = __svc_register(net, progp->pg_name, progp->pg_prog,
 						i, family, proto, port);
-			if (error < 0)
+
+			if (vers->vs_ignore_err) {
+				error = 0;
+				continue;
+			}
+
+			if (error < 0) {
+				printk(KERN_WARNING "svc: failed to register "
+					"%sv%u RPC service (errno %d).\n",
+					progp->pg_name, i, -error);
 				break;
+			}
 		}
 	}
 
-- 
1.8.4.2

