Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36417 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757056Ab1K3CHW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 21:07:22 -0500
Message-ID: <1322618839.11286.130.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        bhalevy@tonian.com, Garth Gibson <garth@panasas.com>,
        Matt Benjamin <matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>,
        Fred Isaman <iisaman@netapp.com>
Date: Tue, 29 Nov 2011 21:07:19 -0500
In-Reply-To: <4ED58ADE.8010809@panasas.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
	     <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>
	    <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>
	   <1322606842.11286.33.camel@lade.trondhjem.org>
	   <4ED563AC.5040501@panasas.com>
	  <1322609431.11286.56.camel@lade.trondhjem.org>
	  <4ED577AE.2060209@panasas.com>
	 <1322614718.11286.104.camel@lade.trondhjem.org>
	 <4ED58ADE.8010809@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 17:46 -0800, Boaz Harrosh wrote: 
> On 11/29/2011 04:58 PM, Trond Myklebust wrote:
> > On Tue, 2011-11-29 at 16:24 -0800, Boaz Harrosh wrote: 
> >> On 11/29/2011 03:30 PM, Trond Myklebust wrote:
> >>> On Tue, 2011-11-29 at 14:58 -0800, Boaz Harrosh wrote: 
> >>
> >> That I don't understand. What "spec worms that the pNFS layout segments open"
> >> Are you seeing. Because it works pretty simple for me. And I don't see the
> >> big difference for files. One thing I learned for the past is that when you
> >> have concerns I should understand them and start to address them. Because
> >> your insights are usually on the Money. If you are concerned then there is
> >> something I should fix.
> > 
> > I'm saying that if I need to manage layouts that deal with >1000 DSes,
> > then I presumably need a strategy for ensuring that I return/forget
> > segments that are no longer needed, and I need a strategy for ensuring
> > that I always hold the segments that I do need; otherwise, I could just
> > ask for a full-file layout and deal with the 1000 DSes (which is what we
> > do today)...
> > 
> 
> Thanks for asking because now I can answer you and you will find that I'm
> one step a head in some of the issues.
> 
> 1. The 1000 DSes problem is separate from the segments problem. The devices

Errr... That was the problem that you used to justify the need for a
full implementation of layout segments in the pNFS files case...

> solution is on the way. The device cache is all but ready to see some
>    periodic scan that throws 0 used devices. We never got to it because
>    currently every one is testing with up to 10 devices and I'm using upto
>    128 devices which is just fine. The load is marginal so far.
>    But I promise you it is right here on my to do list. After some more
>    pressed problem.
>    Lets say one thing this subsystem is the same regardless of if the
>    1000 devices are refed by 1 segment or by 10 segments. Actually if
>    by 10 then I might get rid of some and free devices.
> 
> 2. The many segments problem. There are not that many. It's more less
>    a segment for every 2GB so an lo_seg struct for so much IO is not
>    noticeable.

Where do you get that 2GB number from?

> At the upper bound we do not have any problem because Once the system is
>    out of memory it will start to evict inodes. And on evict we just return
>    them. Also ROC Servers we forget them on close. So so far all our combined
>    testing did not show any real memory pressure caused by that. When shown we
>    can start discarding segs in an LRU fashion. There are all the mechanics
>    to do that, we only need to see the need.

It's not necessarily that simple: if you are already low on memory, them
LAYOUTGET and GETDEVICE will require you to allocate more memory in
order to get round to cleaning those dirty pages.
There are plenty of situations where the majority of dirty pages belong
to a single file. If that file is one of your 1000 DS-files and it
requires you to allocate 1000 new device table entries...

> 3. The current situation is fine and working and showing great performance
>    for objects and blocks. And it is all in the Generic part so it should just
>    be the same for files. I do not see any difference.
> 
>    The only BUG I see is the COMMIT and I think we know how to fix that

I haven't seen any performance numbers for either, so I can't comment.

> > My problem is that the spec certainly doesn't give me any guidance as to
> > such a strategy, and I haven't seen anybody else step up to the plate.
> > In fact, I strongly suspect that such a strategy is going to be very
> > application specific.
> > 
> 
> You never asked. I'm thinking about these things all the time. Currently
> we are far behind the limits of a running system. I think I'm going to
> get to these limits before any one else.
> 
> My strategy is stated above LRU for devices is almost all there ref-counting
> and all only the periodic timer needs to be added.
> LRU for segments is more work, but is doable. But the segments count are
> so low that we will not hit that problem for a long time. Before I ship
> a system that will break that barrier I'll send a fix I promise.

As far as pNFS files is concerned, the memory pressure should be driven
by the number of devices (i.e. DSes).

> > IOW: I don't accept that a layout-segment based solution is useful
> > without some form of strategy for telling me which segments to keep and
> > which to throw out when I start hitting client resource limits. 
> 
> LRU. Again there are not more than a few segments per inode. It's not
> 1000 like devices.

Again, the problem for files shouldn't be the number of segments, it is
number of devices.

> > I also
> > haven't seen any strategy out there for setting loga_length (as opposed
> > to loga_minlength) in the LAYOUTGET requests: as far as I know that is
> > going to be heavily application-dependent in the 1000-DS world.
> > 
> 
> Current situation is working for me. But we also are actively working to
> improve it. What we want is that files-LO can enjoy the same privileges that
> objects and blocks already have, in exactly the same, simple stupid but working,
> way.
> 
> All your above concerns are true and interesting. I call them a rich man problems.
> But they are not specific to files-LO they are generic to all of us. Current situation
> satisfies us for blocks and objects. The file guys out there are jealous.

I'm not convinced that the problems are the same. objects, and
particularly blocks, appear to treat layout segments as a form of byte
range lock. There is no reason for a pNFS files server to do so.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

