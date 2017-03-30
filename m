Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:45259 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933150AbdC3RlX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Mar 2017 13:41:23 -0400
Subject: Re: [PATCH 1/1] NFSv4.1 fix infinite loop on IO BAD_STATEID error
To: Olga Kornievskaia <aglo@umich.edu>
References: <20170330140051.61886-1-kolga@netapp.com>
 <bdff27b8-152d-69dd-8dc1-0452aeff645d@Netapp.com>
 <CAN-5tyG3cVsBRuNu5D_rsPFbQkaWhbZ6DQpKw70ksxq6ArPaEg@mail.gmail.com>
CC: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <367ad3d3-8aec-baeb-04a6-06348c2eb5b7@Netapp.com>
Date: Thu, 30 Mar 2017 13:41:11 -0400
MIME-Version: 1.0
In-Reply-To: <CAN-5tyG3cVsBRuNu5D_rsPFbQkaWhbZ6DQpKw70ksxq6ArPaEg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/30/2017 01:37 PM, Olga Kornievskaia wrote:
> On Thu, Mar 30, 2017 at 1:26 PM, Anna Schumaker
> <Anna.Schumaker@netapp.com> wrote:
>> Hi Olga,
>>
>> On 03/30/2017 10:00 AM, Olga Kornievskaia wrote:
>>> Commit 02bfab0414d7 "NFSv4.1: Don't recheck delegations that
>>> have already been checked" introduced a regression where when a
>>> client received BAD_STATEID error it would not send any TEST_STATEID
>>> and instead go into an infinite loop of resending the IO that caused
>>> the BAD_STATEID.
>>
>> Can you double check the bad commit?  I found it as 63d63cbf5e03 and not 02bfab0414d7.
> 
> Oops. my bad.
> 
>>
>>>
>>> Fixes: 02bfab0414d7 ("NFSv4.1: Don't recheck delegations that have already been checked")
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>>  fs/nfs/nfs4proc.c | 1 +
>>>  1 file changed, 1 insertion(+)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index dfa46e4..fb6d981 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -2460,6 +2460,7 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
>>>       }
>>>
>>>       if (!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags)) {
>>> +             nfs_finish_clear_delegation_stateid(state, &stateid);
>>>               rcu_read_unlock();
>>
>> The NFS_DELEGATION_REVOKED case does the rcu_read_unlock() before the call to nfs_finish_clear_delegation_stateid().  I'm not sure how much of a difference it makes, but can you swap the order of the calls here to match?
> 
> Ok can do. While I'm at it, both if() do the same thing. Should they
> be squashed?

I like the sound of that even better, thanks! :)

> 
>>
>> Thanks,
>> Anna
>>
>>>               return;
>>>       }
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
