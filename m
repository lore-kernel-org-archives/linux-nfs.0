Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:55359 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab3ARWvV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 17:51:21 -0500
Message-ID: <50F9D1E7.4080203@candelatech.com>
Date: Fri, 18 Jan 2013 14:51:19 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question on nfs40_discover_server_trunking.
References: <50F9BE66.6080608@candelatech.com> <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com> <50F9C5B4.5020000@candelatech.com> <1A56CC87-38FF-47B4-9CA9-7BAE394AF0D2@oracle.com> <50F9CDDF.4070609@candelatech.com> <D275BA48-F082-424C-9DC6-A7ABAF6A4578@oracle.com>
In-Reply-To: <D275BA48-F082-424C-9DC6-A7ABAF6A4578@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/18/2013 02:43 PM, Chuck Lever wrote:
>
> On Jan 18, 2013, at 5:34 PM, Ben Greear <greearb@candelatech.com> wrote:
>
>> On 01/18/2013 02:29 PM, Chuck Lever wrote:
>>>
>>> On Jan 18, 2013, at 4:59 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>
>>>> On 01/18/2013 01:33 PM, Chuck Lever wrote:
>>>>>
>>>>> On Jan 18, 2013, at 4:28 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>>>
>>>>>> Any chance the STALE_CLIENTID case needs a 'break'?
>>>>>
>>>>> I don't think so.  LEASE_CONFIRM is set, and we want to wake the state renewal thread.
>>>>>
>>>>>>
>>>>>> Twice I've seen kernel crashes after the nfs40_walk_client_list
>>>>>> failed (though code comments say it should never fail).
>>>>>
>>>>> nfs40_walk_client_list() is looking for an nfs_client that is supposed to already be in the nfs_client list.  If the search fails, that's a bug.
>>>>>
>>>>> Eyeball the contents of your nfs_client list.  You should find an appropriate nfs_client in there, and then figure out why the search doesn't find it.
>>>>
>>>> Ok, I think I found another issue.
>>>>
>>>> nfs4_client_init does not initialize 'old', but passes it to nfs4_discover_server_trunking.
>>>>
>>>> That gets passed to the detect_trunking operation, which is nfs40_discover_server_trunking
>>>> or nfs41_discover_server_trunking.
>>>
>>> Yes, *result is an output parameter, not an input parameter.
>>>
>>>> This will call walk_client_list, which also may not ever assign a value to
>>>> 'result'.
>>>
>>> It should always assign *result in the SUCCESS case.
>>>
>>>> The code in walk_client_list always dereferences result, however.
>>>>
>>>> So, that is probably why my system blows up shortly after the 'impossible'
>>>> error message...
>>>
>>> In particular, nfs4_walk_client_list() does not set *result when it returns NFS4ERR_STALE_CLIENTID.  In nfs4_discover_server_trunking(), should we therefore have this:
>>>
>>>       status = nfs40_walk_client_list(clp, result, cred);
>>>       switch (status) {
>>>       case -NFS4ERR_STALE_CLIENTID:
>>>               set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
>>>>>            nfs4_schedule_state_renewal(clp);
>>>>>            break;
>>>       case 0:
>>>
>>> I'm not sure the nfs4_schedule_state_renewal() call is necessary here.
>>
>>
>> I'm not sure I follow you entirely..but I'm going to start testing this patch in
>> a minute.  Looks like it should fix my crash, and maybe give clues about
>> why we get to the error case in the first place.
>>
>>
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index d6b39a9..3188283 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -307,6 +307,8 @@ int nfs40_walk_client_list(struct nfs_client *new,
>>         };
>>         int status;
>>
>> +       *result = NULL;
>> +
>>         spin_lock(&nn->nfs_client_lock);
>>         list_for_each_entry_safe(pos, n, &nn->nfs_client_list, cl_share_link) {
>>                 /* If "pos" isn't marked ready, we can't trust the
>> @@ -364,6 +366,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
>>                 nfs_put_client(prev);
>>         spin_unlock(&nn->nfs_client_lock);
>>         pr_err("NFS: %s Error: no matching nfs_client found\n", __func__);
>> +       WARN_ON(1);
>>         return -NFS4ERR_STALE_CLIENTID;
>> }
>>
>> @@ -433,6 +436,8 @@ int nfs41_walk_client_list(struct nfs_client *new,
>>         struct nfs_client *pos, *n, *prev = NULL;
>>         int error;
>>
>> +       *result = NULL;
>> +
>
> The design of this code is that output parameters should never be touched except in the "success" case.
>
>>         spin_lock(&nn->nfs_client_lock);
>>         list_for_each_entry_safe(pos, n, &nn->nfs_client_list, cl_share_link) {
>>                 /* If "pos" isn't marked ready, we can't trust the
>> @@ -489,6 +494,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
>>          */
>>         spin_unlock(&nn->nfs_client_lock);
>>         pr_err("NFS: %s Error: no matching nfs_client found\n", __func__);
>> +       WARN_ON(1);
>>         return -NFS4ERR_STALE_CLIENTID;
>> }
>> #endif /* CONFIG_NFS_V4_1 */
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index c351e6b..54d29e2 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -142,7 +142,8 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
>>         case 0:
>>                 /* Sustain the lease, even if it's empty.  If the clientid4
>>                  * goes stale it's of no use for trunking discovery. */
>> -               nfs4_schedule_state_renewal(*result);
>> +               if (*result)
>> +                       nfs4_schedule_state_renewal(*result);
>
> In the STALE_CLIENTID case, this would do state renewal on the wrong nfs_client.
>
>>                 break;
>>         }
>
> Let's look at this again:
>
>   138         status = nfs40_walk_client_list(clp, result, cred);
>   139         switch (status) {
>   140         case -NFS4ERR_STALE_CLIENTID:
>   141                 set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
>
> This arm of the switch operates on "clp" not on "*result".  So we want to add:
>
>         nfs4_schedule_state_renewal(clp);
>         break;
>
> That makes initializing *result above completely unnecessary.

Ok, I'll test that, but I still think the result pointer should be initialized
somewhere.  If a bug like this ever creeps in again, dereferencing a NULL
pointer should be a lot more obvious than dereferencing some random thing.


>
>   142         case 0:
>   143                 /* Sustain the lease, even if it's empty.  If the clientid4
>   144                  * goes stale it's of no use for trunking discovery. */
>   145                 nfs4_schedule_state_renewal(*result);
>   146                 break;
>   147         }
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

