Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33044 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752126AbdLFLyq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 06:54:46 -0500
Received: by mail-qt0-f195.google.com with SMTP id e2so8289176qti.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Dec 2017 03:54:46 -0800 (PST)
Message-ID: <1512561283.4048.1.camel@redhat.com>
Subject: Re: [RFC v4 4/9] namespace: Add umount_end superblock operation
From: Jeff Layton <jlayton@redhat.com>
To: Joshua Watt <jpewhacker@gmail.com>, NeilBrown <neilb@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Date: Wed, 06 Dec 2017 06:54:43 -0500
In-Reply-To: <20171117174552.18722-5-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
         <20171117174552.18722-5-JPEWhacker@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-11-17 at 11:45 -0600, Joshua Watt wrote:
> The umount_end operation allows cleaning of state set by umount_begin in
> the event the filesystem doesn't actually get unmounted.
> 
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  fs/namespace.c     | 22 ++++++++++++++++++++--
>  include/linux/fs.h |  1 +
>  2 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index d18deb4c410b..d2587be4d08b 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1524,6 +1524,12 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
>  	}
>  }
>  
> +static void umount_end(struct super_block *sb, int flags)
> +{
> +	if (flags & MNT_FORCE && sb->s_op->umount_end)

nit: might get some complaints from compiler about order of operations
there. I'd put parenthesis around the flags & MNT_FORCE.

> +		sb->s_op->umount_end(sb);
> +}
> +
>  static void shrink_submounts(struct mount *mnt);
>  
>  static int do_umount(struct mount *mnt, int flags)
> @@ -1589,12 +1595,16 @@ static int do_umount(struct mount *mnt, int flags)
>  		 * Special case for "unmounting" root ...
>  		 * we just try to remount it readonly.
>  		 */
> -		if (!capable(CAP_SYS_ADMIN))
> -			return -EPERM;
> +		if (!capable(CAP_SYS_ADMIN)) {
> +			retval = -EPERM;
> +			goto out_umount_end;
> +		}
>  		down_write(&sb->s_umount);
>  		if (!sb_rdonly(sb))
>  			retval = do_remount_sb(sb, SB_RDONLY, NULL, 0);
>  		up_write(&sb->s_umount);
> +		/* Still mounted. Always invoke the cleanup */
> +		umount_end(sb, flags);
>  		return retval;
>  	}
>  
> @@ -1617,6 +1627,14 @@ static int do_umount(struct mount *mnt, int flags)
>  	}
>  	unlock_mount_hash();
>  	namespace_unlock();
> +
> +out_umount_end:
> +	/* If the umount failed and the file system is still mounted, allow the
> +	 * driver to cleanup any state it may have setup in umount_begin(). Note
> +	 * that this is purposely *not* called when MNT_DETACH is specified.
> +	 */
> +	if (retval)
> +		umount_end(sb, flags);
>  	return retval;
>  }
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 885266aae2d7..5443c22da18f 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1816,6 +1816,7 @@ struct super_operations {
>  	int (*statfs) (struct dentry *, struct kstatfs *);
>  	int (*remount_fs) (struct super_block *, int *, char *);
>  	void (*umount_begin) (struct super_block *);
> +	void (*umount_end)(struct super_block *);
>  
>  	int (*show_options)(struct seq_file *, struct dentry *);
>  	int (*show_devname)(struct seq_file *, struct dentry *);

Since this involves vfs-level changes, please cc linux-fsdevel@vger.kern
el.org on further postings. Other filesystem devs may be interested in
what you're doing here.
-- 
Jeff Layton <jlayton@redhat.com>
