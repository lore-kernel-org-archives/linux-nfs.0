Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44634 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab0IGVKM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 17:10:12 -0400
Message-ID: <4C86AA2F.7080906@candelatech.com>
Date: Tue, 07 Sep 2010 14:10:07 -0700
From: Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RFC:  support srcaddr= option to bind to local IPs.
References: <4C81449B.4010900@candelatech.com>	 <1283882166.2788.48.camel@heimdal.trondhjem.org>	 <4C86A36E.9010906@candelatech.com> <1283892851.2788.107.camel@heimdal.trondhjem.org>
In-Reply-To: <1283892851.2788.107.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/07/2010 01:54 PM, Trond Myklebust wrote:
> On Tue, 2010-09-07 at 13:41 -0700, Ben Greear wrote:
>> On 09/07/2010 10:56 AM, Trond Myklebust wrote:
>>> On Fri, 2010-09-03 at 11:55 -0700, Ben Greear wrote:
>>>> This patch lets one bind the local side of NFS sockets to a particular
>>>> IP address.  This can be useful for users on multi-homed systems.
>>>>
>>>> This patch must be on top of the previous patch to fix the IPv6 address
>>>> comparison or it will not work.
>>>>
>>>> Comments and suggestions welcome...I'll incorporate those and post an
>>>> official signed-off patch after that.
>>>>
>>>> Thanks,
>>>> Ben
>>>>
>>>
>>> The code in nfs_callback_authenticate is going to break NFSv4 callbacks.
>>> Callbacks are sent to the -oclientaddr address, not srcaddr (btw, I
>>> really dislike that new boolean argument to nfs_find_client(). If you
>>> don't want to compare the source address, then have the caller pass a
>>> NULL pointer).
>>
>>
>> Would this fix the callback issue you speak of?  The idea is to
>> use source and dest to match if it exists, but if we find one
>> where server address matches and srcaddr isn't specified,
>> then we will use that.
>
> No. As I said, it needs to match the clientaddr argument, not the
> srcaddr.
>
> The problem is that you are now potentially introducing cases where the
> server may have multiple combinations of clientaddr and srcaddr.

Ok, so what do you think about allowing a flag to bind() to clientaddr
instead of having the separate srcaddr option?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

