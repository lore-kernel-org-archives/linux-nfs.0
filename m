Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33535 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbbFMR3n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2015 13:29:43 -0400
Received: by igbpi8 with SMTP id pi8so29998991igb.0
        for <linux-nfs@vger.kernel.org>; Sat, 13 Jun 2015 10:29:42 -0700 (PDT)
Date: Sat, 13 Jun 2015 12:29:26 -0500
From: Quentin Barnes <qbarnes@gmail.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Adding file handle support to NFS client code
Message-ID: <20150613172926.GA32068@gmail.com>
References: <20150613004718.GA26293@gmail.com>
 <20150613084839.2854b977@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150613084839.2854b977@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 13, 2015 at 08:48:39AM -0400, Jeff Layton wrote:
> On Fri, 12 Jun 2015 19:47:18 -0500
> Quentin Barnes <qbarnes@gmail.com> wrote:
> 
> > I'm thinking of adding support to the NFS client code so that the
> > open_by_handle_at(2) and name_to_handle_at(2) services would work
> > on NFS mounted file systems.  As far as I can tell, this support
> > currently doesn't exist in mainline, correct?
> > 
> 
> Correct.

And I take it no one has any experimental work in this regards
tucked away somewhere either.

> > Many years ago I created and still maintain (unreleased) code for
> > RHEL4-RHEL6 kernels that provide open-by-file-handle services for
> > NFS clients.  The approach was loosely based on Robert Love's ext3
> > open-by-inode patch of long ago.
> > 
> > We have used the modified NFS client code as a significant
> > performance boost in accessing mostly read-only files from NFS file
> > servers.  The files number in the many 10s of millions in trees
> > spread across many hundreds of thousands of nested directories.
> > (Come to think of it, that was several years ago.  I'm sure since
> > then the numbers have grown by at least an order of magnitude or
> > two.)  With the sheer numbers of files and directories, attempting
> > to use even openat(2) with all those directories would still be
> > overwhelming to the servers' inode cache.  Also, just doing all the
> > constant tree-walks down to the files kill performance and stresses
> > the dentry cache, let alone all the network traffic and load on our
> > filers that would generate.  So that's why an open-by-file-handle
> > hack was added to our kernels.
> > 
> > Now the time has come for that functionality to be ported to a
> > RHEL7-based kernel.  Seems to me the best approach would be not to
> > port my old work forward but to complete the fhandle callbacks for
> > NFS clients.  However, before I begin my journey down that path, I'd
> > like to hear if anyone has tried it before, or if there's a good
> > reason not to choose this approach.  Any comments?
> > 
> > 
> > If the NFS client fhandle support is the right way to go, since
> > it wouldn't be a hackfest like my previous effort, I'd attempt
> > contribute it upstream in case anyone else would ever find it
> > useful.
> > 
> > Quentin
> 
> I think it makes sense to use the standard syscalls instead of ioctls
> or something, and having this support sounds at least moderately useful.

Yes, in my hack I have an ioctl() that retrieves the file handle.

> The big stumbling block is that open_by_handle_at (and to some degree
> name_to_handle_at) rely on the filesystem being exportable via knfsd,
> and the NFS client is (intentionally) not. So, you'll have some work to
> do there...

I know there are boundary cases like knfsd that are uninteresting
to our goals, but I still would at least want to be aware of them,
so my code and testing efforts can try to account for them making
the code robust.  (If I can't and have to revert to hacking again to
make it work, I'll not foist those hacks on the community.)

> Also, how do you intend to present the filehandles here in (e.g.)
> name_to_handle_at? Are you planning to generate synthetic filehandles
> based on the inode number that the NFS client generates or are you
> going to try to pass them through (opaquely) as-is from the actual
> server?

Expose the server's NFS file handle to userspace.  That's the way
my current implementation works and is an required design constraint.

Our existing userspace code relies on having a distributed database
mapping the files to their NFS server's file handles.  That
database is shared and updated among the clients.  Of course the
NFS standard doesn't directly support this, since, as far as I can
tell, the server is free to hash client-specific information into
the handle returned to each client.  However, so far in 10+ years,
no NFS server we've encountered does this, so relying on this
implementation-defined behavior hasn't been a problem.

> -- 
> Jeff Layton <jlayton@poochiereds.net>

Quentin
