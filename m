From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 06b/26] Security: Make NFSD work with detached
	security
Date: Thu, 17 Jan 2008 15:48:04 -0500
Message-ID: <20080117204804.GC6416__10322.379114996$1200603055$gmane$org@fieldses.org>
References: <20080115234724.22183.9603.stgit@warthog.procyon.org.uk>
	<20080115234652.22183.24850.stgit@warthog.procyon.org.uk>
	<20849.1200590240@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, Trond.Myklebust@netapp.com,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, nfs@lists.sourceforge.net,
	selinux@tycho.nsa.gov, casey@schaufler-ca.com, sds@tycho.nsa.gov
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:38893 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758003AbYAQUs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2008 15:48:57 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JFbfP-000181-Lq
	for linux-nfs@vger.kernel.org; Fri, 18 Jan 2008 07:48:53 +1100
In-Reply-To: <20849.1200590240@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 17, 2008 at 05:17:20PM +0000, David Howells wrote:
> 
> Make NFSD work with detached security, using the patches that excise the
> security information from task_struct to struct task_security as a base.
> 
> Each time NFSD wants a new security descriptor (to do NFS4 recovery or just to
> do NFS operations), a task_security record is derived from NFSD's *objective*
> security, modified and then applied as the *subjective* security.  This means
> (a) the changes are not visible to anyone looking at NFSD through /proc, (b)
> there is no leakage between two consecutive ops with different security
> configurations.
> 
> Consideration should probably be given to caching the task_security record on
> the basis that there'll probably be several ops that will want to use any
> particular security configuration.

Just curious--why?  Are get_kernel_security(), etc., particularly
expensive?

--b.

> 
> Furthermore, nfs4recover.c perhaps ought to set an appropriate LSM context on
> the record pointed to by rec_security so that the disk is accessed
> appropriately (see set_security_override[_from_ctx]()).
> 
> NOTE!  This patch must be and will be rolled in to patch 06 of 26 to make the
> latter compile fully, however it may be useful to the nfsd maintainers to see
> it as a separate patch.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  fs/nfsd/auth.c        |   31 +++++++++++++++++-------
>  fs/nfsd/nfs4recover.c |   64 +++++++++++++++++++++++++++++++------------------
>  include/linux/sched.h |    1 +
>  kernel/sys.c          |   27 ++++++++++++++++++---
>  4 files changed, 86 insertions(+), 37 deletions(-)
> 
> 
> diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
> index 2192805..462d989 100644
> --- a/fs/nfsd/auth.c
> +++ b/fs/nfsd/auth.c
> @@ -6,6 +6,7 @@
>  
>  #include <linux/types.h>
>  #include <linux/sched.h>
> +#include <linux/cred.h>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/sunrpc/svcauth.h>
>  #include <linux/nfsd/nfsd.h>
> @@ -28,11 +29,17 @@ int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp)
>  
>  int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
>  {
> +	struct task_security *sec, *old;
>  	struct svc_cred	cred = rqstp->rq_cred;
>  	int i;
>  	int flags = nfsexp_flags(rqstp, exp);
>  	int ret;
>  
> +	/* derive the new security record from nfsd's objective security */
> +	sec = get_kernel_security(current);
> +	if (!sec)
> +		return -ENOMEM;
> +
>  	if (flags & NFSEXP_ALLSQUASH) {
>  		cred.cr_uid = exp->ex_anon_uid;
>  		cred.cr_gid = exp->ex_anon_gid;
> @@ -56,23 +63,29 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
>  		get_group_info(cred.cr_group_info);
>  
>  	if (cred.cr_uid != (uid_t) -1)
> -		current->fsuid = cred.cr_uid;
> +		sec->fsuid = cred.cr_uid;
>  	else
> -		current->fsuid = exp->ex_anon_uid;
> +		sec->fsuid = exp->ex_anon_uid;
>  	if (cred.cr_gid != (gid_t) -1)
> -		current->fsgid = cred.cr_gid;
> +		sec->fsgid = cred.cr_gid;
>  	else
> -		current->fsgid = exp->ex_anon_gid;
> +		sec->fsgid = exp->ex_anon_gid;
>  
> -	if (!cred.cr_group_info)
> +	if (!cred.cr_group_info) {
> +		put_task_security(sec);
>  		return -ENOMEM;
> -	ret = set_current_groups(cred.cr_group_info);
> +	}
> +	ret = set_groups(sec, cred.cr_group_info);
>  	put_group_info(cred.cr_group_info);
>  	if ((cred.cr_uid)) {
> -		cap_t(current->cap_effective) &= ~CAP_NFSD_MASK;
> +		cap_t(sec->cap_effective) &= ~CAP_NFSD_MASK;
>  	} else {
> -		cap_t(current->cap_effective) |= (CAP_NFSD_MASK &
> -						  current->cap_permitted);
> +		cap_t(sec->cap_effective) |= CAP_NFSD_MASK & sec->cap_permitted;
>  	}
> +
> +	/* set the new security as nfsd's subjective security */
> +	old = current->act_as;
> +	current->act_as = sec;
> +	put_task_security(old);
>  	return ret;
>  }
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 1602cd0..ae91262 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -46,27 +46,37 @@
>  #include <linux/scatterlist.h>
>  #include <linux/crypto.h>
>  #include <linux/sched.h>
> +#include <linux/cred.h>
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
>  
>  /* Globals */
>  static struct nameidata rec_dir;
>  static int rec_dir_init = 0;
> +static struct task_security *rec_security;
>  
> +/*
> + * switch the special recovery access security in on the current task's
> + * subjective security
> + */
>  static void
> -nfs4_save_user(uid_t *saveuid, gid_t *savegid)
> +nfs4_begin_secure(struct task_security **saved_sec)
>  {
> -	*saveuid = current->fsuid;
> -	*savegid = current->fsgid;
> -	current->fsuid = 0;
> -	current->fsgid = 0;
> +	*saved_sec = current->act_as;
> +	current->act_as = get_task_security(rec_security);
>  }
>  
> +/*
> + * return the current task's subjective security to its former glory
> + */
>  static void
> -nfs4_reset_user(uid_t saveuid, gid_t savegid)
> +nfs4_end_secure(struct task_security *saved_sec)
>  {
> -	current->fsuid = saveuid;
> -	current->fsgid = savegid;
> +	struct task_security *discard;
> +
> +	discard = current->act_as;
> +	current->act_as = saved_sec;
> +	put_task_security(discard);
>  }
>  
>  static void
> @@ -128,10 +138,9 @@ nfsd4_sync_rec_dir(void)
>  int
>  nfsd4_create_clid_dir(struct nfs4_client *clp)
>  {
> +	struct task_security *saved_sec;
>  	char *dname = clp->cl_recdir;
>  	struct dentry *dentry;
> -	uid_t uid;
> -	gid_t gid;
>  	int status;
>  
>  	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
> @@ -139,7 +148,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  	if (!rec_dir_init || clp->cl_firststate)
>  		return 0;
>  
> -	nfs4_save_user(&uid, &gid);
> +	nfs4_begin_secure(&saved_sec);
>  
>  	/* lock the parent */
>  	mutex_lock(&rec_dir.dentry->d_inode->i_mutex);
> @@ -163,7 +172,7 @@ out_unlock:
>  		clp->cl_firststate = 1;
>  		nfsd4_sync_rec_dir();
>  	}
> -	nfs4_reset_user(uid, gid);
> +	nfs4_end_secure(saved_sec);
>  	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
>  	return status;
>  }
> @@ -206,20 +215,19 @@ nfsd4_build_dentrylist(void *arg, const char *name, int namlen,
>  static int
>  nfsd4_list_rec_dir(struct dentry *dir, recdir_func *f)
>  {
> +	struct task_security *saved_sec;
>  	struct file *filp;
>  	struct dentry_list_arg dla = {
>  		.parent = dir,
>  	};
>  	struct list_head *dentries = &dla.dentries;
>  	struct dentry_list *child;
> -	uid_t uid;
> -	gid_t gid;
>  	int status;
>  
>  	if (!rec_dir_init)
>  		return 0;
>  
> -	nfs4_save_user(&uid, &gid);
> +	nfs4_begin_secure(&saved_sec);
>  
>  	filp = dentry_open(dget(dir), mntget(rec_dir.mnt), O_RDONLY);
>  	status = PTR_ERR(filp);
> @@ -244,7 +252,7 @@ out:
>  		dput(child->dentry);
>  		kfree(child);
>  	}
> -	nfs4_reset_user(uid, gid);
> +	nfs4_end_secure(saved_sec);
>  	return status;
>  }
>  
> @@ -306,17 +314,16 @@ out:
>  void
>  nfsd4_remove_clid_dir(struct nfs4_client *clp)
>  {
> -	uid_t uid;
> -	gid_t gid;
> +	struct task_security *saved_sec;
>  	int status;
>  
>  	if (!rec_dir_init || !clp->cl_firststate)
>  		return;
>  
>  	clp->cl_firststate = 0;
> -	nfs4_save_user(&uid, &gid);
> +	nfs4_begin_secure(&saved_sec);
>  	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
> -	nfs4_reset_user(uid, gid);
> +	nfs4_end_secure(saved_sec);
>  	if (status == 0)
>  		nfsd4_sync_rec_dir();
>  	if (status)
> @@ -387,8 +394,7 @@ nfsd4_recdir_load(void) {
>  void
>  nfsd4_init_recdir(char *rec_dirname)
>  {
> -	uid_t			uid = 0;
> -	gid_t			gid = 0;
> +	struct task_security	*saved_sec;
>  	int 			status;
>  
>  	printk("NFSD: Using %s as the NFSv4 state recovery directory\n",
> @@ -396,7 +402,15 @@ nfsd4_init_recdir(char *rec_dirname)
>  
>  	BUG_ON(rec_dir_init);
>  
> -	nfs4_save_user(&uid, &gid);
> +	/* derive the security record from this task's objective security */
> +	rec_security = get_kernel_security(current);
> +	if (!rec_security) {
> +		printk("NFSD:"
> +		       " unable to allocate recovery directory security\n");
> +		return;
> +	}
> +
> +	nfs4_begin_secure(&saved_sec);
>  
>  	status = path_lookup(rec_dirname, LOOKUP_FOLLOW | LOOKUP_DIRECTORY,
>  			&rec_dir);
> @@ -406,7 +420,8 @@ nfsd4_init_recdir(char *rec_dirname)
>  
>  	if (!status)
>  		rec_dir_init = 1;
> -	nfs4_reset_user(uid, gid);
> +
> +	nfs4_end_secure(saved_sec);
>  }
>  
>  void
> @@ -416,4 +431,5 @@ nfsd4_shutdown_recdir(void)
>  		return;
>  	rec_dir_init = 0;
>  	path_release(&rec_dir);
> +	put_task_security(rec_security);
>  }
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 697e707..d079b85 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -886,6 +886,7 @@ struct group_info {
>  extern struct group_info *groups_alloc(int gidsetsize);
>  extern void groups_free(struct group_info *group_info);
>  extern int set_current_groups(struct group_info *group_info);
> +extern int set_groups(struct task_security *sec, struct group_info *group_info);
>  extern int groups_search(struct group_info *group_info, gid_t grp);
>  /* access the groups "array" with this macro */
>  #define GROUP_AT(gi, i) \
> diff --git a/kernel/sys.c b/kernel/sys.c
> index e331b6f..790639f 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1245,10 +1245,16 @@ int groups_search(struct group_info *group_info, gid_t grp)
>  	return 0;
>  }
>  
> -/* validate and set current->group_info */
> -int set_current_groups(struct group_info *group_info)
> +/**
> + * set_groups - Change a group subscription in a security record
> + * @sec: The security record to alter
> + * @group_info: The group list to impose
> + *
> + * Validate a group subscription and, if valid, impose it upon a task security
> + * record.
> + */
> +int set_groups(struct task_security *sec, struct group_info *group_info)
>  {
> -	struct task_security *sec = current->sec;
>  	int retval;
>  	struct group_info *old_info;
>  
> @@ -1265,10 +1271,23 @@ int set_current_groups(struct group_info *group_info)
>  	spin_unlock(&sec->lock);
>  
>  	put_group_info(old_info);
> -
>  	return 0;
>  }
>  
> +EXPORT_SYMBOL(set_groups);
> +
> +/**
> + * set_current_groups - Change current's group subscription
> + * @group_info: The group list to impose
> + *
> + * Validate a group subscription and, if valid, impose it upon current's task
> + * security record.
> + */
> +int set_current_groups(struct group_info *group_info)
> +{
> +	return set_groups(current->sec, group_info);
> +}
> +
>  EXPORT_SYMBOL(set_current_groups);
>  
>  asmlinkage long sys_getgroups(int gidsetsize, gid_t __user *grouplist)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

