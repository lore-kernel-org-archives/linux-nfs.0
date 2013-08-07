Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:59971 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab3HGPo0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Aug 2013 11:44:26 -0400
Received: by mail-qc0-f171.google.com with SMTP id n10so132035qcw.16
        for <linux-nfs@vger.kernel.org>; Wed, 07 Aug 2013 08:44:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52015739.4050702@redhat.com>
References: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
	<1375799403-28544-5-git-send-email-miklos@szeredi.hu>
	<52015739.4050702@redhat.com>
Date: Wed, 7 Aug 2013 17:44:25 +0200
Message-ID: <CAJfpegsD8cgnW59crKABjTE1E5aNpmyO=91ubtNxxp=LnwjgDg@mail.gmail.com>
Subject: Re: [PATCH 4/4] fuse: drop dentry on failed revalidate
From: Miklos Szeredi <miklos@szeredi.hu>
To: Anand Avati <avati@redhat.com>
Cc: Ric Wheeler <rwheeler@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        Brian Foster <bfoster@redhat.com>, David Howells <dhowells@redhat.com>,
        Eric Paris <eparis@redhat.com>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "mszeredi@suse.cz" <mszeredi@suse.cz>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 6, 2013 at 10:06 PM, Anand Avati <avati@redhat.com> wrote:
> On 8/6/13 7:30 AM, Miklos Szeredi wrote:
>>
>> From: Anand Avati <avati@redhat.com>
>>
>> Drop a subtree when we find that it has moved or been delated.  This can
>> be
>> done as long as there are no submounts under this location.
>>
>> If the directory was moved and we come across the same directory in a
>> future lookup it will be reconnected by d_materialise_unique().
>>
>> Signed-off-by: Anand Avati <avati@redhat.com>
>> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
>> ---
>>   fs/fuse/dir.c | 7 ++++++-
>>   1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
>> index 131d14b..4ba5893 100644
>> --- a/fs/fuse/dir.c
>> +++ b/fs/fuse/dir.c
>> @@ -226,8 +226,13 @@ static int fuse_dentry_revalidate(struct dentry
>> *entry, unsigned int flags)
>>                 if (!err) {
>>                         struct fuse_inode *fi = get_fuse_inode(inode);
>>                         if (outarg.nodeid != get_node_id(inode)) {
>> +                               int ret = 0;
>> +
>> +                               if (check_submounts_and_drop(entry) != 0)
>> +                                       ret = 1;
>> +
>>                                 fuse_queue_forget(fc, forget,
>> outarg.nodeid, 1);
>> -                               return 0;
>> +                               return ret;
>
>
> If outarg.nodeid != get_node_id(inode), then we have to return 0 no matter
> what (whether we successfully dropped the entry or not), no?

If we return 0 in that case (we failed to invalidate the dentry), then
the VFS will call d_invalidate() which will fail.  The result is the
same...

> Or are you
> trying to forcefully keep the path to reach the submount alive? If so, we
> still fail in inode_permission() .. -> getattr() of the dir inode, no?

Yes.  But the path to the mountpoint should still be reachable (for
the purpose of unmounting for example).  I'm including an interesting
discussion between Al and Linus about this (mailing lists weren't
CC-d, but I don't think they'd mind).

BTW, the isue that non-directory mountpoints  are dropped by NFS and
friends is not addressed by my previous patchset.  Updated patches
coming up.

Thanks,
Miklos


Subject: [heads-up] breakage with revalidate on NFS and elsewhere

-------------------------------------------------------------------------------
From: Al Viro <viro@ZenIV.linux.org.uk>

    1) In NFS ->d_revalidate() we blindly evict non-directories from
dcache.  So does d_invalidate().  Which will leave anything bound on
the file in question unreachable.  It's not a complete leak (e.g. umount -l
or death of namespace will still evict those), but it's certainly a bug
and one with potential for rather unhappy admin.

Note that there's no reason whatsoever to do that d_drop() in case of
non-directories; the only possible caller (do_revalidate(); the other
call site is for directories only) will call d_invalidate(), which will
drop them itself.

d_invalidate() is more interesting; the minimal fix is to have it check
d_mounted and if it's non-zero - grab namespace_sem, find all vfsmounts
with this ->mnt_root, umount_tree() for all of those, drop namespace_sem,
then release all collected vfsmounts.  What's more, we probably want to
extend that to directories; the same thing could be done for all children
with non-zero d_mounted, killing the "has submounts" logics in NFS revalidate.

It's not even hard to implement - all we need is a secondary hash chains
going through vfsmounts, keyed by ->mnt_mountpoint alone.  That would be
enough (alternative would be to put them on a cyclic list anchored in dentry,
but that'd lead to much worse memory waste since for almost all dentries
the list would be empty).

_However_, there's a secondary issue with d_invalidate() callers.  What
happens to the "case-insensitive" crap?  Suppose we have something mounted
on /mnt/foo/bar, with /mnt/foo/bar being on VFAT.  Somebody wants to open
/mnt/foo/BaR; what should that do to mountpoint?

Current behaviour is
    a) if it's a directory, have lookup return /mnt/foo/bar, case be
damned.
    b) if it's a non-directory, leak the vfsmount(s), return dentry
with new name.

IMO we should _NOT_ make any vfsmounts unreachable in that case; too obvious
abuse potential.  The only question is whether to have invalidation simply
fail (i.e. case (a) for everything) or to try and flip ->mnt_mountpoint in
them to the "replacement" dentry.  I think that the former is the right
answer.  In any case, this means splitting d_invalidate() in two variants
(unmounting and non-unmounting).

We also need to review other __d_drop()/d_drop() users - potentially they
might need the same kind of treatment ;-/

    2) NFS4 ->d_revalidate() is too bloody eager to bypass everything
bypassable; as the result, if you have a something bound on top of file
and attempt to open it, the damn thing will blindly try to open _underlying_
file.  You either get that file opened (and nameidata_to_filp() will return it,
nevermind where had that binding lead pathname resolution) or fail (e.g. if
it's not readable for you) and get open() failure.

That one is nasty.  We certainly can notice that there's a vfsmount
on top of the sucker - this happens only on the last step of pathname
resolution in do_filp_open().  However, what would we do once we find it?
We can't just skip ->d_revalidate().  I suspect that the cheapest way is
to indicate in nd->flags that it shouldn't attempt atomic open (e.g. by
removing LOOKUP_OPEN for the duration) and leave the rest alone.  Longer
term solution, of course, is to split "atomic open" path away into a
separate method, with fallback to ->d_revalidate/->lookup/->create/->open
combination if it's not there *OR* if we have something bound on top of
the sucker (and just want to see if it's stale and binding should be
kicked out).  In either case, we really have to split the last step of
lookup away from path_lookup_open(); O_CREAT path is already split
that way.

    3) while we are at it (== sorting out the intents patch pile),
there's fun with passing flags through nameidata; on MIPS O_SYNC == FMODE_EXEC,
with everything that implies.  Namely, open() a file on nfs4 with O_SYNC,
get it fail with -EACCES if it's not executable.  Moral: don't mix f_flags
with f_mode.  FWIW, as an intermediate step I'm
    a) adding LOOKUP_EXCL in addition to LOOKUP_CREATE/LOOKUP_OPEN, with
callers that set O_EXCL in ->intent.flags setting it in ->flags.
    b) setting ->f_mode and ->f_flags of intent.file from the very
beginning and switching the checks in filesystems to _that_; longer term
we'll simply pass that struct file * directly to methods.  This particular
check (in nfs4_intent_set_file()) goes to ->f_mode, of course...

    4) more in the same pile: open_exec() ignores leases.  Solution:
switch the damn thing to do_filp_open(); makes life interesting wrt the
arguments that need to be passed to the latter, but that's survivable.
That's probably a less immediate mess, though...

    5) v9fs_vfs_create() ignores implicit O_EXCL when called from
mknod(2) (i.e. without LOOKUP_OPEN).  IMO that's a clear bug, fortunately
easy to fix.

Comments?

PS: ->d_revalidate()/d_invalidate() stuff is probably the oldest surviving
serious mess in VFS, with fs/locks.c being a distant second; I'd never
quite got the courage to sort it out until now and AFAICS neither did
Bill Hawes before my time.  So it had festered for more than a decade...

-------------------------------------------------------------------------------
From: Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 5 Aug 2008, Al Viro wrote:
>
>     1) In NFS ->d_revalidate() we blindly evict non-directories from
> dcache.  So does d_invalidate().  Which will leave anything bound on
> the file in question unreachable.

Hmm. If something is bound on top of it, how would we ever even _reach_
->d_revalidate()? We never revalidate mount-points, afaicr ("can
remember", I'm too dang lazy to look it up).

So in _practice_, this can only happen with private mounts and namespaces
(ie we don't happen to have it bound in one namespace, so we revalidate,
and thus screw up the other namespace), right?

> d_invalidate() is more interesting; the minimal fix is to have it check
> d_mounted and if it's non-zero - grab namespace_sem, find all vfsmounts
> with this ->mnt_root, umount_tree() for all of those, drop namespace_sem,
> then release all collected vfsmounts.  What's more, we probably want to
> extend that to directories; the same thing could be done for all children
> with non-zero d_mounted, killing the "has submounts" logics in NFS revalidate.

Wouldn't it be better to do it the other way around instead, and extend
the "don't even bother to revalidate" to anything that is mounted on in
any namespace?

In particular, "d_invalidate()" is *not* designed to be "this dentry is
bad, we have to throw it away". No, it's designed for "this dentry _may_
be stale, throw it away adn try to look it up again".

And that means that doing a unmount_tree() on them is WRONG. Because
you're throwing out mount-points not on knowledge that they have to be
thrown out, but on just the suspicion that maybe we should update some
cached data.

            Linus


-------------------------------------------------------------------------------
From: Al Viro <viro@ZenIV.linux.org.uk>

On Tue, Aug 05, 2008 at 10:31:06AM -0700, Linus Torvalds wrote:
>
>
> On Tue, 5 Aug 2008, Al Viro wrote:
> >
> >     1) In NFS ->d_revalidate() we blindly evict non-directories from
> > dcache.  So does d_invalidate().  Which will leave anything bound on
> > the file in question unreachable.
>
> Hmm. If something is bound on top of it, how would we ever even _reach_
> ->d_revalidate()? We never revalidate mount-points, afaicr ("can
> remember", I'm too dang lazy to look it up).
>
> So in _practice_, this can only happen with private mounts and namespaces
> (ie we don't happen to have it bound in one namespace, so we revalidate,
> and thus screw up the other namespace), right?

No.  We do lookup (d_lookup + revalidate + ->lookup, possibly) and only
then try to cross the mountpoint.

> Wouldn't it be better to do it the other way around instead, and extend
> the "don't even bother to revalidate" to anything that is mounted on in
> any namespace?
>
> In particular, "d_invalidate()" is *not* designed to be "this dentry is
> bad, we have to throw it away". No, it's designed for "this dentry _may_
> be stale, throw it away adn try to look it up again".
>
> And that means that doing a unmount_tree() on them is WRONG. Because
> you're throwing out mount-points not on knowledge that they have to be
> thrown out, but on just the suspicion that maybe we should update some
> cached data.

That sure as hell doesn't match what ->d_revalidate() instances are doing...
It's not "I suspect it might be bogus"; it's pretty hard "I checked if
it's still OK and it's buggered, dead and buried, not necessary in that
order".


-------------------------------------------------------------------------------
From: Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 5 Aug 2008, Al Viro wrote:
> >
> > So in _practice_, this can only happen with private mounts and namespaces
> > (ie we don't happen to have it bound in one namespace, so we revalidate,
> > and thus screw up the other namespace), right?
>
> No.  We do lookup (d_lookup + revalidate + ->lookup, possibly) and only
> then try to cross the mountpoint.

Ouch. So mounts are already broken on NFS, but nobody probably noticed
because it only triggers for regular files (ie single-file bind mounts) by
default.

> That sure as hell doesn't match what ->d_revalidate() instances are doing...
> It's not "I suspect it might be bogus"; it's pretty hard "I checked if
> it's still OK and it's buggered, dead and buried, not necessary in that
> order".

I agree that the ones that do "d_drop" are clearly broken, and they should
just return the right error value and depend on the caller to DTRT. I was
just arguing against your suggested fix. Yes, we should check whether it's
a mount-point, and just effectively ignore the d_revalidate() if so.

(And yes, we should only do this _after_ d_revalidate() has returned
"don't use it", so 99% of your suggested fix is correct - I just don't
think that the "unmount it" is the correct action, we should just ignore
the d_revalidate failure)

            Linus


-------------------------------------------------------------------------------
From: Al Viro <viro@ZenIV.linux.org.uk>

On Tue, Aug 05, 2008 at 11:32:37AM -0700, Linus Torvalds wrote:

> > That sure as hell doesn't match what ->d_revalidate() instances are doing...
> > It's not "I suspect it might be bogus"; it's pretty hard "I checked if
> > it's still OK and it's buggered, dead and buried, not necessary in that
> > order".
>
> I agree that the ones that do "d_drop" are clearly broken, and they should
> just return the right error value and depend on the caller to DTRT. I was
> just arguing against your suggested fix. Yes, we should check whether it's
> a mount-point, and just effectively ignore the d_revalidate() if so.
>
> (And yes, we should only do this _after_ d_revalidate() has returned
> "don't use it", so 99% of your suggested fix is correct - I just don't
> think that the "unmount it" is the correct action, we should just ignore
> the d_revalidate failure)

Either I'm misunderstanding you, or NFS folks will be very unhappy with
that.  Think of the following scenario: something is mounted over NFS
in two places (/mnt/something and /jail/something_else).  We have /dev/null
bound on top of /jail/something_else/sensitive.  That file is removed on
server; we attempt to open /mnt/something/sensitive and instead of expected
-ENOENT we get 100% persistent -ESTALE, simply because there's nothing
to open.  Worse, after the file had been recreated on server we _still_ get
the same error.  Indefinitely.

And yes, we have the same issue for directories.  If server's /home/foo
is mounted on /mnt/foo, some other fs is mounted on /mnt/foo/bar/baz and
server does rm -rf /home/foo/bar, we are stuck with /mnt/foo/bar giving
us -ESTALE.  Moreover, if server does mkdir /home/foo/bar and we do
ls /mnt/foo, we'll see bar.  But attempt to stat it will keep giving us
-ESTALE.  _MOREOVER_, umount(8) on /mnt/foo/bar/baz will be screwed
*anyway*, without bindings, namespaces or anything of that kind.  And
the only way out of that will be umount -l /mnt/foo or direct call of
umount(2), with no stat() or anything of that kind; nothing short of
that will make /mnt/foo go away and nothing short of that will make whatever
we had mounted on /mnt/foo/bar/baz not busy.


-------------------------------------------------------------------------------
From: Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 5 Aug 2008, Al Viro wrote:
>
> Either I'm misunderstanding you, or NFS folks will be very unhappy with
> that.  Think of the following scenario: something is mounted over NFS
> in two places (/mnt/something and /jail/something_else).  We have /dev/null
> bound on top of /jail/something_else/sensitive.  That file is removed on
> server; we attempt to open /mnt/something/sensitive and instead of expected
> -ENOENT we get 100% persistent -ESTALE, simply because there's nothing
> to open.  Worse, after the file had been recreated on server we _still_ get
> the same error.  Indefinitely.

Umm. If somebody uses it as a mount-point, that's still better than
dropping the mount.

Deal with it. If people think it's problematic, then they shouldn't have
mounted something on top of it.

We cannot just auto-unmount. That's _worse_ than the ESTALE issue.

            Linus


-------------------------------------------------------------------------------
From: Al Viro <viro@ZenIV.linux.org.uk>

On Tue, Aug 05, 2008 at 12:07:07PM -0700, Linus Torvalds wrote:
>
>
> On Tue, 5 Aug 2008, Al Viro wrote:
> >
> > Either I'm misunderstanding you, or NFS folks will be very unhappy with
> > that.  Think of the following scenario: something is mounted over NFS
> > in two places (/mnt/something and /jail/something_else).  We have /dev/null
> > bound on top of /jail/something_else/sensitive.  That file is removed on
> > server; we attempt to open /mnt/something/sensitive and instead of expected
> > -ENOENT we get 100% persistent -ESTALE, simply because there's nothing
> > to open.  Worse, after the file had been recreated on server we _still_ get
> > the same error.  Indefinitely.
>
> Umm. If somebody uses it as a mount-point, that's still better than
> dropping the mount.
>
> Deal with it. If people think it's problematic, then they shouldn't have
> mounted something on top of it.
>
> We cannot just auto-unmount. That's _worse_ than the ESTALE issue.

Why?  If anything, I can buy something along the lines of "postpone killing
until lookup from vfsmount that doesn't have anything mounted on it, then
do normal ->lookup() and relocate whatever had been mounted on it to new
dentry, killing the old one".  That would give obviously good behaviour
(stuff is visible where bound and remains visible all along, lookup in
any other instance gives expected behaviour and as soon as that happens we
get the situation completely resolved).

However, it still leaves us lousy behaviour for case without any bindings.
What do you expect to happen in such case, anyway?  A chain of zombie
directories leading to mountpoint?  With any operation on those except
the lookup by exact path resulting in -ESTALE?  Including ls on any of
those suckers, BTW.

So why is auto-unmount bad in case when directories in question are
really, honestly dead and gone?

FWIW, what _is_ the semantics you expect from ->d_revalidate()?  Perhaps
we'd be better off if we simply get rid of cases when ->d_revalidate()
returns 0 just in case; I see only VFAT playing such games on positive
dentries.

Note that _negative_ ones are different; we often return "redo lookup just
in case", but that's fine - nothing is mounted in them or under them.


-------------------------------------------------------------------------------
From: Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 5 Aug 2008, Al Viro wrote:
> On Tue, Aug 05, 2008 at 12:07:07PM -0700, Linus Torvalds wrote:
> >
> > We cannot just auto-unmount. That's _worse_ than the ESTALE issue.
>
> Why?

.. because the kernel shouldn't undo the kinds of decisions that the user
has explicitly asked it to do.

If they user mounted something, the kernel should not just unmount it
willy nilly. That's *FUNDAMENTALLY WRONG*. It's so wrong that I don't
even understand how you can _possibly_ ask "why?". It's obviously wrong.

For example, you did a totally made-up example of something that nobody
would actually ever do, and used it as an example of why we'd have to work
the way you suggest. I will counter-act with

 - first off, even in your unrealistic example, if somebody mounted it,
   you can't just remove it - let the other place get ESTALE, and let the
   _user_ unmount it if required, but it's very possible that the thing
   was mounted on top of a file because of security issues, for example.

   Let's say that you have some http server, and the file that got
   over-mounted was /etc/{password/shadow} for the servers namespace.
   Let's say that the ESTALE happened because somebody changed the
   passwords on the server (which does a "rename" on top of the old
   files). Does that mean that suddenly the client that had been set up to
   explicitly hide those files should suddenly see the real contents?

   You're much better off getting a failure on all points than to expose
   one of them!

See? I can top your unrealistic example with another one - and it all
boils down to the fact that you should _never_ _ever_ override user choice
in the kernel (and that 'mount' was very much a user choice).

But the more _realistic_ case is simply the case where the thing was just
mounted in one place to begin with, and the ESTALE never happens at all!
So the other case is:

 - mount in just one place. That one place gets ESTALE, but who the f*ck
   cares, because nobody will see the native file underneath _anyway_,
   because it's overmounted by something else!

In this case, your "solution" breaks the overmount, with no actual
advantages. There are no ESTALE returns to even protect against. The
ESTALE is immaterial - what is (once more) material is that the user
mounted a file on top of another one, and we want to see the _mounted_
contents.

> So why is auto-unmount bad in case when directories in question are
> really, honestly dead and gone?

.. because they aren't gone locally. We can happily continue to look
through them because they _mounted_ stuff still works. The fact that the
mount-point is gone doesn't change the fact that we have a local mount.

        Linus


-------------------------------------------------------------------------------
From: Al Viro <viro@ZenIV.linux.org.uk>

On Tue, Aug 05, 2008 at 12:38:35PM -0700, Linus Torvalds wrote:

> > So why is auto-unmount bad in case when directories in question are
> > really, honestly dead and gone?
>
> .. because they aren't gone locally. We can happily continue to look
> through them because they _mounted_ stuff still works. The fact that the
> mount-point is gone doesn't change the fact that we have a local mount.

Um.  Again, just one directory can be taken care of; I agree with that.
But what do you do when _ancestors_ are gone?

The mountpoint is covered; we don't care about its contents.  Fine.  What
about 5 levels of directories leading to it, all crapped out?  We can
walk through them, but we can't do anything _else_ - not stat(2), not
readdir(2), nothing.  Again, in this case you have no bindings, etc. -
just something mounted on directory deep in NFS tree, with all the
branch leading to mountpoint being dead and gone on server.

What kind of state do you want to get after that?


-------------------------------------------------------------------------------
From: Al Viro <viro@ZenIV.linux.org.uk>

    BTW, there's another fun side to it.  What do you do when the
kernel itself removes the mountpoint?

    I'm not even talking about the fun with somebody creating mounts
under /proc/<pid>; results seem to be amusing, to put it mildly.  But under
/sys it's not that unthinkable and it leads to the same kind of mess -
forced d_drop(), this time regardless of whether it's a directory or not.
And then there are callers of d_delete() similar to those (configfs, etc.).

    What do you suggest for those?


-------------------------------------------------------------------------------
From: Al Viro <viro@ZenIV.linux.org.uk>

On Wed, Aug 06, 2008 at 02:16:55AM +0100, Al Viro wrote:
>     BTW, there's another fun side to it.  What do you do when the
> kernel itself removes the mountpoint?
>
>     I'm not even talking about the fun with somebody creating mounts
> under /proc/<pid>; results seem to be amusing, to put it mildly.  But under
> /sys it's not that unthinkable and it leads to the same kind of mess -
> forced d_drop(), this time regardless of whether it's a directory or not.
> And then there are callers of d_delete() similar to those (configfs, etc.).
>
>     What do you suggest for those?

BTW, after looking at that stuff I'd say that there's a couple of common
helpers asking to be added - for adding and removing objects in such
trees, with callback for setting up an inode in case of addition.  Would
cut down on the amount of weird callers of lookup_one_len(), while we
are at it...

Another thing: nfs4 handling of open_flags is _brittle_.  I've done a bit
of digging today, dumped a couple of found bugs on steved, but more serious
code review will have to wait for a while...  I'd really appreciate a
braindump on locking for states and delegations, BTW.


-------------------------------------------------------------------------------
From: Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 5 Aug 2008, Al Viro wrote:
>
> Um.  Again, just one directory can be taken care of; I agree with that.
> But what do you do when _ancestors_ are gone?

There's one pretty simple approach: we could just add a "pinning count" to
the dentry, and make any mount increment the count for the target and for
all ancestors. Of course, that would complicate reparenting a bit etc, but
it would certainly trivially make sure that the mount structure is always
around.

That said, no, I'm not convinced it's at all worth it, especially if the
end result ends up being that yes, you can walk that particular path, but
not do anything else with it. On the other hand, maybe that end result
isn't so horrible. After all, what _is_ the meaning of a mounted thing
when the directory structure has been changed without the kernel knowing
what happened?

                Linus
