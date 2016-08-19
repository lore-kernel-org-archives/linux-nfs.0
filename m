Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32948 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752088AbcHSR1G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:27:06 -0400
Date: Fri, 19 Aug 2016 13:27:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
Message-ID: <20160819172704.GJ32329@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble>
 <20160714022643.5874.84409.stgit@noble>
 <20160718200121.GC12304@fieldses.org>
 <878twx9ra3.fsf@notabene.neil.brown.name>
 <20160721172452.GC27148@fieldses.org>
 <87wpjokofy.fsf@notabene.neil.brown.name>
 <20160816152148.GC30124@fieldses.org>
 <87bn0qj1yz.fsf@notabene.neil.brown.name>
 <20160818135754.GA21470@fieldses.org>
 <8737m1im2p.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8737m1im2p.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 19, 2016 at 11:28:30AM +1000, NeilBrown wrote:
> On Thu, Aug 18 2016, J. Bruce Fields wrote:
> 
> > Not really arguing--I'll trust your judgement--just some random ideas:
> >
> > On Thu, Aug 18, 2016 at 11:32:52AM +1000, NeilBrown wrote:
> >> On Wed, Aug 17 2016, J. Bruce Fields wrote:
> >> > In which case what it really wants to say is "before nfs mounts" (or
> >> > even "before nfs mounts of localhost"; and vice versa on shutdown).  I
> >> > can't tell if there's an easy way to get say that.
> >> 
> >> I'd be happy with a difficult/complex way, if it was reliable.
> >> Could we write a systemd generator which parses /etc/fstab, determines
> >> all mount points which a loop-back NFS mounts (or even just any NFS
> >> mounts) and creates a drop-in for nfs-server which adds
> >>   Before=mount-point.mount
> >> for each /mount/point.
> >> 
> >> Could that be reliable?  I might try.
> >
> > Digging around... we've also got this callout from mount to start-statd,
> > can we use something like that to make loopback nfs mounts wait on nfs
> > server startup?
> 
> An nfs mount already waits for the server to start up.  The ordering
> dependency between NFS mounts and the nfs-server only really matters at
> shutdown, and we cannot enhance mount.nfs to wait for a negative amount
> of time (also known as "time travel")

D'oh, I keep forgetting that point.

--b.
