From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: iostat "await" like counter for measuring nfs latency
Date: Thu, 29 Jul 2010 11:53:10 -0400
Message-ID: <4C51A3E6.4000101@oracle.com>
References: <Pine.LNX.4.64.1007271300180.2110@zuben.voltaire.com> <1280244478.2981.3.camel@heimdal.trondhjem.org> <4C4FFC2B.4020906@Voltaire.com> <4C506B78.7040108@oracle.com> <4C508330.8010303@orange.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Or Gerlitz <ogerlitz-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Sebastien Godard <sysstat@orange.fr>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:36434 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416Ab0G2PyQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jul 2010 11:54:16 -0400
In-Reply-To: <4C508330.8010303@orange.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/28/10 03:21 PM, Sebastien Godard wrote:
> On 07/28/2010 07:40 PM, Chuck Lever wrote:
>>
>> On 07/28/10 05:45 AM, Or Gerlitz wrote:
>>> Trond Myklebust wrote:
>>>> On Tue, 2010-07-27 at 13:07 +0300, Or Gerlitz wrote:
>>>>> Doing some iscsi and nfs performance testing, I realized that
>>>>> iostat(1)
>>>>> doesn't support an "await" like counter for measuring nfs latency.
>>>>> Can tracking nfs latency be done in other means? is there a plan to
>>>>> extend the nfs iostats code to include such/similar counter?
>>>
>>>> The information is already available in /proc/self/mountstats. It is up
>>>> to iostat to start using it.
>>>
>>> Sebastian, is there a plan to support await like counter in sysstat?
>>>
>>> I didn't find a source repository (is there an open one? where?) so
>>> downloaded the latest code (version 9.1.3) drop from the website and
>>> couldn't see there such a counter, am I missing something?
>>
>> There are Python scripts in nfs-utils that report the statistics in
>> /proc/self/mountstats. Nobody really likes the file format of
>> /proc/self/mountstats, so the plan is to move these, at some point, to
>> someplace where perf can report them.
>>
>> At that point, iostat support would also be nice.
>>
>
> I'm ready to accept a patch that would add an await like counter to
> measure NFS latency.

What is await, precisely?

And, by "NFS latency" do you mean read/write latency or something else? 
  For NFS, even stat() can require server interaction (ie is not served 
from the system's local memory)

> BTW beginning with sysstat version 9.1.3, there is a specific command
> ("nfsiostat") aimed at displaying stats for network filesystems.
