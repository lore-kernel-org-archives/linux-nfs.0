Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33523 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753894Ab1HUXIE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Aug 2011 19:08:04 -0400
Date: Mon, 22 Aug 2011 09:07:51 +1000
From: NeilBrown <neilb@suse.de>
To: Jamie Lokier <jamie@shareable.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        Sylvain Rochet <gradator@gradator.net>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110822090751.029de688@notabene.brown>
In-Reply-To: <20110821202058.GF14899@jl-vm1.vm.bytemark.co.uk>
References: <20101018223540.GA20730@gradator.net>
	<20110819230344.GA24784@gradator.net>
	<20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
	<20110820012943.GD2203@ZenIV.linux.org.uk>
	<20110820030335.GA14899@jl-vm1.vm.bytemark.co.uk>
	<20110821170714.GB9296@fieldses.org>
	<20110821202058.GF14899@jl-vm1.vm.bytemark.co.uk>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 21 Aug 2011 21:20:58 +0100 Jamie Lokier <jamie@shareable.org> wrote:

> J. Bruce Fields wrote:
> > On Sat, Aug 20, 2011 at 04:03:35AM +0100, Jamie Lokier wrote:
> > > Well you still have your sense of humour...
> > > 
> > > I've never understood why you think it's about the file manager /
> > > desktop, or why you so strongly dislike the feature.  It originated
> > > there historically, but that is not it's primary use.
> > > 
> > > The implementation, sure, but you seem to dislike the very *principle*
> > > of subscribing to changes.
> > > 
> > > Every interesting use of inotify that I've seen is for some kind of
> > > cache support, to eliminate the majority of stat() calls, to remove
> > > disk I/O (no stat means no inode), to ensure correctness (st_mtime is
> > > coarse and unreliable),
> > 
> > It seems rather fragile as an mtime replacement unless it's also got
> > some sort of logging built in at a pretty low level so that you don't
> > lose events while you're not listening.
> 
> It mainly serves as an accelerator for existing stat/mtime checks,
> though it does improve change detection in the last second or so since
> a previous change, which with mtime you have to make pessimistic or
> sometimes-incorrect assumptions.
> 
> Quite a few programs use inotify now because it saves a little power,
> and is a bit more responsive than, say, polling config files with stat().
> 
> For reliable filesystem tracking across times when not listening,
> especially if you don't trust the clock to have no backward steps (and
> you should not), a lazy change count file attribute would do.  It's
> been discussed but never implemented.
> 
> > And of course events have to be defined very carefully to avoid problems
> > such as this one.
> 
> This thread has revealed quite a big hole, I agree.  Apps cannot even
> use their normal filesystem-type whitelisting to catch this.  This is bad!
> 
> It is not the first hole that was found in inotify/dnotify, but it's
> the first one I'm aware of that wasn't pointed out long ago and
> then quietly ignored :-/
> 
> > > and to avoid having to modify every
> > > application which might affect any file from which cached items are
> > > derived to explicitly notify all the applications which might use any
> > > of those files.
> > > 
> > > You like high performance, reliable and correct behaviour, and high
> > > scalability.  So I have never understood why you dislike the
> > > change-subscription principle so strongly, because it is a natural
> > > ally to those properties.
> > 
> > I don't think we've seen a design that does all of that yet.
> 
> Designs get discussed from time to time, over the decades.
> 
> I think one of the reasons it doesn't go further is Al's well-known
> objection -- why put the effort in if you know it will be rejected.
> And a widespread view that it's just unimportant GUI file manager fluff.
> The latter also means dependability issues have tended not to be taken
> seriously.

I know you weren't asking for design suggestions, but somehow I just couldn't
help myself :-)

The (or "a") problem with {d,i,fa}notify is that it makes a core assumption
that is flawed.  i.e. that a file is in some directory.  It might be nice if
that were a reliable fact but thanks to our founding fathers, it is not.
If a file only ever had one name - never more nor less - and could not have
that name changed while it were open, then quite a lot of things would be a
lot easier.  And probably a lot of things would be a lot harder.  But we don't
live in that world (others do - I think you know where it is).

So we must drop this assumption.

Getting notification on an fd when the opened file changes makes perfect
sense.  Some /proc and /sys files already provide this functionality and we
can expect that more will.  Adding that to regular filesystems may not be out
of the question.  This would be useful, but of limited use.  You could find
out when a given file changed - either an mtime-like change or a ctime-like
change.  By monitoring a directory you could find out when a name was added
or removed.  But to find out when "any file in a directory changes" you would
need to open and monitor every file, which is expensive.

The other ("another") problem is the lack of recursion.  You can find out
when a file in a directory changes, but not a file in a directory tree.  This
significantly reduces the value.   We really want to know about directory
trees.  However a "directory tree" - much like "all the files in a directory"
isn't really a very well defined concept - at least from the perspective of
providing notifications.  You cannot easily answer "is this file in that
tree?" or "which tree(s) is this file in?".

However there are well defined sets of files such that we could reliably
generate notifications if any file in the set were changed, or if a file were
added-to or remove-from the set.  We should be looking for these sorts of
sets and seeing which are useful.

e.g.
 - all files in a given filesystem.   Generating notification for any change
   in a given filesystem is a well defined task.  It might generate too much
   noise, but it would still have a place.

 - all files with a given uid (or gid).

 - all directories.  or all regular files

 - all setuid, setgid, or world-writable files

Each of these are strongly defined and we can map from file to set quite
easily.  We could obviously intersect the sets to, so I could get events when
any directory owned by me on a particular filesystem was changed.  It would
even be reasonable for the events to contain a newly opened fd from which I
can extract dev/inode info and possibly extract a path name.

However this still might not be fine-grained enough.  While a "directory
tree" is not really a well defined concept, it is in my mind.  e.g. it
seems reasonable to want to find out about all changes in $HOME/.config

I can see two approaches to this - though there might be others.  All of
them must in some way create a strong concept of a directory tree.

One is to use bind mounts. i.e. I effectively do
    mount --bind $HOME/.config $HOME/.config
and ask for events from the newly created vfsmnt.
This will not catch changes made through file descriptors that were opened
before I did the mount, or through hard links from some other directory
tree.  But for a particular use-case that might not be a problem.

The other requires support from the filesystem and so cannot be provided
universally.  It could possibly be imposed generically for filesystems that
support extended attributes .... but I feel dirty even suggesting that (Dobby
must now go and iron his hands!)

The filesystem could support the concept of a 'directory tree' much like
BTRFS allows subvolumes which a like independent filesystems within the one
big filesystem.  However for this purpose the 'directory tree' would be a
very light weight concept (it wouldn't need its own inode number space).

For example, each inode could store an extra number which is the inode number
of the root of its directory tree.  This would be inherited from parent
during create. Renaming or linking a file would fail if the target had a
different directory tree number.  (renaming a file with only one link might
succeed and change the directory tree number).   An empty directory could be
told to become a root somehow.

Then you would have a strong concept of a directory tree that could be used
for notifications.
Obviously this approach could not be used to solve any immediate problems.
But if new filesystems started supporting light-weight-directory-trees as a
well defined set of files, then in 5-10 years we might have a nice working
solution.


[of course then you need to layer any design you come up with on NFS ... but
that can probably be done in user-space with libraries and daemons].

NeilBrown
