Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48602 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758219Ab0IGUOC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:14:02 -0400
Message-ID: <4C869D00.8030604@suse.de>
Date: Wed, 08 Sep 2010 01:43:52 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC][PATCH] nfs: support legacy NFS flock behavior via mount
 option
References: <4C84DFA7.7050507@suse.de> <1283869039.4291.16.camel@heimdal.trondhjem.org>
In-Reply-To: <1283869039.4291.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/07/2010 07:47 PM, Trond Myklebust wrote:
> On Mon, 2010-09-06 at 18:03 +0530, Suresh Jayaraman wrote:
>> NFS clients since 2.6.12 support flock()locks by emulating the
>> BSD-style locks in terms of POSIX byte range locks. So the NFS client
>> does not allow to lock the same file using both flock() and fcntl
>> byte-range locks.
>>
>> For some Windows applications which seem to use both share mode locks
>> (flock()) and fcntl byte range locks sequentially on the same file,
>> the locking is failing as the lock has already been acquired. i.e. the
>> flock mapped as posix locks collide with actual byte range locks from
>> the same process. The problem was observed on a setup with Windows
>> clients accessing Excel files on a Samba exported share which is
>> originally a NFS mount from a NetApp filer. Since kernels < 2.6.12 does
>> not support flock, what was working (as flock locks were local) in
>> older kernels is not working with newer kernels.
>>
>> This could be seen as a bug in the implementation of the windows
>> application or a NFS client regression, but that is debatable.
>> In the spirit of not breaking existing setups, this patch adds mount
>> options "flock=local" that enables older flock behavior and
>> "flock=fcntl" that allows the current flock behavior.
> 
> So instead of having a special option for flock only, what say we rather
> introduce an option of the form
> 
>   -olocal_lock=
> 
> which can take the values 'none', 'flock', 'fcntl' (or 'posix'?) and
> 'all'?
> 

Sounds good. I just figured out Solaris and HPUX (perhaps few other
Unixes too) already support "llock" mount option (short form of local
lock) with similar semantics. So, I think it would make sense for us to
adapt the same. But, if you think "local_lock" is better, please do a
s/llock/local_lock on the below patch.

---
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH] nfs: introduce mount option 'llock' to make locks local

NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
locks. Due to this, some windows applications which seem to use both flock and
fcntl locks sequentially on the same file, can't lock as they falsely assume
the file is already locked. The problem was reported on a setup with windows
clients accessing excel files on a Samba exported share which is originally a
NFS mount from a NetApp filer.

Older NFS clients (< 2.6.12) did not see this problem as flock locks were
considered local. To support legacy flock behavior, this patch adds a mount
option "-ollock=" which can take the following values:

   'none'  		- Neither of flock locks and fcntl/posix locks are local
   'flock'/'posix' 	- flock locks are local
   'fcntl' 		- fcntl locks are local
   'all'		- Both flock locks and fcntl/posix locks are local


Cc: Neil Brown <neilb@suse.de>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 fs/nfs/file.c             |   15 ++++++++++++---
 fs/nfs/super.c            |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_mount.h |    3 +++
 3 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index eb51bd6..a13a83e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -800,8 +800,13 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 
 	nfs_inc_stats(inode, NFSIOS_VFSLOCK);
 
-	/* No mandatory locks over NFS */
-	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
+	/*
+	 * No mandatory locks over NFS.
+	 * fcntl lock is local if mounted with "-o llock=fcntl" or
+	 * "-o llock=posix"
+	 */
+	if ((__mandatory_lock(inode) && fl->fl_type != F_UNLCK) ||
+			(NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FCNTL))
 		goto out_err;
 
 	if (NFS_PROTO(inode)->lock_check_bounds != NULL) {
@@ -825,12 +830,16 @@ out_err:
  */
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 {
+	struct inode *inode = filp->f_mapping->host;
+
 	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
 			filp->f_path.dentry->d_name.name,
 			fl->fl_type, fl->fl_flags);
 
-	if (!(fl->fl_flags & FL_FLOCK))
+	/* flock is local if mounted with "-o llock=flock" */
+	if ((NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK) ||
+			(!(fl->fl_flags & FL_FLOCK)))
 		return -ENOLCK;
 
 	/* We're simulating flock() locks using posix locks on the server */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ec3966e..7769dd3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -100,6 +100,7 @@ enum {
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
+	Opt_llock,
 
 	/* Special mount options */
 	Opt_userspace, Opt_deprecated, Opt_sloppy,
@@ -171,6 +172,7 @@ static const match_table_t nfs_mount_option_tokens = {
 
 	{ Opt_lookupcache, "lookupcache=%s" },
 	{ Opt_fscache_uniq, "fsc=%s" },
+	{ Opt_llock, "llock=%s" },
 
 	{ Opt_err, NULL }
 };
@@ -236,6 +238,21 @@ static match_table_t nfs_lookupcache_tokens = {
 	{ Opt_lookupcache_err, NULL }
 };
 
+enum {
+	Opt_llock_all, Opt_llock_flock, Opt_llock_fcntl, Opt_llock_none,
+	Opt_llock_err
+};
+
+static match_table_t nfs_llock_tokens = {
+	{ Opt_llock_all, "all" },
+	{ Opt_llock_flock, "flock" },
+	{ Opt_llock_fcntl, "fcntl" },
+	{ Opt_llock_fcntl, "posix" },
+	{ Opt_llock_none, "none" },
+
+	{ Opt_llock_err, NULL }
+};
+
 
 static void nfs_umount_begin(struct super_block *);
 static int  nfs_statfs(struct dentry *, struct kstatfs *);
@@ -1412,6 +1429,33 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->fscache_uniq = string;
 			mnt->options |= NFS_OPTION_FSCACHE;
 			break;
+		case Opt_llock:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			token = match_token(string, nfs_llock_tokens, args);
+			kfree(string);
+			switch (token) {
+			case Opt_llock_all:
+				mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
+					       NFS_MOUNT_LOCAL_FCNTL);
+				break;
+			case Opt_llock_flock:
+				mnt->flags |= NFS_MOUNT_LOCAL_FLOCK;
+				break;
+			case Opt_llock_fcntl:
+				mnt->flags |= NFS_MOUNT_LOCAL_FCNTL;
+				break;
+			case Opt_llock_none:
+				mnt->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
+						NFS_MOUNT_LOCAL_FCNTL);
+				break;
+			default:
+				dfprintk(MOUNT, "NFS:	invalid	"
+						"llock argument\n");
+				return 0;
+			};
+			break;
 
 		/*
 		 * Special options
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 5d59ae8..576bddd 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -71,4 +71,7 @@ struct nfs_mount_data {
 #define NFS_MOUNT_NORESVPORT		0x40000
 #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
 
+#define NFS_MOUNT_LOCAL_FLOCK	0x100000
+#define NFS_MOUNT_LOCAL_FCNTL	0x200000
+
 #endif


