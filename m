From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: NFS/LSM: allow NFS to control all of its own mount options
Date: Wed, 20 Feb 2008 08:50:10 -0500
Message-ID: <1203515410.9902.128.camel@moss-spartans.epoch.ncsc.mil>
References: <1203457094.2928.113.camel@localhost.localdomain>
	 <20080219222408.GB10656@infradead.org>
	 <E1JRlsG-0004UB-H4@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: hch@infradead.org, eparis@redhat.com, linux-nfs@vger.kernel.org,
	selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	steved@redhat.com, jlayton@redhat.com, jmorris@namei.org,
	casey@schaufler-ca.com, trond.myklebust@fys.uio.no,
	chuck.lever@oracle.com, linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <E1JRlsG-0004UB-H4@pomaz-ex.szeredi.hu>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-20 at 11:08 +0100, Miklos Szeredi wrote:
> > Please don't introduce a special case for just nfs.  All filesystems
> > should control their mount options, so please provide some library
> > helpers for context= handling and move it into all filesystems that
> > can support selinux.
> 
> Hmm, looks like selinux is not showing it's mount options in
> /proc/mounts.  Well, actually there's no infrastructure for it either.
> Here's a template patch (completely untested).

I think the intent is to use the security_sb_get_mnt_opts() hook for
this purpose.

> 
> Selinux guys, please fill in the details and submit, thanks.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> 
> Index: linux/fs/namespace.c
> ===================================================================
> --- linux.orig/fs/namespace.c	2008-02-20 10:51:11.000000000 +0100
> +++ linux/fs/namespace.c	2008-02-20 10:51:25.000000000 +0100
> @@ -385,6 +385,7 @@ static int show_vfsmnt(struct seq_file *
>  		if (mnt->mnt_flags & fs_infop->flag)
>  			seq_puts(m, fs_infop->str);
>  	}
> +	security_sb_show_options(m, mnt->mnt_sb);
>  	if (mnt->mnt_sb->s_op->show_options)
>  		err = mnt->mnt_sb->s_op->show_options(m, mnt);
>  	seq_puts(m, " 0 0\n");
> Index: linux/include/linux/security.h
> ===================================================================
> --- linux.orig/include/linux/security.h	2008-02-18 21:20:03.000000000 +0100
> +++ linux/include/linux/security.h	2008-02-20 11:02:04.000000000 +0100
> @@ -80,6 +80,7 @@ struct xfrm_selector;
>  struct xfrm_policy;
>  struct xfrm_state;
>  struct xfrm_user_sec_ctx;
> +struct seq_file;
>  
>  extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
>  extern int cap_netlink_recv(struct sk_buff *skb, int cap);
> @@ -1226,6 +1227,7 @@ struct security_operations {
>  	int (*sb_copy_data)(struct file_system_type *type,
>  			    void *orig, void *copy);
>  	int (*sb_kern_mount) (struct super_block *sb, void *data);
> +	int (*sb_show_options) (struct seq_file *, struct super_block *sb);
>  	int (*sb_statfs) (struct dentry *dentry);
>  	int (*sb_mount) (char *dev_name, struct nameidata * nd,
>  			 char *type, unsigned long flags, void *data);
> @@ -1487,6 +1489,7 @@ int security_sb_alloc(struct super_block
>  void security_sb_free(struct super_block *sb);
>  int security_sb_copy_data(struct file_system_type *type, void *orig, void *copy);
>  int security_sb_kern_mount(struct super_block *sb, void *data);
> +int security_sb_show_options(struct seq_file *, struct super_block *sb);
>  int security_sb_statfs(struct dentry *dentry);
>  int security_sb_mount(char *dev_name, struct nameidata *nd,
>                         char *type, unsigned long flags, void *data);
> @@ -1744,6 +1747,12 @@ static inline int security_sb_kern_mount
>  	return 0;
>  }
>  
> +static inline int security_sb_show_options (struct seq_file *m,
> +					    struct super_block *sb)
> +{
> +	return 0;
> +}
> +
>  static inline int security_sb_statfs (struct dentry *dentry)
>  {
>  	return 0;
> Index: linux/security/security.c
> ===================================================================
> --- linux.orig/security/security.c	2008-02-18 21:20:06.000000000 +0100
> +++ linux/security/security.c	2008-02-20 10:56:16.000000000 +0100
> @@ -252,6 +252,14 @@ int security_sb_kern_mount(struct super_
>  	return security_ops->sb_kern_mount(sb, data);
>  }
>  
> +int security_sb_show_options (struct seq_file *m, struct super_block *sb)
> +{
> +	if (security_ops->sb_show_options)
> +		return security_ops->sb_show_options(m, sb);
> +	else
> +		return 0;
> +}
> +
>  int security_sb_statfs(struct dentry *dentry)
>  {
>  	return security_ops->sb_statfs(dentry);
> Index: linux/security/selinux/hooks.c
> ===================================================================
> --- linux.orig/security/selinux/hooks.c	2008-02-18 21:20:06.000000000 +0100
> +++ linux/security/selinux/hooks.c	2008-02-20 10:58:57.000000000 +0100
> @@ -590,6 +590,12 @@ out:
>  	return rc;
>  }
>  
> +static int selinux_sb_show_options(struct seq_file *m, struct super_block *sb)
> +{
> +	/* ... */
> +	return 0;
> +}
> +
>  static int superblock_doinit(struct super_block *sb, void *data)
>  {
>  	struct superblock_security_struct *sbsec = sb->s_security;
> @@ -4797,6 +4803,7 @@ static struct security_operations selinu
>  	.sb_free_security =		selinux_sb_free_security,
>  	.sb_copy_data =			selinux_sb_copy_data,
>  	.sb_kern_mount =	        selinux_sb_kern_mount,
> +	.sb_show_options =		selinux_sb_show_options,
>  	.sb_statfs =			selinux_sb_statfs,
>  	.sb_mount =			selinux_mount,
>  	.sb_umount =			selinux_umount,
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Stephen Smalley
National Security Agency

