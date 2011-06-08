Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47824 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952Ab1FHTR5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 15:17:57 -0400
Message-ID: <4DEFCAE3.2010107@candelatech.com>
Date: Wed, 08 Jun 2011 12:17:55 -0700
From: Ben Greear <greearb@candelatech.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com> <20110608191155.GB6752@fieldses.org>
In-Reply-To: <20110608191155.GB6752@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/08/2011 12:11 PM, J. Bruce Fields wrote:
> On Wed, Jun 08, 2011 at 10:39:08AM -0700, greearb@candelatech.com wrote:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This lets one specify the source IP address for
>> sockets, allowing users to leverage routing rules
>> on multi-homed systems.
>>
>> Kernel patches to RPC and NFS are needed to complete
>> full functionality.
>
> Possibly dumb question: there's an ongoing effort (I think--haven't
> heard much from them recently?) to make the nfs and rpc code aware of
> which network namespace it's running in.  Would that do what you need?

No, that doesn't help me.  But, this effort shouldn't hurt
any namespace users, and perhaps it would even help.

> Does statd need changes too?

I don't know.  With this nfs-utils patch, and my kernel
changes, I was able to direct traffic out a specific
interface across a routed network to an nfs server
and do reads/writes.

(The default route was out a different interface, so
the binding and routing rules appear to work for all
needed communication.)

As long as there is a chance of getting this in, I plan to
clean up my kernel patches, break them into smaller chunks,
and post a series for consideration.

I'm not sure that the nfs-utils changes are actually that
useful w/out the kernel changes, but at least it shouldn't
hurt anything.

Thanks,
Ben

>
> --b.


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

