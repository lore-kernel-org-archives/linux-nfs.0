From: Kostas Georgiou <k.georgiou@imperial.ac.uk>
Subject: Re: "mount: File exists" when trying to mount a second krb5
	volume!
Date: Sat, 18 Nov 2006 15:15:04 +0000
Message-ID: <20061118151504.GB22995@imperial.ac.uk>
References: <20061117195925.71840.qmail@web58101.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GlRug-0003sr-FB
	for nfs@lists.sourceforge.net; Sat, 18 Nov 2006 07:15:26 -0800
Received: from heppc218.hep.ph.ic.ac.uk ([155.198.211.218])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GlRug-0001v5-NO
	for nfs@lists.sourceforge.net; Sat, 18 Nov 2006 07:15:27 -0800
To: Open Source <opensource3141@yahoo.com>
In-Reply-To: <20061117195925.71840.qmail@web58101.mail.re3.yahoo.com>
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

On Fri, Nov 17, 2006 at 11:59:25AM -0800, Open Source wrote:

> Thanks Trond.  Saving the patch did the trick.  I had
> to do some manual hacking to get the patch to
> apply because you must have done your diff
> against a different kernel tree revision.  I'm using
> 2.6.18 from FC5 updates.
> 
> Once I massaged things, the patch compiled and it
> works.  I am able to mount more than one partition
> with no problems now.  However, I cannot speak
> to the finer points (like memory leaks, etc.) since
> I don't know the code so well.  I trust someone else
> will independently verify it (i.e., code review) before
> it gets into the kernel tree.

I did the same with the FC6 2.6.18 kernel and while it does allow
me to have more than one mount from the server autofs decides that
my home is not in use any more and it unmounts it, somehow this
causes the system to freeze as well.

Nov 17 16:28:14 thufir automount[2483]: mount still busy /home
Nov 17 16:29:29 thufir automount[2483]: expiring path /home/georgiou
Nov 17 16:29:29 thufir automount[2483]: unmounting dir = /home/georgiou
Nov 17 16:29:32 thufir automount[2483]: expired /home/georgiou

Here is the patch with my changes to apply in FC6 which most likely is
bad since I really don't know the code at all :(

Kostas Georgiou

diff -u a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -64,6 +64,7 @@
 	struct dentry *		cl_dentry;	/* inode */
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
+	struct rpc_program *	cl_program;
 	struct rpc_portmap	cl_pmap_default;
 	char			cl_inline_name[32];
 };
diff -u a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -154,6 +154,7 @@
 	clnt->cl_prot     = xprt->prot;
 	clnt->cl_stats    = program->stats;
 	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
+	clnt->cl_program  = program;
 	rpc_init_wait_queue(&clnt->cl_pmap_default.pm_bindwait, "bindwait");
 
 	if (!clnt->cl_port)
@@ -235,6 +236,7 @@
 rpc_clone_client(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *new;
+	int err;
 
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (!new)
@@ -242,6 +244,11 @@
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
 	/* Duplicate portmapper */
@@ -250,8 +257,6 @@
 	new->cl_autobind = 0;
 	new->cl_oneshot = 0;
 	new->cl_dead = 0;
-	if (!IS_ERR(new->cl_dentry))
-		dget(new->cl_dentry);
 	rpc_init_rtt(&new->cl_rtt_default, clnt->cl_xprt->timeout.to_initval);
 	if (new->cl_auth)
 		atomic_inc(&new->cl_auth->au_count);
@@ -313,12 +318,6 @@
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
@@ -327,6 +326,10 @@
 		xprt_destroy(clnt->cl_xprt);
 		clnt->cl_xprt = NULL;
 	}
+	if (clnt->cl_parent != clnt) {
+		rpc_destroy_client(clnt->cl_parent);
+		goto out_free;
+	}
 	if (clnt->cl_server != clnt->cl_inline_name)
 		kfree(clnt->cl_server);
 out_free:


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
