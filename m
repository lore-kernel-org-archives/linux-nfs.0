Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:13168 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbbFXX7E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 19:59:04 -0400
Date: Thu, 25 Jun 2015 09:59:00 +1000
From: Dave Chinner <david@fromorbit.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: dsterba@suse.cz, Liu Bo <bo.li.liu@oracle.com>,
        linux-btrfs@vger.kernel.org, fdmanana@suse.com, kzak@redhat.com,
        linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        mingming.cao@oracle.com
Subject: Re: i_version vs iversion (Was: Re: [RFC PATCH v2 1/2] Btrfs: add
 noi_version option to disable MS_I_VERSION)
Message-ID: <20150624235900.GC7943@dastard>
References: <1434527672-5762-1-git-send-email-bo.li.liu@oracle.com>
 <20150617153306.GY6761@twin.jikos.cz>
 <20150617155234.GB7773@localhost.localdomain>
 <20150617170118.GA6761@twin.jikos.cz>
 <20150618024607.GA8530@localhost.localdomain>
 <20150618143856.GG6761@suse.cz>
 <20150623163241.GA6645@thunk.org>
 <20150624180215.GC726@suse.cz>
 <20150624231750.GE14324@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150624231750.GE14324@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 24, 2015 at 07:17:50PM -0400, Theodore Ts'o wrote:
> On Wed, Jun 24, 2015 at 08:02:15PM +0200, David Sterba wrote:
> > 
> > This sounds similar to what Dave proposed, a per-inode I_VERSION
> > attribute that can be changed through chattr. Though the negated meaning
> > of the flag could be confusing, I had to reread the paragraph again.
> 
> Dave did not specify an I_VERSION attribute that would be stored on
> disk.  Instead he talked about a inode flag that would be set when the
> struct inode is created by the file system.

Right.

> This would allow file systems to permanently configure (on a per-inode
> basis) whether or not a particular inode would require a forced
> i_version update any time the inode's data or metadata is modified.  I
> suppose you could initialized the inode flag from an on-disk
> attribute, but that wasn't implied by Dave's proposal, at least as I
> understood it.

It enables filesystems to do this. If btrfs want to add an on-disk
flag to turn off I_VERSION on a per-inode basis, or imply it from
some other on-disk flag, then they are welcome to do so and the
above infrastructure change will support it.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
