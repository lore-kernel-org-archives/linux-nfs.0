Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:24199 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750903Ab0LMFTu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Dec 2010 00:19:50 -0500
Date: Mon, 13 Dec 2010 16:19:44 +1100
From: Nick Piggin <npiggin@kernel.dk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfsd4: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20101213051944.GA8688@amd>
References: <20101112184353.GA32745@fieldses.org>
 <AANLkTinOSGtrW1S3LKWXarJF-=ZKgh_GMKuPA2ppu-P4@mail.gmail.com>
 <20101115174837.GB10044@fieldses.org>
 <AANLkTim1QjTwOZ4SHdMy8Y6TOAnaOYtTwgwHXfH5H5Xn@mail.gmail.com>
 <AANLkTinMq1W1vx-jZnf7cb1cAnh9OyoVRYtVS7zpujfs@mail.gmail.com>
 <20101129193248.GA9897@fieldses.org>
 <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
 <20101203223326.GB28763@fieldses.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20101203223326.GB28763@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 03, 2010 at 05:33:27PM -0500, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> Without this patch
> 
>        client$ mount -tnfs4 server:/export/ /mnt/
>        client$ tail -f /mnt/FOO
>        ...
>        server$ df -i /export
>        server$ rm /export/FOO
>        (^C the tail -f)
>        server$ df -i /export
>        server$ echo 2 >/proc/sys/vm/drop_caches
>        server$ df -i /export
> 
> the df's will show that the inode is not freed on the filesystem until
> the last step, when it could have been freed after killing the client's
> tail -f.  On-disk data won't be deallocated either, leading to possible
> spurious ENOSPC.
> 
> This occurs because when the client does the close, it arrives in a
> compound with a putfh and a close, processed like:
> 
>        - putfh: look up the filehandle.  The only alias found for the
>          inode will be DCACHE_UNHASHED alias referenced by the filp
>          associated with the nfsd open.  d_obtain_alias() doesn't like
>          this, so it creates a new DCACHE_DISCONECTED dentry and
>          returns that instead.
> 
> Nick Piggin suggested fixing this by allowing d_obtain_alias to return
> the unhashed dentry that is referenced by the filp, instead of making it
> create a new dentry.
> 
> Cc: Nick Piggin <npiggin@gmail.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/dcache.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> On Tue, Nov 30, 2010 at 12:00:16PM +1100, Nick Piggin wrote:
> > On Tue, Nov 30, 2010 at 6:32 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > On Mon, Nov 29, 2010 at 02:56:22PM +1100, Nick Piggin wrote:
> > >> On Tue, Nov 16, 2010 at 5:45 PM, Nick Piggin <npiggin@gmail.com> wrote:
> > >> > On Tue, Nov 16, 2010 at 4:48 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > >> >> On Sat, Nov 13, 2010 at 10:53:12PM +1100, Nick Piggin wrote:
> > >> >>> Can you even put the link check into __d_find_alias?
> > >> >>>
> > >> >>> -               if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
> > >> >>> +               if (S_ISDIR(inode->i_mode) || !inode->i_nlink ||
> > >> >>> !d_unhashed(alias)) {
> > >> >>>
> > >> >>> Something like that?
> > >> >>
> > >> >> The immediate result of that would be for the close rpc (or any rpc's
> > >> >> sent after the file was unlinked) to fail with ESTALE.
> > >> >
> > >> > Why is that? Seems like it would be a bug, because a hashed dentry may
> > >> > be unhashed at any time concurrently to nfsd operation, so it should be
> > >> > able to tolerate that so long as it has a ref on the inode?
> > >>
> > >> Ping? Did you work out why nfs fails with ESTALE in that case? It seems
> > >> to work in my testing (and do the right thing with freeing the inode).
> > >
> > > Bah, sorry, I read too quickly, got the sense of the test backwards, and
> > > thought you were suggesting __d_find_alias() shouldn't return an alias
> > > in the i_nlink == 0 case!
> > >
> > > Yes, agreed, that should solve my problem.
> > 
> > OK, good.
> > 
> > > But what's the reason for the d_unhashed() check now?  Could we get rid
> > > of it entirely?
> > 
> > Well when the inode still has links I think we actually do want any new
> > references to go to hashed dentries. Definitely for d_splice_alias.
> 
> So here's a version with a changelog; objections?

Not sure where Al's hiding...

But I would like to update the comments, and perhaps even a new
add a new function here (or new flag to __d_find_alias).

AFAIKS, the callers are OK, however I suppose d_splice_alias and
d_materialise_unique should not have unlinked inodes at this point,
so at least a BUG_ON for them might be a good idea?

> 
> --b.
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 23702a9..afa8a0d 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -368,7 +368,7 @@ static struct dentry * __d_find_alias(struct inode *inode, int want_discon)
>  		next = tmp->next;
>  		prefetch(next);
>  		alias = list_entry(tmp, struct dentry, d_alias);
> - 		if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
> +		if (S_ISDIR(inode->i_mode) || !inode->i_nlink || !d_unhashed(alias)) {
>  			if (IS_ROOT(alias) &&
>  			    (alias->d_flags & DCACHE_DISCONNECTED))
>  				discon_alias = alias;
