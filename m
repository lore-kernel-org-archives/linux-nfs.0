Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13651 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751749Ab0ISOMf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Sep 2010 10:12:35 -0400
Message-ID: <4C961A50.5010000@panasas.com>
Date: Sun, 19 Sep 2010 16:12:32 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Sorin Faibish <sfaibish@emc.com>, "Peter Honeyman" <Honey@citi.umich.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: Discussion topics for the coming Bake-A-Thon
References: <op.vi7c6cmorwwil4@sfaibish1.corp.emc.com>
In-Reply-To: <op.vi7c6cmorwwil4@sfaibish1.corp.emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/18/2010 02:33 AM, Sorin Faibish wrote:
> All,
> 
> I am trying to build an agenda for discussions during the coming  
> Bake-A-Thon
> at EMC October 4-8. I collected the last week several topics of interest  
> and
> I want to ask you all to add any other topics of interest so I can close  
> the
> agenda of the event. This is the list so far:
> 
> 1. Layoutcommit for file layout (Dave Noveck)
> 2. Server side copy - (James)
> 3. Sparse files and storage preferences (Dean, Sorin)
> 4. Secure NFS (David Quigly)
> 5. Extend cthon tests with callback operations tests (Peter Honeyman)

     And local/remote truncate torture tests.

> 6. Performance tests - tools and benchmarks (Peter Honeyman)

to 6 or 5. Cluster tests. .i.e use of more then one client in concertration
to confuse and crash a server.

> 7. Utils and fedora rpm (Sorin, SteveD)
> 8. pNFS with IPv6 (Sorin)
> 9. Linux FedFS imlementation (Chuck)
> 
> I will allocate 30min for each topic and group them in 2 hours sessions
> mostly in the early PM after lunch.
> 
> Please feel free to add any additional topics and thank you for your  
> patience.
> 
> /Sorin
> 


Thanks
Boaz
