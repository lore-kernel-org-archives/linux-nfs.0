From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Mon, 24 Sep 2007 17:26:12 -0400
Message-ID: <1190669172.6700.20.camel@heimdal.trondhjem.org>
References: <46E121B8.4080105@linux.vnet.ibm.com>
	<6bffcb0e0709071656o6881fa17y61818a9733293a4c@mail.gmail.com>
	<1189289549.13713.4.camel@localhost.localdomain>
	<46E54156.8060706@linux.vnet.ibm.com>
	<1190223091.6734.2.camel@heimdal.trondhjem.org>
	<46F80991.6010001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-66wfFotqyvYbgdOpVsSB"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZvRw-0004XF-V4
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 14:26:41 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZvS0-0004o2-Bg
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 14:26:46 -0700
In-Reply-To: <46F80991.6010001@linux.vnet.ibm.com>
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


--=-66wfFotqyvYbgdOpVsSB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2007-09-25 at 00:31 +0530, Kamalesh Babulal wrote:
> > I'm mystified. I'm quite unable to reproduce this on my own setup: the
> > ENAMETOOLONG error reporting mechanism prevents me from even getting
> > near the above bug.
> > 
> > Could you add a little printk into the 'encode_lookup' routine on line
> > 944 of fs/nfs/nfs4xdr.c to display the value of 'len'?
> > 
> > Cheers
> >   Trond
> 
> Hi Trond,
> 
> Sorry, for replying so late, i have included the printk as you have requested.
> 
> len passed on encode_lookup [811]RESERVE_SPACE(819) failed in function encode_lookup

OK. That is definitely wrong! We shouldn't be allowing anything > 255
according to <limits.h>.

Looks like that code in fs/nfs/client.c has been wrong since its
inception in 2.6.18. Not only for NFSv4, but for NFSv2 and v3 too. We
only caught it 'cos v4 has more stringent tests...

Take two on the patch attached...

Trond

--=-66wfFotqyvYbgdOpVsSB
Content-Disposition: inline; filename=linux-2.6.23-002-fix_nfs4_namelen.dif
Content-Type: message/rfc822; name=linux-2.6.23-002-fix_nfs4_namelen.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sun, 9 Sep 2007 00:10:51 +0200
NFS: Fix an Oops in encode_lookup()
Subject: No Subject
Message-Id: <1190669172.6700.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

It doesn't look as if the NFS file name limit is being initialised correctly
in the struct nfs_server. Make sure that we limit whatever is being set in
nfs_probe_fsinfo() and nfs_init_server().

Also ensure that readdirplus and nfs4_path_walk respect our file name
limits.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c  |   29 +++++++++++++++++++----------
 fs/nfs/dir.c     |    2 ++
 fs/nfs/getroot.c |    3 +++
 3 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a49f9fe..a204484 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -588,16 +588,6 @@ static int nfs_init_server(struct nfs_server *server, const struct nfs_mount_dat
 	server->namelen  = data->namlen;
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
 	nfs_init_server_aclclient(server);
-	if (clp->cl_nfsversion == 3) {
-		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
-			server->namelen = NFS3_MAXNAMLEN;
-		if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
-			server->caps |= NFS_CAP_READDIRPLUS;
-	} else {
-		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
-			server->namelen = NFS2_MAXNAMLEN;
-	}
-
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
@@ -794,6 +784,16 @@ struct nfs_server *nfs_create_server(const struct nfs_mount_data *data,
 	error = nfs_probe_fsinfo(server, mntfh, &fattr);
 	if (error < 0)
 		goto error;
+	if (server->nfs_client->rpc_ops->version == 3) {
+		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
+			server->namelen = NFS3_MAXNAMLEN;
+		if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
+			server->caps |= NFS_CAP_READDIRPLUS;
+	} else {
+		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
+			server->namelen = NFS2_MAXNAMLEN;
+	}
+
 	if (!(fattr.valid & NFS_ATTR_FATTR)) {
 		error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr);
 		if (error < 0) {
@@ -984,6 +984,9 @@ struct nfs_server *nfs4_create_server(const struct nfs4_mount_data *data,
 	if (error < 0)
 		goto error;
 
+	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
+		server->namelen = NFS4_MAXNAMLEN;
+
 	BUG_ON(!server->nfs_client);
 	BUG_ON(!server->nfs_client->rpc_ops);
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
@@ -1056,6 +1059,9 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
+	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
+		server->namelen = NFS4_MAXNAMLEN;
+
 	dprintk("Referral FSID: %llx:%llx\n",
 		(unsigned long long) server->fsid.major,
 		(unsigned long long) server->fsid.minor);
@@ -1115,6 +1121,9 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	if (error < 0)
 		goto out_free_server;
 
+	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
+		server->namelen = NFS4_MAXNAMLEN;
+
 	dprintk("Cloned FSID: %llx:%llx\n",
 		(unsigned long long) server->fsid.major,
 		(unsigned long long) server->fsid.minor);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ea97408..e4a04d1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1162,6 +1162,8 @@ static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc)
 	}
 	if (!desc->plus || !(entry->fattr->valid & NFS_ATTR_FATTR))
 		return NULL;
+	if (name.len > NFS_SERVER(dir)->namelen)
+		return NULL;
 	/* Note: caller is already holding the dir->i_mutex! */
 	dentry = d_alloc(parent, &name);
 	if (dentry == NULL)
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index d1cbf0a..522e5ad 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -175,6 +175,9 @@ next_component:
 		path++;
 	name.len = path - (const char *) name.name;
 
+	if (name.len > NFS4_MAXNAMLEN)
+		return -ENAMETOOLONG;
+
 eat_dot_dir:
 	while (*path == '/')
 		path++;

--=-66wfFotqyvYbgdOpVsSB
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--=-66wfFotqyvYbgdOpVsSB
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-66wfFotqyvYbgdOpVsSB--
