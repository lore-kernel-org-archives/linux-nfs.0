Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:32781 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754836AbdIGLff (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Sep 2017 07:35:35 -0400
Received: by mail-yw0-f180.google.com with SMTP id s62so14149282ywg.0
        for <linux-nfs@vger.kernel.org>; Thu, 07 Sep 2017 04:35:35 -0700 (PDT)
Message-ID: <1504784132.4954.12.camel@redhat.com>
Subject: Re: [PATCH] nfs: track writeback errors with errseq_t
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@kernel.org>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Thu, 07 Sep 2017 07:35:32 -0400
In-Reply-To: <87efrjb2mn.fsf@notabene.neil.brown.name>
References: <20170720194227.7830-1-jlayton@kernel.org>
         <1503683981.22608.0.camel@redhat.com>
         <87h8wsiog4.fsf@notabene.neil.brown.name>
         <1503920855.4563.12.camel@redhat.com>
         <87pobfgo9q.fsf@notabene.neil.brown.name>
         <1504004058.4679.7.camel@redhat.com>
         <87efrjb2mn.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-09-07 at 13:37 +1000, NeilBrown wrote:
> On Tue, Aug 29 2017, Jeff Layton wrote:
> 
> > On Tue, 2017-08-29 at 11:23 +1000, NeilBrown wrote:
> > > On Mon, Aug 28 2017, Jeff Layton wrote:
> > > 
> > > > On Mon, 2017-08-28 at 09:24 +1000, NeilBrown wrote:
> > > > > On Fri, Aug 25 2017, Jeff Layton wrote:
> > > > > 
> > > > > > On Thu, 2017-07-20 at 15:42 -0400, Jeff Layton wrote:
> > > > > > > From: Jeff Layton <jlayton@redhat.com>
> > > > > > > 
> > > > > > > There is some ambiguity in nfs about how writeback errors are
> > > > > > > tracked.
> > > > > > > 
> > > > > > > For instance, nfs_pageio_add_request calls mapping_set_error when
> > > > > > > the
> > > > > > > add fails, but we track errors that occur after adding the
> > > > > > > request
> > > > > > > with a dedicated int error in the open context.
> > > > > > > 
> > > > > > > Now that we have better infrastructure for the vfs layer, this
> > > > > > > latter int is now unnecessary. Just have
> > > > > > > nfs_context_set_write_error set
> > > > > > > the error in the mapping when one occurs.
> > > > > > > 
> > > > > > > Have NFS use file_write_and_wait_range to initiate and wait on
> > > > > > > writeback
> > > > > > > of the data, and then check again after issuing the commit(s).
> > > > > > > 
> > > > > > > With this, we also don't need to pay attention to the ERROR_WRITE
> > > > > > > flag for reporting, and just clear it to indicate to subsequent
> > > > > > > writers that they should try to go asynchronous again.
> > > > > > > 
> > > > > > > In nfs_page_async_flush, sample the error before locking and
> > > > > > > joining
> > > > > > > the requests, and check for errors since that point.
> > > > > > > 
> > > > > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > > > > ---
> > > > > > >  fs/nfs/file.c          | 24 +++++++++++-------------
> > > > > > >  fs/nfs/inode.c         |  3 +--
> > > > > > >  fs/nfs/write.c         |  8 ++++++--
> > > > > > >  include/linux/nfs_fs.h |  1 -
> > > > > > >  4 files changed, 18 insertions(+), 18 deletions(-)
> > > > > > > 
> > > > > > > I have a baling wire and duct tape solution for testing this with
> > > > > > > xfstests (using iptables REJECT targets and soft mounts). This
> > > > > > > seems to
> > > > > > > make nfs do the right thing.
> > > > > > > 
> > > > > > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > > > > > > index 5713eb32a45e..15d3c6faafd3 100644
> > > > > > > --- a/fs/nfs/file.c
> > > > > > > +++ b/fs/nfs/file.c
> > > > > > > @@ -212,25 +212,23 @@ nfs_file_fsync_commit(struct file *file,
> > > > > > > loff_t start, loff_t end, int datasync)
> > > > > > >  {
> > > > > > >  	struct nfs_open_context *ctx =
> > > > > > > nfs_file_open_context(file);
> > > > > > >  	struct inode *inode = file_inode(file);
> > > > > > > -	int have_error, do_resend, status;
> > > > > > > -	int ret = 0;
> > > > > > > +	int do_resend, status;
> > > > > > > +	int ret;
> > > > > > >  
> > > > > > >  	dprintk("NFS: fsync file(%pD2) datasync %d\n", file,
> > > > > > > datasync);
> > > > > > >  
> > > > > > >  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
> > > > > > >  	do_resend =
> > > > > > > test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
> > > > > > > -	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE,
> > > > > > > &ctx->flags);
> > > > > > > -	status = nfs_commit_inode(inode, FLUSH_SYNC);
> > > > > > > -	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx-
> > > > > > > > flags);
> > > > > > > 
> > > > > > > -	if (have_error) {
> > > > > > > -		ret = xchg(&ctx->error, 0);
> > > > > > > -		if (ret)
> > > > > > > -			goto out;
> > > > > > > -	}
> > > > > > > -	if (status < 0) {
> > > > > > > +	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
> > > > > > > +	ret = nfs_commit_inode(inode, FLUSH_SYNC);
> > > > > > > +
> > > > > > > +	/* Recheck and advance after the commit */
> > > > > > > +	status = file_check_and_advance_wb_err(file);
> > > > > 
> > > > > This change makes the code inconsistent with the comment above the
> > > > > function, which still references ctx->error.  The intent of the
> > > > > comment
> > > > > is still correct, but the details have changed.
> > > > > 
> > > > 
> > > > Good catch. I'll fix that up in a respin.
> > > > 
> > > > > Also, there is a call to mapping_set_error() in
> > > > > nfs_pageio_add_request().
> > > > > I wonder if that should be changed to
> > > > >   nfs_context_set_write_error(req->wb_context, desc->pg_error)
> > > > > ??
> > > > > 
> > > > 
> > > > Trickier question...
> > > > 
> > > > I'm not quite sure what semantics we're looking for with
> > > > NFS_CONTEXT_ERROR_WRITE. I know that it forces writes to be
> > > > synchronous, but I'm not quite sure why it gets cleared the way it
> > > > does. It's set on any error but cleared before issuing a commit.
> > > > 
> > > > I added a similar flag to Ceph inodes recently, but only clear it when
> > > > a write succeeds. Wouldn't that make more sense here as well?
> > > 
> > > It is a bit hard to wrap one's mind around.
> > > 
> > > In the original code (commit 7b159fc18d417980) it looks like:
> > >  - test-and-clear bit
> > >  - write and sync
> > >  - test-bit
> > > 
> > > This does, I think, seem safer than "clear on successful write" as the
> > > writes could complete out-of-order and I wouldn't be surprised if the
> > > unsuccessful ones completed with an error before the successful one -
> > > particularly with an error like EDQUOT.
> > > 
> > > However the current code does the writes before the test-and-clear, and
> > > only does the commit afterwards.  That makes it less clear why the
> > > current sequence is a good idea.
> > > 
> > > However ... nfs_file_fsync_commit() is only called if
> > > filemap_write_and_wait_range() returned with success, so we only clear
> > > the flag after successful writes(?).
> > > 
> > > Oh....
> > > This patch from me:
> > > 
> > > Commit: 2edb6bc3852c ("NFS - fix recent breakage to NFS error handling.")
> > > 
> > > seems to have been reverted by
> > > 
> > > Commit: 7b281ee02655 ("NFS: fsync() must exit with an error if page writeback failed")
> > > 
> > > which probably isn't good.  It appears that this code is very fragile
> > > and easily broken.
> 
> On further investigation, I think the problem that I fixed and then we
> reintroduced will be fixed again - more permanently - by your patch.
> The root problem is that nfs keeps error codes in a different way to the
> MM core.  By unifying those, the problem goes.
> (The specific problem is that writes which hit EDQUOT on the server can
>  report EIO on the client).
> 
> 
> > > Maybe we need to work out exactly what is required, and document it - so
> > > we can stop breaking it.
> > > Or maybe we need some unit tests.....
> > > 
> > 
> > Yes, laying out what's necessary for this would be very helpful. We
> > clearly want to set the flag when an error occurs. Under what
> > circumstances should we be clearing it?
> 
> Well.... looking back at  7b159fc18d417980f57ae which introduced the
> flag, prior to that write errors (ctx->error) were only reported by
> nfs_file_flush and nfs_fsync, so only one close() and fsync().
> 
> After that commit, setting the flag would mean that errors could be
> returned by 'write'.  So clearing as part of returning the error makes
> perfect sense.
> 
> As long as the error gets recorded, and gets returned when it is
> recorded, it doesn't much matter when the flag is cleared.  With your
> patches we don't need to flag any more to get errors reliably reported.
> 
> Leaving the flag set means that writes go more slowly - we don't get
> large queue of background rights building up but destined for failure.
> This is the main point made in the comment message when the flag was
> introduced.
> Of course, by the time we first get an error there could already
> by a large queue, so we probably want that to drain completely before
> allowing async writes again.
> 
> It might make sense to have 2 flags.  One which says "writes should be
> synchronous", another that says "There was an error recently".
> We clear the error flag before calling nfs_fsync, and if it is still
> clear afterwards, we clear the sync-writes flag.  Maybe that is more
> complex than needed though.
> 
> I'm leaning towards your suggestion that it doesn't matter very much
> when it gets cleared, and clearing it on any successful write is
> simplest.
> 
> So I'm still in favor of using nfs_context_set_write_error() in
> nfs_pageio_add_request(), primarily because it is most consistent - we
> don't need exceptions.

Thanks for taking a closer look. I can easily make the change above, and
I do think that keeping this mechanism as simple as possible will make
it easier to prevent bitrot.

That said... NFS_CONTEXT_ERROR_WRITE is a per ctx flag, and the ctx is a
per open file description object.

Is that the correct way to track this? All of the ctx's will share the
same inode. If we're getting writeback errors for one context, it's
quite likely that we'll be seeing them via others.

I suppose the counterargument is when we have things like expiring krb5
tickets. Write failures via an expiring set of creds may have no effect
on writeback via other creds.

Still, I think a per-inode flag might make more sense here.

Thoughts?
-- 
Jeff Layton <jlayton@redhat.com>
