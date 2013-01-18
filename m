Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f172.google.com ([209.85.217.172]:57667 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967Ab3AROxL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 09:53:11 -0500
Received: by mail-lb0-f172.google.com with SMTP id n8so996553lbj.3
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jan 2013 06:53:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50F8839B.4070106@schaufler-ca.com>
References: <1358437249-8631-1-git-send-email-jlayton@redhat.com>
	<50F8839B.4070106@schaufler-ca.com>
Date: Fri, 18 Jan 2013 09:53:08 -0500
Message-ID: <CACLa4psB9tiO52HR9ZjKvfLvXfRGxc9V20Tqsg-r+n4-O5uptQ@mail.gmail.com>
Subject: Re: [PATCH RFC] selinux: make security_sb_clone_mnt_opts return an
 error on context mismatch
From: Eric Paris <eparis@parisplace.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        LSM List <linux-security-module@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Stephen Smalley <sds@tycho.nsa.gov>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Odd, but for once I agree with Casey   :)

Acked-by: Eric Paris <eparis@redhat.com>

On Thu, Jan 17, 2013 at 6:04 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
> On 1/17/2013 7:40 AM, Jeff Layton wrote:
>> Sorry if this is tl;dr, but this is a complex problem and I'm not
>> sure what the right solution is...
>>
>> I had the following problem reported a while back. If you mount the
>> same filesystem twice using NFSv4 with different contexts, then the
>> second context= option is ignored. For instance:
>>
>>     # mount server:/export /mnt/test1
>>     # mount server:/export /mnt/test2 -o context=system_u:object_r:tmp_t:s0
>>     # ls -dZ /mnt/test1
>>     drwxrwxrwt. root root system_u:object_r:nfs_t:s0       /mnt/test1
>>     # ls -dZ /mnt/test2
>>     drwxrwxrwt. root root system_u:object_r:nfs_t:s0       /mnt/test2
>>
>> When we call into SELinux to set the context of a "cloned" superblock,
>> it will currently just bail out when it notices that we're reusing an
>> existing superblock. Since the existing superblock is already set up and
>> presumably in use, we can't go overwriting its context with the one from
>> the "original" sb. Because of this, the second context= option in this
>> case cannot take effect.
>>
>> This patch fixes this by turning security_sb_clone_mnt_opts into an int
>> return operation. When it finds that the "new" superblock that it has
>> been handed is already set up, it checks to see whether the contexts on
>> the old superblock match it. If it does, then it will just return
>> success, otherwise it'll return EINVAL and emit a printk to tell the
>> admin why the second mount failed.
>>
>> (Side note: maybe EBUSY would be a better error there?)
>>
>> Note that this patch may cause casualties (which is the reason for the
>> RFC). The NFSv4 code relies on being able to walk down to an export from
>> the pseudoroot. If you mount filesystems that are nested within one
>> another with different contexts, then this patch will make those mounts
>> fail in new and "exciting" ways.
>>
>> For instance, suppose that /export is a separate filesystem on the
>> server:
>>
>>     # mount server:/ /mnt/test1
>>     # mount salusa:/export /mnt/test2 -o context=system_u:object_r:tmp_t:s0
>>     mount.nfs: an incorrect mount option was specified
>>
>> ...with the printk in the ring buffer. Because we *might* eventually
>> walk down to /mnt/test1/export, the mount is denied due to this patch.
>> The second mount needs the pseudoroot superblock, but that's already
>> present with the wrong context.
>>
>> OTOH, if we mount these in the reverse order, then both mounts work,
>> because the pseudoroot superblock created when mounting /export is
>> discarded once that mount is done. If we then however try to walk into
>> that directory, the automount fails for the similar reasons:
>>
>>     # cd /mnt/test1/scratch/
>>     -bash: cd: /mnt/test1/scratch/: Invalid argument
>>
>> The story I've gotten from the SELinux folks that I've talked to is that
>> this is desirable behavior. In SELinux-land, mounting the same data
>> under different contexts is wrong -- there can be only one.
>
> It's hard to imaging a case where mounting the same
> data with different contexts would be "right", although
> I have seen cases where misguided individuals have
> suggested doing just that.
>
> I think your solution is sound, if potentially resulting
> in occasional moaning.
>
>> I'm not sure
>> I like having these sorts of spurious errors though, even with a printk
>> that tries to explain them.
>>
>> Another possibility might be to just emit the printk in this situation
>> but not turn this into an error. IOW, just warn the admin that their
>> context is being ignored. In the case of automounts though, it may be
>> difficult to connect the warnings to actual mounts.
>>
>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> ---
>>  fs/nfs/super.c           |  3 +--
>>  include/linux/security.h | 10 ++++++----
>>  security/capability.c    |  3 ++-
>>  security/security.c      |  4 ++--
>>  security/selinux/hooks.c | 39 +++++++++++++++++++++++++++++++++++----
>>  5 files changed, 46 insertions(+), 13 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 2e7e8c8..939b9f0 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -2426,10 +2426,9 @@ int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
>>                         struct nfs_mount_info *mount_info)
>>  {
>>       /* clone any lsm security options from the parent to the new sb */
>> -     security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
>>       if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
>>               return -ESTALE;
>> -     return 0;
>> +     return security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
>>  }
>>  EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
>>
>> diff --git a/include/linux/security.h b/include/linux/security.h
>> index 0f6afc6..908cf98 100644
>> --- a/include/linux/security.h
>> +++ b/include/linux/security.h
>> @@ -1424,7 +1424,7 @@ struct security_operations {
>>                            struct path *new_path);
>>       int (*sb_set_mnt_opts) (struct super_block *sb,
>>                               struct security_mnt_opts *opts);
>> -     void (*sb_clone_mnt_opts) (const struct super_block *oldsb,
>> +     int (*sb_clone_mnt_opts) (const struct super_block *oldsb,
>>                                  struct super_block *newsb);
>>       int (*sb_parse_opts_str) (char *options, struct security_mnt_opts *opts);
>>
>> @@ -1706,7 +1706,7 @@ int security_sb_mount(const char *dev_name, struct path *path,
>>  int security_sb_umount(struct vfsmount *mnt, int flags);
>>  int security_sb_pivotroot(struct path *old_path, struct path *new_path);
>>  int security_sb_set_mnt_opts(struct super_block *sb, struct security_mnt_opts *opts);
>> -void security_sb_clone_mnt_opts(const struct super_block *oldsb,
>> +int security_sb_clone_mnt_opts(const struct super_block *oldsb,
>>                               struct super_block *newsb);
>>  int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
>>
>> @@ -1996,9 +1996,11 @@ static inline int security_sb_set_mnt_opts(struct super_block *sb,
>>       return 0;
>>  }
>>
>> -static inline void security_sb_clone_mnt_opts(const struct super_block *oldsb,
>> +static inline int security_sb_clone_mnt_opts(const struct super_block *oldsb,
>>                                             struct super_block *newsb)
>> -{ }
>> +{
>> +     return 0;
>> +}
>>
>>  static inline int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts)
>>  {
>> diff --git a/security/capability.c b/security/capability.c
>> index 0fe5a02..60c9680 100644
>> --- a/security/capability.c
>> +++ b/security/capability.c
>> @@ -98,9 +98,10 @@ static int cap_sb_set_mnt_opts(struct super_block *sb,
>>       return 0;
>>  }
>>
>> -static void cap_sb_clone_mnt_opts(const struct super_block *oldsb,
>> +static int cap_sb_clone_mnt_opts(const struct super_block *oldsb,
>>                                 struct super_block *newsb)
>>  {
>> +     return 0;
>>  }
>>
>>  static int cap_sb_parse_opts_str(char *options, struct security_mnt_opts *opts)
>> diff --git a/security/security.c b/security/security.c
>> index daa97f4..f587683 100644
>> --- a/security/security.c
>> +++ b/security/security.c
>> @@ -299,10 +299,10 @@ int security_sb_set_mnt_opts(struct super_block *sb,
>>  }
>>  EXPORT_SYMBOL(security_sb_set_mnt_opts);
>>
>> -void security_sb_clone_mnt_opts(const struct super_block *oldsb,
>> +int security_sb_clone_mnt_opts(const struct super_block *oldsb,
>>                               struct super_block *newsb)
>>  {
>> -     security_ops->sb_clone_mnt_opts(oldsb, newsb);
>> +     return security_ops->sb_clone_mnt_opts(oldsb, newsb);
>>  }
>>  EXPORT_SYMBOL(security_sb_clone_mnt_opts);
>>
>> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
>> index 61a5336..79d06f2 100644
>> --- a/security/selinux/hooks.c
>> +++ b/security/selinux/hooks.c
>> @@ -750,7 +750,37 @@ out_double_mount:
>>       goto out;
>>  }
>>
>> -static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>> +static int selinux_cmp_sb_context(const struct super_block *oldsb,
>> +                                 const struct super_block *newsb)
>> +{
>> +     struct superblock_security_struct *old = oldsb->s_security;
>> +     struct superblock_security_struct *new = newsb->s_security;
>> +     char oldflags = old->flags & SE_MNTMASK;
>> +     char newflags = new->flags & SE_MNTMASK;
>> +
>> +     if (oldflags != newflags)
>> +             goto mismatch;
>> +     if ((oldflags & FSCONTEXT_MNT) && old->sid != new->sid)
>> +             goto mismatch;
>> +     if ((oldflags & CONTEXT_MNT) && old->mntpoint_sid != new->mntpoint_sid)
>> +             goto mismatch;
>> +     if ((oldflags & DEFCONTEXT_MNT) && old->def_sid != new->def_sid)
>> +             goto mismatch;
>> +     if (oldflags & ROOTCONTEXT_MNT) {
>> +             struct inode_security_struct *oldroot = oldsb->s_root->d_inode->i_security;
>> +             struct inode_security_struct *newroot = newsb->s_root->d_inode->i_security;
>> +             if (oldroot->sid != newroot->sid)
>> +                     goto mismatch;
>> +     }
>> +     return 0;
>> +mismatch:
>> +     printk(KERN_WARNING "SELinux: mount invalid.  Same superblock, "
>> +                         "different security settings for (dev %s, "
>> +                         "type %s)\n", newsb->s_id, newsb->s_type->name);
>> +     return -EINVAL;
>> +}
>> +
>> +static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>>                                       struct super_block *newsb)
>>  {
>>       const struct superblock_security_struct *oldsbsec = oldsb->s_security;
>> @@ -765,14 +795,14 @@ static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>>        * mount options.  thus we can safely deal with this superblock later
>>        */
>>       if (!ss_initialized)
>> -             return;
>> +             return 0;
>>
>>       /* how can we clone if the old one wasn't set up?? */
>>       BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
>>
>> -     /* if fs is reusing a sb, just let its options stand... */
>> +     /* if fs is reusing a sb, make sure that the contexts match */
>>       if (newsbsec->flags & SE_SBINITIALIZED)
>> -             return;
>> +             return selinux_cmp_sb_context(oldsb, newsb);
>>
>>       mutex_lock(&newsbsec->lock);
>>
>> @@ -805,6 +835,7 @@ static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>>
>>       sb_finish_set_opts(newsb);
>>       mutex_unlock(&newsbsec->lock);
>> +     return 0;
>>  }
>>
>>  static int selinux_parse_opts_str(char *options,
>
