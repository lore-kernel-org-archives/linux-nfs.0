Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:55322 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753435Ab0LaNDa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Dec 2010 08:03:30 -0500
Date: Fri, 31 Dec 2010 15:03:29 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Rob Landley <rlandley@parallels.com>
Cc: "Kirill A. Shutemov" <kas@openvz.org>, Rob Landley <rob@landley.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Message-ID: <20101231130329.GA3610@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
 <20101230085139.GA29697@shutemov.name>
 <4D1C4C7C.6050606@parallels.com>
 <20101230094433.GB29697@shutemov.name>
 <4D1C5953.6020200@parallels.com>
 <20101230104416.GA31824@shutemov.name>
 <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb@mail.gmail.com>
 <20101230114514.GA31976@shutemov.name>
 <4D1C809B.30405@parallels.com>
Content-Type: multipart/mixed; boundary="24zk1gE8NUlDmwG9"
In-Reply-To: <4D1C809B.30405@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--24zk1gE8NUlDmwG9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Dec 30, 2010 at 06:52:43AM -0600, Rob Landley wrote:
> On 12/30/2010 05:45 AM, Kirill A. Shutemov wrote:
> > Currently, there is no association between rpc_pipefs and mount namespace,
> 
> There is in that the root context doesn't need to have this mounted, and 
> new namespaces do.  So there's an existing association between a LACK of 
> a namespace and a different default behavior.
>
> My understanding (correct me if I'm wrong) is that the historical 
> behavior is that there's only one, and it doesn't actually live anywhere 
> in the filesystem tree.  You're adding a special location.  I'm 
> wondering if there's any way for that location not to be special.

/var/lib/net/rpc_pipefs is default path where userspace part of NFS stack
(gssd, idmapd) want to see rpc_pipefs

> > so I don't see simple way to restrict number of rpc_pipefs per mount
> > namespace. Associating mount namespace with rpc_pipefs is not a good idea,
> > I think.
> 
> I'm talking about associating a default rpc_pipefs instance with a 
> namespace, which it seems to me you're already doing by emulating the 
> legacy behavior.  Before you CLONE_NEWNS you get a magic default mount 
> that doesn't exist in the tree.  After you CLONE_NEWNS you get something 
> like -EINVAL unless you supply your own default.

Root namespace is special. In case of nfsroot you need rpc_pipefs before
root available.

> (I'm actually not sure 
> why new namespaces don't fall back to the magic global one...)

It breaks isolation. Container should not use host's rpc_pipefs without
host's permission.
 
> I'm suggesting that if the user doesn't specify -o rpcmount then the 
> default could be the first rpc_pipefs mount visible to the current 
> process context, rather than a specific path.  Logic to do that exists 
> in the proc/self/mounts code (which I'm reading through now...).

static int check_rpc_pipefs(struct vfsmount *mnt, void *arg)
{
        struct vfsmount **rpcmount = arg;
        struct path path = {
                .mnt = mnt,
                .dentry = mnt->mnt_root,
        };

        if (!mnt->mnt_sb)
                return 0;
        if (mnt->mnt_sb->s_magic != RPCAUTH_GSSMAGIC)
                return 0;

        if (!path_is_under(&path, &current->fs->root))
                return 0;

        *rpcmount = mntget(mnt);
        return 1;
}

struct vfsmount *get_rpc_pipefs(const char *p)
{
        int error;
        struct vfsmount *rpcmount = ERR_PTR(-EINVAL);
        struct path path;

        if (!p) {
                iterate_mounts(check_rpc_pipefs, &rpcmount,
                                current->nsproxy->mnt_ns->root);

                if (IS_ERR(rpcmount) && (current->nsproxy->mnt_ns ==
                                        init_task.nsproxy->mnt_ns))
                        return mntget(init_rpc_pipefs);

                return rpcmount;
        }

        error = kern_path(p, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
        if (error)
                return ERR_PTR(error);

        check_rpc_pipefs(path.mnt, &rpcmount);
        path_put(&path);

        return rpcmount;
}
EXPORT_SYMBOL_GPL(get_rpc_pipefs);

Something like this? Patch to replace patch #10 attached.

-- 
 Kirill A. Shutemov

--24zk1gE8NUlDmwG9
Content-Type: text/plain; charset=us-ascii; name="sunrpc-introduce-get_rpc_pipefs.patch"
Content-Disposition: attachment; filename="sunrpc-introduce-get_rpc_pipefs.patch"

>From 36bdb502360461a8426821a37728aef3a3b8c738 Mon Sep 17 00:00:00 2001
From: Kirill A. Shutemov <kas@openvz.org>
Date: Mon, 20 Dec 2010 04:03:52 +0200
Subject: [PATCH] sunrpc: introduce get_rpc_pipefs()

Get rpc_pipefs mount point by path.

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +
 net/sunrpc/rpc_pipe.c              |   51 ++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index b09bfa5..922057c 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -46,6 +46,8 @@ RPC_I(struct inode *inode)
 
 extern struct vfsmount *init_rpc_pipefs;
 
+struct vfsmount *get_rpc_pipefs(const char *path);
+
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b1e299b..4e09a90 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -16,6 +16,9 @@
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
+#include <linux/nsproxy.h>
+#include <linux/mnt_namespace.h>
+#include <linux/fs_struct.h>
 
 #include <asm/ioctls.h>
 #include <linux/fs.h>
@@ -931,6 +934,54 @@ static const struct super_operations s_ops = {
 
 #define RPCAUTH_GSSMAGIC 0x67596969
 
+static int check_rpc_pipefs(struct vfsmount *mnt, void *arg)
+{
+	struct vfsmount **rpcmount = arg;
+	struct path path = {
+		.mnt = mnt,
+		.dentry = mnt->mnt_root,
+	};
+
+	if (!mnt->mnt_sb)
+		return 0;
+	if (mnt->mnt_sb->s_magic != RPCAUTH_GSSMAGIC)
+		return 0;
+
+	if (!path_is_under(&path, &current->fs->root))
+		return 0;
+
+	*rpcmount = mntget(mnt);
+	return 1;
+}
+
+struct vfsmount *get_rpc_pipefs(const char *p)
+{
+	int error;
+	struct vfsmount *rpcmount = ERR_PTR(-EINVAL);
+	struct path path;
+
+	if (!p) {
+		iterate_mounts(check_rpc_pipefs, &rpcmount,
+				current->nsproxy->mnt_ns->root);
+
+		if (IS_ERR(rpcmount) && (current->nsproxy->mnt_ns ==
+					init_task.nsproxy->mnt_ns))
+			return mntget(init_rpc_pipefs);
+
+		return rpcmount;
+	}
+
+	error = kern_path(p, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
+	if (error)
+		return ERR_PTR(error);
+
+	check_rpc_pipefs(path.mnt, &rpcmount);
+	path_put(&path);
+
+	return rpcmount;
+}
+EXPORT_SYMBOL_GPL(get_rpc_pipefs);
+
 /*
  * We have a single directory with 1 node in it.
  */
-- 
1.7.3.4


--24zk1gE8NUlDmwG9--
