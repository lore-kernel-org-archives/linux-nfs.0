Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59877 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488Ab1FUOhn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 10:37:43 -0400
Date: Tue, 21 Jun 2011 10:37:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Remove deprecated nfsctl system call and related
 code.
Message-ID: <20110621143740.GA25534@fieldses.org>
References: <20110621152743.0e11d8f3@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110621152743.0e11d8f3@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 21, 2011 at 03:27:43PM +1000, NeilBrown wrote:
> Is it too late in the -rc series for this do you think?  I think it is OK -
> we have been compiling it out for 4 releases anyway so no-one is using it.
> And while the next release isn't 2.6.40, it should have been :-)

I figure 2.6.40 == 3.0 in linux kernel-version arithmetic.

But it's not a bug fix, and I think we owe it to people to make sure
something like a feature removal is in a full set of test kernels before
it's in a released kernel.

I'll queue it up for 3.1.

Time flies.  Thanks for keeping track of this.

--b.

> 
> Thanks,
> NeilBrown
> 
> 
> From 701528a10b9efa9f90d1df8689c353988f6dc455 Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.de>
> Date: Tue, 21 Jun 2011 15:22:14 +1000
> Subject: [PATCH] nfsd: Remove deprecated nfsctl system call and related code.
> 
> As promised in feature-removal-schedule.txt it is time to
> remove the nfsctl system call.
> 
> Userspace has perferred to not use this call throughout 2.6 and it has been
> excluded in the default configuration since 2.6.36 (9 months ago).
> 
> So this patch removes all the code that was being compiled out.
> 
> There are still references to sys_nfsctl in various arch systemcall tables
> and related code.  These should be cleaned out too, probably in the next
> merge window.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  Documentation/feature-removal-schedule.txt |   10 -
>  arch/tile/configs/tilegx_defconfig         |    1 -
>  fs/Makefile                                |    1 -
>  fs/compat.c                                |  246 ----------------
>  fs/nfsctl.c                                |  100 -------
>  fs/nfsd/Kconfig                            |   12 -
>  fs/nfsd/export.c                           |  418 ----------------------------
>  fs/nfsd/lockd.c                            |    2 -
>  fs/nfsd/nfsctl.c                           |  343 -----------------------
>  fs/nfsd/nfssvc.c                           |    7 -
>  include/linux/compat.h                     |    9 -
>  include/linux/nfsd/export.h                |    2 -
>  include/linux/sunrpc/cache.h               |    9 -
>  net/sunrpc/svcauth_unix.c                  |   78 -----
>  14 files changed, 0 insertions(+), 1238 deletions(-)
>  delete mode 100644 fs/nfsctl.c
> 
> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
> index 72e2384..04d726f 100644
> --- a/Documentation/feature-removal-schedule.txt
> +++ b/Documentation/feature-removal-schedule.txt
> @@ -491,16 +491,6 @@ Who:	Wey-Yi Guy <wey-yi.w.guy@intel.com>
>  
>  ----------------------------
>  
> -What:   access to nfsd auth cache through sys_nfsservctl or '.' files
> -        in the 'nfsd' filesystem.
> -When:   2.6.40
> -Why:    This is a legacy interface which have been replaced by a more
> -        dynamic cache.  Continuing to maintain this interface is an
> -        unnecessary burden.
> -Who:    NeilBrown <neilb@suse.de>
> -
> -----------------------------
> -
>  What:	cancel_rearming_delayed_work[queue]()
>  When:	2.6.39
>  
> diff --git a/arch/tile/configs/tilegx_defconfig b/arch/tile/configs/tilegx_defconfig
> index 09f1c7f..2ad73fb 100644
> --- a/arch/tile/configs/tilegx_defconfig
> +++ b/arch/tile/configs/tilegx_defconfig
> @@ -1479,7 +1479,6 @@ CONFIG_NFS_FSCACHE=y
>  CONFIG_NFS_USE_KERNEL_DNS=y
>  # CONFIG_NFS_USE_NEW_IDMAPPER is not set
>  CONFIG_NFSD=m
> -CONFIG_NFSD_DEPRECATED=y
>  CONFIG_NFSD_V2_ACL=y
>  CONFIG_NFSD_V3=y
>  CONFIG_NFSD_V3_ACL=y
> diff --git a/fs/Makefile b/fs/Makefile
> index fb68c2b..afc1096 100644
> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -29,7 +29,6 @@ obj-$(CONFIG_EVENTFD)		+= eventfd.o
>  obj-$(CONFIG_AIO)               += aio.o
>  obj-$(CONFIG_FILE_LOCKING)      += locks.o
>  obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
> -obj-$(CONFIG_NFSD_DEPRECATED)	+= nfsctl.o
>  obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
>  obj-$(CONFIG_BINFMT_EM86)	+= binfmt_em86.o
>  obj-$(CONFIG_BINFMT_MISC)	+= binfmt_misc.o
> diff --git a/fs/compat.c b/fs/compat.c
> index 0ea0083..0b48d01 100644
> --- a/fs/compat.c
> +++ b/fs/compat.c
> @@ -1675,256 +1675,10 @@ asmlinkage long compat_sys_ppoll(struct pollfd __user *ufds,
>  }
>  #endif /* HAVE_SET_RESTORE_SIGMASK */
>  
> -#if (defined(CONFIG_NFSD) || defined(CONFIG_NFSD_MODULE)) && !defined(CONFIG_NFSD_DEPRECATED)
> -/* Stuff for NFS server syscalls... */
> -struct compat_nfsctl_svc {
> -	u16			svc32_port;
> -	s32			svc32_nthreads;
> -};
> -
> -struct compat_nfsctl_client {
> -	s8			cl32_ident[NFSCLNT_IDMAX+1];
> -	s32			cl32_naddr;
> -	struct in_addr		cl32_addrlist[NFSCLNT_ADDRMAX];
> -	s32			cl32_fhkeytype;
> -	s32			cl32_fhkeylen;
> -	u8			cl32_fhkey[NFSCLNT_KEYMAX];
> -};
> -
> -struct compat_nfsctl_export {
> -	char		ex32_client[NFSCLNT_IDMAX+1];
> -	char		ex32_path[NFS_MAXPATHLEN+1];
> -	compat_dev_t	ex32_dev;
> -	compat_ino_t	ex32_ino;
> -	compat_int_t	ex32_flags;
> -	__compat_uid_t	ex32_anon_uid;
> -	__compat_gid_t	ex32_anon_gid;
> -};
> -
> -struct compat_nfsctl_fdparm {
> -	struct sockaddr		gd32_addr;
> -	s8			gd32_path[NFS_MAXPATHLEN+1];
> -	compat_int_t		gd32_version;
> -};
> -
> -struct compat_nfsctl_fsparm {
> -	struct sockaddr		gd32_addr;
> -	s8			gd32_path[NFS_MAXPATHLEN+1];
> -	compat_int_t		gd32_maxlen;
> -};
> -
> -struct compat_nfsctl_arg {
> -	compat_int_t		ca32_version;	/* safeguard */
> -	union {
> -		struct compat_nfsctl_svc	u32_svc;
> -		struct compat_nfsctl_client	u32_client;
> -		struct compat_nfsctl_export	u32_export;
> -		struct compat_nfsctl_fdparm	u32_getfd;
> -		struct compat_nfsctl_fsparm	u32_getfs;
> -	} u;
> -#define ca32_svc	u.u32_svc
> -#define ca32_client	u.u32_client
> -#define ca32_export	u.u32_export
> -#define ca32_getfd	u.u32_getfd
> -#define ca32_getfs	u.u32_getfs
> -};
> -
> -union compat_nfsctl_res {
> -	__u8			cr32_getfh[NFS_FHSIZE];
> -	struct knfsd_fh		cr32_getfs;
> -};
> -
> -static int compat_nfs_svc_trans(struct nfsctl_arg *karg,
> -				struct compat_nfsctl_arg __user *arg)
> -{
> -	if (!access_ok(VERIFY_READ, &arg->ca32_svc, sizeof(arg->ca32_svc)) ||
> -		get_user(karg->ca_version, &arg->ca32_version) ||
> -		__get_user(karg->ca_svc.svc_port, &arg->ca32_svc.svc32_port) ||
> -		__get_user(karg->ca_svc.svc_nthreads,
> -				&arg->ca32_svc.svc32_nthreads))
> -		return -EFAULT;
> -	return 0;
> -}
> -
> -static int compat_nfs_clnt_trans(struct nfsctl_arg *karg,
> -				struct compat_nfsctl_arg __user *arg)
> -{
> -	if (!access_ok(VERIFY_READ, &arg->ca32_client,
> -			sizeof(arg->ca32_client)) ||
> -		get_user(karg->ca_version, &arg->ca32_version) ||
> -		__copy_from_user(&karg->ca_client.cl_ident[0],
> -				&arg->ca32_client.cl32_ident[0],
> -				NFSCLNT_IDMAX) ||
> -		__get_user(karg->ca_client.cl_naddr,
> -				&arg->ca32_client.cl32_naddr) ||
> -		__copy_from_user(&karg->ca_client.cl_addrlist[0],
> -				&arg->ca32_client.cl32_addrlist[0],
> -				(sizeof(struct in_addr) * NFSCLNT_ADDRMAX)) ||
> -		__get_user(karg->ca_client.cl_fhkeytype,
> -				&arg->ca32_client.cl32_fhkeytype) ||
> -		__get_user(karg->ca_client.cl_fhkeylen,
> -				&arg->ca32_client.cl32_fhkeylen) ||
> -		__copy_from_user(&karg->ca_client.cl_fhkey[0],
> -				&arg->ca32_client.cl32_fhkey[0],
> -				NFSCLNT_KEYMAX))
> -		return -EFAULT;
> -
> -	return 0;
> -}
> -
> -static int compat_nfs_exp_trans(struct nfsctl_arg *karg,
> -				struct compat_nfsctl_arg __user *arg)
> -{
> -	if (!access_ok(VERIFY_READ, &arg->ca32_export,
> -				sizeof(arg->ca32_export)) ||
> -		get_user(karg->ca_version, &arg->ca32_version) ||
> -		__copy_from_user(&karg->ca_export.ex_client[0],
> -				&arg->ca32_export.ex32_client[0],
> -				NFSCLNT_IDMAX) ||
> -		__copy_from_user(&karg->ca_export.ex_path[0],
> -				&arg->ca32_export.ex32_path[0],
> -				NFS_MAXPATHLEN) ||
> -		__get_user(karg->ca_export.ex_dev,
> -				&arg->ca32_export.ex32_dev) ||
> -		__get_user(karg->ca_export.ex_ino,
> -				&arg->ca32_export.ex32_ino) ||
> -		__get_user(karg->ca_export.ex_flags,
> -				&arg->ca32_export.ex32_flags) ||
> -		__get_user(karg->ca_export.ex_anon_uid,
> -				&arg->ca32_export.ex32_anon_uid) ||
> -		__get_user(karg->ca_export.ex_anon_gid,
> -				&arg->ca32_export.ex32_anon_gid))
> -		return -EFAULT;
> -	SET_UID(karg->ca_export.ex_anon_uid, karg->ca_export.ex_anon_uid);
> -	SET_GID(karg->ca_export.ex_anon_gid, karg->ca_export.ex_anon_gid);
> -
> -	return 0;
> -}
> -
> -static int compat_nfs_getfd_trans(struct nfsctl_arg *karg,
> -				struct compat_nfsctl_arg __user *arg)
> -{
> -	if (!access_ok(VERIFY_READ, &arg->ca32_getfd,
> -			sizeof(arg->ca32_getfd)) ||
> -		get_user(karg->ca_version, &arg->ca32_version) ||
> -		__copy_from_user(&karg->ca_getfd.gd_addr,
> -				&arg->ca32_getfd.gd32_addr,
> -				(sizeof(struct sockaddr))) ||
> -		__copy_from_user(&karg->ca_getfd.gd_path,
> -				&arg->ca32_getfd.gd32_path,
> -				(NFS_MAXPATHLEN+1)) ||
> -		__get_user(karg->ca_getfd.gd_version,
> -				&arg->ca32_getfd.gd32_version))
> -		return -EFAULT;
> -
> -	return 0;
> -}
> -
> -static int compat_nfs_getfs_trans(struct nfsctl_arg *karg,
> -				struct compat_nfsctl_arg __user *arg)
> -{
> -	if (!access_ok(VERIFY_READ,&arg->ca32_getfs,sizeof(arg->ca32_getfs)) ||
> -		get_user(karg->ca_version, &arg->ca32_version) ||
> -		__copy_from_user(&karg->ca_getfs.gd_addr,
> -				&arg->ca32_getfs.gd32_addr,
> -				(sizeof(struct sockaddr))) ||
> -		__copy_from_user(&karg->ca_getfs.gd_path,
> -				&arg->ca32_getfs.gd32_path,
> -				(NFS_MAXPATHLEN+1)) ||
> -		__get_user(karg->ca_getfs.gd_maxlen,
> -				&arg->ca32_getfs.gd32_maxlen))
> -		return -EFAULT;
> -
> -	return 0;
> -}
> -
> -/* This really doesn't need translations, we are only passing
> - * back a union which contains opaque nfs file handle data.
> - */
> -static int compat_nfs_getfh_res_trans(union nfsctl_res *kres,
> -				union compat_nfsctl_res __user *res)
> -{
> -	int err;
> -
> -	err = copy_to_user(res, kres, sizeof(*res));
> -
> -	return (err) ? -EFAULT : 0;
> -}
> -
> -asmlinkage long compat_sys_nfsservctl(int cmd,
> -				struct compat_nfsctl_arg __user *arg,
> -				union compat_nfsctl_res __user *res)
> -{
> -	struct nfsctl_arg *karg;
> -	union nfsctl_res *kres;
> -	mm_segment_t oldfs;
> -	int err;
> -
> -	karg = kmalloc(sizeof(*karg), GFP_USER);
> -	kres = kmalloc(sizeof(*kres), GFP_USER);
> -	if(!karg || !kres) {
> -		err = -ENOMEM;
> -		goto done;
> -	}
> -
> -	switch(cmd) {
> -	case NFSCTL_SVC:
> -		err = compat_nfs_svc_trans(karg, arg);
> -		break;
> -
> -	case NFSCTL_ADDCLIENT:
> -		err = compat_nfs_clnt_trans(karg, arg);
> -		break;
> -
> -	case NFSCTL_DELCLIENT:
> -		err = compat_nfs_clnt_trans(karg, arg);
> -		break;
> -
> -	case NFSCTL_EXPORT:
> -	case NFSCTL_UNEXPORT:
> -		err = compat_nfs_exp_trans(karg, arg);
> -		break;
> -
> -	case NFSCTL_GETFD:
> -		err = compat_nfs_getfd_trans(karg, arg);
> -		break;
> -
> -	case NFSCTL_GETFS:
> -		err = compat_nfs_getfs_trans(karg, arg);
> -		break;
> -
> -	default:
> -		err = -EINVAL;
> -		break;
> -	}
> -
> -	if (err)
> -		goto done;
> -
> -	oldfs = get_fs();
> -	set_fs(KERNEL_DS);
> -	/* The __user pointer casts are valid because of the set_fs() */
> -	err = sys_nfsservctl(cmd, (void __user *) karg, (void __user *) kres);
> -	set_fs(oldfs);
> -
> -	if (err)
> -		goto done;
> -
> -	if((cmd == NFSCTL_GETFD) ||
> -	   (cmd == NFSCTL_GETFS))
> -		err = compat_nfs_getfh_res_trans(kres, res);
> -
> -done:
> -	kfree(karg);
> -	kfree(kres);
> -	return err;
> -}
> -#else /* !NFSD */
>  long asmlinkage compat_sys_nfsservctl(int cmd, void *notused, void *notused2)
>  {
>  	return sys_ni_syscall();
>  }
> -#endif
>  
>  #ifdef CONFIG_EPOLL
>  
> diff --git a/fs/nfsctl.c b/fs/nfsctl.c
> deleted file mode 100644
> index 124e8fc..0000000
> --- a/fs/nfsctl.c
> +++ /dev/null
> @@ -1,100 +0,0 @@
> -/*
> - *	fs/nfsctl.c
> - *
> - *	This should eventually move to userland.
> - *
> - */
> -#include <linux/types.h>
> -#include <linux/file.h>
> -#include <linux/fs.h>
> -#include <linux/nfsd/syscall.h>
> -#include <linux/cred.h>
> -#include <linux/sched.h>
> -#include <linux/linkage.h>
> -#include <linux/namei.h>
> -#include <linux/mount.h>
> -#include <linux/syscalls.h>
> -#include <asm/uaccess.h>
> -
> -/*
> - * open a file on nfsd fs
> - */
> -
> -static struct file *do_open(char *name, int flags)
> -{
> -	struct vfsmount *mnt;
> -	struct file *file;
> -
> -	mnt = do_kern_mount("nfsd", 0, "nfsd", NULL);
> -	if (IS_ERR(mnt))
> -		return (struct file *)mnt;
> -
> -	file = file_open_root(mnt->mnt_root, mnt, name, flags);
> -
> -	mntput(mnt);	/* drop do_kern_mount reference */
> -	return file;
> -}
> -
> -static struct {
> -	char *name; int wsize; int rsize;
> -} map[] = {
> -	[NFSCTL_SVC] = {
> -		.name	= ".svc",
> -		.wsize	= sizeof(struct nfsctl_svc)
> -	},
> -	[NFSCTL_ADDCLIENT] = {
> -		.name	= ".add",
> -		.wsize	= sizeof(struct nfsctl_client)
> -	},
> -	[NFSCTL_DELCLIENT] = {
> -		.name	= ".del",
> -		.wsize	= sizeof(struct nfsctl_client)
> -	},
> -	[NFSCTL_EXPORT] = {
> -		.name	= ".export",
> -		.wsize	= sizeof(struct nfsctl_export)
> -	},
> -	[NFSCTL_UNEXPORT] = {
> -		.name	= ".unexport",
> -		.wsize	= sizeof(struct nfsctl_export)
> -	},
> -	[NFSCTL_GETFD] = {
> -		.name	= ".getfd",
> -		.wsize	= sizeof(struct nfsctl_fdparm),
> -		.rsize	= NFS_FHSIZE
> -	},
> -	[NFSCTL_GETFS] = {
> -		.name	= ".getfs",
> -		.wsize	= sizeof(struct nfsctl_fsparm),
> -		.rsize	= sizeof(struct knfsd_fh)
> -	},
> -};
> -
> -SYSCALL_DEFINE3(nfsservctl, int, cmd, struct nfsctl_arg __user *, arg,
> -		void __user *, res)
> -{
> -	struct file *file;
> -	void __user *p = &arg->u;
> -	int version;
> -	int err;
> -
> -	if (copy_from_user(&version, &arg->ca_version, sizeof(int)))
> -		return -EFAULT;
> -
> -	if (version != NFSCTL_VERSION)
> -		return -EINVAL;
> -
> -	if (cmd < 0 || cmd >= ARRAY_SIZE(map) || !map[cmd].name)
> -		return -EINVAL;
> -
> -	file = do_open(map[cmd].name, map[cmd].rsize ? O_RDWR : O_WRONLY);	
> -	if (IS_ERR(file))
> -		return PTR_ERR(file);
> -	err = file->f_op->write(file, p, map[cmd].wsize, &file->f_pos);
> -	if (err >= 0 && map[cmd].rsize)
> -		err = file->f_op->read(file, res, map[cmd].rsize, &file->f_pos);
> -	if (err >= 0)
> -		err = 0;
> -	fput(file);
> -	return err;
> -}
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 18b3e89..4264377 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -28,18 +28,6 @@ config NFSD
>  
>  	  If unsure, say N.
>  
> -config NFSD_DEPRECATED
> -	bool "Include support for deprecated syscall interface to NFSD"
> -	depends on NFSD
> -	default y
> -	help
> -	  The syscall interface to nfsd was obsoleted in 2.6.0 by a new
> -	  filesystem based interface.  The old interface is due for removal
> -	  in 2.6.40.  If you wish to remove the interface before then
> -	  say N.
> -
> -	  In unsure, say Y.
> -
>  config NFSD_V2_ACL
>  	bool
>  	depends on NFSD
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index b9566e4..f4cc1e2 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -797,58 +797,6 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
>  	return ek;
>  }
>  
> -#ifdef CONFIG_NFSD_DEPRECATED
> -static int exp_set_key(svc_client *clp, int fsid_type, u32 *fsidv,
> -		       struct svc_export *exp)
> -{
> -	struct svc_expkey key, *ek;
> -
> -	key.ek_client = clp;
> -	key.ek_fsidtype = fsid_type;
> -	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
> -	key.ek_path = exp->ex_path;
> -	key.h.expiry_time = NEVER;
> -	key.h.flags = 0;
> -
> -	ek = svc_expkey_lookup(&key);
> -	if (ek)
> -		ek = svc_expkey_update(&key,ek);
> -	if (ek) {
> -		cache_put(&ek->h, &svc_expkey_cache);
> -		return 0;
> -	}
> -	return -ENOMEM;
> -}
> -
> -/*
> - * Find the client's export entry matching xdev/xino.
> - */
> -static inline struct svc_expkey *
> -exp_get_key(svc_client *clp, dev_t dev, ino_t ino)
> -{
> -	u32 fsidv[3];
> -	
> -	if (old_valid_dev(dev)) {
> -		mk_fsid(FSID_DEV, fsidv, dev, ino, 0, NULL);
> -		return exp_find_key(clp, FSID_DEV, fsidv, NULL);
> -	}
> -	mk_fsid(FSID_ENCODE_DEV, fsidv, dev, ino, 0, NULL);
> -	return exp_find_key(clp, FSID_ENCODE_DEV, fsidv, NULL);
> -}
> -
> -/*
> - * Find the client's export entry matching fsid
> - */
> -static inline struct svc_expkey *
> -exp_get_fsid_key(svc_client *clp, int fsid)
> -{
> -	u32 fsidv[2];
> -
> -	mk_fsid(FSID_NUM, fsidv, 0, 0, fsid, NULL);
> -
> -	return exp_find_key(clp, FSID_NUM, fsidv, NULL);
> -}
> -#endif
>  
>  static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
>  				     struct cache_req *reqp)
> @@ -890,275 +838,7 @@ static struct svc_export *exp_parent(svc_client *clp, struct path *path)
>  	return exp;
>  }
>  
> -#ifdef CONFIG_NFSD_DEPRECATED
> -/*
> - * Hashtable locking. Write locks are placed only by user processes
> - * wanting to modify export information.
> - * Write locking only done in this file.  Read locking
> - * needed externally.
> - */
> -
> -static DECLARE_RWSEM(hash_sem);
> -
> -void
> -exp_readlock(void)
> -{
> -	down_read(&hash_sem);
> -}
> -
> -static inline void
> -exp_writelock(void)
> -{
> -	down_write(&hash_sem);
> -}
> -
> -void
> -exp_readunlock(void)
> -{
> -	up_read(&hash_sem);
> -}
> -
> -static inline void
> -exp_writeunlock(void)
> -{
> -	up_write(&hash_sem);
> -}
> -#else
> -
> -/* hash_sem not needed once deprecated interface is removed */
> -void exp_readlock(void) {}
> -static inline void exp_writelock(void){}
> -void exp_readunlock(void) {}
> -static inline void exp_writeunlock(void){}
> -
> -#endif
> -
> -#ifdef CONFIG_NFSD_DEPRECATED
> -static void		exp_do_unexport(svc_export *unexp);
> -static int		exp_verify_string(char *cp, int max);
> -
> -static void exp_fsid_unhash(struct svc_export *exp)
> -{
> -	struct svc_expkey *ek;
> -
> -	if ((exp->ex_flags & NFSEXP_FSID) == 0)
> -		return;
> -
> -	ek = exp_get_fsid_key(exp->ex_client, exp->ex_fsid);
> -	if (!IS_ERR(ek)) {
> -		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
> -		cache_put(&ek->h, &svc_expkey_cache);
> -	}
> -}
> -
> -static int exp_fsid_hash(svc_client *clp, struct svc_export *exp)
> -{
> -	u32 fsid[2];
> - 
> -	if ((exp->ex_flags & NFSEXP_FSID) == 0)
> -		return 0;
> -
> -	mk_fsid(FSID_NUM, fsid, 0, 0, exp->ex_fsid, NULL);
> -	return exp_set_key(clp, FSID_NUM, fsid, exp);
> -}
> -
> -static int exp_hash(struct auth_domain *clp, struct svc_export *exp)
> -{
> -	u32 fsid[2];
> -	struct inode *inode = exp->ex_path.dentry->d_inode;
> -	dev_t dev = inode->i_sb->s_dev;
> -
> -	if (old_valid_dev(dev)) {
> -		mk_fsid(FSID_DEV, fsid, dev, inode->i_ino, 0, NULL);
> -		return exp_set_key(clp, FSID_DEV, fsid, exp);
> -	}
> -	mk_fsid(FSID_ENCODE_DEV, fsid, dev, inode->i_ino, 0, NULL);
> -	return exp_set_key(clp, FSID_ENCODE_DEV, fsid, exp);
> -}
>  
> -static void exp_unhash(struct svc_export *exp)
> -{
> -	struct svc_expkey *ek;
> -	struct inode *inode = exp->ex_path.dentry->d_inode;
> -
> -	ek = exp_get_key(exp->ex_client, inode->i_sb->s_dev, inode->i_ino);
> -	if (!IS_ERR(ek)) {
> -		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
> -		cache_put(&ek->h, &svc_expkey_cache);
> -	}
> -}
> -	
> -/*
> - * Export a file system.
> - */
> -int
> -exp_export(struct nfsctl_export *nxp)
> -{
> -	svc_client	*clp;
> -	struct svc_export	*exp = NULL;
> -	struct svc_export	new;
> -	struct svc_expkey	*fsid_key = NULL;
> -	struct path path;
> -	int		err;
> -
> -	/* Consistency check */
> -	err = -EINVAL;
> -	if (!exp_verify_string(nxp->ex_path, NFS_MAXPATHLEN) ||
> -	    !exp_verify_string(nxp->ex_client, NFSCLNT_IDMAX))
> -		goto out;
> -
> -	dprintk("exp_export called for %s:%s (%x/%ld fl %x).\n",
> -			nxp->ex_client, nxp->ex_path,
> -			(unsigned)nxp->ex_dev, (long)nxp->ex_ino,
> -			nxp->ex_flags);
> -
> -	/* Try to lock the export table for update */
> -	exp_writelock();
> -
> -	/* Look up client info */
> -	if (!(clp = auth_domain_find(nxp->ex_client)))
> -		goto out_unlock;
> -
> -
> -	/* Look up the dentry */
> -	err = kern_path(nxp->ex_path, 0, &path);
> -	if (err)
> -		goto out_put_clp;
> -	err = -EINVAL;
> -
> -	exp = exp_get_by_name(clp, &path, NULL);
> -
> -	memset(&new, 0, sizeof(new));
> -
> -	/* must make sure there won't be an ex_fsid clash */
> -	if ((nxp->ex_flags & NFSEXP_FSID) &&
> -	    (!IS_ERR(fsid_key = exp_get_fsid_key(clp, nxp->ex_dev))) &&
> -	    fsid_key->ek_path.mnt &&
> -	    (fsid_key->ek_path.mnt != path.mnt ||
> -	     fsid_key->ek_path.dentry != path.dentry))
> -		goto finish;
> -
> -	if (!IS_ERR(exp)) {
> -		/* just a flags/id/fsid update */
> -
> -		exp_fsid_unhash(exp);
> -		exp->ex_flags    = nxp->ex_flags;
> -		exp->ex_anon_uid = nxp->ex_anon_uid;
> -		exp->ex_anon_gid = nxp->ex_anon_gid;
> -		exp->ex_fsid     = nxp->ex_dev;
> -
> -		err = exp_fsid_hash(clp, exp);
> -		goto finish;
> -	}
> -
> -	err = check_export(path.dentry->d_inode, &nxp->ex_flags, NULL);
> -	if (err) goto finish;
> -
> -	err = -ENOMEM;
> -
> -	dprintk("nfsd: creating export entry %p for client %p\n", exp, clp);
> -
> -	new.h.expiry_time = NEVER;
> -	new.h.flags = 0;
> -	new.ex_pathname = kstrdup(nxp->ex_path, GFP_KERNEL);
> -	if (!new.ex_pathname)
> -		goto finish;
> -	new.ex_client = clp;
> -	new.ex_path = path;
> -	new.ex_flags = nxp->ex_flags;
> -	new.ex_anon_uid = nxp->ex_anon_uid;
> -	new.ex_anon_gid = nxp->ex_anon_gid;
> -	new.ex_fsid = nxp->ex_dev;
> -
> -	exp = svc_export_lookup(&new);
> -	if (exp)
> -		exp = svc_export_update(&new, exp);
> -
> -	if (!exp)
> -		goto finish;
> -
> -	if (exp_hash(clp, exp) ||
> -	    exp_fsid_hash(clp, exp)) {
> -		/* failed to create at least one index */
> -		exp_do_unexport(exp);
> -		cache_flush();
> -	} else
> -		err = 0;
> -finish:
> -	kfree(new.ex_pathname);
> -	if (!IS_ERR_OR_NULL(exp))
> -		exp_put(exp);
> -	if (!IS_ERR_OR_NULL(fsid_key))
> -		cache_put(&fsid_key->h, &svc_expkey_cache);
> -	path_put(&path);
> -out_put_clp:
> -	auth_domain_put(clp);
> -out_unlock:
> -	exp_writeunlock();
> -out:
> -	return err;
> -}
> -
> -/*
> - * Unexport a file system. The export entry has already
> - * been removed from the client's list of exported fs's.
> - */
> -static void
> -exp_do_unexport(svc_export *unexp)
> -{
> -	sunrpc_invalidate(&unexp->h, &svc_export_cache);
> -	exp_unhash(unexp);
> -	exp_fsid_unhash(unexp);
> -}
> -
> -
> -/*
> - * unexport syscall.
> - */
> -int
> -exp_unexport(struct nfsctl_export *nxp)
> -{
> -	struct auth_domain *dom;
> -	svc_export *exp;
> -	struct path path;
> -	int		err;
> -
> -	/* Consistency check */
> -	if (!exp_verify_string(nxp->ex_path, NFS_MAXPATHLEN) ||
> -	    !exp_verify_string(nxp->ex_client, NFSCLNT_IDMAX))
> -		return -EINVAL;
> -
> -	exp_writelock();
> -
> -	err = -EINVAL;
> -	dom = auth_domain_find(nxp->ex_client);
> -	if (!dom) {
> -		dprintk("nfsd: unexport couldn't find %s\n", nxp->ex_client);
> -		goto out_unlock;
> -	}
> -
> -	err = kern_path(nxp->ex_path, 0, &path);
> -	if (err)
> -		goto out_domain;
> -
> -	err = -EINVAL;
> -	exp = exp_get_by_name(dom, &path, NULL);
> -	path_put(&path);
> -	if (IS_ERR(exp))
> -		goto out_domain;
> -
> -	exp_do_unexport(exp);
> -	exp_put(exp);
> -	err = 0;
> -
> -out_domain:
> -	auth_domain_put(dom);
> -	cache_flush();
> -out_unlock:
> -	exp_writeunlock();
> -	return err;
> -}
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  
>  /*
>   * Obtain the root fh on behalf of a client.
> @@ -1367,7 +1047,6 @@ static void *e_start(struct seq_file *m, loff_t *pos)
>  	unsigned hash, export;
>  	struct cache_head *ch;
>  	
> -	exp_readlock();
>  	read_lock(&svc_export_cache.hash_lock);
>  	if (!n--)
>  		return SEQ_START_TOKEN;
> @@ -1418,7 +1097,6 @@ static void e_stop(struct seq_file *m, void *p)
>  	__releases(svc_export_cache.hash_lock)
>  {
>  	read_unlock(&svc_export_cache.hash_lock);
> -	exp_readunlock();
>  }
>  
>  static struct flags {
> @@ -1550,97 +1228,6 @@ const struct seq_operations nfs_exports_op = {
>  	.show	= e_show,
>  };
>  
> -#ifdef CONFIG_NFSD_DEPRECATED
> -/*
> - * Add or modify a client.
> - * Change requests may involve the list of host addresses. The list of
> - * exports and possibly existing uid maps are left untouched.
> - */
> -int
> -exp_addclient(struct nfsctl_client *ncp)
> -{
> -	struct auth_domain	*dom;
> -	int			i, err;
> -	struct in6_addr addr6;
> -
> -	/* First, consistency check. */
> -	err = -EINVAL;
> -	if (! exp_verify_string(ncp->cl_ident, NFSCLNT_IDMAX))
> -		goto out;
> -	if (ncp->cl_naddr > NFSCLNT_ADDRMAX)
> -		goto out;
> -
> -	/* Lock the hashtable */
> -	exp_writelock();
> -
> -	dom = unix_domain_find(ncp->cl_ident);
> -
> -	err = -ENOMEM;
> -	if (!dom)
> -		goto out_unlock;
> -
> -	/* Insert client into hashtable. */
> -	for (i = 0; i < ncp->cl_naddr; i++) {
> -		ipv6_addr_set_v4mapped(ncp->cl_addrlist[i].s_addr, &addr6);
> -		auth_unix_add_addr(&init_net, &addr6, dom);
> -	}
> -	auth_unix_forget_old(dom);
> -	auth_domain_put(dom);
> -
> -	err = 0;
> -
> -out_unlock:
> -	exp_writeunlock();
> -out:
> -	return err;
> -}
> -
> -/*
> - * Delete a client given an identifier.
> - */
> -int
> -exp_delclient(struct nfsctl_client *ncp)
> -{
> -	int		err;
> -	struct auth_domain *dom;
> -
> -	err = -EINVAL;
> -	if (!exp_verify_string(ncp->cl_ident, NFSCLNT_IDMAX))
> -		goto out;
> -
> -	/* Lock the hashtable */
> -	exp_writelock();
> -
> -	dom = auth_domain_find(ncp->cl_ident);
> -	/* just make sure that no addresses work 
> -	 * and that it will expire soon 
> -	 */
> -	if (dom) {
> -		err = auth_unix_forget_old(dom);
> -		auth_domain_put(dom);
> -	}
> -
> -	exp_writeunlock();
> -out:
> -	return err;
> -}
> -
> -/*
> - * Verify that string is non-empty and does not exceed max length.
> - */
> -static int
> -exp_verify_string(char *cp, int max)
> -{
> -	int	i;
> -
> -	for (i = 0; i < max; i++)
> -		if (!cp[i])
> -			return i;
> -	cp[i] = 0;
> -	printk(KERN_NOTICE "nfsd: couldn't validate string %s\n", cp);
> -	return 0;
> -}
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  
>  /*
>   * Initialize the exports module.
> @@ -1667,10 +1254,8 @@ nfsd_export_init(void)
>  void
>  nfsd_export_flush(void)
>  {
> -	exp_writelock();
>  	cache_purge(&svc_expkey_cache);
>  	cache_purge(&svc_export_cache);
> -	exp_writeunlock();
>  }
>  
>  /*
> @@ -1682,12 +1267,9 @@ nfsd_export_shutdown(void)
>  
>  	dprintk("nfsd: shutting down export module.\n");
>  
> -	exp_writelock();
> -
>  	cache_unregister(&svc_expkey_cache);
>  	cache_unregister(&svc_export_cache);
>  	svcauth_unix_purge();
>  
> -	exp_writeunlock();
>  	dprintk("nfsd: export shutdown complete.\n");
>  }
> diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
> index 7c831a2..77e7a5c 100644
> --- a/fs/nfsd/lockd.c
> +++ b/fs/nfsd/lockd.c
> @@ -35,10 +35,8 @@ nlm_fopen(struct svc_rqst *rqstp, struct nfs_fh *f, struct file **filp)
>  	memcpy((char*)&fh.fh_handle.fh_base, f->data, f->size);
>  	fh.fh_export = NULL;
>  
> -	exp_readlock();
>  	nfserr = nfsd_open(rqstp, &fh, S_IFREG, NFSD_MAY_LOCK, filp);
>  	fh_put(&fh);
> -	exp_readunlock();
>   	/* We return nlm error codes as nlm doesn't know
>  	 * about nfsd, but nfsd does know about nlm..
>  	 */
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 1f5eae4..5d155c1 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -23,15 +23,6 @@
>   */
>  enum {
>  	NFSD_Root = 1,
> -#ifdef CONFIG_NFSD_DEPRECATED
> -	NFSD_Svc,
> -	NFSD_Add,
> -	NFSD_Del,
> -	NFSD_Export,
> -	NFSD_Unexport,
> -	NFSD_Getfd,
> -	NFSD_Getfs,
> -#endif
>  	NFSD_List,
>  	NFSD_Export_features,
>  	NFSD_Fh,
> @@ -58,15 +49,6 @@ enum {
>  /*
>   * write() for these nodes.
>   */
> -#ifdef CONFIG_NFSD_DEPRECATED
> -static ssize_t write_svc(struct file *file, char *buf, size_t size);
> -static ssize_t write_add(struct file *file, char *buf, size_t size);
> -static ssize_t write_del(struct file *file, char *buf, size_t size);
> -static ssize_t write_export(struct file *file, char *buf, size_t size);
> -static ssize_t write_unexport(struct file *file, char *buf, size_t size);
> -static ssize_t write_getfd(struct file *file, char *buf, size_t size);
> -static ssize_t write_getfs(struct file *file, char *buf, size_t size);
> -#endif
>  static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
>  static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size);
>  static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size);
> @@ -82,15 +64,6 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
>  #endif
>  
>  static ssize_t (*write_op[])(struct file *, char *, size_t) = {
> -#ifdef CONFIG_NFSD_DEPRECATED
> -	[NFSD_Svc] = write_svc,
> -	[NFSD_Add] = write_add,
> -	[NFSD_Del] = write_del,
> -	[NFSD_Export] = write_export,
> -	[NFSD_Unexport] = write_unexport,
> -	[NFSD_Getfd] = write_getfd,
> -	[NFSD_Getfs] = write_getfs,
> -#endif
>  	[NFSD_Fh] = write_filehandle,
>  	[NFSD_FO_UnlockIP] = write_unlock_ip,
>  	[NFSD_FO_UnlockFS] = write_unlock_fs,
> @@ -129,16 +102,6 @@ static ssize_t nfsctl_transaction_write(struct file *file, const char __user *bu
>  
>  static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
>  {
> -#ifdef CONFIG_NFSD_DEPRECATED
> -	static int warned;
> -	if (file->f_dentry->d_name.name[0] == '.' && !warned) {
> -		printk(KERN_INFO
> -		       "Warning: \"%s\" uses deprecated NFSD interface: %s."
> -		       "  This will be removed in 2.6.40\n",
> -		       current->comm, file->f_dentry->d_name.name);
> -		warned = 1;
> -	}
> -#endif
>  	if (! file->private_data) {
>  		/* An attempt to read a transaction file without writing
>  		 * causes a 0-byte write so that the file can return
> @@ -233,303 +196,6 @@ static const struct file_operations pool_stats_operations = {
>   * payload - write methods
>   */
>  
> -#ifdef CONFIG_NFSD_DEPRECATED
> -/**
> - * write_svc - Start kernel's NFSD server
> - *
> - * Deprecated.  /proc/fs/nfsd/threads is preferred.
> - * Function remains to support old versions of nfs-utils.
> - *
> - * Input:
> - *			buf:	struct nfsctl_svc
> - *				svc_port:	port number of this
> - *						server's listener
> - *				svc_nthreads:	number of threads to start
> - *			size:	size in bytes of passed in nfsctl_svc
> - * Output:
> - *	On success:	returns zero
> - *	On error:	return code is negative errno value
> - */
> -static ssize_t write_svc(struct file *file, char *buf, size_t size)
> -{
> -	struct nfsctl_svc *data;
> -	int err;
> -	if (size < sizeof(*data))
> -		return -EINVAL;
> -	data = (struct nfsctl_svc*) buf;
> -	err = nfsd_svc(data->svc_port, data->svc_nthreads);
> -	if (err < 0)
> -		return err;
> -	return 0;
> -}
> -
> -/**
> - * write_add - Add or modify client entry in auth unix cache
> - *
> - * Deprecated.  /proc/net/rpc/auth.unix.ip is preferred.
> - * Function remains to support old versions of nfs-utils.
> - *
> - * Input:
> - *			buf:	struct nfsctl_client
> - *				cl_ident:	'\0'-terminated C string
> - *						containing domain name
> - *						of client
> - *				cl_naddr:	no. of items in cl_addrlist
> - *				cl_addrlist:	array of client addresses
> - *				cl_fhkeytype:	ignored
> - *				cl_fhkeylen:	ignored
> - *				cl_fhkey:	ignored
> - *			size:	size in bytes of passed in nfsctl_client
> - * Output:
> - *	On success:	returns zero
> - *	On error:	return code is negative errno value
> - *
> - * Note: Only AF_INET client addresses are passed in, since
> - * nfsctl_client.cl_addrlist contains only in_addr fields for addresses.
> - */
> -static ssize_t write_add(struct file *file, char *buf, size_t size)
> -{
> -	struct nfsctl_client *data;
> -	if (size < sizeof(*data))
> -		return -EINVAL;
> -	data = (struct nfsctl_client *)buf;
> -	return exp_addclient(data);
> -}
> -
> -/**
> - * write_del - Remove client from auth unix cache
> - *
> - * Deprecated.  /proc/net/rpc/auth.unix.ip is preferred.
> - * Function remains to support old versions of nfs-utils.
> - *
> - * Input:
> - *			buf:	struct nfsctl_client
> - *				cl_ident:	'\0'-terminated C string
> - *						containing domain name
> - *						of client
> - *				cl_naddr:	ignored
> - *				cl_addrlist:	ignored
> - *				cl_fhkeytype:	ignored
> - *				cl_fhkeylen:	ignored
> - *				cl_fhkey:	ignored
> - *			size:	size in bytes of passed in nfsctl_client
> - * Output:
> - *	On success:	returns zero
> - *	On error:	return code is negative errno value
> - *
> - * Note: Only AF_INET client addresses are passed in, since
> - * nfsctl_client.cl_addrlist contains only in_addr fields for addresses.
> - */
> -static ssize_t write_del(struct file *file, char *buf, size_t size)
> -{
> -	struct nfsctl_client *data;
> -	if (size < sizeof(*data))
> -		return -EINVAL;
> -	data = (struct nfsctl_client *)buf;
> -	return exp_delclient(data);
> -}
> -
> -/**
> - * write_export - Export part or all of a local file system
> - *
> - * Deprecated.  /proc/net/rpc/{nfsd.export,nfsd.fh} are preferred.
> - * Function remains to support old versions of nfs-utils.
> - *
> - * Input:
> - *			buf:	struct nfsctl_export
> - *				ex_client:	'\0'-terminated C string
> - *						containing domain name
> - *						of client allowed to access
> - *						this export
> - *				ex_path:	'\0'-terminated C string
> - *						containing pathname of
> - *						directory in local file system
> - *				ex_dev:		fsid to use for this export
> - *				ex_ino:		ignored
> - *				ex_flags:	export flags for this export
> - *				ex_anon_uid:	UID to use for anonymous
> - *						requests
> - *				ex_anon_gid:	GID to use for anonymous
> - *						requests
> - *			size:	size in bytes of passed in nfsctl_export
> - * Output:
> - *	On success:	returns zero
> - *	On error:	return code is negative errno value
> - */
> -static ssize_t write_export(struct file *file, char *buf, size_t size)
> -{
> -	struct nfsctl_export *data;
> -	if (size < sizeof(*data))
> -		return -EINVAL;
> -	data = (struct nfsctl_export*)buf;
> -	return exp_export(data);
> -}
> -
> -/**
> - * write_unexport - Unexport a previously exported file system
> - *
> - * Deprecated.  /proc/net/rpc/{nfsd.export,nfsd.fh} are preferred.
> - * Function remains to support old versions of nfs-utils.
> - *
> - * Input:
> - *			buf:	struct nfsctl_export
> - *				ex_client:	'\0'-terminated C string
> - *						containing domain name
> - *						of client no longer allowed
> - *						to access this export
> - *				ex_path:	'\0'-terminated C string
> - *						containing pathname of
> - *						directory in local file system
> - *				ex_dev:		ignored
> - *				ex_ino:		ignored
> - *				ex_flags:	ignored
> - *				ex_anon_uid:	ignored
> - *				ex_anon_gid:	ignored
> - *			size:	size in bytes of passed in nfsctl_export
> - * Output:
> - *	On success:	returns zero
> - *	On error:	return code is negative errno value
> - */
> -static ssize_t write_unexport(struct file *file, char *buf, size_t size)
> -{
> -	struct nfsctl_export *data;
> -
> -	if (size < sizeof(*data))
> -		return -EINVAL;
> -	data = (struct nfsctl_export*)buf;
> -	return exp_unexport(data);
> -}
> -
> -/**
> - * write_getfs - Get a variable-length NFS file handle by path
> - *
> - * Deprecated.  /proc/fs/nfsd/filehandle is preferred.
> - * Function remains to support old versions of nfs-utils.
> - *
> - * Input:
> - *			buf:	struct nfsctl_fsparm
> - *				gd_addr:	socket address of client
> - *				gd_path:	'\0'-terminated C string
> - *						containing pathname of
> - *						directory in local file system
> - *				gd_maxlen:	maximum size of returned file
> - *						handle
> - *			size:	size in bytes of passed in nfsctl_fsparm
> - * Output:
> - *	On success:	passed-in buffer filled with a knfsd_fh structure
> - *			(a variable-length raw NFS file handle);
> - *			return code is the size in bytes of the file handle
> - *	On error:	return code is negative errno value
> - *
> - * Note: Only AF_INET client addresses are passed in, since gd_addr
> - * is the same size as a struct sockaddr_in.
> - */
> -static ssize_t write_getfs(struct file *file, char *buf, size_t size)
> -{
> -	struct nfsctl_fsparm *data;
> -	struct sockaddr_in *sin;
> -	struct auth_domain *clp;
> -	int err = 0;
> -	struct knfsd_fh *res;
> -	struct in6_addr in6;
> -
> -	if (size < sizeof(*data))
> -		return -EINVAL;
> -	data = (struct nfsctl_fsparm*)buf;
> -	err = -EPROTONOSUPPORT;
> -	if (data->gd_addr.sa_family != AF_INET)
> -		goto out;
> -	sin = (struct sockaddr_in *)&data->gd_addr;
> -	if (data->gd_maxlen > NFS3_FHSIZE)
> -		data->gd_maxlen = NFS3_FHSIZE;
> -
> -	res = (struct knfsd_fh*)buf;
> -
> -	exp_readlock();
> -
> -	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
> -
> -	clp = auth_unix_lookup(&init_net, &in6);
> -	if (!clp)
> -		err = -EPERM;
> -	else {
> -		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
> -		auth_domain_put(clp);
> -	}
> -	exp_readunlock();
> -	if (err == 0)
> -		err = res->fh_size + offsetof(struct knfsd_fh, fh_base);
> - out:
> -	return err;
> -}
> -
> -/**
> - * write_getfd - Get a fixed-length NFS file handle by path (used by mountd)
> - *
> - * Deprecated.  /proc/fs/nfsd/filehandle is preferred.
> - * Function remains to support old versions of nfs-utils.
> - *
> - * Input:
> - *			buf:	struct nfsctl_fdparm
> - *				gd_addr:	socket address of client
> - *				gd_path:	'\0'-terminated C string
> - *						containing pathname of
> - *						directory in local file system
> - *				gd_version:	fdparm structure version
> - *			size:	size in bytes of passed in nfsctl_fdparm
> - * Output:
> - *	On success:	passed-in buffer filled with nfsctl_res
> - *			(a fixed-length raw NFS file handle);
> - *			return code is the size in bytes of the file handle
> - *	On error:	return code is negative errno value
> - *
> - * Note: Only AF_INET client addresses are passed in, since gd_addr
> - * is the same size as a struct sockaddr_in.
> - */
> -static ssize_t write_getfd(struct file *file, char *buf, size_t size)
> -{
> -	struct nfsctl_fdparm *data;
> -	struct sockaddr_in *sin;
> -	struct auth_domain *clp;
> -	int err = 0;
> -	struct knfsd_fh fh;
> -	char *res;
> -	struct in6_addr in6;
> -
> -	if (size < sizeof(*data))
> -		return -EINVAL;
> -	data = (struct nfsctl_fdparm*)buf;
> -	err = -EPROTONOSUPPORT;
> -	if (data->gd_addr.sa_family != AF_INET)
> -		goto out;
> -	err = -EINVAL;
> -	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
> -		goto out;
> -
> -	res = buf;
> -	sin = (struct sockaddr_in *)&data->gd_addr;
> -	exp_readlock();
> -
> -	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
> -
> -	clp = auth_unix_lookup(&init_net, &in6);
> -	if (!clp)
> -		err = -EPERM;
> -	else {
> -		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
> -		auth_domain_put(clp);
> -	}
> -	exp_readunlock();
> -
> -	if (err == 0) {
> -		memset(res,0, NFS_FHSIZE);
> -		memcpy(res, &fh.fh_base, fh.fh_size);
> -		err = NFS_FHSIZE;
> -	}
> - out:
> -	return err;
> -}
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  
>  /**
>   * write_unlock_ip - Release all locks used by a client
> @@ -1404,15 +1070,6 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
>  static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
>  {
>  	static struct tree_descr nfsd_files[] = {
> -#ifdef CONFIG_NFSD_DEPRECATED
> -		[NFSD_Svc] = {".svc", &transaction_ops, S_IWUSR},
> -		[NFSD_Add] = {".add", &transaction_ops, S_IWUSR},
> -		[NFSD_Del] = {".del", &transaction_ops, S_IWUSR},
> -		[NFSD_Export] = {".export", &transaction_ops, S_IWUSR},
> -		[NFSD_Unexport] = {".unexport", &transaction_ops, S_IWUSR},
> -		[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
> -		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
> -#endif
>  		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
>  		[NFSD_Export_features] = {"export_features",
>  					&export_features_operations, S_IRUGO},
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 18743c4..bb8397f 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -528,16 +528,9 @@ nfsd(void *vrqstp)
>  			continue;
>  		}
>  
> -
> -		/* Lock the export hash tables for reading. */
> -		exp_readlock();
> -
>  		validate_process_creds();
>  		svc_process(rqstp);
>  		validate_process_creds();
> -
> -		/* Unlock export hash tables */
> -		exp_readunlock();
>  	}
>  
>  	/* Clear signals before calling svc_exit_thread() */
> diff --git a/include/linux/compat.h b/include/linux/compat.h
> index ddcb7db..851afdf 100644
> --- a/include/linux/compat.h
> +++ b/include/linux/compat.h
> @@ -438,16 +438,7 @@ asmlinkage long compat_sys_ppoll(struct pollfd __user *ufds,
>  				 struct compat_timespec __user *tsp,
>  				 const compat_sigset_t __user *sigmask,
>  				 compat_size_t sigsetsize);
> -#if (defined(CONFIG_NFSD) || defined(CONFIG_NFSD_MODULE)) && \
> -	!defined(CONFIG_NFSD_DEPRECATED)
> -union compat_nfsctl_res;
> -struct compat_nfsctl_arg;
> -asmlinkage long compat_sys_nfsservctl(int cmd,
> -				      struct compat_nfsctl_arg __user *arg,
> -				      union compat_nfsctl_res __user *res);
> -#else
>  asmlinkage long compat_sys_nfsservctl(int cmd, void *notused, void *notused2);
> -#endif
>  asmlinkage long compat_sys_signalfd4(int ufd,
>  				     const compat_sigset_t __user *sigmask,
>  				     compat_size_t sigsetsize, int flags);
> diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
> index 84058ec..8a31a20 100644
> --- a/include/linux/nfsd/export.h
> +++ b/include/linux/nfsd/export.h
> @@ -133,8 +133,6 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
>  int			nfsd_export_init(void);
>  void			nfsd_export_shutdown(void);
>  void			nfsd_export_flush(void);
> -void			exp_readlock(void);
> -void			exp_readunlock(void);
>  struct svc_export *	rqst_exp_get_by_name(struct svc_rqst *,
>  					     struct path *);
>  struct svc_export *	rqst_exp_parent(struct svc_rqst *,
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 8d2eef1..d1c79a9 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -256,13 +256,4 @@ static inline time_t get_expiry(char **bpp)
>  	return rv - boot.tv_sec;
>  }
>  
> -#ifdef CONFIG_NFSD_DEPRECATED
> -static inline void sunrpc_invalidate(struct cache_head *h,
> -				     struct cache_detail *detail)
> -{
> -	h->expiry_time = seconds_since_boot() - 1;
> -	detail->nextcheck = seconds_since_boot();
> -}
> -#endif /* CONFIG_NFSD_DEPRECATED */
> -
>  #endif /*  _LINUX_SUNRPC_CACHE_H_ */
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index c8e1021..31b9dea 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -30,9 +30,6 @@
>  
>  struct unix_domain {
>  	struct auth_domain	h;
> -#ifdef CONFIG_NFSD_DEPRECATED
> -	int	addr_changes;
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  	/* other stuff later */
>  };
>  
> @@ -74,9 +71,6 @@ struct auth_domain *unix_domain_find(char *name)
>  			return NULL;
>  		}
>  		new->h.flavour = &svcauth_unix;
> -#ifdef CONFIG_NFSD_DEPRECATED
> -		new->addr_changes = 0;
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  		rv = auth_domain_lookup(name, &new->h);
>  	}
>  }
> @@ -95,9 +89,6 @@ struct ip_map {
>  	char			m_class[8]; /* e.g. "nfsd" */
>  	struct in6_addr		m_addr;
>  	struct unix_domain	*m_client;
> -#ifdef CONFIG_NFSD_DEPRECATED
> -	int			m_add_change;
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  };
>  
>  static void ip_map_put(struct kref *kref)
> @@ -151,9 +142,6 @@ static void update(struct cache_head *cnew, struct cache_head *citem)
>  
>  	kref_get(&item->m_client->h.ref);
>  	new->m_client = item->m_client;
> -#ifdef CONFIG_NFSD_DEPRECATED
> -	new->m_add_change = item->m_add_change;
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  }
>  static struct cache_head *ip_map_alloc(void)
>  {
> @@ -338,16 +326,6 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
>  	ip.h.flags = 0;
>  	if (!udom)
>  		set_bit(CACHE_NEGATIVE, &ip.h.flags);
> -#ifdef CONFIG_NFSD_DEPRECATED
> -	else {
> -		ip.m_add_change = udom->addr_changes;
> -		/* if this is from the legacy set_client system call,
> -		 * we need m_add_change to be one higher
> -		 */
> -		if (expiry == NEVER)
> -			ip.m_add_change++;
> -	}
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  	ip.h.expiry_time = expiry;
>  	ch = sunrpc_cache_update(cd, &ip.h, &ipm->h,
>  				 hash_str(ipm->m_class, IP_HASHBITS) ^
> @@ -367,62 +345,6 @@ static inline int ip_map_update(struct net *net, struct ip_map *ipm,
>  	return __ip_map_update(sn->ip_map_cache, ipm, udom, expiry);
>  }
>  
> -#ifdef CONFIG_NFSD_DEPRECATED
> -int auth_unix_add_addr(struct net *net, struct in6_addr *addr, struct auth_domain *dom)
> -{
> -	struct unix_domain *udom;
> -	struct ip_map *ipmp;
> -
> -	if (dom->flavour != &svcauth_unix)
> -		return -EINVAL;
> -	udom = container_of(dom, struct unix_domain, h);
> -	ipmp = ip_map_lookup(net, "nfsd", addr);
> -
> -	if (ipmp)
> -		return ip_map_update(net, ipmp, udom, NEVER);
> -	else
> -		return -ENOMEM;
> -}
> -EXPORT_SYMBOL_GPL(auth_unix_add_addr);
> -
> -int auth_unix_forget_old(struct auth_domain *dom)
> -{
> -	struct unix_domain *udom;
> -
> -	if (dom->flavour != &svcauth_unix)
> -		return -EINVAL;
> -	udom = container_of(dom, struct unix_domain, h);
> -	udom->addr_changes++;
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(auth_unix_forget_old);
> -
> -struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
> -{
> -	struct ip_map *ipm;
> -	struct auth_domain *rv;
> -	struct sunrpc_net *sn;
> -
> -	sn = net_generic(net, sunrpc_net_id);
> -	ipm = ip_map_lookup(net, "nfsd", addr);
> -
> -	if (!ipm)
> -		return NULL;
> -	if (cache_check(sn->ip_map_cache, &ipm->h, NULL))
> -		return NULL;
> -
> -	if ((ipm->m_client->addr_changes - ipm->m_add_change) >0) {
> -		sunrpc_invalidate(&ipm->h, sn->ip_map_cache);
> -		rv = NULL;
> -	} else {
> -		rv = &ipm->m_client->h;
> -		kref_get(&rv->ref);
> -	}
> -	cache_put(&ipm->h, sn->ip_map_cache);
> -	return rv;
> -}
> -EXPORT_SYMBOL_GPL(auth_unix_lookup);
> -#endif /* CONFIG_NFSD_DEPRECATED */
>  
>  void svcauth_unix_purge(void)
>  {
> -- 
> 1.7.3.4
> 
