From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/11] lockd: Allow mount option to specify caller_name
Date: Thu, 01 Apr 2010 15:04:00 -0400
Message-ID: <20100401190400.6395.52787.stgit@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:19740 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758053Ab0DATED (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:04:03 -0400
Received: by qw-out-2122.google.com with SMTP id 8so489766qwh.37
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:04:02 -0700 (PDT)
In-Reply-To: <20100401183724.6395.60353.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NLMPROC_LOCK requests have a "caller_name" argument which is supposed
to contain the hostname the server uses to call the client back.
Linux simply stuffs the system's utsname in this field, but this is
not always the correct choice.  For example:

  o  If an unqualified hostname is used for the client's utsname,
     it could be ambiguous when the server tries to resolve it
  o  If the client's actual hostname is determined by DHCP, it may
     not match its utsname
  o  If the NFS mount was done in a network namespace, the namespace
     name won't match the client's utsname
  o  If the client has multiple network interfaces, it should provide
     a hostname that matches the source address used to contact the
     server

In all of these cases, user space can determine the correct value of
the caller_name argument at mount time.

So, add a mount option that allows user space to specify the value of
the caller_name argument of NLMPROC_LOCK requests.  If not specified,
the kernel continues to use the init utsname, as before.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c         |    3 ++-
 fs/lockd/host.c             |    7 ++++++-
 fs/nfs/client.c             |   11 +++++++++++
 fs/nfs/internal.h           |    1 +
 fs/nfs/super.c              |    9 +++++++++
 include/linux/lockd/bind.h  |    1 +
 include/linux/lockd/lockd.h |    1 +
 include/linux/nfs_fs_sb.h   |    5 +++++
 8 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index fc9032d..0a0d98a 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -61,7 +61,8 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 
 	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
 				   nlm_init->protocol, nlm_version,
-				   nlm_init->hostname, nlm_init->noresvport);
+				   nlm_init->myname, nlm_init->hostname,
+				   nlm_init->noresvport);
 	if (host == NULL) {
 		lockd_down();
 		return ERR_PTR(-ENOLCK);
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 7d3cd2e..c23bf0d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -39,6 +39,7 @@ struct nlm_lookup_host_info {
 	const size_t		salen;		/* it's length */
 	const unsigned short	protocol;	/* transport to search for*/
 	const u32		version;	/* NLM version to search for */
+	const char		*my_name;	/* local hostname */
 	const char		*hostname;	/* remote's hostname */
 	const size_t		hostname_len;	/* it's length */
 	const struct sockaddr	*src_sap;	/* our address (optional) */
@@ -366,7 +367,8 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	else {
 		host = NULL;
 		nsm = nsm_get_handle(ni->sap, ni->salen,
-				ni->hostname, ni->hostname_len, NULL);
+				ni->hostname, ni->hostname_len,
+				ni->my_name);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
@@ -453,6 +455,7 @@ static void nlm_kobj_release(struct kobject *kobj)
  * @protocol: transport protocol to use
  * @version: NLM protocol version
  * @hostname: '\0'-terminated hostname of server
+ * @myname: '\0'-terminated hostname of local system
  * @noresvport: 1 if non-privileged port should be used
  *
  * Returns an nlm_host structure that matches the passed-in
@@ -465,6 +468,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 				     const unsigned short protocol,
 				     const u32 version,
 				     const char *hostname,
+				     const char *myname,
 				     int noresvport)
 {
 	const struct sockaddr source = {
@@ -476,6 +480,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.salen		= salen,
 		.protocol	= protocol,
 		.version	= version,
+		.my_name	= myname,
 		.hostname	= hostname,
 		.hostname_len	= strlen(hostname),
 		.src_sap	= &source,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee77713..920b842 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -98,6 +98,7 @@ struct rpc_program		nfsacl_program = {
 #endif  /* CONFIG_NFS_V3_ACL */
 
 struct nfs_client_initdata {
+	const char *myname;
 	const char *hostname;
 	const struct sockaddr *addr;
 	size_t addrlen;
@@ -129,6 +130,13 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
 	clp->cl_addrlen = cl_init->addrlen;
 
+	if (cl_init->myname) {
+		err = -ENOMEM;
+		clp->cl_myname = kstrdup(cl_init->myname, GFP_KERNEL);
+		if (!clp->cl_myname)
+			goto error_cleanup;
+	}
+
 	if (cl_init->hostname) {
 		err = -ENOMEM;
 		clp->cl_hostname = kstrdup(cl_init->hostname, GFP_KERNEL);
@@ -159,6 +167,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	return clp;
 
 error_cleanup:
+	kfree(clp->cl_myname);
 	kfree(clp);
 error_0:
 	return ERR_PTR(err);
@@ -645,6 +654,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 	struct nlm_host *host;
 	struct nfs_client *clp = server->nfs_client;
 	struct nlmclnt_initdata nlm_init = {
+		.myname		= clp->cl_myname,
 		.hostname	= clp->cl_hostname,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrlen	= clp->cl_addrlen,
@@ -780,6 +790,7 @@ static int nfs_init_server(struct nfs_server *server,
 			   const struct nfs_parsed_mount_data *data)
 {
 	struct nfs_client_initdata cl_init = {
+		.myname = data->myname,
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 37c37f8..ff0c906 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -80,6 +80,7 @@ struct nfs_parsed_mount_data {
 	unsigned int		version;
 	unsigned int		minorversion;
 	char			*fscache_uniq;
+	char			*myname;
 
 	struct {
 		struct sockaddr_storage	address;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 21a0dcb..50a6d82 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -99,6 +99,7 @@ enum {
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
+	Opt_caller_name,
 
 	/* Special mount options */
 	Opt_userspace, Opt_deprecated, Opt_sloppy,
@@ -170,6 +171,7 @@ static const match_table_t nfs_mount_option_tokens = {
 
 	{ Opt_lookupcache, "lookupcache=%s" },
 	{ Opt_fscache_uniq, "fsc=%s" },
+	{ Opt_caller_name, "callername=%s" },
 
 	{ Opt_err, NULL }
 };
@@ -1383,6 +1385,13 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->fscache_uniq = string;
 			mnt->options |= NFS_OPTION_FSCACHE;
 			break;
+		case Opt_caller_name:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			kfree(mnt->myname);
+			mnt->myname = string;
+			break;
 
 		/*
 		 * Special options
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index fbc48f8..5d51b87 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -36,6 +36,7 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
  * rpc_ops field.
  */
 struct nlmclnt_initdata {
+	const char		*myname;
 	const char		*hostname;
 	const struct sockaddr	*address;
 	size_t			addrlen;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a19bdde..e83b62d 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -226,6 +226,7 @@ struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 					const size_t salen,
 					const unsigned short protocol,
 					const u32 version,
+					const char *myname,
 					const char *hostname,
 					int noresvport);
 struct nlm_host  *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 34fc6be..7c86c2f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -66,6 +66,11 @@ struct nfs_client {
 	/* idmapper */
 	struct idmap *		cl_idmap;
 
+	/* Our local hostname, as a null-terminated string.
+	 * This is used to generate the caller_name for v2/v3 locking.
+	 */
+	char			*cl_myname;
+
 	/* Our own IP address, as a null-terminated string.
 	 * This is used to generate the clientid, and the callback address.
 	 */

