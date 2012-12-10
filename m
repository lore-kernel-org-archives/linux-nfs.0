Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab2LJSIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 13:08:51 -0500
Date: Mon, 10 Dec 2012 13:08:47 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "jiali@redhat.com" <jiali@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: don't extend writes to cover entire page if
 pagecache is invalid
Message-ID: <20121210130847.2eebbf03@corrin.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91191DE05@SACEXCMBX04-PRD.hq.netapp.com>
References: <1355149548-4225-1-git-send-email-jlayton@redhat.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91191BACE@SACEXCMBX04-PRD.hq.netapp.com>
	<20121210110547.2eade853@corrin.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91191DCB0@SACEXCMBX04-PRD.hq.netapp.com>
	<20121210115316.1a4d74c9@corrin.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91191DD42@SACEXCMBX04-PRD.hq.netapp.com>
	<20121210122028.114b94b4@corrin.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91191DE05@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Dec 2012 18:00:06 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2012-12-10 at 12:20 -0500, Jeff Layton wrote:
> > On Mon, 10 Dec 2012 17:02:00 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Mon, 2012-12-10 at 11:53 -0500, Jeff Layton wrote:
> > > > On Mon, 10 Dec 2012 16:28:47 +0000
> > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > > 
> > > > > On Mon, 2012-12-10 at 11:05 -0500, Jeff Layton wrote:
> > > > > > On Mon, 10 Dec 2012 14:42:23 +0000
> > > > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > > > > 
> > > > > > > On Mon, 2012-12-10 at 09:25 -0500, Jeff Layton wrote:
> > > > > > > > Jian reported that the following sequence would leave "testfile" with
> > > > > > > > corrupt data:
> > > > > > > > 
> > > > > > > >     # mount localhost:/export /mnt/nfs/ -o vers=3
> > > > > > > >     # echo abc > /mnt/nfs/testfile; echo def >> /export/testfile; echo ghi >> /mnt/nfs/testfile
> > > > > > > >     # cat -v /export/testfile
> > > > > > > >     abc
> > > > > > > >     ^@^@^@^@ghi
> > > > > > > > 
> > > > > > > > While there's no locking involved here, the operations are serialized,
> > > > > > > > so CTO should prevent corruption.
> > > > > > > > 
> > > > > > > > The first write to the file is fine and writes 4 bytes. The file is then
> > > > > > > > extended on the server. When it's reopened a GETATTR is issued and the
> > > > > > > > size change is noticed. This causes NFS_INO_INVALID_DATA to be set on
> > > > > > > > the file. Because the file is opened for write only,
> > > > > > > > nfs_want_read_modify_write() returns 0 to nfs_write_begin().
> > > > > > > > nfs_updatepage then calls nfs_write_pageuptodate() to see if it should
> > > > > > > > extend the nfs_page to cover the whole page. NFS_INO_INVALID_DATA is
> > > > > > > > still set on the file at that point, but that flag is ignored and
> > > > > > > > nfs_pageuptodate erroneously extends the write to cover the whole page,
> > > > > > > > with the write done on the server side filled in with zeroes.
> > > > > > > > 
> > > > > > > > This patch just has that function check for NFS_INO_INVALID_DATA in
> > > > > > > > addition to NFS_INO_REVAL_PAGECACHE. This fixes the bug, but looking
> > > > > > > > over the code, I wonder if we might have a similar bug in
> > > > > > > > nfs_revalidate_size(). The difference between those two flags is very
> > > > > > > > subtle, so it seems like we ought to be checking for
> > > > > > > > NFS_INO_INVALID_DATA in most of the places that we look for
> > > > > > > > NFS_INO_REVAL_PAGECACHE.
> > > > > > > > 
> > > > > > > > I believe this is regression introduced by commit 8d197a568. The code
> > > > > > > > did check for NFS_INO_INVALID_DATA prior to that patch.
> > > > > > > > 
> > > > > > > > Original bug report is here:
> > > > > > > > 
> > > > > > > >     https://bugzilla.redhat.com/show_bug.cgi?id=885743
> > > > > > > 
> > > > > > > Hi Jeff,
> > > > > > > 
> > > > > > > The point of NFS_INO_REVAL_PAGECACHE is to be able to distinguish
> > > > > > > between situations where the file size or change attribute is in doubt
> > > > > > > (and so the page cache validity is in doubt), and situations where other
> > > > > > > attributes are in doubt (such as ACCESS caches, file owner, nlinks,...).
> > > > > > > This is why we're only checking for NFS_INO_REVAL_PAGECACHE and not
> > > > > > > NFS_INO_INVALID_DATA in the functions you mention above.
> > > > > > > 
> > > > > > 
> > > > > > Ok, now I'm really confused... I thought that:
> > > > > > 
> > > > > > NFS_INO_INVALID_DATA == pagecache data was known to be wrong
> > > > > > NFS_INO_REVAL_PAGECACHE == pagecache data is questionable
> > > > > 
> > > > > There is no "known to be wrong" state. Both mean "needs revalidation".
> > > > > 
> > > > > > ...but if I understand what you're saying above, the "data" that
> > > > > > NFS_INO_INVALID_DATA refers to is in peripheral caches, like the ACCESS
> > > > > > cache? I guess then I don't quite understand what NFS_INO_INVALID_ATTR
> > > > > > and NFS_INO_INVALID_ACCESS are for. Aren't they supposed to indicate that
> > > > > > the attrs and access caches are invalid?
> > > > > 
> > > > > NFS_INO_INVALID_ATTR basically means that some aspect of the file
> > > > > metadata needs revalidation, and so a call to nfs_revalidate_inode()
> > > > > will always result in a GETATTR rpc call.
> > > > > 
> > > > > NFS_INO_INVALID_ACCESS means that the file access cache needs
> > > > > revalidation. A call to nfs_do_access() will always result in an ACCESS
> > > > > rpc call.
> > > > > 
> > > > > NFS_INO_REVAL_PAGECACHE means that the file page cache data needs
> > > > > revalidation. A call to nfs_revalidate_file_size() or
> > > > > nfs_revalidate_mapping() will result in a revalidation of the page
> > > > > cache. In practice that means a GETATTR rpc call, but that may change if
> > > > > future versions of NFS allow for different methods of revalidating the
> > > > > page cache; consider, for instance, the byte-range delegation RFC that
> > > > > Bruce and I published a few years back.
> > > > > 
> > > > 
> > > > Ok, thanks. Another question though -- what does NFS_INO_INVALID_DATA
> > > > mean, and what distinguishes it from NFS_INO_REVAL_PAGECACHE?
> > > 
> > > See above. They affect _different_ revalidation situations (represented
> > > by different revalidation functions).
> > > 
> > > > > > > So the fix here should be to set NFS_INO_REVAL_PAGECACHE when the change
> > > > > > > attribute and/or size change is noticed. The only function I can see
> > > > > > > that appears to get this wrong is nfs_wcc_update_inode(). Does fixing
> > > > > > > that lay the bug to rest?
> > > > > > > 
> > > > > > 
> > > > > > No, that doesn't fix it. There's another place that misses setting that
> > > > > > flag too in nfs_update_inode() where the size changes. I added it there
> > > > > > too and that also didn't fix it. Here's why (I think):
> > > > > > 
> > > > > > When the size change is noticed via the CTO GETATTR call, then my
> > > > > > patched kernel now sets NFS_INO_REVAL_PAGECACHE in nfs_update_inode.
> > > > > > Now cache_validity is set to 0x2a. The kernel then makes an ACCESS call
> > > > > > that also ultimately ends up in nfs_update_inode.
> > > > > > 
> > > > > > nfs_update_inode saves off the cache_validity flags and clears all of
> > > > > > them except for NFS_INO_INVALID_DATA. As best I can tell, the
> > > > > > saved_cache_validity is then ending up discarded and on exit the
> > > > > > cache_validity is ending up set to just NFS_INO_INVALID_DATA.
> > > > > > 
> > > > > > It seems like we ought to be restoring the save_cache_validity flags
> > > > > > before exiting that function, but I confess that I don't quite grasp
> > > > > > the logic in nfs_update_inode. Thoughts?
> > > > > 
> > > > > If the ACCESS call isn't revalidating the file size, then it should not
> > > > > be clearing NFS_INO_REVAL_PAGECACHE; it does this by restoring that bit
> > > > > from the "save_cache_validity" variable and storing it in "invalid". As
> > > > > far as I can tell, that code is correct in upstream.
> > > > > 
> > > > 
> > > > FWIW, I'm working on a 3.7-rc8 kernel here...
> > > > 
> > > > The ACCESS call ends up with an fattr that has NFS_ATTR_FATTR_SIZE set,
> > > > it just doesn't detect any change in size due to the fact that the CTO
> > > > GETATTR call has already updated it.
> > > > 
> > > > ------------------[snip]------------------------
> > > >         /* Check if our cached file size is stale */
> > > >         if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
> > > >                 new_isize = nfs_size_to_loff_t(fattr->size);
> > > >                 cur_isize = i_size_read(inode);
> > > >                 if (new_isize != cur_isize) {
> > > >                         /* Do we perhaps have any outstanding writes, or has
> > > >                          * the file grown beyond our last write? */
> > > >                         if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) ||
> > > >                              new_isize > cur_isize) {
> > > >                                 i_size_write(inode, new_isize);
> > > >                                 invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> > > >                         }
> > > >                         dprintk("NFS: isize change on server for file %s/%ld "
> > > >                                         "(%Ld to %Ld)\n",
> > > >                                         inode->i_sb->s_id,
> > > >                                         inode->i_ino,
> > > >                                         (long long)cur_isize,
> > > >                                         (long long)new_isize);
> > > >                 }
> > > >         } else
> > > >                 invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> > > >                                 | NFS_INO_REVAL_PAGECACHE
> > > >                                 | NFS_INO_REVAL_FORCED);
> > > > ------------------[snip]------------------------
> > > > 
> > > > So here, we only restore set the REVAL_PAGECACHE flag in invalid if the
> > > > size changed, or there was no size attribute present in the response.
> > > > The size hasn't changed since the GETATTR call, so REVAL_PAGECACHE is
> > > > not restored.
> > > 
> > > I don't understand. Why does it need to be restored? The
> > > NFS_ATTR_FATTR_SIZE is set, so the server has sent us an updated value
> > > for the size. Is it lying to us?
> > > 
> > 
> > No, this is NFSv3 and IIUC, NFS_ATTR_FATTR_SIZE just means that
> > fattr->size is populated with a value sent by the server. In fact,
> > looking at decode_fattr3():
> > 
> >         fattr->valid |= NFS_ATTR_FATTR_V3;
> > 
> > ...and NFS_ATTR_FATTR_V3 contains NFS_ATTR_FATTR_SIZE.
> 
> Right. The NFSv3 server is always supposed to send us the correct value
> for the size.
> 
> > Maybe this flag doesn't need to be restored. I really don't understand
> > the current logic in nfs_update_inode at all so I'll have to defer to
> > your judgement here.
> > 
> > All I know is that when the CTO GETATTR call is done, the kernel sees
> > that the size has changed. Presumably, it sets NFS_INO_REVAL_PAGECACHE
> > to reflect that fact.
> 
> It should also set NFS_INO_INVALID_DATA, which is _not_ cleared by
> nfs_update_inode()
> 
> >  Then, on the following ACCESS call that gets back
> > attributes, it clears that flag without invalidating the cache.
> 
> Ah... I see the bug:
> 
> nfs_write_pageuptodate() needs to check for NFS_INO_REVAL_PAGECACHE|
> NFS_INO_INVALID_DATA...
> 

That's exactly what the original patch I sent did :)
-- 
Jeff Layton <jlayton@redhat.com>
