Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:42325 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686Ab2HONjd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2012 09:39:33 -0400
Message-ID: <502BA6B4.9020106@gmail.com>
Date: Wed, 15 Aug 2012 15:40:04 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
CC: "Eric W. Biederman" <ebiederm@xmission.com>, torvalds@linux-foundation.org,
        tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH 02/16] user_ns: use new hashtable implementation
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com> <1344961490-4068-3-git-send-email-levinsasha928@gmail.com> <87txw5hw0s.fsf@xmission.com> <502AF184.4010907@gmail.com> <87393phshy.fsf@xmission.com> <502AFCD5.6070104@gmail.com> <87obmchmpu.fsf@xmission.com> <20120815033155.GA32653@Krystal>
In-Reply-To: <20120815033155.GA32653@Krystal>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/15/2012 05:31 AM, Mathieu Desnoyers wrote:
> * Eric W. Biederman (ebiederm@xmission.com) wrote:
>> Sasha Levin <levinsasha928@gmail.com> writes:
>>
>>> On 08/15/2012 03:08 AM, Eric W. Biederman wrote:
>>>>> I can offer the following: I'll write a small module that will hash 1...10000
>>>>>> into a hashtable which uses 7 bits (just like user_ns) and post the distribution
>>>>>> we'll get.
>>>> That won't hurt.  I think 1-100 then 1000-1100 may actually be more
>>>> representative.  Not that I would mind seeing the larger range.
>>>> Especially since I am in the process of encouraging the use of more
>>>> uids.
>>>>
>>>
>>> Alrighty, the results are in (numbers are objects in bucket):
>>>
>>> For the 0...10000 range:
>>>
>>> Average: 78.125
>>> Std dev: 1.4197704151
>>> Min: 75
>>> Max: 80
>>>
>>>
>>> For the 1...100 range:
>>>
>>> Average: 0.78125
>>> Std dev: 0.5164613088
>>> Min: 0
>>> Max: 2
>>>
>>>
>>> For the 1000...1100 range:
>>>
>>> Average: 0.7890625
>>> Std dev: 0.4964812206
>>> Min: 0
>>> Max: 2
>>>
>>>
>>> Looks like hash_32 is pretty good with small numbers.
>>
>> Yes hash_32 seems reasonable for the uid hash.   With those long hash
>> chains I wouldn't like to be on a machine with 10,000 processes with
>> each with a different uid, and a processes calling setuid in the fast
>> path.
>>
>> The uid hash that we are playing with is one that I sort of wish that
>> the hash table could grow in size, so that we could scale up better.
> 
> Hi Eric,
> 
> If you want to try out something that has more features than a basic
> hash table, already exists and is available for you to play with, you
> might want to have a look at the RCU lock-free resizable hash table.
> It's initially done in userspace, but shares the same RCU semantic as
> the kernel, and has chunk-based kernel-friendly index backends (thanks
> to Lai Jiangshan), very useful to integrate with the kernel page
> allocator.

I'm guessing that once this static hashtable is stable, a
DEFINE_DYNAMIC_HASHTABLE() will get introduced which will evolve into something
similar to what Mathieu has pointed out in the urcu.

