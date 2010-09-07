Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41304 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab0IGXSk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 19:18:40 -0400
Message-ID: <4C86C847.5060204@candelatech.com>
Date: Tue, 07 Sep 2010 16:18:31 -0700
From: Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RFC:  support srcaddr= option to bind to local IPs.
References: <4C81449B.4010900@candelatech.com>	 <1283882166.2788.48.camel@heimdal.trondhjem.org>	 <4C86A36E.9010906@candelatech.com>	 <1283892851.2788.107.camel@heimdal.trondhjem.org>	 <4C86AA2F.7080906@candelatech.com> <1283893975.9097.2.camel@heimdal.trondhjem.org>
In-Reply-To: <1283893975.9097.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/07/2010 02:12 PM, Trond Myklebust wrote:
> On Tue, 2010-09-07 at 14:10 -0700, Ben Greear wrote:
>> On 09/07/2010 01:54 PM, Trond Myklebust wrote:

>>> No. As I said, it needs to match the clientaddr argument, not the
>>> srcaddr.
>>>
>>> The problem is that you are now potentially introducing cases where the
>>> server may have multiple combinations of clientaddr and srcaddr.
>>
>> Ok, so what do you think about allowing a flag to bind() to clientaddr
>> instead of having the separate srcaddr option?
>
> That might be slightly less intrusive, but I'm still unconvinced it is
> something we need to support in the upstream kernels.

It seems clientaddr is saved as a string instead of a struct sockaddr_storage,
which means doing conversion in lots of places.  So, using a bindclient flag
and clientaddr would be even trickier than my srcaddr= approach.

I can still try to get that working if that's the only hurdle to upstream
inclusion, but if it's all for my own use, I'm just going to use the same
api as for cifs, and ensure the caller always uses same thing for srcaddr
and clientaddr.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

