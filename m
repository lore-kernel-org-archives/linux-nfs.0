Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40764 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab2HOBep (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 21:34:45 -0400
Message-ID: <502AFCD5.6070104@gmail.com>
Date: Wed, 15 Aug 2012 03:35:17 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
To: "Eric W. Biederman" <ebiederm@xmission.com>
CC: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, aarcange@redhat.com, ericvh@gmail.com,
        netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com,
        mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH 02/16] user_ns: use new hashtable implementation
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com> <1344961490-4068-3-git-send-email-levinsasha928@gmail.com> <87txw5hw0s.fsf@xmission.com> <502AF184.4010907@gmail.com> <87393phshy.fsf@xmission.com>
In-Reply-To: <87393phshy.fsf@xmission.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/15/2012 03:08 AM, Eric W. Biederman wrote:
>> I can offer the following: I'll write a small module that will hash 1...10000
>> > into a hashtable which uses 7 bits (just like user_ns) and post the distribution
>> > we'll get.
> That won't hurt.  I think 1-100 then 1000-1100 may actually be more
> representative.  Not that I would mind seeing the larger range.
> Especially since I am in the process of encouraging the use of more
> uids.
> 

Alrighty, the results are in (numbers are objects in bucket):

For the 0...10000 range:

Average: 78.125
Std dev: 1.4197704151
Min: 75
Max: 80


For the 1...100 range:

Average: 0.78125
Std dev: 0.5164613088
Min: 0
Max: 2


For the 1000...1100 range:

Average: 0.7890625
Std dev: 0.4964812206
Min: 0
Max: 2


Looks like hash_32 is pretty good with small numbers.
