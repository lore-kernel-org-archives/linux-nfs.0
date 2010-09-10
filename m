Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:53924 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962Ab0IJGJZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Sep 2010 02:09:25 -0400
Message-ID: <4C89CB8C.5050404@suse.de>
Date: Fri, 10 Sep 2010 11:39:16 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: Neil Brown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make locks
 local
References: <4C893746.6090202@suse.de>	<20100909162037.20c4ebec@tlielax.poochiereds.net>	<4C896A59.8060903@suse.de>	<1284083063.2764.12.camel@heimdal.trondhjem.org>	<4C89AF05.408@suse.de> <20100910142456.387c9fbb@notabene>
In-Reply-To: <20100910142456.387c9fbb@notabene>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/10/2010 09:54 AM, Neil Brown wrote:
> On Fri, 10 Sep 2010 09:37:33 +0530
> Suresh Jayaraman <sjayaraman@suse.de> wrote:
>> ---
>> From: Suresh Jayaraman <sjayaraman@suse.de>
>> Subject: [PATCH] nfs: introduce mount option '-olocal_lock' to make locks local
>>
>> NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
>> locks. Due to this, some windows applications which seem to use both flock
>> (share mode lock mapped as flock by Samba) and fcntl locks sequentially on
>> the same file, can't lock as they falsely assume the file is already locked.
>> The problem was reported on a setup with windows clients accessing excel files
>> on a Samba exported share which is originally a NFS mount from a NetApp filer.
>>
>> Older NFS clients (< 2.6.12) did not see this problem as flock locks were
>> considered local. To support legacy flock behavior, this patch adds a mount
>> option "-olocal_lock=" which can take the following values:
>>
>>    'none'  		- Neither flock locks nor POSIX locks are local
>>    'flock' 		- flock locks are local
>>    'posix' 		- fcntl/POSIX locks are local
>>    'all'		- Both flock locks and POSIX locks are local
>>
>> Testing:
>>
>> This patch was tested by using -olocal_lock option with different values and
>> the NLM calls were noted from the network packet captured.
>>
>>    'none'  - NLM calls were seen during both flock() and fcntl(), flock lock
>>    	     was granted, fcntl was denied
>>    'flock' - no NLM calls for flock(), NLM call was seen for fcntl(),
>>    	     granted
>>    'posix' - NLM call was seen for flock() - granted, no NLM call for fcntl()
>>    'all'   - no NLM calls were seen during both flock() and fcntl()
>>
>> Cc: Neil Brown <neilb@suse.de>
>> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
>> ---
>>  fs/nfs/client.c           |    6 +++-
>>  fs/nfs/file.c             |   35 +++++++++++++++++++++++----------
>>  fs/nfs/super.c            |   46 +++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/nfs_mount.h |    5 +++-
>>  4 files changed, 78 insertions(+), 14 deletions(-)
>>
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 4e7df2a..5f01f42 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -635,7 +635,8 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
>>   */
>>  static void nfs_destroy_server(struct nfs_server *server)
>>  {
>> -	if (!(server->flags & NFS_MOUNT_NONLM))
>> +	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
>> +			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
>>  		nlmclnt_done(server->nlm_host);
>>  }
>>  
>> @@ -657,7 +658,8 @@ static int nfs_start_lockd(struct nfs_server *server)
>>  
>>  	if (nlm_init.nfs_version > 3)
>>  		return 0;
>> -	if (server->flags & NFS_MOUNT_NONLM)
>> +	if ((server->flags & NFS_MOUNT_LOCAL_FLOCK) &&
>> +			(server->flags & NFS_MOUNT_LOCAL_FCNTL))
>>  		return 0;
>>  
>>  	switch (clp->cl_proto) {
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index eb51bd6..e338d37 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -684,7 +684,8 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
>>  	return ret;
>>  }
>>  
>> -static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
>> +static int
>> +do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>>  {
>>  	struct inode *inode = filp->f_mapping->host;
>>  	int status = 0;
>> @@ -699,7 +700,7 @@ static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
>>  	if (nfs_have_delegation(inode, FMODE_READ))
>>  		goto out_noconflict;
>>  
>> -	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)
>> +	if ((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) || is_local)
>>  		goto out_noconflict;
> 
> I cannot figure out why this isn't simply
>         if (is_local)
> 		goto out_noconflict;
> 

Yes, just checking is_local is sufficient since we set NFS_MOUNT_NONLM to NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL. Here's the fixed version:

Changes since last post:
  - remove unneeded NFS_MOUNT_NONLM flag checks from do_getlk()/do_setlk()/do_unlck
  - update comments to include the new mount option


From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH] nfs: introduce mount option '-olocal_lock' to make locks local

NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
locks. Due to this, some windows applications which seem to use both flock
(share mode lock mapped as flock by Samba) and fcntl locks sequentially on
the same file, can't lock as they falsely assume the file is already locked.
The problem was reported on a setup with windows clients accessing excel files
on a Samba exported share which is originally a NFS mount from a NetApp filer.

Older NFS clients (< 2.6.12) did not see this problem as flock locks were
considered local. To support legacy flock behavior, this patch adds a mount
option "-olocal_lock=" which can take the following values:

   'none'  		- Neither flock locks nor POSIX locks are local
   'flock' 		- flock locks are local
   'posix' 		- fcntl/POSIX locks are local
   'all'		- Both flock locks and POSIX locks are local

Testing:

This patch was tested by using -olocal_lock option with different values and
the NLM calls were noted from the network packet captured.

   'none'  - NLM calls were seen during both flock() and fcntl(), flock lock
   	     was granted, fcntl was denied
   'flock' - no NLM calls for flock(), NLM call was seen for fcntl(),
   	     granted
   'posix' - NLM call was seen for flock() - granted, no NLM call for fcntl()
   'all'   - no NLM calls were seen during both flock() and fcntl()

Cc: Neil Brown <neilb@suse.de>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 fs/nfs/client.c           |    6 +++-
 fs/nfs/file.c             |   45 +++++++++++++++++++++++++++++++------------
 fs/nfs/super.c            |   46 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_mount.h |    5 +++-
 4 files changed, 86 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4e7df2a..5f01f42 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -635,7 +635,8 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
  */
 static void nfs_destroy_server(struct nfs_server *server)
 {
-	if (!(server->flags & NFS_MOUNT_NONLM))
+	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
+			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
 		nlmclnt_done(server->nlm_host);
 }
 
@@ -657,7 +658,8 @@ static int nfs_start_lockd(struct nfs_server *server)
 
 	if (nlm_init.nfs_version > 3)
 		return 0;
-	if (server->flags & NFS_MOUNT_NONLM)
+	if ((server->flags & NFS_MOUNT_LOCAL_FLOCK) &&
+			(server->flags & NFS_MOUNT_LOCAL_FCNTL))
 		return 0;
 
 	switch (clp->cl_proto) {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index eb51bd6..59cbe1b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -684,7 +684,8 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 	return ret;
 }
 
-static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
+static int
+do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int status = 0;
@@ -699,7 +700,7 @@ static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
 	if (nfs_have_delegation(inode, FMODE_READ))
 		goto out_noconflict;
 
-	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)
+	if (is_local)
 		goto out_noconflict;
 
 	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
@@ -730,7 +731,8 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
 	return res;
 }
 
-static int do_unlk(struct file *filp, int cmd, struct file_lock *fl)
+static int
+do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int status;
@@ -745,15 +747,19 @@ static int do_unlk(struct file *filp, int cmd, struct file_lock *fl)
 	 * 	If we're signalled while cleaning up locks on process exit, we
 	 * 	still need to complete the unlock.
 	 */
-	/* Use local locking if mounted with "-onolock" */
-	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
+	/*
+	 * Use local locking if mounted with "-onolock" or with appropriate
+	 * "-olocal_lock="
+	 */
+	if (!is_local)
 		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
 	else
 		status = do_vfs_lock(filp, fl);
 	return status;
 }
 
-static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
+static int
+do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int status;
@@ -766,8 +772,11 @@ static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
 	if (status != 0)
 		goto out;
 
-	/* Use local locking if mounted with "-onolock" */
-	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
+	/*
+	 * Use local locking if mounted with "-onolock" or with appropriate
+	 * "-olocal_lock="
+	 */
+	if (!is_local)
 		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
 	else
 		status = do_vfs_lock(filp, fl);
@@ -791,6 +800,7 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int ret = -ENOLCK;
+	int is_local = 0;
 
 	dprintk("NFS: lock(%s/%s, t=%x, fl=%x, r=%lld:%lld)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
@@ -804,6 +814,9 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
 		goto out_err;
 
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FCNTL)
+		is_local = 1;
+
 	if (NFS_PROTO(inode)->lock_check_bounds != NULL) {
 		ret = NFS_PROTO(inode)->lock_check_bounds(fl);
 		if (ret < 0)
@@ -811,11 +824,11 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 	}
 
 	if (IS_GETLK(cmd))
-		ret = do_getlk(filp, cmd, fl);
+		ret = do_getlk(filp, cmd, fl, is_local);
 	else if (fl->fl_type == F_UNLCK)
-		ret = do_unlk(filp, cmd, fl);
+		ret = do_unlk(filp, cmd, fl, is_local);
 	else
-		ret = do_setlk(filp, cmd, fl);
+		ret = do_setlk(filp, cmd, fl, is_local);
 out_err:
 	return ret;
 }
@@ -825,6 +838,9 @@ out_err:
  */
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 {
+	struct inode *inode = filp->f_mapping->host;
+	int is_local = 0;
+
 	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
 			filp->f_path.dentry->d_name.name,
@@ -833,14 +849,17 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	if (!(fl->fl_flags & FL_FLOCK))
 		return -ENOLCK;
 
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
+		is_local = 1;
+
 	/* We're simulating flock() locks using posix locks on the server */
 	fl->fl_owner = (fl_owner_t)filp;
 	fl->fl_start = 0;
 	fl->fl_end = OFFSET_MAX;
 
 	if (fl->fl_type == F_UNLCK)
-		return do_unlk(filp, cmd, fl);
-	return do_setlk(filp, cmd, fl);
+		return do_unlk(filp, cmd, fl, is_local);
+	return do_setlk(filp, cmd, fl, is_local);
 }
 
 /*
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ec3966e..78c08e9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -100,6 +100,7 @@ enum {
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
+	Opt_local_lock,
 
 	/* Special mount options */
 	Opt_userspace, Opt_deprecated, Opt_sloppy,
@@ -171,6 +172,7 @@ static const match_table_t nfs_mount_option_tokens = {
 
 	{ Opt_lookupcache, "lookupcache=%s" },
 	{ Opt_fscache_uniq, "fsc=%s" },
+	{ Opt_local_lock, "local_lock=%s" },
 
 	{ Opt_err, NULL }
 };
@@ -236,6 +238,22 @@ static match_table_t nfs_lookupcache_tokens = {
 	{ Opt_lookupcache_err, NULL }
 };
 
+enum {
+	Opt_local_lock_all, Opt_local_lock_flock, Opt_local_lock_posix,
+	Opt_local_lock_none,
+
+	Opt_local_lock_err
+};
+
+static match_table_t nfs_local_lock_tokens = {
+	{ Opt_local_lock_all, "all" },
+	{ Opt_local_lock_flock, "flock" },
+	{ Opt_local_lock_posix, "posix" },
+	{ Opt_local_lock_none, "none" },
+
+	{ Opt_local_lock_err, NULL }
+};
+
 
 static void nfs_umount_begin(struct super_block *);
 static int  nfs_statfs(struct dentry *, struct kstatfs *);
@@ -1412,6 +1430,34 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->fscache_uniq = string;
 			mnt->options |= NFS_OPTION_FSCACHE;
 			break;
+		case Opt_local_lock:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			token = match_token(string, nfs_local_lock_tokens,
+					args);
+			kfree(string);
+			switch (token) {
+			case Opt_local_lock_all:
+				mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
+					       NFS_MOUNT_LOCAL_FCNTL);
+				break;
+			case Opt_local_lock_flock:
+				mnt->flags |= NFS_MOUNT_LOCAL_FLOCK;
+				break;
+			case Opt_local_lock_posix:
+				mnt->flags |= NFS_MOUNT_LOCAL_FCNTL;
+				break;
+			case Opt_local_lock_none:
+				mnt->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
+						NFS_MOUNT_LOCAL_FCNTL);
+				break;
+			default:
+				dfprintk(MOUNT, "NFS:	invalid	"
+						"local_lock argument\n");
+				return 0;
+			};
+			break;
 
 		/*
 		 * Special options
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 5d59ae8..d6a16cc 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -56,7 +56,6 @@ struct nfs_mount_data {
 #define NFS_MOUNT_TCP		0x0040	/* 2 */
 #define NFS_MOUNT_VER3		0x0080	/* 3 */
 #define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
-#define NFS_MOUNT_NONLM		0x0200	/* 3 */
 #define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
 #define NFS_MOUNT_NOACL		0x0800	/* 4 */
 #define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
@@ -71,4 +70,8 @@ struct nfs_mount_data {
 #define NFS_MOUNT_NORESVPORT		0x40000
 #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
 
+#define NFS_MOUNT_LOCAL_FLOCK	0x100000
+#define NFS_MOUNT_LOCAL_FCNTL	0x200000
+#define NFS_MOUNT_NONLM		(NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL)
+
 #endif
