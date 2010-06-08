Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61040 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751789Ab0FHF0s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 01:26:48 -0400
Message-ID: <4C0DD495.5070908@panasas.com>
Date: Tue, 08 Jun 2010 08:26:45 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Welch, Brent" <welch@panasas.com>
CC: sfaibish <sfaibish@emc.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Performance results with exofs
References: <op.vdxrrgf1unckof@usensfaibisl2e.eng.emc.com> <4C0D195B.8030401@panasas.com> <4C0D1AAB.4070304@panasas.com> <op.vdxxhfqsunckof@usensfaibisl2e.eng.emc.com> <20100607182948.GF25257@fieldses.org> <4C0D3D59.4000305@panasas.com> <20100607184902.GI25257@fieldses.org>
In-Reply-To: <20100607184902.GI25257@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2010 09:49 PM, J. Bruce Fields wrote:
>>
>> It's a know problem with a network storage cluster. What happens is
>> that with 8of8 all the clients exercise all of the nodes at the same
>> time so they are clashing on the network.
> 
> OK, so if two clients are both trying to send a stripe of data to the
> same OSD data at the same time, absent a switch that could somehow
> afford to queue up a full stripe-unit's worth of data, packets get lost?
> 

It's tcp they don't get lost, per-se they just get queued up. And that tcp
ramp up and all that, you know. 

We use a 64k stripe unit with say raid of 4-8 that's 256k-1M bytes in a stripe.
I don't think a network buffer that big will help at all. It'll just delay
everything more. The best is a sound statistical network strategy that'll let
the system even out overall. (Or not ...)

> (Also, out of curiosity: do you know of any papers or documentation that
> describe that problem in more detail?)
> 

Personally, I'm privileged to learn from the best here at Panasas. 

CC: Brent, Can you recommend to Bruce some good papers about raid
groups and network SAN strategies? 

> --b.

Boaz
