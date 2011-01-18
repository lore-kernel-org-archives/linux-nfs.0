Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19857 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457Ab1ARSf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 13:35:29 -0500
Message-ID: <4D35DD69.2040902@panasas.com>
Date: Tue, 18 Jan 2011 20:35:21 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Daniel.Muntz@emc.com, rees@umich.edu, androsadamson@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: 4.1 no-pnfs mount option?
References: <20110114151945.GA21629@merit.edu>	 <AANLkTimSp6BTgk1YQonXd6HuVS-JEpQUWqsny7JymJsd@mail.gmail.com>	 <20110114153846.GA21766@merit.edu>	 <1295019712.3576.1.camel@heimdal.trondhjem.org>	 <DE966DA98A4ABE438D726BDF1699CF61043985B53F@MX05A.corp.emc.com> <1295375309.3746.25.camel@heimdal.trondhjem.org>
In-Reply-To: <1295375309.3746.25.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-01-18 20:28, Trond Myklebust wrote:
> On Tue, 2011-01-18 at 12:44 -0500, Daniel.Muntz@emc.com wrote: 
>>
>>> -----Original Message-----
>>> From: linux-nfs-owner@vger.kernel.org 
>>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
>>> Sent: Friday, January 14, 2011 7:42 AM
>>> To: Jim Rees
>>> Cc: William A. (Andy) Adamson; linux-nfs@vger.kernel.org
>>> Subject: Re: 4.1 no-pnfs mount option?
>>>
>>> On Fri, 2011-01-14 at 10:38 -0500, Jim Rees wrote: 
>>>> William A. (Andy) Adamson wrote:
>>>>
>>>>   No mount option - just configure your machine to not load any pnfs
>>>>   layoutdriver modules.
>>>>
>>>> That works, thanks, but I was hoping for a way to have 
>>> layout and non-layout
>>>> mounts going on at the same time.
>>>
>>> Different VMs?
>>>
>>> Trond
>>
>> Would there be any objections to adding a "nopnfs" mount option to force this behavior?  It could be useful at least for testing, possibly for working around server problems, or if an admin knows that certain clients' usage patterns would be better served by disabling pnfs.
> 
> Yes. Why should we be adding debugging mount options to the upstream
> code? Just test the damned pnfs code properly before it goes upstream...
> 
> Trond

Such a mount option could be useful for dealing with buggy servers (pnfs-wise) so you
could mount one server with pnfs and another without.

Benny
