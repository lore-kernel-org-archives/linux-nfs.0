From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH DRAFT 1/1] RPC transport naming with strings
Date: Wed, 12 Sep 2007 21:46:52 -0400
Message-ID: <EXNANE01WwY0VnkB4lt000004f3@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVdpj-0003JF-KK
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 18:49:33 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVdpn-00048N-Pq
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 18:49:36 -0700
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

Here's a DRAFT patch of the changes to use a string instead of
an integer identifier for transport selection, as you suggested.
It's a lot more of a change than I'd like, but frankly it *is* a
better method. This code seems to work, I've only tested it a
little.

The soft spot is how NFS makes its transport settings, because
all it's doing now is passing a name down to the RPC setup. For
example, the default timeouts and retries for TCP vs UDP. Currently,
it knows perfectly what transport it's using, and sets these appropriately.
In two places, in fact - once in super.c in nfs_validate_mount_data(),
and again in client.c in nfs_init_timeout_values(). I've coded some
basics, but I have to think about this some more. The goal is to
need no NFS layer changes to specify a new protocol.

It should merge into my previous changes after #14, but there
might be some conflicts, as I rebased to 2.6.23-rc6 and had to
fix up some NFS_ALL merge issues. I guess Linus pulled some of
your xprt patches from Trond's git, but Trond's git (and NFS_ALL)
isn't merged forward yet.

Thoughts? Thanks.

-----

NFS/SUNRPC: name transport protocols by string

Trial balloon for naming RPC transports with a string, instead of an integer.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 fs/lockd/host.c                 |    2 
 fs/lockd/mon.c                  |    2 
 fs/nfs/client.c                 |   25 +++++-------
 fs/nfs/internal.h               |    4 -
 fs/nfs/mount_clnt.c             |    4 -
 fs/nfs/nfsroot.c                |    3 -
 fs/nfs/super.c                  |   82 +++++++++++-----------------------------
 fs/nfsd/nfs4callback.c          |    3 -
 include/linux/nfs_fs.h          |    2 
 include/linux/sunrpc/clnt.h     |    5 +-
 include/linux/sunrpc/xprt.h     |    3 -
 include/linux/sunrpc/xprtsock.h |    9 ----
 net/sunrpc/clnt.c               |    2 
 net/sunrpc/rpcb_clnt.c          |   17 ++++----
 net/sunrpc/xprt.c               |    6 +-
 net/sunrpc/xprtsock.c           |    2 
 16 files changed, 66 insertions(+), 105 deletions(-)

Index: kernel/include/linux/sunrpc/xprtsock.h
===================================================================
--- kernel.orig/include/linux/sunrpc/xprtsock.h
+++ kernel/include/linux/sunrpc/xprtsock.h
@@ -20,14 +20,9 @@ void		cleanup_socket_xprt(void);
 
 /*
  * RPC transport identifiers for UDP, TCP
- *
- * To preserve compatibility with the historical use of raw IP protocol
- * id's for transport selection, these are specified with the previous
- * values. No such restriction exists for new transports, except that
- * they may not collide with these values (17 and 6, respectively).
  */
-#define XPRT_TRANSPORT_UDP	IPPROTO_UDP
-#define XPRT_TRANSPORT_TCP	IPPROTO_TCP
+#define XPRT_TRANSPORT_UDP	"udp"
+#define XPRT_TRANSPORT_TCP	"tcp"
 
 /*
  * RPC slot table sizes for UDP, TCP transports
Index: kernel/include/linux/sunrpc/xprt.h
===================================================================
--- kernel.orig/include/linux/sunrpc/xprt.h
+++ kernel/include/linux/sunrpc/xprt.h
@@ -187,7 +187,7 @@ struct rpc_xprt {
 };
 
 struct xprt_create {
-	int			ident;		/* XPRT_TRANSPORT identifier */
+	const char		*transport;	/* XPRT_TRANSPORT identifier */
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
@@ -196,7 +196,6 @@ struct xprt_create {
 
 struct xprt_class {
 	struct list_head	list;
-	int			ident;		/* XPRT_TRANSPORT identifier */
 	struct rpc_xprt *	(*setup)(struct xprt_create *);
 	struct module		*owner;
 	char			name[32];
Index: kernel/fs/nfs/internal.h
===================================================================
--- kernel.orig/fs/nfs/internal.h
+++ kernel/fs/nfs/internal.h
@@ -45,7 +45,7 @@ struct nfs_parsed_mount_data {
 		unsigned int		program;
 		unsigned int		version;
 		unsigned short		port;
-		int			protocol;
+		char			transport[8];
 	} mount_server;
 
 	struct {
@@ -53,7 +53,7 @@ struct nfs_parsed_mount_data {
 		char			*hostname;
 		char			*export_path;
 		unsigned int		program;
-		int			protocol;
+		char			transport[8];
 	} nfs_server;
 };
 
Index: kernel/include/linux/sunrpc/clnt.h
===================================================================
--- kernel.orig/include/linux/sunrpc/clnt.h
+++ kernel/include/linux/sunrpc/clnt.h
@@ -95,7 +95,7 @@ struct rpc_procinfo {
 #ifdef __KERNEL__
 
 struct rpc_create_args {
-	int			protocol;
+	const char		*transport;
 	struct sockaddr		*address;
 	size_t			addrsize;
 	struct sockaddr		*saddress;
@@ -123,7 +123,8 @@ void		rpc_shutdown_client(struct rpc_cln
 void		rpc_release_client(struct rpc_clnt *);
 
 int		rpcb_register(u32, u32, int, unsigned short, int *);
-int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
+int		rpcb_getport_sync(struct sockaddr_in *, const char *,
+				  __u32, __u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
Index: kernel/net/sunrpc/clnt.c
===================================================================
--- kernel.orig/net/sunrpc/clnt.c
+++ kernel/net/sunrpc/clnt.c
@@ -235,7 +235,7 @@ struct rpc_clnt *rpc_create(struct rpc_c
 	struct rpc_xprt *xprt;
 	struct rpc_clnt *clnt;
 	struct xprt_create xprtargs = {
-		.ident = args->protocol,
+		.transport = args->transport,
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
Index: kernel/net/sunrpc/rpcb_clnt.c
===================================================================
--- kernel.orig/net/sunrpc/rpcb_clnt.c
+++ kernel/net/sunrpc/rpcb_clnt.c
@@ -162,10 +162,10 @@ static void rpcb_wake_rpcbind_waiters(st
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-					int proto, int version, int privileged)
+			const char *transport, int version, int privileged)
 {
 	struct rpc_create_args args = {
-		.protocol	= proto,
+		.transport	= transport,
 		.address	= srvaddr,
 		.addrsize	= sizeof(struct sockaddr_in),
 		.servername	= hostname,
@@ -248,17 +248,18 @@ int rpcb_register(u32 prog, u32 vers, in
 /**
  * rpcb_getport_sync - obtain the port for an RPC service on a given host
  * @sin: address of remote peer
+ * @transport: RPC transport to use for sending this request
  * @prog: RPC program number to bind
  * @vers: RPC version number to bind
- * @prot: transport protocol to use to make this request
+ * @prot: transport protocol to resolve with this request
  *
  * Called from outside the RPC client in a synchronous task context.
  * Uses default timeout parameters specified by underlying transport.
  *
  * XXX: Needs to support IPv6, and rpcbind versions 3 and 4
  */
-int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
-		      __u32 vers, int prot)
+int rpcb_getport_sync(struct sockaddr_in *sin, const char *transport,
+			__u32 prog, __u32 vers, int prot)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
@@ -279,7 +280,8 @@ int rpcb_getport_sync(struct sockaddr_in
 		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	sprintf(hostname, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
-	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
+	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin,
+				transport, 2, 0);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -368,7 +370,8 @@ void rpcb_getport_async(struct rpc_task 
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __FUNCTION__, bind_version);
 
-	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot,
+	rpcb_clnt = rpcb_create(clnt->cl_server, &addr,
+				rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO),
 				bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
Index: kernel/fs/nfs/super.c
===================================================================
--- kernel.orig/fs/nfs/super.c
+++ kernel/fs/nfs/super.c
@@ -152,19 +152,6 @@ static match_table_t nfs_mount_option_to
 };
 
 enum {
-	Opt_xprt_udp, Opt_xprt_tcp,
-
-	Opt_xprt_err
-};
-
-static match_table_t nfs_xprt_protocol_tokens = {
-	{ Opt_xprt_udp, "udp" },
-	{ Opt_xprt_tcp, "tcp" },
-
-	{ Opt_xprt_err, NULL }
-};
-
-enum {
 	Opt_sec_none, Opt_sec_sys,
 	Opt_sec_krb5, Opt_sec_krb5i, Opt_sec_krb5p,
 	Opt_sec_lkey, Opt_sec_lkeyi, Opt_sec_lkeyp,
@@ -657,15 +644,12 @@ static int nfs_parse_mount_options(char 
 			break;
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
-			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+			strcpy(mnt->nfs_server.transport, XPRT_TRANSPORT_UDP);
 			mnt->timeo = 7;
 			mnt->retrans = 5;
 			break;
 		case Opt_tcp:
-			mnt->flags |= NFS_MOUNT_TCP;
-			mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-			mnt->timeo = 600;
-			mnt->retrans = 2;
+			strcpy(mnt->nfs_server.transport, XPRT_TRANSPORT_TCP);
 			break;
 		case Opt_acl:
 			mnt->flags &= ~NFS_MOUNT_NOACL;
@@ -865,45 +849,23 @@ static int nfs_parse_mount_options(char 
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			token = match_token(string,
-					    nfs_xprt_protocol_tokens, args);
+			strncpy(mnt->nfs_server.transport, string,
+				sizeof mnt->nfs_server.transport - 1);
 			kfree(string);
-
-			switch (token) {
-			case Opt_xprt_udp:
+			if (strcmp(string, XPRT_TRANSPORT_UDP) == 0 &&
+			    mnt->timeo == 600 && mnt->retrans == 2) {
 				mnt->flags &= ~NFS_MOUNT_TCP;
-				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 				mnt->timeo = 7;
 				mnt->retrans = 5;
-				break;
-			case Opt_xprt_tcp:
-				mnt->flags |= NFS_MOUNT_TCP;
-				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-				mnt->timeo = 600;
-				mnt->retrans = 2;
-				break;
-			default:
-				goto out_unrec_xprt;
 			}
 			break;
 		case Opt_mountproto:
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			token = match_token(string,
-					    nfs_xprt_protocol_tokens, args);
+			strncpy(mnt->mount_server.transport, string,
+				sizeof mnt->mount_server.transport - 1);
 			kfree(string);
-
-			switch (token) {
-			case Opt_xprt_udp:
-				mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
-				break;
-			case Opt_xprt_tcp:
-				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
-				break;
-			default:
-				goto out_unrec_xprt;
-			}
 			break;
 		case Opt_addr:
 			string = match_strdup(args);
@@ -949,10 +911,6 @@ out_unrec_vers:
 	printk(KERN_INFO "NFS: unrecognized NFS version number\n");
 	return 0;
 
-out_unrec_xprt:
-	printk(KERN_INFO "NFS: unrecognized transport protocol\n");
-	return 0;
-
 out_unrec_sec:
 	printk(KERN_INFO "NFS: unrecognized security flavor\n");
 	return 0;
@@ -988,9 +946,10 @@ static int nfs_try_mount(struct nfs_pars
 		sin = args->nfs_server.address;
 	if (args->mount_server.port == 0) {
 		status = rpcb_getport_sync(&sin,
+					   args->mount_server.transport,
 					   args->mount_server.program,
 					   args->mount_server.version,
-					   args->mount_server.protocol);
+					   IPPROTO_UDP);
 		if (status < 0)
 			goto out_err;
 		sin.sin_port = htons(status);
@@ -1006,7 +965,7 @@ static int nfs_try_mount(struct nfs_pars
 			   args->nfs_server.hostname,
 			   args->nfs_server.export_path,
 			   args->mount_server.version,
-			   args->mount_server.protocol,
+			   args->mount_server.transport,
 			   root_fh);
 	if (status < 0)
 		goto out_err;
@@ -1058,9 +1017,9 @@ static int nfs_validate_mount_data(void 
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
-	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
+	strcpy(args->mount_server.transport, XPRT_TRANSPORT_UDP);
 	args->mount_server.program = NFS_MNT_PROGRAM;
-	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+	strcpy(args->nfs_server.transport, XPRT_TRANSPORT_TCP);
 	args->nfs_server.program = NFS_PROGRAM;
 
 	switch (data->version) {
@@ -1107,7 +1066,7 @@ static int nfs_validate_mount_data(void 
 		args->acdirmax		= data->acdirmax;
 		args->nfs_server.address = data->addr;
 		if (!(data->flags & NFS_MOUNT_TCP))
-			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+			strcpy(args->nfs_server.transport, XPRT_TRANSPORT_UDP);
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
 		args->namlen		= data->namlen;
@@ -1530,7 +1489,7 @@ static int nfs4_validate_mount_data(void
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
-	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+	strcpy(args->nfs_server.transport, XPRT_TRANSPORT_TCP);
 
 	switch (data->version) {
 	case 1:
@@ -1590,8 +1549,15 @@ static int nfs4_validate_mount_data(void
 		args->acregmax	= data->acregmax;
 		args->acdirmin	= data->acdirmin;
 		args->acdirmax	= data->acdirmax;
-		args->nfs_server.protocol = data->proto;
-
+		switch (data->proto) {
+		case IPPROTO_UDP:	/* Violates RFC3050 */
+			strcpy(args->nfs_server.transport, XPRT_TRANSPORT_UDP);
+			break;
+		default: /* to use other protocols, must use string mount */
+		case IPPROTO_TCP:
+			strcpy(args->nfs_server.transport, XPRT_TRANSPORT_TCP);
+			break;
+		}
 		break;
 	default: {
 		unsigned int len;
Index: kernel/fs/lockd/host.c
===================================================================
--- kernel.orig/fs/lockd/host.c
+++ kernel/fs/lockd/host.c
@@ -233,7 +233,6 @@ nlm_bind_host(struct nlm_host *host)
 			.to_retries	= 5U,
 		};
 		struct rpc_create_args args = {
-			.protocol	= host->h_proto,
 			.address	= (struct sockaddr *)&host->h_addr,
 			.addrsize	= sizeof(host->h_addr),
 			.saddress	= (struct sockaddr *)&host->h_saddr,
@@ -246,6 +245,7 @@ nlm_bind_host(struct nlm_host *host)
 					   RPC_CLNT_CREATE_AUTOBIND),
 		};
 
+		args.transport = rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO);
 		clnt = rpc_create(&args);
 		if (!IS_ERR(clnt))
 			host->h_rpcclnt = clnt;
Index: kernel/fs/nfs/client.c
===================================================================
--- kernel.orig/fs/nfs/client.c
+++ kernel/fs/nfs/client.c
@@ -332,7 +332,7 @@ static void nfs_mark_client_ready(struct
 /*
  * Initialise the timeout values for a connection
  */
-static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
+static void nfs_init_timeout_values(struct rpc_timeout *to, const char *proto,
 				    unsigned int timeo, unsigned int retrans)
 {
 	to->to_initval = timeo * HZ / 10;
@@ -340,8 +340,7 @@ static void nfs_init_timeout_values(stru
 	if (!to->to_retries)
 		to->to_retries = 2;
 
-	switch (proto) {
-	case XPRT_TRANSPORT_TCP:
+	if (strcmp(proto, XPRT_TRANSPORT_TCP) == 0) {
 		if (!to->to_initval)
 			to->to_initval = 60 * HZ;
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
@@ -349,23 +348,20 @@ static void nfs_init_timeout_values(stru
 		to->to_increment = to->to_initval;
 		to->to_maxval = to->to_initval + (to->to_increment * to->to_retries);
 		to->to_exponential = 0;
-		break;
-	case XPRT_TRANSPORT_UDP:
-	default:
+	} else {			/* XPRT_TRANSPORT_UDP or other */
 		if (!to->to_initval)
 			to->to_initval = 11 * HZ / 10;
 		if (to->to_initval > NFS_MAX_UDP_TIMEOUT)
 			to->to_initval = NFS_MAX_UDP_TIMEOUT;
 		to->to_maxval = NFS_MAX_UDP_TIMEOUT;
 		to->to_exponential = 1;
-		break;
 	}
 }
 
 /*
  * Create an RPC client handle
  */
-static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
+static int nfs_create_rpc_client(struct nfs_client *clp, const char *proto,
 						unsigned int timeo,
 						unsigned int retrans,
 						rpc_authflavor_t flavor,
@@ -374,7 +370,7 @@ static int nfs_create_rpc_client(struct 
 	struct rpc_timeout	timeparms;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
-		.protocol	= proto,
+		.transport	= proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= sizeof(clp->cl_addr),
 		.timeout	= &timeparms,
@@ -523,7 +519,7 @@ static int nfs_init_client(struct nfs_cl
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
-	error = nfs_create_rpc_client(clp, data->nfs_server.protocol,
+	error = nfs_create_rpc_client(clp, data->nfs_server.transport,
 				data->timeo, data->retrans, RPC_AUTH_UNIX, 0);
 	if (error < 0)
 		goto error;
@@ -832,7 +828,7 @@ error:
  * Initialise an NFS4 client record
  */
 static int nfs4_init_client(struct nfs_client *clp,
-		int proto, int timeo, int retrans,
+		const char *proto, int timeo, int retrans,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour)
 {
@@ -877,7 +873,7 @@ static int nfs4_set_client(struct nfs_se
 		const char *hostname, const struct sockaddr_in *addr,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
-		int proto, int timeo, int retrans)
+		const char *proto, int timeo, int retrans)
 {
 	struct nfs_client *clp;
 	int error;
@@ -959,7 +955,7 @@ struct nfs_server *nfs4_create_server(co
 			&data->nfs_server.address,
 			data->client_address,
 			data->auth_flavors[0],
-			data->nfs_server.protocol,
+			data->nfs_server.transport,
 			data->timeo, data->retrans);
 	if (error < 0)
 		goto error;
@@ -1031,7 +1027,8 @@ struct nfs_server *nfs4_create_referral_
 	error = nfs4_set_client(server, data->hostname, data->addr,
 			parent_client->cl_ipaddr,
 			data->authflavor,
-			parent_server->client->cl_xprt->prot,
+			rpc_peeraddr2str(parent_server->client,
+					 RPC_DISPLAY_PROTO),
 			parent_client->retrans_timeo,
 			parent_client->retrans_count);
 	if (error < 0)
Index: kernel/net/sunrpc/xprt.c
===================================================================
--- kernel.orig/net/sunrpc/xprt.c
+++ kernel/net/sunrpc/xprt.c
@@ -104,7 +104,7 @@ int xprt_register_transport(struct xprt_
 	spin_lock(&xprt_list_lock);
 	list_for_each_entry(t, &xprt_list, list) {
 		/* don't register the same transport class twice */
-		if (t->ident == transport->ident)
+		if (strcmp(t->name, transport->name) == 0)
 			goto out;
 	}
 
@@ -987,13 +987,13 @@ struct rpc_xprt *xprt_create_transport(s
 
 	spin_lock(&xprt_list_lock);
 	list_for_each_entry(t, &xprt_list, list) {
-		if (t->ident == args->ident) {
+		if (strcmp(t->name, args->transport) == 0) {
 			spin_unlock(&xprt_list_lock);
 			goto found;
 		}
 	}
 	spin_unlock(&xprt_list_lock);
-	printk(KERN_ERR "RPC: transport (%d) not supported\n", args->ident);
+	printk(KERN_ERR "RPC: transport (%s) not supported\n", args->transport);
 	return ERR_PTR(-EIO);
 
 found:
Index: kernel/fs/lockd/mon.c
===================================================================
--- kernel.orig/fs/lockd/mon.c
+++ kernel/fs/lockd/mon.c
@@ -133,7 +133,7 @@ nsm_create(void)
 		.sin_port	= 0,
 	};
 	struct rpc_create_args args = {
-		.protocol	= XPRT_TRANSPORT_UDP,
+		.transport	= XPRT_TRANSPORT_UDP,
 		.address	= (struct sockaddr *)&sin,
 		.addrsize	= sizeof(sin),
 		.servername	= "localhost",
Index: kernel/net/sunrpc/xprtsock.c
===================================================================
--- kernel.orig/net/sunrpc/xprtsock.c
+++ kernel/net/sunrpc/xprtsock.c
@@ -1955,7 +1955,6 @@ static struct xprt_class	xs_udp_transpor
 	.list		= LIST_HEAD_INIT(xs_udp_transport.list),
 	.name		= "udp",
 	.owner		= THIS_MODULE,
-	.ident		= IPPROTO_UDP,
 	.setup		= xs_setup_udp,
 };
 
@@ -1963,7 +1962,6 @@ static struct xprt_class	xs_tcp_transpor
 	.list		= LIST_HEAD_INIT(xs_tcp_transport.list),
 	.name		= "tcp",
 	.owner		= THIS_MODULE,
-	.ident		= IPPROTO_TCP,
 	.setup		= xs_setup_tcp,
 };
 
Index: kernel/fs/nfs/mount_clnt.c
===================================================================
--- kernel.orig/fs/nfs/mount_clnt.c
+++ kernel/fs/nfs/mount_clnt.c
@@ -39,7 +39,7 @@ struct mnt_fhstatus {
  * Uses default timeout parameters specified by underlying transport.
  */
 int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
-	      int version, int protocol, struct nfs_fh *fh)
+	      int version, char *protocol, struct nfs_fh *fh)
 {
 	struct mnt_fhstatus	result = {
 		.fh		= fh
@@ -49,7 +49,7 @@ int nfs_mount(struct sockaddr *addr, siz
 		.rpc_resp	= &result,
 	};
 	struct rpc_create_args args = {
-		.protocol	= protocol,
+		.transport	= protocol,
 		.address	= addr,
 		.addrsize	= len,
 		.servername	= hostname,
Index: kernel/fs/nfsd/nfs4callback.c
===================================================================
--- kernel.orig/fs/nfsd/nfs4callback.c
+++ kernel/fs/nfsd/nfs4callback.c
@@ -42,6 +42,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprtsock.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/state.h>
 #include <linux/sunrpc/sched.h>
@@ -381,7 +382,7 @@ nfsd4_probe_callback(struct nfs4_client 
 	};
 	struct rpc_program *	program = &cb->cb_program;
 	struct rpc_create_args args = {
-		.protocol	= IPPROTO_TCP,
+		.transport	= XPRT_TRANSPORT_TCP,
 		.address	= (struct sockaddr *)&addr,
 		.addrsize	= sizeof(addr),
 		.timeout	= &timeparms,
Index: kernel/include/linux/nfs_fs.h
===================================================================
--- kernel.orig/include/linux/nfs_fs.h
+++ kernel/include/linux/nfs_fs.h
@@ -501,7 +501,7 @@ static inline void nfs3_forget_cached_ac
  * linux/fs/mount_clnt.c
  */
 extern int  nfs_mount(struct sockaddr *, size_t, char *, char *,
-		      int, int, struct nfs_fh *);
+		      int, char *, struct nfs_fh *);
 
 /*
  * inline functions
Index: kernel/fs/nfs/nfsroot.c
===================================================================
--- kernel.orig/fs/nfs/nfsroot.c
+++ kernel/fs/nfs/nfsroot.c
@@ -429,7 +429,8 @@ static int __init root_nfs_getport(int p
 	printk(KERN_NOTICE "Looking up port of RPC %d/%d on %u.%u.%u.%u\n",
 		program, version, NIPQUAD(servaddr));
 	set_sockaddr(&sin, servaddr, 0);
-	return rpcb_getport_sync(&sin, program, version, proto);
+	return rpcb_getport_sync(&sin, XPRT_TRANSPORT_UDP,
+				 program, version, proto);
 }
 
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
