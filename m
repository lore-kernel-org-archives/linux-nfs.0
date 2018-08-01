Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:46207 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387592AbeHAMtL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 08:49:11 -0400
Received: by mail-qk0-f195.google.com with SMTP id 191-v6so6381599qki.13
        for <linux-nfs@vger.kernel.org>; Wed, 01 Aug 2018 04:03:57 -0700 (PDT)
Message-ID: <b5b90ff75a222ce3ace37dbd625916ae9aaa9830.camel@poochiereds.net>
Subject: Re: [PATCH 4/4] locks: map correct ino/dev pairs when exporting to
 userspace
From: Jeff Layton <jlayton@poochiereds.net>
To: Mark Fasheh <mfasheh@suse.de>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Cc: linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org
Date: Wed, 01 Aug 2018 07:03:54 -0400
In-Reply-To: <20180731211045.5671-5-mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de>
         <20180731211045.5671-5-mfasheh@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2018-07-31 at 14:10 -0700, Mark Fasheh wrote:
> /proc/locks does not always print the correct inode number/device pair.
> Update lock_get_status() to use vfs_map_unique_ino_dev() to get the real,
> unique values for userspace.
> 
> Signed-off-by: Mark Fasheh <mfasheh@suse.de>
> ---
>  fs/locks.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index db7b6917d9c5..3a012df87fd8 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -2621,6 +2621,7 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
>  			    loff_t id, char *pfx)
>  {
>  	struct inode *inode = NULL;
> +	struct dentry *dentry;
>  	unsigned int fl_pid;
>  	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
>  
> @@ -2633,8 +2634,10 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
>  	if (fl_pid == 0)
>  		return;
>  
> -	if (fl->fl_file != NULL)
> +	if (fl->fl_file != NULL) {
>  		inode = locks_inode(fl->fl_file);
> +		dentry = file_dentry(fl->fl_file);
> +	}
>  
>  	seq_printf(f, "%lld:%s ", id, pfx);
>  	if (IS_POSIX(fl)) {
> @@ -2681,10 +2684,13 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
>  			       : (fl->fl_type == F_WRLCK) ? "WRITE" : "READ ");
>  	}
>  	if (inode) {
> +		__u64 ino;
> +		dev_t dev;
> +
> +		vfs_map_unique_ino_dev(dentry, &ino, &dev);

This code is under a spinlock (blocked_locks_lock or ctx->flc_lock). I
don't think it'll be ok to call ->getattr while holding a spinlock.

>  		/* userspace relies on this representation of dev_t */
>  		seq_printf(f, "%d %02x:%02x:%ld ", fl_pid,
> -				MAJOR(inode->i_sb->s_dev),
> -				MINOR(inode->i_sb->s_dev), inode->i_ino);
> +				MAJOR(dev), MINOR(dev), inode->i_ino);
>  	} else {
>  		seq_printf(f, "%d <none>:0 ", fl_pid);
>  	}

-- 
Jeff Layton <jlayton@poochiereds.net>

