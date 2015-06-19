Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45542 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753172AbbFSU3Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jun 2015 16:29:16 -0400
Date: Fri, 19 Jun 2015 16:29:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 3/6 v5] fs_pin: Kill fs_pin under a reference of vfsmnt
Message-ID: <20150619202916.GE21903@fieldses.org>
References: <5581266C.9080404@gmail.com>
 <558126FA.8050608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <558126FA.8050608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 17, 2015 at 03:51:22PM +0800, Kinglong Mee wrote:
> v5, new patch

I don't know this code at all.  I'll try to give it a proper review.
But could you help me by explaining in some detail what this is doing
and why you're sure it's correct?

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/namespace.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 1b9e111..3f08a48 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1049,8 +1049,6 @@ static void cleanup_mnt(struct mount *mnt)
>  	 * so mnt_get_writers() below is safe.
>  	 */
>  	WARN_ON(mnt_get_writers(mnt));
> -	if (unlikely(mnt->mnt_pins.first))
> -		mnt_pin_kill(mnt);
>  	fsnotify_vfsmount_delete(&mnt->mnt);
>  	dput(mnt->mnt.mnt_root);
>  	deactivate_super(mnt->mnt.mnt_sb);
> @@ -1078,6 +1076,7 @@ static DECLARE_DELAYED_WORK(delayed_mntput_work, delayed_mntput);
>  
>  static void mntput_no_expire(struct mount *mnt)
>  {
> +put_again:
>  	rcu_read_lock();
>  	mnt_add_count(mnt, -1);
>  	if (likely(mnt->mnt_ns)) { /* shouldn't be the last one */
> @@ -1090,6 +1089,13 @@ static void mntput_no_expire(struct mount *mnt)
>  		unlock_mount_hash();
>  		return;
>  	}
> +	if (unlikely(mnt->mnt_pins.first)) {
> +		mnt_add_count(mnt, 1);
> +		rcu_read_unlock();
> +		unlock_mount_hash();
> +		mnt_pin_kill(mnt);
> +		goto put_again;
> +	}
>  	if (unlikely(mnt->mnt.mnt_flags & MNT_DOOMED)) {
>  		rcu_read_unlock();
>  		unlock_mount_hash();
> -- 
> 2.4.3
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
