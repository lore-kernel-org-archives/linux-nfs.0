Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42519 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752802Ab0FGSlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 14:41:32 -0400
Message-ID: <4C0D3D59.4000305@panasas.com>
Date: Mon, 07 Jun 2010 21:41:29 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: sfaibish <sfaibish@emc.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Performance results with exofs
References: <op.vdxrrgf1unckof@usensfaibisl2e.eng.emc.com> <4C0D195B.8030401@panasas.com> <4C0D1AAB.4070304@panasas.com> <op.vdxxhfqsunckof@usensfaibisl2e.eng.emc.com> <20100607182948.GF25257@fieldses.org>
In-Reply-To: <20100607182948.GF25257@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2010 09:29 PM, J. Bruce Fields wrote:
>>> On 06/07/2010 07:07 PM, Boaz Harrosh wrote:
>>>> I did not yet publish the Document. It's stuck behind my dis-talent for
>>>> writing and the pnfs bugs de jur.
> 
> Untalented writing we can fix, as long as the details are there!
> 
>>>>
>>>> Basically all machines:
>>>> - connected by a 1 GBit link.
>>>> - All clients doing a dd write of 8GB file from /dev/zero
>>>> - 3of8 is the special raid-groups arrangement of exofs && objlayout
>>>>   where out of 8 devices each file is striped over 3 devices in a
>>>>   round robin fashion. (*With a small dirty trick)
> 
> Random stupid questions:
> 
> 	- why do you think the 3of8 arrangement is scaling better than
> 	  the 8of8?

It's a know problem with a network storage cluster. What happens is
that with 8of8 all the clients exercise all of the nodes at the same
time so they are clashing on the network.

With 3of8 each node can still saturate it's link. (3 was chosen carefully from the
first test) and some nodes talk to some OSDs while other talk to other, so there is
more chance of pairs * 1GBit at the same time.

(The dirty trick I did was insert dummy files so the 4 client test will exercise all
 8 devices. Otherwise the stupid exofs round robin algorithm would only exercise 4+3
 devices.)

> 	- Have you tried any other workloads?  (Perfectly reasonable
> 	  that simple write throughput would be the first thing to
> 	  check--I'm just curious.)

Never got to it. Busy with Bakeathon preparations. Would like too very much

Thanks
Boaz

> 
>>>>
>>>
>>> - All tests over an *empty* filesystem.
>>>
>>>> [single client]
>>>> 1 - osds 40MB
>>>> 2 - osds 80MB
>>>> 4 - osds 114MB (saturation point of the 1 Gbit link)
>>>> 8 - osds 114MB
>>>>
>>>> [2 clients 8of8 osds]
>>>> 226 MBs
>>>>
>>>> [4 clients 8of8 osds]
>>>> 263 MBs
>>>>
>>>> [8 clients 8of8 osds]
>>>> 252 MBs
>>>>
>>>> [1 clients 3of8 osds]
>>>> 114 MBs
>>>>
>>>> [2 clients 3of8 osds *]
>>>> 226 MBs
>>>>
>>>> [4 clients 3of8 osds *]
>>>> 417 MBs
> 
> If each osd has a single gigabit interface, and you're striping to 3, of
> them, isn't that 417/3 == 139 MB/s each?
> 
> (Oh, I see: you must be writing to a different file from each client,
> hence you are using all osd's even if each client is only using 3?)
> 
> --b.
> 
>>>>
>>>> [8 clients 3of8 osds]
>>>> 405 MBs

