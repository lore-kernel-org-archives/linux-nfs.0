Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758560Ab2HHOnA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 10:43:00 -0400
Message-ID: <50227AE9.2020600@netapp.com>
Date: Wed, 08 Aug 2012 10:42:49 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
References: <20120804000819.GB25558@fieldses.org>  <20120803220039.743fe1f0@corrin.poochiereds.net>  <20120804190104.GA2135@fieldses.org>  <20120807130932.79625d7e@tlielax.poochiereds.net>  <20120807194250.GB22532@fieldses.org> <50217035.5010304@netapp.com>  <20120807195703.GC22532@fieldses.org> <50217649.6010402@netapp.com>  <20120807202523.GD22532@fieldses.org> <1344374613.8845.3.camel@lade.trondhjem.org>
In-Reply-To: <1344374613.8845.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 05:23 PM, Myklebust, Trond wrote:
> On Tue, 2012-08-07 at 16:25 -0400, J. Bruce Fields wrote:
>> On Tue, Aug 07, 2012 at 04:10:49PM -0400, Bryan Schumaker wrote:
>>> On 08/07/2012 03:57 PM, J. Bruce Fields wrote:
>>>> On Tue, Aug 07, 2012 at 03:44:53PM -0400, Bryan Schumaker wrote:
>>>>> On 08/07/2012 03:42 PM, J. Bruce Fields wrote:
>>>>>> On Tue, Aug 07, 2012 at 01:09:32PM -0400, Jeff Layton wrote:
>>>>>>> On Sat, 4 Aug 2012 15:01:04 -0400
>>>>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>>>
>>>>>>>> On Fri, Aug 03, 2012 at 10:00:39PM -0400, Jeff Layton wrote:
>>>>>>>>> On Fri, 3 Aug 2012 20:08:19 -0400
>>>>>>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>>>>>
>>>>>>>>>> I'm getting
>>>>>>>>>>
>>>>>>>>>> 	# mount -tnfs -onfsvers=4 pip1:/exports /mnt/
>>>>>>>>>>
>>>>>>>>>> (OK, admittedly that's with 3.6.0-rc1 + a few experimental patches, but
>>>>>>>>>> I doubt they're related.)
>>>>>>>>>>
>>>>>>>>>> Also:
>>>>>>>>>>
>>>>>>>>>> 	[root@pip2 ~]# modprobe nfs4
>>>>>>>>>> 	[root@pip2 ~]# lsmod|grep nfs4
>>>>>>>>>> 	[root@pip2 ~]# 
>>>>>>>>>>
>>>>>>>>>> --b.
>>>>>>>>>
>>>>>>>>> I hit the same problem...
>>>>>>>>>
>>>>>>>>> Try removing /usr/lib/modprobe.d/nfs.conf (assuming you're running
>>>>>>>>> Fedora).
>>>>>>>>
>>>>>>>> Oog, right.
>>>>>>>>
>>>>>>>> But, without testing--won't that make v4 mounts fail on older kernels?
>>>>>>>
>>>>>>> Actually, now that I look, this does not seem to break on older kernels
>>>>>>> as long as you use a syntax like:
>>>>>>>
>>>>>>>     # mount -t nfs server:/export /mnt/point -o vers=4
>>>>>>>
>>>>>>> ...if, however you use a syntax like:
>>>>>>>
>>>>>>>     # mount -t nfs4 server:/export /mnt/point
>>>>>>>
>>>>>>> ...then it fails without the above file in place. I guess the question
>>>>>>> we have to answer is: Do we want to continue to support the "-t nfs4"
>>>>>>> mount syntax?
>>>>>>
>>>>>> I think you're right that we want to deprecate it.
>>>>>>
>>>>>> Though this is a bit of a harsh way to do it--would have been nice to
>>>>>> have some transition period with a warning or something.
>>>>>
>>>>> I didn't expect this to be broken, both ways of mounting still work on my VMs so I expected them to work for everybody else too.
>>>>
>>>> Huh.  Just checked on an old kernel without an "alias nfs4 nfs" in
>>>> modprobe configuration, and sure enough I get "No such device".
>>>>
>>>> Maybe you have some initscripts or something else that's loading the
>>>> nfs module for you before the mount?
>>>
>>> My nfs-common daemon script loads sunrpc, nfs
>>
>> Yep, that's why you're not seeing it.
>>
>>> and nfsd but not nfs2, nfs3 or nfs4.
>>>
>>> Could we rename the module to avoid the alias name collision?  Something like this (untested) maybe?
>>
>> I don't think that will help.
> 
> It should if we also add back in
> 
> struct file_system_type nfs4_fs_type = {
>         .owner          = THIS_MODULE,
>         .name           = "nfs4",
>         .mount          = nfs_fs_mount,
>         .kill_sb        = nfs_kill_super,
>         .fs_flags       = FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
> };
> 
> and then add that to register_nfs_fs()/unregister_nfs_fs(). As far as I
> can see, that will trigger all the right incantations in
> nfs_validate_mount_data() to mount an NFSv4 filesystem.

So you're suggesting something like this?  I can split it into two patches for the final submission, one to rename the modules and one to move the nfs4_fs_type back to nfs.ko.

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8bf3a3f..b7db608 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,19 +12,19 @@ nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_SYSCTL)	+= sysctl.o
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
-nfs4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
+obj-$(CONFIG_NFS_V4) += nfsv4.o
+nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
 	  delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
 	  nfs4namespace.o nfs4getroot.o nfs4client.o
-nfs4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
-nfs4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
+nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
+nfsv4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9fc0d9d..9969444 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -105,7 +105,7 @@ struct nfs_subversion *get_nfs_version(unsigned int version)
 
 	if (IS_ERR(nfs)) {
 		mutex_lock(&nfs_version_mutex);
-		request_module("nfs%d", version);
+		request_module("nfsv%d", version);
 		nfs = find_nfs_version(version);
 		mutex_unlock(&nfs_version_mutex);
 	}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 19c1a56..43f4971 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -205,6 +205,9 @@ extern const struct dentry_operations nfs4_dentry_operations;
 int nfs_atomic_open(struct inode *, struct dentry *, struct file *,
 
+/* super.c */
+extern struct file_system_type nfs4_fs_type;
+
 /* nfs4namespace.c */
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 12a31a9..bd61221 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -23,14 +23,6 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 
-static struct file_system_type nfs4_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs_fs_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
 static struct file_system_type nfs4_remote_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
@@ -344,14 +336,8 @@ static int __init init_nfs_v4(void)
 	if (err)
 		goto out1;
 
-	err = register_filesystem(&nfs4_fs_type);
-	if (err < 0)
-		goto out2;
-
 	register_nfs_version(&nfs_v4);
 	return 0;
-out2:
-	nfs4_unregister_sysctl();
 out1:
 	nfs_idmap_quit();
 out:
@@ -361,7 +347,6 @@ out:
 static void __exit exit_nfs_v4(void)
 {
 	unregister_nfs_version(&nfs_v4);
-	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
 	nfs_idmap_quit();
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ac6a3c5..49b2dfa 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -319,6 +319,15 @@ EXPORT_SYMBOL_GPL(nfs_sops);
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
 static int nfs4_validate_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
+
+struct file_system_type nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.mount		= nfs_fs_mount,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+EXPORT_SYMBOL_GPL(nfs4_fs_type);
 #endif
 
 static struct shrinker acl_shrinker = {
@@ -326,6 +335,27 @@ static struct shrinker acl_shrinker = {
 	.seeks		= DEFAULT_SEEKS,
 };
 
+#if IS_ENABLED(CONFIG_NFS_V4)
+static int __init register_nfs4_fs(void)
+{
+	return register_filesystem(&nfs4_fs_type);
+}
+
+static void unregister_nfs4_fs(void)
+{
+	unregister_filesystem(&nfs4_fs_type);
+}
+#else
+static int __init register_nfs4_fs(void)
+{
+	return 0;
+}
+
+static void unregister_nfs4_fs(void)
+{
+}
+#endif /* CONFIG_NFS_V4 */
+
 /*
  * Register the NFS filesystems
  */
@@ -337,12 +367,18 @@ int __init register_nfs_fs(void)
 	if (ret < 0)
 		goto error_0;
 
-	ret = nfs_register_sysctl();
+	ret = register_nfs4_fs();
 	if (ret < 0)
 		goto error_1;
+
+	ret = nfs_register_sysctl();
+	if (ret < 0)
+		goto error_2;
 	register_shrinker(&acl_shrinker);
 	return 0;
 
+error_2:
+	unregister_nfs4_fs();
 error_1:
 	unregister_filesystem(&nfs_fs_type);
 error_0:
@@ -356,6 +392,7 @@ void __exit unregister_nfs_fs(void)
 {
 	unregister_shrinker(&acl_shrinker);
 	nfs_unregister_sysctl();
+	unregister_nfs4_fs();
 	unregister_filesystem(&nfs_fs_type);
 }
 


> 
>>>
>>>
>>>
>>> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
>>> index 8bf3a3f..b7db608 100644
>>> --- a/fs/nfs/Makefile
>>> +++ b/fs/nfs/Makefile
>>> @@ -12,19 +12,19 @@ nfs-$(CONFIG_ROOT_NFS)      += nfsroot.o
>>>  nfs-$(CONFIG_SYSCTL)   += sysctl.o
>>>  nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
>>>  
>>> -obj-$(CONFIG_NFS_V2) += nfs2.o
>>> -nfs2-y := nfs2super.o proc.o nfs2xdr.o
>>> +obj-$(CONFIG_NFS_V2) += nfsv2.o
>>> +nfsv2-y := nfs2super.o proc.o nfs2xdr.o
>>>  
>>> -obj-$(CONFIG_NFS_V3) += nfs3.o
>>> -nfs3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
>>> -nfs3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
>>> +obj-$(CONFIG_NFS_V3) += nfsv3.o
>>> +nfsv3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
>>> +nfsv3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
>>>  
>>> -obj-$(CONFIG_NFS_V4) += nfs4.o
>>> -nfs4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
>>> +obj-$(CONFIG_NFS_V4) += nfsv4.o
>>> +nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
>>>           delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
>>>           nfs4namespace.o nfs4getroot.o nfs4client.o
>>> -nfs4-$(CONFIG_SYSCTL)  += nfs4sysctl.o
>>> -nfs4-$(CONFIG_NFS_V4_1)        += pnfs.o pnfs_dev.o
>>> +nfsv4-$(CONFIG_SYSCTL) += nfs4sysctl.o
>>> +nfsv4-$(CONFIG_NFS_V4_1)       += pnfs.o pnfs_dev.o
>>>  
>>>  obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
>>>  nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>> index 9fc0d9d..9969444 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -105,7 +105,7 @@ struct nfs_subversion *get_nfs_version(unsigned int version)
>>>  
>>>         if (IS_ERR(nfs)) {
>>>                 mutex_lock(&nfs_version_mutex);
>>> -               request_module("nfs%d", version);
>>> +               request_module("nfsv%d", version);
>>>                 nfs = find_nfs_version(version);
>>>                 mutex_unlock(&nfs_version_mutex);
>>>         }
>>>
>>>
>>>>
>>>> --b.
>>>>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

