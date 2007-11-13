From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/25] NFS: Support non-IPv4 addresses in
	nfs_parsed_mount_data
Date: Tue, 13 Nov 2007 13:32:56 -0500
Message-ID: <20071113183256.5087.23486.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0ZE-0000Xd-Ay
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:56 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0ZJ-0000Ol-6i
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:33:02 -0800
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

Replace the nfs_server and mount_server address fields in the
nfs_parsed_mount_data structure with a "struct sockaddr_storage" and a
length, instead of a "struct sockaddr_in".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c   |   11 +++++-----
 fs/nfs/internal.h |    6 ++++--
 fs/nfs/super.c    |   56 +++++++++++++++++++++++++++++++++--------------------
 3 files changed, 44 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 37b63a6..3ee0f0d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -573,6 +573,7 @@ error:
 static int nfs_init_server(struct nfs_server *server,
 			   const struct nfs_parsed_mount_data *data)
 {
+	struct sockaddr *sap = (struct sockaddr *)&data->nfs_server.address;
 	struct nfs_client *clp;
 	unsigned int nfsvers = 2;
 	int error;
@@ -585,10 +586,8 @@ static int nfs_init_server(struct nfs_server *server,
 #endif
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(data->nfs_server.hostname,
-				(struct sockaddr *)&data->nfs_server.address,
-				sizeof(data->nfs_server.address),
-				nfsvers);
+	clp = nfs_get_client(data->nfs_server.hostname, sap,
+			     data->nfs_server.addrlen, nfsvers);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
@@ -985,6 +984,7 @@ static int nfs4_init_server(struct nfs_server *server,
 struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 				      struct nfs_fh *mntfh)
 {
+	struct sockaddr *sap = (struct sockaddr *)&data->nfs_server.address;
 	struct nfs_fattr fattr;
 	struct nfs_server *server;
 	int error;
@@ -998,8 +998,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	/* Get a client record */
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
-			(struct sockaddr *)&data->nfs_server.address,
-			sizeof(data->nfs_server.address),
+			sap, data->nfs_server.addrlen,
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 40f2619..f8ccba9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -44,7 +44,8 @@ struct nfs_parsed_mount_data {
 	char			*client_address;
 
 	struct {
-		struct sockaddr_in	address;
+		struct sockaddr_storage	address;
+		size_t			addrlen;
 		char			*hostname;
 		unsigned int		version;
 		unsigned short		port;
@@ -52,7 +53,8 @@ struct nfs_parsed_mount_data {
 	} mount_server;
 
 	struct {
-		struct sockaddr_in	address;
+		struct sockaddr_storage	address;
+		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
 		int			protocol;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c09c045..3ea4a4f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -599,8 +599,10 @@ static int nfs_set_address_port(struct sockaddr *sap, unsigned short port)
 /*
  * Sanity-check a server address provided by the mount command
  */
-static int nfs_verify_server_address(struct sockaddr *addr)
+static int nfs_verify_server_address(struct sockaddr_storage *ssp)
 {
+	struct sockaddr *addr = (struct sockaddr *)ssp;
+
 	switch (addr->sa_family) {
 	case AF_INET: {
 		struct sockaddr_in *sa = (struct sockaddr_in *) addr;
@@ -617,10 +619,14 @@ static int nfs_verify_server_address(struct sockaddr *addr)
  * Parse string addresses passed in via a mount option.
  */
 static void nfs_parse_server_address(char *value,
-				     struct sockaddr_in *addr)
+				     struct sockaddr_storage *ssp,
+				     size_t *len)
 {
-	addr->sin_family = AF_INET;
-	addr->sin_addr.s_addr = in_aton(value);
+	struct sockaddr_in *ap = (struct sockaddr_in *)ssp;
+
+	ap->sin_family = AF_INET;
+	ap->sin_addr.s_addr = in_aton(value);
+	*len = sizeof(*ap);
 }
 
 /*
@@ -977,7 +983,8 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			nfs_parse_server_address(string,
-						 &mnt->nfs_server.address);
+						 &mnt->nfs_server.address,
+						 &mnt->nfs_server.addrlen);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -997,7 +1004,8 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			nfs_parse_server_address(string,
-						 &mnt->mount_server.address);
+						 &mnt->mount_server.address,
+						 &mnt->mount_server.addrlen);
 			kfree(string);
 			break;
 
@@ -1059,10 +1067,11 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (args->mount_server.address.sin_addr.s_addr != INADDR_ANY)
-		sin = args->mount_server.address;
+	if (args->mount_server.addrlen != 0)
+		memcpy(&sin, &args->mount_server.address, sizeof(sin));
 	else
-		sin = args->nfs_server.address;
+		memcpy(&sin, &args->nfs_server.address, sizeof(sin));
+
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
@@ -1158,9 +1167,6 @@ static int nfs_validate_mount_data(void *options,
 			memset(mntfh->data + mntfh->size, 0,
 			       sizeof(mntfh->data) - mntfh->size);
 
-		if (!nfs_verify_server_address((struct sockaddr *) &data->addr))
-			goto out_no_address;
-
 		/*
 		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
 		 * can deal with.
@@ -1175,7 +1181,13 @@ static int nfs_validate_mount_data(void *options,
 		args->acregmax		= data->acregmax;
 		args->acdirmin		= data->acdirmin;
 		args->acdirmax		= data->acdirmax;
-		args->nfs_server.address = data->addr;
+
+		memcpy(&args->nfs_server.address, &data->addr,
+		       sizeof(data->addr));
+		args->nfs_server.addrlen = sizeof(data->addr);
+		if (!nfs_verify_server_address(&args->nfs_server.address))
+			goto out_no_address;
+
 		if (!(data->flags & NFS_MOUNT_TCP))
 			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
@@ -1193,8 +1205,7 @@ static int nfs_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (!nfs_verify_server_address(&args->nfs_server.address))
 			goto out_no_address;
 
 		c = strchr(dev_name, ':');
@@ -1612,6 +1623,7 @@ static int nfs4_validate_mount_data(void *options,
 				    struct nfs_parsed_mount_data *args,
 				    const char *dev_name)
 {
+	struct sockaddr_in *ap;
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 	char *c;
@@ -1632,15 +1644,17 @@ static int nfs4_validate_mount_data(void *options,
 
 	switch (data->version) {
 	case 1:
-		if (data->host_addrlen != sizeof(args->nfs_server.address))
+		ap = (struct sockaddr_in *)&args->nfs_server.address;
+		if (data->host_addrlen > sizeof(args->nfs_server.address))
+			goto out_no_address;
+		if (data->host_addrlen == 0)
 			goto out_no_address;
-		if (copy_from_user(&args->nfs_server.address,
-				   data->host_addr,
-				   sizeof(args->nfs_server.address)))
+		if (copy_from_user(ap, data->host_addr, data->host_addrlen))
 			return -EFAULT;
+		args->nfs_server.addrlen = data->host_addrlen;
 		if (nfs4_default_port(sap))
 			goto out_no_address;
-		if (!nfs_verify_server_address(sap))
+		if (!nfs_verify_server_address(&args->nfs_server.address))
 			goto out_no_address;
 
 		switch (data->auth_flavourlen) {
@@ -1698,7 +1712,7 @@ static int nfs4_validate_mount_data(void *options,
 
 		if (nfs4_default_port(sap))
 			return -EINVAL;
-		if (!nfs_verify_server_address(sap))
+		if (!nfs_verify_server_address(&args->nfs_server.address))
 			return -EINVAL;
 
 		switch (args->auth_flavor_len) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
