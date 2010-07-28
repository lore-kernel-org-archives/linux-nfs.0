Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([80.12.242.26]:17842 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751006Ab0G1TVB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jul 2010 15:21:01 -0400
Message-ID: <4C508330.8010303@orange.fr>
Date: Wed, 28 Jul 2010 21:21:20 +0200
From: Sebastien Godard <sysstat@orange.fr>
To: Or Gerlitz <ogerlitz@Voltaire.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: iostat "await" like counter for measuring nfs latency
References: <Pine.LNX.4.64.1007271300180.2110@zuben.voltaire.com> <1280244478.2981.3.camel@heimdal.trondhjem.org> <4C4FFC2B.4020906@Voltaire.com> <4C506B78.7040108@oracle.com>
In-Reply-To: <4C506B78.7040108@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/28/2010 07:40 PM, Chuck Lever wrote:
>
> On 07/28/10 05:45 AM, Or Gerlitz wrote:
>> Trond Myklebust wrote:
>>> On Tue, 2010-07-27 at 13:07 +0300, Or Gerlitz wrote:
>>>> Doing some iscsi and nfs performance testing, I realized that 
>>>> iostat(1)
>>>> doesn't support an "await" like counter for measuring nfs latency.
>>>> Can tracking nfs latency be done in other means? is there a plan to
>>>> extend the nfs iostats code to include such/similar counter?
>>
>>> The information is already available in /proc/self/mountstats. It is up
>>> to iostat to start using it.
>>
>> Sebastian, is there a plan to support await like counter in sysstat?
>>
>> I didn't find a source repository (is there an open one? where?) so
>> downloaded the latest code (version 9.1.3) drop from the website and
>> couldn't see there such a counter, am I missing something?
>
> There are Python scripts in nfs-utils that report the statistics in 
> /proc/self/mountstats.  Nobody really likes the file format of 
> /proc/self/mountstats, so the plan is to move these, at some point, to 
> someplace where perf can report them.
>
> At that point, iostat support would also be nice.
>

I'm ready to accept a patch that would add an await like counter to 
measure NFS latency.
BTW beginning with sysstat version 9.1.3, there is a specific command 
("nfsiostat") aimed at displaying stats for network filesystems.

Regards,

-- 
Sébastien Godard (sysstat<at>  orange.fr)
Help support sysstat...!
Visit http://pagesperso-orange.fr/sebastien.godard/




