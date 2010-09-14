Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from jay.phy.queensu.ca ([130.15.24.47]:56277 "EHLO
	jay.phy.QueensU.CA" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960Ab0INSk5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 14:40:57 -0400
Date: Tue, 14 Sep 2010 14:40:44 -0400
From: Peter Skensved <peter@jay.phy.QueensU.CA>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd4_stateowners problem
Message-ID: <20100914184044.GA30454@jay.phy.QueensU.CA>
References: <20100827174823.GA26792@jay.phy.QueensU.CA> <20100914173154.GC2409@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100914173154.GC2409@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 14, 2010 at 01:31:54PM -0400, J. Bruce Fields wrote:
> On Fri, Aug 27, 2010 at 01:48:23PM -0400, Peter Skensved wrote:
> > 
> >   I'm looking for pointers and information on how to debug and annoying NFS
> > problem that has been bugging us for a long time. The problem is that the number
> > of nfsd4_stateowners keeps increasing until all low memory is exhausted and
> > the oom-killer is invoked. The severity of the problem has changed over time
> > with different kernels. At present it takes about 5 weeks for the size to
> > grow to 500 Mb  ( kernel 2.6.18-194.8.1.el5PAE, CentOS5.5 ). Restarting 
> > nfs clears up the problem but it is definitely not the preferred solution. 
> > 
> >  The increase in the number of nfsd4_stateowners appears to happen in bursts.
> > Nothing happens for long times and I suddenly see a burst. I've tried ( briefly )
> > to turn on all logging in rpcdebug and have run tcpdump while watching slabtop
> > but there is too much output to be able to see if there is anything strange
> > happening. So - my question is : how do I limit the diagnostic output to what
> > is relevant ? What are the modules and flags that I should be looking at ?
> > Any other info I should bemonitoring ? /proc/fs/nfsfs ?
> 
> >From the point of view of upstream, 2.6.18 is a bit old.
> 
> I can't think of any existing logging or statistics that would answer
> the question; we'd probably need to add some more.
> 
> --b.


 Thanks for the reply.  The current RedHat EL5 kernels are all based on 2.6.18 with
a lot of backported fixes so I'm not sure what version of the NFS code I'm effectively
running.

 Do you know what the state_owners are used for ? What puzzles me is that in our case
we have a large number of workstations which NFS mounts some fairly large, mostly static
common directories and automounts HOME directories. So I would expect the amount of state
info that needs to be kept would be fairly constant. When the automounter unmounts the
info ought to go away . Yet the number of stateowners for the most part just keep on
growing. 

 The only work around at the moment is to reboot before it has eaten up around 500 Mb
of slabs
 

                                                                   peter
