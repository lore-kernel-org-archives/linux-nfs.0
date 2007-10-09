From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: linux-2.6.23-rc9-CITI_NFS4_ALL-1
Date: Tue, 09 Oct 2007 18:11:27 +0200
Message-ID: <470BA82F.6090804@bull.net>
References: <E1Idoz6-0000W5-SM@fieldses.org> <4709FBF6.4090700@bull.net>
	<1191943060.8739.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1191943060.8739.9.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust a =E9crit :

>On Mon, 2007-10-08 at 11:44 +0200, Le Rouzic wrote:
>  =

>
>>Hi,
>>
>>Running 2.6.23-rc9-CITI_NFS4_ALL-1 on two Intel X86_64 two ways machines =
as client and
>>server, the runtest (-b) of the basic commands of the connectathon suite =
gives
>>the following errors:
>>
>>./runtests -b -t /mnt/nosec1/test_nfs1_nfs4_gb
>>/test6: readdir
>>        ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) unlinked 'file.0' dir en=
try
>>read pass 1
>>        ./test6: (/mnt/nosec1/test_nfs1_nfs4_gb) Test failed with 1 errors
>>
>>
>>Bug has been registered at:
>>
>>Bug: =

>>  http://bugzilla.linux-nfs.org/show_bug.cgi?id=3D148  =

>>
>>Cheers
>>    =

>>
>
>I believe that applying the following 2 patches should fix this problem.
>
>Cheers
>  Trond
>  =

>
        Hi,

       They do . We can close the bug at least for this test.
      Cheers




>  =

>
>
> ------------------------------------------------------------------------
>
> Sujet:
> No Subject
> Exp=E9diteur:
> Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:
> Mon, 8 Oct 2007 14:10:31 -0400
>
>
>nfs_post_op_update_inode() is really only meant to be used if we expect the
>inode and its attributes to have changed in some way.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
>
> fs/nfs/nfs3proc.c |    3 +--
> fs/nfs/nfs4proc.c |    5 ++---
> 2 files changed, 3 insertions(+), 5 deletions(-)
>
>diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
>index 6e05f6c..4cdc236 100644
>--- a/fs/nfs/nfs3proc.c
>+++ b/fs/nfs/nfs3proc.c
>@@ -777,8 +777,7 @@ static int nfs3_commit_done(struct rpc_task *task, str=
uct nfs_write_data *data)
> {
> 	if (nfs3_async_handle_jukebox(task, data->inode))
> 		return -EAGAIN;
>-	if (task->tk_status >=3D 0)
>-		nfs_post_op_update_inode(data->inode, data->res.fattr);
>+	nfs_refresh_inode(data->inode, data->res.fattr);
> 	return 0;
> }
> =

>diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>index 52af5a7..30d5dd5 100644
>--- a/fs/nfs/nfs4proc.c
>+++ b/fs/nfs/nfs4proc.c
>@@ -2475,8 +2475,7 @@ static int nfs4_commit_done(struct rpc_task *task, s=
truct nfs_write_data *data)
> 		rpc_restart_call(task);
> 		return -EAGAIN;
> 	}
>-	if (task->tk_status >=3D 0)
>-		nfs_post_op_update_inode(inode, data->res.fattr);
>+	nfs_refresh_inode(inode, data->res.fattr);
> 	return 0;
> }
> =

>@@ -3046,7 +3045,7 @@ static int _nfs4_proc_delegreturn(struct inode *inod=
e, struct rpc_cred *cred, co
> 	if (status =3D=3D 0) {
> 		status =3D data->rpc_status;
> 		if (status =3D=3D 0)
>-			nfs_post_op_update_inode(inode, &data->fattr);
>+			nfs_refresh_inode(inode, &data->fattr);
> 	}
> 	rpc_put_task(task);
> 	return status;
>  =

>
>
> ------------------------------------------------------------------------
>
> Sujet:
> No Subject
> Exp=E9diteur:
> Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:
> Mon, 8 Oct 2007 09:24:22 -0400
>
>
>We're failing basic test6 against Linux servers because they lack a correct
>change attribute. The fix is to assume that we always want to invalidate
>the readdir caches when we call update_changeattr and/or
>nfs_post_op_update_inode on a directory.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
>
> fs/nfs/inode.c    |   10 +++++++++-
> fs/nfs/nfs4proc.c |   10 ++++------
> 2 files changed, 13 insertions(+), 7 deletions(-)
>
>diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>index 4693879..c44cd02 100644
>--- a/fs/nfs/inode.c
>+++ b/fs/nfs/inode.c
>@@ -876,11 +876,19 @@ int nfs_post_op_update_inode(struct inode *inode, st=
ruct nfs_fattr *fattr)
> {
> 	struct nfs_inode *nfsi =3D NFS_I(inode);
> =

>-	if (fattr->valid & NFS_ATTR_FATTR)
>+	if (fattr->valid & NFS_ATTR_FATTR) {
>+		if (S_ISDIR(inode->i_mode)) {
>+			spin_lock(&inode->i_lock);
>+			nfsi->cache_validity |=3D NFS_INO_INVALID_DATA;
>+			spin_unlock(&inode->i_lock);
>+		}
> 		return nfs_refresh_inode(inode, fattr);
>+	}
> =

> 	spin_lock(&inode->i_lock);
> 	nfsi->cache_validity |=3D NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ATTR|NF=
S_INO_REVAL_PAGECACHE;
>+	if (S_ISDIR(inode->i_mode))
>+		nfsi->cache_validity |=3D NFS_INO_INVALID_DATA;
> 	spin_unlock(&inode->i_lock);
> 	return 0;
> }
>diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>index 30d5dd5..cb99fd9 100644
>--- a/fs/nfs/nfs4proc.c
>+++ b/fs/nfs/nfs4proc.c
>@@ -208,12 +208,10 @@ static void update_changeattr(struct inode *dir, str=
uct nfs4_change_info *cinfo)
> 	struct nfs_inode *nfsi =3D NFS_I(dir);
> =

> 	spin_lock(&dir->i_lock);
>-	if (cinfo->after !=3D nfsi->change_attr) {
>-		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|=
NFS_INO_INVALID_DATA;
>-		if (!cinfo->atomic || cinfo->before !=3D nfsi->change_attr)
>-			nfsi->cache_change_attribute =3D jiffies;
>-		nfsi->change_attr =3D cinfo->after;
>-	}
>+	nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|N=
FS_INO_INVALID_DATA;
>+	if (!cinfo->atomic || cinfo->before !=3D nfsi->change_attr)
>+		nfsi->cache_change_attribute =3D jiffies;
>+	nfsi->change_attr =3D cinfo->after;
> 	spin_unlock(&dir->i_lock);
> }
> =

>  =

>


-- =

-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic =

Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- =
