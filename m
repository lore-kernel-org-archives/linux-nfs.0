From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 3/5] NFS: Adding trace points to nfs/client.c
Date: Fri, 16 Jan 2009 11:30:09 -0500
Message-ID: <4970B611.1040300@RedHat.com>
References: <4970B451.4080201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: SystemTAP <systemtap@redhat.com>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4970B451.4080201@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Added trace points to a number of client routines 
used in the mount process. If a routine was only called
by the the mounting process, the prefix on the trace
point starts with 'trace_nfs_mount' otherwise the 
routine name as used as the prefix.

Signed-off-by: Steve Dickson <steved@redhat.com>

--- linux/fs/nfs/client.c.orig	2009-01-14 15:54:19.000000000 -0500
+++ linux/fs/nfs/client.c	2009-01-15 12:40:08.000000000 -0500
@@ -37,6 +37,7 @@
 #include <linux/in6.h>
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
+#include <trace/nfs.h>
 
 #include <asm/system.h>
 
@@ -46,6 +47,19 @@
 #include "iostat.h"
 #include "internal.h"
 
+DEFINE_TRACE(nfs_create_rpc_client);
+DEFINE_TRACE(nfs_create_rpc_client_proto);
+DEFINE_TRACE(nfs_start_lockd);
+DEFINE_TRACE(nfs_init_server_rpcclient);
+DEFINE_TRACE(nfs_init_server_rpcclient_clone);
+DEFINE_TRACE(nfs_init_server_rpcclient_auth);
+DEFINE_TRACE(nfs_mount_init_clnt);
+DEFINE_TRACE(nfs_mount_init_srv);
+DEFINE_TRACE(nfs_probe_fsinfo);
+DEFINE_TRACE(nfs_probe_fsinfo_setcaps);
+DEFINE_TRACE(nfs_probe_fsinfo_fsinfo);
+DEFINE_TRACE(nfs_create_server);
+
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 static DEFINE_SPINLOCK(nfs_client_lock);
@@ -507,6 +521,8 @@ static int nfs_create_rpc_client(struct 
 	if (noresvport)
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
+	trace_nfs_create_rpc_client(clp, timeparms, flavor, args.flags);
+
 	if (!IS_ERR(clp->cl_rpcclient))
 		return 0;
 
@@ -514,6 +530,7 @@ static int nfs_create_rpc_client(struct 
 	if (IS_ERR(clnt)) {
 		dprintk("%s: cannot create RPC client. Error = %ld\n",
 				__func__, PTR_ERR(clnt));
+		trace_nfs_create_rpc_client_proto(clp, PTR_ERR(clnt));
 		return PTR_ERR(clnt);
 	}
 
@@ -554,9 +571,10 @@ static int nfs_start_lockd(struct nfs_se
 		return 0;
 
 	host = nlmclnt_init(&nlm_init);
-	if (IS_ERR(host))
+	if (IS_ERR(host)) {
+		trace_nfs_start_lockd(server, PTR_ERR(host));
 		return PTR_ERR(host);
-
+	}
 	server->nlm_host = host;
 	server->destroy = nfs_destroy_server;
 	return 0;
@@ -601,9 +619,12 @@ static int nfs_init_server_rpcclient(str
 {
 	struct nfs_client *clp = server->nfs_client;
 
+	trace_nfs_init_server_rpcclient(server, timeo, pseudoflavour);
+
 	server->client = rpc_clone_client(clp->cl_rpcclient);
 	if (IS_ERR(server->client)) {
 		dprintk("%s: couldn't create rpc_client!\n", __func__);
+		trace_nfs_init_server_rpcclient_clone(server, PTR_ERR(server->client));
 		return PTR_ERR(server->client);
 	}
 
@@ -618,6 +639,7 @@ static int nfs_init_server_rpcclient(str
 		auth = rpcauth_create(pseudoflavour, server->client);
 		if (IS_ERR(auth)) {
 			dprintk("%s: couldn't create credcache!\n", __func__);
+			trace_nfs_init_server_rpcclient_auth(server, PTR_ERR(auth));
 			return PTR_ERR(auth);
 		}
 	}
@@ -657,6 +679,7 @@ static int nfs_init_client(struct nfs_cl
 error:
 	nfs_mark_client_ready(clp, error);
 	dprintk("<-- nfs_init_client() = xerror %d\n", error);
+	trace_nfs_mount_init_clnt(clp, error);
 	return error;
 }
 
@@ -688,6 +711,7 @@ static int nfs_init_server(struct nfs_se
 	clp = nfs_get_client(&cl_init);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
+		trace_nfs_mount_init_srv(server, PTR_ERR(clp));
 		return PTR_ERR(clp);
 	}
 
@@ -807,19 +831,23 @@ static int nfs_probe_fsinfo(struct nfs_s
 	int error;
 
 	dprintk("--> nfs_probe_fsinfo()\n");
+	trace_nfs_probe_fsinfo(server, mntfh, fattr);
 
 	if (clp->rpc_ops->set_capabilities != NULL) {
 		error = clp->rpc_ops->set_capabilities(server, mntfh);
-		if (error < 0)
+		if (error < 0) {
+			trace_nfs_probe_fsinfo_setcaps(server, error);
 			goto out_error;
+		}
 	}
 
 	fsinfo.fattr = fattr;
 	nfs_fattr_init(fattr);
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
-	if (error < 0)
+	if (error < 0) {
+		trace_nfs_probe_fsinfo_fsinfo(server, error);
 		goto out_error;
-
+	}
 	nfs_server_set_fsinfo(server, &fsinfo);
 	error = bdi_init(&server->backing_dev_info);
 	if (error)
@@ -956,6 +984,7 @@ struct nfs_server *nfs_create_server(con
 	if (!(fattr.valid & NFS_ATTR_FATTR)) {
 		error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr);
 		if (error < 0) {
+			trace_nfs_create_server(server, mntfh, error);
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
 		}
