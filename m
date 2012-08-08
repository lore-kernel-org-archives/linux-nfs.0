Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:65326 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964903Ab2HHSBf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 14:01:35 -0400
Received: by ghrr11 with SMTP id r11so1073889ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 11:01:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMFXNOztZkvP963ZWAa72aAj3ydJvhLgxU2m8_20bsZV3uqwLQ@mail.gmail.com>
References: <CAMFXNOztZkvP963ZWAa72aAj3ydJvhLgxU2m8_20bsZV3uqwLQ@mail.gmail.com>
From: "bjschuma@gmail.com" <bjschuma@gmail.com>
Date: Wed, 8 Aug 2012 14:01:14 -0400
Message-ID: <CAMFXNOw0G4Yp0GZmetF6akD=YqKyXBL9aoFq=kF2wiEPwPhU0w@mail.gmail.com>
Subject: [PATCH 1/2] NFS: Fix a regression when loading the NFS v4 module
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I forgot to CC the mailing list... oops.


---------- Forwarded message ----------
From: bjschuma@gmail.com <bjschuma@gmail.com>
Date: Wed, Aug 8, 2012 at 1:57 PM
Subject: [PATCH 1/2] NFS: Fix a regression when loading the NFS v4 module
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, jlayton@redhat.com


Some systems have a modprobe.d/nfs.conf file that sets an nfs4 alias
pointing to nfs.ko, rather than nfs4.ko.  This can prevent the v4 module
from loading on mount, since the kernel sees that something named "nfs4"
has already been loaded.  To work around this, I've renamed the modules
to "nfsv2.ko" "nfsv3.ko" and "nfsv4.ko".

I also had to move the nfs4_fs_type back to nfs.ko to ensure that `mount
-t nfs4` still works.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile    | 18 +++++++++---------
 fs/nfs/client.c    |  2 +-
 fs/nfs/nfs4_fs.h   |  3 +++
 fs/nfs/nfs4super.c | 15 ---------------
 fs/nfs/super.c     | 37 ++++++++++++++++++++++++++++++++++++-
 5 files changed, 49 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8bf3a3f..b7db608 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,19 +12,19 @@ nfs-$(CONFIG_ROOT_NFS)      += nfsroot.o
 nfs-$(CONFIG_SYSCTL)   += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o

-obj-$(CONFIG_NFS_V2) += nfs2.o
-nfs2-y := nfs2super.o proc.o nfs2xdr.o
+obj-$(CONFIG_NFS_V2) += nfsv2.o
+nfsv2-y := nfs2super.o proc.o nfs2xdr.o

-obj-$(CONFIG_NFS_V3) += nfs3.o
-nfs3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
-nfs3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
+obj-$(CONFIG_NFS_V3) += nfsv3.o
+nfsv3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
+nfsv3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o

-obj-$(CONFIG_NFS_V4) += nfs4.o
-nfs4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o
nfs4file.o \
+obj-$(CONFIG_NFS_V4) += nfsv4.o
+nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o
nfs4file.o \
          delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
          nfs4namespace.o nfs4getroot.o nfs4client.o
-nfs4-$(CONFIG_SYSCTL)  += nfs4sysctl.o
-nfs4-$(CONFIG_NFS_V4_1)        += pnfs.o pnfs_dev.o
+nfsv4-$(CONFIG_SYSCTL) += nfs4sysctl.o
+nfsv4-$(CONFIG_NFS_V4_1)       += pnfs.o pnfs_dev.o

 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9fc0d9d..9969444 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -105,7 +105,7 @@ struct nfs_subversion *get_nfs_version(unsigned int version)

        if (IS_ERR(nfs)) {
                mutex_lock(&nfs_version_mutex);
-               request_module("nfs%d", version);
+               request_module("nfsv%d", version);
                nfs = find_nfs_version(version);
                mutex_unlock(&nfs_version_mutex);
        }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 19c1a56..43f4971 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -205,6 +205,9 @@ extern const struct dentry_operations
nfs4_dentry_operations;
 int nfs_atomic_open(struct inode *, struct dentry *, struct file *,
                    unsigned, umode_t, int *);

+/* super.c */
+extern struct file_system_type nfs4_fs_type;
+
 /* nfs4namespace.c */
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct
inode *, struct qstr *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 12a31a9..bd61221 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -23,14 +23,6 @@ static struct dentry *nfs4_referral_mount(struct
file_system_type *fs_type,
 static struct dentry *nfs4_remote_referral_mount(struct
file_system_type *fs_type,
        int flags, const char *dev_name, void *raw_data);

-static struct file_system_type nfs4_fs_type = {
-       .owner          = THIS_MODULE,
-       .name           = "nfs4",
-       .mount          = nfs_fs_mount,
-       .kill_sb        = nfs_kill_super,
-       .fs_flags       =
FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
 static struct file_system_type nfs4_remote_fs_type = {
        .owner          = THIS_MODULE,
        .name           = "nfs4",
@@ -344,14 +336,8 @@ static int __init init_nfs_v4(void)
        if (err)
                goto out1;

-       err = register_filesystem(&nfs4_fs_type);
-       if (err < 0)
-               goto out2;
-
        register_nfs_version(&nfs_v4);
        return 0;
-out2:
-       nfs4_unregister_sysctl();
 out1:
        nfs_idmap_quit();
 out:
@@ -361,7 +347,6 @@ out:
 static void __exit exit_nfs_v4(void)
 {
        unregister_nfs_version(&nfs_v4);
-       unregister_filesystem(&nfs4_fs_type);
        nfs4_unregister_sysctl();
        nfs_idmap_quit();
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ac6a3c5..c4a15c5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -319,6 +319,34 @@ EXPORT_SYMBOL_GPL(nfs_sops);
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
 static int nfs4_validate_mount_data(void *options,
        struct nfs_parsed_mount_data *args, const char *dev_name);
+
+struct file_system_type nfs4_fs_type = {
+       .owner          = THIS_MODULE,
+       .name           = "nfs4",
+       .mount          = nfs_fs_mount,
+       .kill_sb        = nfs_kill_super,
+       .fs_flags       =
FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+EXPORT_SYMBOL_GPL(nfs4_fs_type);
+
+static int __init register_nfs4_fs(void)
+{
+       return register_filesystem(&nfs4_fs_type);
+}
+
+static void unregister_nfs4_fs(void)
+{
+       unregister_filesystem(&nfs4_fs_type);
+}
+#else
+static int __init register_nfs4_fs(void)
+{
+       return 0;
+}
+
+static void unregister_nfs4_fs(void)
+{
+}
 #endif

 static struct shrinker acl_shrinker = {
@@ -337,12 +365,18 @@ int __init register_nfs_fs(void)
        if (ret < 0)
                goto error_0;

-       ret = nfs_register_sysctl();
+       ret = register_nfs4_fs();
        if (ret < 0)
                goto error_1;
+
+       ret = nfs_register_sysctl();
+       if (ret < 0)
+               goto error_2;
        register_shrinker(&acl_shrinker);
        return 0;

+error_2:
+       unregister_nfs4_fs();
 error_1:
        unregister_filesystem(&nfs_fs_type);
 error_0:
@@ -356,6 +390,7 @@ void __exit unregister_nfs_fs(void)
 {
        unregister_shrinker(&acl_shrinker);
        nfs_unregister_sysctl();
+       unregister_nfs4_fs();
        unregister_filesystem(&nfs_fs_type);
 }

--
1.7.11.4
