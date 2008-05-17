From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Fri, 16 May 2008 19:25:19 -0700
Message-ID: <67F2C25D-DCE9-45D3-A077-5450CC72AB5F@oracle.com>
References: <20080509011918.GK12690@fieldses.org> <1210309839.8657.0.camel@localhost> <20080509152750.GA325@fieldses.org> <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org> <20080509235930.GM1907@fieldses.org> <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com> <1210440728.12927.5.camel@localhost> <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com> <1d07ca700805101807s7c034b08sc531993aa81010b2@mail.gmail.com> <20080516195326.GD14228@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "david m. richter" <richterd@gmail.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Manoj Naik <manoj@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62915 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbYEQC3X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 May 2008 22:29:23 -0400
In-Reply-To: <20080516195326.GD14228@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 16, 2008, at 12:53 PM, J. Bruce Fields wrote:
> On Sat, May 10, 2008 at 09:07:23PM -0400, david m. richter wrote:
>> On Sat, May 10, 2008 at 7:50 PM, Chuck Lever  
>> <chuck.lever@oracle.com> wrote:
>>> On May 10, 2008, at 10:32 AM, Trond Myklebust wrote:
>>>>
>>>> On Fri, 2008-05-09 at 19:29 -0700, Chuck Lever wrote:
>>>>>
>>>>> Should you use in4_pton() instead?
>>>>
>>>> Can we rather convert this to use nfs_parse_server_address? We  
>>>> don't
>>>> need 10 different ways to parse text addresses...
>>>
>>> I'm OK with that, as long as there isn't a technical problem with  
>>> using
>>> in4_pton().
>>
>> nfs_parse_server_address() uses in4_pton(), it just also groks ipv6.
>
> This is all a bit orthogonal to the actual bug, as all those functions
> want null-terminated strings too.
>
> We could apply the below (compile-tested only) and then add ipv6  
> support
> and converting to nfs_parse_server_address() in a subsequent patch.

It might make more sense to use the utility conversion functions that  
are already provided, but just guarantee that we always pass them a  
null-terminated string.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
