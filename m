Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35085 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458AbaGOQ43 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 12:56:29 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so974461qgd.37
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 09:56:28 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 12:56:26 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd4_locku / nfs4_free_lock_stateid question
Message-ID: <20140715125626.18fa1869@tlielax.poochiereds.net>
In-Reply-To: <20140715145029.GI17956@fieldses.org>
References: <20140713110047.GA28727@infradead.org>
	<20140713080541.30ecbb51@tlielax.poochiereds.net>
	<20140713121919.GA6456@infradead.org>
	<20140715081334.654473fd@tlielax.poochiereds.net>
	<20140715145029.GI17956@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Jul 2014 10:50:29 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jul 15, 2014 at 08:13:34AM -0400, Jeff Layton wrote:
> > On Sun, 13 Jul 2014 05:19:19 -0700
> > Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > > On Sun, Jul 13, 2014 at 08:05:41AM -0400, Jeff Layton wrote:
> > > > It is weird, but I don't think it really matters as the filp is only
> > > > really used as a way to get to the inode -- it really doesn't matter
> > > > which struct file we use there. find_any_file will both take a
> > > > reference to and return the file, which is then eventually fput in
> > > > filp_close, so there should be no refcount leak or anything.
> > > > 
> > > > The weirdness all comes from the vfs-layer file locking interfaces,
> > > > many of which take a struct file argument when they really would be
> > > > fine with a struct inode. Maybe one of these days we can get around to
> > > > cleaning that up.
> > > 
> > > If filesystems get the file passed we should assume that they actually
> > > use it.  In fact AFS does, but it's not NFS exportable at the moment,
> > > and ceph does in a debug printk.  I'd be much happier to waste a pointer
> > > in the lock stateid to avoid this inconsistant interface.  And it would
> > > allow to kill find_any_fileas well..
> > > 
> > 
> > I started looking at this this morning...
> > 
> > FWIW, I don't see where AFS uses the struct file for anything
> > non-trivial in the filp_close codepaths. afs_do_unlk doesn't seem to do
> > much with it, and I don't see a ->flush operation for AFS. Am I missing
> > something there?
> > 
> > Here's what I think this change would look like. It builds but is
> > otherwise untested, and the commit log is sort of half-assed right now.
> > It should get slotted on top of this patch in the series:
> > 
> >     nfsd: do filp_close in sc_free callback for lock stateids
> > 
> > I'm not sure this really improves anything.
> > 
> > For one thing, we can only store a single struct file, but there's no
> > guarantee that the locks represented by the lock stateid all used that
> > file.
> 
> Right, so after this patch st_file means "the last file used by a lock
> operation using this lock stateid"?
> 

Yes. If we did decide to use some variant of this, I might change the
name just to avoid confusion with the old st_file field.

> > Also, find_any_file is rather cheap, so I don't see this helping
> > performance much.
> > 
> > Given that, is this really worth the extra memory? Thoughts?
> 
> I'm not convinced it is.  But I understand that we're imposing a weird
> assumption on the lock interface: "if you're exportable, you should use
> the struct file we passed you only to get the inode".
> 
> It's out of scope for this work now, but I wonder whether my
> f9d7562fdb9d "nfsd4: share file descriptors between stateid's" was a
> mistake.  It also seemed potentially surprising to filesystems that we
> could write or write-lock using a struct file originally opened for
> read, but maybe that wasn't really a problem.
> 

Hmm...maybe.

I think though that you'd have had the same problem if you had tried to
use a different scheme. The VFS just doesn't do open upgrades today,
and that's the part that makes this so difficult.

Doing an upgrade means that you're going to change the struct file, and
that makes it difficult to guarantee that you'll always use the same one
for locking.


> > @@ -4866,8 +4849,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		case NFS4_READW_LT:
> >  			spin_lock(&fp->fi_lock);
> >  			filp = find_readable_file_locked(fp);
> > -			if (filp)
> > +			if (filp) {
> > +				swap(lock_stp->st_file, filp);
> >  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
> 
> I haven't checked carefully, but in the case of a new lock stateid, is
> st_file going to be NULL, in which case this is going to cause the
> openmode check following this case statement to fail?
> 
> --b.


-- 
Jeff Layton <jlayton@primarydata.com>
