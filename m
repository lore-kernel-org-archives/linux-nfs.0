Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36364 "EHLO
	mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbcGGKxI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2016 06:53:08 -0400
Received: by mail-qt0-f196.google.com with SMTP id w59so475819qtd.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jul 2016 03:53:07 -0700 (PDT)
Message-ID: <1467888784.3195.20.camel@poochiereds.net>
Subject: Re: [RFC] [PATCH 0/2] mkdir lookup optimization
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jul 2016 06:53:04 -0400
In-Reply-To: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru>
References: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-07-07 at 01:53 -0400, Oleg Drokin wrote:
> (sorry for resend, the first go around did not make it to fsdevel and to Al).
> 
> This is inspired by a bug in Lustre that's ATM is shared by NFS
> and used o be shared by CIFS code.
> 
> The problem at hand is: when you try to mkdir in a directory
> where you do not have permissions to create anything, you only
> supposed to get EPERM if the directory you are creatign does not exist.
> Now if the name does exist, you are supposed to get EEXIST instead.
> There are tons of programs that when fed a pathname go and try
> to perform a create of every path component starting from /,
> and ignoring EEXIST, but not other errors. Those programs are broken
> by the above mentioned bug.
> 
> All is fine everywhere by Lustre and NFS at the moment, because
> there's an optimization at hand. e.g. in NFS:
>        /*
>         * If we're doing an exclusive create, optimize away the lookup
>         * but don't hash the dentry.
>         */
>        if (nfs_is_exclusive_create(dir, flags))
>                return NULL;
> 
> Now, this is all fine except when you have no permissions to create
> anything - then vfs_mknod/mkdir/create will do may_create(dir, dentry)
> and we exit spuriously with EPERM.
> 
> [green@fedora1 crash]$ mkdir aaa 
> mkdir: cannot create directory 'aaa': Permission denied
> [green@fedora1 crash]$ mkdir lost+found
> mkdir: cannot create directory 'lost+found': Permission denied
> [green@fedora1 crash]$ ls -ld lost+found
> drwx------ 2 root root 16384 May 25  2013 lost+found
> [green@fedora1 crash]$ mkdir lost+found
> mkdir: cannot create directory 'lost+found': File exists
> 
> cifs had exactly the same code, but it got removed when atomic_open
> was introduced (throwing away a perfectly good optimization for mkdir
> in process) with commit d2c127197dfc0b2bae62a52e1e0d3e3ff493919e
> "cifs: implement i_op->atomic_open()"
> 
> These two patches are the lazy way of fixing the problem -
> "just throw in the extra permission check before bailing out"
> with a bit of complication on the NFS side because there
> the inode permission check is actually circumvented in nfs_permission,
> for MAY_WRITE | !MAY_READ case which is enough to fool
> may_create, but not enough to fool some following check, I guess
> as the problem still exists.
> (I am not sure of the performance implications of just removing that
> thing in nfs_permission).
> 
> Anyway I think instead of resurrecting this optimization for cifs,
> and seeing if ceph and others need it, why not bring it up
> all the way to __lookup_hash() so that we don't do actual lookup
> if the parent is writeable?
> 
> Even for local filesystems like ext4 that's of benefit - we save
> one lookup (even with hashed dirs, that only gives us the last blook
> to lookat and then we still need to check all names to make sure
> the one we want does not exist - so it's not exactly free).
> 
> This should not upset any sort of client-side SELinux/other security
> stuff magic either. If the name exists, we get EEXIST no matter what,
> if it does not exist, parent policy declares if we can create or not
> anyway.
> 
> Something like this (+ whatever nfs_permission fix):
> diff --git a/fs/namei.c b/fs/namei.c
> index 70580ab..b9de645 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -1512,6 +1512,10 @@ static struct dentry *__lookup_hash(const struct qstr *name,
> 	if (unlikely(!dentry))
> 		return ERR_PTR(-ENOMEM);
> 
> +	if ((flags & LOOKUP_EXCL|LOOKUP_CREATE) &&
> +	    (may_create(base, dentry) == 0))
> +		return dentry;
> +

That would need to check that LOOKUP_EXCL is actually set. I think you
want something like:

   (flags & (LOOKUP_EXCL|LOOKUP_CREATE)) == (LOOKUP_EXCL|LOOKUP_CREATE)

...and you'd have to figure out how to determine the isdir param for
may_create at that point.

That said, it does seem like a reasonable idea at first glance.

> 	return lookup_real(base->d_inode, dentry, flags);
> }
> 
> Comments?
> 
> Oleg Drokin (2):
>   nfs: Fix spurios EPERM when mkdir of existing dentry
>   staging/lustre: Prevent spurious EPERM on mkdir
> 
>  drivers/staging/lustre/lustre/llite/namei.c | 8 ++++++--
>  fs/nfs/dir.c                                | 4 +++-
>  2 files changed, 9 insertions(+), 3 deletions(-)
> 

-- 
Jeff Layton <jlayton@poochiereds.net>
