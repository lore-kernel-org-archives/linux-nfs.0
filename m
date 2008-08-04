From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Mon, 4 Aug 2008 02:19:12 -0400
Message-ID: <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com>
References: <18578.21997.529551.676627@notabene.brown>
	 <1217597759.3454.356.camel@pmac.infradead.org>
	 <1217598976.3454.359.camel@pmac.infradead.org>
	 <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
	 <1217607571.3454.417.camel@pmac.infradead.org>
	 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	 <20080802182644.GE30454@fieldses.org>
	 <18581.40178.976747.769343@notabene.brown>
	 <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com>
	 <18582.21855.2092.903688@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"David Woodhouse" <dwmw2@infradead.org>, viro@zeniv.linux.org.uk,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:9407 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbYHDGTP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2008 02:19:15 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1738898fkq.5
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2008 23:19:13 -0700 (PDT)
In-Reply-To: <18582.21855.2092.903688-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 3, 2008 at 9:03 PM, Neil Brown <neilb@suse.de> wrote:
> On Sunday August 3, chuck.lever@oracle.com wrote:
>> On Sun, Aug 3, 2008 at 7:56 AM, Neil Brown <neilb@suse.de> wrote:
>> > On Saturday August 2, bfields@fieldses.org wrote:
>> >>
>> >> Though really I can't see any great objection to just moving xfs's hack
>> >> up into nfsd.  It may not do everything, but it seems like an
>> >> incremental improvement.
>> >
>> > Because it is a hack, and hacks have a tendency to hide deeper
>> > problems, and not be ever get cleaned up and generally to become a
>> > burden to future generations.
>>
>> Agreed that maintainability is an important concern.
>>
>> However, I don't see that what David suggests in general is hiding a
>> deeper problem, but is rather exposing it.  Can you explain what you
>> think is the issue?
>
> The locking bothers me.
> The VFS seems to have a general policy of doing the locking itself to
> make life easier for filesystem implementors (or to make it harder for
> them to mess up, depending on your perspective).
>
> The current issue seems to suggest that the locking provided by the
> VFS is no longer adequate, so each filesystem is needing to create
> something itself.  That suggests to me a weakness in the model.

I often find the VFS locking schemes to be inflexible.

However, in this case, I think that the VFS locking is adequate; NFSD
is doing something that the VFS (and hence the individual file systems
themselves) wasn't designed for.  Adding extra export APIs (like
lookup_locked or lookup_fh) seems like an appropriate way to address
the problem.

> Possibly the VFS should give up trying to be in control and let
> filesystems do their own locking.  Possibly there are still things
> that the VFS can do which are universally good.  I think these are
> questions that should be addressed.

I agree it's worth thinking carefully about this.  Thinking out loud
(as you have done) is helpful.

> Maybe they have already been addressed and I missed the conversation
> (that wouldn't surprise me much).  But seeing words like "hack"
> suggests to me that it hasn't.  So I want to make sure I understand
> the problem properly and deeply before giving my blessing to a hack.
>
> So: what are the issues?
>
>  Obviously readdir can race with create and you don't want them
>  tripping each other up.  The current VFS approach to this is i_mutex.
>  Any place which modifies a directory or does a lookup in a directory
>  takes i_mutex to ensure that the directory doesn't change.
>
>  This is probably fairly limiting.  With a tree-structured directory
>  you only really need to lock the 'current node' of the tree.
>  So any access would lock the top node, find which child to follow,
>  then lock the child and unlock the parent.  Rebalancing might need to
>  be creative as you cannot lock a parent while holding a lock on the
>  child, but that isn't insurmountable.
>  So I could argue that holding i_mutex across a lookup or create or
>  readdir maybe isn't ideal.  It would be interesting to explore the
>  possibility of dropping i_mutex across calls into the filesystem.
>  By the time the filesystem is called, we really only need to be
>  locking the names (dentries) rather than the whole directory.
>  More on this later...
>
>  Some filesystems want to restructure directories and times that are
>  independent of any particular access.  This might be defragmentation
>  or rebalancing or whatever.  Clearly there needs to be mutual
>  exclusion between this and other accesses such as readdir and lookup.
>  The VFS clearly cannot help with this.  It doesn't know when
>  rebalancing might happen or are what sort of granularity.  So the
>  filesystem must do it's own locking.
>  It strikes me that this sort of locking would best be done by
>  spinlocks at the block level rather than a per-inode mutex.  However
>  I haven't actually implemented this (yet) so I cannot be certain.
>
>  This is what is causing the current problem (for JFFS2 at least).
>  JFF2 has a per-inode lock which protects against internally visible
>  changes to the inode.  Further (and this is key) this lock is held
>  across the filldir callback.
>  i_mutex is also held across the filldir callback, but there is an
>  important difference.  It is taken by the VFS, not the filesystem,
>  and it is guaranteed always to be held across the filldir callback.
>  So the filldir callback can call e.g. lookup without further locking.
>
>  Backing up a little:  given that the filesystem implementor chose to
>  use per-inode locking to protect internal restructuring (which is
>  certainly an easier option), why not just use i_mutex?  The reason
>  is that a create operation might trigger system-wide garbage
>  collection which could trigger restructuring of the current inode,
>  which would lead to an A-A deadlock (as the create is waiting for the
>  garbage collection, and so still holding i_mutex).
>
> So, given that background, it is possible to see some more possible
> solutions (other than the ones already mentioned).
>
>  - drop the internal lock across filldir.
>   It could be seen a impolite to hold any locks across a callback
>   that are not documented as being held.
>   This would put an extra burden on the filesystem, but it shouldn't
>   be a particularly big burden.
>   A filesystem needs to be able to find the 'next' entry from a
>   sequential 'seek' pointer so that is the most state that needs to
>   be preserved.  It might be convenient to be able to keep more state
>   (pointers into data structures etc).  All this can be achieved with
>   fairly standard practice:
>     a/ have a 'version' number per inode which is updated when any
>        internal restructure happens.
>     b/ when calling filldir, record the version number, drop the lock
>        call filldir, reclaim the lock, check the version number
>     c/ if the version number matches (as it mostly will) just keep
>        going.  If it doesn't jump back to the top of readdir where
>        we decode the current seek address.
>
>   Some filesystems have problems implementing seekdir/telldir so they
>   might not be totally happy here.  I have little sympathy for such
>   filesystems and feel the burden should be on them to make it work.

If I understand your suggestion correctly, I can see cases where it
would be nearly impossible for NFSD to make forward progress
assembling a full readdir result to post to a client.  This seems like
the same problem as retrying a pathname resolution until we no longer
get an ESTALE.  If an application makes continuous changes to a
directory (such as, say, a very busy MTA) it would be impossible for
NFSD to finish a READDIR.

As a sidebar, I do agree that locking out other accessors when
handling a very large directory can be a real problem.  I've seen this
on the client side with certain workloads.  The usual answer in this
case is to ask the application developer to use a hierarchical
directory structure.  :-/

But we are still stuck with seekdir/telldir.

>  - use i_mutex to protect internal changes too, and drop i_mutex while
>   doing internal restructuring.   This would need some VFS changes so
>   that dropping i_mutex would be safe.  It would require some way to
>   lock an individual dentry.  Probably you would lock it under
>   i_mutex by setting a flag bit, wait for the flag on some inode-wide
>   waitqueue, and drop the lock by clearing the flag and waking the
>   waitqueue. And you are never allowed to look at ->d_inode if the
>   lock flag is set.
>
> Of these I really like the second.  Refining the i_mutex down to a
> per-name lock before calling in to the filesystem seems like a really
> good idea and should be good for scalability and large directories.
> It isn't something to be done lightly though.  The filesystem would
> still be given i_mutex held, but would be allowed to drop it if it
> wanted to.  We could have an FS_DROPS_I_MUTEX similar to the current
> FS_RENAME_DOES_D_MOVE.
>
> For the first, I really like the idea that a lock should not be held
> across calls the filldir.  I feel that a filesystem doing that is
> "wrong" in much the same way that some think that recursing into the
> filesystem as nfsd does is "wrong".  In reality neither is "wrong", we
> just need to work together and negotiate and work out the best way to
> meet all of our needs.
>
> So what should we do now?  I think that for JFFS2 to drop and reclaim
> f->sem in readdir would be all of 20 lines of code, including updating
> a ->version counter elsewhere in the code.  Replicating that in all
> the filesystems that need it would probably be more code than the nfsd
> change though.

That doesn't fix XFS or the clustered file systems, and I'm still
concerned about starving other accessors (see above).

> On the other hand, if we implement the nfsd change, it will almost
> certainly never go away, even if all filesystems eventually find that
> they don't need it any more because someone improves the locking
> rules in the VFS.

I understand this sentiment completely, but I'm not as pessimistic about this.

> Where as the code in the filesystems could quite
> possibly go away when they are revised to make better use of the
> locking regime.  So I don't think that is an ideal situation either.

Making such changes to the VFS could take a long time.  I know that
distributions are already getting phone calls (twitters?) about this
problem.

> If I had time, I would work on modifying the VFS to allow filesystems
> to drop i_mutex.  However I don't have time at the moment, so I'll
> leave the decision to be made by someone else  (Hi Bruce!  I'll
> support whatever you decide).
>
> But I think it is important to understand what is really going on and
> not just implement a hack that works around the problem.  I think I do
> understand now, so I am a lot happier.  Hopefully you do too.

Yes, thanks.  I will need to re-read your explanation a few more times
to digest it further.

So, the JFFS2 locking problem is a garbage-collection issue.  I'm not
sure this is the case with other file systems like XFS and OCFS2.  My
impression was that XFS had a transaction logging deadlock, and that
OCFS2 (and possibly GFS2) would have issues with cross-node locking in
these cases (yes, it's 2am here and I should be in bed instead of
answering e-mail).  Similar that these are all internal restructuring
issues, but potentially different enough that each will need some
careful analysis -- cross-node locking has failure modes that may be a
challenge to deal with.  Not to mention the other NFSv4 issues David
dug up that have nothing to do with readdir.

--
Chuck Lever
