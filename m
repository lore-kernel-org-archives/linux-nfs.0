Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60242 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586Ab0HRFyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 01:54:09 -0400
Date: Wed, 18 Aug 2010 15:53:59 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100818155359.66b9ddb6@notabene>
In-Reply-To: <20100817192937.GD26609@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<20100817192937.GD26609@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 17 Aug 2010 15:29:38 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Aug 17, 2010 at 08:39:41PM +0100, Alan Cox wrote:
> > > The problem with "increment mtime by a nanosecond when necessary" is
> > > that timestamps can wind up out of order.  As in:
> > 
> > Surely that depends on your implementation ?
> > 
> > > 1) Do a bunch of operations on file A
> > > 2) Do one operation on file B
> > > 
> > > Imagine each operation on A incrementing its timestamp by a nanosecond
> > > "just because".  If all of these operations happen in less than 4 ms,
> > > you can wind up with the timestamp on B being EARLIER than the
> > > timestamp on A.  That is a big no-no (think "make" or anything else
> > > relying on timestamps for relative times).
> > 
> > 
> > [time resolution bits of data][value incremented value for that time]
> > 
> > 
> > 	if (time_now == time_last)
> > 		return { time_last , ++ct };
> > 	else {
> > 		ct = 0;
> > 		time_last = time_now;
> > 		return { time_last , 0 };
> > 	}
> > 
> > providing it is done with the same 'ct' across the fs and you can't do
> > enough ops/second to wrap the nanosecs - which should be fine for now,
> > your ordering is still safe is it not ?
> 
> Right, so if I understand correctly, you're proposing a time source
> that's global to the filesystem and that guarantees it will always
> return a unique value by incrementing the nanoseconds field if jiffies
> haven't changed since the last time it was called.
> 
> (Does it really need to be global across all filesystems?  Or is it
> unreasonable to expect your unbelievably-fast make's to behave well when
> sources and targets live on different filesystems?)
>

I'm not sure you even want to pay for a per-filesystem atomic access when
updating mtime.  mnt_want_write - called at the same time - seems to go to
some lengths to avoid an atomic operation.

I think that nfsd should be the only place that has to pay the atomic
penalty, as it is where the need is.

I imagine something like this:
 - Create a global struct timespec which is protected by a seqlock
   Call it current_nfsd_time or similar.
 - file_update_time reads this and uses it if it is newer than
   current_fs_time.
 - nfsd updates it whenever it reads an mtime out of an inode that matches
   current_fs_time to the granularity of 1/HZ.
   If the current value is before current_kernel_time, it
   is set to current_kernel_time, otherwise tv_nsec is incremented -
   unless that increases
   beyond jiffies_to_usec(1)*1000 beyond current_kernel_time.
 - the global 'struct timespec' is zeroed whenever system time is set
   backwards.

Then - providing the fs stores nanosecond timestamps - we should have stable,
globally ordered, precise (if not entirely accurate) time stamps, and a
penalty would only be paid when nfsd actually needs the information.


[[You could probably make ext3 work reasonably well by adding a mount option
  which:
    - advertises s_time_gran as 1
    - when storing: rounds timestamps up to the next second if tv_nsec != 0
    - when loading, setting the timestamp to the current time if the stored
      number matches current_kernel_time().tv_sec+1
  You would get occasional forward jumps in mtime, but usually when you
  aren't looking, and at least you would not get real changes that are not
  reflected in mtime
]]

NeilBrown
