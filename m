From: Neil Brown <neilb@suse.de>
Subject: Re: reconnect_path() breaks NFS server causing occasional EACCES
Date: Tue, 29 Apr 2008 15:20:30 +1000
Message-ID: <18454.45086.254692.412079@notabene.brown>
References: <20080404102449.GA10209@janus>
	<20080407184346.GF3305@fieldses.org>
	<20080409133639.GA9588@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53259 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504AbYD2FUP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2008 01:20:15 -0400
In-Reply-To: message from Christoph Hellwig on Wednesday April 9
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday April 9, hch@lst.de wrote:
> On Mon, Apr 07, 2008 at 02:43:46PM -0400, J. Bruce Fields wrote:
> > Anyone who depends on the "x" bit to control access to objects in an
> > nfs-exported filesystem is already in trouble.  We could do so for
> > directories (at the expense of non-posix-like behavior such as what
> > you've seen), but we probably can't for files.  So I'm inclined to think
> > this is the right thing to do.
> > 
> > The "DON'T USE THIS FUNCTION EVER, thanks." suggests we should at least
> > consult the person who added that comment (cc'd) before adding a call to
> > lookup_one_noperm().  (And if we decide to do this, we should make a
> > note of this in that comment.)
> 
> That function really shouldn't be used and we should obey the x bit.
> And yes, due to NFSs staleless file handles this will lead to non-posix
> behaviour which is expected.  The same will happen with other nfs
> servers aswell.

For the record, I disagree.  I think it is perfectly appropriate to
use this function.  I think that obeying the 'x' bit is wrong.

Why?

What we are doing here is reconstructing the dcache to correctly
reflect the filesystem.  The reason that we need to do this (rather
than just leaving the dentry disconnected as we sometimes do with
files) is so that lock_rename can find valid d_parent pointers and can
guard against certain directory rename races that might create
disconnected loops.

i.e. the look_one_* is not being done on behalf of the owner of the
file, or of the group-owner of the file, or of anyone else.  It is
being done on behalf of the filesystem to ensure future filesystem
consistency.
So none of the 'x' bits (owner, group-owner, world) is appropriate to
validate this lookup.

NeilBrown
