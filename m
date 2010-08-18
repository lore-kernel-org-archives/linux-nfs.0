Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47397 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074Ab0HRXrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 19:47:47 -0400
Date: Thu, 19 Aug 2010 09:47:38 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100819094738.37cfa566@notabene>
In-Reply-To: <20100818173203.GC32430@fieldses.org>
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
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 18 Aug 2010 13:32:03 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Aug 18, 2010 at 03:53:59PM +1000, Neil Brown wrote:
> > I'm not sure you even want to pay for a per-filesystem atomic access when
> > updating mtime.  mnt_want_write - called at the same time - seems to go to
> > some lengths to avoid an atomic operation.
> > 
> > I think that nfsd should be the only place that has to pay the atomic
> > penalty, as it is where the need is.
> > 
> > I imagine something like this:
> >  - Create a global struct timespec which is protected by a seqlock
> >    Call it current_nfsd_time or similar.
> >  - file_update_time reads this and uses it if it is newer than
> >    current_fs_time.
> >  - nfsd updates it whenever it reads an mtime out of an inode that matches
> >    current_fs_time to the granularity of 1/HZ.
> 
> We can also skip the update whenever current_nfsd_time is greater than
> the inode's mtime--that's enough to ensure that the next
> file_update_time() call will get a time different from the inode's
> current mtime.

Yes, I agree with you and Patrick - very sensible optimisation.

> 
> Would the extra expense rule out treating sys_stat() the same as nfsd?
> It would be nice to be able to solve the same problem for userspace
> nfsd's (or any other application that might be using mtime to save
> rereading data).

It would be nice, but I would be loathe to add any cost to 'stat' unless we
knew it was needed.
If we had an xstat() which could explicitly ask for
high-precision-time-stamps, then yes - otherwise maybe not.

(or maybe define a system:linux.xxxx xattr which would read as a
high-precision time stamp...  I seem to be warming to the idea of using the
xattr interface for enhancing stat).

NeilBrown
