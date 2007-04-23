From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] NFS: More nfs4 in-kernel mount option
	parsing	infrastructure
Date: Mon, 23 Apr 2007 18:04:09 -0400
Message-ID: <20070423220408.24305.98920.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6dr-0003PQ-Hz
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:15 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6dt-0008Np-UA
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:18 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add function for switching between an nfs4_mount_data structure from user
space (the current nfs4 mount mechanism) and generating an nfs4_mount_data
structure from a text string containing nfs4 mount options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  165 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 144 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9260364..97bbe10 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1096,6 +1096,150 @@ out_err:
 	return ERR_PTR(-EINVAL);
 }
 
+static void *nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
+{
+	void *p = NULL;
+
+	if (!src->len)
+		return ERR_PTR(-EINVAL);
+	if (src->len < maxlen)
+		maxlen = src->len;
+	if (dst == NULL) {
+		p = dst = kmalloc(maxlen + 1, GFP_KERNEL);
+		if (p == NULL)
+			return ERR_PTR(-ENOMEM);
+	}
+	if (copy_from_user(dst, src->data, maxlen)) {
+		kfree(p);
+		return ERR_PTR(-EFAULT);
+	}
+	dst[maxlen] = '\0';
+	return dst;
+}
+
+static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
+				    const char *dev_name,
+				    struct sockaddr_in *addr,
+				    rpc_authflavor_t *authflavour,
+				    char **hostname,
+				    char **mntpath,
+				    char *ip_addr)
+{
+	struct nfs4_mount_data *data = *options;
+	char *c;
+	unsigned len;
+
+	if (data == NULL) {
+		dprintk("%s: missing data argument\n", __FUNCTION__);
+		return -EINVAL;
+	}
+
+	switch (data->version) {
+	case 1:
+		if (data->host_addrlen != sizeof(*addr))
+			return -EINVAL;
+		if (copy_from_user(addr, data->host_addr, sizeof(*addr)))
+			return -EFAULT;
+		if (addr->sin_port == 0)
+			addr->sin_port = htons(NFS_PORT);
+		if (!nfs_verify_server_address((struct sockaddr *) addr,
+					       data->host_addrlen))
+			return -EINVAL;
+
+		switch (data->auth_flavourlen) {
+		case 0:
+			*authflavour = RPC_AUTH_UNIX;
+			break;
+		case 1:
+			if (copy_from_user(authflavour, data->auth_flavours,
+					   sizeof(*authflavour)))
+				return -EFAULT;
+		default:
+			goto out_inval_auth;
+		}
+
+		c = nfs_copy_user_string(ip_addr, &data->client_addr, 80);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+
+		c = nfs_copy_user_string(NULL, &data->hostname, 256);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+		*hostname = c;
+
+		c = nfs_copy_user_string(NULL, &data->mnt_path, 1024);
+		if (IS_ERR(c)) {
+			kfree(*hostname);
+			return PTR_ERR(c);
+		}
+		*mntpath = c;
+		dprintk("MNTPATH: %s\n", *mntpath);
+
+		return 0;
+	default:
+		data = nfs4_convert_mount_opts((char *) data);
+		if (IS_ERR(data))
+			return PTR_ERR(data);
+		*options = data;
+
+		memcpy(addr, data->host_addr, sizeof(*addr));
+		if (!nfs_verify_server_address((struct sockaddr *) addr,
+						data->host_addrlen))
+			return -EINVAL;
+
+		switch (data->auth_flavourlen) {
+		case 0:
+			*authflavour = RPC_AUTH_UNIX;
+			break;
+		case 1:
+			*authflavour = (rpc_authflavor_t) data->auth_flavours;
+			break;
+		default:
+			goto out_inval_auth;
+		}
+
+		memset(ip_addr, '\0', data->client_addr.len + 1);
+		strncpy(ip_addr, data->client_addr.data, data->client_addr.len);
+
+		/*
+		 * Split "dev_name" into "hostname:mntpath".
+		 */
+		c = strchr(dev_name, ':');
+		if (c == NULL)
+			return -EINVAL;
+		/* while calculating len, pretend ':' is '\0' */
+		len = c - dev_name;
+		if (len > 256)
+			return -EINVAL;
+		*hostname = kzalloc(len, GFP_KERNEL);
+		if (*hostname == NULL)
+			return -ENOMEM;
+		strncpy(*hostname, dev_name, len - 1);
+
+		c++;			/* step over the ':' */
+		len = strlen(c);
+		if (len > 1023) {
+			kfree(*hostname);
+			return -EINVAL;
+		}
+		*mntpath = kzalloc(len + 1, GFP_KERNEL);
+		if (*mntpath == NULL) {
+			kfree(*hostname);
+			return -ENOMEM;
+		}
+		strncpy(*mntpath, c, len);
+
+		dprintk("MNTPATH: %s\n", *mntpath);
+
+		return 0;
+	}
+
+out_inval_auth:
+	dprintk("%s: Invalid number of RPC auth flavours %d.\n",
+		__FUNCTION__, data->auth_flavourlen);
+	return -EINVAL;
+}
+
 /*
  * Finish setting up a cloned NFS4 superblock
  */
@@ -1120,27 +1264,6 @@ static void nfs4_fill_super(struct super_block *sb)
 	nfs_initialise_sb(sb);
 }
 
-static void *nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
-{
-	void *p = NULL;
-
-	if (!src->len)
-		return ERR_PTR(-EINVAL);
-	if (src->len < maxlen)
-		maxlen = src->len;
-	if (dst == NULL) {
-		p = dst = kmalloc(maxlen + 1, GFP_KERNEL);
-		if (p == NULL)
-			return ERR_PTR(-ENOMEM);
-	}
-	if (copy_from_user(dst, src->data, maxlen)) {
-		kfree(p);
-		return ERR_PTR(-EFAULT);
-	}
-	dst[maxlen] = '\0';
-	return dst;
-}
-
 /*
  * Get the superblock for an NFS4 mountpoint
  */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
