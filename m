Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f45.google.com ([209.85.160.45]:41244 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab3LaFR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Dec 2013 00:17:28 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so12243464pbb.18
        for <linux-nfs@vger.kernel.org>; Mon, 30 Dec 2013 21:17:28 -0800 (PST)
Message-ID: <52C25360.9080207@gmail.com>
Date: Tue, 31 Dec 2013 13:17:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J.,Bruce Fields" <bfields@fieldses.org>,
        Gareth Williams <gareth@garethwilliams.me.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com
Subject: [PATCH 1/2 v2] SUNRPC/NFSD:  Supports new option for ignoring the
 result of svc_register
References: <52B47A12.2070202@garethwilliams.me.uk>	<20131223173956.GA9221@fieldses.org>	<52BD53CA.5050205@gmail.com>	<7FD776EA-EAA8-41E0-9567-BF3924D365AC@oracle.com>	<20131227184309.GA9161@fieldses.org>	<01763B6D-C8CB-46B7-87AC-CE189496019A@oracle.com>	<6E281EC9-49CB-4BDA-BDF3-7A6F4B703156@gmail.com>	<CAB6yy34woYZaJ=k=Ga9iT_mmBWBiCUj1SprT=Se2SVrOu6YO_Q@mail.gmail.com>	<5D65FDE6-D1AB-442C-BFD8-141AB87FF321@gmail.com> <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com> <52C1577B.9080100@gmail.com> <52C15847.9030208@gmail.com> <68E6D30F-B2D6-4919-9748-E7F1162AC3B7@oracle.com> <52C2377E.8040006@gmail.com>
In-Reply-To: <52C2377E.8040006@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Williams reports starting NFSv4 failed without rpcbind, get error,

#rpc.nfsd -N 2 -N 3
rpc.nfsd: writing fd to kernel failed: errno 111 (Connection refused)
rpc.nfsd: unable to set any sockets for nfsd 

For this, NFSv4 needs ignoring the result from svc_register, 
so adds a flags in svc_version.

v2:
use meaningful name vs_rpcb_optnl insteads vs_ignore_err
move setting nfsd_version4's vs_rpcb_optnl option from old patch [2/2]

Reported-by: Gareth Williams <gareth@garethwilliams.me.uk>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c         |  1 +
 include/linux/sunrpc/svc.h |  4 +++-
 net/sunrpc/svc.c           | 25 +++++++++++++++++--------
 3 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 419572f..db3d5b9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1881,6 +1881,7 @@ struct svc_version	nfsd_version4 = {
 		.vs_proc	= nfsd_procedures4,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
+		.vs_rpcb_optnl	= 1,
 };
 
 /*
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6eecfc2..10e28d1 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -386,8 +386,10 @@ struct svc_version {
 	struct svc_procedure *	vs_proc;	/* per-procedure info */
 	u32			vs_xdrsize;	/* xdrsize needed for this version */
 
-	unsigned int		vs_hidden : 1;	/* Don't register with portmapper.
+	unsigned int		vs_hidden : 1,	/* Don't register with portmapper.
 						 * Only used for nfsacl so far. */
+				vs_rpcb_optnl:1;/* Don't care the result of register.
+						 * Only used for nfsv4. */
 
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e7fbe36..5de6801 100644
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
+			if (vers->vs_rpcb_optnl) {
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
