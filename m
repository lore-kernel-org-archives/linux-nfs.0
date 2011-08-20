Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:57224 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952Ab1HTDVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 23:21:08 -0400
Date: Sat, 20 Aug 2011 04:21:06 +0100
From: Jamie Lokier <jamie@shareable.org>
To: Sylvain Rochet <gradator@gradator.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110820032106.GB14899@jl-vm1.vm.bytemark.co.uk>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
 <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
 <20110820004734.GA26693@gradator.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110820004734.GA26693@gradator.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sylvain Rochet wrote:
> Hi Jamie,
> 
> 
> On Sat, Aug 20, 2011 at 12:37:56AM +0100, Jamie Lokier wrote:
> > 
> > Oh dear, that's a security hole, if something is using inotify/dnotify
> > to watch and assumes that file contents (on the same machine,
> > i.e. server in this case) do not change if there's no event received.
> > 
> > It also breaks cache applications which make the same assumption.
> > 
> > I do quite like the idea of using it to break past fanotify security
> > restrictions though ;-)
> 
> It also probably means that fanotify misses some events when a filesystem 
> is modified over NFS. If fanotify is used the way it is designed, i.e. 
> with an antiviruse software, this may be an interesting way to skip the 
> antiviruse check.
> 
> Here we go:
> 
> NFS server, run the fanotify example tool:
> 
> ~/fanotify-example# ./fanotify -m /data/
> 
> NFS client, open a fd then do some I/O:
> 
> # exec 1> test
> # ls -la
> # 
> 
> NFS server log:
> 
> /data/test: pid=1235 modify close(writable)
> 
> NFS server, cache clearing:
> 
> # echo 3 > /proc/sys/vm/drop_caches 
> 
> NFS client, more I/O:
> 
> # ls -la
> 
> NFS server log:
> 
> /data: pid=1234 modify close(writable)
> 
> We receive an event... which is obviously wrong. This is even worse than 
> no event at all, we receive an event about the wrong inode, the parent 
> inode of the modified file actually.

That sounds like a proper bug, maybe it can be fixed at least?

> > Is a solution to open inotify watches on every file individually?  If 
> > so that seems quite severe.
> 
> This is what I am going to do, at least temporarily, I only need to 
> watch about a million file (and slowly counting).
> 
> The startup time to watch an entire filesystem using inotify already 
> require a full filesystem walk, watching all files and directories 
> instead of directories only will not change much because most of the 
> time is spent waiting I/O operations. This may however require a lot 
> more memory both on kernel side and userland side.

Watching an entire filesystem entails reading all the directories, but
you don't have to fetch the inodes of files.  But still, it's very
slow (takes about 15 minutes on my /home from cold cache, just to read
the million or so directories).

There was some work on propagating events upwards so that efficient
recursive watches could be established, in the context of fanotify but
it would make sense to be available to all fsnotify users.  I wonder
how that went.

> > Then this can be solved, in principle (if there's no better way), by
> > watching a "virtual directory" that gets all events for when the
> > access doesn't have a parent directory.  There needs to be some way to
> > watch it, and some way to get the appropriate file from the event (as
> > there is no real directory.  Or maybe there could be a virtual
> > filesystem (like /proc, /sys etc.) containing a magic directory that
> > receives these inode-only events, such that lookups in that directory
> > yield the affected file.  Exactly as if the directory contains a hard
> > link to every file, perhaps a text encoding of the handles passed
> > through sys_open_by_handle_at.
> 
> By doing that, we'll only get the inode nb as we cannot fetch the filename.

Yes... That's ok if it's one we are tracking inode->multiple-paths in
userspace anyway (for hard links).  But it's quite demanding if we
hoped to avoid fetching and storing that in userspace for
st_nlink == 1 files.

In that case it is still better to get a notification "something
unknown on this FS has changed", rather than no notification.
Userspace would react by flushing all of its cached knowledge of
things under directory watches that don't have direct watches.  But at
least that's reliable and correct behaviour, and if it happens often,
userspace heuristics can react by watching priority inodes more directly.

If that's the common case, then these nameless, pathless events could
just trigger a simple event with catch-all IN_NO_PATH flag set,
referring to the filesytem but no more detail than that.  inotify
would accept that flag when adding a watch, ignore the inode given but
remember the filesystem, and send all events with no path to the
watch(es) created with that flag on that filesystem.  It's a flag
because the event type is still useful.

All the best,
-- Jamie
