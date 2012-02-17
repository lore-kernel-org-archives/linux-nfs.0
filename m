Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:44469 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062Ab2BQQee convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2012 11:34:34 -0500
MIME-Version: 1.0
In-Reply-To: <20120216223011.GA23997@fieldses.org>
References: <20101227234641.GA22248@fieldses.org> <20110118204509.GA10903@fieldses.org>
 <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org> <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk> <20110311150749.2fa2be66@notabene.brown>
 <20120214170300.GA4309@fieldses.org> <20120215165633.GE12490@fieldses.org>
 <20120216140603.08cb4900@notabene.brown> <20120216223011.GA23997@fieldses.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Sat, 18 Feb 2012 00:34:14 +0800
Message-ID: <CA+a=Yy7WgT37Gost38MrV-qtk8MgnTdqKmjBQDvRLGmuh59r3g@mail.gmail.com>
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed dentries
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Nick Piggin <npiggin@gmail.com>, Nick Piggin <npiggin@kernel.dk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 17, 2012 at 6:30 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Feb 16, 2012 at 02:06:03PM +1100, NeilBrown wrote:
>> I was going ask how you managed to get an 'unhashed' dentry which was not
>> DISCONNECTED, and belonged to a directory that could be the subject of
>> d_splice_alias (that implies it has a name).
>>
>> The bug sounds like a race between lookup and rmdir, which should be
>> prevented by i_mutex.
>>
>> I think that using __d_find_any_alias would just be papering over the
>> problem, and would trigger a BUG_ON when it returned a non-DISCONNECTED alias.
>
> Looking through the latest upstream code, I can't come up with another
> obvious reproducer.
>
> But I also can't see the code making any particular effort to ensure
> that dentries are removed from inode's alias lists at the same time
> they're unhashed.
>
> E.g., trace up through the callers of d_drop/__d_drop and try to
> convince yourselves that they all end up removing the dentry from the
> alias list.
>
> Can you see any reason why the following would actually create a
> problem?
>
> --b.
>
> commit fcfef6b7319c5d19ea5064317528ff994343b011
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Mon Feb 13 13:38:33 2012 -0500
>
>    exports: stop d_splice_alias creating directory aliases
>
>    A directory should never have more than one dentry pointing to it.
>
>    But d_splice_alias() does so in the case of a directory with an
>    already-existing non-DISCONNECTED dentry.
>
>    Prior to the removal of dentry_unhash() from vfs_rmdir(), around v3.0,
>    this could cause an nfsd deadlock like this:
>
>        - Somebody attempts to remove a non-empty directory.
>        - The dentry_unhash() in vfs_rmdir() unhashes the dentry
>          pointing to the non-empty directory.
>        - ->rmdir() then fails with -ENOTEMPTY
>        - Before the vfs_rmdir() caller reaches dput(), an nfsd process
>          in rename looks up the directory by filehandle; at the end of
>          that lookup, this dentry is found by d_alloc_anon(), and a
>          reference is taken on it, preventing dput() from removing it.
>        - A regular lookup of the directory calls d_splice_alias(),
>          finds only an unhashed (not a DISCONNECTED) dentry, and
>          insteads adds a new one, so the directory now has two
>          dentries.
>        - The nfsd process in rename, which was previously looking up
>          the source directory of the rename, now looks up the target
>          directory (which is the same), and gets the dentry newly
>          created by the previous lookup.
>        - The rename, seeing two different dentries, assumes this is a
>          cross-directory rename and attempts to take the i_mutex on the
>          directory twice.
>
>    I don't see as obvious a reproducer now, but I also don't see the
>    existing code taking care to remove dentries from the alias list
>    whenever they're unhashed.
>
>    It therefore seems safest to allow d_splice_alias to use any dentry it
>    finds.
>
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index f68e193..1fd2256 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1602,9 +1602,8 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
>
>        if (inode && S_ISDIR(inode->i_mode)) {
>                spin_lock(&inode->i_lock);
> -               new = __d_find_alias(inode, 1);
by replacing this, the want_discon argument is no longer in use. care
to remove it as well?

-- 
Thanks,
Tao
> +               new = __d_find_any_alias(inode);
>                if (new) {
> -                       BUG_ON(!(new->d_flags & DCACHE_DISCONNECTED));
>                        spin_unlock(&inode->i_lock);
>                        security_d_instantiate(new, inode);
>                        d_move(new, dentry);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
