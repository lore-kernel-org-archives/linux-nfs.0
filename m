Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:38012 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdH1Lrj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Aug 2017 07:47:39 -0400
Received: by mail-qt0-f174.google.com with SMTP id w42so919630qtg.5
        for <linux-nfs@vger.kernel.org>; Mon, 28 Aug 2017 04:47:38 -0700 (PDT)
Message-ID: <1503920855.4563.12.camel@redhat.com>
Subject: Re: [PATCH] nfs: track writeback errors with errseq_t
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@kernel.org>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Mon, 28 Aug 2017 07:47:35 -0400
In-Reply-To: <87h8wsiog4.fsf@notabene.neil.brown.name>
References: <20170720194227.7830-1-jlayton@kernel.org>
         <1503683981.22608.0.camel@redhat.com>
         <87h8wsiog4.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-08-28 at 09:24 +1000, NeilBrown wrote:
> On Fri, Aug 25 2017, Jeff Layton wrote:
> 
> > On Thu, 2017-07-20 at 15:42 -0400, Jeff Layton wrote:
> > > From: Jeff Layton <jlayton@redhat.com>
> > > 
> > > There is some ambiguity in nfs about how writeback errors are
> > > tracked.
> > > 
> > > For instance, nfs_pageio_add_request calls mapping_set_error when
> > > the
> > > add fails, but we track errors that occur after adding the
> > > request
> > > with a dedicated int error in the open context.
> > > 
> > > Now that we have better infrastructure for the vfs layer, this
> > > latter int is now unnecessary. Just have
> > > nfs_context_set_write_error set
> > > the error in the mapping when one occurs.
> > > 
> > > Have NFS use file_write_and_wait_range to initiate and wait on
> > > writeback
> > > of the data, and then check again after issuing the commit(s).
> > > 
> > > With this, we also don't need to pay attention to the ERROR_WRITE
> > > flag for reporting, and just clear it to indicate to subsequent
> > > writers that they should try to go asynchronous again.
> > > 
> > > In nfs_page_async_flush, sample the error before locking and
> > > joining
> > > the requests, and check for errors since that point.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  fs/nfs/file.c          | 24 +++++++++++-------------
> > >  fs/nfs/inode.c         |  3 +--
> > >  fs/nfs/write.c         |  8 ++++++--
> > >  include/linux/nfs_fs.h |  1 -
> > >  4 files changed, 18 insertions(+), 18 deletions(-)
> > > 
> > > I have a baling wire and duct tape solution for testing this with
> > > xfstests (using iptables REJECT targets and soft mounts). This
> > > seems to
> > > make nfs do the right thing.
> > > 
> > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > > index 5713eb32a45e..15d3c6faafd3 100644
> > > --- a/fs/nfs/file.c
> > > +++ b/fs/nfs/file.c
> > > @@ -212,25 +212,23 @@ nfs_file_fsync_commit(struct file *file,
> > > loff_t start, loff_t end, int datasync)
> > >  {
> > >  	struct nfs_open_context *ctx =
> > > nfs_file_open_context(file);
> > >  	struct inode *inode = file_inode(file);
> > > -	int have_error, do_resend, status;
> > > -	int ret = 0;
> > > +	int do_resend, status;
> > > +	int ret;
> > >  
> > >  	dprintk("NFS: fsync file(%pD2) datasync %d\n", file,
> > > datasync);
> > >  
> > >  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
> > >  	do_resend =
> > > test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
> > > -	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE,
> > > &ctx->flags);
> > > -	status = nfs_commit_inode(inode, FLUSH_SYNC);
> > > -	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx-
> > > >flags);
> > > -	if (have_error) {
> > > -		ret = xchg(&ctx->error, 0);
> > > -		if (ret)
> > > -			goto out;
> > > -	}
> > > -	if (status < 0) {
> > > +	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
> > > +	ret = nfs_commit_inode(inode, FLUSH_SYNC);
> > > +
> > > +	/* Recheck and advance after the commit */
> > > +	status = file_check_and_advance_wb_err(file);
> 
> This change makes the code inconsistent with the comment above the
> function, which still references ctx->error.  The intent of the
> comment
> is still correct, but the details have changed.
> 

Good catch. I'll fix that up in a respin.

> Also, there is a call to mapping_set_error() in
> nfs_pageio_add_request().
> I wonder if that should be changed to
>   nfs_context_set_write_error(req->wb_context, desc->pg_error)
> ??
> 

Trickier question...

I'm not quite sure what semantics we're looking for with
NFS_CONTEXT_ERROR_WRITE. I know that it forces writes to be
synchronous, but I'm not quite sure why it gets cleared the way it
does. It's set on any error but cleared before issuing a commit.

I added a similar flag to Ceph inodes recently, but only clear it when
a write succeeds. Wouldn't that make more sense here as well?

-- 
Jeff Layton <jlayton@redhat.com>
