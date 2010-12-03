Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47111 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753580Ab0LCWd3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Dec 2010 17:33:29 -0500
Date: Fri, 3 Dec 2010 17:33:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Nick Piggin <npiggin@gmail.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH] nfsd4: allow __d_obtain_alias() to return unhashed dentries
Message-ID: <20101203223326.GB28763@fieldses.org>
References: <20101112184353.GA32745@fieldses.org>
 <AANLkTinOSGtrW1S3LKWXarJF-=ZKgh_GMKuPA2ppu-P4@mail.gmail.com>
 <20101115174837.GB10044@fieldses.org>
 <AANLkTim1QjTwOZ4SHdMy8Y6TOAnaOYtTwgwHXfH5H5Xn@mail.gmail.com>
 <AANLkTinMq1W1vx-jZnf7cb1cAnh9OyoVRYtVS7zpujfs@mail.gmail.com>
 <20101129193248.GA9897@fieldses.org>
 <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Without this patch

       client$ mount -tnfs4 server:/export/ /mnt/
       client$ tail -f /mnt/FOO
       ...
       server$ df -i /export
       server$ rm /export/FOO
       (^C the tail -f)
       server$ df -i /export
       server$ echo 2 >/proc/sys/vm/drop_caches
       server$ df -i /export

the df's will show that the inode is not freed on the filesystem until
the last step, when it could have been freed after killing the client's
tail -f.  On-disk data won't be deallocated either, leading to possible
spurious ENOSPC.

This occurs because when the client does the close, it arrives in a
compound with a putfh and a close, processed like:

       - putfh: look up the filehandle.  The only alias found for the
         inode will be DCACHE_UNHASHED alias referenced by the filp
         associated with the nfsd open.  d_obtain_alias() doesn't like
         this, so it creates a new DCACHE_DISCONECTED dentry and
         returns that instead.

Nick Piggin suggested fixing this by allowing d_obtain_alias to return
the unhashed dentry that is referenced by the filp, instead of making it
create a new dentry.

Cc: Nick Piggin <npiggin@gmail.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

On Tue, Nov 30, 2010 at 12:00:16PM +1100, Nick Piggin wrote:
> On Tue, Nov 30, 2010 at 6:32 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Mon, Nov 29, 2010 at 02:56:22PM +1100, Nick Piggin wrote:
> >> On Tue, Nov 16, 2010 at 5:45 PM, Nick Piggin <npiggin@gmail.com> wrote:
> >> > On Tue, Nov 16, 2010 at 4:48 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> >> On Sat, Nov 13, 2010 at 10:53:12PM +1100, Nick Piggin wrote:
> >> >>> Can you even put the link check into __d_find_alias?
> >> >>>
> >> >>> -               if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
> >> >>> +               if (S_ISDIR(inode->i_mode) || !inode->i_nlink ||
> >> >>> !d_unhashed(alias)) {
> >> >>>
> >> >>> Something like that?
> >> >>
> >> >> The immediate result of that would be for the close rpc (or any rpc's
> >> >> sent after the file was unlinked) to fail with ESTALE.
> >> >
> >> > Why is that? Seems like it would be a bug, because a hashed dentry may
> >> > be unhashed at any time concurrently to nfsd operation, so it should be
> >> > able to tolerate that so long as it has a ref on the inode?
> >>
> >> Ping? Did you work out why nfs fails with ESTALE in that case? It seems
> >> to work in my testing (and do the right thing with freeing the inode).
> >
> > Bah, sorry, I read too quickly, got the sense of the test backwards, and
> > thought you were suggesting __d_find_alias() shouldn't return an alias
> > in the i_nlink == 0 case!
> >
> > Yes, agreed, that should solve my problem.
> 
> OK, good.
> 
> > But what's the reason for the d_unhashed() check now?  Could we get rid
> > of it entirely?
> 
> Well when the inode still has links I think we actually do want any new
> references to go to hashed dentries. Definitely for d_splice_alias.

So here's a version with a changelog; objections?

--b.

diff --git a/fs/dcache.c b/fs/dcache.c
index 23702a9..afa8a0d 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -368,7 +368,7 @@ static struct dentry * __d_find_alias(struct inode *inode, int want_discon)
 		next = tmp->next;
 		prefetch(next);
 		alias = list_entry(tmp, struct dentry, d_alias);
- 		if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
+		if (S_ISDIR(inode->i_mode) || !inode->i_nlink || !d_unhashed(alias)) {
 			if (IS_ROOT(alias) &&
 			    (alias->d_flags & DCACHE_DISCONNECTED))
 				discon_alias = alias;
-- 
1.7.1

