From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/21] SUNRPC: Add a convenient default for the
	hostname when	calling rpc_create()
Date: Sun, 01 Jul 2007 12:13:22 -0400
Message-ID: <20070701161322.2786.82830.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I524c-0004aG-JN
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:54 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I524f-0004Au-7L
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:58 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

A couple of callers just use a stringified IP address for the rpc client's
hostname.  Move the logic for constructing this into rpc_create(), so it can
be shared.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c    |   13 ++++---------
 fs/nfsd/nfs4callback.c |    6 ------
 net/sunrpc/clnt.c      |   13 +++++++++++++
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 878d7a5..2892ec8 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -28,8 +28,7 @@
 #define MOUNT_UMNT		3
  */
 
-static struct rpc_clnt *	mnt_create(char *, struct sockaddr_in *,
-								int, int);
+static struct rpc_clnt *	mnt_create(struct sockaddr_in *, int, int);
 static struct rpc_program	mnt_program;
 
 struct mnt_fhstatus {
@@ -52,14 +51,12 @@ nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
 		.rpc_argp	= path,
 		.rpc_resp	= &result,
 	};
-	char			hostname[32];
 	int			status;
 
 	dprintk("NFS:      nfs_mount(%08x:%s)\n",
 			(unsigned)ntohl(addr->sin_addr.s_addr), path);
 
-	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr->sin_addr.s_addr));
-	mnt_clnt = mnt_create(hostname, addr, version, protocol);
+	mnt_clnt = mnt_create(addr, version, protocol);
 	if (IS_ERR(mnt_clnt))
 		return PTR_ERR(mnt_clnt);
 
@@ -73,15 +70,13 @@ nfsroot_mount(struct sockaddr_in *addr, char *path, struct nfs_fh *fh,
 	return status < 0? status : (result.status? -EACCES : 0);
 }
 
-static struct rpc_clnt *
-mnt_create(char *hostname, struct sockaddr_in *srvaddr, int version,
-		int protocol)
+static struct rpc_clnt *mnt_create(struct sockaddr_in *srvaddr, int version,
+				   int protocol)
 {
 	struct rpc_create_args args = {
 		.protocol	= protocol,
 		.address	= (struct sockaddr *)srvaddr,
 		.addrsize	= sizeof(*srvaddr),
-		.servername	= hostname,
 		.program	= &mnt_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6b1b487..5443c52 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -394,7 +394,6 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
 	};
-	char clientname[16];
 	int status;
 
 	if (atomic_read(&cb->cb_set))
@@ -417,11 +416,6 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	memset(program->stats, 0, sizeof(cb->cb_stat));
 	program->stats->program = program;
 
-	/* Just here to make some printk's more useful: */
-	snprintf(clientname, sizeof(clientname),
-		"%u.%u.%u.%u", NIPQUAD(addr.sin_addr));
-	args.servername = clientname;
-
 	/* Create RPC client */
 	cb->cb_client = rpc_create(&args);
 	if (IS_ERR(cb->cb_client)) {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e1553cf..dd9cc63 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -234,6 +234,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 {
 	struct rpc_xprt *xprt;
 	struct rpc_clnt *clnt;
+	char servername[20];
 
 	xprt = xprt_create_transport(args->protocol, args->address,
 					args->addrsize, args->timeout);
@@ -241,6 +242,18 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		return (struct rpc_clnt *)xprt;
 
 	/*
+	 * If the caller chooses not to specify a hostname, whip
+	 * up a string representation of the passed-in address.
+	 */
+	if (args->servername == NULL) {
+		struct sockaddr_in *addr =
+					(struct sockaddr_in *) &args->address;
+		sprintf(servername, NIPQUAD_FMT,
+			NIPQUAD(addr->sin_addr.s_addr));
+		args->servername = servername;
+	}
+
+	/*
 	 * By default, kernel RPC client connects from a reserved port.
 	 * CAP_NET_BIND_SERVICE will not be set for unprivileged requesters,
 	 * but it is always enabled for rpciod, which handles the connect


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
