Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38620 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710Ab0INUCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Sep 2010 16:02:01 -0400
Date: Tue, 14 Sep 2010 16:00:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Peter Skensved <peter@jay.phy.QueensU.CA>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd4_stateowners problem
Message-ID: <20100914200054.GC4148@fieldses.org>
References: <20100827174823.GA26792@jay.phy.QueensU.CA>
 <20100914173154.GC2409@fieldses.org>
 <20100914184044.GA30454@jay.phy.QueensU.CA>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100914184044.GA30454@jay.phy.QueensU.CA>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 14, 2010 at 02:40:44PM -0400, Peter Skensved wrote:
>  Thanks for the reply.  The current RedHat EL5 kernels are all based on 2.6.18 with
> a lot of backported fixes so I'm not sure what version of the NFS code I'm effectively
> running.
> 
>  Do you know what the state_owners are used for ? What puzzles me is that in our case

They represent some notion of "who" is performing an open, or performing
a lock.

> we have a large number of workstations which NFS mounts some fairly large, mostly static
> common directories and automounts HOME directories. So I would expect the amount of state
> info that needs to be kept would be fairly constant. When the automounter unmounts the
> info ought to go away . Yet the number of stateowners for the most part just keep on
> growing. 
> 
>  The only work around at the moment is to reboot before it has eaten up around 500 Mb
> of slabs

Is someone doing a lot of file locking?

I can't remember the logic the server uses to decide when to throw away
a lockowner, but it may just be inadequate.

The client has also had some fixes recently to be better about telling
the server when to throw them away.

--b.
