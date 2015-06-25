Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53702 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389AbbFYSqp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jun 2015 14:46:45 -0400
Date: Thu, 25 Jun 2015 14:46:44 -0400
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: dsterba@suse.cz, Liu Bo <bo.li.liu@oracle.com>,
        linux-btrfs@vger.kernel.org, fdmanana@suse.com, kzak@redhat.com,
        linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        mingming.cao@oracle.com
Subject: Re: i_version vs iversion (Was: Re: [RFC PATCH v2 1/2] Btrfs: add
 noi_version option to disable MS_I_VERSION)
Message-ID: <20150625184644.GA12300@fieldses.org>
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
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 23, 2015 at 12:32:41PM -0400, Theodore Ts'o wrote:
> On Thu, Jun 18, 2015 at 04:38:56PM +0200, David Sterba wrote:
> > Moving the discussion to fsdevel.
> > 
> > Summary: disabling MS_I_VERSION brings some speedups to btrfs, but the
> > generic 'noiversion' option cannot be used to achieve that. It is
> > processed before it reaches btrfs superblock callback, where
> > MS_I_VERSION is forced.
> > 
> > The proposed fix is to add btrfs-specific i_version/noi_version to btrfs,
> > to which I object.
> 
> I was talking to Mingming about this on today's ext4 conference call,
> and one of the reasons why ext4 turns off i_version update by default
> is because it does a real number on our performance as well --- and
> furthermore, the only real user of the field from what we can tell is
> NFSv4, which not all that many ext4 users actually care about.
> 
> This has caused pain for the nfsv4 folks since it means that they need
> to tell people to use a special mount option for ext4 if they are
> actually using this for nfsv4, and I suspect they won't be all that
> eager to hear that btrfs is going to go the same way.

Yes, thanks for looking into this!

> This however got us thinking --- even in if NFSv4 is depending on
> i_version, it doesn't actually _look_ at that field all that often.

Most clients will query it on every write.  (I just took a quick look at
the code and I believe the Linux client's requesting it immediately
after every write, except in the O_DIRECT and delegated cases.)

> It's only going to look at it in a response to a client's getattr
> call, and that in turn is used to so the client can do its local disk
> cache invalidation if anby of the data blocks of the inode has changed.
> 
> So what if we have a per-inode flag which "don't update I_VERSION",
> which is off by default, but after the i_version has been updated at
> least once, is set, so the i_version field won't be updated again ---
> at least until something has actually looked at the i_version field,
> when the "don't update I_VERSOIN" flag will get cleared again.
> 
> So basically, if we know there are no microphones in the forest, we
> don't need to make the tree fall.  However, if someone has sampled the
> i_version field, then the next time the inode gets updated, we will
> update the i_version field so the NFSv4 client can hear the sound of
> the tree crashing to the forst floor and so it can invalidate its
> local cache of the file.  :-)
> 
> This should significantly improve the performance of using the
> i_version field if the file system is being exported via NFSv4, and if
> NFSv4 is not in use, no one will be looking at the i_version field, so
> the performance impact will be very slight, and thus we could enable
> i_version updates by default for btrfs and ext4.
> 
> And this should make the distribution folks happy, since it will unify
> the behavior of all file systems, and make life easier for users who
> won't need to set certain magic mount options depending on what file
> system they are using and whether they are using NFSv4 or not.
> 
> Does this sound reasonable?

Just to make sure I understand, the logic is something like:

	to read the i_version:

		inode->i_version_seen = true;
		return inode->i_version

	to update the i_version:

		/*
		 * If nobody's seen this value of i_version then we can
		 * keep using it, otherwise we need a new one:
		 */
		if (inode->i_version_seen)
			inode->i_version++;
		inode->i_version_seen = false;

Looks OK to me.  As I say I'd expect i_version_seen == true to end up
being the common case in a lot of v4 workloads, so I'm more skeptical of
the claim of a performance improvement in the v4 case.

Could maintaining the new flag be a significant drag in itself?  If not,
then I guess we're not making things any worse there, so fine.

--b.
