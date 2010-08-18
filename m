Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47232 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387Ab0HRXlq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 19:41:46 -0400
Date: Thu, 19 Aug 2010 09:41:36 +1000
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100819094136.24fef59b@notabene>
In-Reply-To: <0F91AB9D-0E14-4384-ADD6-0A467C3ABFAC@oracle.com>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<20100817192937.GD26609@fieldses.org>
	<20100818155359.66b9ddb6@notabene>
	<20100818173203.GC32430@fieldses.org>
	<0F91AB9D-0E14-4384-ADD6-0A467C3ABFAC@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 18 Aug 2010 14:15:51 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Aug 18, 2010, at 1:32 PM, J. Bruce Fields wrote:
> 
> > On Wed, Aug 18, 2010 at 03:53:59PM +1000, Neil Brown wrote:
> >> I'm not sure you even want to pay for a per-filesystem atomic access when
> >> updating mtime.  mnt_want_write - called at the same time - seems to go to
> >> some lengths to avoid an atomic operation.
> >> 
> >> I think that nfsd should be the only place that has to pay the atomic
> >> penalty, as it is where the need is.
> >> 
> >> I imagine something like this:
> >> - Create a global struct timespec which is protected by a seqlock
> >>   Call it current_nfsd_time or similar.
> >> - file_update_time reads this and uses it if it is newer than
> >>   current_fs_time.
> >> - nfsd updates it whenever it reads an mtime out of an inode that matches
> >>   current_fs_time to the granularity of 1/HZ.
> > 
> > We can also skip the update whenever current_nfsd_time is greater than
> > the inode's mtime--that's enough to ensure that the next
> > file_update_time() call will get a time different from the inode's
> > current mtime.
> 
> Would it help if we only did this for directories, for now?
> 
> Files have close-to-open.  Directories... don't.  So we have the problem where directory changes (ie file creation and deletion) takes a long time (some times an infinitely long time) to propagate to clients.  Plus: directories don't change very often, so using fine-grained time stamps only on directories wouldn't impact heavy I/O workloads.

I'm don't quite see how close-to-open really affects this issue - it still
relies on the timestamps and so can cache old data if a file update didn't
change the timestamp.

In my mind the difference is that near-concurrent access to files usually
involves file locking which flushes caches (and if it doesn't then you have
bigger problems) while near-concurrent access to directories relies on the
natural atomicity of dir operations so no locking or flushing occurs.

So I agree that this is probably more of an issue for directories than for
files, and that implementing it just for directories would be a sensible
first step with lower expected overhead - just my reasoning seems to be a bit
different.

Thanks,
NeilBrown
