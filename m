Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:46384 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1733098AbeHAHZF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 03:25:05 -0400
MIME-Version: 1.0
In-Reply-To: <20180731232127.GB20761@wotan.suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de> <20180731211045.5671-2-mfasheh@suse.de>
 <20180731232127.GB20761@wotan.suse.de>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 1 Aug 2018 08:41:14 +0300
Message-ID: <CAOQ4uxiXV=jobVxp_T2NNb7TdbDX+qNjfm4VCr5qAjgLX9BrgA@mail.gmail.com>
Subject: Re: [PATCH 1/4] vfs: introduce function to map unique ino/dev pairs
To: Mark Fasheh <mfasheh@suse.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Btrfs <linux-btrfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        Jeff Mahoney <jeffm@suse.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 1, 2018 at 2:21 AM, Mark Fasheh <mfasheh@suse.de> wrote:
>
> On Tue, Jul 31, 2018 at 02:10:42PM -0700, Mark Fasheh wrote:
>> diff --git a/fs/stat.c b/fs/stat.c
>> index f8e6fb2c3657..80ea42505219 100644
>> --- a/fs/stat.c
>> +++ b/fs/stat.c
>> @@ -84,6 +84,29 @@ int vfs_getattr_nosec(const struct path *path, struct kstat *stat,
>>  }
>>  EXPORT_SYMBOL(vfs_getattr_nosec);
>>
>> +void vfs_map_unique_ino_dev(struct dentry *dentry, u64 *ino, dev_t *dev)
>> +{
>> +     int ret;
>> +     struct path path;
>> +     struct kstat stat;
>> +
>> +     path.mnt = NULL;
>> +     path.dentry = dentry;
>> +     /* ->dev is always returned, so we only need to specify ino here */
>> +     ret = vfs_getattr_nosec(&path, &stat, STATX_INO, 0);
>> +     if (ret) {
>> +             struct inode *inode = d_inode(dentry);
>> +             /* Fallback to old behavior in case of getattr error */
>> +             *ino = inode->i_ino;
>> +             *dev = inode->i_sb->s_dev;
>> +             return ret;
>
> Ooof, attached is a version of this patch which doesn't try to return a value
> from a void function. Apologies for the extra e-mail.
>
> From Mark Fasheh <mfasheh@suse.de>
>
> [PATCH 1/4] vfs: introduce function to map unique ino/dev pairs
>
> There are places in the VFS where we export an ino/dev pair to userspace.
> /proc/PID/maps is a good example - we directly expose inode->i_ino and
> inode->i_sb->s_dev to userspace there.  Many filesystems don't put a unique
> value in inode->i_ino and instead rely on ->getattr to provide the real
> inode number to userspace.  super->s_dev is similar - some filesystems
> expose a difference device from what's put in super->s_dev when queried via
> stat/statx.
>
> Ultimately this makes it impossible for a user (or software) to match one of
> those reported pairs to the right inode.
>
> We can fix this by adding a helper function, vfs_map_unique_ino_dev(), which
> will query the owning filesystem (via ->getattr) to get the correct ino/dev
> pair.  Later patches will update those places which simply dump inode->i_ino
> and super->s_dev to use the helper.
>
> Signed-off-by: Mark Fasheh <mfasheh@suse.de>
> ---
>  fs/stat.c          | 22 ++++++++++++++++++++++
>  include/linux/fs.h |  2 ++
>  2 files changed, 24 insertions(+)
>
> diff --git a/fs/stat.c b/fs/stat.c
> index f8e6fb2c3657..20c72d618ed5 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> @@ -84,6 +84,28 @@ int vfs_getattr_nosec(const struct path *path, struct kstat *stat,
>  }
>  EXPORT_SYMBOL(vfs_getattr_nosec);
>
> +void vfs_map_unique_ino_dev(struct dentry *dentry, u64 *ino, dev_t *dev)

I find this function name a bit more than function can guaranty.
It's just a fancy wrapper around ->getattr()
How about vfs_get_ino_dev() ?

Thanks,
Amir.
