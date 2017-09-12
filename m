Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:33459 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdILPUU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Sep 2017 11:20:20 -0400
Received: by mail-yw0-f171.google.com with SMTP id s62so28962219ywg.0
        for <linux-nfs@vger.kernel.org>; Tue, 12 Sep 2017 08:20:19 -0700 (PDT)
Message-ID: <1505229616.28831.26.camel@redhat.com>
Subject: Re: [PATCH] nfs: track writeback errors with errseq_t
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date: Tue, 12 Sep 2017 11:20:16 -0400
In-Reply-To: <87poawc390.fsf@notabene.neil.brown.name>
References: <20170720194227.7830-1-jlayton@kernel.org>
         <1503683981.22608.0.camel@redhat.com>
         <87h8wsiog4.fsf@notabene.neil.brown.name>
         <1503920855.4563.12.camel@redhat.com>
         <87pobfgo9q.fsf@notabene.neil.brown.name>
         <1504004058.4679.7.camel@redhat.com>
         <87efrjb2mn.fsf@notabene.neil.brown.name>
         <1504784132.4954.12.camel@redhat.com>
         <1504796087.3561.7.camel@primarydata.com>
         <874ls9diij.fsf@notabene.neil.brown.name>
         <1505126785.4916.7.camel@redhat.com>
         <87poawc390.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-09-12 at 07:52 +1000, NeilBrown wrote:
> > On Mon, 2017-09-11 at 13:24 +1000, NeilBrown wrote:
> > > On Thu, Sep 07 2017, Trond Myklebust wrote:
> > > 
> > > > On Thu, 2017-09-07 at 07:35 -0400, Jeff Layton wrote:
> > > > > On Thu, 2017-09-07 at 13:37 +1000, NeilBrown wrote:
> > > > > > On Tue, Aug 29 2017, Jeff Layton wrote:
> > > > > > 
> > > > > > > On Tue, 2017-08-29 at 11:23 +1000, NeilBrown wrote:
> > > > > > > > On Mon, Aug 28 2017, Jeff Layton wrote:
> > > > > > > > 
> > > > > > > > > On Mon, 2017-08-28 at 09:24 +1000, NeilBrown wrote:
> > > > > > > > > > On Fri, Aug 25 2017, Jeff Layton wrote:
> > > > > > > > > > 
> > > > > > > > > > > On Thu, 2017-07-20 at 15:42 -0400, Jeff Layton wrote:
> > > > > > > > > > > > From: Jeff Layton <jlayton@redhat.com>
> > > > > > > > > > > > 
> > > > > > > > > > > > There is some ambiguity in nfs about how writeback
> > > > > > > > > > > > errors are
> > > > > > > > > > > > tracked.
> > > > > > > > > > > > 
> > > > > > > > > > > > For instance, nfs_pageio_add_request calls
> > > > > > > > > > > > mapping_set_error when
> > > > > > > > > > > > the
> > > > > > > > > > > > add fails, but we track errors that occur after adding
> > > > > > > > > > > > the
> > > > > > > > > > > > request
> > > > > > > > > > > > with a dedicated int error in the open context.
> > > > > > > > > > > > 
> > > > > > > > > > > > Now that we have better infrastructure for the vfs
> > > > > > > > > > > > layer, this
> > > > > > > > > > > > latter int is now unnecessary. Just have
> > > > > > > > > > > > nfs_context_set_write_error set
> > > > > > > > > > > > the error in the mapping when one occurs.
> > > > > > > > > > > > 
> > > > > > > > > > > > Have NFS use file_write_and_wait_range to initiate and
> > > > > > > > > > > > wait on
> > > > > > > > > > > > writeback
> > > > > > > > > > > > of the data, and then check again after issuing the
> > > > > > > > > > > > commit(s).
> > > > > > > > > > > > 
> > > > > > > > > > > > With this, we also don't need to pay attention to the
> > > > > > > > > > > > ERROR_WRITE
> > > > > > > > > > > > flag for reporting, and just clear it to indicate to
> > > > > > > > > > > > subsequent
> > > > > > > > > > > > writers that they should try to go asynchronous again.
> > > > > > > > > > > > 
> > > > > > > > > > > > In nfs_page_async_flush, sample the error before
> > > > > > > > > > > > locking and
> > > > > > > > > > > > joining
> > > > > > > > > > > > the requests, and check for errors since that point.
> > > > > > > > > > > > 
> > > > > > > > > > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > > > > > > > > > ---
> > > > > > > > > > > >  fs/nfs/file.c          | 24 +++++++++++-------------
> > > > > > > > > > > >  fs/nfs/inode.c         |  3 +--
> > > > > > > > > > > >  fs/nfs/write.c         |  8 ++++++--
> > > > > > > > > > > >  include/linux/nfs_fs.h |  1 -
> > > > > > > > > > > >  4 files changed, 18 insertions(+), 18 deletions(-)
> > > > > > > > > > > > 
> > > > > > > > > > > > I have a baling wire and duct tape solution for testing
> > > > > > > > > > > > this with
> > > > > > > > > > > > xfstests (using iptables REJECT targets and soft
> > > > > > > > > > > > mounts). This
> > > > > > > > > > > > seems to
> > > > > > > > > > > > make nfs do the right thing.
> > > > > > > > > > > > 
> > > > > > > > > > > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > > > > > > > > > > > index 5713eb32a45e..15d3c6faafd3 100644
> > > > > > > > > > > > --- a/fs/nfs/file.c
> > > > > > > > > > > > +++ b/fs/nfs/file.c
> > > > > > > > > > > > @@ -212,25 +212,23 @@ nfs_file_fsync_commit(struct file
> > > > > > > > > > > > *file,
> > > > > > > > > > > > loff_t start, loff_t end, int datasync)
> > > > > > > > > > > >  {
> > > > > > > > > > > >  	struct nfs_open_context *ctx =
> > > > > > > > > > > > nfs_file_open_context(file);
> > > > > > > > > > > >  	struct inode *inode = file_inode(file);
> > > > > > > > > > > > -	int have_error, do_resend, status;
> > > > > > > > > > > > -	int ret = 0;
> > > > > > > > > > > > +	int do_resend, status;
> > > > > > > > > > > > +	int ret;
> > > > > > > > > > > >  
> > > > > > > > > > > >  	dprintk("NFS: fsync file(%pD2) datasync %d\n",
> > > > > > > > > > > > file,
> > > > > > > > > > > > datasync);
> > > > > > > > > > > >  
> > > > > > > > > > > >  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
> > > > > > > > > > > >  	do_resend =
> > > > > > > > > > > > test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx-
> > > > > > > > > > > > > flags);
> > > > > > > > > > > > 
> > > > > > > > > > > > -	have_error =
> > > > > > > > > > > > test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE,
> > > > > > > > > > > > &ctx->flags);
> > > > > > > > > > > > -	status = nfs_commit_inode(inode, FLUSH_SYNC);
> > > > > > > > > > > > -	have_error |=
> > > > > > > > > > > > test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx-
> > > > > > > > > > > > > flags);
> > > > > > > > > > > > 
> > > > > > > > > > > > -	if (have_error) {
> > > > > > > > > > > > -		ret = xchg(&ctx->error, 0);
> > > > > > > > > > > > -		if (ret)
> > > > > > > > > > > > -			goto out;
> > > > > > > > > > > > -	}
> > > > > > > > > > > > -	if (status < 0) {
> > > > > > > > > > > > +	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx-
> > > > > > > > > > > > > flags);
> > > > > > > > > > > > 
> > > > > > > > > > > > +	ret = nfs_commit_inode(inode, FLUSH_SYNC);
> > > > > > > > > > > > +
> > > > > > > > > > > > +	/* Recheck and advance after the commit */
> > > > > > > > > > > > +	status = file_check_and_advance_wb_err(file);
> > > > > > > > > > 
> > > > > > > > > > This change makes the code inconsistent with the comment
> > > > > > > > > > above the
> > > > > > > > > > function, which still references ctx->error.  The intent of
> > > > > > > > > > the
> > > > > > > > > > comment
> > > > > > > > > > is still correct, but the details have changed.
> > > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > Good catch. I'll fix that up in a respin.
> > > > > > > > > 
> > > > > > > > > > Also, there is a call to mapping_set_error() in
> > > > > > > > > > nfs_pageio_add_request().
> > > > > > > > > > I wonder if that should be changed to
> > > > > > > > > >   nfs_context_set_write_error(req->wb_context, desc-
> > > > > > > > > > > pg_error)
> > > > > > > > > > 
> > > > > > > > > > ??
> > > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > Trickier question...
> > > > > > > > > 
> > > > > > > > > I'm not quite sure what semantics we're looking for with
> > > > > > > > > NFS_CONTEXT_ERROR_WRITE. I know that it forces writes to be
> > > > > > > > > synchronous, but I'm not quite sure why it gets cleared the
> > > > > > > > > way it
> > > > > > > > > does. It's set on any error but cleared before issuing a
> > > > > > > > > commit.
> > > > > > > > > 
> > > > > > > > > I added a similar flag to Ceph inodes recently, but only
> > > > > > > > > clear it when
> > > > > > > > > a write succeeds. Wouldn't that make more sense here as well?
> > > > > > > > 
> > > > > > > > It is a bit hard to wrap one's mind around.
> > > > > > > > 
> > > > > > > > In the original code (commit 7b159fc18d417980) it looks like:
> > > > > > > >  - test-and-clear bit
> > > > > > > >  - write and sync
> > > > > > > >  - test-bit
> > > > > > > > 
> > > > > > > > This does, I think, seem safer than "clear on successful write"
> > > > > > > > as the
> > > > > > > > writes could complete out-of-order and I wouldn't be surprised
> > > > > > > > if the
> > > > > > > > unsuccessful ones completed with an error before the successful
> > > > > > > > one -
> > > > > > > > particularly with an error like EDQUOT.
> > > > > > > > 
> > > > > > > > However the current code does the writes before the test-and-
> > > > > > > > clear, and
> > > > > > > > only does the commit afterwards.  That makes it less clear why
> > > > > > > > the
> > > > > > > > current sequence is a good idea.
> > > > > > > > 
> > > > > > > > However ... nfs_file_fsync_commit() is only called if
> > > > > > > > filemap_write_and_wait_range() returned with success, so we
> > > > > > > > only clear
> > > > > > > > the flag after successful writes(?).
> > > > > > > > 
> > > > > > > > Oh....
> > > > > > > > This patch from me:
> > > > > > > > 
> > > > > > > > Commit: 2edb6bc3852c ("NFS - fix recent breakage to NFS error
> > > > > > > > handling.")
> > > > > > > > 
> > > > > > > > seems to have been reverted by
> > > > > > > > 
> > > > > > > > Commit: 7b281ee02655 ("NFS: fsync() must exit with an error if
> > > > > > > > page writeback failed")
> > > > > > > > 
> > > > > > > > which probably isn't good.  It appears that this code is very
> > > > > > > > fragile
> > > > > > > > and easily broken.
> > > > > > 
> > > > > > On further investigation, I think the problem that I fixed and then
> > > > > > we
> > > > > > reintroduced will be fixed again - more permanently - by your
> > > > > > patch.
> > > > > > The root problem is that nfs keeps error codes in a different way
> > > > > > to the
> > > > > > MM core.  By unifying those, the problem goes.
> > > > > > (The specific problem is that writes which hit EDQUOT on the server
> > > > > > can
> > > > > >  report EIO on the client).
> > > > > > 
> > > > > > 
> > > > > > > > Maybe we need to work out exactly what is required, and
> > > > > > > > document it - so
> > > > > > > > we can stop breaking it.
> > > > > > > > Or maybe we need some unit tests.....
> > > > > > > > 
> > > > > > > 
> > > > > > > Yes, laying out what's necessary for this would be very helpful.
> > > > > > > We
> > > > > > > clearly want to set the flag when an error occurs. Under what
> > > > > > > circumstances should we be clearing it?
> > > > > > 
> > > > > > Well.... looking back at  7b159fc18d417980f57ae which introduced
> > > > > > the
> > > > > > flag, prior to that write errors (ctx->error) were only reported by
> > > > > > nfs_file_flush and nfs_fsync, so only one close() and fsync().
> > > > > > 
> > > > > > After that commit, setting the flag would mean that errors could be
> > > > > > returned by 'write'.  So clearing as part of returning the error
> > > > > > makes
> > > > > > perfect sense.
> > > > > > 
> > > > > > As long as the error gets recorded, and gets returned when it is
> > > > > > recorded, it doesn't much matter when the flag is cleared.  With
> > > > > > your
> > > > > > patches we don't need to flag any more to get errors reliably
> > > > > > reported.
> > > > > > 
> > > > > > Leaving the flag set means that writes go more slowly - we don't
> > > > > > get
> > > > > > large queue of background rights building up but destined for
> > > > > > failure.
> > > > > > This is the main point made in the comment message when the flag
> > > > > > was
> > > > > > introduced.
> > > > > > Of course, by the time we first get an error there could already
> > > > > > by a large queue, so we probably want that to drain completely
> > > > > > before
> > > > > > allowing async writes again.
> > > > 
> > > > We already have this functionality implemented in the existing code.
> > > > 
> > > > > > 
> > > > > > It might make sense to have 2 flags.  One which says "writes should
> > > > > > be
> > > > > > synchronous", another that says "There was an error recently".
> > > > > > We clear the error flag before calling nfs_fsync, and if it is
> > > > > > still
> > > > > > clear afterwards, we clear the sync-writes flag.  Maybe that is
> > > > > > more
> > > > > > complex than needed though.
> > > > > > 
> > > > 
> > > > We also need to preserve the NFS_CONTEXT_RESEND_WRITES flag. I don't
> > > > see any global mechanism that will replace that.
> > > > 
> > > > > > I'm leaning towards your suggestion that it doesn't matter very
> > > > > > much
> > > > > > when it gets cleared, and clearing it on any successful write is
> > > > > > simplest.
> > > > > > 
> > > > > > So I'm still in favor of using nfs_context_set_write_error() in
> > > > > > nfs_pageio_add_request(), primarily because it is most consistent -
> > > > > > we
> > > > > > don't need exceptions.
> > > > > 
> > > > > Thanks for taking a closer look. I can easily make the change above,
> > > > > and
> > > > > I do think that keeping this mechanism as simple as possible will
> > > > > make
> > > > > it easier to prevent bitrot.
> > > > > 
> > > > > That said... NFS_CONTEXT_ERROR_WRITE is a per ctx flag, and the ctx
> > > > > is a
> > > > > per open file description object.
> > > > > 
> > > > > Is that the correct way to track this? All of the ctx's will share
> > > > > the
> > > > > same inode. If we're getting writeback errors for one context, it's
> > > > > quite likely that we'll be seeing them via others.
> > > > > 
> > > > > I suppose the counterargument is when we have things like expiring
> > > > > krb5
> > > > > tickets. Write failures via an expiring set of creds may have no
> > > > > effect
> > > > > on writeback via other creds.
> > > > > 
> > > > > Still, I think a per-inode flag might make more sense here.
> > > > > 
> > > > > Thoughts?
> > > > 
> > > > As far as I'm concerned, that would be a regression. The most common
> > > > problem when flushing writeback data to the server aside from ENOSPC
> > > > (and possibly ESTALE) is EACCES, which is particular to the file
> > > > descriptor that opened the file.
> > > > 
> > > > File contexts, and NFS_CONTEXT_ERROR_WRITE solve that problem by being
> > > > private to the file descriptor.
> > > 
> > > Thanks for the reminder that errors are per-context and this patch drops
> > > this.  The per-context nature of errors in NFS was the reason that I
> > > nagged Jeff to make errseq_t a stand-alone type rather than just a part
> > > of address_space.  I had envisaged that it would be embedded in the
> > > open_context as well.
> > > We still could do that, but as there is precisely one open-file for each
> > > open_context, the gains are not great.
> > > 
> > > However, while looking over the code to make sure I really understood it
> > > and all the possible consequences of changing to errseq_t I found a few
> > > anomalies.  The patch below addresses them all.
> > > 
> > > Would you see if they may sense to you?
> > > 
> > > Thanks,
> > > NeilBrown
> > > 
> > > 
> > > From: NeilBrown <neilb@suse.com>
> > > Date: Mon, 11 Sep 2017 13:15:50 +1000
> > > Subject: [PATCH] NFS: various changes relating to reporting IO errors.
> > > 
> > > 1/ remove 'start' and 'end' args from nfs_file_fsync_commit().
> > >    They aren't used.
> > > 
> > > 2/ Make nfs_context_set_write_error() a "static inline" in internal.h
> > >    so we can...
> > > 
> > > 3/ Use nfs_context_set_write_error() instead of mapping_set_error()
> > >    if nfs_pageio_add_request() fails before sending any request.
> > >    NFS generally keeps errors in the open_context, not the mapping,
> > >    so this is more consistent.
> > > 
> > > 4/ If filemap_write_and_write_range() reports any error, still
> > >    check ctx->error.  The value in ctx->error is likely to be
> > >    more useful.  As part of this, NFS_CONTEXT_ERROR_WRITE is
> > >    cleared slightly earlier, before nfs_file_fsync_commit() is called,
> > >    rather than at the start of that function.
> > > 
> > > Signed-off-by: NeilBrown <neilb@suse.com>
> > > ---
> > >  fs/nfs/file.c     | 16 ++++++++++------
> > >  fs/nfs/internal.h |  7 +++++++
> > >  fs/nfs/pagelist.c |  4 ++--
> > >  fs/nfs/write.c    |  7 -------
> > >  4 files changed, 19 insertions(+), 15 deletions(-)
> > > 
> > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > > index af330c31f627..ab324f14081f 100644
> > > --- a/fs/nfs/file.c
> > > +++ b/fs/nfs/file.c
> > > @@ -208,21 +208,19 @@ EXPORT_SYMBOL_GPL(nfs_file_mmap);
> > >   * fall back to doing a synchronous write.
> > >   */
> > >  static int
> > > -nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
> > > +nfs_file_fsync_commit(struct file *file, int datasync)
> > >  {
> > >  	struct nfs_open_context *ctx = nfs_file_open_context(file);
> > >  	struct inode *inode = file_inode(file);
> > > -	int have_error, do_resend, status;
> > > +	int do_resend, status;
> > >  	int ret = 0;
> > >  
> > >  	dprintk("NFS: fsync file(%pD2) datasync %d\n", file, datasync);
> > >  
> > >  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
> > >  	do_resend = test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
> > > -	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
> > >  	status = nfs_commit_inode(inode, FLUSH_SYNC);
> > > -	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
> > > -	if (have_error) {
> > > +	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags)) {
> > >  		ret = xchg(&ctx->error, 0);
> > >  		if (ret)
> > >  			goto out;
> > > @@ -247,10 +245,16 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
> > >  	trace_nfs_fsync_enter(inode);
> > >  
> > >  	do {
> > > +		struct nfs_open_context *ctx = nfs_file_open_context(file);
> > >  		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
> > > +		if (test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags)) {
> > > +			int ret2 = xchg(&ctx->error, 0);
> > > +			if (ret2)
> > > +				ret = ret2;
> > > +		}
> > >  		if (ret != 0)
> > >  			break;
> > > -		ret = nfs_file_fsync_commit(file, start, end, datasync);
> > > +		ret = nfs_file_fsync_commit(file, datasync);
> > >  		if (!ret)
> > >  			ret = pnfs_sync_inode(inode, !!datasync);
> > >  		/*
> > > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > > index dc456416d2be..44c8962fec91 100644
> > > --- a/fs/nfs/internal.h
> > > +++ b/fs/nfs/internal.h
> > > @@ -769,3 +769,10 @@ static inline bool nfs_error_is_fatal(int err)
> > >  		return false;
> > >  	}
> > >  }
> > > +
> > > +static inline void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
> > > +{
> > > +	ctx->error = error;
> > > +	smp_wmb();
> > > +	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
> > > +}
> > > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> > > index de9066a92c0d..0ebd26b9a6bd 100644
> > > --- a/fs/nfs/pagelist.c
> > > +++ b/fs/nfs/pagelist.c
> > > @@ -1198,8 +1198,8 @@ out_failed:
> > >  
> > >  		/* remember fatal errors */
> > >  		if (nfs_error_is_fatal(desc->pg_error))
> > > -			mapping_set_error(desc->pg_inode->i_mapping,
> > > -					  desc->pg_error);
> > > +			nfs_context_set_write_error(req->wb_context,
> > > +						    desc->pg_error);
> > >  
> > >  		func = desc->pg_completion_ops->error_cleanup;
> > >  		for (midx = 0; midx < desc->pg_mirror_count; midx++) {
> > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > index b1af5dee5e0a..f702bf2def79 100644
> > > --- a/fs/nfs/write.c
> > > +++ b/fs/nfs/write.c
> > > @@ -147,13 +147,6 @@ static void nfs_io_completion_put(struct nfs_io_completion *ioc)
> > >  		kref_put(&ioc->refcount, nfs_io_completion_release);
> > >  }
> > >  
> > > -static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
> > > -{
> > > -	ctx->error = error;
> > > -	smp_wmb();
> > > -	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
> > > -}
> > > -
> > >  /*
> > >   * nfs_page_find_head_request_locked - find head request associated with @page
> > >   *
> > 
> > This should probably be broken out into at least a 2-3 different
> > patches.
> > 
> > Ok, so to make sure I understand:
> > 
> > All writeback is done under the aegis of an open context, and writes
> > from different open contexts are not mergeable. We also flush to the
> > server in the case that a dirty page is written via an incompatible open
> > context. So with that we can always tie
> 
> Not quite.  Writes from different open contexts are sometimes mergeable,
> providing the credential is the same and there are no locks that might
> get in the way. (nfs_flush_incompatible() gets rid of conflicts writes
> to the same page as part of nfs_write_begin().
> When writes are merged, all contexts remain reachable from the request
> through an 'nfs_page'. nfs_write_completion() iterates over all the
> nfs_pages attached to the nfs_pgio_header, and sets the context
> write_error from the hdr->error.
> 

Ok, by this account, NFS should already have "correct" error reporting
semantics on fsync. i.e. when the file is written via multiple fds, you
should get back an error on all fds if those writebacks failed.

I have a test for nfs for the new-style error reporting:

    https://git.kernel.org/pub/scm/linux/kernel/git/jlayton/xfstests-dev.git/log/?h=wberr

The nfs test is still pretty rickety, using soft mounts and iptables to
cause requests to fail. With the patch I originally proposed, this test
would pass. When I run this test on normal mainline kernels, it fails:

-------------------------------8<------------------------------
FSTYP         -- nfs
PLATFORM      -- Linux/x86_64 wberr 4.12.11-300.fc26.x86_64
MKFS_OPTIONS  -- knfsdsrv:/export/scratch
MOUNT_OPTIONS -- -o context=system_u:object_r:root_t:s0 knfsdsrv:/export/scratch /mnt/scratch

nfs/002	 - output mismatch (see /home/jlayton/git/xfstests/results//nfs/002.out.bad)
    --- tests/nfs/002.out	2017-07-19 13:12:59.354561869 -0400
    +++ /home/jlayton/git/xfstests/results//nfs/002.out.bad	2017-09-12 11:17:17.335943539 -0400
    @@ -1,3 +1,3 @@
     QA output created by 002
     Format and mount
    -Test passed!
    +Success on second fsync on fd[1]!
    ...
    (Run 'diff -u tests/nfs/002.out /home/jlayton/git/xfstests/results//nfs/002.out.bad'  to see the entire diff)
Ran: nfs/002
Failures: nfs/002
Failed 1 of 1 tests
-------------------------------8<------------------------------

I'm not sure that errors are really propagated to all struct files like
you suggest above. I'll plan to look a little more closely at what's
happening here, when I get some time.

> > 
> > In that case, yes...mixing in errseq_t doesn't really buy us much here,
> > and I agree with most of the changes above.
> > 
> > That said...I'm still not thrilled with how NFS_CONTEXT_ERROR_WRITE is
> > handled in this code. That flag is set when a write fails, but is only
> > cleared on fsync.
> > 
> > That seems wrong to me. Why wait for an fsync to start doing async
> > writes again once they start working? What if the application never does
> > an fsync? Clearing that flag on a successful WRITE seems like it'd make
> > more sense.
> 
> We don't really 'wait' for an fsync.  Having NFS_CONTEXT_ERROR_WRITE
> means that the very next write will force an fsync
> (nfs_need_check_write()).  So we really just wait for the next write.
> The current code doesn't seem "obviously right" to me, but it isn't
> "obviously wrong" either, and I can only make it obviously right to me
> by making it more complex, and I don't think I can justify that.

Thanks for pointing this out. I missed the bit about it forcing the
fsync when this fails. I agree that that should be fine.

-- 
Jeff Layton <jlayton@redhat.com>
