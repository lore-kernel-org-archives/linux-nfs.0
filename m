From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: rpc.idmapd oops with latest NFS bits from your web site
Date: Mon, 14 Aug 2006 13:26:55 -0400
Message-ID: <1155576415.5664.98.camel@localhost>
References: <76bd70e30608101221se9d6fb6l8bb50e93109c7a5b@mail.gmail.com>
	<1155238502.5826.2.camel@localhost>
	<76bd70e30608101245w45779d6u7ef99d790c726d31@mail.gmail.com>
	<1155246274.5826.64.camel@localhost>
	<76bd70e30608110734g619ad245u464a840c89e9dce9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-rtALUxMN+8+6S30wGf48"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCgDz-0007YH-Uo
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 10:27:40 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCgDy-0002oV-3F
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 10:27:40 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30608110734g619ad245u464a840c89e9dce9@mail.gmail.com>
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


--=-rtALUxMN+8+6S30wGf48
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2006-08-11 at 10:34 -0400, Chuck Lever wrote:
> On 8/10/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Thu, 2006-08-10 at 15:45 -0400, Chuck Lever wrote:
> > > Yeah.  I'd say something is overwriting i_cdev with garbarge.  Then
> > > __fput sees that i_cdev is not NULL and tries to call cdev_put with a
> > > bogus address.
> >
> > Looks like something is calling fput() on a file pointing to an inode
> > that has already been freed. 6b6b6b6b is the mark of the poisoned slab
> > entry.
> >
> > Hmm.... Does the attached patch fix it for you?
> 
> Unfortunately, no.  Exact same symptoms.

OK. I think I've nailed it now. Please try the following patch, which
has been merged into the NFS git tree...

Cheers,
  Trond

--=-rtALUxMN+8+6S30wGf48
Content-Disposition: inline;
	filename=linux-2.6.18-009-fix_rpc_unlink_rmdir_3.dif
Content-Type: message/rfc822; name=linux-2.6.18-009-fix_rpc_unlink_rmdir_3.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
SUNRPC: Fix dentry refcounting issues with users of rpc_pipefs
Date: Mon, 14 Aug 2006 13:26:26 -0400
Subject: No Subject
Message-Id: <1155576386.5664.97.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

rpc_unlink() and rpc_rmdir() will dput the dentry reference for you.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/idmap.c                 |    1 -
 net/sunrpc/auth_gss/auth_gss.c |    1 -
 net/sunrpc/clnt.c              |   15 ++++++---------
 3 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index df0be12..07a5dd5 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -131,7 +131,6 @@ nfs_idmap_delete(struct nfs4_client *clp
 	if (!idmap)
 		return;
 	rpc_unlink(idmap->idmap_dentry);
-	dput(idmap->idmap_dentry);
 	clp->cl_idmap = NULL;
 	kfree(idmap);
 }
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index beaa7b8..ef1cf5b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -719,7 +719,6 @@ gss_destroy(struct rpc_auth *auth)
 
 	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
 	rpc_unlink(gss_auth->dentry);
-	dput(gss_auth->dentry);
 	gss_auth->dentry = NULL;
 	gss_mech_put(gss_auth->mech);
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d307556..d9eac70 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -184,7 +184,6 @@ rpc_new_client(struct rpc_xprt *xprt, ch
 out_no_auth:
 	if (!IS_ERR(clnt->cl_dentry)) {
 		rpc_rmdir(clnt->cl_dentry);
-		dput(clnt->cl_dentry);
 		rpc_put_mount();
 	}
 out_no_path:
@@ -251,10 +250,8 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	new->cl_autobind = 0;
 	new->cl_oneshot = 0;
 	new->cl_dead = 0;
-	if (!IS_ERR(new->cl_dentry)) {
+	if (!IS_ERR(new->cl_dentry))
 		dget(new->cl_dentry);
-		rpc_get_mount();
-	}
 	rpc_init_rtt(&new->cl_rtt_default, clnt->cl_xprt->timeout.to_initval);
 	if (new->cl_auth)
 		atomic_inc(&new->cl_auth->au_count);
@@ -317,11 +314,15 @@ rpc_destroy_client(struct rpc_clnt *clnt
 		clnt->cl_auth = NULL;
 	}
 	if (clnt->cl_parent != clnt) {
+		if (!IS_ERR(clnt->cl_dentry))
+			dput(clnt->cl_dentry);
 		rpc_destroy_client(clnt->cl_parent);
 		goto out_free;
 	}
-	if (!IS_ERR(clnt->cl_dentry))
+	if (!IS_ERR(clnt->cl_dentry)) {
 		rpc_rmdir(clnt->cl_dentry);
+		rpc_put_mount();
+	}
 	if (clnt->cl_xprt) {
 		xprt_destroy(clnt->cl_xprt);
 		clnt->cl_xprt = NULL;
@@ -331,10 +332,6 @@ rpc_destroy_client(struct rpc_clnt *clnt
 out_free:
 	rpc_free_iostats(clnt->cl_metrics);
 	clnt->cl_metrics = NULL;
-	if (!IS_ERR(clnt->cl_dentry)) {
-		dput(clnt->cl_dentry);
-		rpc_put_mount();
-	}
 	kfree(clnt);
 	return 0;
 }

--=-rtALUxMN+8+6S30wGf48
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=-rtALUxMN+8+6S30wGf48
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-rtALUxMN+8+6S30wGf48--
