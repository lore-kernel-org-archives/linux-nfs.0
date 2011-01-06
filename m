Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:35838 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526Ab1AFHdo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 02:33:44 -0500
Message-ID: <4D257054.8080807@parallels.com>
Date: Thu, 6 Jan 2011 01:33:40 -0600
From: Rob Landley <rlandley@parallels.com>
To: Daniel Stodden <daniel.stodden@citrix.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Cache flush question.
References: <1294130649.3529.96.camel@ramone>	 <1294151542.3389.7.camel@heimdal.trondhjem.org> <1294269347.29719.1673.camel@agari.van.xensource.com>
In-Reply-To: <1294269347.29719.1673.camel@agari.van.xensource.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/05/2011 05:15 PM, Daniel Stodden wrote:
> On Tue, 2011-01-04 at 09:32 -0500, Trond Myklebust wrote:
>> On Tue, 2011-01-04 at 00:44 -0800, Daniel Stodden wrote:
>>> Hi anyone.
>>>
>>> If somebody's got a sec to enlighten me, there's some phenomenon I
>>> recently came across and found somewhat counterintuitive first.
>>>
>>> Whenever I
>>>
>>>   1. Dirty a bunch of pages backed by an NFS mount on some server.
>>>
>>>   2. Block the traffic with iptables (TCP, assuming that mattered).
>>>      Still plenty of writeback pending.
>>>
>>>   3. Sync
>>>
>>> I see #3 drive the dirty count in /proc/meminfo drop back to
>>> almost-zero, immediately. The sync itself blocks, though.
>>>
>>> So the pages are called clean the moment the write got queued, not
>>> acked? Leaving the rest just to retransmits by the socket then? Is this
>>> just done so because one can, or would that order rather matter for
>>> consistency?
>>
>> Take a look at the 'Writeback:' count, which should turn non-zero when
>> you hit #3.
>>
>> The VM allows pages to be either dirty or in writeback, but not both at
>> the same time. This is not NFS-specific. The same rule applies to local
>> filesystems.
>
> Ah. That explains everything. Actually a question then, thanks for the
> clarification :)
>
> Rob Landley's comment regarding tx queue size somewhat made a good point
> too.

Not nearly as good as I thought at the time.

 > But, given the rates I see, this queues mostly cache pages on the
> transport, not copies, right?

Easy enough to tell: there's a "Writeback" field in /proc/meminfo.  Add 
'em up and see what's missing.

Rob
