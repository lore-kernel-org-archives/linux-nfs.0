Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38047 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab0INRdA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Sep 2010 13:33:00 -0400
Date: Tue, 14 Sep 2010 13:31:54 -0400
To: Peter Skensved <peter@jay.phy.QueensU.CA>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd4_stateowners problem
Message-ID: <20100914173154.GC2409@fieldses.org>
References: <20100827174823.GA26792@jay.phy.QueensU.CA>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100827174823.GA26792@jay.phy.QueensU.CA>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 27, 2010 at 01:48:23PM -0400, Peter Skensved wrote:
> 
>   I'm looking for pointers and information on how to debug and annoying NFS
> problem that has been bugging us for a long time. The problem is that the number
> of nfsd4_stateowners keeps increasing until all low memory is exhausted and
> the oom-killer is invoked. The severity of the problem has changed over time
> with different kernels. At present it takes about 5 weeks for the size to
> grow to 500 Mb  ( kernel 2.6.18-194.8.1.el5PAE, CentOS5.5 ). Restarting 
> nfs clears up the problem but it is definitely not the preferred solution. 
> 
>  The increase in the number of nfsd4_stateowners appears to happen in bursts.
> Nothing happens for long times and I suddenly see a burst. I've tried ( briefly )
> to turn on all logging in rpcdebug and have run tcpdump while watching slabtop
> but there is too much output to be able to see if there is anything strange
> happening. So - my question is : how do I limit the diagnostic output to what
> is relevant ? What are the modules and flags that I should be looking at ?
> Any other info I should bemonitoring ? /proc/fs/nfsfs ?

>From the point of view of upstream, 2.6.18 is a bit old.

I can't think of any existing logging or statistics that would answer
the question; we'd probably need to add some more.

--b.
