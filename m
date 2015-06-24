Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:53494 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbbFXXR6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2015 19:17:58 -0400
Date: Wed, 24 Jun 2015 19:17:50 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: dsterba@suse.cz, Liu Bo <bo.li.liu@oracle.com>,
        linux-btrfs@vger.kernel.org, fdmanana@suse.com, kzak@redhat.com,
        linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        mingming.cao@oracle.com
Subject: Re: i_version vs iversion (Was: Re: [RFC PATCH v2 1/2] Btrfs: add
 noi_version option to disable MS_I_VERSION)
Message-ID: <20150624231750.GE14324@thunk.org>
References: <1434527672-5762-1-git-send-email-bo.li.liu@oracle.com>
 <20150617153306.GY6761@twin.jikos.cz>
 <20150617155234.GB7773@localhost.localdomain>
 <20150617170118.GA6761@twin.jikos.cz>
 <20150618024607.GA8530@localhost.localdomain>
 <20150618143856.GG6761@suse.cz>
 <20150623163241.GA6645@thunk.org>
 <20150624180215.GC726@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150624180215.GC726@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 24, 2015 at 08:02:15PM +0200, David Sterba wrote:
> 
> This sounds similar to what Dave proposed, a per-inode I_VERSION
> attribute that can be changed through chattr. Though the negated meaning
> of the flag could be confusing, I had to reread the paragraph again.

Dave did not specify an I_VERSION attribute that would be stored on
disk.  Instead he talked about a inode flag that would be set when the
struct inode is created by the file system.

This would allow file systems to permanently configure (on a per-inode
basis) whether or not a particular inode would require a forced
i_version update any time the inode's data or metadata is modified.  I
suppose you could initialized the inode flag from an on-disk
attribute, but that wasn't implied by Dave's proposal, at least as I
understood it.

> > This should significantly improve the performance of using the
> > i_version field if the file system is being exported via NFSv4, and if
> > NFSv4 is not in use, no one will be looking at the i_version field, so
> > the performance impact will be very slight, and thus we could enable
> > i_version updates by default for btrfs and ext4.
> 
> Btrfs default is to update i_version and the uscecase gets fixed by the
> per-inode attribute. But from your description above I think that this
> might not be enough for ext4. The reason I see are the different
> defaults. You want to turn it on by default but not impose any
> performance penalty for that, while for our usecase it's sufficient to
> selectively turn it off.

The problem with selectively turning it off is that the user might
decide for a particular file which is getting lots of updates to turn
off i_version updates --- but then at some subsequent time, that file
is part of a file system which is exported NFSv4, clients will
mysteriously break because i_version was manually turned off.

So this is going to be a potential support nightmare for enterprise
distro help desks --- the user will report that a particular file is
constantly getting corrupted, due to the NFSv4 cache invalidation
getting broken, and it might not be obvious why this is only happening
with this one file, and it's because with btrfs, the i_version update
for particular file was selectively turned off.  I don't think it's a
good design where it is easy for the user to set a flag which breaks
functionality, and in a potentially confusing way, especially when the
net result is potential data corruption.

This is why I would much rather have the default be on, but with
minimal (preferably not measurable) performance overhead.  It's the
best of both worlds.

						- Ted
						
