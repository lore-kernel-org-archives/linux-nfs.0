From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!
Date: Thu, 16 Nov 2006 12:46:04 -0500
Message-ID: <1163699164.9593.29.camel@lade.trondhjem.org>
References: <20061116023117.36380.qmail@web58102.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Open Source <opensource3141@yahoo.com>
In-Reply-To: <20061116023117.36380.qmail@web58102.mail.re3.yahoo.com>
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

On Wed, 2006-11-15 at 18:31 -0800, Open Source wrote:
> Hi all,
> 
> I think I have found the answer.  It is similar to this issue but not
> exactly the same as:
> 
> http://linux-nfs.org/pipermail/nfsv4/2005-November/002807.html
> 
> Here's what is happening.  In 2.6.18 there is a new file called
> fs/nfs/client.c.  In this file it does the following for every new
> mount:
> 
> 1) Lookup to see if an existing client has the same specification
> as the requested mount.
> 
> 2) If so, clone that client.  If not, create a new one.
> 
> 3) Create any pipes required by the auth pseudoflavor by
> calling rpcauth_create.
> 
> 4) Continue with the mounting of the volume.
> 
> Now, if you have no connections to the server, a new rpc
> client is created and the pipes are created with no problems.
> For the second mount to the same server, the rpc client is
> cloned and has the same path in /var/lib/nfs/rpc_pipefs/nfs
> has the first connection.  Therefore on step 3 the pipe creation
> fails in net/sunrpc/auth_gss/auth_gss.c.  This causes the
> entire mount to fail.

Thanks for debugging this! I think the right thing to do here is just to
give the cloned clients their own rpc_pipefs directory. Can you see if
the following patch fixes your problem?

Cheers,
  Trond

----------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: 1163695047 -0500
SUNRPC: Give cloned RPC clients their own rpc_pipefs directory

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |   19 +++++++++++--------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index f6d1d64..a1be89d 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -53,6 +53,7 @@ struct rpc_clnt {
 	struct dentry *		cl_dentry;	/* inode */
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
+	struct rpc_program *	cl_program;
 	char			cl_inline_name[32];
 };
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 587f3ec..4d269e5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -141,6 +141,7 @@ static struct rpc_clnt * rpc_new_client(
 	clnt->cl_vers     = version->number;
 	clnt->cl_stats    = program->stats;
 	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
+	clnt->cl_program  = program;
 
 	if (!xprt_bound(clnt->cl_xprt))
 		clnt->cl_autobind = 1;
@@ -252,6 +253,7 @@ struct rpc_clnt *
 rpc_clone_client(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *new;
+	int err;
 
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (!new)
@@ -259,6 +261,11 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	memcpy(new, clnt, sizeof(*new));
 	atomic_set(&new->cl_count, 1);
 	atomic_set(&new->cl_users, 0);
+	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
+	if (err != 0) {
+		kfree(new);
+		return ERR_PTR(err);
+	}
 	new->cl_parent = clnt;
 	atomic_inc(&clnt->cl_count);
 	new->cl_xprt = xprt_get(clnt->cl_xprt);
@@ -266,8 +273,6 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	new->cl_autobind = 0;
 	new->cl_oneshot = 0;
 	new->cl_dead = 0;
-	if (!IS_ERR(new->cl_dentry))
-		dget(new->cl_dentry);
 	rpc_init_rtt(&new->cl_rtt_default, clnt->cl_xprt->timeout.to_initval);
 	if (new->cl_auth)
 		atomic_inc(&new->cl_auth->au_count);
@@ -328,16 +333,14 @@ rpc_destroy_client(struct rpc_clnt *clnt
 		rpcauth_destroy(clnt->cl_auth);
 		clnt->cl_auth = NULL;
 	}
-	if (clnt->cl_parent != clnt) {
-		if (!IS_ERR(clnt->cl_dentry))
-			dput(clnt->cl_dentry);
-		rpc_destroy_client(clnt->cl_parent);
-		goto out_free;
-	}
 	if (!IS_ERR(clnt->cl_dentry)) {
 		rpc_rmdir(clnt->cl_dentry);
 		rpc_put_mount();
 	}
+	if (clnt->cl_parent != clnt) {
+		rpc_destroy_client(clnt->cl_parent);
+		goto out_free;
+	}
 	if (clnt->cl_server != clnt->cl_inline_name)
 		kfree(clnt->cl_server);
 out_free:
