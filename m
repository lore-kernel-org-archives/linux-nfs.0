Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:32845 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab1HTDDh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 23:03:37 -0400
Date: Sat, 20 Aug 2011 04:03:35 +0100
From: Jamie Lokier <jamie@shareable.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Sylvain Rochet <gradator@gradator.net>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110820030335.GA14899@jl-vm1.vm.bytemark.co.uk>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
 <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
 <20110820012943.GD2203@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110820012943.GD2203@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Al Viro wrote:
> On Sat, Aug 20, 2011 at 12:37:56AM +0100, Jamie Lokier wrote:
> 
> > Possible solution:
> 
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
> There is a better way - stop using idiotify...  It has always been a
> mistake, driven down our throats by filemangler and desktop crowd.

Well you still have your sense of humour...

I've never understood why you think it's about the file manager /
desktop, or why you so strongly dislike the feature.  It originated
there historically, but that is not it's primary use.

The implementation, sure, but you seem to dislike the very *principle*
of subscribing to changes.

Every interesting use of inotify that I've seen is for some kind of
cache support, to eliminate the majority of stat() calls, to remove
disk I/O (no stat means no inode), to ensure correctness (st_mtime is
coarse and unreliable), and to avoid having to modify every
application which might affect any file from which cached items are
derived to explicitly notify all the applications which might use any
of those files.

You like high performance, reliable and correct behaviour, and high
scalability.  So I have never understood why you dislike the
change-subscription principle so strongly, because it is a natural
ally to those properties.

All the best,
-- Jamie
