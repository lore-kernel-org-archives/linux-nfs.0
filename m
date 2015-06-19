Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56655 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479AbbFSUoY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 16:44:24 -0400
Date: Fri, 19 Jun 2015 21:44:18 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 3/6 v5] fs_pin: Kill fs_pin under a reference of vfsmnt
Message-ID: <20150619204418.GM17109@ZenIV.linux.org.uk>
References: <5581266C.9080404@gmail.com>
 <558126FA.8050608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <558126FA.8050608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 17, 2015 at 03:51:22PM +0800, Kinglong Mee wrote:
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

This is absolutely wrong.  For one thing, you are running those suckers on
fairly deep stack now, which is a bloody bad idea for a lot reasons -
final mntput() can come with a lot of stack space consumed.  For another,
I'm really not convinced that what you are doing won't bugger the ordering
to hell and back - not without a detailed analysis I don't see in these
patches.

If you want to be able to grab references by those suckers, this is a very
wrong way to go.  Look at legitimize_mnt() for better approach, and yes,
you need to be able to cope with "too late, it's already doomed".  Or you'll
trade those -EBUSY for race with umount(2) returning before the fs shutdown
is complete.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
