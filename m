Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53223 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810AbbFXSCS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2015 14:02:18 -0400
Date: Wed, 24 Jun 2015 20:02:15 +0200
From: David Sterba <dsterba@suse.cz>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: Liu Bo <bo.li.liu@oracle.com>, linux-btrfs@vger.kernel.org,
        fdmanana@suse.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com, mingming.cao@oracle.com
Subject: Re: i_version vs iversion (Was: Re: [RFC PATCH v2 1/2] Btrfs: add
 noi_version option to disable MS_I_VERSION)
Message-ID: <20150624180215.GC726@suse.cz>
Reply-To: dsterba@suse.cz
References: <1434527672-5762-1-git-send-email-bo.li.liu@oracle.com>
 <20150617153306.GY6761@twin.jikos.cz>
 <20150617155234.GB7773@localhost.localdomain>
 <20150617170118.GA6761@twin.jikos.cz>
 <20150618024607.GA8530@localhost.localdomain>
 <20150618143856.GG6761@suse.cz>
 <20150623163241.GA6645@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150623163241.GA6645@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 23, 2015 at 12:32:41PM -0400, Theodore Ts'o wrote:
> This has caused pain for the nfsv4 folks since it means that they need
> to tell people to use a special mount option for ext4 if they are
> actually using this for nfsv4, and I suspect they won't be all that
> eager to hear that btrfs is going to go the same way.

I did not mean to change the default behaviour with respect to nfs, that
would be a regression.

> This however got us thinking --- even in if NFSv4 is depending on
> i_version, it doesn't actually _look_ at that field all that often.
> It's only going to look at it in a response to a client's getattr
> call, and that in turn is used to so the client can do its local disk
> cache invalidation if anby of the data blocks of the inode has changed.
> 
> So what if we have a per-inode flag which "don't update I_VERSION",
> which is off by default, but after the i_version has been updated at
> least once, is set, so the i_version field won't be updated again ---
> at least until something has actually looked at the i_version field,
> when the "don't update I_VERSOIN" flag will get cleared again.

This sounds similar to what Dave proposed, a per-inode I_VERSION
attribute that can be changed through chattr. Though the negated meaning
of the flag could be confusing, I had to reread the paragraph again.

> This should significantly improve the performance of using the
> i_version field if the file system is being exported via NFSv4, and if
> NFSv4 is not in use, no one will be looking at the i_version field, so
> the performance impact will be very slight, and thus we could enable
> i_version updates by default for btrfs and ext4.

Btrfs default is to update i_version and the uscecase gets fixed by the
per-inode attribute. But from your description above I think that this
might not be enough for ext4. The reason I see are the different
defaults. You want to turn it on by default but not impose any
performance penalty for that, while for our usecase it's sufficient to
selectively turn it off.

I've tried to locate the source of performance drop for ext4 + iversion,
but was not successful so I don't know if the proposed fix is complete.

> And this should make the distribution folks happy, since it will unify
> the behavior of all file systems, and make life easier for users who
> won't need to set certain magic mount options depending on what file
> system they are using and whether they are using NFSv4 or not.
> 
> Does this sound reasonable?

It does, the unified behaviour wrt NFS is definitely a good thing.
