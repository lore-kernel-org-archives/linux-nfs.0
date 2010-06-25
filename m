From: <Staubach_Peter@emc.com>
Subject: RE: [PATCH] sunrpc: split the vs_hidden flag into TCP and UDP variants
Date: Fri, 25 Jun 2010 08:58:12 -0400
Message-ID: <BF3BB6D12298F54B89C8DCC1E4073D800183CAB2@CORPUSMX50A.corp.emc.com>
References: <1277429621-9579-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: <jlayton@redhat.com>, <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:52090 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737Ab0FYM6x convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jun 2010 08:58:53 -0400
In-Reply-To: <1277429621-9579-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Does this mean that the Linux NFS server will no longer respond to NFSv4
requests coming in over UDP?  If it will continue to do so, wouldn't it
be more important to solve that correctly?

	Thanx...

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org
[mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Jeff Layton
Sent: Thursday, June 24, 2010 9:34 PM
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: split the vs_hidden flag into TCP and UDP
variants

RFC3530 states:

   Where an NFS version 4 implementation supports operation over the IP
   network protocol, the supported transports between NFS and IP MUST be
   among the IETF-approved congestion control transport protocols, which
   include TCP and SCTP

The NFS server currently registers the NFSv4 UDP port with the
portmapper, which it really shouldn't do. This patch splits the
vs_hidden flag into TCP and UDP variants, and sets vs_hidden_udp for the
NFSv4 service.

Reported-by: Sachin Prabhu <sprabhu@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback_xdr.c      |    3 ++-
 fs/nfsd/nfs2acl.c          |    1 -
 fs/nfsd/nfs3acl.c          |    1 -
 fs/nfsd/nfs4proc.c         |    1 +
 include/linux/sunrpc/svc.h |    5 +++--
 net/sunrpc/svc.c           |   15 +++++++++++----
 6 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 05af212..30baf97 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -783,7 +783,8 @@ struct svc_version nfs4_callback_version1 = {
 	.vs_proc = nfs4_callback_procedures1,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
-	.vs_hidden = 1,
+	.vs_hidden_tcp = true,
+	.vs_hidden_udp = true,
 };
 
 struct svc_version nfs4_callback_version4 = {
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 6aa5590..ec602b4 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -352,5 +352,4 @@ struct svc_version	nfsd_acl_version2 = {
 		.vs_proc	= nfsd_acl_procedures2,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
-		.vs_hidden	= 0,
 };
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index a596e9d..1949a4c 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -262,6 +262,5 @@ struct svc_version	nfsd_acl_version3 = {
 		.vs_proc	= nfsd_acl_procedures3,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
-		.vs_hidden	= 0,
 };
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 59ec449..4dfbf08 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1365,6 +1365,7 @@ struct svc_version	nfsd_version4 = {
 		.vs_proc	= nfsd_procedures4,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
+		.vs_hidden_udp	= true,
 };
 
 /*
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..27ff713 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -370,8 +370,9 @@ struct svc_version {
 	struct svc_procedure *	vs_proc;	/* per-procedure info */
 	u32			vs_xdrsize;	/* xdrsize needed for
this version */
 
-	unsigned int		vs_hidden : 1;	/* Don't register with
portmapper.
-						 * Only used for nfsacl
so far. */
+	/* these flags control whether program is registered with
rpcbind */
+	bool			vs_hidden_tcp;
+	bool			vs_hidden_udp;
 
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d9017d6..487792c 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -868,6 +868,7 @@ int svc_register(const struct svc_serv *serv, const
int family,
 	struct svc_program	*progp;
 	unsigned int		i;
 	int			error = 0;
+	bool			vs_hidden;
 
 	BUG_ON(proto == 0 && port == 0);
 
@@ -876,16 +877,20 @@ int svc_register(const struct svc_serv *serv,
const int family,
 			if (progp->pg_vers[i] == NULL)
 				continue;
 
+			vs_hidden = (proto == IPPROTO_UDP) ?
+				    progp->pg_vers[i]->vs_hidden_udp :
+				    progp->pg_vers[i]->vs_hidden_tcp;
+
 			dprintk("svc: svc_register(%sv%d, %s, %u,
%u)%s\n",
 					progp->pg_name,
 					i,
-					proto == IPPROTO_UDP?  "udp" :
"tcp",
+					proto == IPPROTO_UDP ?  "udp" :
"tcp",
 					port,
 					family,
-					progp->pg_vers[i]->vs_hidden?
+					vs_hidden ?
 						" (but not telling
portmap)" : "");
 
-			if (progp->pg_vers[i]->vs_hidden)
+			if (vs_hidden)
 				continue;
 
 			error = __svc_register(progp->pg_name,
progp->pg_prog,
@@ -943,7 +948,9 @@ static void svc_unregister(const struct svc_serv
*serv)
 		for (i = 0; i < progp->pg_nvers; i++) {
 			if (progp->pg_vers[i] == NULL)
 				continue;
-			if (progp->pg_vers[i]->vs_hidden)
+
+			if (progp->pg_vers[i]->vs_hidden_tcp &&
+			    progp->pg_vers[i]->vs_hidden_udp)
 				continue;
 
 			__svc_unregister(progp->pg_prog, i,
progp->pg_name);
-- 
1.5.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

