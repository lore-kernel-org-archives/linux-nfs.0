Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f52.google.com ([209.85.215.52]:62890 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758223Ab3ETVOh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 17:14:37 -0400
Received: by mail-la0-f52.google.com with SMTP id fo13so6841820lab.39
        for <linux-nfs@vger.kernel.org>; Mon, 20 May 2013 14:14:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368719808-14584-2-git-send-email-SteveD@redhat.com>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
	<1368719808-14584-2-git-send-email-SteveD@redhat.com>
Date: Mon, 20 May 2013 17:14:35 -0400
Message-ID: <CACLa4pvsjpf7RGj4ZDekWi+d9wJLmzJvp0OxQt0eUdHfd--3JQ@mail.gmail.com>
Subject: Re: [PATCH 01/13] Security: Add hook to calculate context based on a
 negative dentry.
From: Eric Paris <eparis@parisplace.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 16, 2013 at 11:56 AM, Steve Dickson <SteveD@redhat.com> wrote:
> From: Steve Dickson <steved@redhat.com>
>
> There is a time where we need to calculate a context without the
> inode having been created yet. To do this we take the negative dentry and
> calculate a context based on the process and the parent directory contexts.
>
> Acked-by: James Morris <james.l.morris@oracle.com>
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>

Acked-by: Eric Paris <eparis@redhat.com>

> ---
>  include/linux/security.h | 27 +++++++++++++++++++++++++++
>  security/capability.c    |  8 ++++++++
>  security/security.c      | 10 ++++++++++
>  security/selinux/hooks.c | 35 +++++++++++++++++++++++++++++++++++
>  4 files changed, 80 insertions(+)
>
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 4686491..c2af462 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -26,6 +26,7 @@
>  #include <linux/capability.h>
>  #include <linux/slab.h>
>  #include <linux/err.h>
> +#include <linux/string.h>
>
>  struct linux_binprm;
>  struct cred;
> @@ -306,6 +307,15 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *     Parse a string of security data filling in the opts structure
>   *     @options string containing all mount options known by the LSM
>   *     @opts binary data structure usable by the LSM
> + * @dentry_init_security:
> + *     Compute a context for a dentry as the inode is not yet available
> + *     since NFSv4 has no label backed by an EA anyway.
> + *     @dentry dentry to use in calculating the context.
> + *     @mode mode used to determine resource type.
> + *     @name name of the last path component used to create file
> + *     @ctx pointer to place the pointer to the resulting context in.
> + *     @ctxlen point to place the length of the resulting context.
> + *
>   *
>   * Security hooks for inode operations.
>   *
> @@ -1443,6 +1453,10 @@ struct security_operations {
>         int (*sb_clone_mnt_opts) (const struct super_block *oldsb,
>                                    struct super_block *newsb);
>         int (*sb_parse_opts_str) (char *options, struct security_mnt_opts *opts);
> +       int (*dentry_init_security) (struct dentry *dentry, int mode,
> +                                       struct qstr *name, void **ctx,
> +                                       u32 *ctxlen);
> +
>
>  #ifdef CONFIG_SECURITY_PATH
>         int (*path_unlink) (struct path *dir, struct dentry *dentry);
> @@ -1729,6 +1743,9 @@ int security_sb_set_mnt_opts(struct super_block *sb, struct security_mnt_opts *o
>  int security_sb_clone_mnt_opts(const struct super_block *oldsb,
>                                 struct super_block *newsb);
>  int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
> +int security_dentry_init_security(struct dentry *dentry, int mode,
> +                                       struct qstr *name, void **ctx,
> +                                       u32 *ctxlen);
>
>  int security_inode_alloc(struct inode *inode);
>  void security_inode_free(struct inode *inode);
> @@ -2035,6 +2052,16 @@ static inline int security_inode_alloc(struct inode *inode)
>  static inline void security_inode_free(struct inode *inode)
>  { }
>
> +static inline int security_dentry_init_security(struct dentry *dentry,
> +                                                int mode,
> +                                                struct qstr *name,
> +                                                void **ctx,
> +                                                u32 *ctxlen)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +
>  static inline int security_inode_init_security(struct inode *inode,
>                                                 struct inode *dir,
>                                                 const struct qstr *qstr,
> diff --git a/security/capability.c b/security/capability.c
> index 83efc90..7aeec66 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -109,6 +109,13 @@ static int cap_sb_parse_opts_str(char *options, struct security_mnt_opts *opts)
>         return 0;
>  }
>
> +static int cap_dentry_init_security(struct dentry *dentry, int mode,
> +                                       struct qstr *name, void **ctx,
> +                                       u32 *ctxlen)
> +{
> +       return 0;
> +}
> +
>  static int cap_inode_alloc_security(struct inode *inode)
>  {
>         return 0;
> @@ -931,6 +938,7 @@ void __init security_fixup_ops(struct security_operations *ops)
>         set_to_cap_if_null(ops, sb_set_mnt_opts);
>         set_to_cap_if_null(ops, sb_clone_mnt_opts);
>         set_to_cap_if_null(ops, sb_parse_opts_str);
> +       set_to_cap_if_null(ops, dentry_init_security);
>         set_to_cap_if_null(ops, inode_alloc_security);
>         set_to_cap_if_null(ops, inode_free_security);
>         set_to_cap_if_null(ops, inode_init_security);
> diff --git a/security/security.c b/security/security.c
> index a3dce87..0fe2b2e 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -12,6 +12,7 @@
>   */
>
>  #include <linux/capability.h>
> +#include <linux/dcache.h>
>  #include <linux/module.h>
>  #include <linux/init.h>
>  #include <linux/kernel.h>
> @@ -324,6 +325,15 @@ void security_inode_free(struct inode *inode)
>         security_ops->inode_free_security(inode);
>  }
>
> +int security_dentry_init_security(struct dentry *dentry, int mode,
> +                                       struct qstr *name, void **ctx,
> +                                       u32 *ctxlen)
> +{
> +       return security_ops->dentry_init_security(dentry, mode, name,
> +                                                       ctx, ctxlen);
> +}
> +EXPORT_SYMBOL(security_dentry_init_security);
> +
>  int security_inode_init_security(struct inode *inode, struct inode *dir,
>                                  const struct qstr *qstr,
>                                  const initxattrs initxattrs, void *fs_data)
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 5c6f2cd..b1f7bd7 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2515,6 +2515,40 @@ static void selinux_inode_free_security(struct inode *inode)
>         inode_free_security(inode);
>  }
>
> +static int selinux_dentry_init_security(struct dentry *dentry, int mode,
> +                                       struct qstr *name, void **ctx,
> +                                       u32 *ctxlen)
> +{
> +       const struct cred *cred = current_cred();
> +       struct task_security_struct *tsec;
> +       struct inode_security_struct *dsec;
> +       struct superblock_security_struct *sbsec;
> +       struct inode *dir = dentry->d_parent->d_inode;
> +       u32 newsid;
> +       int rc;
> +
> +       tsec = cred->security;
> +       dsec = dir->i_security;
> +       sbsec = dir->i_sb->s_security;
> +
> +       if (tsec->create_sid && sbsec->behavior != SECURITY_FS_USE_MNTPOINT) {
> +               newsid = tsec->create_sid;
> +       } else {
> +               rc = security_transition_sid(tsec->sid, dsec->sid,
> +                                            inode_mode_to_security_class(mode),
> +                                            name,
> +                                            &newsid);
> +               if (rc) {
> +                       printk(KERN_WARNING
> +                               "%s: security_transition_sid failed, rc=%d\n",
> +                              __func__, -rc);
> +                       return rc;
> +               }
> +       }
> +
> +       return security_sid_to_context(newsid, (char **)ctx, ctxlen);
> +}
> +
>  static int selinux_inode_init_security(struct inode *inode, struct inode *dir,
>                                        const struct qstr *qstr, char **name,
>                                        void **value, size_t *len)
> @@ -5562,6 +5596,7 @@ static struct security_operations selinux_ops = {
>         .sb_clone_mnt_opts =            selinux_sb_clone_mnt_opts,
>         .sb_parse_opts_str =            selinux_parse_opts_str,
>
> +       .dentry_init_security =         selinux_dentry_init_security,
>
>         .inode_alloc_security =         selinux_inode_alloc_security,
>         .inode_free_security =          selinux_inode_free_security,
> --
> 1.8.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
