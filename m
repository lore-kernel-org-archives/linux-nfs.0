From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sun, 18 Nov 2007 14:18:06 -0500
Message-ID: <1195413486.7893.16.camel__37858.2022538923$1195417102$gmane$org@heimdal.trondhjem.org>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117180946.GA14055@elte.hu>
	<20071117101957.7562639d.akpm@linux-foundation.org>
	<64bb37e0711171140w5f1451e0qea081a4fbc7a45f7@mail.gmail.com>
	<20071117230508.GB25905@dyad>
	<64bb37e0711181044s75fd1081sdf44dac2e060d49a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-0u0k0e3Vj+pdAwCkOyen"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, steved@redhat.com,
	LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>, Ingo Molnar <mingo@elte.hu>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Itq2l-0000fM-H7
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 11:42:59 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Itq2q-0005Tu-6u
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 11:43:05 -0800
In-Reply-To: <64bb37e0711181044s75fd1081sdf44dac2e060d49a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--=-0u0k0e3Vj+pdAwCkOyen
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sun, 2007-11-18 at 19:44 +0100, Torsten Kaiser wrote:
> On Nov 18, 2007 12:05 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > I've been staring at this NFS code for a while an can't make any sense
> > out of it. It seems to correctly initialize the waitqueue. So this would
> > indicate corruption of some sort.
> 
> No, it does not "correctly" initialize the waitqueue. It doesn't even
> try to initialize it.
> 
> I now found the guilty patch and what is wrong with it.
> 
> nfs-stop-sillyname-renames-and-unmounts-from-racing.patch adds:
> 
> @@ -110,8 +112,22 @@ struct nfs_server {
>                                                    filesystem */
>  #endif
>         void (*destroy)(struct nfs_server *);
> +
> +       atomic_t active; /* Keep trace of any activity to this server */
> +       wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
> 
> and tries to initialize it:
> @@ -593,6 +593,10 @@ static int nfs_init_server(struct nfs_server *server,
>         server->namelen  = data->namlen;
>         /* Create a client RPC handle for the NFSv3 ACL management interface */
>         nfs_init_server_aclclient(server);
> +
> +       init_waitqueue_head(&server->active_wq);
> +       atomic_set(&server->active, 0);
> +
> 
> and then uses it via nfs_sb_active and nfs_sb_deactive:
> 
> @@ -29,6 +29,7 @@ struct nfs_unlinkdata {
>  static void
>  nfs_free_unlinkdata(struct nfs_unlinkdata *data)
>  {
> +       nfs_sb_deactive(NFS_SERVER(data->dir));
>         iput(data->dir);
>         put_rpccred(data->cred);
>         kfree(data->args.name.name);
> @@ -151,6 +152,7 @@ static int nfs_do_call_unlink(struct dentry
> *parent, struct inode *dir, struct n
>                 nfs_dec_sillycount(dir);
>                 return 0;
>         }
> +       nfs_sb_active(NFS_SERVER(dir));
>         data->args.fh = NFS_FH(dir);
>         nfs_fattr_init(&data->res.dir_attr);
> 
> 
> But it does not notice this:
> struct dentry_operations nfs_dentry_operations = {
>         .d_revalidate   = nfs_lookup_revalidate,
>         .d_delete       = nfs_dentry_delete,
>         .d_iput         = nfs_dentry_iput,
> };
> struct dentry_operations nfs4_dentry_operations = {
>         .d_revalidate   = nfs_open_revalidate,
>         .d_delete       = nfs_dentry_delete,
>         .d_iput         = nfs_dentry_iput,
> };
> 
> NFSv2/3 and NFSv4 share the same dentry_iput and so share the same
> unlink and sillyrename logic.
> But they do not share nfs_init_server()!
> 
> I wonder why this doesn't blow up more violently, but only hangs...
> 
> But as I don't know if it is correct to add the workqueue
> initialization to nfs4_init_server() or remove the nfs_sb_active /
> nfs_sb_deactive for the NFSv4 case, I can't offer a patch to fix this.
> 
> Torsten

I had already fixed that one in my own stack. Attached are the 3 patches
that I've got. 1 from SteveD, 2 fixes.

Andrew, could you please unapply the sillyrename patches you've got, and
apply these 3 instead?

Trond


--=-0u0k0e3Vj+pdAwCkOyen
Content-Disposition: attachment;
	filename=linux-2.6.24-005-fix_sillyrename_bug_on_umount.dif
Content-Type: message/rfc822;
	name=linux-2.6.24-005-fix_sillyrename_bug_on_umount.dif

From: Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Nov 2007 04:05:04 -0500
Subject: NFS: Stop sillyname renames and unmounts from racing
Message-Id: <1195413486.7893.17.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Added an active/deactive mechanism to the nfs_server structure
allowing async operations to hold off umount until the
operations are done.

Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    4 ++++
 fs/nfs/super.c            |   13 +++++++++++++
 fs/nfs/unlink.c           |    2 ++
 include/linux/nfs_fs_sb.h |   17 +++++++++++++++++
 4 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 70587f3..2ecf726 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -593,6 +593,10 @@ static int nfs_init_server(struct nfs_server *server,
 	server->namelen  = data->namlen;
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
 	nfs_init_server_aclclient(server);
+
+	init_waitqueue_head(&server->active_wq);
+	atomic_set(&server->active, 0);
+
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 71067d1..833aed8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -202,6 +202,7 @@ static int nfs_get_sb(struct file_system_type *, int, const char *, void *, stru
 static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
+static void nfs_put_super(struct super_block *);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -223,6 +224,7 @@ static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -1772,6 +1774,17 @@ static void nfs4_kill_super(struct super_block *sb)
 	nfs_free_server(server);
 }
 
+static void nfs_put_super(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+	/*
+	 * Make sure there are no outstanding ops to this server.
+	 * If so, wait for them to finish before allowing the
+	 * unmount to continue.
+	 */
+	wait_event(server->active_wq, atomic_read(&server->active) == 0);
+}
+
 /*
  * Clone an NFS4 server record on xdev traversal (FSID-change)
  */
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 233ad38..cf12a24 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -29,6 +29,7 @@ struct nfs_unlinkdata {
 static void
 nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
+	nfs_sb_deactive(NFS_SERVER(data->dir));
 	iput(data->dir);
 	put_rpccred(data->cred);
 	kfree(data->args.name.name);
@@ -151,6 +152,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		nfs_dec_sillycount(dir);
 		return 0;
 	}
+	nfs_sb_active(NFS_SERVER(dir));
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(&data->res.dir_attr);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0cac49b..6ef3af8 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -4,6 +4,8 @@
 #include <linux/list.h>
 #include <linux/backing-dev.h>
 
+#include <asm/atomic.h>
+
 struct nfs_iostats;
 
 /*
@@ -110,8 +112,23 @@ struct nfs_server {
 						   filesystem */
 #endif
 	void (*destroy)(struct nfs_server *);
+
+	atomic_t active; /* Keep trace of any activity to this server */
+	wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
 };
 
+static inline void 
+nfs_sb_active(struct nfs_server *server)
+{
+	atomic_inc(&server->active);
+}
+static inline void 
+nfs_sb_deactive(struct nfs_server *server)
+{
+	if (atomic_dec_and_test(&server->active))
+		wake_up(&server->active_wq);
+}
+
 /* Server capabilities */
 #define NFS_CAP_READDIRPLUS	(1U << 0)
 #define NFS_CAP_HARDLINKS	(1U << 1)

--=-0u0k0e3Vj+pdAwCkOyen
Content-Disposition: attachment;
	filename=linux-2.6.24-006-fix_to_fix_sillyrename_bug_on_umount.dif
Content-Type: message/rfc822;
	name=linux-2.6.24-006-fix_to_fix_sillyrename_bug_on_umount.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 17 Nov 2007 13:08:49 -0500
Subject: NFS: Fix up problems with Steve's sillyrename fix
Message-Id: <1195413486.7893.18.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    6 +++---
 fs/nfs/internal.h         |    2 ++
 fs/nfs/super.c            |   33 ++++++++++++++++++++++-----------
 fs/nfs/unlink.c           |    2 ++
 include/linux/nfs_fs_sb.h |   13 +------------
 5 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2ecf726..be9fecb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -594,9 +594,6 @@ static int nfs_init_server(struct nfs_server *server,
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
 	nfs_init_server_aclclient(server);
 
-	init_waitqueue_head(&server->active_wq);
-	atomic_set(&server->active, 0);
-
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
@@ -736,6 +733,9 @@ static struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->client_link);
 	INIT_LIST_HEAD(&server->master_link);
 
+	init_waitqueue_head(&server->active_wq);
+	atomic_set(&server->active, 0);
+
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {
 		kfree(server);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f3acf48..7579379 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -160,6 +160,8 @@ extern struct rpc_stat nfs_rpcstat;
 
 extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
+extern void nfs_sb_active(struct nfs_server *server);
+extern void nfs_sb_deactive(struct nfs_server *server);
 
 /* namespace.c */
 extern char *nfs_path(const char *base,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 833aed8..046d1ac 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -327,6 +327,28 @@ void __exit unregister_nfs_fs(void)
 	unregister_filesystem(&nfs_fs_type);
 }
 
+void nfs_sb_active(struct nfs_server *server)
+{
+	atomic_inc(&server->active);
+}
+
+void nfs_sb_deactive(struct nfs_server *server)
+{
+	if (atomic_dec_and_test(&server->active))
+		wake_up(&server->active_wq);
+}
+
+static void nfs_put_super(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+	/*
+	 * Make sure there are no outstanding ops to this server.
+	 * If so, wait for them to finish before allowing the
+	 * unmount to continue.
+	 */
+	wait_event(server->active_wq, atomic_read(&server->active) == 0);
+}
+
 /*
  * Deliver file system statistics to userspace
  */
@@ -1774,17 +1796,6 @@ static void nfs4_kill_super(struct super_block *sb)
 	nfs_free_server(server);
 }
 
-static void nfs_put_super(struct super_block *sb)
-{
-	struct nfs_server *server = NFS_SB(sb);
-	/*
-	 * Make sure there are no outstanding ops to this server.
-	 * If so, wait for them to finish before allowing the
-	 * unmount to continue.
-	 */
-	wait_event(server->active_wq, atomic_read(&server->active) == 0);
-}
-
 /*
  * Clone an NFS4 server record on xdev traversal (FSID-change)
  */
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index cf12a24..b97d3bb 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -14,6 +14,8 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 
+#include "internal.h"
+
 struct nfs_unlinkdata {
 	struct hlist_node list;
 	struct nfs_removeargs args;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6ef3af8..9f949b5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -3,6 +3,7 @@
 
 #include <linux/list.h>
 #include <linux/backing-dev.h>
+#include <linux/wait.h>
 
 #include <asm/atomic.h>
 
@@ -117,18 +118,6 @@ struct nfs_server {
 	wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
 };
 
-static inline void 
-nfs_sb_active(struct nfs_server *server)
-{
-	atomic_inc(&server->active);
-}
-static inline void 
-nfs_sb_deactive(struct nfs_server *server)
-{
-	if (atomic_dec_and_test(&server->active))
-		wake_up(&server->active_wq);
-}
-
 /* Server capabilities */
 #define NFS_CAP_READDIRPLUS	(1U << 0)
 #define NFS_CAP_HARDLINKS	(1U << 1)

--=-0u0k0e3Vj+pdAwCkOyen
Content-Disposition: attachment;
	filename=linux-2.6.24-007-fix_nfs_free_unlinkdata.dif
Content-Type: message/rfc822; name=linux-2.6.24-007-fix_nfs_free_unlinkdata.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 17 Nov 2007 13:52:36 -0500
Subject: NFS: Fix nfs_free_unlinkdata()
Message-Id: <1195413486.7893.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

We should really only be calling nfs_sb_deactive() at the end of an RPC
call, to balance the nfs_sb_active() call in nfs_do_call_unlink(). OTOH,
nfs_free_unlinkdata() can be called from a variety of other situations.

Fix is to move the call to nfs_sb_deactive() into
nfs_async_unlink_release().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/unlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index b97d3bb..c90862a 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -31,7 +31,6 @@ struct nfs_unlinkdata {
 static void
 nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
-	nfs_sb_deactive(NFS_SERVER(data->dir));
 	iput(data->dir);
 	put_rpccred(data->cred);
 	kfree(data->args.name.name);
@@ -116,6 +115,7 @@ static void nfs_async_unlink_release(void *calldata)
 	struct nfs_unlinkdata	*data = calldata;
 
 	nfs_dec_sillycount(data->dir);
+	nfs_sb_deactive(NFS_SERVER(data->dir));
 	nfs_free_unlinkdata(data);
 }
 

--=-0u0k0e3Vj+pdAwCkOyen
Content-Disposition: attachment; filename=series
Content-Type: text/plain; name=series; charset=utf-8
Content-Transfer-Encoding: 7bit

# This series applies on GIT commit 4c1fe2f78a08e2c514a39c91a0eb7b55bbd3c0d2
linux-2.6.24-005-fix_sillyrename_bug_on_umount.dif
linux-2.6.24-006-fix_to_fix_sillyrename_bug_on_umount.dif
linux-2.6.24-007-fix_nfs_free_unlinkdata.dif

--=-0u0k0e3Vj+pdAwCkOyen
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--=-0u0k0e3Vj+pdAwCkOyen
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--=-0u0k0e3Vj+pdAwCkOyen--



