Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:41556 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680Ab2JaAeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Oct 2012 20:34:05 -0400
MIME-Version: 1.0
In-Reply-To: <20121030214257.GB2681@htj.dyndns.org>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com> <20121030214257.GB2681@htj.dyndns.org>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Tue, 30 Oct 2012 20:33:43 -0400
Message-ID: <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com,
        axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 30, 2012 at 5:42 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> Just some nitpicks.
>
> On Tue, Oct 30, 2012 at 02:45:57PM -0400, Sasha Levin wrote:
>> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
>> +#define hash_min(val, bits)                                                  \
>> +({                                                                           \
>> +     sizeof(val) <= 4 ?                                                      \
>> +     hash_32(val, bits) :                                                    \
>> +     hash_long(val, bits);                                                   \
>> +})
>
> Doesn't the above fit in 80 column.  Why is it broken into multiple
> lines?  Also, you probably want () around at least @val.  In general,
> it's a good idea to add () around any macro argument to avoid nasty
> surprises.

It was broken to multiple lines because it looks nicer that way (IMO).

If we wrap it with () it's going to go over 80, so it's going to stay
broken down either way :)


Thanks,
Sasha

> Looks good to me otherwise.
>
>  Reviewed-by: Tejun Heo <tj@kernel.org>
>
> Thanks.
>
> --
> tejun
