Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40318 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758209AbcEFS3Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 May 2016 14:29:24 -0400
Date: Fri, 6 May 2016 14:29:23 -0400
To: Dave Chinner <david@fromorbit.com>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160506182923.GB13350@fieldses.org>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
 <20160504225601.GZ26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160504225601.GZ26977@dastard>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 05, 2016 at 08:56:02AM +1000, Dave Chinner wrote:
> IMO, exposing the inode generation number to anyone is a potential
> security problem because they are used in file handles.
> 
> Most file handles provided by filesystems are simply an encoding of
> the inode number + generation number, plus maybe the ino+gen of the
> parent dir if the NFS server is configured to do this. This makes it
> trivial for an attacker to guess what the likely generation numbers
> are going to be for inode numbers surrounding any given inode, hence
> greatly reducing the search space for guessing valid file handles.
> 
> We've known this to be a problem for a long time - file handles are
> not cryptographically secure,

I once thought signing filehandles cryptographically to prevent spoofing
would be interesting.  But once you've handed out a filehandle, it's
hard to keep it secret.  And the server's required to respect a file's
filehandle for the lifetime of the file, so it only has to leak once.
So I'm no longer convinced it's worth going to that kind of trouble.

Just choosing the generation number randomly, OK, maybe that's a
reasonable measure.

> so exposing information like this by
> default make guessing handles successfully almost trivial for many
> filesystems.
> 
> In the latest XFS filesystem format, we randomise the generation
> value during every inode allocation to make it hard to guess the
> handle of adjacent inodes from an existing ino+gen pair, or even
> from life time to life time of the same inode.

The one thing I wonder about is whether that increases the probability
of a filehandle collision (where you accidentally generate the same
filehandle for two different files).

If the generation number is a 32-bit counter per inode number (is that
actually the way filesystems work?), then it takes 2^32 reuses of the
inode number to hit the same filehandle.  If you choose it randomly then
you expect a collision after about 2^16 reuses.

I don't know, maybe this is still unlikely enough to be academic.

> We don't use a secure
> random number generator (prandom_u32()) so it's still possible to
> guess with enough trial and observation. However, it makes it
> several orders of magnitude harder to guess and requires knowledge
> of inode allocation order to guess correctly once the random number
> sequence has been deduced and so makes brute force the only real
> option for guessing a valid handle for an inode.
> 
> However, this is definitely a problem for the older format where
> each cluster of inodes was initialised with the same seed at cluster
> allocation time and the generation number was simply incremented for
> each life time. Most filesystems use a similar method for seeding
> and incrementing generation numbers, so once the generation numbers
> are exposed it makes handles trivial to calculate successfully.
> 
> >      If the caller didn't ask for them, then they may be approximated.  For
> >      example, NFS won't waste any time updating them from the server, unless
> >      as a byproduct of updating something requested.
> 
> I would suggest that exposing them from the NFS server is something
> we most definitely don't want to do because they are the only thing
> that keeps remote users from guessing filehandles with ease....

The first line of defense is not to depend on unguessable filehandles.
(Don't export sudirectories unless you're willing to export the whole
filesystem; and don't depend on directory permissions to keep children
secret.)

--b.
