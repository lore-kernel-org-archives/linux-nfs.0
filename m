From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: reconnect_path() breaks NFS server causing occasional EACCES
Date: Tue, 29 Apr 2008 19:40:04 +0200
Message-ID: <20080429174004.GA28719@janus>
References: <20080404102449.GA10209@janus> <20080407184346.GF3305@fieldses.org> <20080409133639.GA9588@lst.de> <18454.45086.254692.412079@notabene.brown> <20080429163554.GE20420@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@lst.de>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:42600 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760827AbYD2RkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2008 13:40:06 -0400
In-Reply-To: <20080429163554.GE20420@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 29, 2008 at 12:35:54PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 29, 2008 at 03:20:30PM +1000, Neil Brown wrote:
> > On Wednesday April 9, hch@lst.de wrote:
> > > On Mon, Apr 07, 2008 at 02:43:46PM -0400, J. Bruce Fields wrote:
> > > > Anyone who depends on the "x" bit to control access to objects in an
> > > > nfs-exported filesystem is already in trouble.  We could do so for
> > > > directories (at the expense of non-posix-like behavior such as what
> > > > you've seen), but we probably can't for files.  So I'm inclined to think
> > > > this is the right thing to do.
> > > > 
> > > > The "DON'T USE THIS FUNCTION EVER, thanks." suggests we should at least
> > > > consult the person who added that comment (cc'd) before adding a call to
> > > > lookup_one_noperm().  (And if we decide to do this, we should make a
> > > > note of this in that comment.)
> > > 
> > > That function really shouldn't be used and we should obey the x bit.
> > > And yes, due to NFSs staleless file handles this will lead to non-posix
> > > behaviour which is expected.  The same will happen with other nfs
> > > servers aswell.
> > 
> > For the record, I disagree.  I think it is perfectly appropriate to
> > use this function.  I think that obeying the 'x' bit is wrong.
> > 
> > Why?
> > 
> > What we are doing here is reconstructing the dcache to correctly
> > reflect the filesystem.  The reason that we need to do this (rather
> > than just leaving the dentry disconnected as we sometimes do with
> > files) is so that lock_rename can find valid d_parent pointers and can
> > guard against certain directory rename races that might create
> > disconnected loops.
> > 
> > i.e. the look_one_* is not being done on behalf of the owner of the
> > file, or of the group-owner of the file, or of anyone else.  It is
> > being done on behalf of the filesystem to ensure future filesystem
> > consistency.
> > So none of the 'x' bits (owner, group-owner, world) is appropriate to
> > validate this lookup.

Ok, so this is another reason why the x-bit check is incorrect. Sounds like
it could cause improper behavior in other cases.

> 
> Just to make sure I understand--you're not claiming that there's an
> actual threat of corrupting the on-disk filesystem or in-core data
> structures, right? 
> 
> I understand the "this isn't being done as any particular user"
> argument.
> 
> It also seems to me that the actual security value of these checks is
> very low, given that all they're likely to do is raise the cost of a
> filehandle-guessing attack slightly, without really eliminating it.
> 
> And from the point of a user the current behavior seems likely to lead
> to difficult-to-analyse behavior.
> 
> So I don't understand Christoph's objection yet either.
> 
> It might also help if we could confirm or deny Christoph's assertion
> about the behavior of other nfs servers.  It shouldn't be hard to run
> the original test case
> 
> 	http://marc.info/?l=linux-nfs&m=120730475719642&w=2
> 
> against another server or two.

I don't think it is that relevant for two reasons:

* Currently, the linux NFS server behaves inconsistent depending
  on memory pressure/reboot. That on its own looks like a bug to me.

* The NFS server should never re-check access to a [directory]
  path which has been used in the past to obtain a handle:
  Permission checks apply only once, at open time. This is how
  POSIX filesystems behave.

I also guess it will be hard to find another NFS server with exactly the
same behavior. Either the x-bit of the complete path to the file-handle
is checked upon every operation (sounds totally broken to me) or it is
never checked beyond open time. It looks like this bug has everything
to do with the internal housekeeping and is certainly not intentional.

-- 
Frank
