From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux-2.6.23-rc9-CITI_NFS4_ALL-1
Date: Tue, 09 Oct 2007 11:17:40 -0400
Message-ID: <1191943060.8739.9.camel@heimdal.trondhjem.org>
References: <E1Idoz6-0000W5-SM@fieldses.org>  <4709FBF6.4090700@bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-AyYPVt7UxwA2NGQtVisa"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfGpk-0002dC-Va
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:17:22 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfGpo-0007Re-3K
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:17:25 -0700
In-Reply-To: <4709FBF6.4090700@bull.net>
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


--=-AyYPVt7UxwA2NGQtVisa
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Mon, 2007-10-08 at 11:44 +0200, Le Rouzic wrote:
> Hi,
> 
> Running 2.6.23-rc9-CITI_NFS4_ALL-1 on two Intel X86_64 two ways machines as client and
> server, the runtest (-b) of the basic commands of the connectathon suite gives
> the following errors:
> 
> ./runtests -b -t /mnt/nosec1/test_nfs1_nfs4_gb
> /test6: readdir
>         ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) unlinked 'file.0' dir entry
> read pass 1
>         ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) Test failed with 1 errors
> 
> 
> Bug has been registered at:
> 
> Bug: 
>   http://bugzilla.linux-nfs.org/show_bug.cgi?id=148  
> 
> Cheers

I believe that applying the following 2 patches should fix this problem.

Cheers
  Trond


--=-AyYPVt7UxwA2NGQtVisa
Content-Disposition: attachment;
	filename=linux-2.6.23-128-nfs_use_nfs_refresh_inode.dif
Content-Type: message/rfc822;
	name=linux-2.6.23-128-nfs_use_nfs_refresh_inode.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 8 Oct 2007 14:10:31 -0400
NFS: Use nfs_refresh_inode() in ops that aren't expected to change the inode
Subject: No Subject
Message-Id: <1191943060.8739.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

nfs_post_op_update_inode() is really only meant to be used if we expect the
inode and its attributes to have changed in some way.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs3proc.c |    3 +--
 fs/nfs/nfs4proc.c |    5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 6e05f6c..4cdc236 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -777,8 +777,7 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (nfs3_async_handle_jukebox(task, data->inode))
 		return -EAGAIN;
-	if (task->tk_status >= 0)
-		nfs_post_op_update_inode(data->inode, data->res.fattr);
+	nfs_refresh_inode(data->inode, data->res.fattr);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 52af5a7..30d5dd5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2475,8 +2475,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
-	if (task->tk_status >= 0)
-		nfs_post_op_update_inode(inode, data->res.fattr);
+	nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
 
@@ -3046,7 +3045,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	if (status == 0) {
 		status = data->rpc_status;
 		if (status == 0)
-			nfs_post_op_update_inode(inode, &data->fattr);
+			nfs_refresh_inode(inode, &data->fattr);
 	}
 	rpc_put_task(task);
 	return status;

--=-AyYPVt7UxwA2NGQtVisa
Content-Disposition: attachment;
	filename=linux-2.6.23-129-nfs_fix_connectathon_failure.dif
Content-Type: message/rfc822;
	name=linux-2.6.23-129-nfs_fix_connectathon_failure.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 8 Oct 2007 09:24:22 -0400
NFSv4: Fix a connectathon regression
Subject: No Subject
Message-Id: <1191943060.8739.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

We're failing basic test6 against Linux servers because they lack a correct
change attribute. The fix is to assume that we always want to invalidate
the readdir caches when we call update_changeattr and/or
nfs_post_op_update_inode on a directory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c    |   10 +++++++++-
 fs/nfs/nfs4proc.c |   10 ++++------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 4693879..c44cd02 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -876,11 +876,19 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	if (fattr->valid & NFS_ATTR_FATTR)
+	if (fattr->valid & NFS_ATTR_FATTR) {
+		if (S_ISDIR(inode->i_mode)) {
+			spin_lock(&inode->i_lock);
+			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+			spin_unlock(&inode->i_lock);
+		}
 		return nfs_refresh_inode(inode, fattr);
+	}
 
 	spin_lock(&inode->i_lock);
 	nfsi->cache_validity |= NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+	if (S_ISDIR(inode->i_mode))
+		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
 	return 0;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 30d5dd5..cb99fd9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -208,12 +208,10 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 	struct nfs_inode *nfsi = NFS_I(dir);
 
 	spin_lock(&dir->i_lock);
-	if (cinfo->after != nfsi->change_attr) {
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA;
-		if (!cinfo->atomic || cinfo->before != nfsi->change_attr)
-			nfsi->cache_change_attribute = jiffies;
-		nfsi->change_attr = cinfo->after;
-	}
+	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA;
+	if (!cinfo->atomic || cinfo->before != nfsi->change_attr)
+		nfsi->cache_change_attribute = jiffies;
+	nfsi->change_attr = cinfo->after;
 	spin_unlock(&dir->i_lock);
 }
 

--=-AyYPVt7UxwA2NGQtVisa
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--=-AyYPVt7UxwA2NGQtVisa
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-AyYPVt7UxwA2NGQtVisa--
