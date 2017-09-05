Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38332 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752723AbdIET4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Sep 2017 15:56:21 -0400
Date: Tue, 5 Sep 2017 15:56:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20170905195619.GB17828@parsley.fieldses.org>
References: <1503697958-6122-3-git-send-email-bfields@redhat.com>
 <878ti4i9pi.fsf@notabene.neil.brown.name>
 <20170829214026.GI8822@parsley.fieldses.org>
 <8760d5hol3.fsf@notabene.neil.brown.name>
 <20170830170938.GC24373@parsley.fieldses.org>
 <87wp5kfxi3.fsf@notabene.neil.brown.name>
 <20170831190531.GA8223@parsley.fieldses.org>
 <873787fhc5.fsf@notabene.neil.brown.name>
 <20170901161809.GA22140@parsley.fieldses.org>
 <871snndq04.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <871snndq04.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 04, 2017 at 02:52:43PM +1000, NeilBrown wrote:
> On Fri, Sep 01 2017, J. Bruce Fields wrote:
> 
> >> 
> >> nfsd would need to find that delegation, prevent further delegations
> >> being handed out, and check that there aren't already conflicting
> >> delegations.  If there are conflicts, recall them.  Once there are no
> >> conflicting delegations, make the vfs_ request.
> >
> > The way that we currently serialize setting, unsetting, and breaking
> > delegations is by locks on the delegated inodes which aren't taken till
> > deeper in the vfs code.
> 
> Do we?
> I can see nfs4_set_delegation adding a new delegation for a new client
> without entering the vfs at all if there is already a lease held.

By "delegations", I meant locks of type FL_DELEG.  But even then I was
wrong, apologies.

There is an inode_trylock in generic_add_lease that will prevent any new
delegations from being given while the inode's locked.

> If there isn't a lease already, vfs_setlease() is called, which doesn't
> its own internal locking of course.  Much the same applies to unsetting
> delegations.
> Breaking delegations involves nfsd_break_deleg_cb() which has a comment
> that it is called with i_lock held.... that seems to be used to
> be sure that it is safe to a reference to the delegation state id.
> Is that the only dependency on the vfs locking, or did I miss something?
> 
> >
> > I guess you're suggesting adding a second mechanism to prevent
> > delegations being given out on the inode.  We could add an atomic
> > counter taken by each nfsd breaker while it's in progress.  Hrm.
> 
> Something like that.
> We would also need to be able to look up an nfs4_file by inode (why
> *are* they hashed by file handle??)

Grepping the logs....  That was ca9432178378 "nfsd: Use the filehandle
to look up the struct nfs4_file instead of inode" which doesn't give a
full justification.  Later commits suggest it might be about keeping
nfsv4 state in many-to-one filehandle->inode cases (spec requirement, I
believe) and preventing the nfs4_file from pinning the inode (not seeing
immediately why that was an issue).

Anyway, I can't think of a reason why hashing the filehandle's a
problem.

> and add some wait queue somewhere
> so the breaker could wait for a delegation to be returned.

In the nfsd case we're just returning to the client immediately, so
that's not really necessary, though maybe it could be useful.

> My big-picture point is that any complexity created by NFSD's choice to
> merge delegations to multiple clients into a single vfs-level delegation
> should be handled by NFSD, and not imposed on the VFS.
> It certainly makes sense for the VFS to understand that certain
> operations are being performed by an fl_owner_t, and to allow
> delegations to that owner to remain.  It doesn't make as much sense for
> the VFS to understand that there is a finer granularity of ownership
> than the one that it already supports.

Fair enough, I'll think about that.

--b.
