Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51208 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042Ab0IHAfu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 20:35:50 -0400
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [nfs] nfs:  Support srcaddr= to bind to specific IP address.
Date: Tue,  7 Sep 2010 17:35:38 -0700
Message-Id: <1283906138-5086-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

In order to have more control on multi-homed machines, it is
nice to be able to bind to a specific IP address.  This can aid
with interface selection, policy based routing, multiple unique
mounts to the same server, and similar things.

This patch allows srcaddr= option for NFS.  The key 'srcaddr'
was chosen to match the similar patch for cifs.

For NFSv4, if one is specifying clientaddr, it must be the same as
srcaddr or things may not work properly.

NFSv3, NFSv4 over TCP/IPv4 and TCP/IPv6 has been successfully tested.

Usage:
  mount -t nfs4 [2002::1]:/rpool/ben /mnt/foo/ben-1 -o srcaddr=2002::2,clientaddr=2002::2
  mount -t nfs4 192.168.100.3:/foo /mnt/foo/ben-2 -o srcaddr=192.168.100.174

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 64fd427... 4d3f3f7... M	fs/lockd/clntlock.c
:100644 100644 bb464d1210... e0bbea9... M	fs/lockd/host.c
:100644 100644 e17b49e... 2fd22ac... M	fs/nfs/callback.c
:100644 100644 85a7cfd... c86300b... M	fs/nfs/callback.h
:100644 100644 930d10f... aa90e7e... M	fs/nfs/callback_proc.c
:100644 100644 05af212... ad422f3... M	fs/nfs/callback_xdr.c
:100644 100644 4e7df2a... 13284f7... M	fs/nfs/client.c
:100644 100644 c961bc9... 126201f... M	fs/nfs/internal.h
:100644 100644 59047f8... 91d2922... M	fs/nfs/mount_clnt.c
:100644 100644 ec3966e... dc31cb3... M	fs/nfs/super.c
:100644 100644 fbc48f8... 94b1cd0... M	include/linux/lockd/bind.h
:100644 100644 a34dea4... 1a58107... M	include/linux/lockd/lockd.h
:100644 100644 c82ee7c... 1183695... M	include/linux/nfs_fs_sb.h
:100644 100644 5a3085b... 7c836e7... M	include/linux/sunrpc/svc.h
 fs/lockd/clntlock.c         |    3 +-
 fs/lockd/host.c             |    8 ++---
 fs/nfs/callback.c           |    2 +-
 fs/nfs/callback.h           |    2 +
 fs/nfs/callback_proc.c      |    6 ++--
 fs/nfs/callback_xdr.c       |    2 +
 fs/nfs/client.c             |   79 ++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h           |    9 ++++-
 fs/nfs/mount_clnt.c         |    1 +
 fs/nfs/super.c              |   31 ++++++++++++++++-
 include/linux/lockd/bind.h  |    1 +
 include/linux/lockd/lockd.h |    1 +
 include/linux/nfs_fs_sb.h   |    4 ++
 include/linux/sunrpc/svc.h  |    5 +++
 14 files changed, 138 insertions(+), 16 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 64fd427..4d3f3f7 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -60,7 +60,8 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	if (status < 0)
 		return ERR_PTR(status);
 
-	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
+	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->srcaddr,
+				   nlm_init->addrlen,
 				   nlm_init->protocol, nlm_version,
 				   nlm_init->hostname, nlm_init->noresvport);
 	if (host == NULL) {
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index bb464d1..e0bbea9 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -232,15 +232,13 @@ nlm_destroy_host(struct nlm_host *host)
  * created and returned.
  */
 struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
+				     const struct sockaddr *srcaddr,
 				     const size_t salen,
 				     const unsigned short protocol,
 				     const u32 version,
 				     const char *hostname,
 				     int noresvport)
 {
-	const struct sockaddr source = {
-		.sa_family	= AF_UNSPEC,
-	};
 	struct nlm_lookup_host_info ni = {
 		.server		= 0,
 		.sap		= sap,
@@ -249,8 +247,8 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.version	= version,
 		.hostname	= hostname,
 		.hostname_len	= strlen(hostname),
-		.src_sap	= &source,
-		.src_len	= sizeof(source),
+		.src_sap	= srcaddr,
+		.src_len	= salen,
 		.noresvport	= noresvport,
 	};
 
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e17b49e..2fd22ac 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -353,7 +353,7 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 	int ret = SVC_OK;
 
 	/* Don't talk to strangers */
-	clp = nfs_find_client(svc_addr(rqstp), 4);
+	clp = nfs_find_client(svc_daddr(rqstp), svc_addr(rqstp), 4);
 	if (clp == NULL)
 		return SVC_DROP;
 
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 85a7cfd..c86300b 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -50,6 +50,7 @@ struct cb_compound_hdr_res {
 
 struct cb_getattrargs {
 	struct sockaddr *addr;
+	struct sockaddr *srcaddr;
 	struct nfs_fh fh;
 	uint32_t bitmap[2];
 };
@@ -65,6 +66,7 @@ struct cb_getattrres {
 
 struct cb_recallargs {
 	struct sockaddr *addr;
+	struct sockaddr *srcaddr;
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	uint32_t truncate;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 930d10f..aa90e7e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -26,7 +26,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client(args->srcaddr, args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
@@ -69,7 +69,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client(args->srcaddr, args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
@@ -198,7 +198,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 {
 	struct nfs_client *clp;
 
-	clp = nfs_find_client(addr, 4);
+	clp = nfs_find_client(NULL, addr, 4);
 	if (clp == NULL)
 		return NULL;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 05af212..ad422f3 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -191,6 +191,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	if (unlikely(status != 0))
 		goto out;
 	args->addr = svc_addr(rqstp);
+	args->srcaddr = svc_daddr(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
@@ -203,6 +204,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 status;
 
 	args->addr = svc_addr(rqstp);
+	args->srcaddr = svc_daddr(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4e7df2a..13284f7 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -101,7 +101,9 @@ struct rpc_program		nfsacl_program = {
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr *addr;
+	const struct sockaddr *srcaddr;
 	size_t addrlen;
+	size_t srcaddrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 	int proto;
 	u32 minorversion;
@@ -129,6 +131,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
 	clp->cl_addrlen = cl_init->addrlen;
+	memcpy(&clp->srcaddr, cl_init->srcaddr, cl_init->srcaddrlen);
 
 	if (cl_init->hostname) {
 		err = -ENOMEM;
@@ -275,7 +278,7 @@ static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
 	    sin1->sin6_scope_id != sin2->sin6_scope_id)
 		return 0;
 
-	return ipv6_addr_equal(&sin1->sin6_addr, &sin1->sin6_addr);
+	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
 }
 #else	/* !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE) */
 static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
@@ -336,6 +339,8 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
 	case AF_INET6:
 		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
+	case AF_UNSPEC:
+		return 1; /* two UNSPEC addresses match */
 	}
 	return 0;
 }
@@ -363,9 +368,11 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
+struct nfs_client *nfs_find_client(const struct sockaddr *srcaddr,
+				   const struct sockaddr *addr, u32 nfsversion)
 {
 	struct nfs_client *clp;
+	struct nfs_client *ok_fit = NULL;
 
 	spin_lock(&nfs_client_lock);
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
@@ -384,10 +391,30 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 		if (!nfs_sockaddr_match_ipaddr(addr, clap))
 			continue;
 
+		if (srcaddr) {
+			const struct sockaddr *sa;
+			sa = (const struct sockaddr *)&clp->cl_addr;
+			if (!nfs_sockaddr_match_ipaddr(srcaddr, sa)) {
+				/* If clp doesn't bind to srcaddr, then
+				 * it is a potential match if we don't find
+				 * a better one.
+				 */
+				if (sa->sa_family == AF_UNSPEC && !ok_fit)
+					ok_fit = clp;
+				continue;
+			}
+		}
+found_one:
 		atomic_inc(&clp->cl_count);
 		spin_unlock(&nfs_client_lock);
 		return clp;
 	}
+
+	if (ok_fit) {
+		clp = ok_fit;
+		goto found_one;
+	}
+
 	spin_unlock(&nfs_client_lock);
 	return NULL;
 }
@@ -399,11 +426,14 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 {
 	struct sockaddr *sap = (struct sockaddr *)&clp->cl_addr;
+	struct sockaddr *srcap = (struct sockaddr *)&clp->srcaddr;
 	u32 nfsvers = clp->rpc_ops->version;
 
 	spin_lock(&nfs_client_lock);
 	list_for_each_entry_continue(clp, &nfs_client_list, cl_share_link) {
 		struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+		const struct sockaddr *sa;
+		sa = (const struct sockaddr *)&clp->srcaddr;
 
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state != NFS_CS_READY)
@@ -417,6 +447,12 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 		if (!nfs_sockaddr_match_ipaddr(sap, clap))
 			continue;
 
+		/* Check to make sure local-IP bindings match,
+		 * but just the IP-addr.
+		 */
+		if (!nfs_sockaddr_match_ipaddr(srcap, sa))
+			continue;
+
 		atomic_inc(&clp->cl_count);
 		spin_unlock(&nfs_client_lock);
 		return clp;
@@ -436,6 +472,8 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
 	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+		const struct sockaddr *sa;
+		sa = (const struct sockaddr *)&clp->srcaddr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -446,9 +484,17 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 		if (clp->cl_proto != data->proto)
 			continue;
+
+		/* Check to make sure local-IP bindings match,
+		 * but just the IP-addr.
+		 */
+		if (!nfs_sockaddr_match_ipaddr(data->srcaddr, sa))
+			continue;
+
 		/* Match nfsv4 minorversion */
 		if (clp->cl_minorversion != data->minorversion)
 			continue;
+
 		/* Match the full socket address */
 		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
@@ -602,6 +648,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
 		.protocol	= clp->cl_proto,
+		.saddress	= (struct sockaddr *)&clp->srcaddr,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
 		.timeout	= timeparms,
@@ -649,6 +696,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 	struct nlmclnt_initdata nlm_init = {
 		.hostname	= clp->cl_hostname,
 		.address	= (struct sockaddr *)&clp->cl_addr,
+		.srcaddr	= (struct sockaddr *)&clp->srcaddr,
 		.addrlen	= clp->cl_addrlen,
 		.nfs_version	= clp->rpc_ops->version,
 		.noresvport	= server->flags & NFS_MOUNT_NORESVPORT ?
@@ -785,6 +833,8 @@ static int nfs_init_server(struct nfs_server *server,
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
+		.srcaddr = (const struct sockaddr *)&data->srcaddr.address,
+		.srcaddrlen = data->srcaddr.addrlen,
 		.rpc_ops = &nfs_v2_clientops,
 		.proto = data->nfs_server.protocol,
 	};
@@ -1226,6 +1276,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		const struct sockaddr *addr,
 		const size_t addrlen,
 		const char *ip_addr,
+		const struct sockaddr *srcaddr,
+		const size_t srcaddrlen,
 		rpc_authflavor_t authflavour,
 		int proto, const struct rpc_timeout *timeparms,
 		u32 minorversion)
@@ -1234,6 +1286,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		.hostname = hostname,
 		.addr = addr,
 		.addrlen = addrlen,
+		.srcaddr = srcaddr,
+		.srcaddrlen = srcaddrlen,
 		.rpc_ops = &nfs_v4_clientops,
 		.proto = proto,
 		.minorversion = minorversion,
@@ -1366,6 +1420,8 @@ static int nfs4_init_server(struct nfs_server *server,
 			(const struct sockaddr *)&data->nfs_server.address,
 			data->nfs_server.addrlen,
 			data->client_address,
+			(const struct sockaddr *)&data->srcaddr.address,
+			data->srcaddr.addrlen,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
 			&timeparms,
@@ -1456,6 +1512,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addr,
 				data->addrlen,
 				parent_client->cl_ipaddr,
+				(const struct sockaddr *)&parent_client->srcaddr,
+				parent_client->srcaddrlen,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
 				parent_server->client->cl_timeout,
@@ -1654,19 +1712,32 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 
 	/* display header on line 1 */
 	if (v == &nfs_client_list) {
-		seq_puts(m, "NV SERVER   PORT USE HOSTNAME\n");
+		seq_puts(m, "NV SERVER   PORT USE HOSTNAME"
+			 "           SRCADDR\n");
 		return 0;
 	}
 
 	/* display one transport per line on subsequent lines */
 	clp = list_entry(v, struct nfs_client, cl_share_link);
 
-	seq_printf(m, "v%u %s %s %3d %s\n",
+	seq_printf(m, "v%u %s %s %3d %s",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
 		   atomic_read(&clp->cl_count),
 		   clp->cl_hostname);
+	if (clp->srcaddr.ss_family == AF_INET) {
+		const struct sockaddr_in *sin;
+		sin = (const struct sockaddr_in *)&clp->srcaddr;
+		seq_printf(m, "   %pI4\n", &sin->sin_addr.s_addr);
+	} else if (clp->srcaddr.ss_family == AF_INET6) {
+		const struct sockaddr_in6 *sin6;
+		sin6 = (const struct sockaddr_in6 *)&clp->srcaddr;
+		seq_printf(m, "   %pI6c\n", &sin6->sin6_addr);
+	} else if (clp->srcaddr.ss_family == AF_UNSPEC)
+		seq_printf(m, "   ANY\n");
+	else
+		seq_printf(m, "   UNKNOWN_%i\n", (int)(clp->srcaddr.ss_family));
 
 	return 0;
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c961bc9..126201f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -84,6 +84,11 @@ struct nfs_parsed_mount_data {
 	struct {
 		struct sockaddr_storage	address;
 		size_t			addrlen;
+	} srcaddr;
+
+	struct {
+		struct sockaddr_storage	address;
+		size_t			addrlen;
 		char			*hostname;
 		u32			version;
 		int			port;
@@ -105,6 +110,7 @@ struct nfs_parsed_mount_data {
 /* mount_clnt.c */
 struct nfs_mount_request {
 	struct sockaddr		*sap;
+	struct sockaddr		*srcaddr;
 	size_t			salen;
 	char			*hostname;
 	char			*dirpath;
@@ -123,7 +129,8 @@ extern void nfs_umount(const struct nfs_mount_request *info);
 extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
-extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32);
+extern struct nfs_client *nfs_find_client(const struct sockaddr *srcaddr,
+					  const struct sockaddr *, u32);
 extern struct nfs_client *nfs_find_client_next(struct nfs_client *);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 59047f8..91d2922 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -154,6 +154,7 @@ int nfs_mount(struct nfs_mount_request *info)
 	};
 	struct rpc_create_args args = {
 		.protocol	= info->protocol,
+		.saddress	= info->srcaddr,
 		.address	= info->sap,
 		.addrsize	= info->salen,
 		.servername	= info->hostname,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ec3966e..dc31cb3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -97,7 +97,7 @@ enum {
 
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
-	Opt_addr, Opt_mountaddr, Opt_clientaddr,
+	Opt_addr, Opt_mountaddr, Opt_clientaddr, Opt_srcaddr,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
 
@@ -166,6 +166,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountproto, "mountproto=%s" },
 	{ Opt_addr, "addr=%s" },
 	{ Opt_clientaddr, "clientaddr=%s" },
+	{ Opt_srcaddr, "srcaddr=%s" },
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
@@ -653,6 +654,15 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	else
 		nfs_show_nfsv4_options(m, nfss, showdefaults);
 
+	if (clp->srcaddr.ss_family == AF_INET6) {
+		struct sockaddr_in6 *sin6;
+		sin6 = (struct sockaddr_in6 *)(&clp->srcaddr);
+		seq_printf(m, ",srcaddr=%pI6c", &sin6->sin6_addr);
+	} else if (clp->srcaddr.ss_family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&clp->srcaddr;
+		seq_printf(m, ",srcaddr=%pI4", &sin->sin_addr.s_addr);
+	}
+
 	if (nfss->options & NFS_OPTION_FSCACHE)
 		seq_printf(m, ",fsc");
 
@@ -1360,6 +1370,23 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(mnt->client_address);
 			mnt->client_address = string;
 			break;
+		case Opt_srcaddr:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			mnt->srcaddr.addrlen =
+				rpc_pton(string, strlen(string),
+					 (struct sockaddr *)
+					 &mnt->srcaddr.address,
+					 sizeof(mnt->srcaddr.address));
+			kfree(string);
+			if (mnt->srcaddr.addrlen == 0) {
+				printk(KERN_WARNING
+				       "nfs: Could not parse srcaddr: %s\n",
+				       string);
+				goto out_invalid_address;
+			}
+			break;
 		case Opt_mounthost:
 			string = match_strdup(args);
 			if (string == NULL)
@@ -1536,6 +1563,8 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)
 						&args->mount_server.address,
+		.srcaddr	= (struct sockaddr *)&args->srcaddr.address,
+		.salen		= args->mount_server.addrlen,
 		.dirpath	= args->nfs_server.export_path,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index fbc48f8..94b1cd0 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -38,6 +38,7 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
 struct nlmclnt_initdata {
 	const char		*hostname;
 	const struct sockaddr	*address;
+	const struct sockaddr	*srcaddr;
 	size_t			addrlen;
 	unsigned short		protocol;
 	u32			nfs_version;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a34dea4..1a58107 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -217,6 +217,7 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
  * Host cache
  */
 struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
+					const struct sockaddr *bindaddr,
 					const size_t salen,
 					const unsigned short protocol,
 					const u32 version,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c82ee7c..1183695 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -84,6 +84,10 @@ struct nfs_client {
 	struct nfs4_session	*cl_session; 	/* sharred session */
 #endif /* CONFIG_NFS_V4_1 */
 
+	/* If we should bind to a local IP, it should be specified below. */
+	struct sockaddr_storage	srcaddr;
+	size_t			srcaddrlen;
+
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..7c836e7 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -298,6 +298,11 @@ static inline struct sockaddr *svc_addr(const struct svc_rqst *rqst)
 	return (struct sockaddr *) &rqst->rq_addr;
 }
 
+static inline struct sockaddr *svc_daddr(struct svc_rqst *rqst)
+{
+	return (struct sockaddr *) &rqst->rq_daddr;
+}
+
 /*
  * Check buffer bounds after decoding arguments
  */
-- 
1.6.2.5

