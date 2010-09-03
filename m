Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37801 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab0ICSzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 14:55:25 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o83ItOeE016792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 3 Sep 2010 11:55:24 -0700
Message-ID: <4C81449B.4010900@candelatech.com>
Date: Fri, 03 Sep 2010 11:55:23 -0700
From: Ben Greear <greearb@candelatech.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RFC:  support srcaddr= option to bind to local IPs.
Content-Type: multipart/mixed;
 boundary="------------090505020904030503080105"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------090505020904030503080105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch lets one bind the local side of NFS sockets to a particular
IP address.  This can be useful for users on multi-homed systems.

This patch must be on top of the previous patch to fix the IPv6 address
comparison or it will not work.

Comments and suggestions welcome...I'll incorporate those and post an
official signed-off patch after that.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------090505020904030503080105
Content-Type: text/plain;
 name="nfs_srcaddr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs_srcaddr.patch"

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
index e17b49e..985a700 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -353,7 +353,7 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 	int ret = SVC_OK;
 
 	/* Don't talk to strangers */
-	clp = nfs_find_client(svc_addr(rqstp), 4);
+	clp = nfs_find_client(svc_daddr(rqstp), true, svc_addr(rqstp), 4);
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
index 930d10f..7a7b0d4 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -26,7 +26,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client(args->srcaddr, true, args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
@@ -69,7 +69,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client(args->srcaddr, true, args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
@@ -197,8 +197,15 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	struct nfs4_sessionid *sessionid)
 {
 	struct nfs_client *clp;
+	/* This would be the IP (if any) that we are bound
+	 * to locally.  Since session-id appears to be unique,
+	 * we'll just ignore the bind-addr and match directly on
+	 * session-id.
+	 */
+	struct sockaddr_storage srcaddr;
+	memset(&srcaddr, 0, sizeof(srcaddr));
 
-	clp = nfs_find_client(addr, 4);
+	clp = nfs_find_client((struct sockaddr *)&srcaddr, false, addr, 4);
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
index e734072..d9e8d53 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -101,6 +101,7 @@ struct rpc_program		nfsacl_program = {
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr *addr;
+	const struct sockaddr *srcaddr;
 	size_t addrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 	int proto;
@@ -129,6 +130,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
 	clp->cl_addrlen = cl_init->addrlen;
+	memcpy(&clp->srcaddr, cl_init->srcaddr, cl_init->addrlen);
 
 	if (cl_init->hostname) {
 		err = -ENOMEM;
@@ -336,6 +338,8 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
 	case AF_INET6:
 		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
+	case AF_UNSPEC:
+		return 1; /* two UNSPEC addresses match */
 	}
 	return 0;
 }
@@ -363,7 +367,9 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
+struct nfs_client *nfs_find_client(const struct sockaddr *srcaddr,
+				   bool compare_srcaddr,
+				   const struct sockaddr *addr, u32 nfsversion)
 {
 	struct nfs_client *clp;
 
@@ -380,7 +386,14 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
-		/* Match only the IP address, not the port number */
+		if (compare_srcaddr) {
+			/* Match only the IP address, not the port number */
+			const struct sockaddr *sa;
+			sa = (const struct sockaddr *)&clp->srcaddr;
+			if (!nfs_sockaddr_match_ipaddr(srcaddr, sa))
+				continue;
+		}
+
 		if (!nfs_sockaddr_match_ipaddr(addr, clap))
 			continue;
 
@@ -399,11 +412,14 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
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
@@ -417,6 +433,12 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
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
@@ -436,6 +458,8 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
 	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+		const struct sockaddr *sa;
+		sa = (const struct sockaddr *)&clp->srcaddr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -446,9 +470,17 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 		if (clp->cl_proto != data->proto)
 			continue;
+
+		/* Check to make sure local-IP bindings match,
+		 * but just the IP-addr.
+		 */
+		if (!nfs_sockaddr_match_ipaddr(sa, data->srcaddr))
+			continue;
+
 		/* Match nfsv4 minorversion */
 		if (clp->cl_minorversion != data->minorversion)
 			continue;
+
 		/* Match the full socket address */
 		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
@@ -494,7 +526,6 @@ install_client:
 	clp = new;
 	list_add(&clp->cl_share_link, &nfs_client_list);
 	spin_unlock(&nfs_client_lock);
-	dprintk("--> nfs_get_client() = %p [new]\n", clp);
 	return clp;
 
 	/* found an existing client
@@ -602,6 +633,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
 		.protocol	= clp->cl_proto,
+		.saddress	= (struct sockaddr *)&clp->srcaddr,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
 		.timeout	= timeparms,
@@ -649,6 +681,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 	struct nlmclnt_initdata nlm_init = {
 		.hostname	= clp->cl_hostname,
 		.address	= (struct sockaddr *)&clp->cl_addr,
+		.srcaddr	= (struct sockaddr *)&clp->srcaddr,
 		.addrlen	= clp->cl_addrlen,
 		.nfs_version	= clp->rpc_ops->version,
 		.noresvport	= server->flags & NFS_MOUNT_NORESVPORT ?
@@ -785,6 +818,7 @@ static int nfs_init_server(struct nfs_server *server,
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
+		.srcaddr = (const struct sockaddr *)&data->srcaddr.address,
 		.rpc_ops = &nfs_v2_clientops,
 		.proto = data->nfs_server.protocol,
 	};
@@ -1226,6 +1260,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		const struct sockaddr *addr,
 		const size_t addrlen,
 		const char *ip_addr,
+		const struct sockaddr *srcaddr,
 		rpc_authflavor_t authflavour,
 		int proto, const struct rpc_timeout *timeparms,
 		u32 minorversion)
@@ -1234,6 +1269,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		.hostname = hostname,
 		.addr = addr,
 		.addrlen = addrlen,
+		.srcaddr = srcaddr,
 		.rpc_ops = &nfs_v4_clientops,
 		.proto = proto,
 		.minorversion = minorversion,
@@ -1366,6 +1402,7 @@ static int nfs4_init_server(struct nfs_server *server,
 			(const struct sockaddr *)&data->nfs_server.address,
 			data->nfs_server.addrlen,
 			data->client_address,
+			(const struct sockaddr *)&data->srcaddr.address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
 			&timeparms,
@@ -1456,6 +1493,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addr,
 				data->addrlen,
 				parent_client->cl_ipaddr,
+				(const struct sockaddr *)&parent_client->srcaddr,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
 				parent_server->client->cl_timeout,
@@ -1654,19 +1692,32 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 
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
index c961bc9..ac7a47f 100644
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
@@ -123,7 +129,9 @@ extern void nfs_umount(const struct nfs_mount_request *info);
 extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
-extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32);
+extern struct nfs_client *nfs_find_client(const struct sockaddr *srcaddr,
+					  bool compare_srcaddr,
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
index c82ee7c..b65a632 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -84,6 +84,9 @@ struct nfs_client {
 	struct nfs4_session	*cl_session; 	/* sharred session */
 #endif /* CONFIG_NFS_V4_1 */
 
+	/* If we should bind to a local IP, it should be specified below. */
+	struct sockaddr_storage	srcaddr;
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

--------------090505020904030503080105--
