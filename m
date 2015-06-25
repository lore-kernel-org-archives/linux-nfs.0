Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:55545 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbbFYWNH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jun 2015 18:13:07 -0400
Date: Thu, 25 Jun 2015 18:12:57 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: dsterba@suse.cz, Liu Bo <bo.li.liu@oracle.com>,
        linux-btrfs@vger.kernel.org, fdmanana@suse.com, kzak@redhat.com,
        linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        mingming.cao@oracle.com
Subject: Re: i_version vs iversion (Was: Re: [RFC PATCH v2 1/2] Btrfs: add
 noi_version option to disable MS_I_VERSION)
Message-ID: <20150625221257.GD13380@thunk.org>
References: <1434527672-5762-1-git-send-email-bo.li.liu@oracle.com>
 <20150617153306.GY6761@twin.jikos.cz>
 <20150617155234.GB7773@localhost.localdomain>
 <20150617170118.GA6761@twin.jikos.cz>
 <20150618024607.GA8530@localhost.localdomain>
 <20150618143856.GG6761@suse.cz>
 <20150623163241.GA6645@thunk.org>
 <20150625184644.GA12300@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150625184644.GA12300@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 25, 2015 at 02:46:44PM -0400, J. Bruce Fields wrote:
> > Does this sound reasonable?
> 
> Just to make sure I understand, the logic is something like:
> 
> 	to read the i_version:
> 
> 		inode->i_version_seen = true;
> 		return inode->i_version
> 
> 	to update the i_version:
> 
> 		/*
> 		 * If nobody's seen this value of i_version then we can
> 		 * keep using it, otherwise we need a new one:
> 		 */
> 		if (inode->i_version_seen)
> 			inode->i_version++;
> 		inode->i_version_seen = false;

Yep, that's what I was proposing.

> Looks OK to me.  As I say I'd expect i_version_seen == true to end up
> being the common case in a lot of v4 workloads, so I'm more skeptical of
> the claim of a performance improvement in the v4 case.

Well, so long as we require i_version to be committed to disk on every
single disk write, we're going to be trading off:

	* client-side performance of the advanced NFSv4 cacheing for reads
	* server-side performance for writes
	* data robustness in case of the server crashing and the client-side cache
	  getting out of sync with the server after the crash

I don't see any way around that.  (So for example, with lazy mtime
updates we wouldn't be updating the inode after every single
non-allocating write; enabling i_version updates will trash that
optimization.)

I just want to reduce to a bare minimum the performance hit in the
case where NFSv4 exports are not being used (since that is true in a
very *large* number of ext4 deployments --- i.e., every single Android
handset using ext4 :-), such that we can leave i_version updates
turned on by default.

> Could maintaining the new flag be a significant drag in itself?  If not,
> then I guess we're not making things any worse there, so fine.

I don't think so; it's a bit in the in-memory inode, so I don't think
that should be an issue.

						- Ted
