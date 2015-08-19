Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43517 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbbHSE5A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2015 00:57:00 -0400
Date: Wed, 19 Aug 2015 14:56:50 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/6 v9] fs: New helper legitimize_mntget() for getting a
 legitimize mnt
Message-ID: <20150819145650.46352023@noble>
In-Reply-To: <55D2DD17.7050504@gmail.com>
References: <55D2DBF6.3010406@gmail.com>
	<55D2DD17.7050504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 18 Aug 2015 15:21:59 +0800 Kinglong Mee <kinglongmee@gmail.com>
wrote:

> New helper legitimize_mntget for getting a mnt without setting
> MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED, otherwise return NULL.
> 
> v9, Update using read_seqbegin_or_lock instead read_seqlock_excl
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/namespace.c        | 30 ++++++++++++++++++++++++++++++
>  include/linux/mount.h |  1 +
>  2 files changed, 31 insertions(+)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 2b8aa15..bf4a9f5 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1153,6 +1153,36 @@ struct vfsmount *mntget(struct vfsmount *mnt)
>  }
>  EXPORT_SYMBOL(mntget);
>  
> +struct vfsmount *legitimize_mntget(struct vfsmount *vfsmnt)
> +{
> +	struct mount *mnt;
> +	unsigned seq = 0;
> +
> +	if (vfsmnt == NULL)
> +		return NULL;
> +retry:
> +	read_seqbegin_or_lock(&mount_lock, &seq);
> +
> +	if (vfsmnt->mnt_flags & (MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED))
> +		vfsmnt = NULL;
> +	else if (need_seqretry(&mount_lock, seq))
> +		goto retry;
> +	else {
> +		mnt = real_mount(vfsmnt);
> +		mnt_add_count(mnt, 1);
> +		if (need_seqretry(&mount_lock, seq) ||
> +		    vfsmnt->mnt_flags & (MNT_SYNC_UMOUNT | MNT_UMOUNT |
> +					 MNT_DOOMED)) {
> +			mnt_add_count(mnt, -1);
> +			goto retry;
> +		}
> +	}
> +
> +	done_seqretry(&mount_lock, seq);
> +	return vfsmnt;
> +}
> +EXPORT_SYMBOL(legitimize_mntget);

I'm struggling with this.  I know I wrote the above, but I'm no longer
sure it is correct .. at all.

All three of those flags are only set while mount_lock is held for
writing, so if the second need_seqretry() returns zero, then we can
be certain that none of the flags have changed yet, so there is no point
testing them again.

Ahh...  looking back at __legitimize_mnt I think I see the important
point now - or at least I now see that point which I saw before more
clearly.

After the mnt_add_count, if need_seqretry() returns zero, we are done.
If not, we need to clean up and try again.
To do this we need to check MNT_SYNC_UMOUNT.
If that is clear it is safe and best to call mntput() on the mnt.
If it is set, then we just do the mnt_add_count(mnt, -1) and give up
completely.

Also, the usage for read_seqbegin_or_lock is all wrong.  I'm sure I
copied something but I got it badly wrong.
When you retry, you need to set 'seq' to 1, otherwise it never locks.
I thought it would be more "clever" than at.

So maybe:

retry:
  read_seqbegin_or_lock(&mount_lock, &seq);

  if (vfsmnt->mnt_flags & (....))
        vfs_mnt = NULL;
  else {
        mnt = real_mount(vfsmnt);
        mnt_add_count(mnt, 1);
        if (need_seqretry(&mount_lock, seq)) {
             /* lost the race, need to try again */
             if (vfsmnt->mnt_flags & MNT_SYNC_UMOUNT) {
                  /* no point trying... */
                  mnt_add_count(mnt, -1):
                  vfsmnt = NULL;
             } else {
                  mntput(vfsmnt);
                  seq = 1;
                  goto retry;
             }
        }
  }
  done_seqretry(&mount_lock, seq);
  return vfsmnt;


NeilBrown

