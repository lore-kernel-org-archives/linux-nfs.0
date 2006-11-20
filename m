From: Open Source <opensource3141@yahoo.com>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Mon, 20 Nov 2006 11:47:00 -0800 (PST)
Message-ID: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Hi Trond,

I can confirm that I also see a crash with your patch file in place!
I'm not sure if that's because it didn't apply cleanly to begin with
and my massaging might have caused a problem.  I don't think
so though.

Basically if you mount a couple NFSv3+krb5 partitions and
then unmount one of them, the system locks up after about 2
seconds.  I didn't see this before since I didn't use the
automounter utility.

Thanks,
Paarvai


----- Original Message ----
From: Kostas Georgiou <k.georgiou@imperial.ac.uk>
To: Open Source <opensource3141@yahoo.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>; nfs@lists.sourceforge.net; nfsv4@linux-nfs.org
Sent: Saturday, November 18, 2006 7:15:04 AM
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5 volume!

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
     struct dentry *        cl_dentry;    /* inode */
     struct rpc_clnt *    cl_parent;    /* Points to parent of clones */
     struct rpc_rtt        cl_rtt_default;
+    struct rpc_program *    cl_program;
     struct rpc_portmap    cl_pmap_default;
     char            cl_inline_name[32];
 };
diff -u a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -154,6 +154,7 @@
     clnt->cl_prot     = xprt->prot;
     clnt->cl_stats    = program->stats;
     clnt->cl_metrics  = rpc_alloc_iostats(clnt);
+    clnt->cl_program  = program;
     rpc_init_wait_queue(&clnt->cl_pmap_default.pm_bindwait, "bindwait");
 
     if (!clnt->cl_port)
@@ -235,6 +236,7 @@
 rpc_clone_client(struct rpc_clnt *clnt)
 {
     struct rpc_clnt *new;
+    int err;
 
     new = kmalloc(sizeof(*new), GFP_KERNEL);
     if (!new)
@@ -242,6 +244,11 @@
     memcpy(new, clnt, sizeof(*new));
     atomic_set(&new->cl_count, 1);
     atomic_set(&new->cl_users, 0);
+    err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
+    if (err != 0) {
+        kfree(new);
+        return ERR_PTR(err);
+    }
     new->cl_parent = clnt;
     atomic_inc(&clnt->cl_count);
     /* Duplicate portmapper */
@@ -250,8 +257,6 @@
     new->cl_autobind = 0;
     new->cl_oneshot = 0;
     new->cl_dead = 0;
-    if (!IS_ERR(new->cl_dentry))
-        dget(new->cl_dentry);
     rpc_init_rtt(&new->cl_rtt_default, clnt->cl_xprt->timeout.to_initval);
     if (new->cl_auth)
         atomic_inc(&new->cl_auth->au_count);
@@ -313,12 +318,6 @@
         rpcauth_destroy(clnt->cl_auth);
         clnt->cl_auth = NULL;
     }
-    if (clnt->cl_parent != clnt) {
-        if (!IS_ERR(clnt->cl_dentry))
-            dput(clnt->cl_dentry);
-        rpc_destroy_client(clnt->cl_parent);
-        goto out_free;
-    }
     if (!IS_ERR(clnt->cl_dentry)) {
         rpc_rmdir(clnt->cl_dentry);
         rpc_put_mount();
@@ -327,6 +326,10 @@
         xprt_destroy(clnt->cl_xprt);
         clnt->cl_xprt = NULL;
     }
+    if (clnt->cl_parent != clnt) {
+        rpc_destroy_client(clnt->cl_parent);
+        goto out_free;
+    }
     if (clnt->cl_server != clnt->cl_inline_name)
         kfree(clnt->cl_server);
 out_free:
